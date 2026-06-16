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

export interface OutboxEntry {
  idempotency_key: string;
  tenant_id: string;
  clinician_id: string;
  patient_id: string;
  resource_type: "Observation" | "DocumentReference";
  endpoint_id: string;
  payload: Record<string, unknown>;
  status: OutboxStatus;
  attempts: number;
  created_at: string;
  last_attempt_at: string | null;
}
