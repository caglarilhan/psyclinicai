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

import { applyCors, authorizeUid } from "./lib/auth";
import { env } from "./lib/env";
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

/** 1. Anthropic relay — key stays server-side; clients send transcript only. */
export const anthropicRelay = functions.https.onRequest(async (req, res) => {
  if (applyCors(req, res)) return;
  if (req.method !== "POST") return void res.status(405).send("POST only");

  const uid = await authorizeUid(req, "anthropicRelay");
  if (!uid) return void res.status(401).json({ error: "unauthorized" });

  try {
    const upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(req.body),
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
      await db.collection("subscriptions").doc(email).set(
        { tier, active, status: sub.status, updatedAt: Date.now() },
        { merge: true },
      );
    }
  }
  res.json({ received: true });
});
