jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: {
      serverTimestamp: () => "__SERVER_TS__",
      increment: (n: number) => ({__increment: n}),
    },
  },
}));
jest.mock("firebase-functions", () => ({
  logger: {warn: jest.fn(), error: jest.fn(), info: jest.fn()},
  https: {onRequest: (fn: unknown) => fn},
}));

import {
  hourBucket,
  reserveHourlyQuota,
  secondsToNextHour,
} from "../llm_proxy";

describe("hourBucket", () => {
  it("formats UTC YYYYMMDDHH", () => {
    expect(hourBucket(new Date(Date.UTC(2026, 5, 16, 12, 34, 56)))).toBe(
      "2026061612",
    );
    expect(hourBucket(new Date(Date.UTC(2026, 0, 1, 0, 0, 0)))).toBe(
      "2026010100",
    );
  });
});

describe("secondsToNextHour", () => {
  it("returns ~3599s at minute 0:01", () => {
    const d = new Date(Date.UTC(2026, 5, 16, 12, 0, 1));
    expect(secondsToNextHour(d)).toBe(3599);
  });

  it("returns 1s minimum when on the boundary", () => {
    const d = new Date(Date.UTC(2026, 5, 16, 12, 59, 59, 999));
    expect(secondsToNextHour(d)).toBeGreaterThanOrEqual(1);
    expect(secondsToNextHour(d)).toBeLessThanOrEqual(2);
  });
});

function makeFakeDb(initialCount: number, cap: number) {
  let count = initialCount;
  const merges: Array<Record<string, unknown>> = [];

  const docRef = {_path: "tenant_quota/tenantA_2026061612"};
  const tx = {
    get: async (_ref: unknown) => ({
      exists: count > 0,
      data: () => ({count}),
    }),
    set: (
      _ref: unknown,
      payload: Record<string, unknown>,
      _opts: unknown,
    ) => {
      merges.push(payload);
      const inc = (payload.count as {__increment?: number} | undefined)
        ?.__increment ?? 0;
      count += inc;
    },
  };
  return {
    db: {
      collection: () => ({doc: () => docRef}),
      runTransaction: <T,>(fn: (t: typeof tx) => Promise<T>) => fn(tx),
    } as unknown as Parameters<typeof reserveHourlyQuota>[0],
    snapshotCount: () => count,
    merges,
    cap,
  };
}

describe("reserveHourlyQuota (F-001 P0 #3 — 1k req/h hard cap)", () => {
  const NOW = new Date(Date.UTC(2026, 5, 16, 12, 30, 0));

  it("admits the request when under cap and increments the bucket", async () => {
    const f = makeFakeDb(/*count*/ 42, /*cap*/ 1000);
    const r = await reserveHourlyQuota(f.db, "tenantA", f.cap, NOW);
    expect(r.ok).toBe(true);
    expect(r.used).toBe(43);
    expect(r.cap).toBe(1000);
    expect(f.merges).toHaveLength(1);
    expect(f.merges[0].bucket).toBe("2026061612");
    expect(f.merges[0].tenant_id).toBe("tenantA");
  });

  it("refuses with retry-after and does NOT increment when at cap", async () => {
    const f = makeFakeDb(/*count*/ 1000, /*cap*/ 1000);
    const r = await reserveHourlyQuota(f.db, "tenantA", f.cap, NOW);
    expect(r.ok).toBe(false);
    expect(r.used).toBe(1000);
    expect(r.cap).toBe(1000);
    expect(r.retryAfter).toBeGreaterThan(0);
    expect(r.retryAfter).toBeLessThanOrEqual(3600);
    expect(f.merges).toHaveLength(0);
    expect(f.snapshotCount()).toBe(1000);
  });

  it("exhausting a small cap eventually returns ok:false", async () => {
    const f = makeFakeDb(0, 3);
    const r1 = await reserveHourlyQuota(f.db, "tenantA", 3, NOW);
    const r2 = await reserveHourlyQuota(f.db, "tenantA", 3, NOW);
    const r3 = await reserveHourlyQuota(f.db, "tenantA", 3, NOW);
    const r4 = await reserveHourlyQuota(f.db, "tenantA", 3, NOW);
    expect([r1.ok, r2.ok, r3.ok, r4.ok]).toEqual([true, true, true, false]);
    expect(r4.used).toBe(3);
    expect(r4.retryAfter).toBeGreaterThan(0);
  });
});
