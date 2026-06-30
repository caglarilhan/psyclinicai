import {
  MODEL_VERSION,
  bandValue,
  modelMetadata,
  predictNoShowProbability,
  sigmoid,
} from "../lib/noshow_model";

describe("sigmoid", () => {
  test("0 → 0.5", () => {
    expect(sigmoid(0)).toBeCloseTo(0.5, 6);
  });
  test("monotonic increasing", () => {
    expect(sigmoid(-2)).toBeLessThan(sigmoid(-1));
    expect(sigmoid(0)).toBeLessThan(sigmoid(1));
    expect(sigmoid(1)).toBeLessThan(sigmoid(2));
  });
  test("bounded [0,1]", () => {
    // Floats saturate at the extremes — sigmoid(100) === 1 by IEEE 754.
    expect(sigmoid(-100)).toBeGreaterThanOrEqual(0);
    expect(sigmoid(100)).toBeLessThanOrEqual(1);
    // Far from saturation, strict bounds hold.
    expect(sigmoid(-5)).toBeGreaterThan(0);
    expect(sigmoid(5)).toBeLessThan(1);
  });
  test("symmetric around 0", () => {
    expect(sigmoid(-3) + sigmoid(3)).toBeCloseTo(1, 6);
  });
});

describe("bandValue", () => {
  test("lead_time band buckets", () => {
    expect(bandValue("lead_time_days_band", 1)).toBe(0);
    expect(bandValue("lead_time_days_band", 7)).toBe(0);
    expect(bandValue("lead_time_days_band", 10)).toBe(1);
    expect(bandValue("lead_time_days_band", 60)).toBe(3);
    expect(bandValue("lead_time_days_band", 90)).toBe(4);
  });
  test("slot_hour_band buckets", () => {
    expect(bandValue("slot_hour_band", 9)).toBe(0);
    expect(bandValue("slot_hour_band", 13)).toBe(1);
    expect(bandValue("slot_hour_band", 19)).toBe(2);
  });
  test("weekday clamps to [0,6]", () => {
    expect(bandValue("weekday", 1)).toBe(0);
    expect(bandValue("weekday", 7)).toBe(6);
    expect(bandValue("weekday", 99)).toBe(6);
  });
  test("distance_band buckets", () => {
    expect(bandValue("distance_band", 3)).toBe(0);
    expect(bandValue("distance_band", 10)).toBe(1);
    expect(bandValue("distance_band", 25)).toBe(2);
    expect(bandValue("distance_band", 50)).toBe(3);
  });
});

describe("predictNoShowProbability", () => {
  test("baseline empty features → bias-only probability", () => {
    const p = predictNoShowProbability({});
    // bias = -2.1 → sigmoid(-2.1) ≈ 0.109
    expect(p).toBeGreaterThan(0.10);
    expect(p).toBeLessThan(0.13);
  });

  test("first-session + high no-show history → high probability", () => {
    const p = predictNoShowProbability({
      is_first_session: true,
      history_noshow_count_90d: 4,
      history_attended_count_90d: 0,
    });
    expect(p).toBeGreaterThan(0.5);
  });

  test("strong attended history + safety plan → low probability", () => {
    const p = predictNoShowProbability({
      history_attended_count_90d: 8,
      history_noshow_count_90d: 0,
      has_active_safety_plan: true,
    });
    expect(p).toBeLessThan(0.05);
  });

  test("telehealth lowers vs in-person, same patient", () => {
    const base = {
      is_first_session: true,
      history_noshow_count_90d: 1,
    };
    const inPerson = predictNoShowProbability({...base, modality: false});
    const telehealth = predictNoShowProbability({...base, modality: true});
    expect(telehealth).toBeLessThan(inPerson);
  });

  test("rejects unknown feature key", () => {
    expect(() =>
      predictNoShowProbability({foo_bar: 1 as never}),
    ).toThrow();
  });
});

describe("modelMetadata", () => {
  test("returns version + feature count", () => {
    const m = modelMetadata();
    expect(m.version).toBe(MODEL_VERSION);
    expect(m.featureCount).toBeGreaterThan(0);
  });
});
