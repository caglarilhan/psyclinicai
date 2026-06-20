// Sprint 33 P2 — pure-logic tests for the return-URL guard.

jest.mock("firebase-admin", () => ({
  firestore: {FieldValue: {serverTimestamp: () => "__SERVER_TS__"}},
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
jest.mock("../lib/auth", () => ({applyCors: jest.fn(), authorizeUid: jest.fn()}));
jest.mock("../lib/stripe", () => ({
  stripeClient: () => ({
    billingPortal: {sessions: {create: jest.fn()}},
  }),
}));

import {isAllowedReturnUrl} from "../stripe_customer_portal";

describe("isAllowedReturnUrl", () => {
  it("accepts canonical hosting domain over HTTPS", () => {
    expect(
      isAllowedReturnUrl("https://psyclinicai.web.app/settings"),
    ).toBe(true);
    expect(isAllowedReturnUrl("https://psyclinicai.com/")).toBe(true);
    expect(isAllowedReturnUrl("https://www.psyclinicai.com/")).toBe(true);
  });

  it("accepts localhost (dev)", () => {
    expect(isAllowedReturnUrl("http://localhost:8080/settings")).toBe(true);
  });

  it("rejects empty / undefined", () => {
    expect(isAllowedReturnUrl(undefined)).toBe(false);
    expect(isAllowedReturnUrl("")).toBe(false);
  });

  it("rejects unrelated hosts", () => {
    expect(
      isAllowedReturnUrl("https://attacker.example/phish"),
    ).toBe(false);
    expect(
      isAllowedReturnUrl("https://psyclinicai.com.attacker.example/"),
    ).toBe(false);
  });

  it("rejects non-https (except localhost)", () => {
    expect(isAllowedReturnUrl("http://psyclinicai.com/")).toBe(false);
  });

  it("rejects malformed URLs", () => {
    expect(isAllowedReturnUrl("not a url")).toBe(false);
    expect(isAllowedReturnUrl("javascript:alert(1)")).toBe(false);
  });
});
