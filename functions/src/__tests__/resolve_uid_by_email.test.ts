/**
 * M-13 (audit 2026-06-21) — verify the email→uid resolver swallows
 * `auth/user-not-found` and propagates everything else. This is the
 * helper that lets stripeWebhook write to subscriptions/{uid}
 * instead of subscriptions/{email} (PII in doc path).
 */
process.env.STRIPE_API_KEY = "sk_test_dummy";
process.env.STRIPE_WEBHOOK_SECRET = "whsec_dummy";
process.env.STRIPE_SUBSCRIPTION_WEBHOOK_SECRET = "whsec_sub_dummy";
process.env.ALLOWED_ORIGINS = "https://app.test";
process.env.APP_URL = "https://app.test";

const getUserByEmail = jest.fn();
jest.mock("firebase-admin", () => ({
  initializeApp: jest.fn(),
  apps: [{}], // pretend already-initialised so index.ts skips initializeApp
  firestore: Object.assign(
    () => ({
      collection: () => ({doc: () => ({set: jest.fn()})}),
    }),
    {FieldValue: {serverTimestamp: () => "__TS__"}},
  ),
  auth: () => ({getUserByEmail}),
}));

jest.mock("firebase-functions", () => {
  // Chainable stub: every method returns the same proxy so
  // expressions like `functions.runWith({...}).region("eu").firestore
  // .document("x/{id}").onCreate(fn)` resolve without throwing.
  const passthrough = (fn: unknown) => fn;
  const trigger = {
    onRun: passthrough,
    onCreate: passthrough,
    onUpdate: passthrough,
    onDelete: passthrough,
    onWrite: passthrough,
    onCall: passthrough,
    onRequest: passthrough,
  };
  const chain: Record<string, unknown> = {};
  Object.assign(chain, {
    runWith: () => chain,
    region: () => chain,
    https: {onRequest: passthrough, onCall: passthrough},
    firestore: {document: () => trigger},
    auth: {user: () => trigger},
    pubsub: {
      schedule: () => ({
        timeZone: () => trigger,
        ...trigger,
      }),
    },
    timeZone: () => trigger,
    document: () => trigger,
    user: () => trigger,
    schedule: () => ({timeZone: () => trigger, ...trigger}),
  });
  return {
    logger: {warn: jest.fn(), error: jest.fn(), info: jest.fn()},
    ...chain,
  };
});

jest.mock("../lib/stripe", () => ({
  stripeClient: () => ({
    webhooks: {constructEvent: jest.fn()},
  }),
  verifyWebhook: jest.fn(),
  tierByPrice: () => ({}),
}));

import {resolveUidByEmail} from "../index";

describe("resolveUidByEmail — M-13", () => {
  beforeEach(() => getUserByEmail.mockReset());

  it("returns the uid when the user exists", async () => {
    getUserByEmail.mockResolvedValueOnce({uid: "clinic-42"});
    expect(await resolveUidByEmail("doc@example.com")).toBe("clinic-42");
    expect(getUserByEmail).toHaveBeenCalledWith("doc@example.com");
  });

  it("returns null when getUserByEmail throws auth/user-not-found", async () => {
    getUserByEmail.mockRejectedValueOnce({code: "auth/user-not-found"});
    expect(await resolveUidByEmail("ghost@example.com")).toBeNull();
  });

  it("returns null on errorInfo.code shape (admin SDK 12+)", async () => {
    getUserByEmail.mockRejectedValueOnce({
      errorInfo: {code: "auth/user-not-found"},
    });
    expect(await resolveUidByEmail("ghost@example.com")).toBeNull();
  });

  it("propagates non-not-found errors (network/permission)", async () => {
    const boom = new Error("unreachable");
    Object.assign(boom, {code: "auth/internal-error"});
    getUserByEmail.mockRejectedValueOnce(boom);
    await expect(resolveUidByEmail("a@b.com")).rejects.toBe(boom);
  });
});
