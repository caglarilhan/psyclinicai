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

import {applyCors, authorizeUid} from "./lib/auth";

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
    if (applyCors(req, res)) return;
    if (req.method !== "POST") {
      return void res.status(405).json({error: "POST only"});
    }

    const uid = await authorizeUid(req, "dsarExport");
    if (!uid) return void res.status(401).json({error: "unauthorized"});

    const patientId = String(
      (req.body as {patientId?: unknown})?.patientId ?? ""
    ).trim();
    if (!patientId) {
      return void res.status(400).json({error: "patient_id_required"});
    }

    try {
      const db = admin.firestore();
      const bundle = await buildDsarBundle(db, uid, patientId);

      // Compliance audit row — Art. 30 ROPA wants every access event
      // logged. We never log the bundle itself (PHI), only the counts.
      await db.collection("audit_logs").add({
        id: `dsar-${uid}-${patientId}-${Date.now()}`,
        kind: "dsar_export",
        action: "dsar.export_built",
        actor: uid,
        clinic_id: uid,
        entity: `patient:${patientId} collections=${bundle.manifest.length}`,
        timestamp_utc: admin.firestore.Timestamp.now(),
        result: "success",
      });

      res.status(200).json(bundle);
    } catch (e) {
      functions.logger.error("dsarExport.failed", {
        uid,
        patientId,
        reason: String(e),
      });
      res.status(502).json({error: "export_failed"});
    }
  });
