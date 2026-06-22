/**
 * Sprint 32 P0 — Wave A → Wave B billing graduation.
 *
 * Listens to three Stripe events relevant to the founding-member trial
 * cohort:
 *
 *   - `customer.subscription.updated`   → trial→active transition,
 *                                         plan change, period rollover.
 *   - `customer.subscription.deleted`   → cancel-at-period-end fired or
 *                                         the subscription was reaped.
 *   - `invoice.payment_failed`          → dunning trigger.
 *
 * Each event is processed idempotently via `processed_webhooks/{id}` —
 * same pattern as `stripe_connect.ts` (Sprint 29 B-09). The actual
 * dunning email is sent by a separate Sendgrid trigger reading the
 * dunning ledger so this handler stays a single Firestore write.
 *
 * Skill-panel coverage: senior-backend (handler shape), finance-
 * billing-ops (transition logic), release-manager (idempotency).
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {stripeClient} from "./lib/stripe";

/** Pure-logic mapper — kept exported so unit tests can hit it. */
export function classifyTransition(
  prev: string | undefined,
  next: string,
): "trial_to_paid" | "renewed" | "cancelled" | "noop" {
  if (next === "canceled") return "cancelled";
  if (prev === "trialing" && next === "active") return "trial_to_paid";
  if (prev === "active" && next === "active") return "renewed";
  return "noop";
}

interface SubscriptionLite {
  id: string;
  status: string;
  current_period_end?: number;
  cancel_at?: number | null;
  items?: {
    data: Array<{
      price?: {
        id?: string;
        product?: string;
        unit_amount?: number;
        currency?: string;
      };
    }>;
  };
  metadata?: Record<string, string>;
}

/** Build the Firestore-shaped record the dashboards read. */
export function buildSubscriptionRecord(
  sub: SubscriptionLite,
  transition: ReturnType<typeof classifyTransition>,
): Record<string, unknown> {
  const item = sub.items?.data?.[0];
  return {
    subscription_id: sub.id,
    status: sub.status,
    transition,
    current_period_end: sub.current_period_end ?? null,
    cancel_at: sub.cancel_at ?? null,
    price_id: item?.price?.id ?? null,
    product_id: item?.price?.product ?? null,
    unit_amount: item?.price?.unit_amount ?? null,
    currency: item?.price?.currency ?? null,
    last_sync_at: admin.firestore.FieldValue.serverTimestamp(),
  };
}

export const stripeSubscriptionWebhook = functions
  .runWith({minInstances: 0, memory: "256MB", timeoutSeconds: 30})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    const stripe = stripeClient();
    const signature = req.headers["stripe-signature"];
    const secret = process.env.STRIPE_SUBSCRIPTION_WEBHOOK_SECRET ?? "";
    if (!signature || !secret) {
      res.status(400).json({error: "missing_signature_or_secret"});
      return;
    }
    let event;
    try {
      event = stripe.webhooks.constructEvent(
        (req as unknown as {rawBody: Buffer}).rawBody,
        signature as string,
        secret,
      );
    } catch (e) {
      functions.logger.error("stripeSubscription.invalid", {
        error: String(e).slice(0, 200),
      });
      res.status(400).json({error: "invalid_signature"});
      return;
    }

    const relevant = new Set([
      "customer.subscription.updated",
      "customer.subscription.deleted",
      "invoice.payment_failed",
    ]);
    if (!relevant.has(event.type)) {
      res.json({ignored: true, type: event.type});
      return;
    }

    const processedRef = admin
      .firestore()
      .collection("processed_webhooks")
      .doc(event.id);

    const result = await admin.firestore().runTransaction(async (tx) => {
      const seen = await tx.get(processedRef);
      if (seen.exists) return "duplicate";

      tx.set(processedRef, {
        event_id: event.id,
        event_type: event.type,
        processed_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (event.type === "invoice.payment_failed") {
        const invoice = event.data.object as {
          id: string;
          customer: string;
          subscription?: string;
          amount_due?: number;
          attempt_count?: number;
          next_payment_attempt?: number | null;
          metadata?: Record<string, string>;
        };
        const tenantId =
          invoice.metadata?.tenant_id ?? invoice.customer ?? "";
        if (tenantId) {
          tx.set(
            admin
              .firestore()
              .collection("tenants")
              .doc(tenantId)
              .collection("private")
              .doc("dunning"),
            {
              invoice_id: invoice.id,
              amount_due: invoice.amount_due ?? 0,
              attempt_count: invoice.attempt_count ?? 1,
              next_payment_attempt: invoice.next_payment_attempt ?? null,
              last_failure_at:
                admin.firestore.FieldValue.serverTimestamp(),
            },
            {merge: true},
          );
        }
        return "dunning_recorded";
      }

      const sub = event.data.object as SubscriptionLite;
      const previousAttributes =
        (event.data as {previous_attributes?: {status?: string}})
          .previous_attributes ?? {};
      const transition = classifyTransition(
        previousAttributes.status,
        sub.status,
      );
      const tenantId = sub.metadata?.tenant_id ?? "";
      if (!tenantId) return "ignored_no_tenant";

      tx.set(
        admin
          .firestore()
          .collection("tenants")
          .doc(tenantId)
          .collection("private")
          .doc("stripe_subscription"),
        buildSubscriptionRecord(sub, transition),
        {merge: true},
      );
      return transition;
    });

    res.json({type: event.type, result});
  });
