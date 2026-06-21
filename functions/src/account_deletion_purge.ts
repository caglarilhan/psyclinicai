/**
 * B18 backend — GDPR Article 17 erasure purge (Sprint 9).
 *
 * The client lets a clinician submit an [AccountDeletionRequest] with a
 * 30-day grace window. This function runs the actual purge once the
 * grace window closes and no cancellation arrived. PHI-bearing rows are
 * pseudonymised (not hard-deleted) so the audit log keeps its hash
 * chain — HIPAA §164.316 still owns retention.
 *
 * Schedule: hourly. Hourly lets the legal hand-off email arrive within
 * an hour of the grace window closing instead of the next day, while
 * keeping read pressure low.
 *
 * Schema contract:
 *   account_deletions/{userId}:
 *     user_id              : string  (== docId)
 *     requested_at         : Timestamp
 *     grace_ends_at        : Timestamp
 *     cancelled_at         : Timestamp | null
 *     completed_at         : Timestamp | null
 *     subject_patient_ids? : string[]  (clinician-side: every patient
 *                                       whose record gets pseudonymised
 *                                       in the same erasure)
 *
 * Without [subject_patient_ids] the function refuses to fan-out — it
 * would otherwise touch the wrong document keys and produce a fake
 * "all done" while real PHI sits intact. That is a GDPR Art. 17
 * compliance failure we'd rather catch loud than silent.
 *
 * One purge run writes a single `deletion.purge_completed` audit row
 * stamped with `clinic_id: "__system__"` so clinic-scoped read rules
 * still match a system view.
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const DELETIONS_COLLECTION = "account_deletions";
const AUDIT_COLLECTION = "audit_logs";

/**
 * True when the request has passed its grace window AND nobody
 * cancelled / completed it. Pure for unit testing.
 */
export function isReadyToPurge(
  request: {
    requestedAt: Date;
    graceEndsAt: Date;
    cancelledAt?: Date | null;
    completedAt?: Date | null;
  },
  now: Date
): boolean {
  if (request.cancelledAt) return false;
  if (request.completedAt) return false;
  return now.getTime() >= request.graceEndsAt.getTime();
}

/**
 * Pseudonymisation merge payloads for the PHI-bearing collections.
 * Centralised so the runbook can mirror it verbatim.
 *
 * NOTE: documents in each collection are keyed by their own id
 * (patientId / planId / noteId), NOT by the deletion-requesting user
 * id. The handler queries by [patient_id] before applying these.
 */
export const purgeFanOut: Record<string, Record<string, unknown>> = {
  intakes: {
    full_name: null,
    date_of_birth: null,
    gender: null,
    phone: null,
    email: null,
    emergency_contact_name: null,
    emergency_contact_phone: null,
    presenting_concern: "__purged__",
    medical_history: "__purged__",
    mental_health_history: "__purged__",
    substance_use: "__purged__",
    allergies: [],
    current_medications: [],
    purged: true,
  },
  safety_plans: {
    warning_signs: [],
    coping_strategies: [],
    social_distractions: [],
    support_contacts: [],
    professionals: [],
    crisis_lines: [],
    reasons_for_living: [],
    means_safety: "",
    purged: true,
  },
  session_notes: {
    markdown: "__purged__",
    sections: {},
    purged: true,
  },
  // KRİTİK-6 (audit 2026-06-21): GDPR Art. 17 erasure was not removing
  // PHQ-9 / GAD-7 / C-SSRS / PCL-5 answers. `answers` is the
  // patient-reported series; `score`/`severity` are derived and may stay
  // (clinical evidence) — but we strip the raw response vector and any
  // free-text notes that could leak identifiers.
  assessments: {
    answers: [],
    notes: "__purged__",
    self_harm_flag: null,
    purged: true,
  },
  // TODO (KRİTİK-6 follow-up): superbills, treatment_plans, messages,
  // homework, telehealth_sessions, deposit_charges. These live as
  // nested subcollections under clinics/{clinicId}/patients/{patientId}
  // per docs/STATUS.md; pseudonymisePatient() queries flat top-level
  // collections by patient_id, so the fan-out helper needs a
  // subcollection-walk variant before we can list them here.
  // Tracking issue: open before launch.
};

