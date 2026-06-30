import {
  MBC_DISPATCH_RULES,
  MBC_LAST_REVIEWED,
  MBC_SCHEMA_VERSION,
  isDueForDispatch,
  mbcRuleByScaleId,
  tokenExpiryMillis,
} from "../lib/mbc_dispatch_catalog";

describe("MBC dispatch catalog invariants", () => {
  test("catalog is non-empty", () => {
    expect(MBC_DISPATCH_RULES.length).toBeGreaterThan(0);
  });

  test("every rule has reminderAtHours <= linkLifetimeHours", () => {
    for (const r of MBC_DISPATCH_RULES) {
      expect(r.reminderAtHours).toBeLessThanOrEqual(r.linkLifetimeHours);
    }
  });

  test("every rule has at least one audience + channel", () => {
    for (const r of MBC_DISPATCH_RULES) {
      expect(r.audiences.length).toBeGreaterThan(0);
      expect(r.channels.length).toBeGreaterThan(0);
    }
  });

  test("every rule has non-empty regulatory anchor", () => {
    for (const r of MBC_DISPATCH_RULES) {
      expect(r.regulatoryRefs.length).toBeGreaterThan(0);
    }
  });

  test("schemaVersion + lastReviewed shape", () => {
    expect(MBC_SCHEMA_VERSION).toBeGreaterThan(0);
    expect(MBC_LAST_REVIEWED).toMatch(/^\d{4}-\d{2}$/);
  });

  test("maxItemsPerSession positive", () => {
    for (const r of MBC_DISPATCH_RULES) {
      expect(r.maxItemsPerSession).toBeGreaterThan(0);
    }
  });

  test("scaleId set is unique", () => {
    const seen = new Set<string>();
    for (const r of MBC_DISPATCH_RULES) {
      expect(seen.has(r.scaleId)).toBe(false);
      seen.add(r.scaleId);
    }
  });
});

describe("mbcRuleByScaleId", () => {
  test("returns matching rule", () => {
    expect(mbcRuleByScaleId("phq9").scaleId).toBe("phq9");
  });

  test("throws on unknown id", () => {
    expect(() => mbcRuleByScaleId("nonsense")).toThrow();
  });
});

describe("isDueForDispatch", () => {
  const rule = mbcRuleByScaleId("phq9");
  // phq9 has intervalDays = 14
  const day = 24 * 3_600_000;

  test("first-time dispatch is always due", () => {
    expect(
      isDueForDispatch({
        rule,
        lastDispatchedAtMillis: null,
        nowMillis: 1_000_000_000,
      }),
    ).toBe(true);
  });

  test("inside interval is not due", () => {
    const last = 1_000_000_000;
    const now = last + 5 * day;
    expect(
      isDueForDispatch({
        rule,
        lastDispatchedAtMillis: last,
        nowMillis: now,
      }),
    ).toBe(false);
  });

  test("at interval boundary is due", () => {
    const last = 1_000_000_000;
    const now = last + 14 * day;
    expect(
      isDueForDispatch({
        rule,
        lastDispatchedAtMillis: last,
        nowMillis: now,
      }),
    ).toBe(true);
  });
});

describe("tokenExpiryMillis", () => {
  test("phq9 link expires linkLifetimeHours after dispatch", () => {
    const rule = mbcRuleByScaleId("phq9");
    const dispatched = 1_700_000_000_000;
    const expected = dispatched + rule.linkLifetimeHours * 3_600_000;
    expect(
      tokenExpiryMillis({rule, dispatchedAtMillis: dispatched}),
    ).toBe(expected);
  });
});
