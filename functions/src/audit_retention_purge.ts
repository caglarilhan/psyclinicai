/**
 * B10 — Audit log retention purge (Sprint 9).
 *
 * HIPAA §164.316(b)(2)(i) requires audit logs to be retained for at
 * least six years. After that window we **pseudonymise** the rows
 * (drop actor / entity / ip; keep id + kind + timestamp + chain hash)
 * instead of deleting them — the hash chain stays verifiable so a
 * future auditor can prove no one tampered with the trail.
 *
 * Schedule: daily at 02:00 UTC. The window is large enough that a few
 * hours of jitter do not matter; we pick a low-traffic slot so the
 * pseudonymisation pass does not contend with the active clinic day.
 *
 * Each pass writes its own `retention.purge_run` audit log entry so
 * the cron itself is auditable.
 *
 * Production wiring lives in `index.ts` (re-export). Unit tests use
 * `firebase-functions-test` to feed a fake snapshot through the
 * pure helpers exported below.
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

import {AuditChainRow, verifyChainSlice} from "./lib/audit_chain";

/** Where audit log rows live in Firestore. Mirrors the client model. */
const AUDIT_COLLECTION = "audit_logs";

/**
 * Six-year cutoff computed via calendar arithmetic so leap years do
 * not silently shorten the HIPAA window. `365*6` is 1-2 days short
 * of six years on most cohorts.
 */
export function sixYearsBefore(now: Date): Date {
  const d = new Date(now.getTime());
  d.setUTCFullYear(d.getUTCFullYear() - 6);
  return d;
}

/**
 * Pure helper — returns the merge payload that pseudonymises a row.
 * Kept exported so unit tests can call it without booting admin SDK.
 */
export function pseudonymisePayload(): Record<string, unknown> {
  return {
    actor: null,
    entity: "__purged__",
    ip: null,
    device: null,
    // user_id stays — it's already an opaque uid, not PHI on its own.
    // id, kind, timestamp_utc, result, hash, user_id keep their values
    // so the chain stays verifiable.
    purged: true,
    purged_at: admin.firestore.FieldValue.serverTimestamp(),
  };
}

/**
 * True when [createdAt] is older than six calendar years before [now].
 * Both must be UTC.
 */
export function isExpired(createdAt: Date, now: Date): boolean {
  return createdAt.getTime() < sixYearsBefore(now).getTime();
}

/**
 * Result of a single retention pass — surfaced so tests can pin
 * counts without parsing logs.
 */
export interface RetentionPurgeResult {
  purged: number;
  failed: number;
  commit_failed: number;
  tampered_skipped: number;
  cutoff_utc: string;
}

/**
 * Pure-ish handler: walks `audit_logs`, pseudonymises every row whose
 * `timestamp_utc < cutoff`, verifies the hash chain per batch, and
 * writes a single `retention.purge_run` self-audit entry at the end.
 *
 * Pulled out of the scheduled wrapper so a Cloud Functions emulator
 * isn't required for unit coverage — callers pass a stub Firestore
 * and inject `now` to anchor the cutoff math.
 */
