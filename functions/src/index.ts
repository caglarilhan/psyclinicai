/**
 * PsyClinicAI backend — Firebase Cloud Functions entry point.
 *
 * HTTP handlers:
 *   • anthropicRelay         — proxy LLM calls so the API key + PHI
 *                              never sit in the browser.
 *   • createCheckoutSession  — create a Stripe Checkout session.
 *   • stripeWebhook          — sync subscription status into Firestore.
 *   • telehealthRoom         — mint a Daily.co meeting room + token.
 *   • depositIntent          — create a manual-capture PaymentIntent.
 *   • depositCapture         — capture the no-show charge.
 *
 * Scheduled compliance jobs (no HTTP surface, exported for Firebase
 * deploy discovery):
 *   • auditRetentionPurge        (Sprint 9, HIPAA §164.316)
 *   • accountDeletionPurge       (Sprint 9, GDPR Art. 17)
 *   • escalationSoftLockCleanup  (Sprint 10, C-SSRS cross-device)
 *   • accessReviewCron           (Sprint 14, SOC 2 CC6.1)
 *
 * Cross-cutting helpers live under `./lib/`:
 *   • `lib/env.ts`     — fail-fast env loader + CORS allow-list.
 *   • `lib/auth.ts`    — Firebase ID token verification + clinician
 *                         claim gate + CORS preflight handshake.
 *   • `lib/stripe.ts`  — single Stripe client factory.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

// Sprint 9 — scheduled compliance jobs.
export { auditRetentionPurge } from "./audit_retention_purge";
export { accountDeletionPurge } from "./account_deletion_purge";

// Sprint 10 — C-SSRS cross-device soft-lock cleanup (hourly).
export { escalationSoftLockCleanup } from "./escalation_soft_lock_cleanup";

// Sprint 11 — Telehealth room minting + Stripe deposit handlers.
export { telehealthRoom } from "./telehealth_room";
export { depositIntent, depositCapture } from "./deposit_handler";

// Sprint 21 — server-side LLM proxy + Stripe Connect onboarding.
export { llmProxy } from "./llm_proxy";
export {
  stripeConnectOnboard,
  stripeConnectWebhook,
} from "./stripe_connect";

// Sprint 27 — server-side Clinical RAG proxy (F-003 close).
export { ragProxy } from "./rag_proxy";

// Sprint 14 — SOC 2 quarterly access review snapshot cron.
export { accessReviewCron } from "./access_review_cron";

// Sprint 25 W2 — public health probe for statuspage.io polling.
export { healthcheck } from "./healthcheck";

// Sprint 30 PILAR1 — Ambient Clinical Scribe SOAP draft generator.
export { aiScribeDraftSoap } from "./ai_scribe_draft_soap";

// Sprint 26 W1 — WebAuthn / FIDO2 passkey enrolment + assertion.
export {
  passkeyRegisterOptions,
  passkeyRegisterVerify,
} from "./passkey_register";
export {
  passkeyAuthOptions,
  passkeyAuthVerify,
} from "./passkey_authenticate";

// Sprint 29 S-03 — assign tenant_id custom claim on user creation +
// admin re-bind for group practices. Unblocks DEFAULT_TENANT_ID="" on
// the psyrag hub.
export {
  assignTenantOnCreate,
  adminSetTenantClaim,
} from "./setTenantClaim";

// Sprint 29 P-08 — waitlist welcome email triggers (Sendgrid template).
// No-op until SENDGRID_API_KEY + SENDGRID_TEMPLATE_WAITLIST are set in
// Cloud Functions secrets; safe to deploy ahead of vendor unlock.
export {
  onLandingWaitlistCreate,
  onBetaSignupCreate,
} from "./waitlist_email";

// Sprint 30 polish — Slack ping on new beta signup (SLACK_SIGNUP_WEBHOOK).
export {onBetaSignupSlack} from "./slack_notify";

// Sprint 30 polish — founders@ inbox digest on new beta signup. Sendgrid
// no-template fallback so it ships value even before the digest template
// is designed.
export {onBetaSignupFoundersEmail} from "./founders_email";

// Sprint 32 P0 — Wave A → Wave B billing graduation hook. Idempotent
// via processed_webhooks/{event.id}; no-op until
// STRIPE_SUBSCRIPTION_WEBHOOK_SECRET is set.
export {stripeSubscriptionWebhook} from "./stripe_subscription";

// Sprint 32 P1 — EHR FHIR R4 Observation submit handler. Outbox-backed
// + retry-aware; idempotent on (endpoint, instrument, patient, date).
export {ehrSubmitProm} from "./ehr_observation_handler";

// Sprint 33 P1 — hourly reconciler: sweeps failed outbox rows, retries
// up to 24 h, then flips to permanently_failed + Slack-visible.
export {ehrOutboxReconciler} from "./ehr_outbox_reconciler";

// Sprint 33 P2 — Customer Portal session mint. Stripe Portal is the only
// place card-edits live; the app redirects through this endpoint so we
// stay outside PCI scope.
export {stripeCustomerPortalSession} from "./stripe_customer_portal";

// M2 (audit 2026-06-21) — GDPR Art. 15 + 20 patient data export.
// Returns a structured JSON bundle of every record we hold about the
// patient, scoped to the calling clinician's tenancy. Audit-logged.
export {dsarExport} from "./dsar_export";

// M-11 (audit 2026-06-21) — GDPR Art. 7(3) consent-withdrawal audit
// trigger. Mirrors every consent_records.withdrawnAt transition into
// the immutable audit_logs chain so a disputed downstream processing
// event can be traced back to the withdrawal moment.
export {consentWithdrawalAudit} from "./consent_withdrawal_audit";

import { applyCors, authorizeUid } from "./lib/auth";
import { checkAiConsent, extractPatientId } from "./lib/consent_gate";
import { env } from "./lib/env";
import { scrubPhiInPayload } from "./lib/phi_scrub";
import { applyRateLimit, applySecurityHeaders } from "./lib/security_chain";
import { stripeClient, verifyWebhook } from "./lib/stripe";

const db = admin.firestore();

/**
 * Lazy lookup so the module imports without env vars in tests; the
 * checkout handler is the first caller that needs them.
 */
