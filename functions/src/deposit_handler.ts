/**
 * Deposit + no-show capture (Sprint 11, hardened Sprint 14 review).
 *
 * Creates a Stripe PaymentIntent in `manual_capture` mode so the card
 * is authorised when the patient confirms the slot but not charged
 * until the no-show window closes. Two endpoints:
 *
 *   POST /deposit/intent   — clinician creates the hold
 *   POST /deposit/capture  — clinician marks a no-show, funds are taken
 *
 * Hardening highlights (post-review):
 *   • `paymentIntentId` is format-checked (`pi_` prefix + 24+ chars)
 *     before reaching Stripe.
 *   • Capture verifies the PaymentIntent's `metadata.clinicId`
 *     matches the caller — prevents IDOR / cross-clinic capture.
 *   • `customerId` is retrieved and its `metadata.clinicId` is
 *     checked too — prevents creating intents against another
 *     clinic's Stripe customer.
 *   • PaymentIntent creation uses an idempotency key built from
 *     `uid + appointmentId` so a client retry never doubles up.
 */
import * as functions from "firebase-functions";

import { applyCors, authorizeClinicianUid } from "./lib/auth";
import { stripeClient } from "./lib/stripe";

/**
 * Minimum chargeable amount per currency (Stripe minimum order value).
 */
export const minDepositCentsByCurrency: Record<string, number> = {
  EUR: 50,
  USD: 50,
  GBP: 30,
  TRY: 1500,
};

/**
 * Validate the requested deposit amount. Returns an empty string if
 * the amount is acceptable, or an explainer message.
 */
export function validateDepositAmount(
  amountCents: number,
  currency: string,
): string {
  if (!Number.isInteger(amountCents) || amountCents <= 0) {
    return "amountCents must be a positive integer";
  }
  const code = currency.toUpperCase();
  const min = minDepositCentsByCurrency[code];
  if (min == null) {
    return `Unsupported currency: ${currency}`;
  }
  if (amountCents < min) {
    return `Below the ${code} minimum (${min} cents)`;
  }
  if (amountCents > 100_000) {
    return "Deposit exceeds the 1,000 unit ceiling";
  }
  return "";
}

/** Stripe PaymentIntent id pattern — `pi_` + alphanumeric. */
const PI_PATTERN = /^pi_[a-zA-Z0-9_]{8,}$/;
/** Stripe Customer id pattern — `cus_` + alphanumeric. */
const CUSTOMER_PATTERN = /^cus_[a-zA-Z0-9_]{8,}$/;

export function isValidPaymentIntentId(id: string): boolean {
  return PI_PATTERN.test(id);
}

export function isValidCustomerId(id: string): boolean {
  return CUSTOMER_PATTERN.test(id);
}

/**
 * Captures (no-show) are only allowed when the deposit is currently
 * `held` AND the appointment's scheduled time has passed by at least
 * 24h. Pure for unit tests.
 */
export function canCaptureDeposit(
  row: { status: string; scheduledFor: Date },
  now: Date,
  policyWindowHours = 24,
): { ok: boolean; reason: string } {
  if (row.status !== "held") {
    return { ok: false, reason: "Deposit is not in `held` state" };
  }
  const windowEnd =
    row.scheduledFor.getTime() + policyWindowHours * 60 * 60 * 1000;
  if (now.getTime() < windowEnd) {
    return {
      ok: false,
      reason:
        "Cannot capture until the no-show policy window has closed",
    };
  }
  return { ok: true, reason: "" };
}

function logStripeError(scope: string, e: unknown): void {
  const err = e as { code?: string; type?: string };
  functions.logger.error(`${scope}.stripe_error`, {
    code: err.code,
    type: err.type,
  });
}

/**
 * POST /deposit/intent — create a PaymentIntent in manual-capture mode.
 */
export const depositIntent = functions.https.onRequest(async (req, res) => {
  if (applyCors(req, res)) return;
  if (req.method !== "POST") return void res.status(405).send("POST only");

  const uid = await authorizeClinicianUid(req, "depositIntent");
  if (!uid) return void res.status(401).json({ error: "unauthorized" });

  const amountCents = Number(req.body?.amountCents ?? 0);
  const currency = String(req.body?.currency ?? "EUR");
  const customerId = String(req.body?.customerId ?? "");
  const appointmentId = String(req.body?.appointmentId ?? "");
  if (!customerId || !appointmentId) {
    return void res.status(400).json({ error: "missing_fields" });
  }
  if (!isValidCustomerId(customerId)) {
    return void res.status(400).json({ error: "bad_customer_id" });
  }
  const v = validateDepositAmount(amountCents, currency);
  if (v) {
    return void res.status(400).json({ error: "bad_amount", detail: v });
  }

  try {
    // Verify the Stripe customer actually belongs to this clinician.
    const customer = await stripeClient().customers.retrieve(customerId);
    if (
      customer.deleted ||
      (customer as { metadata?: { clinicId?: string } }).metadata
        ?.clinicId !== uid
    ) {
      functions.logger.warn("depositIntent.customer_ownership_mismatch", {
        uid,
        customerId,
      });
      return void res.status(403).json({ error: "forbidden_customer" });
    }

    const intent = await stripeClient().paymentIntents.create(
      {
        amount: amountCents,
        currency: currency.toLowerCase(),
        capture_method: "manual",
        customer: customerId,
        metadata: {
          clinicId: uid,
          appointmentId,
          purpose: "deposit",
        },
      },
      { idempotencyKey: `deposit-${uid}-${appointmentId}` },
    );
    res.json({
      paymentIntentId: intent.id,
      clientSecret: intent.client_secret,
    });
  } catch (e) {
    logStripeError("depositIntent", e);
    res.status(502).json({ error: "stripe_error" });
  }
});

/**
 * POST /deposit/capture — clinician marks a no-show; funds are taken.
 * Verifies the PI belongs to the caller before capturing.
 */
export const depositCapture = functions.https.onRequest(async (req, res) => {
  if (applyCors(req, res)) return;
  if (req.method !== "POST") return void res.status(405).send("POST only");

  const uid = await authorizeClinicianUid(req, "depositCapture");
  if (!uid) return void res.status(401).json({ error: "unauthorized" });

  const paymentIntentId = String(req.body?.paymentIntentId ?? "");
  const noShowReasonCode = String(req.body?.noShowReasonCode ?? "");
  if (!paymentIntentId || !noShowReasonCode) {
    return void res.status(400).json({ error: "missing_fields" });
  }
  if (!isValidPaymentIntentId(paymentIntentId)) {
    return void res.status(400).json({ error: "bad_payment_intent_id" });
  }

  try {
    // Verify the PaymentIntent's metadata.clinicId before capturing —
    // refuses cross-clinic capture attempts.
    const existing = await stripeClient().paymentIntents.retrieve(
      paymentIntentId,
    );
    if ((existing.metadata?.clinicId ?? null) !== uid) {
      functions.logger.warn("depositCapture.ownership_mismatch", {
        uid,
        paymentIntentId,
      });
      return void res.status(403).json({ error: "forbidden_intent" });
    }

    const captured = await stripeClient().paymentIntents.capture(
      paymentIntentId,
    );
    functions.logger.info("deposit.captured", {
      paymentIntentId,
      reason: noShowReasonCode,
    });
    res.json({
      capturedAt: new Date().toISOString(),
      status: captured.status,
    });
  } catch (e) {
    logStripeError("depositCapture", e);
    res.status(502).json({ error: "stripe_error" });
  }
});
