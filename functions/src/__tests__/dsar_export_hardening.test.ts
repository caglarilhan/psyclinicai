/**
 * Hardening surface for the DSAR endpoint:
 *   - 24h repeat-window detection (rate limit lookup),
 *   - 30-day SLA stamp shape (KVK Tebliğ md. 13 / GDPR Art. 12(3)).
 *
 * The HTTP handler itself stays out of scope (would need the Firebase
 * Functions emulator). These pure helpers cover the math + the
 * Firestore document-shape contract.
 */
jest.mock("firebase-admin", () => {
  const Timestamp = {
    now: () => ({
      toDate: () => new Date("2026-06-24T10:00:00Z"),
      __ts: "now",
    }),
    fromDate: (d: Date) => ({toDate: () => d, __ts: d.toISOString()}),
  };
  return {
    firestore: Object.assign(() => ({}), {Timestamp}),
  };
});

import {
  findRecentExportForTesting,
  setClockForTesting,
  slaExpiresAtForTesting,
} from "../dsar_export";

interface RateLimitDoc {
  last_export_at_utc?: {toDate: () => Date};
}

function makeDb(docs: Record<string, RateLimitDoc | undefined>) {
  return {
    collection: (col: string) => ({
      doc: (id: string) => ({
        get: async () => {
          const data = docs[`${col}/${id}`];
          return {
            exists: data !== undefined,
            data: () => data ?? {},
          };
        },
      }),
    }),
  } as unknown as import("firebase-admin").firestore.Firestore;
}

describe("DSAR SLA expiry stamp", () => {
  it("30-day SLA from 2026-06-24T10:00:00Z lands at 2026-07-24T10:00:00Z", () => {
    const now = new Date("2026-06-24T10:00:00Z");
    expect(slaExpiresAtForTesting(now)).toBe("2026-07-24T10:00:00.000Z");
  });

  it("SLA is exactly 30 * 24 * 60 * 60 * 1000 ms in the future", () => {
    const now = new Date("2026-01-01T00:00:00Z");
    const sla = new Date(slaExpiresAtForTesting(now));
    expect(sla.getTime() - now.getTime()).toBe(30 * 24 * 60 * 60 * 1000);
  });
});

describe("DSAR 24h repeat-window detection", () => {
  beforeEach(() => {
    setClockForTesting(() => new Date("2026-06-24T10:00:00Z"));
  });
  afterEach(() => {
    setClockForTesting(() => new Date());
  });

  it("returns null when no doc exists", async () => {
    const db = makeDb({});
    const recent = await findRecentExportForTesting(db, "u1", "p1");
    expect(recent).toBeNull();
  });

  it("returns null when the doc has no timestamp", async () => {
    const db = makeDb({"dsar_requests/u1_p1": {}});
    const recent = await findRecentExportForTesting(db, "u1", "p1");
    expect(recent).toBeNull();
  });

  it("returns the last-export Date when within 24h", async () => {
    const last = new Date("2026-06-24T01:00:00Z"); // 9h before "now"
    const db = makeDb({
      "dsar_requests/u1_p1": {
        last_export_at_utc: {toDate: () => last},
      },
    });
    const recent = await findRecentExportForTesting(db, "u1", "p1");
    expect(recent?.toISOString()).toBe(last.toISOString());
  });

  it("returns null when the last export is older than 24h", async () => {
    const last = new Date("2026-06-22T09:00:00Z"); // ~49h before "now"
    const db = makeDb({
      "dsar_requests/u1_p1": {
        last_export_at_utc: {toDate: () => last},
      },
    });
    const recent = await findRecentExportForTesting(db, "u1", "p1");
    expect(recent).toBeNull();
  });

  it("respects a custom window override (test seam)", async () => {
    const last = new Date("2026-06-24T08:00:00Z"); // 2h before "now"
    const db = makeDb({
      "dsar_requests/u1_p1": {
        last_export_at_utc: {toDate: () => last},
      },
    });
    // 1-hour window — 2h ago is OUTSIDE → null.
    const recent = await findRecentExportForTesting(
      db,
      "u1",
      "p1",
      60 * 60 * 1000,
    );
    expect(recent).toBeNull();
  });
});
