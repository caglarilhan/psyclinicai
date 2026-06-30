import {
  NOSHOW_FEATURES,
  NOSHOW_LAST_REVIEWED,
  NOSHOW_PLAYBOOKS,
  NOSHOW_SCHEMA_VERSION,
  noshowFeatureByKey,
  playbookForTier,
  tierForProbability,
} from "../lib/noshow_feature_catalog";

describe("noshow catalog invariants", () => {
  test("features non-empty + unique keys", () => {
    expect(NOSHOW_FEATURES.length).toBeGreaterThan(0);
    const seen = new Set<string>();
    for (const f of NOSHOW_FEATURES) {
      expect(seen.has(f.key)).toBe(false);
      seen.add(f.key);
    }
  });

  test("no feature has high PHI sensitivity", () => {
    for (const f of NOSHOW_FEATURES) {
      expect(f.phiSensitivity).not.toBe("high");
    }
  });

  test("playbooks cover all three tiers", () => {
    const tiers = NOSHOW_PLAYBOOKS.map((p) => p.tier).sort();
    expect(tiers).toEqual(["high", "low", "medium"]);
  });

  test("high tier requires deposit + waitlist offer", () => {
    const p = playbookForTier("high");
    expect(p.depositRequired).toBe(true);
    expect(p.waitlistOfferOnCancel).toBe(true);
  });

  test("low tier never spams (single 24h reminder, no deposit)", () => {
    const p = playbookForTier("low");
    expect(p.depositRequired).toBe(false);
    expect(p.confirmCadenceHours.length).toBe(1);
  });

  test("confirmCadenceHours sorted DESCENDING (earliest reminder first)",
    () => {
      for (const p of NOSHOW_PLAYBOOKS) {
        const sorted = [...p.confirmCadenceHours].sort((a, b) => b - a);
        expect(p.confirmCadenceHours).toEqual(sorted);
      }
    });

  test("schemaVersion + lastReviewed shape", () => {
    expect(NOSHOW_SCHEMA_VERSION).toBeGreaterThan(0);
    expect(NOSHOW_LAST_REVIEWED).toMatch(/^\d{4}-\d{2}$/);
  });
});

describe("noshowFeatureByKey", () => {
  test("returns matching", () => {
    expect(noshowFeatureByKey("history_attended_count_90d").kind).toBe(
      "count",
    );
  });

  test("throws on unknown", () => {
    expect(() => noshowFeatureByKey("nope")).toThrow();
  });
});

describe("tierForProbability", () => {
  test("low band", () => {
    expect(tierForProbability(0.0)).toBe("low");
    expect(tierForProbability(0.14)).toBe("low");
  });
  test("medium band", () => {
    expect(tierForProbability(0.15)).toBe("medium");
    expect(tierForProbability(0.39)).toBe("medium");
  });
  test("high band", () => {
    expect(tierForProbability(0.4)).toBe("high");
    expect(tierForProbability(1.0)).toBe("high");
  });
});
