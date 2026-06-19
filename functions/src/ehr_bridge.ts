/**
 * EHR FHIR R4 write Bridge — MVP scaffold (Sprint 27 W2).
 *
 * Goal: push PHQ-9/GAD-7 results as FHIR `Observation` resources and
 * session note PDFs as `DocumentReference` resources into a small
 * allow-list of FHIR sandboxes (Epic R4 sandbox, Cerner Code-cloud,
 * one EU EHR sandbox TBD by the operator).
 *
 * This file ships the **pure** parts now — endpoint allow-list,
 * FHIR resource builders, idempotency-key derivation, outbox doc
 * shape. The actual HTTPS handler + SMART-on-FHIR backend client
 * (mTLS + JWT bearer) lands W2 day 4 once sandbox credentials are
 * issued. Splitting the pure surface out means we can ship + test
 * the rules before the secrets exist.
 */

/** Whitelisted FHIR endpoints. Anything else → `unknown_endpoint`. */
export const EHR_ENDPOINT_ALLOWLIST: ReadonlyArray<EhrEndpoint> = [
  {
    id: "epic-r4-sandbox",
    label: "Epic R4 sandbox",
    baseUrl: "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4",
    region: "US",
  },
  {
    id: "cerner-codecloud-sandbox",
    label: "Cerner Code sandbox",
    baseUrl: "https://fhir-myrecord.cerner.com/r4/ec2458f2-1e24-41c8-b71b-0e701af7583d",
    region: "US",
  },
  {
    id: "hapi-eu-sandbox",
    label: "HAPI EU sandbox",
    baseUrl: "https://hapi.fhir.org/baseR4",
    region: "EU",
  },
];

export interface EhrEndpoint {
  id: string;
  label: string;
  baseUrl: string;
  region: "US" | "EU";
}

/** Lookup by `id`, returns `null` for unknown endpoints. */
export function endpointById(id: string): EhrEndpoint | null {
  return EHR_ENDPOINT_ALLOWLIST.find((e) => e.id === id) ?? null;
}

// ── FHIR resource builders ─────────────────────────────────────────

export type PromInstrument = "PHQ-9" | "GAD-7";

const LOINC_BY_INSTRUMENT: Record<PromInstrument, string> = {
  "PHQ-9": "44261-6",
  "GAD-7": "70274-6",
};

export function buildPromObservation(args: {
  instrument: PromInstrument;
  score: number;
  effectiveAtIso: string;
  patientFhirRef: string;
  practitionerFhirRef: string;
}): Record<string, unknown> {
  return {
    resourceType: "Observation",
    status: "final",
    category: [
      {
        coding: [
          {
            system: "http://terminology.hl7.org/CodeSystem/observation-category",
            code: "survey",
            display: "Survey",
          },
        ],
      },
    ],
    code: {
      coding: [
        {
          system: "http://loinc.org",
          code: LOINC_BY_INSTRUMENT[args.instrument],
          display: `${args.instrument} total score`,
        },
      ],
      text: `${args.instrument} total score`,
    },
    subject: {reference: args.patientFhirRef},
    performer: [{reference: args.practitionerFhirRef}],
    effectiveDateTime: args.effectiveAtIso,
    valueQuantity: {
      value: args.score,
      system: "http://unitsofmeasure.org",
      code: "{score}",
    },
  };
}

export function buildSessionNoteDocRef(args: {
  patientFhirRef: string;
  practitionerFhirRef: string;
  pdfSha256: string;
  pdfSizeBytes: number;
  pdfUrl: string;
  createdAtIso: string;
  encounterFhirRef?: string;
}): Record<string, unknown> {
  return {
    resourceType: "DocumentReference",
    status: "current",
    docStatus: "final",
    type: {
      coding: [
        {
          system: "http://loinc.org",
          code: "11506-3",
          display: "Progress note",
        },
      ],
    },
    subject: {reference: args.patientFhirRef},
    author: [{reference: args.practitionerFhirRef}],
    date: args.createdAtIso,
    content: [
      {
        attachment: {
          contentType: "application/pdf",
          url: args.pdfUrl,
          size: args.pdfSizeBytes,
          hash: args.pdfSha256,
          creation: args.createdAtIso,
        },
      },
    ],
    ...(args.encounterFhirRef ?
      {context: {encounter: [{reference: args.encounterFhirRef}]}} :
      {}),
  };
}

// ── Outbox + idempotency ───────────────────────────────────────────

/**
 * Deterministic idempotency key for the outbox. Hashing a stable
 * tuple lets retries deduplicate on the server side AND lets the
 * client surface "already queued" before posting.
 */
export function outboxIdempotencyKey(args: {
  endpointId: string;
  resourceType: "Observation" | "DocumentReference";
  subjectKey: string;
  eventKey: string;
}): string {
  return `${args.endpointId}:${args.resourceType}:${args.subjectKey}:${args.eventKey}`;
}

export type OutboxStatus = "queued" | "sent" | "failed";

// Sprint 31 P1 / Sprint 32 P1 — widen the type so Patient + Encounter
// rides the same outbox plumbing as Observation + DocumentReference.
export type FhirResourceType =
  | "Observation"
  | "DocumentReference"
  | "Patient"
  | "Encounter";

