/**
 * Sprint 29 P-08 — waitlist welcome email Cloud Function.
 *
 * Trigger: Firestore onCreate at `landing_waitlist/{doc}` (and
 * `beta_signups/{doc}` for the public-beta cohort). Sends a Sendgrid
 * dynamic template, stamps `welcome_sent_at`, and never throws so a
 * delivery hiccup cannot block the Firestore write.
 *
 * Secrets required at deploy time:
 *   SENDGRID_API_KEY            — API key, "Mail Send" scope only.
 *   SENDGRID_TEMPLATE_WAITLIST  — d-XXXXXXXXXXXX, dynamic template id.
 *   SENDGRID_FROM_EMAIL         — verified sender, e.g. founders@psyclinicai.com
 *
 * When secrets are unset, the function logs a single info line and
 * returns — useful for dev / preview / regression test runs.
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

interface WaitlistDoc {
  email?: string;
  clinic_name?: string;
  country?: string;
  region?: string;
  role?: string;
  source?: string;
}

interface SendgridResult {
  ok: boolean;
  skipped?: boolean;
  reason?: string;
  status?: number;
}

async function sendWelcome(
  email: string,
  templateData: Record<string, string>,
): Promise<SendgridResult> {
  const apiKey = process.env.SENDGRID_API_KEY ?? "";
  const templateId = process.env.SENDGRID_TEMPLATE_WAITLIST ?? "";
  const fromEmail =
    process.env.SENDGRID_FROM_EMAIL ?? "founders@psyclinicai.com";
  if (!apiKey || !templateId) {
    return {ok: true, skipped: true, reason: "secrets_unset"};
  }
  const body = {
    personalizations: [
      {
        to: [{email}],
        dynamic_template_data: templateData,
      },
    ],
    from: {email: fromEmail, name: "PsyClinicAI"},
    template_id: templateId,
    asm: {group_id: 0, groups_to_display: []},
    mail_settings: {sandbox_mode: {enable: false}},
  };
  const res = await fetch("https://api.sendgrid.com/v3/mail/send", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  return {ok: res.ok, status: res.status};
}

/**
 * Fires once per new landing-waitlist row.
 */
export const onLandingWaitlistCreate = functions
  .region("europe-west1")
  .firestore.document("landing_waitlist/{docId}")
  .onCreate(async (snap) => {
    const doc = (snap.data() ?? {}) as WaitlistDoc;
    const email = (doc.email ?? "").trim();
    if (!email) {
      functions.logger.warn("waitlist.no_email", {docId: snap.id});
      return;
    }
    const result = await sendWelcome(email, {
      list: "landing-waitlist",
      cohort: "Wave A",
      reply_to: "founders@psyclinicai.com",
    });
    await snap.ref.set(
      {
        welcome_sent_at: admin.firestore.FieldValue.serverTimestamp(),
        welcome_result: result,
      },
      {merge: true},
    );
  });

/**
 * Fires once per new beta-signups row (richer template — pilot path).
 */
export const onBetaSignupCreate = functions
  .region("europe-west1")
  .firestore.document("beta_signups/{docId}")
  .onCreate(async (snap) => {
    const doc = (snap.data() ?? {}) as WaitlistDoc;
    const email = (doc.email ?? "").trim();
    if (!email) {
      functions.logger.warn("beta_signup.no_email", {docId: snap.id});
      return;
    }
    const result = await sendWelcome(email, {
      list: "beta-signups",
      cohort: "Wave A — pilot",
      clinic_name: doc.clinic_name ?? "",
      country: doc.country ?? "",
      role: doc.role ?? "",
      reply_to: "founders@psyclinicai.com",
    });
    await snap.ref.set(
      {
        welcome_sent_at: admin.firestore.FieldValue.serverTimestamp(),
        welcome_result: result,
      },
      {merge: true},
    );
  });
