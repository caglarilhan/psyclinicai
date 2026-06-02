jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: { serverTimestamp: () => "__SERVER_TS__" },
    Timestamp: { fromDate: (d: Date) => ({ __ts: d.toISOString() }) },
  },
}));

import { isQuarterStart, nextQuarterStart } from "../access_review_cron";

describe("isQuarterStart", () => {
  it("returns true on Jan 1 / Apr 1 / Jul 1 / Oct 1", () => {
    for (const m of [0, 3, 6, 9]) {
      expect(isQuarterStart(new Date(Date.UTC(2026, m, 1)))).toBe(true);
    }
  });

  it("returns false on every other day", () => {
    expect(isQuarterStart(new Date(Date.UTC(2026, 0, 2)))).toBe(false);
    expect(isQuarterStart(new Date(Date.UTC(2026, 1, 1)))).toBe(false);
    expect(isQuarterStart(new Date(Date.UTC(2026, 5, 15)))).toBe(false);
  });
});

describe("nextQuarterStart", () => {
  it("rolls forward to the next quarter boundary", () => {
    expect(nextQuarterStart(new Date(Date.UTC(2026, 5, 5)))).toEqual(
      new Date(Date.UTC(2026, 6, 1))
    );
  });

  it("crosses the year boundary when needed", () => {
    expect(nextQuarterStart(new Date(Date.UTC(2026, 10, 15)))).toEqual(
      new Date(Date.UTC(2027, 0, 1))
    );
  });

  it("on a quarter boundary, returns the NEXT one, not the same day",
      () => {
    expect(nextQuarterStart(new Date(Date.UTC(2026, 6, 1)))).toEqual(
      new Date(Date.UTC(2026, 9, 1))
    );
  });
});
