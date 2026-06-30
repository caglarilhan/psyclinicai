/**
 * NS1 — No-show feature + recovery catalog (TS mirror of
 * `lib/services/noshow/noshow_feature_catalog.dart`).
 *
 * Drift between this file and the Dart side is enforced by
 * `test/noshow_feature_catalog_parity_test.dart`.
 */

export type NoShowRiskTier = "low" | "medium" | "high";

export type FeatureKind = "count" | "ratio" | "boolean" | "band";

export type PhiSensitivity = "none" | "low" | "high";

export interface NoShowFeatureSpec {
  readonly key: string;
  readonly label: string;
  readonly kind: FeatureKind;
  readonly phiSensitivity: PhiSensitivity;
  readonly rationale: string;
}

export interface NoShowRecoveryPlaybook {
  readonly tier: NoShowRiskTier;
  readonly confirmCadenceHours: ReadonlyArray<number>;
  readonly smsConfirmHours: number;
  readonly callConfirmHours: number;
  readonly depositRequired: boolean;
  readonly waitlistOfferOnCancel: boolean;
  readonly estUsdSavedPerSlot: number;
  readonly regulatoryRefs: ReadonlyArray<string>;
}

export const NOSHOW_SCHEMA_VERSION = 1 as const;
export const NOSHOW_LAST_REVIEWED = "2026-06" as const;

export const NOSHOW_FEATURES: ReadonlyArray<NoShowFeatureSpec> = [
  {
    key: "history_attended_count_90d",
    label: "Attended appointments in last 90 days",
    kind: "count",
    phiSensitivity: "none",
    rationale: "Strongest single predictor of show-up behaviour.",
  },
  {
    key: "history_noshow_count_90d",
    label: "No-shows in last 90 days",
    kind: "count",
    phiSensitivity: "none",
    rationale: "Direct base-rate signal.",
  },
  {
    key: "history_late_cancel_count_90d",
    label: "Late cancellations in last 90 days",
    kind: "count",
    phiSensitivity: "none",
    rationale:
      "Late cancels correlate with future no-shows even when " +
      "total attended count looks fine.",
  },
  {
    key: "days_since_last_session",
    label: "Days since the last attended session",
    kind: "count",
    phiSensitivity: "none",
    rationale: "Gap from last contact is a strong drop-off signal.",
  },
  {
    key: "is_first_session",
    label: "First-ever session with this clinician",
    kind: "boolean",
    phiSensitivity: "none",
    rationale:
      "First-session no-show rate is roughly 2x the established " +
      "patient rate per Mitchell et al. (2014).",
  },
  {
    key: "lead_time_days_band",
    label: "Days between booking and appointment",
    kind: "band",
    phiSensitivity: "none",
    rationale:
      "Longer lead times monotonically increase no-show probability.",
  },
  {
    key: "slot_hour_band",
    label: "Hour-of-day band (morning / midday / evening)",
    kind: "band",
    phiSensitivity: "none",
    rationale: "Evening slots show ~1.4x no-show vs midday in our data.",
  },
  {
    key: "weekday",
    label: "Day of week (Mon..Sun)",
    kind: "band",
    phiSensitivity: "none",
    rationale: "Monday + Friday slots skew higher.",
  },
  {
    key: "modality",
    label: "In-person vs telehealth",
    kind: "boolean",
    phiSensitivity: "none",
    rationale:
      "Telehealth slots no-show less in our cohort; controlled for " +
      "distance band.",
  },
  {
    key: "distance_band",
    label: "Approximate travel distance band",
    kind: "band",
    phiSensitivity: "low",
    rationale:
      "Coarse band only — never the raw address. Drops out when " +
      "modality == telehealth.",
  },
  {
    key: "has_active_safety_plan",
    label: "Patient has an active safety plan",
    kind: "boolean",
    phiSensitivity: "low",
    rationale:
      "Crisis-tier patients show up MORE reliably (the safety plan " +
      "itself is a retention intervention).",
  },
] as const;

export const NOSHOW_PLAYBOOKS: ReadonlyArray<NoShowRecoveryPlaybook> = [
  {
    tier: "low",
    confirmCadenceHours: [24],
    smsConfirmHours: 24,
    callConfirmHours: 0,
    depositRequired: false,
    waitlistOfferOnCancel: false,
    estUsdSavedPerSlot: 0,
    regulatoryRefs: ["Joint Commission scheduling efficiency"],
  },
  {
    tier: "medium",
    confirmCadenceHours: [48, 24, 4],
    smsConfirmHours: 24,
    callConfirmHours: 4,
    depositRequired: false,
    waitlistOfferOnCancel: true,
    estUsdSavedPerSlot: 60,
    regulatoryRefs: [
      "Joint Commission scheduling efficiency",
      "NIH PMC4574795 SMS reminders evidence",
    ],
  },
  {
    tier: "high",
    confirmCadenceHours: [72, 48, 24, 4, 1],
    smsConfirmHours: 24,
    callConfirmHours: 4,
    depositRequired: true,
    waitlistOfferOnCancel: true,
    estUsdSavedPerSlot: 120,
    regulatoryRefs: [
      "Joint Commission scheduling efficiency",
      "NIH PMC4574795 SMS reminders evidence",
    ],
  },
] as const;

export function noshowFeatureByKey(key: string): NoShowFeatureSpec {
  for (const f of NOSHOW_FEATURES) {
    if (f.key === key) return f;
  }
  throw new Error(`Unknown no-show feature key=${key}`);
}

export function playbookForTier(tier: NoShowRiskTier): NoShowRecoveryPlaybook {
  for (const p of NOSHOW_PLAYBOOKS) {
    if (p.tier === tier) return p;
  }
  throw new Error(`No playbook for tier ${tier} — catalog corrupt`);
}

export function tierForProbability(p: number): NoShowRiskTier {
  if (p < 0.15) return "low";
  if (p < 0.4) return "medium";
  return "high";
}
