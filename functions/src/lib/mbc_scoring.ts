/**
 * MBC server-side scoring (PILAR 2 / PR-2).
 *
 * Mirrors the validated scoring algorithms in
 * `lib/services/assessments/clinical_scales.dart`. Kept in TS so the
 * public submit endpoint can score without going through the Flutter
 * scoring helpers (which would re-introduce a client-trust chain).
 *
 * Severity bands intentionally line up with
 * `lib/services/assessments/outcome_measure_catalog.dart`.
 */

import {mbcRuleByScaleId} from "./mbc_dispatch_catalog";

export type Severity =
  | "none"
  | "minimal"
  | "mild"
  | "moderate"
  | "moderatelySevere"
  | "severe";

export interface ScaleScore {
  score: number;
  maxScore: number;
  severity: Severity;
  alarmTriggered: boolean;
  clinicianAction: string;
}

interface Band {
  severity: Severity;
  minScore: number;
  maxScore: number;
  action: string;
}

interface ScaleSpec {
  itemCount: number;
  itemMin: number;
  itemMax: number;
  /** When set, the raw sum is multiplied by this (WHO-5 ×4). */
  rawMultiplier: number;
  maxScore: number;
  alarmAt: number;
  bands: Band[];
}

const PHQ9: ScaleSpec = {
  itemCount: 9,
  itemMin: 0,
  itemMax: 3,
  rawMultiplier: 1,
  maxScore: 27,
  alarmAt: 10,
  bands: [
    {severity: "minimal", minScore: 0, maxScore: 4,
      action: "No action required; re-screen at next visit."},
    {severity: "mild", minScore: 5, maxScore: 9,
      action: "Watchful waiting; repeat in 2-4 weeks."},
    {severity: "moderate", minScore: 10, maxScore: 14,
      action: "Treatment plan; counselling / pharmacotherapy decision."},
    {severity: "moderatelySevere", minScore: 15, maxScore: 19,
      action: "Active treatment; pharmacotherapy + therapy."},
    {severity: "severe", minScore: 20, maxScore: 27,
      action:
          "Immediate treatment; expedited referral if symptoms acute."},
  ],
};

const GAD7: ScaleSpec = {
  itemCount: 7,
  itemMin: 0,
  itemMax: 3,
  rawMultiplier: 1,
  maxScore: 21,
  alarmAt: 10,
  bands: [
    {severity: "minimal", minScore: 0, maxScore: 4,
      action: "No action required; re-screen at next visit."},
    {severity: "mild", minScore: 5, maxScore: 9,
      action: "Watchful waiting; repeat in 2-4 weeks."},
    {severity: "moderate", minScore: 10, maxScore: 14,
      action: "Active treatment decision; counselling first-line."},
    {severity: "severe", minScore: 15, maxScore: 21,
      action:
          "Active treatment; consider pharmacotherapy alongside therapy."},
  ],
};

const WHO5: ScaleSpec = {
  itemCount: 5,
  itemMin: 0,
  itemMax: 5,
  rawMultiplier: 4,
  maxScore: 100,
  alarmAt: 52, // WHO-5 alarms below threshold (low wellbeing)
  bands: [
    {severity: "severe", minScore: 0, maxScore: 48,
      action: "Likely depression; administer PHQ-9 + clinical review."},
    {severity: "moderate", minScore: 49, maxScore: 68,
      action: "Reduced wellbeing; explore + re-screen in 2 weeks."},
    {severity: "none", minScore: 69, maxScore: 100,
      action: "Good wellbeing; no further action."},
  ],
};

const AUDIT: ScaleSpec = {
  itemCount: 10,
  itemMin: 0,
  itemMax: 4,
  rawMultiplier: 1,
  maxScore: 40,
  alarmAt: 16,
  bands: [
    {severity: "minimal", minScore: 0, maxScore: 7,
      action: "No action; education leaflet at discharge."},
    {severity: "mild", minScore: 8, maxScore: 15,
      action: "Brief intervention; re-screen in 12 weeks."},
    {severity: "moderate", minScore: 16, maxScore: 19,
      action: "Counselling + monitoring; consider specialist referral."},
    {severity: "severe", minScore: 20, maxScore: 40,
      action: "Specialist referral for alcohol-use treatment."},
  ],
};

const PCL5: ScaleSpec = {
  itemCount: 20,
  itemMin: 0,
  itemMax: 4,
  rawMultiplier: 1,
  maxScore: 80,
  alarmAt: 33,
  bands: [
    {severity: "minimal", minScore: 0, maxScore: 32,
      action: "No PTSD diagnosis indicated; re-screen as needed."},
    {severity: "moderate", minScore: 33, maxScore: 50,
      action: "Probable PTSD; administer structured clinical interview."},
    {severity: "severe", minScore: 51, maxScore: 80,
      action:
          "High symptom burden; expedited PTSD-specialist consult."},
  ],
};

const SPECS: Record<string, ScaleSpec> = {
  phq9: PHQ9,
  gad7: GAD7,
  who5: WHO5,
  audit: AUDIT,
  pcl5: PCL5,
};

export function specForScale(scaleId: string): ScaleSpec {
  const spec = SPECS[scaleId];
  if (!spec) throw new Error(`No scoring spec for scaleId=${scaleId}`);
  return spec;
}

/** Pure scoring. Validates item count + range; throws on bad input. */
export function scoreScale(scaleId: string, answers: number[]): ScaleScore {
  const spec = specForScale(scaleId);
  if (answers.length !== spec.itemCount) {
    throw new Error(
      `Wrong item count for ${scaleId}: ` +
        `expected ${spec.itemCount}, got ${answers.length}`,
    );
  }
  for (const a of answers) {
    if (!Number.isInteger(a) || a < spec.itemMin || a > spec.itemMax) {
      throw new Error(
        `Bad item value ${a} for ${scaleId}: ` +
          `expected integer in [${spec.itemMin}, ${spec.itemMax}]`,
      );
    }
  }
  const raw = answers.reduce((a, b) => a + b, 0);
  const score = raw * spec.rawMultiplier;
  const band =
    spec.bands.find((b) => score >= b.minScore && score <= b.maxScore) ??
    spec.bands[spec.bands.length - 1];

  // WHO-5 alarms when score is LOW (wellbeing), all others when HIGH.
  const alarmTriggered = scaleId === "who5" ?
    score <= spec.alarmAt :
    score >= spec.alarmAt;

  return {
    score,
    maxScore: spec.maxScore,
    severity: band.severity,
    alarmTriggered,
    clinicianAction: band.action,
  };
}

/** True when the scale id is one we know how to dispatch + score. */
export function canScore(scaleId: string): boolean {
  if (!(scaleId in SPECS)) return false;
  try {
    mbcRuleByScaleId(scaleId);
    return true;
  } catch {
    return false;
  }
}
