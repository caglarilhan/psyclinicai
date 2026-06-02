/**
 * C-SSRS soft-lock cleanup (Sprint 10 — cross-device persistence).
 *
 * Rows in `escalation_soft_locks` represent a clinician dismissing
 * an imminent / immediate C-SSRS escalation. The dashboard banner
 * stays up for 24h after dismissal (`followUpDueAt`). If nobody
 * follows up in that window the row is left in place so the audit
 * trail keeps the evidence — we only flip `stale=true` so the
 * dashboard moves it out of the "active" tab.
 *
 * Schedule: hourly. The clinical follow-up window is 24h but the
 * scheduler runs hourly so the "needs review" tab updates within
 * an hour of the boundary.
 *
 * Pure helpers are exported for Jest unit tests.
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const COLLECTION = "escalation_soft_locks";
const AUDIT_COLLECTION = "audit_logs";

/**
 * Returns true when [followUpDueAt] is in the past relative to [now]
 * and the row is not already marked stale. Pure for unit testing.
 */
export function shouldMarkStale(
  row: {
    followUpDueAt: Date;
    stale: boolean;
    supervisorHandoffId?: string | null;
  },
  now: Date
): boolean {
  if (row.stale) return false;
  if (row.supervisorHandoffId) {
    // A documented handoff counts as follow-up — the dashboard will
    // surface that chain separately, no need to age the row out.
    return false;
  }
  return now.getTime() >= row.followUpDueAt.getTime();
}

/**
 * Top-level scheduled handler. Picks up every row past its follow-up
 * window, marks it stale, writes a single retention audit entry at
 * the end of the pass.
 */
export const escalationSoftLockCleanup = functions.pubsub
  .schedule("every 1 hours")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const now = new Date();
    const nowTs = admin.firestore.Timestamp.fromDate(now);

    const expired = await db
      .collection(COLLECTION)
      .where("followUpDueAt", "<=", nowTs)
      .where("stale", "==", false)
      .limit(200)
      .get();

    if (expired.empty) {
      functions.logger.info("escalation_soft_lock.cleanup_idle", {
        scanned_at: now.toISOString(),
      });
      return { aged: 0 };
    }

    let aged = 0;
    let failed = 0;
    const batch = db.batch();

    for (const doc of expired.docs) {
      const data = doc.data() as { supervisorHandoffId?: string };
      // Skip rows that already have a documented handoff — defence in
      // depth in case the query and the JSON drift.
      if (data.supervisorHandoffId) continue;
      batch.update(doc.ref, {
        stale: true,
        staled_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      aged++;
    }

    try {
      await batch.commit();
    } catch (e) {
      failed = aged;
      aged = 0;
      functions.logger.error("escalation_soft_lock.batch_failed", {
        error: String(e),
      });
    }

    try {
      await db.collection(AUDIT_COLLECTION).add({
        id: `softlock-stale-${now.toISOString()}`,
        kind: "softlock",
        action: "softlock.cleanup_run",
        actor: "system.escalation_soft_lock_cleanup",
        clinic_id: "__system__",
        entity: `aged=${aged} failed=${failed}`,
        timestamp_utc: nowTs,
        result: failed === 0 ? "success" : "failure",
      });
    } catch (e) {
      // Audit log write must never re-throw out of the scheduler —
      // an unhandled rejection here triggers an hourly retry storm.
      functions.logger.error("escalation_soft_lock.audit_write_failed", {
        reason: String(e),
      });
    }

    functions.logger.info("escalation_soft_lock.cleanup_complete", {
      aged,
      failed,
    });
    return { aged, failed };
  });
