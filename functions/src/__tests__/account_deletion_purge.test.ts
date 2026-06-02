/**
 * Pure-helper tests for B18 account deletion.
 *
 * `firebase-admin` is mocked so we exercise the helpers in isolation.
 */
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

import {
  isReadyToPurge,
  purgeFanOut,
} from "../account_deletion_purge";

const baseRequest = (overrides: Partial<{
  requestedAt: Date;
  graceEndsAt: Date;
  cancelledAt: Date | null;
  completedAt: Date | null;
}> = {}) => ({
  requestedAt: new Date(Date.UTC(2026, 4, 1)),
  graceEndsAt: new Date(Date.UTC(2026, 5, 1)),
  cancelledAt: null as Date | null,
  completedAt: null as Date | null,
  ...overrides,
});

describe("isReadyToPurge", () => {
  it("is true once the grace window has passed", () => {
    expect(
      isReadyToPurge(baseRequest(), new Date(Date.UTC(2026, 5, 2)))
    ).toBe(true);
  });

  it("is false before the grace window closes", () => {
    expect(
      isReadyToPurge(baseRequest(), new Date(Date.UTC(2026, 4, 30)))
    ).toBe(false);
  });

  it("is true exactly at the grace boundary", () => {
    // The handler is hourly — boundary inclusion lets the next tick
    // pick the request up without an off-by-one delay.
    expect(
      isReadyToPurge(baseRequest(), new Date(Date.UTC(2026, 5, 1)))
    ).toBe(true);
  });

  it("is false when the request was cancelled", () => {
    expect(
      isReadyToPurge(
        baseRequest({ cancelledAt: new Date(Date.UTC(2026, 4, 15)) }),
        new Date(Date.UTC(2026, 5, 10))
      )
    ).toBe(false);
  });

  it("is false when the purge already completed", () => {
    expect(
      isReadyToPurge(
        baseRequest({ completedAt: new Date(Date.UTC(2026, 5, 2)) }),
        new Date(Date.UTC(2026, 5, 5))
      )
    ).toBe(false);
  });
});

describe("purgeFanOut payloads", () => {
  it("marks every collection as purged", () => {
    for (const c of Object.keys(purgeFanOut)) {
      expect(purgeFanOut[c].purged).toBe(true);
    }
  });

  it("intake payload nulls demographics and scrubs free-text", () => {
    const p = purgeFanOut.intakes;
    expect(p.full_name).toBeNull();
    expect(p.date_of_birth).toBeNull();
    expect(p.phone).toBeNull();
    expect(p.email).toBeNull();
    expect(p.presenting_concern).toBe("__purged__");
    expect(p.medical_history).toBe("__purged__");
    expect(p.allergies).toEqual([]);
    expect(p.current_medications).toEqual([]);
  });

  it("safety_plans payload blanks every Stanley-Brown section", () => {
    const p = purgeFanOut.safety_plans;
    expect(p.warning_signs).toEqual([]);
    expect(p.coping_strategies).toEqual([]);
    expect(p.support_contacts).toEqual([]);
    expect(p.professionals).toEqual([]);
    expect(p.crisis_lines).toEqual([]);
    expect(p.reasons_for_living).toEqual([]);
    expect(p.means_safety).toBe("");
  });

  it("session_notes payload empties markdown but keeps schema", () => {
    const p = purgeFanOut.session_notes;
    expect(p.markdown).toBe("__purged__");
    expect(p.sections).toEqual({});
  });
});
