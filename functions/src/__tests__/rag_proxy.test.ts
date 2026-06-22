jest.mock("firebase-admin", () => ({
  firestore: () => ({collection: () => ({add: jest.fn()})}),
  auth: () => ({verifyIdToken: jest.fn()}),
}));
// Sprint 31 — Sprint 29 D-10 wrapped the handler with
// `functions.runWith({...}).region("europe-west1").https.onRequest(fn)`.
// Extend the mock so the chain resolves down to the raw fn.
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

import {extractOp} from "../rag_proxy";

describe("extractOp — Sprint 27 F-003 allow-list", () => {
  it("accepts the four supported ops", () => {
    expect(extractOp("/analyze")).toBe("analyze");
    expect(extractOp("/query")).toBe("query");
    expect(extractOp("/feedback")).toBe("feedback");
    expect(extractOp("/health")).toBe("health");
  });

  it("strips path prefixes such as a Hosting rewrite", () => {
    expect(extractOp("/v1/rag/analyze")).toBe("analyze");
    expect(extractOp("/ragProxy/feedback")).toBe("feedback");
  });

  it("rejects unknown ops (no proxy passthrough leak)", () => {
    expect(extractOp("/admin")).toBeNull();
    expect(extractOp("/api/rag/internal")).toBeNull();
    expect(extractOp("/")).toBeNull();
    expect(extractOp("")).toBeNull();
  });

  it("is case-sensitive — the upstream API is case-sensitive too", () => {
    expect(extractOp("/Analyze")).toBeNull();
    expect(extractOp("/HEALTH")).toBeNull();
  });
});
