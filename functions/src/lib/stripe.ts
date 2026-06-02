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
 */
export function verifyWebhook(
  rawBody: Buffer,
  signature: string,
): Stripe.Event {
  return stripeClient().webhooks.constructEvent(
    rawBody,
    signature,
    env.STRIPE_WEBHOOK_SECRET,
  );
}
