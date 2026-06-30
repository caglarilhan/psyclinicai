/**
 * AS1 — SOAP section catalog (TS mirror of
 * `lib/services/ai_scribe/soap_section_catalog.dart`).
 *
 * Drift between this file and the Dart side is enforced by
 * `test/soap_section_parity_test.dart`. Add a field on one side
 * without the other and the parity test will fail in CI.
 *
 * See the Dart doc-comment for the regulatory framing + scope notes.
 */

export type SoapSection = "subjective" | "objective" | "assessment" | "plan";

export type SoapFieldKind =
  | "longText"
  | "bulletList"
  | "structuredList"
  | "codedTerm";

export interface SoapFieldSpec {
  readonly key: string;
  readonly label: string;
  readonly kind: SoapFieldKind;
  readonly required: boolean;
  readonly placeholder: string;
  readonly citationRequired: boolean;
}

export interface SoapSectionSpec {
  readonly section: SoapSection;
  readonly title: string;
  readonly purpose: string;
  readonly fields: ReadonlyArray<SoapFieldSpec>;
  readonly maxOutputTokens: number;
  readonly regulatoryRefs: ReadonlyArray<string>;
}

export const SOAP_SCHEMA_VERSION = 1 as const;
export const SOAP_LAST_REVIEWED = "2026-06" as const;

export const SOAP_SECTION_TEMPERATURE: Readonly<Record<SoapSection, number>> = {
  subjective: 0.2,
  objective: 0.1,
  assessment: 0.3,
  plan: 0.2,
} as const;

