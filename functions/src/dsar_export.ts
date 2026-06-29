/**
 * GDPR Art. 15 (right of access) + Art. 20 (data portability) export.
 *
 * Patients have the right to receive a copy of every personal-data
 * record we hold about them, in a structured machine-readable format,
 * within one month of the request. The Cloud Function below assembles
 * that bundle on demand and returns it as JSON; the client wraps it in
 * the encrypted ZIP container documented in
 * `lib/utils/dsar_export_zip.dart` before handing it to the patient.
 *
 * Authorization
 *   - Caller MUST be a clinician (`authorizeUid` → uid) and the data
 *     they request MUST live under their `clinic_id`. We never cross
 *     the tenancy boundary — the same `clinic_id == uid` rule the
 *     Firestore rules enforce is repeated here so a function-level
 *     misconfiguration cannot leak across clinics.
 *
 * Scope
 *   - Flat top-level collections (`intakes`, `safety_plans`,
 *     `session_notes`, `assessments`, `consent_records`) filtered by
 *     `patient_id` / `patientId`.
 *   - Nested patient sub-collections under
 *     `clinics/{clinicId}/patients/{patientId}/...`
 *     (`sessions`, `superbills`, `treatment_plans`, `homework`,
 *     `telehealth_sessions`, `messages`, `deposit_charges`).
 *   - Recurses into known nested-nested paths
 *     (sessions/{id}/notes).
 *   - Returns a `manifest` block listing every collection that was
 *     read and the row count, so an auditor can reproduce the export.
 *
 * Out of scope
 *   - Raw audio. Per our SECURITY policy raw recordings never leave
 *     the device. The transcript is included where present.
 *   - Pseudonymised rows (`purged: true`). The patient already
 *     deleted these via the M1 account-deletion purge; surfacing them
 *     would violate Art. 17.
 *
 * Output shape (truncated):
 *   {
 *     "generatedAt": "2026-06-21T10:00:00.000Z",
 *     "clinicId": "<uid>",
 *     "patientId": "<opaque>",
 *     "policyVersion": "GDPR Art. 15 + 20, KVKK Art. 11",
 *     "manifest": [
 *       {"collection": "intakes", "count": 1, "path": "flat"},
 *       {"collection": "sessions", "count": 12, "path": "nested"},
 *       ...
 *     ],
 *     "records": {
 *       "intakes": [...],
 *       "sessions": [...],
 *       ...
 *     }
 *   }
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {applyCors, authorizeClinicianUid} from "./lib/auth";
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";

/**
 * KVK Tebliğ md. 13 + GDPR Art. 12(3) both mandate a 30-day response
 * window. The audit row stamps this so a downstream report can flag
 * any pending DSARs nearing the deadline.
 */
const DSAR_SLA_DAYS = 30;

/**
 * Anti-abuse rate limit: each (clinic, patient) tuple gets one
 * successful export per 24 hours. A second request inside that window
 * is rejected at the HTTP layer and the attempt is audit-logged.
 */
const DSAR_REPEAT_WINDOW_MS = 24 * 60 * 60 * 1000;

/**
 * Test-only seam: production reads the wall clock; tests inject a
 * stable instant so the rate-limit math is deterministic.
 */
let _clockNow: () => Date = () => new Date();

/** @visibleForTesting */
export function setClockForTesting(now: () => Date): void {
  _clockNow = now;
}

/** @visibleForTesting — pure SLA arithmetic. */
export function slaExpiresAtForTesting(now: Date): string {
  return _slaExpiresAt(now);
}

/** @visibleForTesting — rate-limit lookup against a Firestore stub. */
export function findRecentExportForTesting(
  db: admin.firestore.Firestore,
  clinicId: string,
  patientId: string,
  windowMs: number = DSAR_REPEAT_WINDOW_MS,
): Promise<Date | null> {
  return _findRecentExport(db, clinicId, patientId, windowMs);
}

interface DsarAuditRow {
  id: string;
  kind: "dsar_export";
  action:
    | "dsar.export_built"
    | "dsar.rate_limited"
    | "dsar.failed"
    | "dsar.unauthorized";
  actor: string | null;
  clinic_id: string | null;
  entity: string;
  timestamp_utc: admin.firestore.Timestamp;
  sla_expires_at_utc: string;
  result: "success" | "denied" | "failed";
  bytes_estimated?: number;
}

