import {canScore, scoreScale, specForScale} from "../lib/mbc_scoring";

describe("scoreScale invariants", () => {
  test("PHQ-9 all zero → minimal + not alarmed", () => {
    const r = scoreScale("phq9", [0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(r.score).toBe(0);
    expect(r.severity).toBe("minimal");
    expect(r.alarmTriggered).toBe(false);
  });

  test("PHQ-9 score 10 (moderate) triggers alarm", () => {
    const r = scoreScale("phq9", [2, 2, 2, 2, 2, 0, 0, 0, 0]);
    expect(r.score).toBe(10);
    expect(r.severity).toBe("moderate");
    expect(r.alarmTriggered).toBe(true);
  });

  test("PHQ-9 score 27 max → severe", () => {
    const r = scoreScale("phq9", [3, 3, 3, 3, 3, 3, 3, 3, 3]);
    expect(r.score).toBe(27);
    expect(r.severity).toBe("severe");
  });

  test("GAD-7 score 15 → severe", () => {
    const r = scoreScale("gad7", [3, 3, 3, 3, 3, 0, 0]);
    expect(r.score).toBe(15);
    expect(r.severity).toBe("severe");
    expect(r.alarmTriggered).toBe(true);
  });

  test("WHO-5 raw 13 → score 52 → moderate, alarms at low wellbeing", () => {
    // raw sum 13 × 4 = 52 → moderate band 49..68; alarmAt=52 → score ≤ 52 alarms
    const r = scoreScale("who5", [3, 3, 3, 2, 2]);
    expect(r.score).toBe(52);
    expect(r.severity).toBe("moderate");
    expect(r.alarmTriggered).toBe(true);
  });

  test("WHO-5 max (25 × 4 = 100) → none + not alarmed", () => {
    const r = scoreScale("who5", [5, 5, 5, 5, 5]);
    expect(r.score).toBe(100);
    expect(r.severity).toBe("none");
    expect(r.alarmTriggered).toBe(false);
  });

  test("PCL-5 score 33 → moderate + alarmed", () => {
    const r = scoreScale("pcl5", [
      2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0, 0, 0,
    ]);
    expect(r.score).toBe(33);
    expect(r.severity).toBe("moderate");
    expect(r.alarmTriggered).toBe(true);
  });

  test("AUDIT score 16 → moderate + alarmed", () => {
    const r = scoreScale("audit", [4, 4, 4, 4, 0, 0, 0, 0, 0, 0]);
    expect(r.score).toBe(16);
    expect(r.severity).toBe("moderate");
    expect(r.alarmTriggered).toBe(true);
  });

  test("rejects wrong item count", () => {
    expect(() => scoreScale("phq9", [0, 0, 0])).toThrow();
  });

  test("rejects out-of-range item value", () => {
    expect(() => scoreScale("phq9", [4, 0, 0, 0, 0, 0, 0, 0, 0])).toThrow();
    expect(() =>
      scoreScale("phq9", [-1, 0, 0, 0, 0, 0, 0, 0, 0]),
    ).toThrow();
  });

  test("rejects non-integer", () => {
    expect(() =>
      scoreScale("phq9", [0.5, 0, 0, 0, 0, 0, 0, 0, 0]),
    ).toThrow();
  });
});

describe("specForScale", () => {
  test("returns spec for known", () => {
    expect(specForScale("phq9").itemCount).toBe(9);
    expect(specForScale("gad7").itemCount).toBe(7);
    expect(specForScale("pcl5").itemCount).toBe(20);
  });

  test("throws on unknown", () => {
    expect(() => specForScale("nope")).toThrow();
  });
});

describe("canScore", () => {
  test("true for catalog scales", () => {
    expect(canScore("phq9")).toBe(true);
    expect(canScore("gad7")).toBe(true);
  });

  test("false for unknown scale", () => {
    expect(canScore("nope")).toBe(false);
  });
});
