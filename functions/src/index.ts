/**
 * PsyClinicAI backend (Firebase Cloud Functions).
 *
 * Three responsibilities, all keeping secrets server-side:
 *   1. anthropicRelay        — proxy LLM calls so the API key + PHI never sit
 *                              in the browser (closes SECURITY-BACKLOG #1).
 *   2. createCheckoutSession — create a Stripe Checkout session (secret key
 *                              never reaches the client).
 *   3. stripeWebhook         — sync subscription status into Firestore.
 *
 * Secrets come from environment (see .env.example) — nothing is committed.
 */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();
const db = admin.firestore();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY ?? "", {
  apiVersion: "2024-06-20",
});

// Maps our tier names to Stripe Price IDs (set in env).
const PRICE_BY_TIER: Record<string, string | undefined> = {
  solo: process.env.STRIPE_PRICE_SOLO,
  practice: process.env.STRIPE_PRICE_PRACTICE,
  group: process.env.STRIPE_PRICE_GROUP,
};
const TIER_BY_PRICE: Record<string, string> = Object.entries(PRICE_BY_TIER)
  .filter(([, v]) => !!v)
  .reduce((acc, [tier, price]) => ({ ...acc, [price as string]: tier }), {});

const APP_URL = process.env.APP_URL ?? "https://app.psyclinicai.com";

/** 1. Anthropic relay — key stays server-side; clients send transcript only. */
export const anthropicRelay = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", APP_URL);
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") return void res.status(204).send("");
  if (req.method !== "POST") return void res.status(405).send("POST only");

  // TODO(founder): verify the Firebase ID token here before relaying PHI.
  //   const decoded = await admin.auth().verifyIdToken(bearerToken);

  try {
    const upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": process.env.ANTHROPIC_API_KEY ?? "",
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify(req.body),
    });
    const text = await upstream.text();
    res.status(upstream.status).set("Content-Type", "application/json").send(text);
  } catch (e) {
    functions.logger.error("anthropicRelay failed", e);
    res.status(502).json({ error: "relay_failed" });
  }
});

/** 2. Create a Stripe Checkout session for a tier. */
export const createCheckoutSession = functions.https.onRequest(
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", APP_URL);
    res.set("Access-Control-Allow-Headers", "Content-Type");
    if (req.method === "OPTIONS") return void res.status(204).send("");
    if (req.method !== "POST") return void res.status(405).send("POST only");

    const tier = String(req.body?.tier ?? "");
    const email = req.body?.email as string | undefined;
    const price = PRICE_BY_TIER[tier];
    if (!price) return void res.status(400).json({ error: "unknown_tier" });

    try {
      const session = await stripe.checkout.sessions.create({
        mode: "subscription",
        line_items: [{ price, quantity: 1 }],
        customer_email: email,
        success_url: `${APP_URL}/#/dashboard?checkout=success`,
        cancel_url: `${APP_URL}/#/?checkout=cancel`,
      });
      res.json({ url: session.url });
    } catch (e) {
      functions.logger.error("createCheckoutSession failed", e);
      res.status(502).json({ error: "stripe_error" });
    }
  }
);

/** 3. Stripe webhook — keep subscription status in Firestore. */
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"] as string;
  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      (req as functions.https.Request).rawBody,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET ?? ""
    );
  } catch (e) {
    functions.logger.error("webhook signature verification failed", e);
    return void res.status(400).send("bad signature");
  }

  if (
    event.type === "customer.subscription.created" ||
    event.type === "customer.subscription.updated" ||
    event.type === "customer.subscription.deleted"
  ) {
    const sub = event.data.object as Stripe.Subscription;
    const email = (sub as unknown as { customer_email?: string }).customer_email;
    const priceId = sub.items.data[0]?.price.id ?? "";
    const tier = TIER_BY_PRICE[priceId] ?? "free";
    const active = sub.status === "active" || sub.status === "trialing";

    // TODO(founder): resolve the clinician UID from the Stripe customer id.
    if (email) {
      await db.collection("subscriptions").doc(email).set(
        { tier, active, status: sub.status, updatedAt: Date.now() },
        { merge: true }
      );
    }
  }
  res.json({ received: true });
});