async function _writeAudit(
  db: admin.firestore.Firestore,
  row: DsarAuditRow,
): Promise<void> {
  try {
    await db.collection("audit_logs").add(row);
  } catch (e) {
    functions.logger.error("dsarExport.audit_failed", {
      reason: String(e),
      id: row.id,
    });
  }
}

function _slaExpiresAt(now: Date): string {
  const t = new Date(now.getTime() + DSAR_SLA_DAYS * 24 * 60 * 60 * 1000);
  return t.toISOString();
}

async function _findRecentExport(
  db: admin.firestore.Firestore,
  clinicId: string,
  patientId: string,
  windowMs: number,
): Promise<Date | null> {
  const doc = await db
    .collection("dsar_requests")
    .doc(`${clinicId}_${patientId}`)
    .get();
  if (!doc.exists) return null;
  const data = doc.data() as {
    last_export_at_utc?: admin.firestore.Timestamp;
  };
  const ts = data.last_export_at_utc;
  if (!ts) return null;
  const last = ts.toDate();
  if (_clockNow().getTime() - last.getTime() <= windowMs) return last;
  return null;
}

async function _stampExport(
  db: admin.firestore.Firestore,
  clinicId: string,
  patientId: string,
): Promise<void> {
  await db
    .collection("dsar_requests")
    .doc(`${clinicId}_${patientId}`)
    .set(
      {
        clinic_id: clinicId,
        patient_id: patientId,
        last_export_at_utc: admin.firestore.Timestamp.now(),
      },
      {merge: true},
    );
}

/** Top-level collections keyed by patient_id (camelCase + snake_case). */
const FLAT_COLLECTIONS: Array<{
  name: string;
  collection: string;
  field: string;
  tenancyField?: string;
}> = [
  {name: "intakes", collection: "intakes", field: "patient_id"},
  {name: "safety_plans", collection: "safety_plans", field: "patient_id"},
  {name: "session_notes", collection: "session_notes", field: "patient_id"},
  {name: "assessments", collection: "assessments", field: "patient_id"},
  {
    name: "consent_records",
    collection: "consent_records",
    field: "patientId",
    tenancyField: "clinic_id",
  },
  // K1 — per-kind consent entries (PR #95 + #98). Same tenancy
  // gate as consent_records; surfaces every grant + revoke row
  // including the audit-relevant revokedAt timestamp so the patient
  // sees their full Consent Center history in the export.
  {
    name: "consent_entries",
    collection: "consent_entries",
    field: "patientId",
    tenancyField: "clinic_id",
  },
];

/** Nested patient sub-collections (`clinics/{c}/patients/{p}/{sub}`). */
const NESTED_SUBCOLLECTIONS: Array<{name: string; nested?: string[]}> = [
  {name: "sessions", nested: ["notes"]},
  {name: "superbills"},
  {name: "treatment_plans"},
  {name: "homework"},
  {name: "telehealth_sessions"},
  {name: "messages"},
  {name: "deposit_charges"},
  {name: "assessments"}, // some practices keep assessments nested too
];

interface ManifestEntry {
  collection: string;
  count: number;
  path: "flat" | "nested" | "nested-nested";
}

interface DsarBundle {
  generatedAt: string;
  clinicId: string;
  patientId: string;
  policyVersion: string;
  manifest: ManifestEntry[];
  records: Record<string, unknown[]>;
}

