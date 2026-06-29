/**
 * M-2 (audit 2026-06-21) — verify llmProxy enforces the consent gate
 * before any model invocation when the request body carries a
 * patientId. The gate is a thin wrapper over checkAiConsent; we mock
 * it to assert wiring + correct HTTP response.
 */
// Set env vars before any module import; llmProxy reads
// LLM_PROXY_HOURLY_QUOTA and friends lazily through the env proxy.
process.env.LLM_PROXY_HOURLY_QUOTA = "1000";
process.env.LLM_PROXY_MONTHLY_CEILING_USD = "250";
process.env.ANTHROPIC_PROXY_API_KEY = "test-key";

// Tiny Firestore stub — enough surface to satisfy quota reservation
// when consent is granted (the no-patient test exercises the
// downstream path). Returns ok for both transactions.
const noPatientFlowDb = () => ({
  collection: () => ({
    doc: () => ({_path: "x"}),
    add: jest.fn(async () => ({})),
  }),
  runTransaction: async (
    fn: (
      tx: {
        get: () => Promise<{exists: false; data: () => undefined}>;
        set: () => void;
      },
    ) => unknown,
  ) =>
    fn({
      get: async () => ({exists: false as const, data: () => undefined}),
      set: () => undefined,
    }),
});
jest.mock("firebase-admin", () => ({
  firestore: Object.assign(() => noPatientFlowDb(), {
    FieldValue: {
      serverTimestamp: () => "__SERVER_TS__",
      increment: (n: number) => ({__increment: n}),
    },
  }),
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

jest.mock("../lib/auth", () => ({
  applyCors: jest.fn(() => false),
  authorizeUid: jest.fn(async () => "clinic-1"),
}));

const checkAiConsentMock = jest.fn();
jest.mock("../lib/consent_gate", () => {
  const actual = jest.requireActual("../lib/consent_gate");
  return {
    ...actual,
    checkAiConsent: (...args: unknown[]) => checkAiConsentMock(...args),
  };
});

// Stub global fetch so the handler can't accidentally reach Anthropic
// when the gate test is mis-wired. If consent denial works, the gate
// returns 403 before fetch is ever called.
const fetchMock = jest.fn();
(global as unknown as {fetch: unknown}).fetch = fetchMock;

import {llmProxy} from "../llm_proxy";

interface FakeRes {
  statusCode: number;
  body: unknown;
  headers: Record<string, string>;
  status: (n: number) => FakeRes;
  json: (b: unknown) => FakeRes;
  set: (k: string, v: string) => FakeRes;
  setHeader: (k: string, v: string) => void;
}
function makeRes(): FakeRes {
  const res = {
    statusCode: 200,
    body: undefined as unknown,
    headers: {} as Record<string, string>,
  };
  const api: FakeRes = {
    get statusCode() {
      return res.statusCode;
    },
    set statusCode(n: number) {
      res.statusCode = n;
    },
    get body() {
      return res.body;
    },
    set body(b: unknown) {
      res.body = b;
    },
    get headers() {
      return res.headers;
    },
    set headers(h: Record<string, string>) {
      res.headers = h;
    },
    status(n: number) {
      res.statusCode = n;
      return api;
    },
    json(b: unknown) {
      res.body = b;
      return api;
    },
    set(k: string, v: string) {
      res.headers[k] = v;
      return api;
    },
    setHeader(k: string, v: string) {
      res.headers[k] = v;
    },
  };
  return api;
}

function call(body: unknown): Promise<FakeRes> {
  const req = {method: "POST", headers: {authorization: "Bearer x"}, body};
  const res = makeRes();
  return Promise.resolve(
    (llmProxy as unknown as (r: unknown, s: unknown) => Promise<void>)(
      req,
      res,
    ),
  ).then(() => res);
}

describe("llmProxy — M-2 consent gate", () => {
  beforeEach(() => {
    checkAiConsentMock.mockReset();
    fetchMock.mockReset();
  });

  it("403s with missing_consent when patient has no consent record", async () => {
    checkAiConsentMock.mockResolvedValueOnce({
      ok: false,
      reason: "missing_consent",
    });
    const res = await call({
      tenantId: "t1",
      model: "claude-haiku-4-5",
      prompt: "hi",
      patientId: "p-99",
    });
    expect(res.statusCode).toBe(403);
    expect(res.body).toEqual({
      error: "consent_required",
      reason: "missing_consent",
    });
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("403s with withdrawn when consent has been revoked", async () => {
    checkAiConsentMock.mockResolvedValueOnce({
      ok: false,
      reason: "withdrawn",
    });
    const res = await call({
      tenantId: "t1",
      model: "claude-haiku-4-5",
      prompt: "summarise the last session",
      patientId: "p-1",
    });
    expect(res.statusCode).toBe(403);
    expect((res.body as {reason: string}).reason).toBe("withdrawn");
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("skips the consent lookup when no patient is bound", async () => {
    // Body has no patientId at all — gate must not be invoked, and
    // the request flows past it. We stub fetch with a 502 so the
    // handler returns early without touching the real upstream;
    // we only assert the gate decision, not the model response.
    fetchMock.mockResolvedValueOnce({
      ok: false,
      status: 502,
      text: async () => "stub",
    });
    await call({
      tenantId: "t1",
      model: "claude-haiku-4-5",
      prompt: "draft a generic intake template",
    });
    expect(checkAiConsentMock).not.toHaveBeenCalled();
  });
});