function priceByTier(): Record<string, string | undefined> {
  return {
    solo: process.env.STRIPE_PRICE_SOLO,
    practice: process.env.STRIPE_PRICE_PRACTICE,
    group: process.env.STRIPE_PRICE_GROUP,
  };
}

function tierByPrice(): Record<string, string> {
  return Object.entries(priceByTier())
    .filter(([, v]) => !!v)
    .reduce(
      (acc, [tier, price]) => ({ ...acc, [price as string]: tier }),
      {},
    );
}

/**
 * 1. Anthropic relay — key stays server-side; clients send transcript only.
 *
 * KRİTİK-2 / KRİTİK-4 (audit 2026-06-21) hardening:
 *  - Consent gate: a request that mentions a `patientId` must show an
 *    active `consent_records` row with `aiAssistanceConsent == true`.
 *    Non-PHI calls (no patientId) skip the gate.
 *  - PHI scrub: every string field in the forwarded body is walked
 *    through the server-side detector set; identifiers are replaced
 *    with tokens before egress. The Anthropic side only sees the
 *    minimum-necessary text.
 *  - Body size cap: 256 KB. Anthropic itself caps at 200K tokens but
 *    we refuse oversize payloads up front so a runaway client cannot
 *    burn the proxy key.
 *  - Model allow-list: only the 3 Claude families we have a contract
 *    for. Defensive against a typo'd or experimental model name
 *    leaking through. `model` unset → upstream applies its default and
 *    we let it through, so legacy callers keep working.
 */
const ALLOWED_RELAY_MODELS = new Set([
  "claude-haiku-4-5",
  "claude-haiku-4-5-20251001",
  "claude-sonnet-4-6",
  "claude-opus-4-7",
]);
const MAX_RELAY_BODY_BYTES = 256 * 1024;

export const anthropicRelay = functions.https.onRequest(async (req, res) => {
  applySecurityHeaders(res);
  if (applyCors(req, res)) return;
  if (applyRateLimit(req, res, "ai-copilot-inference")) return;
  if (req.method !== "POST") return void res.status(405).send("POST only");

  const uid = await authorizeUid(req, "anthropicRelay");
  if (!uid) return void res.status(401).json({ error: "unauthorized" });

  const body = req.body as Record<string, unknown> | undefined;
  if (!body || typeof body !== "object") {
    return void res.status(400).json({ error: "bad_request" });
  }

  // Model allow-list. `model` is optional on the Anthropic API; only
  // reject when the caller named something we do not expect.
  const requestedModel = typeof body.model === "string" ? body.model : "";
  if (requestedModel && !ALLOWED_RELAY_MODELS.has(requestedModel)) {
    functions.logger.warn("anthropicRelay.unknown_model", {
      uid,
      model: requestedModel.slice(0, 80),
    });
    return void res.status(400).json({ error: "unknown_model" });
  }

  // Size cap. JSON.stringify before the fetch anyway, so do it here
  // for the budget check and reuse the string.
  let serialised: string;
  try {
    serialised = JSON.stringify(body);
  } catch (e) {
    return void res
      .status(400)
      .json({ error: "bad_request", detail: String(e) });
  }
  if (serialised.length > MAX_RELAY_BODY_BYTES) {
    functions.logger.warn("anthropicRelay.body_too_large", {
      uid,
      bytes: serialised.length,
      cap: MAX_RELAY_BODY_BYTES,
    });
    return void res.status(413).json({ error: "body_too_large" });
  }

  // Consent gate — only enforced when the caller flagged a patient.
  const patientId = extractPatientId(body);
  if (patientId !== null) {
    const decision = await checkAiConsent({
      db,
      clinicId: uid,
      patientId,
    });
    if (!decision.ok) {
      functions.logger.warn("anthropicRelay.consent_denied", {
        uid,
        reason: decision.reason,
      });
      return void res
        .status(403)
        .json({ error: "consent_required", reason: decision.reason });
    }
  }

  // PHI scrub — applied to every string in the payload, including
  // nested `messages[*].content` and `system` prompts.
  const { payload: scrubbedBody, totalRemoved, removed } =
    scrubPhiInPayload(body);
  if (totalRemoved > 0) {
    functions.logger.info("anthropicRelay.phi_scrubbed", {
      uid,
      total: totalRemoved,
      removed,
    });
  }

  try {
    const upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(scrubbedBody),
    });
    const text = await upstream.text();
    res
      .status(upstream.status)
      .set("Content-Type", "application/json")
      .send(text);
  } catch (e) {
    functions.logger.error("anthropicRelay.upstream_failed", {
      reason: String(e),
    });
    res.status(502).json({ error: "relay_failed" });
  }
});

