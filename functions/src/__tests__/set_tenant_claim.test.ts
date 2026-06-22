/**
 * M-12 (audit 2026-06-21) — verify the adminSetTenantClaim
 * escalation surface rejects bad input + reserved prefixes.
 *
 * The handler itself is wrapped in `functions.https.onCall`; we mock
 * the wrapper to passthrough and invoke the unwrapped fn directly so
 * we can exercise the validation branches in isolation.
 */
const getUser = jest.fn();
const setCustomUserClaims = jest.fn();
const docSet = jest.fn();
const adminActionsAdd = jest.fn();

jest.mock("firebase-admin", () => ({
  auth: () => ({getUser, setCustomUserClaims}),
  firestore: Object.assign(
    () => ({
      doc: () => ({set: docSet}),
      collection: () => ({add: adminActionsAdd}),
    }),
    {
      FieldValue: {
        serverTimestamp: () => "__TS__",
      },
    },
  ),
}));

jest.mock("firebase-functions", () => {
  class HttpsError extends Error {
    constructor(public code: string, message: string) {
      super(message);
    }
  }
  return {
    logger: {warn: jest.fn(), error: jest.fn(), info: jest.fn()},
    auth: {user: () => ({onCreate: (fn: unknown) => fn})},
    https: {
      onCall: (fn: unknown) => fn,
      HttpsError,
    },
  };
});

import {adminSetTenantClaim, isValidTenantId, RESERVED_PREFIXES} from
  "../setTenantClaim";

type Callable = (
  data: Record<string, unknown>,
  context: {auth?: {uid: string; token: Record<string, unknown>}},
) => Promise<unknown>;

const callable = adminSetTenantClaim as unknown as Callable;

const adminCtx = {
  auth: {
    uid: "platform-admin-1",
    token: {is_platform_admin: true},
  },
};

beforeEach(() => {
  getUser.mockReset();
  setCustomUserClaims.mockReset();
  docSet.mockReset();
  adminActionsAdd.mockReset();
  getUser.mockResolvedValue({customClaims: {tenant_id: "tenant-old"}});
  setCustomUserClaims.mockResolvedValue(undefined);
  docSet.mockResolvedValue(undefined);
  adminActionsAdd.mockResolvedValue(undefined);
});

describe("isValidTenantId — M-12", () => {
  it("accepts alphanumeric + hyphen + underscore up to 64 chars", () => {
    expect(isValidTenantId("tenant-1")).toBe(true);
    expect(isValidTenantId("a_b_C-9")).toBe(true);
    expect(isValidTenantId("x".repeat(64))).toBe(true);
  });

  it("rejects path separators / dots / whitespace / overly long ids", () => {
    expect(isValidTenantId("a/b")).toBe(false);
    expect(isValidTenantId("a.b")).toBe(false);
    expect(isValidTenantId("a b")).toBe(false);
    expect(isValidTenantId("")).toBe(false);
    expect(isValidTenantId("x".repeat(65))).toBe(false);
  });
});

describe("adminSetTenantClaim — M-12 escalation hardening", () => {
  it("refuses callers without is_platform_admin", async () => {
    await expect(
      callable(
        {uid: "u1", tenant_id: "tenant-1"},
        {auth: {uid: "u1", token: {}}},
      ),
    ).rejects.toMatchObject({code: "permission-denied"});
    expect(setCustomUserClaims).not.toHaveBeenCalled();
  });

  it("refuses unauthenticated callers", async () => {
    await expect(
      callable({uid: "u1", tenant_id: "tenant-1"}, {}),
    ).rejects.toMatchObject({code: "unauthenticated"});
  });

  it("refuses missing uid / tenant_id", async () => {
    await expect(
      callable({uid: "", tenant_id: "t1"}, adminCtx),
    ).rejects.toMatchObject({code: "invalid-argument"});
    await expect(
      callable({uid: "u1", tenant_id: ""}, adminCtx),
    ).rejects.toMatchObject({code: "invalid-argument"});
  });

  it("refuses path-injection attempts in tenant_id", async () => {
    await expect(
      callable({uid: "u1", tenant_id: "a/b"}, adminCtx),
    ).rejects.toMatchObject({code: "invalid-argument"});
    expect(setCustomUserClaims).not.toHaveBeenCalled();
  });

  it("refuses reserved platform prefixes", async () => {
    for (const prefix of RESERVED_PREFIXES) {
      await expect(
        callable({uid: "u1", tenant_id: `${prefix}escalate`}, adminCtx),
      ).rejects.toMatchObject({code: "permission-denied"});
    }
    expect(setCustomUserClaims).not.toHaveBeenCalled();
  });

  it("writes both user mirror + admin_actions audit on success", async () => {
    const res = await callable(
      {uid: "u1", tenant_id: "tenant-new"},
      adminCtx,
    );
    expect(res).toEqual({ok: true, uid: "u1", tenant_id: "tenant-new"});
    expect(setCustomUserClaims).toHaveBeenCalledWith("u1", {
      tenant_id: "tenant-new",
    });
    expect(docSet).toHaveBeenCalledTimes(1);
    expect(adminActionsAdd).toHaveBeenCalledTimes(1);
    expect(adminActionsAdd.mock.calls[0][0]).toMatchObject({
      action: "tenant_reassign",
      target_uid: "u1",
      prev_tenant_id: "tenant-old",
      next_tenant_id: "tenant-new",
      actor_uid: "platform-admin-1",
    });
  });
});