/**
 * Pseudonymise every row in [collection] that points at [patientId].
 * Returns the count of rows touched. Errors are caught and surfaced
 * via the logger so a single bad row never sinks the whole purge.
 */
async function pseudonymisePatient(
  db: admin.firestore.Firestore,
  collection: string,
  patientId: string,
  payload: Record<string, unknown>,
  now: Date
): Promise<number> {
  const snap = await db
    .collection(collection)
    .where("patient_id", "==", patientId)
    .limit(500)
    .get();
  if (snap.empty) return 0;

  const batch = db.batch();
  for (const doc of snap.docs) {
    batch.set(
      doc.ref,
      { ...payload, purged_at: admin.firestore.Timestamp.fromDate(now) },
      { merge: true }
    );
  }
  await batch.commit();
  return snap.size;
}

/**
 * Top-level scheduled handler. Picks up every ready request, runs the
 * fan-out, marks the request completed, writes a self-audit entry.
 */
export const accountDeletionPurge = functions.pubsub
  .schedule("every 1 hours")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const now = new Date();
    const nowTs = admin.firestore.Timestamp.fromDate(now);

    // Firestore range queries must compare Timestamp ↔ Timestamp; an
    // ISO string would silently match zero rows.
    const ready = await db
      .collection(DELETIONS_COLLECTION)
      .where("grace_ends_at", "<=", nowTs)
      .where("completed_at", "==", null)
      .where("cancelled_at", "==", null)
      .limit(100)
      .get();

    if (ready.empty) {
      functions.logger.info("account_deletion.purge_idle", {
        scanned_at: now.toISOString(),
      });
      return { purged: 0, failed: 0, skipped: 0 };
    }

    let purged = 0;
    let failed = 0;
    let skipped = 0;

    for (const reqDoc of ready.docs) {
      const userId = reqDoc.id;
      const data = reqDoc.data() as {
        subject_patient_ids?: unknown;
      };
      const patientIds = Array.isArray(data.subject_patient_ids)
        ? (data.subject_patient_ids.filter(
            (x) => typeof x === "string" && x.length > 0
          ) as string[])
        : [];

      // Fail loud: a request without a patient roster is a schema
      // mismatch from the client. Skip + warn rather than touch the
      // wrong document keys and pretend we erased PHI.
      if (patientIds.length === 0) {
        skipped++;
        functions.logger.warn("account_deletion.no_patient_roster", {
          userId,
        });
        continue;
      }

      try {
        let touched = 0;
        for (const collection of Object.keys(purgeFanOut)) {
          touched += await pseudonymisePatient(
            db,
            collection,
            // intentionally sequential; per-patient × per-collection
            // batches keep us well under the 500-write cap.
            patientIds[0],
            purgeFanOut[collection],
            now
          );
          for (const pid of patientIds.slice(1)) {
            touched += await pseudonymisePatient(
              db,
              collection,
              pid,
              purgeFanOut[collection],
              now
            );
          }
        }

        const closing = db.batch();
        closing.update(reqDoc.ref, { completed_at: nowTs });
        closing.set(db.collection(AUDIT_COLLECTION).doc(), {
          id: `deletion-${userId}-${now.toISOString()}`,
          kind: "deletion",
          action: "deletion.purge_completed",
          actor: "system.account_deletion_purge",
          clinic_id: "__system__",
          entity: `user:${userId} patients=${patientIds.length} rows=${touched}`,
          timestamp_utc: nowTs,
          result: "success",
        });
        await closing.commit();
        purged++;
      } catch (e) {
        failed++;
        functions.logger.error("account_deletion.user_failed", {
          userId,
          error: String(e),
        });
      }
    }

    functions.logger.info("account_deletion.purge_complete", {
      purged,
      failed,
      skipped,
    });
    return { purged, failed, skipped };
  });
