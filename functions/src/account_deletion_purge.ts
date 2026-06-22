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
 * Returns the total count of rows touched (across all paged batches).
 * Errors are caught and surfaced via the logger so a single bad row
 * never sinks the whole purge.
 *
 * Used for the flat top-level collections (`intakes`, `safety_plans`,
 * `session_notes`, `assessments`) that record `patient_id` directly.
 * For nested patient sub-collections, see [pseudonymiseSubcollection].
 *
 * M-4 fix (audit 2026-06-21): the previous implementation only ran
 * one `.limit(500)` batch per (collection, patient) pair. A patient
 * with >500 session_notes (rare but happens for long-term cases) had
 * the tail of their notes left intact — a GDPR Art. 17 partial
 * erasure failure. We now page through with cursor + batch under the
 * Firestore 500-write cap until the query returns empty.
 */
async function pseudonymisePatient(
  db: admin.firestore.Firestore,
  collection: string,
  patientId: string,
  payload: Record<string, unknown>,
  now: Date
): Promise<number> {
  const pageSize = 400;
  let touched = 0;
  let cursor: admin.firestore.QueryDocumentSnapshot | null = null;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    let q: admin.firestore.Query = db
      .collection(collection)
      .where("patient_id", "==", patientId)
      .limit(pageSize);
    if (cursor) q = q.startAfter(cursor);
    const snap = await q.get();
    if (snap.empty) break;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.set(
        doc.ref,
        { ...payload, purged_at: admin.firestore.Timestamp.fromDate(now) },
        { merge: true }
      );
    }
    await batch.commit();
    touched += snap.size;

    if (snap.size < pageSize) break;
    cursor = snap.docs[snap.docs.length - 1];
  }
  return touched;
}

/**
 * Nested patient sub-collection fan-out for KRİTİK-6 (audit 2026-06-21).
 *
 * Walks `clinics/{clinicId}/patients/{patientId}/{subcollection}` and
 * pseudonymises every doc with [payload]. Returns the total number of
 * docs touched.
 *
 * Pagination: Firestore caps batched writes at 500 ops; we page through
 * the sub-collection in 400-doc windows (leaving headroom for the
 * `purged_at` merge field). Recurses into the known deeper sub-paths
 * (sessions → notes) so notes nested under a session also get purged.
 *
 * This complements [pseudonymisePatient] which only handles the flat
 * top-level collections (legacy schema). New chart objects
 * (superbills, telehealth_sessions, treatment_plans, homework,
 * messages, deposit_charges) live as patient sub-collections per
 * `lib/services/data/firestore_schema.dart` and require this walker.
 */
export async function pseudonymiseSubcollection(
  db: admin.firestore.Firestore,
  clinicId: string,
  patientId: string,
  subcollection: string,
  payload: Record<string, unknown>,
  now: Date,
  options: {
    pageSize?: number;
    nestedSubcollections?: string[];
  } = {}
): Promise<number> {
  const pageSize = options.pageSize ?? 400;
  const parentPath = `clinics/${clinicId}/patients/${patientId}/${subcollection}`;

  let touched = 0;
  let cursor: admin.firestore.QueryDocumentSnapshot | null = null;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    let q: admin.firestore.Query = db.collection(parentPath).limit(pageSize);
    if (cursor) q = q.startAfter(cursor);
    const snap = await q.get();
    if (snap.empty) break;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.set(
        doc.ref,
        { ...payload, purged_at: admin.firestore.Timestamp.fromDate(now) },
        { merge: true }
      );
    }
    await batch.commit();
    touched += snap.size;

    // Recurse into known nested sub-collections (e.g. sessions/{id}/notes).
    if (options.nestedSubcollections?.length) {
      for (const doc of snap.docs) {
        for (const nested of options.nestedSubcollections) {
          const nestedPath = `${doc.ref.path}/${nested}`;
          touched += await pseudonymiseNestedPath(db, nestedPath, payload, now);
        }
      }
    }

    if (snap.size < pageSize) break;
    cursor = snap.docs[snap.docs.length - 1];
  }

  return touched;
}

async function pseudonymiseNestedPath(
  db: admin.firestore.Firestore,
  path: string,
  payload: Record<string, unknown>,
  now: Date
): Promise<number> {
  let touched = 0;
  let cursor: admin.firestore.QueryDocumentSnapshot | null = null;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    let q: admin.firestore.Query = db.collection(path).limit(400);
    if (cursor) q = q.startAfter(cursor);
    const snap = await q.get();
    if (snap.empty) break;
    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.set(
        doc.ref,
        { ...payload, purged_at: admin.firestore.Timestamp.fromDate(now) },
        { merge: true }
      );
    }
    await batch.commit();
    touched += snap.size;
    if (snap.size < 400) break;
    cursor = snap.docs[snap.docs.length - 1];
  }
  return touched;
}

/**
 * Per-patient sub-collection purge payloads. Each entry pseudonymises
 * the PHI-bearing fields while keeping the chart's structural rows
 * (HIPAA §164.316 retention) intact.
 *
 * Field names follow `lib/services/data/firestore_schema.dart`.
 */
export const subcollectionPurgeFanOut: Record<
  string,
  { payload: Record<string, unknown>; nestedSubcollections?: string[] }
> = {
  sessions: {
    payload: {
      transcript: "__purged__",
      flaggedRisk: null,
      purged: true,
    },
    // Notes are nested under each session document.
    nestedSubcollections: ["notes"],
  },
  superbills: {
    payload: {
      invoiceNumber: null,
      diagnoses: [],
      serviceLines: [],
      pdfUrl: null,
      purged: true,
    },
  },
  treatment_plans: {
    payload: {
      goals: [],
      interventions: [],
      narrative: "__purged__",
      purged: true,
    },
  },
  homework: {
    payload: {
      assignment: "__purged__",
      response: "__purged__",
      purged: true,
    },
  },
  telehealth_sessions: {
    payload: {
      patient_name: null,
      patientName: null,
      recordingUrl: null,
      notes: "__purged__",
      purged: true,
    },
  },
  messages: {
    payload: {
      body: "__purged__",
      attachments: [],
      purged: true,
    },
  },
  deposit_charges: {
    payload: {
      description: "__purged__",
      receipt_url: null,
      purged: true,
    },
  },
};

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
        // Phase 1: legacy flat top-level collections (patient_id field).
        for (const collection of Object.keys(purgeFanOut)) {
          for (const pid of patientIds) {
            touched += await pseudonymisePatient(
              db,
              collection,
              pid,
              purgeFanOut[collection],
              now
            );
          }
        }
        // Phase 2 (KRİTİK-6 close): nested patient sub-collections under
        // `clinics/{clinicId}/patients/{patientId}/*`. The Cloud Function
        // owner (clinic id) equals `userId` for the solo pilot tenancy.
        for (const sub of Object.keys(subcollectionPurgeFanOut)) {
          const entry = subcollectionPurgeFanOut[sub];
          for (const pid of patientIds) {
            touched += await pseudonymiseSubcollection(
              db,
              userId,
              pid,
              sub,
              entry.payload,
              now,
              { nestedSubcollections: entry.nestedSubcollections }
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