export interface OutboxEntry {
  idempotency_key: string;
  tenant_id: string;
  clinician_id: string;
  patient_id: string;
  resource_type: FhirResourceType;
  endpoint_id: string;
  payload: Record<string, unknown>;
  status: OutboxStatus;
  attempts: number;
  created_at: string;
  last_attempt_at: string | null;
}

// ── Sprint 31 P1 — Patient resource ────────────────────────────────

export interface PatientBuilderArgs {
  /** Local MRN — stamped as Identifier#value. */
  mrn: string;
  /** Family name (no PHI in tests; pilot data only). */
  familyName: string;
  givenNames: string[];
  birthDateIso: string; // YYYY-MM-DD
  /** Patient gender at the FHIR level — administrative, not clinical. */
  gender?: "male" | "female" | "other" | "unknown";
  /** Two-letter ISO country code, e.g. "US", "DE". */
  countryCode?: string;
}

export function buildPatientResource(
  args: PatientBuilderArgs,
): Record<string, unknown> {
  return {
    resourceType: "Patient",
    identifier: [
      {
        use: "usual",
        system: "https://psyclinicai.com/fhir/identifier/mrn",
        value: args.mrn,
      },
    ],
    active: true,
    name: [
      {
        use: "official",
        family: args.familyName,
        given: args.givenNames,
      },
    ],
    gender: args.gender ?? "unknown",
    birthDate: args.birthDateIso,
    ...(args.countryCode ?
      {address: [{country: args.countryCode}]} :
      {}),
  };
}

// ── Sprint 31 P1 — Encounter resource ──────────────────────────────

export type EncounterClass = "AMB" | "VR" | "HH";

export interface EncounterBuilderArgs {
  /** Local encounter id (uuid v4 from session.id). */
  encounterId: string;
  patientFhirRef: string;
  practitionerFhirRef: string;
  /** FHIR class. AMB = ambulatory office, VR = virtual telehealth, HH = home health. */
  class: EncounterClass;
  /** ICD-10-CM / DSM-5 primary code, e.g. "F32.1". */
  reasonCode?: string;
  reasonDisplay?: string;
  startedAtIso: string;
  endedAtIso?: string;
}

const ENCOUNTER_CLASS_DISPLAY: Record<EncounterClass, string> = {
  AMB: "ambulatory",
  VR: "virtual",
  HH: "home health",
};

export function buildEncounterResource(
  args: EncounterBuilderArgs,
): Record<string, unknown> {
  return {
    resourceType: "Encounter",
    identifier: [
      {
        system: "https://psyclinicai.com/fhir/identifier/encounter",
        value: args.encounterId,
      },
    ],
    status: args.endedAtIso ? "finished" : "in-progress",
    class: {
      system: "http://terminology.hl7.org/CodeSystem/v3-ActCode",
      code: args.class,
      display: ENCOUNTER_CLASS_DISPLAY[args.class],
    },
    subject: {reference: args.patientFhirRef},
    participant: [
      {
        individual: {reference: args.practitionerFhirRef},
      },
    ],
    period: {
      start: args.startedAtIso,
      ...(args.endedAtIso ? {end: args.endedAtIso} : {}),
    },
    ...(args.reasonCode ?
      {
        reasonCode: [
          {
            coding: [
              {
                system: "http://hl7.org/fhir/sid/icd-10-cm",
                code: args.reasonCode,
                ...(args.reasonDisplay ? {display: args.reasonDisplay} : {}),
              },
            ],
          },
        ],
      } :
      {}),
  };
}

// ── Sprint 31 P1 — retry helper (HTTPS POST surface stubbed) ────────

export interface SendResult {
  status: OutboxStatus;
  attempts: number;
  finalError?: string;
}

/**
 * Pure-logic exponential backoff scheduler. Returns the list of
 * wait-times (ms) for `maxAttempts` retries; consumers use it with
 * setTimeout / a real HTTP client. Tested directly so the policy is
 * locked in: 250 ms, 500 ms, 1 s, 2 s, capped at 4 s.
 */
export function backoffSchedule(maxAttempts: number): number[] {
  const out: number[] = [];
  let cur = 250;
  for (let i = 0; i < maxAttempts; i++) {
    out.push(Math.min(cur, 4000));
    cur *= 2;
  }
  return out;
}

/**
 * In-memory retry driver — given a `doSend` callback that resolves to
 * `true` on success, returns the final SendResult. Lets a Cloud
 * Function handler keep its real HTTP call surface tiny while still
 * benefiting from a tested retry policy.
 */
export async function retryWithBackoff(
  doSend: (attempt: number) => Promise<boolean>,
  maxAttempts: number,
  sleep: (ms: number) => Promise<void> = (ms) =>
    new Promise((r) => setTimeout(r, ms)),
): Promise<SendResult> {
  const waits = backoffSchedule(maxAttempts);
  let lastErr: string | undefined;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const ok = await doSend(attempt);
      if (ok) return {status: "sent", attempts: attempt};
    } catch (e) {
      lastErr = String(e).slice(0, 200);
    }
    if (attempt < maxAttempts) await sleep(waits[attempt - 1]);
  }
  return {status: "failed", attempts: maxAttempts, finalError: lastErr};
}
