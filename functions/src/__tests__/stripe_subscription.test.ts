// Sprint 32 P0 — pure-logic tests for the subscription webhook
// helpers. The HTTP handler exercises Firestore through transactions
// which is covered by the manual Stripe-CLI replay in
// docs/runbooks/stripe-graduation.md (born on first use).

jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: {
      serverTimestamp: () => "__SERVER_TS__",
    },
  },
}));
jest.mock("firebase-functions", () => {
  const onRequest = (fn: unknown) => fn;
  const region = () => ({https: {onRequest}});
  const runWith = () => ({region});
  return {
    logger: {warn: jest.fn(), error: jest.fn(), info: jest.fn()},
    https: {onRequest},
    runWith,
    region,
  };
});
jest.mock("../lib/stripe", () => ({
  stripeClient: () => ({
    webhooks: {constructEvent: jest.fn()},
  }),
}));

import {
  buildSubscriptionRecord,
  classifyTransition,
} from "../stripe_subscription";

describe("classifyTransition", () => {
  it("trial_to_paid on trialing → active", () => {
    expect(classifyTransition("trialing", "active")).toBe("trial_to_paid");
  });

  it("renewed on active → active", () => {
    expect(classifyTransition("active", "active")).toBe("renewed");
  });

  it("cancelled regardless of previous state", () => {
    expect(classifyTransition("active", "canceled")).toBe("cancelled");
    expect(classifyTransition("trialing", "canceled")).toBe("cancelled");
    expect(classifyTransition(undefined, "canceled")).toBe("cancelled");
  });

  it("noop for unhandled transitions", () => {
    expect(classifyTransition("active", "past_due")).toBe("noop");
    expect(classifyTransition(undefined, "incomplete")).toBe("noop");
  });
});

describe("buildSubscriptionRecord", () => {
  const sub = {
    id: "sub_test_001",
    status: "active",
    current_period_end: 1_780_000_000,
    cancel_at: null,
    items: {
      data: [
        {
          price: {
            id: "price_solo_monthly",
            product: "prod_solo",
            unit_amount: 4900,
            currency: "usd",
          },
        },
      ],
    },
    metadata: {tenant_id: "tenant_42"},
  };

  it("flattens the first line-item price + product", () => {
    const rec = buildSubscriptionRecord(sub, "trial_to_paid");
    expect(rec.subscription_id).toBe("sub_test_001");
    expect(rec.status).toBe("active");
    expect(rec.transition).toBe("trial_to_paid");
    expect(rec.price_id).toBe("price_solo_monthly");
    expect(rec.product_id).toBe("prod_solo");
    expect(rec.unit_amount).toBe(4900);
    expect(rec.currency).toBe("usd");
    expect(rec.current_period_end).toBe(1_780_000_000);
    expect(rec.last_sync_at).toBe("__SERVER_TS__");
  });

  it("tolerates a subscription with no items array", () => {
    const rec = buildSubscriptionRecord(
      {id: "sub_naked", status: "active"},
      "renewed",
    );
    expect(rec.price_id).toBeNull();
    expect(rec.product_id).toBeNull();
    expect(rec.unit_amount).toBeNull();
    expect(rec.currency).toBeNull();
  });

  it("propagates cancel_at when provided", () => {
    const rec = buildSubscriptionRecord(
      {
        id: "sub_cxl",
        status: "active",
        cancel_at: 1_780_500_000,
      },
      "noop",
    );
    expect(rec.cancel_at).toBe(1_780_500_000);
  });
});