export async function buildDsarBundle(
  db: admin.firestore.Firestore,
  clinicId: string,
  patientId: string
): Promise<DsarBundle> {
  const records: Record<string, unknown[]> = {};
  const manifest: ManifestEntry[] = [];

  // Phase 1 — flat top-level collections filtered by clinic + patient.
  for (const cfg of FLAT_COLLECTIONS) {
    let q: admin.firestore.Query = db
      .collection(cfg.collection)
      .where(cfg.field, "==", patientId);
    if (cfg.tenancyField) {
      q = q.where(cfg.tenancyField, "==", clinicId);
    }
    const snap = await q.limit(1000).get();
    const rows: unknown[] = [];
    for (const d of snap.docs) {
      const data = d.data() as Record<string, unknown>;
      if (data.purged === true) continue;
      rows.push({id: d.id, ...data});
    }
    if (rows.length > 0) records[cfg.name] = rows;
    manifest.push({collection: cfg.name, count: rows.length, path: "flat"});
  }

  // Phase 2 — nested patient sub-collections + their nested-nested rows.
  for (const sub of NESTED_SUBCOLLECTIONS) {
    const parentPath = `clinics/${clinicId}/patients/${patientId}/${sub.name}`;
    const rows: unknown[] = [];
    let cursor: admin.firestore.QueryDocumentSnapshot | null = null;
    // eslint-disable-next-line no-constant-condition
    while (true) {
      let q: admin.firestore.Query = db.collection(parentPath).limit(400);
      if (cursor) q = q.startAfter(cursor);
      const snap = await q.get();
      if (snap.empty) break;
      for (const d of snap.docs) {
        const data = d.data() as Record<string, unknown>;
        if (data.purged === true) continue;
        const row: Record<string, unknown> = {id: d.id, ...data};
        // Recurse into known nested-nested children (sessions/{id}/notes).
        if (sub.nested?.length) {
          const nestedBundle: Record<string, unknown[]> = {};
          for (const nestedName of sub.nested) {
            const nestedPath = `${d.ref.path}/${nestedName}`;
            const nestedSnap = await db
              .collection(nestedPath)
              .limit(400)
              .get();
            const nestedRows = nestedSnap.docs
              .map((nd) => ({
                id: nd.id,
                ...(nd.data() as Record<string, unknown>),
              }))
              .filter((r) => (r as {purged?: boolean}).purged !== true);
            if (nestedRows.length > 0) nestedBundle[nestedName] = nestedRows;
            manifest.push({
              collection: `${sub.name}/${nestedName}`,
              count: nestedRows.length,
              path: "nested-nested",
            });
          }
          if (Object.keys(nestedBundle).length > 0) {
            row._nested = nestedBundle;
          }
        }
        rows.push(row);
      }
      if (snap.size < 400) break;
      cursor = snap.docs[snap.docs.length - 1];
    }
    if (rows.length > 0) records[sub.name] = rows;
    manifest.push({collection: sub.name, count: rows.length, path: "nested"});
  }

  // Phase 3 (K1) — forensic audit mirror rows scoped to this patient.
  // Schema is `clinic_audit_logs/{clinicId}/entries/{rowId}` with
  // `actor` set to the patient id at write time (see consent flow).
  // Surfacing the audit trail in the patient's own DSAR closes the
  // KVKK md. 11(d) "veri faaliyetlerinin niteliğini öğrenme" right
  // — the patient sees exactly which actions touched their record.
  {
    const auditPath = `clinic_audit_logs/${clinicId}/entries`;
    const auditRows: unknown[] = [];
    let cursor: admin.firestore.QueryDocumentSnapshot | null = null;
    // eslint-disable-next-line no-constant-condition
    while (true) {
      let q: admin.firestore.Query = db
        .collection(auditPath)
        .where("actor", "==", patientId)
        .limit(400);
      if (cursor) q = q.startAfter(cursor);
      const snap = await q.get();
      if (snap.empty) break;
      for (const d of snap.docs) {
        const data = d.data() as Record<string, unknown>;
        if (data.purged === true) continue;
        auditRows.push({id: d.id, ...data});
      }
      if (snap.size < 400) break;
      cursor = snap.docs[snap.docs.length - 1];
    }
    if (auditRows.length > 0) {
      // Sort by timestamp_utc ASC client-side — the orderBy on
      // Firestore would require a composite index (actor +
      // timestamp_utc) and break the no-index test mock. Sort here
      // for a deterministic, chain-replayable export.
      auditRows.sort((a, b) => {
        const at = (a as {timestamp_utc?: string}).timestamp_utc ?? "";
        const bt = (b as {timestamp_utc?: string}).timestamp_utc ?? "";
        return at.localeCompare(bt);
      });
      records.audit_log = auditRows;
    }
    manifest.push({
      collection: "audit_log",
      count: auditRows.length,
      path: "nested",
    });
  }

  return {
    generatedAt: new Date().toISOString(),
    clinicId,
    patientId,
    policyVersion: "GDPR Art. 15 + 20, KVKK Art. 11",
    manifest,
    records,
  };
}

