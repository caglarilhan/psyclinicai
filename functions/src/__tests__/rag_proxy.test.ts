jest.mock("firebase-admin", () => ({
  firestore: () => ({collection: () => ({add: jest.fn()})}),
  auth: () => ({verifyIdToken: jest.fn()}),
}));
jest.mock("firebase-functions", () => ({
  logger: {warn: jest.fn(), error: jest.fn(), info: jest.fn()},
  https: {onRequest: (fn: unknown) => fn},
}));

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
