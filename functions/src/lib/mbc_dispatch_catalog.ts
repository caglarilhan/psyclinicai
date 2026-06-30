/**
 * MBC1 — Measurement-Based Care dispatch catalog (TS mirror of
 * `lib/services/mbc/mbc_dispatch_catalog.dart`).
 *
 * Drift between this file and the Dart side is enforced by
 * `test/mbc_dispatch_catalog_parity_test.dart`. Add a field on one
 * side without the other and the parity test fails in CI.
 *
 * See the Dart doc-comment for the regulatory framing + scope notes.
 */

export type DispatchChannel = "email" | "sms" | "portal";

export type DispatchAudience =
  | "patientAdult"
  | "patientAdolescent"
  | "caregiver";

export interface MbcDispatchRule {
  readonly scaleId: string;
  readonly fullName: string;
  readonly intervalDays: number;
  readonly linkLifetimeHours: number;
  readonly reminderAtHours: number;
  readonly audiences: ReadonlyArray<DispatchAudience>;
  readonly channels: ReadonlyArray<DispatchChannel>;
  readonly publicSubmit: boolean;
  readonly maxItemsPerSession: number;
  readonly payerCadenceLabel: string;
  readonly regulatoryRefs: ReadonlyArray<string>;
}

export const MBC_SCHEMA_VERSION = 1 as const;
export const MBC_LAST_REVIEWED = "2026-06" as const;

export const MBC_DISPATCH_RULES: ReadonlyArray<MbcDispatchRule> = [
  {
    scaleId: "phq9",
    fullName: "Patient Health Questionnaire-9 (PHQ-9)",
    intervalDays: 14,
    linkLifetimeHours: 72,
    reminderAtHours: 48,
    audiences: ["patientAdult"],
    channels: ["email", "sms"],
    publicSubmit: true,
    maxItemsPerSession: 9,
    payerCadenceLabel: "every 2 weeks",
    regulatoryRefs: [
      "NICE CG90 depression in adults",
      "CMS MIPS #134",
      "Joint Commission NPSG 15.01.01 (item 9)",
    ],
  },
  {
    scaleId: "gad7",
    fullName: "Generalised Anxiety Disorder-7 (GAD-7)",
    intervalDays: 14,
    linkLifetimeHours: 72,
    reminderAtHours: 48,
    audiences: ["patientAdult"],
    channels: ["email", "sms"],
    publicSubmit: true,
    maxItemsPerSession: 7,
    payerCadenceLabel: "every 2 weeks",
    regulatoryRefs: [
      "NICE CG113 generalised anxiety disorder",
      "CMS MIPS #134",
    ],
  },
  {
    scaleId: "who5",
    fullName: "WHO-5 Wellbeing Index",
    intervalDays: 28,
    linkLifetimeHours: 96,
    reminderAtHours: 72,
    audiences: ["patientAdult"],
    channels: ["email", "portal"],
    publicSubmit: true,
    maxItemsPerSession: 5,
    payerCadenceLabel: "monthly",
    regulatoryRefs: ["Topp et al. (2015) WHO-5 systematic review"],
  },
  {
    scaleId: "audit",
    fullName: "AUDIT — Alcohol Use Disorders Identification Test",
    intervalDays: 84,
    linkLifetimeHours: 96,
    reminderAtHours: 72,
    audiences: ["patientAdult"],
    channels: ["email"],
    publicSubmit: true,
    maxItemsPerSession: 10,
    payerCadenceLabel: "quarterly",
    regulatoryRefs: ["NICE CG115 alcohol-use disorders"],
  },
  {
    scaleId: "pcl5",
    fullName: "PCL-5 — PTSD Checklist for DSM-5",
    intervalDays: 28,
    linkLifetimeHours: 96,
    reminderAtHours: 72,
    audiences: ["patientAdult"],
    channels: ["email", "portal"],
    publicSubmit: true,
    maxItemsPerSession: 10,
    payerCadenceLabel: "monthly",
    regulatoryRefs: ["NICE NG116 post-traumatic stress disorder"],
  },
] as const;

export function mbcRuleByScaleId(scaleId: string): MbcDispatchRule {
  for (const r of MBC_DISPATCH_RULES) {
    if (r.scaleId === scaleId) return r;
  }
  throw new Error(`No MBC dispatch rule for scaleId=${scaleId}`);
}

export function isDueForDispatch(params: {
  rule: MbcDispatchRule;
  lastDispatchedAtMillis: number | null;
  nowMillis: number;
}): boolean {
  const {rule, lastDispatchedAtMillis, nowMillis} = params;
  if (lastDispatchedAtMillis === null) return true;
  const dueMillis =
    lastDispatchedAtMillis + rule.intervalDays * 24 * 3_600_000;
  return nowMillis >= dueMillis;
}

export function tokenExpiryMillis(params: {
  rule: MbcDispatchRule;
  dispatchedAtMillis: number;
}): number {
  return params.dispatchedAtMillis + params.rule.linkLifetimeHours * 3_600_000;
}
