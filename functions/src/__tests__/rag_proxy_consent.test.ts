/**
 * M-2 (audit 2026-06-21) — verify ragProxy enforces the consent gate
 * before forwarding the request to the upstream RAG hub. `health` is
 * exempt because it carries no PHI body; analyze/query/feedback MUST
 * 403 when the patient pointer has no consent record.
 */
process.env.RAG_HUB_URL = "https://example.invalid";
process.env.RAG_HUB_KEY = "test-key";
process.env.ALLOWED_ORIGINS = "https://app.test";

jest.mock("firebase-admin", () => ({
  firestore: Object.assign(() => ({collection: () => ({add: jest.fn()})}), {
    FieldValue: {
      serverTimestamp: () => "__SERVER_TS__",
    },
  }),
  auth: () => ({
    verifyIdToken: jest.fn(async () => ({
      uid: "clinic-1",
      tenantId: "tenant-1",
    })),
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
}));

const checkAiConsentMock = jest.fn();
jest.mock("../lib/consent_gate", () => {
  const actual = jest.requireActual("../lib/consent_gate");
  return {
    ...actual,
    checkAiConsent: (...args: unknown[]) => checkAiConsentMock(...args),
  };
});

const fetchMock = jest.fn();
(global as unknown as {fetch: unknown}).fetch = fetchMock;

import {ragProxy} from "../rag_proxy";

interface FakeRes {
  statusCode: number;
  body: unknown;
  headers: Record<string, string>;
  status: (n: number) => FakeRes;
  json: (b: unknown) => FakeRes;
  set: (k: string, v: string) => FakeRes;
  send: (b: unknown) => FakeRes;
}
function makeRes(): FakeRes {
  const state = {
    statusCode: 200,
    body: undefined as unknown,
    headers: {} as Record<string, string>,
  };
  const api: FakeRes = {
    get statusCode() {
      return state.statusCode;
    },
    set statusCode(n: number) {
      state.statusCode = n;
    },
    get body() {
      return state.body;
    },
    set body(b: unknown) {
      state.body = b;
    },
    get headers() {
      return state.headers;
    },
    set headers(h: Record<string, string>) {
      state.headers = h;
    },
    status(n: number) {
      state.statusCode = n;
      return api;
    },
    json(b: unknown) {
      state.body = b;
      return api;
    },
    set(k: string, v: string) {
      state.headers[k] = v;
      return api;
    },
    send(b: unknown) {
      state.body = b;
      return api;
    },
  };
  return api;
}

function call(path: string, method: string, body: unknown): Promise<FakeRes> {
  const req = {
    method,
    path,
    headers: {authorization: "Bearer x"},
    body,
  };
  const res = makeRes();
  return Promise.resolve(
    (ragProxy as unknown as (r: unknown, s: unknown) => Promise<void>)(
      req,
      res,
    ),
  ).then(() => res);
}

describe("ragProxy — M-2 consent gate", () => {
  beforeEach(() => {
    checkAiConsentMock.mockReset();
    fetchMock.mockReset();
  });

  it("403s on analyze when patient has no consent record", async () => {
    checkAiConsentMock.mockResolvedValueOnce({
      ok: false,
      reason: "missing_consent",
    });
    const res = await call("/analyze", "POST", {
      patientId: "p-99",
      query: "any",
    });
    expect(res.statusCode).toBe(403);
    expect(res.body).toEqual({
      error: "consent_required",
      reason: "missing_consent",
    });
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("403s on query when consent is withdrawn", async () => {
    checkAiConsentMock.mockResolvedValueOnce({
      ok: false,
      reason: "withdrawn",
    });
    const res = await call("/query", "POST", {patient_id: "p-1", q: "test"});
    expect(res.statusCode).toBe(403);
    expect((res.body as {reason: string}).reason).toBe("withdrawn");
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("exempts the health op from the consent gate", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      status: 200,
      text: async () => '{"status":"ok"}',
      headers: {get: () => "application/json"},
    });
    const res = await call("/health", "GET", undefined);
    expect(checkAiConsentMock).not.toHaveBeenCalled();
    expect(res.statusCode).toBe(200);
  });

  it("skips the gate when no patient is bound (non-PHI query)", async () => {
    fetchMock.mockResolvedValueOnce({
      ok: true,
      status: 200,
      text: async () => "{}",
      headers: {get: () => "application/json"},
    });
    await call("/query", "POST", {q: "generic-knowledge-base lookup"});
    expect(checkAiConsentMock).not.toHaveBeenCalled();
  });
});
