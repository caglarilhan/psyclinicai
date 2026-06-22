/**
 * Sprint 30 polish — founders@psyclinicai.com digest CF.
 *
 * Different from `waitlist_email.onBetaSignupCreate` — that one emails
 * the prospective pilot. This one emails the founder so they can act on
 * the lead within minutes (cold-email response window is < 1 h for the
 * meaningful reply-rate uplift cited by `cmo-advisor`).
 *
 * Required secret: SENDGRID_API_KEY + SENDGRID_FOUNDERS_INBOX (defaults
 * to founders@psyclinicai.com). Falls back to Sendgrid template id
 * `SENDGRID_TEMPLATE_FOUNDERS_DIGEST` if set; otherwise sends a plain
 * text email so the no-template path still ships value.
 */

import * as functions from "firebase-functions";

interface SignupDoc {
  email?: string;
  clinic_name?: string;
  country?: string;
  region?: string;
  role?: string;
  source?: string;
}

function plain(doc: SignupDoc): string {
  return [
    "New beta signup just landed.",
    "",
    `Email: ${doc.email ?? "(none)"}`,
    `Clinic: ${doc.clinic_name ?? "(unknown)"}`,
    `Country: ${doc.country ?? "?"}`,
    `Region: ${doc.region ?? "?"}`,
    `Role: ${doc.role ?? "?"}`,
    `Source: ${doc.source ?? "?"}`,
    "",
    "Outreach window: < 1 h ideally; the LinkedIn reply rate halves",
    "after that. Pilot agreement: docs/PILOT-AGREEMENT.md.",
  ].join("\n");
}

async function sendToFounders(doc: SignupDoc): Promise<void> {
  const apiKey = process.env.SENDGRID_API_KEY ?? "";
  const inbox =
    process.env.SENDGRID_FOUNDERS_INBOX ?? "founders@psyclinicai.com";
  const templateId = process.env.SENDGRID_TEMPLATE_FOUNDERS_DIGEST ?? "";
  if (!apiKey) {
    functions.logger.info("founders_email.skipped", {reason: "no_key"});
    return;
  }
  const fromEmail =
    process.env.SENDGRID_FROM_EMAIL ?? "founders@psyclinicai.com";
  const personalisation: Record<string, unknown> = {
    to: [{email: inbox}],
  };
  const body: Record<string, unknown> = {
    personalizations: [personalisation],
    from: {email: fromEmail, name: "PsyClinicAI signal"},
  };
  if (templateId) {
    personalisation["dynamic_template_data"] = {
      email: doc.email ?? "",
      clinic_name: doc.clinic_name ?? "",
      country: doc.country ?? "",
      region: doc.region ?? "",
      role: doc.role ?? "",
    };
    body["template_id"] = templateId;
  } else {
    body["subject"] = `New beta signup: ${doc.email ?? "(no email)"}`;
    body["content"] = [{type: "text/plain", value: plain(doc)}];
  }
  try {
    await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
  } catch (e) {
    functions.logger.error("founders_email.send_failed", {
      error: String(e).slice(0, 200),
    });
  }
}

export const onBetaSignupFoundersEmail = functions
  .region("europe-west1")
  .firestore.document("beta_signups/{docId}")
  .onCreate(async (snap) => {
    await sendToFounders((snap.data() ?? {}) as SignupDoc);
  });
