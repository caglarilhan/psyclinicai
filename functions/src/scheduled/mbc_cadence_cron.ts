/**
 * `mbcCadenceCron` — Sprint 31 PR-F.
 *
 * Hourly scheduled function that walks recent `mbc_dispatch` rows,
 * groups them by (tenant_id, patient_id, scale_id), and for any
 * group whose most-recent submitted dispatch is **overdue** per the
 * catalog interval, mints a NEW dispatch row so the clinician
 * dashboard surfaces it as "ready to send".
 *
 * MVP posture (Sprint 31):
 *   * No SMS / email egress — that comes in Sprint 33 with Twilio +
 *     Sendgrid adapters. This cron only mints the dispatch row.
 *   * "Active rotation" is implicit: any (patient, scale) tuple that
 *     has ever been submitted is treated as auto-cadence until the
 *     clinician explicitly closes it (Sprint 32 will add an
 *     `mbc_active = false` flag).
 *
 * **Deploy requirement**: Firebase Cloud Scheduler / Pub/Sub
 * scheduled functions require the **Blaze (pay-as-you-go) plan**.
 * On Spark the export is included in the build but `firebase deploy`
 * skips the scheduled registration with a notice. Once revenue
 * justifies Blaze the function activates with zero code change.
 */
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as functions from "firebase-functions";

import {
  isDueForDispatch,
  mbcRuleByScaleId,
  MbcDispatchRule,
  tokenExpiryMillis,
} from "../lib/mbc_dispatch_catalog";

interface DispatchRow {
  tenant_id?: string;
  clinic_id?: string;
  patient_id?: string;
  scale_id?: string;
  dispatched_at?: admin.firestore.Timestamp;
  submitted_at?: admin.firestore.Timestamp | null;
  expires_at?: admin.firestore.Timestamp;
}

interface OverdueCandidate {
  tenantId: string;
  clinicId: string;
  patientId: string;
  scaleId: string;
  lastDispatchedAt: Date;
}

/**
 * Walks dispatches and returns the set of (tenant, patient, scale)
 * tuples whose most-recent SUBMITTED dispatch is past the catalog
 * interval. Pure helper — exported for unit tests.
 */
export function findOverdueRotations(
  rows: DispatchRow[],
  now: Date,
): OverdueCandidate[] {
  const latest = new Map<string, DispatchRow>();
  for (const r of rows) {
    if (!r.tenant_id || !r.patient_id || !r.scale_id) continue;
    if (!r.submitted_at) continue;
    const k = `${r.tenant_id}::${r.patient_id}::${r.scale_id}`;
    const prev = latest.get(k);
    const ts = r.dispatched_at?.toMillis() ?? 0;
    if (!prev || ts > (prev.dispatched_at?.toMillis() ?? 0)) {
      latest.set(k, r);
    }
  }
  const out: OverdueCandidate[] = [];
  for (const [, r] of latest) {
    let rule: MbcDispatchRule;
    try {
      rule = mbcRuleByScaleId(r.scale_id!);
    } catch {
      continue;
    }
    const last = r.dispatched_at?.toDate() ?? null;
    if (
      isDueForDispatch({
        rule,
        lastDispatchedAtMillis: last ? last.getTime() : null,
        nowMillis: now.getTime(),
      })
    ) {
      out.push({
        tenantId: r.tenant_id!,
        clinicId: r.clinic_id ?? r.tenant_id!,
        patientId: r.patient_id!,
        scaleId: r.scale_id!,
        lastDispatchedAt: last ?? new Date(0),
      });
    }
  }
  return out;
}

function mintToken(): string {
  return crypto
    .randomBytes(32)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function sha256Hex(input: string): string {
  return crypto.createHash("sha256").update(input).digest("hex");
}

/**
 * Mints a fresh dispatch row for one overdue candidate. Reuses the
 * exact same fields as `mbcDispatchLink` so the dashboard renders
 * the auto-rotated row identically to clinician-triggered rows.
 * `auto_rotation_source = "cron"` flags the origin for audit.
 */
export async function mintAutoRotationDispatch(
  db: admin.firestore.Firestore,
  candidate: OverdueCandidate,
  now: Date,
): Promise<string> {
  const rule = mbcRuleByScaleId(candidate.scaleId);
  const token = mintToken();
  const expires = tokenExpiryMillis({
    rule,
    dispatchedAtMillis: now.getTime(),
  });
  const channel = rule.channels[0];
  const ref = await db.collection("mbc_dispatch").add({
    tenant_id: candidate.tenantId,
    clinic_id: candidate.clinicId,
    patient_id: candidate.patientId,
    scale_id: candidate.scaleId,
    token_hash: sha256Hex(token),
    channel,
    dispatched_at: admin.firestore.Timestamp.fromMillis(now.getTime()),
    expires_at: admin.firestore.Timestamp.fromMillis(expires),
    submitted_at: null,
    reminded_at: null,
    auto_rotation_source: "cron",
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  return ref.id;
}

/**
 * Hourly schedule. Reads the most recent 5,000 dispatched rows + mints
 * new dispatches for overdue rotations.
 */
export const mbcCadenceCron = functions
  .runWith({memory: "512MB", timeoutSeconds: 540})
  .region("europe-west1")
  .pubsub.schedule("every 60 minutes")
  .timeZone("Europe/Berlin")
  .onRun(async () => {
    const db = admin.firestore();
    const snap = await db
      .collection("mbc_dispatch")
      .orderBy("dispatched_at", "desc")
      .limit(5000)
      .get();
    const rows: DispatchRow[] = snap.docs.map(
      (d) => d.data() as DispatchRow,
    );
    const now = new Date();
    const candidates = findOverdueRotations(rows, now);
    let minted = 0;
    for (const c of candidates) {
      try {
        await mintAutoRotationDispatch(db, c, now);
        minted++;
      } catch (e) {
        functions.logger.warn("mbc_cadence_cron.mint_failed", {
          tenant: c.tenantId,
          patient: c.patientId,
          scale: c.scaleId,
          error: String(e),
        });
      }
    }
    functions.logger.info("mbc_cadence_cron.summary", {
      candidates: candidates.length,
      minted,
      scanned: rows.length,
    });
    return null;
  });