export const SOAP_SECTIONS: ReadonlyArray<SoapSectionSpec> = [
  {
    section: "subjective",
    title: "Subjective",
    purpose:
      "Patient-reported experience, mood, presenting concerns, " +
      "symptom timeline, life events since last session.",
    fields: [
      {
        key: "chief_complaint",
        label: "Chief complaint",
        kind: "longText",
        required: true,
        placeholder:
          "One sentence summarising the patient's focus today.",
        citationRequired: true,
      },
      {
        key: "history_present_illness",
        label: "History of present illness",
        kind: "longText",
        required: true,
        placeholder:
          "Timeline, frequency, intensity, triggers since last visit.",
        citationRequired: true,
      },
      {
        key: "patient_reported_symptoms",
        label: "Patient-reported symptoms",
        kind: "bulletList",
        required: true,
        placeholder: "Bullets of symptoms in the patient's own words.",
        citationRequired: true,
      },
      {
        key: "life_events",
        label: "Recent life events",
        kind: "bulletList",
        required: false,
        placeholder: "Stressors / supports since last session.",
        citationRequired: true,
      },
    ],
    maxOutputTokens: 600,
    regulatoryRefs: ["AAFP SOAP note guidance", "NIH NBK482263 SOAP structure"],
  },
  {
    section: "objective",
    title: "Objective",
    purpose:
      "Clinician-observed mental status exam, affect, behaviour, " +
      "observable measurements (outcome scale results, vitals if " +
      "collected, attendance / engagement metrics).",
    fields: [
      {
        key: "mental_status_exam",
        label: "Mental status exam",
        kind: "structuredList",
        required: true,
        placeholder:
          "Appearance, behaviour, speech, mood, affect, thought process, " +
          "thought content, perception, cognition, insight, judgement.",
        citationRequired: true,
      },
      {
        key: "outcome_measure_scores",
        label: "Outcome measure scores (today)",
        kind: "structuredList",
        required: false,
        placeholder:
          "PHQ-9, GAD-7, WHO-5, etc. — only what was administered.",
        citationRequired: false,
      },
      {
        key: "observable_behaviour",
        label: "Observable behaviour notes",
        kind: "bulletList",
        required: false,
        placeholder: "Engagement, eye contact, motor activity, etc.",
        citationRequired: true,
      },
    ],
    maxOutputTokens: 500,
    regulatoryRefs: [
      "NIH NBK482263 SOAP structure",
      "APA MSE documentation guidance",
    ],
  },
  {
    section: "assessment",
    title: "Assessment",
    purpose:
      "Clinical formulation. Working diagnoses (DSM-5-TR), " +
      "differential, risk assessment, progress vs treatment goals.",
    fields: [
      {
        key: "working_diagnoses",
        label: "Working diagnoses (DSM-5-TR)",
        kind: "codedTerm",
        required: true,
        placeholder:
          "List with DSM-5-TR code + plain-language label. Mark each " +
          "as confirmed / provisional / rule-out.",
        citationRequired: true,
      },
      {
        key: "differential_diagnoses",
        label: "Differential diagnoses",
        kind: "codedTerm",
        required: false,
        placeholder: "Conditions actively considered + ruled out.",
        citationRequired: true,
      },
      {
        key: "risk_assessment",
        label: "Risk assessment",
        kind: "structuredList",
        required: true,
        placeholder:
          "Suicide, self-harm, harm-to-others, neglect, substance — " +
          "one row each with risk level + rationale + plan reference.",
        citationRequired: true,
      },
      {
        key: "progress_vs_goals",
        label: "Progress vs treatment goals",
        kind: "bulletList",
        required: true,
        placeholder: "Movement on each active treatment-plan goal.",
        citationRequired: true,
      },
    ],
    maxOutputTokens: 700,
    regulatoryRefs: [
      "DSM-5-TR diagnostic criteria",
      "Joint Commission NPSG 15.01.01 (suicide risk)",
      "FDA CDS non-device criterion §520(o)(1)(E)",
    ],
  },
  {
    section: "plan",
    title: "Plan",
    purpose:
      "Next steps: interventions delivered, homework assigned, " +
      "medication discussion (without prescribing), referrals, " +
      "next-session cadence, safety plan if elevated risk.",
    fields: [
      {
        key: "interventions_delivered",
        label: "Interventions delivered this session",
        kind: "bulletList",
        required: true,
        placeholder:
          "CBT thought record, behavioural activation, exposure plan, " +
          "DBT skills coaching, etc. — modality + technique.",
        citationRequired: true,
      },
      {
        key: "homework_assigned",
        label: "Homework / between-session work",
        kind: "bulletList",
        required: false,
        placeholder:
          "Specific tasks the patient agreed to do before next visit.",
        citationRequired: true,
      },
      {
        key: "medication_discussion",
        label: "Medication discussion (non-prescriptive)",
        kind: "longText",
        required: false,
        placeholder:
          "Note any conversation about psychotropics. Do not record " +
          "prescriptions — that is the prescriber's eRx system.",
        citationRequired: true,
      },
      {
        key: "referrals",
        label: "Referrals + coordination",
        kind: "bulletList",
        required: false,
        placeholder: "Specialist referrals, ROIs, care-team updates.",
        citationRequired: true,
      },
      {
        key: "safety_plan_reference",
        label: "Safety plan reference",
        kind: "longText",
        required: false,
        placeholder:
          "If risk is elevated, link / summarise the active safety plan. " +
          "Required when assessment.risk_assessment has a non-low row.",
        citationRequired: true,
      },
      {
        key: "next_session",
        label: "Next session cadence",
        kind: "longText",
        required: true,
        placeholder: "When + modality + focus.",
        citationRequired: false,
      },
    ],
    maxOutputTokens: 700,
    regulatoryRefs: [
      "NIH NBK482263 SOAP structure",
      "SAMHSA TIP 50 safety planning",
      "Stanley-Brown Safety Plan",
    ],
  },
] as const;

export function soapSectionByName(section: SoapSection): SoapSectionSpec {
  for (const spec of SOAP_SECTIONS) {
    if (spec.section === section) return spec;
  }
  throw new Error(`Unknown SOAP section ${section} — catalog corrupt`);
}

/**
 * Builds the JSON-schema fragment the LLM must conform to for one
 * section. Keys + required flags come straight from the catalog so
 * adding a field is one edit away.
 */
export function jsonSchemaForSection(
  spec: SoapSectionSpec,
): Record<string, unknown> {
  const properties: Record<string, unknown> = {};
  const required: string[] = [];
  for (const f of spec.fields) {
    const value =
      f.kind === "longText"
        ? { type: "string" }
        : { type: "array", items: { type: "string" } };
    properties[f.key] = {
      type: "object",
      properties: {
        value,
        transcript_spans: {
          type: "array",
          items: {
            type: "object",
            properties: {
              start_ms: { type: "integer", minimum: 0 },
              end_ms: { type: "integer", minimum: 0 },
            },
            required: ["start_ms", "end_ms"],
            additionalProperties: false,
          },
        },
      },
      required: f.citationRequired ? ["value", "transcript_spans"] : ["value"],
      additionalProperties: false,
    };
    if (f.required) required.push(f.key);
  }
  return {
    type: "object",
    properties,
    required,
    additionalProperties: false,
  };
}