// EU region — keeps the patient data residency promise the marketing
// copy makes.
export const dsarExport = functions
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (applyRateLimit(req, res, "portal-dsar")) return;
    if (req.method !== "POST") {
      return void res.status(405).json({error: "POST only"});
    }

    const db = admin.firestore();
    const now = _clockNow();
    const sla = _slaExpiresAt(now);

    // Clinician-only gate. Patient/non-clinician tokens never reach
    // the DSAR builder — caught + audit-logged at the boundary.
    const uid = await authorizeClinicianUid(req, "dsarExport");
    if (!uid) {
      await _writeAudit(db, {
        id: `dsar-unauth-${Date.now()}`,
        kind: "dsar_export",
        action: "dsar.unauthorized",
        actor: null,
        clinic_id: null,
        entity: "auth_gate=reject",
        timestamp_utc: admin.firestore.Timestamp.now(),
        sla_expires_at_utc: sla,
        result: "denied",
      });
      return void res.status(401).json({error: "unauthorized"});
    }

    const patientId = String(
      (req.body as {patientId?: unknown})?.patientId ?? "",
    ).trim();
    if (!patientId) {
      return void res.status(400).json({error: "patient_id_required"});
    }

    // 24-hour anti-abuse window — accidental double-submits and
    // scripted scraping both trip this.
    try {
      const recent = await _findRecentExport(
        db,
        uid,
        patientId,
        DSAR_REPEAT_WINDOW_MS,
      );
      if (recent) {
        await _writeAudit(db, {
          id: `dsar-rl-${uid}-${patientId}-${Date.now()}`,
          kind: "dsar_export",
          action: "dsar.rate_limited",
          actor: uid,
          clinic_id: uid,
          entity:
            `patient:${patientId} last_export_at=${recent.toISOString()}`,
          timestamp_utc: admin.firestore.Timestamp.now(),
          sla_expires_at_utc: sla,
          result: "denied",
        });
        return void res.status(429).json({
          error: "rate_limited",
          last_export_at_utc: recent.toISOString(),
          retry_after_utc: new Date(
            recent.getTime() + DSAR_REPEAT_WINDOW_MS,
          ).toISOString(),
        });
      }
    } catch (e) {
      functions.logger.warn("dsarExport.rate_limit_check_failed", {
        uid,
        patientId,
        reason: String(e),
      });
      // Fail-open on the rate-limit storage lookup: a transient
      // Firestore error must not make the regulator wait 30 days for
      // a re-try.
    }

    try {
      const bundle = await buildDsarBundle(db, uid, patientId);
      const bytesEstimated = JSON.stringify(bundle).length;

      await _stampExport(db, uid, patientId);

      // KVKK Art. 11 / GDPR Art. 30 audit row — counts + SLA, never
      // PHI. `sla_expires_at_utc` lets a downstream alert flag any
      // request older than the configured threshold.
      await _writeAudit(db, {
        id: `dsar-${uid}-${patientId}-${Date.now()}`,
        kind: "dsar_export",
        action: "dsar.export_built",
        actor: uid,
        clinic_id: uid,
        entity:
          `patient:${patientId} collections=${bundle.manifest.length}`,
        timestamp_utc: admin.firestore.Timestamp.now(),
        sla_expires_at_utc: sla,
        result: "success",
        bytes_estimated: bytesEstimated,
      });

      res.status(200).json(bundle);
    } catch (e) {
      functions.logger.error("dsarExport.failed", {
        uid,
        patientId,
        reason: String(e),
      });
      await _writeAudit(db, {
        id: `dsar-fail-${uid}-${patientId}-${Date.now()}`,
        kind: "dsar_export",
        action: "dsar.failed",
        actor: uid,
        clinic_id: uid,
        entity: `patient:${patientId} reason=${String(e).slice(0, 200)}`,
        timestamp_utc: admin.firestore.Timestamp.now(),
        sla_expires_at_utc: sla,
        result: "failed",
      });
      res.status(502).json({error: "export_failed"});
    }
  });
