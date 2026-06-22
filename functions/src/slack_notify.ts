/**
 * Sprint 30 polish — Slack webhook ping every time a fresh beta signup
 * lands. Lets the founder run direct outreach within minutes instead of
 * polling a Firestore dashboard.
 *
 * Required secret: SLACK_SIGNUP_WEBHOOK — incoming webhook URL for the
 * `#launches` channel.
 *
 * No-op when the secret is unset, so the function is safe to deploy
 * ahead of the vendor unlock (see `vendor-unlocks.md` §6).
 */

import * as functions from "firebase-functions";

interface SignupDoc {
  email?: string;
  clinic_name?: string;
  country?: string;
  region?: string;
  role?: string;
}

function summarise(doc: SignupDoc): string {
  const email = doc.email ?? "(no email)";
  const clinic = doc.clinic_name ?? "(unknown clinic)";
  const region = doc.region ?? "??";
  const role = doc.role ?? "??";
  const country = doc.country ?? "??";
  return `:tada: new beta signup\n*${email}*\n_${clinic}_ — ${role} · ${country} · ${region}`;
}

async function postToSlack(text: string): Promise<void> {
  const hook = process.env.SLACK_SIGNUP_WEBHOOK ?? "";
  if (!hook) return; // no-op until vendor unlock
  try {
    await fetch(hook, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({text, unfurl_links: false}),
    });
  } catch (e) {
    functions.logger.error("slack_signup.post_failed", {
      error: String(e).slice(0, 200),
    });
  }
}

export const onBetaSignupSlack = functions
  .region("europe-west1")
  .firestore.document("beta_signups/{docId}")
  .onCreate(async (snap) => {
    await postToSlack(summarise((snap.data() ?? {}) as SignupDoc));
  });