/** 2. Create a Stripe Checkout session for a tier. */
export const createCheckoutSession = functions.https.onRequest(
  async (req, res) => {
    if (applyCors(req, res)) return;
    if (req.method !== "POST") return void res.status(405).send("POST only");

    const tier = String(req.body?.tier ?? "");
    const email = req.body?.email as string | undefined;
    const price = priceByTier()[tier];
    if (!price) return void res.status(400).json({ error: "unknown_tier" });

    try {
      const session = await stripeClient().checkout.sessions.create({
        mode: "subscription",
        line_items: [{ price, quantity: 1 }],
        customer_email: email,
        success_url: `${env.APP_URL}/#/dashboard?checkout=success`,
        cancel_url: `${env.APP_URL}/#/?checkout=cancel`,
      });
      res.json({ url: session.url });
    } catch (e) {
      const err = e as { code?: string; type?: string };
      functions.logger.error("createCheckoutSession.failed", {
        code: err.code,
        type: err.type,
      });
      res.status(502).json({ error: "stripe_error" });
    }
  },
);

/** 3. Stripe webhook — keep subscription status in Firestore. */
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"] as string;
  let event;
  try {
    event = verifyWebhook(
      (req as functions.https.Request).rawBody,
      sig,
    );
  } catch (e) {
    functions.logger.error("stripeWebhook.bad_signature", {
      reason: String(e),
    });
    return void res.status(400).send("bad signature");
  }

  // M-5 fix (audit 2026-06-21): Stripe delivers at-least-once, so we
  // dedupe via processed_webhooks/{event.id}. Without this a retried
  // event could re-trigger the subscription tier write — fine for
  // updates, bad for downgrades that race a fresh upgrade. The
  // transactional set + check matches the pattern in
  // stripe_subscription.ts so both webhooks share semantics.
  const processedRef = db.collection("processed_webhooks").doc(event.id);
  const dedupe = await db.runTransaction(async (tx) => {
    const seen = await tx.get(processedRef);
    if (seen.exists) return "duplicate";
    tx.set(processedRef, {
      event_id: event.id,
      event_type: event.type,
      processed_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    return "fresh";
  });
  if (dedupe === "duplicate") {
    res.json({received: true, duplicate: true});
    return;
  }

  if (
    event.type === "customer.subscription.created" ||
    event.type === "customer.subscription.updated" ||
    event.type === "customer.subscription.deleted"
  ) {
    const sub = event.data.object;
    const email = (sub as unknown as { customer_email?: string })
      .customer_email;
    const priceId = sub.items.data[0]?.price.id ?? "";
    const tier = tierByPrice()[priceId] ?? "free";
    const active = sub.status === "active" || sub.status === "trialing";

    if (email) {
      // M-13 fix (audit 2026-06-21): subscriptions used to be keyed
      // by `email`, which (a) leaks PII into the doc path (logs,
      // exports), (b) breaks when a user changes email, and (c)
      // cannot be guarded by Firestore rules without a custom claim
      // map. Switch to `subscriptions/{uid}` by resolving the
      // Firebase Auth user. If the email has no matching user (e.g.
      // someone bought before signing up), we log and skip — the
      // newer stripe_subscription.ts path is the canonical writer
      // for tenant-scoped records.
      const uid = await resolveUidByEmail(email);
      if (uid) {
        await db.collection("subscriptions").doc(uid).set(
          {
            tier,
            active,
            status: sub.status,
            customer_email: email,
            updatedAt: Date.now(),
          },
          { merge: true },
        );
      } else {
        functions.logger.warn("stripeWebhook.no_uid_for_email", {
          event_id: event.id,
        });
      }
    }
  }
  res.json({ received: true });
});

/**
 * M-13 helper (audit 2026-06-21) — resolve a Firebase Auth UID from
 * an email. Returns null when the user is unknown (race between
 * checkout and signup, deleted account) so the caller can decide
 * how to log + skip. Exposed for unit tests.
 */
export async function resolveUidByEmail(
  email: string,
): Promise<string | null> {
  try {
    const user = await admin.auth().getUserByEmail(email);
    return user.uid;
  } catch (e) {
    // getUserByEmail throws `auth/user-not-found` when there is no
    // match. We swallow only that case; any other error (network,
    // permission) should still bubble for observability.
    const code =
      (e as {code?: string})?.code ?? (e as {errorInfo?: {code?: string}})
        ?.errorInfo?.code;
    if (code === "auth/user-not-found") return null;
    throw e;
  }
}
