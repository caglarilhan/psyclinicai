jest.mock("firebase-admin", () => ({
  firestore: {
    Timestamp: { fromDate: (d: Date) => ({ __ts: d.toISOString() }) },
    FieldValue: { serverTimestamp: () => "__SERVER_TS__" },
  },
}));
jest.mock("stripe", () => {
  return jest.fn().mockImplementation(() => ({
    paymentIntents: {
      create: jest.fn(),
      capture: jest.fn(),
    },
  }));
});

import {
  validateDepositAmount,
  canCaptureDeposit,
  minDepositCentsByCurrency,
} from "../deposit_handler";

describe("validateDepositAmount", () => {
  it("accepts a typical EUR deposit", () => {
    expect(validateDepositAmount(2500, "EUR")).toBe("");
  });

  it("rejects amounts below the per-currency minimum", () => {
    const min = minDepositCentsByCurrency.EUR;
    expect(validateDepositAmount(min - 1, "EUR")).toMatch(/minimum/);
  });

  it("rejects an unsupported currency", () => {
    expect(validateDepositAmount(1000, "XXX")).toMatch(/Unsupported/);
  });

  it("rejects zero or negative amounts", () => {
    expect(validateDepositAmount(0, "EUR")).toMatch(/positive/);
    expect(validateDepositAmount(-1, "EUR")).toMatch(/positive/);
  });

  it("rejects non-integer amounts", () => {
    expect(validateDepositAmount(99.5, "EUR")).toMatch(/integer/);
  });

  it("rejects amounts above the 1000-unit ceiling", () => {
    expect(validateDepositAmount(100_001, "EUR")).toMatch(/ceiling/);
  });
});

describe("canCaptureDeposit", () => {
  const scheduled = new Date(Date.UTC(2026, 5, 2, 14));

  it("is OK once the policy window has closed", () => {
    const after = new Date(scheduled.getTime() + 25 * 60 * 60 * 1000);
    expect(
      canCaptureDeposit({ status: "held", scheduledFor: scheduled }, after)
        .ok
    ).toBe(true);
  });

  it("refuses to capture before the window closes", () => {
    const tooSoon = new Date(scheduled.getTime() + 1 * 60 * 60 * 1000);
    const r = canCaptureDeposit(
      { status: "held", scheduledFor: scheduled },
      tooSoon
    );
    expect(r.ok).toBe(false);
    expect(r.reason).toMatch(/window/);
  });

  it("refuses to capture a deposit that is not held", () => {
    const after = new Date(scheduled.getTime() + 25 * 60 * 60 * 1000);
    const r = canCaptureDeposit(
      { status: "pending", scheduledFor: scheduled },
      after
    );
    expect(r.ok).toBe(false);
    expect(r.reason).toMatch(/held/);
  });
});
