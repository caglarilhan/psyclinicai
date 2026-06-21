/**
 * Consent-withdrawal audit trigger (audit 2026-06-21, M-11).
 *
 * GDPR Art. 7(3) requires that withdrawal of consent be as easy as
 * granting it AND that we keep evidence the withdrawal happened (so a
 * disputed processing event downstream can be traced back to the
 * withdrawal moment). KVKK Art. 11 has the equivalent. The previous
 * implementation flipped `withdrawnAt` on `consent_records` from the
 * client but nothing mirrored that into the immutable `audit_logs`
 * chain — meaning a future dispute had no server-side proof of when
 * the withdrawal landed.
 *
 * This Firestore trigger watches `consent_records/{recordId}` for
 * updates and, when `withdrawnAt` transitions from null → non-null,
 * writes a `consent.withdrawn` audit row keyed by the consent record's
 * `clinic_id` so the immutable rules (`audit_logs/{logId}` rule:
 * `allow create, update, delete: if false` for the client → admin-SDK
 * writes pass) carry the trail.
 *
 * We never log the consent body — only the metadata an auditor needs
 * (record id, patient id, clinic id, withdrawal timestamp).
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

interface ConsentRecord {
  patientId?: unknown;
  clinic_id?: unknown;
  withdrawnAt?: unknown;
  policyVersion?: unknown;
}

/**
 * True when the `withdrawnAt` field went from null/absent to a real
 * value. Exposed pure for unit tests so we don't have to mock the
 * Firebase trigger envelope.
 */
export function detectsWithdrawal(
  before: ConsentRecord | null,
  after: ConsentRecord | null
): boolean {
  if (!after) return false;
  const afterWithdrawn =
    after.withdrawnAt !== undefined && after.withdrawnAt !== null;
  if (!afterWithdrawn) return false;
  const beforeWithdrawn =
    !!before &&
    before.withdrawnAt !== undefined &&
    before.withdrawnAt !== null;
  return !beforeWithdrawn;
}

/**
 * Build the audit row a withdrawal triggers. Pure builder so tests
 * can assert the shape without booting Firestore.
 */
export function buildWithdrawalAuditRow(params: {
  recordId: string;
  after: ConsentRecord;
  now: Date;
}): Record<string, unknown> {
  const clinicId =
    typeof params.after.clinic_id === "string" ? params.after.clinic_id : "";
  const patientId =
    typeof params.after.patientId === "string" ? params.after.patientId : "";
  const policyVersion =
    typeof params.after.policyVersion === "string" ?
      params.after.policyVersion :
      "";
  return {
    id: `consent-withdrawn-${params.recordId}-${params.now.toISOString()}`,
    kind: "consent",
    event_type: "consent.withdrawn",
    action: "consent.withdrawn",
    actor: "client.user",
    clinic_id: clinicId,
    entity:
      `consent_record:${params.recordId} ` +
      `patient:${patientId} policy:${policyVersion}`,
    ts: admin.firestore.Timestamp.fromDate(params.now),
    timestamp_utc: admin.firestore.Timestamp.fromDate(params.now),
    result: "success",
  };
}

export const consentWithdrawalAudit = functions
  .region("europe-west1")
  .firestore.document("consent_records/{recordId}")
  .onUpdate(async (change, context) => {
    const before = (change.before.data() as ConsentRecord | undefined) ?? null;
    const after = (change.after.data() as ConsentRecord | undefined) ?? null;
    if (!detectsWithdrawal(before, after)) return;

    try {
      const row = buildWithdrawalAuditRow({
        recordId: context.params.recordId as string,
        after: after as ConsentRecord,
        now: new Date(),
      });
      await admin.firestore().collection("audit_logs").add(row);
      functions.logger.info("consent_withdrawal_audited", {
        record_id: context.params.recordId,
      });
    } catch (e) {
      functions.logger.error("consent_withdrawal_audit_failed", {
        record_id: context.params.recordId,
        reason: String(e).slice(0, 200),
      });
      throw e;
    }
  });
