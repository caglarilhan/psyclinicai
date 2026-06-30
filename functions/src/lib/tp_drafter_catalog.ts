/**
 * TPD1 — Treatment Plan Drafter catalog (TS mirror of
 * `lib/services/treatment_plan_drafter/tp_drafter_catalog.dart`).
 *
 * Drift between this file and the Dart side is enforced by
 * `test/tp_drafter_catalog_parity_test.dart`.
 */

export type TpDisorderId =
  | "majorDepressiveDisorder"
  | "generalisedAnxietyDisorder"
  | "panicDisorder"
  | "socialAnxietyDisorder"
  | "ptsd"
  | "ocd"
  | "borderlinePersonalityDisorder"
  | "bingEatingDisorder"
  | "alcoholUseDisorder"
  | "insomniaDisorder";

export type TpModality =
  | "cbt"
  | "dbt"
  | "emdr"
  | "act"
  | "ipt"
  | "mi"
  | "cbti";

export interface TpProtocolSpec {
  readonly disorder: TpDisorderId;
  readonly modality: TpModality;
  readonly label: string;
  readonly recommendedSessions: number;
  readonly outcomeInstrument: string;
  readonly guidelineAnchors: ReadonlyArray<string>;
  readonly requiresSupervisorCoSign: boolean;
}

export const TPD_SCHEMA_VERSION = 1 as const;
export const TPD_LAST_REVIEWED = "2026-06" as const;

export const TPD_PROTOCOLS: ReadonlyArray<TpProtocolSpec> = [
  {
    disorder: "majorDepressiveDisorder",
    modality: "cbt",
    label: "CBT for Major Depressive Disorder",
    recommendedSessions: 16,
    outcomeInstrument: "phq9",
    guidelineAnchors: [
      "NICE CG90 depression in adults",
      "APA Clinical Practice Guideline for the Treatment of Depression (2019)",
    ],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "majorDepressiveDisorder",
    modality: "ipt",
    label: "Interpersonal Therapy for Major Depressive Disorder",
    recommendedSessions: 16,
    outcomeInstrument: "phq9",
    guidelineAnchors: [
      "NICE CG90 depression in adults",
      "Markowitz & Weissman IPT manual (2012)",
    ],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "generalisedAnxietyDisorder",
    modality: "cbt",
    label: "CBT for Generalised Anxiety Disorder",
    recommendedSessions: 14,
    outcomeInstrument: "gad7",
    guidelineAnchors: [
      "NICE CG113 generalised anxiety disorder",
      "APA Clinical Practice Guideline for Anxiety Disorders (2024)",
    ],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "panicDisorder",
    modality: "cbt",
    label: "CBT for Panic Disorder (interoceptive exposure)",
    recommendedSessions: 12,
    outcomeInstrument: "gad7",
    guidelineAnchors: [
      "NICE CG113 generalised anxiety + panic",
      "APA Clinical Practice Guideline for Anxiety Disorders (2024)",
    ],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "socialAnxietyDisorder",
    modality: "cbt",
    label: "CBT for Social Anxiety Disorder",
    recommendedSessions: 14,
    outcomeInstrument: "gad7",
    guidelineAnchors: ["NICE CG159 social anxiety disorder"],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "ptsd",
    modality: "emdr",
    label: "EMDR for PTSD",
    recommendedSessions: 12,
    outcomeInstrument: "pcl5",
    guidelineAnchors: [
      "NICE NG116 post-traumatic stress disorder",
      "WHO mhGAP 2023 PTSD module",
    ],
    requiresSupervisorCoSign: true,
  },
  {
    disorder: "ptsd",
    modality: "cbt",
    label: "Trauma-Focused CBT for PTSD",
    recommendedSessions: 14,
    outcomeInstrument: "pcl5",
    guidelineAnchors: [
      "NICE NG116 post-traumatic stress disorder",
      "APA Clinical Practice Guideline for PTSD (2017)",
    ],
    requiresSupervisorCoSign: true,
  },
  {
    disorder: "ocd",
    modality: "cbt",
    label: "ERP-based CBT for OCD",
    recommendedSessions: 16,
    outcomeInstrument: "gad7",
    guidelineAnchors: [
      "NICE CG31 obsessive-compulsive disorder",
      "APA Clinical Practice Guideline for OCD (2013)",
    ],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "borderlinePersonalityDisorder",
    modality: "dbt",
    label: "DBT for Borderline Personality Disorder",
    recommendedSessions: 48,
    outcomeInstrument: "phq9",
    guidelineAnchors: [
      "NICE CG78 borderline personality disorder",
      "Linehan DBT Skills Training Manual (2nd ed.)",
    ],
    requiresSupervisorCoSign: true,
  },
  {
    disorder: "bingEatingDisorder",
    modality: "cbt",
    label: "CBT for Binge-Eating Disorder",
    recommendedSessions: 16,
    outcomeInstrument: "phq9",
    guidelineAnchors: ["NICE NG69 eating disorders"],
    requiresSupervisorCoSign: false,
  },
  {
    disorder: "alcoholUseDisorder",
    modality: "mi",
    label: "Motivational Interviewing for Alcohol Use Disorder",
    recommendedSessions: 8,
    outcomeInstrument: "audit",
    guidelineAnchors: [
      "NICE CG115 alcohol-use disorders",
      "SAMHSA TIP 35 enhancing motivation",
    ],
    requiresSupervisorCoSign: true,
  },
  {
    disorder: "insomniaDisorder",
    modality: "cbti",
    label: "CBT-I for Insomnia Disorder",
    recommendedSessions: 6,
    outcomeInstrument: "phq9",
    guidelineAnchors: ["AASM clinical practice guideline for CBT-I (2021)"],
    requiresSupervisorCoSign: false,
  },
] as const;