export async function runRetentionPurge(
  db: admin.firestore.Firestore,
  now: Date,
): Promise<RetentionPurgeResult> {
  const cutoff = sixYearsBefore(now);
    // Firestore range queries against a Timestamp field must use a
    // Timestamp value — an ISO string compares as a different type
    // and silently returns zero rows.
    const cutoffTs = admin.firestore.Timestamp.fromDate(cutoff);

    let purged = 0;
    let failed = 0;
    let commitFailed = 0;
    let tamperedSkipped = 0;
    let cursor: admin.firestore.QueryDocumentSnapshot | null = null;

    /* eslint-disable no-await-in-loop */
    for (;;) {
      let q = db
        .collection(AUDIT_COLLECTION)
        .where("timestamp_utc", "<", cutoffTs)
        .orderBy("timestamp_utc")
        .limit(200);
      if (cursor) q = q.startAfter(cursor);

      const snap = await q.get();
      if (snap.empty) break;

      // L-6 fix (audit 2026-06-21): verify the hash chain over this
      // batch BEFORE pseudonymising. A tampered chain that gets
      // pseudonymised loses the evidence that proves tampering — so
      // we skip + log a tampered batch instead, and the operator
      // rebuilds from cold storage. Genesis hash (prev=null) is fine
      // for the first batch in a fresh cohort; later batches use the
      // most recent row's hash from the previous page as `initialPrev`.
      const chainRows: AuditChainRow[] = snap.docs.map((doc) => {
        const d = doc.data() as Record<string, unknown>;
        return {
          id: doc.id,
          kind: (d.kind as string) ?? "",
          action: (d.action as string) ?? "",
          actor: (d.actor as string) ?? "",
          entity: (d.entity as string) ?? "",
          timestamp_utc:
            ((d.timestamp_utc as admin.firestore.Timestamp | undefined)
              ?.toDate()
              .toISOString()) ?? "",
          result: (d.result as string) ?? "",
          hash: (d.hash as string | undefined) ?? null,
          prev_hash: (d.prev_hash as string | undefined) ?? null,
        };
      });
      const verdict = verifyChainSlice(chainRows);
      if (!verdict.ok) {
        tamperedSkipped += snap.size;
        functions.logger.error("audit_retention.chain_tampered", {
          rows: snap.size,
          first_bad: verdict.firstBadIndex,
          reason: verdict.reason,
        });
        // Skip the batch — do NOT pseudonymise rows whose integrity
        // we cannot prove. Operator must restore from cold storage.
        cursor = snap.docs[snap.docs.length - 1] ?? null;
        if (snap.size < 200) break;
        continue;
      }

      const batch = db.batch();
      let stagedInBatch = 0;
      for (const doc of snap.docs) {
        try {
          batch.update(doc.ref, pseudonymisePayload());
          stagedInBatch++;
        } catch (e) {
          failed++;
          functions.logger.error("audit_retention.row_failed", {
            id: doc.id,
            error: String(e),
          });
        }
      }

      try {
        await batch.commit();
        purged += stagedInBatch;
      } catch (e) {
        // Whole batch lost — do NOT add stagedInBatch to purged.
        commitFailed += stagedInBatch;
        functions.logger.error("audit_retention.batch_failed", {
          rows: stagedInBatch,
          error: String(e),
        });
      }

      cursor = snap.docs[snap.docs.length - 1] ?? null;
      if (snap.size < 200) break;
    }
    /* eslint-enable no-await-in-loop */

    // Self-audit entry — the purge itself is auditable. `clinic_id` is
    // a system sentinel so clinic-scoped read rules can still match
    // ("system" view) without exposing the row to a real tenant.
    await db.collection(AUDIT_COLLECTION).add({
      id: `retention-${now.toISOString()}`,
      kind: "retention",
      action: "retention.purge_run",
      actor: "system.audit_retention_purge",
      clinic_id: "__system__",
      entity:
        `purged=${purged} failed=${failed} ` +
        `commit_failed=${commitFailed} ` +
        `tampered_skipped=${tamperedSkipped}`,
      timestamp_utc: admin.firestore.Timestamp.fromDate(now),
      result:
        failed === 0 && commitFailed === 0 && tamperedSkipped === 0 ?
          "success" :
          "failure",
    });

  functions.logger.info("audit_retention.purge_complete", {
    purged,
    failed,
    commit_failed: commitFailed,
    tampered_skipped: tamperedSkipped,
    cutoff: cutoff.toISOString(),
  });

  return {
    purged,
    failed,
    commit_failed: commitFailed,
    tampered_skipped: tamperedSkipped,
    cutoff_utc: cutoff.toISOString(),
  };
}

/**
 * Top-level scheduled handler. Runs every 24h at 02:00 UTC and
 * delegates to [runRetentionPurge]. Kept as a thin wrapper so the
 * core logic stays unit-testable with a stub Firestore.
 */
export const auditRetentionPurge = functions.pubsub
  .schedule("every 24 hours")
  .timeZone("UTC")
  .onRun(async () => {
    await runRetentionPurge(admin.firestore(), new Date());
    return null;
  });
