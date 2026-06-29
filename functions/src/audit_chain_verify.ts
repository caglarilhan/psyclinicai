/**
 * J2 (B4 follow-up) — client audit-chain verifier.
 *
 * The on-device `AuditLogRepository` mirrors each sealed row to
 * `clinic_audit_logs/{clinicId}/entries/{rowId}` via
 * `FirestoreAuditLogMirror` (PR J1). This function walks every
 * clinic's mirrored chain nightly, recomputes each row's hash, and
 * pages an operator if any row drifts — meaning either a tamper
 * attempt or a serialisation drift between client and server.
 *
 * Schedule: daily at 03:30 UTC (off-peak; sister to
 * `audit_retention_purge` at 02:00 UTC).
 *
 * Per-clinic isolation: a corruption on one clinic is logged + paged
 * but does not stop the verifier — every clinic gets a verdict
 * each fire.
 *
 * Production wiring lives in `index.ts` (re-export). Unit tests
 * call [runChainVerify] with a stub Firestore + clinicId list.
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

import {
  AuditChainRow,
  CLIENT_GENESIS_PREV_HASH,
  VerifyResult,
  verifyClientChainSlice,
} from "./lib/audit_chain";

/** Path to per-clinic mirror collection — matches client constant. */
const MIRROR_COLLECTION = "clinic_audit_logs";
const ENTRIES_SUBCOLLECTION = "entries";

/** Pure summary returned by [runChainVerify] for test assertions. */
export interface ChainVerifyRun {
  clinicsChecked: number;
  clinicsClean: number;
  clinicsCorrupt: number;
  clinicsEmpty: number;
  /** Per-clinic verdicts keyed by clinicId. */
  results: Record<string, VerifyResult>;
}

/**
 * Pulls every row under `clinic_audit_logs/{clinicId}/entries`
 * ordered by `timestamp_utc` ASC. Lifted here so the core flow can
 * be unit-tested by replacing the function with a fixture.
 */
async function fetchClientRows(
  db: admin.firestore.Firestore,
  clinicId: string,
): Promise<AuditChainRow[]> {
  const snap = await db
    .collection(MIRROR_COLLECTION)
    .doc(clinicId)
    .collection(ENTRIES_SUBCOLLECTION)
    .orderBy("timestamp_utc", "asc")
    .get();
  return snap.docs.map((d) => d.data() as AuditChainRow);
}

/**
 * Pure verifier entry point — given a Firestore handle and a list
 * of clinicIds, walks each clinic's mirrored chain and returns a
 * per-clinic verdict map. Exported for unit testing without booting
 * the scheduled wrapper.
 */
export async function runChainVerify(
  db: admin.firestore.Firestore,
  clinicIds: string[],
  fetchRows: (
    db: admin.firestore.Firestore,
    clinicId: string,
  ) => Promise<AuditChainRow[]> = fetchClientRows,
): Promise<ChainVerifyRun> {
  const results: Record<string, VerifyResult> = {};
  let clean = 0;
  let corrupt = 0;
  let empty = 0;
  for (const clinicId of clinicIds) {
    let rows: AuditChainRow[];
    try {
      rows = await fetchRows(db, clinicId);
    } catch (e) {
      // Treat fetch errors as corruption — operator needs to look.
      results[clinicId] = {
        ok: false,
        rowsChecked: 0,
        firstBadIndex: -1,
        reason: `fetch_failed: ${(e as Error).message}`,
      };
      corrupt += 1;
      continue;
    }
    if (rows.length === 0) {
      results[clinicId] = {
        ok: true,
        rowsChecked: 0,
        firstBadIndex: -1,
        reason: "empty_chain",
      };
      empty += 1;
      continue;
    }
    const verdict = verifyClientChainSlice(rows, CLIENT_GENESIS_PREV_HASH);
    results[clinicId] = verdict;
    if (verdict.ok) {
      clean += 1;
    } else {
      corrupt += 1;
      functions.logger.error("audit_chain.tamper_detected", {
        clinic_id: clinicId,
        first_bad_index: verdict.firstBadIndex,
        rows_checked: verdict.rowsChecked,
        reason: verdict.reason,
      });
    }
  }
  return {
    clinicsChecked: clinicIds.length,
    clinicsClean: clean,
    clinicsCorrupt: corrupt,
    clinicsEmpty: empty,
    results,
  };
}

/**
 * Resolves the clinicIds that exist in the mirror collection.
 * Exported so a test can pass a stub instead of round-tripping
 * Firestore admin SDK setup.
 */
export async function listMirroredClinics(
  db: admin.firestore.Firestore,
): Promise<string[]> {
  // `listDocuments` returns refs for every doc id (including those
  // with only subcollections and no fields), so a clinic with N
  // entries is detected even if the top-level doc itself is empty.
  const docs = await db.collection(MIRROR_COLLECTION).listDocuments();
  return docs.map((d) => d.id);
}

/**
 * Scheduled wrapper — daily at 03:30 UTC. Pages on any corrupt
 * clinic via the logger error channel; the existing GCP alert
 * routes that to Sentry / oncall.
 */
export const auditChainVerify = functions.pubsub
  .schedule("30 3 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    const db = admin.firestore();
    const clinicIds = await listMirroredClinics(db);
    const run = await runChainVerify(db, clinicIds);
    functions.logger.info("audit_chain_verify.complete", {
      clinics_checked: run.clinicsChecked,
      clinics_clean: run.clinicsClean,
      clinics_corrupt: run.clinicsCorrupt,
      clinics_empty: run.clinicsEmpty,
    });
    return null;
  });
