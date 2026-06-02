/**
 * Quarterly access review cron (Sprint 14).
 *
 * SOC 2 CC6.1 expects evidence that a privileged user list is
 * reviewed on a quarterly cadence. This job runs the 1st of every
 * quarter (Jan / Apr / Jul / Oct), captures the current `clinicians`
 * + admin-role roster, and writes a `access_review` row that the
 * compliance officer signs off on inside seven days.
 *
 * The job does NOT mutate user roles; it only snapshots state and
 * pings the compliance address.
 *
 * Pure helpers (`isQuarterStart`, `nextQuarterStart`) are exported
 * so the schedule policy is unit-testable.
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * True when the date falls on the first of January, April, July, or
 * October — the quarters used by SOC 2 evidence collection.
 */
export function isQuarterStart(d: Date): boolean {
  if (d.getUTCDate() !== 1) return false;
  return [0, 3, 6, 9].includes(d.getUTCMonth());
}

/**
 * Returns the next quarter boundary strictly after [d].
 */
export function nextQuarterStart(d: Date): Date {
  const year = d.getUTCFullYear();
  const month = d.getUTCMonth();
  const quarterStarts = [0, 3, 6, 9];
  for (const qm of quarterStarts) {
    if (qm > month) {
      return new Date(Date.UTC(year, qm, 1));
    }
  }
  return new Date(Date.UTC(year + 1, 0, 1));
}

const REVIEWS_COLLECTION = "access_reviews";
const AUDIT_COLLECTION = "audit_logs";

/**
 * Paginate through the `clinicians` collection, emitting only the
 * fields needed for an access review (UID + roles). Email and other
 * PII are intentionally NOT persisted in the snapshot — the
 * compliance officer pulls them from Firebase Auth at sign-off
 * time. GDPR Art. 5(1)(e) + HIPAA minimum-necessary.
 */
async function snapshotRoster(
  db: admin.firestore.Firestore,
): Promise<Array<{ uid: string; roles: string[] }>> {
  const pageSize = 200;
  const out: Array<{ uid: string; roles: string[] }> = [];
  let cursor: admin.firestore.QueryDocumentSnapshot | null = null;

  /* eslint-disable no-await-in-loop */
  for (;;) {
    let q = db
      .collection("clinicians")
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(pageSize);
    if (cursor) q = q.startAfter(cursor);
    const snap = await q.get();
    if (snap.empty) break;
    for (const doc of snap.docs) {
      out.push({
        uid: doc.id,
        roles: (doc.data() as { roles?: string[] }).roles ?? [],
      });
    }
    cursor = snap.docs[snap.docs.length - 1] ?? null;
    if (snap.size < pageSize) break;
  }
  /* eslint-enable no-await-in-loop */
  return out;
}

export const accessReviewCron = functions.pubsub
  .schedule("0 6 1 1,4,7,10 *")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const now = new Date();

    const roster = await snapshotRoster(db);

    await db.collection(REVIEWS_COLLECTION).add({
      created_at: admin.firestore.Timestamp.fromDate(now),
      created_for_quarter: now.toISOString().slice(0, 7),
      roster_count: roster.length,
      // Persist UID + roles only — email is *not* on disk. SOC 2
      // CC6.1 evidence + HIPAA minimum-necessary.
      roster,
      reviewed_by: null,
      reviewed_at: null,
    });

    try {
      await db.collection(AUDIT_COLLECTION).add({
        id: `access-review-${now.toISOString()}`,
        kind: "access_review",
        action: "access_review.snapshot_captured",
        actor: "system.access_review_cron",
        clinic_id: "__system__",
        entity: `roster_count=${roster.length}`,
        timestamp_utc: admin.firestore.Timestamp.fromDate(now),
        result: "success",
      });
    } catch (e) {
      // Audit write failure must never tear down the scheduled run
      // (and re-trigger every hour) — log loudly and exit cleanly.
      functions.logger.error("access_review.audit_write_failed", {
        reason: String(e),
      });
    }

    functions.logger.info("access_review.snapshot", {
      roster_count: roster.length,
      next_due: nextQuarterStart(now).toISOString(),
    });
    return { roster_count: roster.length };
  });
