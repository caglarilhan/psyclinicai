import Stripe from "stripe";

import { env } from "./env";

/**
 * Single Stripe client factory so the SDK version (and any future
 * options like `maxNetworkRetries`) stay in one place. Lazy so the
 * module can be imported in tests without the env var being set.
 */
let _client: Stripe | undefined;

export function stripeClient(): Stripe {
  if (_client) return _client;
  _client = new Stripe(env.STRIPE_SECRET_KEY, {
    apiVersion: "2024-06-20",
  });
  return _client;
}

/**
 * Verify a Stripe webhook signature. Throws when the secret env var
 * is absent so a misconfigured deploy refuses events outright.
 *
 * Sprint 28 / F-006 close: pin replay tolerance to 300 s (5 min)
 * explicitly. The Stripe SDK already defaults to 300 but the pentest
 * ledger asked for the value to be visible in code so reviewers do not
 * have to trust a vendor default.
 */
const WEBHOOK_REPLAY_TOLERANCE_SECONDS = 300;

export function verifyWebhook(
  rawBody: Buffer,
  signature: string,
): Stripe.Event {
  return stripeClient().webhooks.constructEvent(
    rawBody,
    signature,
    env.STRIPE_WEBHOOK_SECRET,
    WEBHOOK_REPLAY_TOLERANCE_SECONDS,
  );
}
