/**
 * Pure-helper tests for B10 audit retention.
 *
 * `firebase-admin` is mocked so we can call `pseudonymisePayload()`
 * without booting the SDK — the only admin reference is the
 * `FieldValue.serverTimestamp()` sentinel.
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
  sixYearsBefore,
  pseudonymisePayload,
  isExpired,
} from "../audit_retention_purge";

describe("sixYearsBefore", () => {
  it("subtracts six calendar years (leap-year safe)", () => {
    const now = new Date(Date.UTC(2026, 5, 2, 12, 0, 0));
    const cutoff = sixYearsBefore(now);
    expect(cutoff.getUTCFullYear()).toBe(2020);
    expect(cutoff.getUTCMonth()).toBe(5);
    expect(cutoff.getUTCDate()).toBe(2);
  });

  it("does not mutate the input", () => {
    const now = new Date(Date.UTC(2026, 5, 2));
    const before = now.getTime();
    sixYearsBefore(now);
    expect(now.getTime()).toBe(before);
  });
});

describe("isExpired", () => {
  const now = new Date(Date.UTC(2026, 5, 2));

  it("returns true for rows older than six years", () => {
    const created = new Date(Date.UTC(2020, 5, 1));
    expect(isExpired(created, now)).toBe(true);
  });

  it("returns false at the exact six-year boundary", () => {
    const created = new Date(Date.UTC(2020, 5, 2));
    expect(isExpired(created, now)).toBe(false);
  });

  it("returns false for fresh rows", () => {
    const created = new Date(Date.UTC(2026, 4, 30));
    expect(isExpired(created, now)).toBe(false);
  });
});

describe("pseudonymisePayload", () => {
  it("blanks PHI fields and marks the row purged", () => {
    const p = pseudonymisePayload();
    expect(p.actor).toBeNull();
    expect(p.entity).toBe("__purged__");
    expect(p.ip).toBeNull();
    expect(p.device).toBeNull();
    expect(p.purged).toBe(true);
    expect(p.purged_at).toBe("__SERVER_TS__");
  });

  it("does NOT include id, kind, timestamp_utc, hash, or user_id", () => {
    // Hash-chain verification depends on these staying intact on the
    // original document; the merge payload must leave them alone.
    const p = pseudonymisePayload();
    expect(p).not.toHaveProperty("id");
    expect(p).not.toHaveProperty("kind");
    expect(p).not.toHaveProperty("timestamp_utc");
    expect(p).not.toHaveProperty("hash");
    expect(p).not.toHaveProperty("user_id");
  });
});
