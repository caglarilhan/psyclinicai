// Sprint 33 P1 — pure-logic tests for decideAction. Firestore wiring
// stays out of unit scope (covered by the manual runbook replay).

jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: {serverTimestamp: () => "__SERVER_TS__"},
  },
}));
jest.mock("firebase-functions", () => {
  const noop = jest.fn();
  const schedChain = {timeZone: () => ({onRun: noop})};
  const pubsub = {schedule: () => schedChain};
  const region = () => ({pubsub, https: {onRequest: noop}});
  const runWith = () => ({region});
  return {
    logger: {warn: noop, error: noop, info: noop},
    pubsub,
    https: {onRequest: noop},
    region,
    runWith,
  };
});
jest.mock("../lib/auth", () => ({applyCors: jest.fn(), authorizeUid: jest.fn()}));

import {decideAction} from "../ehr_outbox_reconciler";

// Cast through `unknown` because the production type is the full
// admin.firestore.Timestamp; we only need `toMillis()` for decideAction.
function ts(ms: number): import("firebase-admin").firestore.Timestamp {
  return {
    toMillis: () => ms,
    seconds: Math.floor(ms / 1000),
    nanoseconds: 0,
  } as unknown as import("firebase-admin").firestore.Timestamp;
}

describe("decideAction (Sprint 33 P1)", () => {
  const nowMs = 1_788_000_000_000; // ~2026-08-10 UTC

  it("skip — row has status sent", () => {
    expect(
      decideAction({status: "sent", created_at: ts(nowMs - 1000)}, nowMs),
    ).toBe("skip");
  });

  it("skip — row has no created_at", () => {
    expect(
      decideAction({status: "failed", created_at: null}, nowMs),
    ).toBe("skip");
  });

  it("retry — failed row inside 24 h window", () => {
    const tenMinAgo = nowMs - 10 * 60 * 1000;
    expect(
      decideAction({status: "failed", created_at: ts(tenMinAgo)}, nowMs),
    ).toBe("retry");
  });

  it("retry — failed row exactly at 12 h", () => {
    const twelveH = nowMs - 12 * 60 * 60 * 1000;
    expect(
      decideAction({status: "failed", created_at: ts(twelveH)}, nowMs),
    ).toBe("retry");
  });

  it("permanently_fail — failed row past the 24 h window", () => {
    const oldMs = nowMs - 25 * 60 * 60 * 1000;
    expect(
      decideAction({status: "failed", created_at: ts(oldMs)}, nowMs),
    ).toBe("permanently_fail");
  });

  it("retry vs permanently_fail respects a custom 1 h window", () => {
    const fortyMin = nowMs - 40 * 60 * 1000;
    expect(
      decideAction(
        {status: "failed", created_at: ts(fortyMin)},
        nowMs,
        60 * 60 * 1000,
      ),
    ).toBe("retry");
    const ninetyMin = nowMs - 90 * 60 * 1000;
    expect(
      decideAction(
        {status: "failed", created_at: ts(ninetyMin)},
        nowMs,
        60 * 60 * 1000,
      ),
    ).toBe("permanently_fail");
  });

  it("skip — status field missing entirely", () => {
    expect(
      decideAction(
        {created_at: ts(nowMs - 1000)} as unknown as Record<string, unknown>,
        nowMs,
      ),
    ).toBe("skip");
  });
});