export const TPD_SMART_GOAL_FIELDS = [
  "goal_text",
  "specific",
  "measurable",
  "achievable",
  "relevant",
  "time_bound",
  "cited_guideline",
] as const;

export const TPD_OUTPUT_SECTIONS = [
  "presenting_problems",
  "smart_goals",
  "session_plan",
  "homework_templates",
  "outcome_reassessment",
  "risk_review_cadence",
] as const;

export function tpProtocolByKey(params: {
  disorder: TpDisorderId;
  modality: TpModality;
}): TpProtocolSpec {
  for (const p of TPD_PROTOCOLS) {
    if (p.disorder === params.disorder && p.modality === params.modality) {
      return p;
    }
  }
  throw new Error(
    `No drafter protocol for ${params.disorder} × ${params.modality}`,
  );
}

/**
 * JSON schema fragment the LLM must conform to for the full drafted
 * plan. Pure for unit tests — keys + required come straight from the
 * catalog so adding a field is one edit away.
 */
export function jsonSchemaForPlan(): Record<string, unknown> {
  const smartGoalItem = {
    type: "object",
    properties: Object.fromEntries(
      TPD_SMART_GOAL_FIELDS.map((k) => [k, {type: "string"}]),
    ),
    required: [...TPD_SMART_GOAL_FIELDS],
    additionalProperties: false,
  };
  const properties: Record<string, unknown> = {
    presenting_problems: {
      type: "array",
      items: {type: "string"},
    },
    smart_goals: {
      type: "array",
      items: smartGoalItem,
    },
    session_plan: {
      type: "array",
      items: {
        type: "object",
        properties: {
          session_index: {type: "integer", minimum: 1},
          focus: {type: "string"},
          interventions: {type: "array", items: {type: "string"}},
          homework: {type: "string"},
        },
        required: ["session_index", "focus", "interventions"],
        additionalProperties: false,
      },
    },
    homework_templates: {type: "array", items: {type: "string"}},
    outcome_reassessment: {
      type: "object",
      properties: {
        instrument: {type: "string"},
        cadence_label: {type: "string"},
      },
      required: ["instrument", "cadence_label"],
      additionalProperties: false,
    },
    risk_review_cadence: {type: "string"},
  };
  return {
    type: "object",
    properties,
    required: [...TPD_OUTPUT_SECTIONS],
    additionalProperties: false,
  };
}
