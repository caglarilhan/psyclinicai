/**
 * Sprint 33 P1 — EHR FHIR R4 outbox reconciliation cron.
 *
 * Hourly sweep over `ehr_outbox/{tid}/entries` for rows whose status
 * is `failed` AND whose creation timestamp is < 24 h old. Each one
 * is retried once via the same retryWithBackoff policy used by the
 * synchronous handler. If still failing after 24 h since creation,
 * the row is flipped to `permanently_failed` and a copy is written to
 * `tenants/{tid}/private/ehr_failed/{key}` so the operator console
 * can chase it.
 *
 * Skill-panel coverage: senior-backend (cron shape), healthcare-emr-
 * patterns (FHIR retry semantics), silent-failure-hunter (no row
 * silently aging out without operator visibility), release-manager
 * (idempotent — safe to run multiple times in a row).
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {
  endpointById,
  retryWithBackoff,
} from "./ehr_bridge";
import {postObservation} from "./ehr_observation_handler";

const MAX_RETRY_WINDOW_MS = 24 * 60 * 60 * 1000;

interface OutboxRow {
  endpoint_id?: string;
  payload?: Record<string, unknown>;
  status?: string;
  attempts?: number;
  created_at?: admin.firestore.Timestamp | null;
  last_attempt_at?: admin.firestore.Timestamp | null;
}

/**
 * Pure-logic decision: should we retry this row, mark it permanently
 * failed, or skip it? Exposed so unit tests don't need a Firestore
 * stub.
 */
export type ReconcileAction = "retry" | "permanently_fail" | "skip";

export function decideAction(
  row: OutboxRow,
  nowMs: number,
  maxWindowMs: number = MAX_RETRY_WINDOW_MS,
): ReconcileAction {
  if (row.status !== "failed") return "skip";
  const createdMs = row.created_at?.toMillis?.() ?? 0;
  if (createdMs === 0) return "skip";
  const ageMs = nowMs - createdMs;
  if (ageMs > maxWindowMs) return "permanently_fail";
  return "retry";
}

export const ehrOutboxReconciler = functions
  .runWith({memory: "256MB", timeoutSeconds: 540})
  .region("europe-west1")
  .pubsub.schedule("every 60 minutes")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const tenants = await db.collection("ehr_outbox").listDocuments();
    let retried = 0;
    let permanentlyFailed = 0;
    let recovered = 0;

    for (const tenantRef of tenants) {
      const failedRows = await tenantRef
        .collection("entries")
        .where("status", "==", "failed")
        .limit(50)
        .get();

      for (const doc of failedRows.docs) {
        const row = (doc.data() ?? {}) as OutboxRow;
        const decision = decideAction(row, Date.now());

        if (decision === "skip") continue;

        if (decision === "permanently_fail") {
          await doc.ref.set(
            {status: "permanently_failed"},
            {merge: true},
          );
          await db
            .doc(
              `tenants/${tenantRef.id}/private/ehr_failed/${doc.id}`,
            )
            .set({
              outbox_key: doc.id,
              endpoint_id: row.endpoint_id ?? "",
              attempts: row.attempts ?? 0,
              created_at: row.created_at ?? null,
              marked_at: admin.firestore.FieldValue.serverTimestamp(),
            });
          permanentlyFailed += 1;
          functions.logger.warn("ehr_outbox.permanently_failed", {
            tenantId: tenantRef.id,
            outboxKey: doc.id,
          });
          continue;
        }

        const endpoint = endpointById(row.endpoint_id ?? "");
        if (endpoint === null || !row.payload) continue;

        const send = await retryWithBackoff(
          async () =>
            postObservation(endpoint.baseUrl, row.payload!),
          3,
        );

        if (send.status === "sent") {
          await doc.ref.set(
            {
              status: "sent",
              attempts: (row.attempts ?? 0) + send.attempts,
              last_attempt_at:
                admin.firestore.FieldValue.serverTimestamp(),
              final_error: null,
            },
            {merge: true},
          );
          recovered += 1;
        } else {
          await doc.ref.set(
            {
              attempts: (row.attempts ?? 0) + send.attempts,
              last_attempt_at:
                admin.firestore.FieldValue.serverTimestamp(),
              final_error: send.finalError ?? null,
            },
            {merge: true},
          );
          retried += 1;
        }
      }
    }

    functions.logger.info("ehr_outbox.reconciler_summary", {
      retried,
      recovered,
      permanently_failed: permanentlyFailed,
    });

    return {retried, recovered, permanentlyFailed};
  });
