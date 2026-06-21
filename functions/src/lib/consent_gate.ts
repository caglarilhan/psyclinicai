/**
 * Server-side consent gate for AI-bound Cloud Functions.
 *
 * Closes audit finding KRİTİK-2 (2026-06-21): the `anthropicRelay`
 * forwarded transcripts to Anthropic without verifying that the patient
 * had granted AI-assistance consent. The Dart-side `ConsentGuard` only
 * runs when callers wire it (8 of 10 copilot services skip it today),
 * so the only safe enforcement is on the server.
 *
 * Contract (relayed from the caller in the request body):
 *   { patientId?: string, ... }
 *
 * Rules:
 *   - patientId missing or empty  → ALLOW (non-PHI calls like generic
 *     template drafts; UI consent screen has already shown the
 *     AI-disclosure copy).
 *   - patientId present           → REQUIRE a consent_records row owned
 *     by the caller (`clinic_id == uid`) with
 *     `aiAssistanceConsent == true` and `withdrawnAt == null`.
 *
 * Reasons returned as machine codes so dashboards / SIEM can group
 * failures: `missing_consent`, `withdrawn`, `not_ai_authorized`.
 *
 * Regulator framing: GDPR Art. 9(2)(a) explicit consent for
 * special-category data; KVKK Md. 6; HIPAA §164.508 authorisation for
 * non-TPO disclosure to a business associate (Anthropic).
 */
import * as admin from "firebase-admin";

export type ConsentDecision =
  | {ok: true; reason: "no_patient_in_request" | "consented"}
  | {ok: false; reason: "missing_consent" | "withdrawn" | "not_ai_authorized"};

const CONSENT_COLLECTION = "consent_records";

/**
 * Look up the most recent consent record for `(clinicId, patientId)`
 * and decide whether AI-bound processing is allowed. Pure async,
 * idempotent — safe to call multiple times per request.
 */
export async function checkAiConsent(params: {
  db: admin.firestore.Firestore;
  clinicId: string;
  patientId: string | null | undefined;
}): Promise<ConsentDecision> {
  const patientId = (params.patientId ?? "").trim();
  if (patientId.length === 0) {
    return {ok: true, reason: "no_patient_in_request"};
  }

  // Schema: consent_records/{recordId} — fields are stored in the
  // camelCase shape persisted by `lib/models/consent_record.dart`:
  //   { patientId, clinic_id, aiAssistanceConsent, withdrawnAt, ... }
  //
  // `clinic_id` is enforced by Firestore rules (line 130), so we MUST
  // include it in the query — otherwise admin SDK would scan across
  // tenants. We bound the query to the latest signed record per
  // patient/clinician pair (intake re-sign overwrites the prior one in
  // most clinics; until the schema enforces a single row we sort by
  // signedAt desc and take the top).
  const snap = await params.db
    .collection(CONSENT_COLLECTION)
    .where("clinic_id", "==", params.clinicId)
    .where("patientId", "==", patientId)
    .orderBy("signedAt", "desc")
    .limit(1)
    .get();

  if (snap.empty) {
    return {ok: false, reason: "missing_consent"};
  }

  const data = snap.docs[0].data() as Record<string, unknown>;
  const withdrawnAt = data.withdrawnAt;
  if (withdrawnAt !== undefined && withdrawnAt !== null) {
    return {ok: false, reason: "withdrawn"};
  }
  if (data.aiAssistanceConsent !== true) {
    return {ok: false, reason: "not_ai_authorized"};
  }
  return {ok: true, reason: "consented"};
}

/**
 * Extract a `patientId` from common request body shapes used by the
 * copilot path. The handler can call this helper instead of digging
 * through `req.body` itself, and we keep all of the field-name
 * fallbacks in one place (the legacy paths use `patient_id` snake_case
 * but the newer DSAR-aligned ones use `patientId`).
 */
export function extractPatientId(body: unknown): string | null {
  if (!body || typeof body !== "object") return null;
  const obj = body as Record<string, unknown>;
  const candidates = [
    obj.patientId,
    obj.patient_id,
    obj.patient && typeof obj.patient === "object" &&
      (obj.patient as Record<string, unknown>).id,
  ];
  for (const c of candidates) {
    if (typeof c === "string" && c.trim().length > 0) return c.trim();
  }
  return null;
}
