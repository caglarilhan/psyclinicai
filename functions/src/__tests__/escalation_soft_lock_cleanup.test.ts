jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: {
      serverTimestamp: () => "__SERVER_TS__",
    },
    Timestamp: {
      fromDate: (d: Date) => ({ __ts: d.toISOString() }),
    },
  },
}));

import { shouldMarkStale } from "../escalation_soft_lock_cleanup";

const now = new Date(Date.UTC(2026, 5, 2, 12));

describe("shouldMarkStale", () => {
  it("flips to true once followUpDueAt has passed", () => {
    expect(
      shouldMarkStale(
        {
          followUpDueAt: new Date(Date.UTC(2026, 5, 1)),
          stale: false,
        },
        now
      )
    ).toBe(true);
  });

  it("stays false before the follow-up window closes", () => {
    expect(
      shouldMarkStale(
        {
          followUpDueAt: new Date(Date.UTC(2026, 5, 3)),
          stale: false,
        },
        now
      )
    ).toBe(false);
  });

  it("never re-stales an already-stale row", () => {
    expect(
      shouldMarkStale(
        {
          followUpDueAt: new Date(Date.UTC(2026, 5, 1)),
          stale: true,
        },
        now
      )
    ).toBe(false);
  });

  it("respects a supervisor handoff — handoff means follow-up happened",
      () => {
    expect(
      shouldMarkStale(
        {
          followUpDueAt: new Date(Date.UTC(2026, 5, 1)),
          stale: false,
          supervisorHandoffId: "rev-42",
        },
        now
      )
    ).toBe(false);
  });
});
