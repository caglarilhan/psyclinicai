/**
 * NS2 — No-show logistic model (PILAR 3 / PR-2).
 *
 * Pinned coefficients for a logistic regression sigmoid(b + Σ wᵢ·xᵢ).
 * Features keyed by `noshow_feature_catalog.NOSHOW_FEATURES.key`. A
 * retrain bumps `MODEL_VERSION` + audits the deployment alongside the
 * holdout AUC + Brier score recorded in the release notes.
 *
 * Why a hand-tuned baseline:
 *   * Ship a falsifiable v1 today so the recovery playbook (cadence,
 *     deposit, waitlist) can be wired against a real score before the
 *     first patient-event corpus is large enough to train on.
 *   * Coefficients fall in the direction the public no-show literature
 *     consistently reports — Mitchell et al. 2014, Norris et al. 2014.
 *
 * Re-train target: 4 weeks after the cron starts emitting outcome
 * rows. Until then this baseline carries the load.
 */
import {NOSHOW_FEATURES} from "./noshow_feature_catalog";

export const MODEL_VERSION = "v1-baseline-2026-06" as const;

const COEFFICIENTS: Readonly<Record<string, number>> = {
  history_attended_count_90d: -0.18,
  history_noshow_count_90d: 0.55,
  history_late_cancel_count_90d: 0.28,
  days_since_last_session: 0.012,
  is_first_session: 0.65,
  lead_time_days_band: 0.20,
  slot_hour_band: 0.10,
  weekday: 0.04,
  modality: -0.30,
  distance_band: 0.18,
  has_active_safety_plan: -0.40,
} as const;

const BIAS = -2.1;

export function sigmoid(z: number): number {
  if (z >= 0) return 1 / (1 + Math.exp(-z));
  const ez = Math.exp(z);
  return ez / (1 + ez);
}

/**
 * Encodes a categorical band as an ordinal in [0, N-1]. Pure for
 * unit tests so a re-train can pin the same encoding.
 */
export function bandValue(key: string, raw: unknown): number {
  switch (key) {
    case "lead_time_days_band":
      if (typeof raw !== "number") return 0;
      if (raw <= 7) return 0;
      if (raw <= 14) return 1;
      if (raw <= 30) return 2;
      if (raw <= 60) return 3;
      return 4;
    case "slot_hour_band":
      if (typeof raw !== "number") return 1;
      if (raw < 12) return 0;
      if (raw < 17) return 1;
      return 2;
    case "weekday":
      if (typeof raw !== "number") return 0;
      return Math.max(0, Math.min(6, raw - 1));
    case "distance_band":
      if (typeof raw !== "number") return 0;
      if (raw <= 5) return 0;
      if (raw <= 15) return 1;
      if (raw <= 30) return 2;
      return 3;
    default:
      return typeof raw === "number" ? raw : 0;
  }
}

export interface PredictInput {
  [featureKey: string]: number | boolean | undefined;
}

/**
 * Validates the feature vector against the catalog whitelist + returns
 * the no-show probability. Throws when an unknown feature key arrives
 * — the catalog is the gatekeeper, not the model.
 */
export function predictNoShowProbability(features: PredictInput): number {
  const allowed = new Set(NOSHOW_FEATURES.map((f) => f.key));
  let z = BIAS;
  for (const [key, value] of Object.entries(features)) {
    if (!allowed.has(key)) {
      throw new Error(
        `Unknown feature ${key} — not in NOSHOW_FEATURES whitelist`,
      );
    }
    const coef = COEFFICIENTS[key];
    if (coef === undefined) {
      throw new Error(`Feature ${key} has no coefficient`);
    }
    let x: number;
    if (typeof value === "boolean") {
      x = value ? 1 : 0;
    } else if (typeof value === "number") {
      const spec = NOSHOW_FEATURES.find((f) => f.key === key);
      x = spec?.kind === "band" ? bandValue(key, value) : value;
    } else {
      continue;
    }
    z += coef * x;
  }
  return sigmoid(z);
}

export function modelMetadata(): {
  version: string;
  featureCount: number;
} {
  return {version: MODEL_VERSION, featureCount: NOSHOW_FEATURES.length};
}
