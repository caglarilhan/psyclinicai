/**
 * Sprint 32 P1 — EHR FHIR R4 Observation HTTPS handler.
 *
 * Wires Sprint 27 W2 + Sprint 31 P1 pieces together:
 *
 *   PROM completion (PHQ-9 / GAD-7)
 *     → buildPromObservation
 *       → outbox write (Firestore `ehr_outbox/{tenantId}/{idempotencyKey}`)
 *         → retryWithBackoff against the allow-listed FHIR endpoint
 *           → outbox row flipped to sent or failed.
 *
 * Handler is intentionally a `clinic-internal callable`: clinician
 * triggers it after signing the note. Idempotency comes from the
 * outbox key — replaying the same (endpoint, instrument, patient,
 * date) yields the existing outbox entry rather than a duplicate
 * write.
 *
 * Skill-panel coverage: senior-backend (handler shape), rag-architect
 * (resource builder reuse), healthcare-emr-patterns (FHIR Observation
 * idempotency), release-manager (retry + outbox audit).
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {applyCors, authorizeUid} from "./lib/auth";
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";
import {
  PromInstrument,
  buildPromObservation,
  endpointById,
  outboxIdempotencyKey,
  retryWithBackoff,
} from "./ehr_bridge";

interface PromCompletionBody {
  endpointId: string;
  instrument: PromInstrument;
  score: number;
  effectiveAtIso: string;
  patientFhirRef: string;
  practitionerFhirRef: string;
  /** Stable patient id local to our system — used for idempotency. */
  subjectKey: string;
  /** Stable event id local to our system (encounter id + date). */
  eventKey: string;
}

/**
 * Validate incoming body. Returns either `{ok: true, body}` or
 * `{ok: false, error}` so the handler can branch without nested ifs.
 */
export function validatePromCompletion(input: unknown): {
  ok: true;
  body: PromCompletionBody;
} | {
  ok: false;
  error: string;
} {
  if (typeof input !== "object" || input === null) {
    return {ok: false, error: "body_not_object"};
  }
  const b = input as Record<string, unknown>;
  const required = [
    "endpointId",
    "instrument",
    "score",
    "effectiveAtIso",
    "patientFhirRef",
    "practitionerFhirRef",
    "subjectKey",
    "eventKey",
  ];
  for (const k of required) {
    if (typeof b[k] === "undefined" || b[k] === null || b[k] === "") {
      return {ok: false, error: `missing_${k}`};
    }
  }
  if (b.instrument !== "PHQ-9" && b.instrument !== "GAD-7") {
    return {ok: false, error: "unsupported_instrument"};
  }
  if (typeof b.score !== "number" || b.score < 0 || b.score > 27) {
    return {ok: false, error: "score_out_of_range"};
  }
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(String(b.effectiveAtIso))) {
    return {ok: false, error: "effective_at_not_iso"};
  }
  return {ok: true, body: b as unknown as PromCompletionBody};
}

/**
 * Post the Observation to the FHIR endpoint. Pure-ish: receives a
 * `fetchFn` so tests inject a fake. Returns `true` on 2xx.
 */
export async function postObservation(
  baseUrl: string,
  observation: Record<string, unknown>,
  fetchFn: typeof fetch = fetch,
): Promise<boolean> {
  const r = await fetchFn(`${baseUrl}/Observation`, {
    method: "POST",
    headers: {
      "Content-Type": "application/fhir+json",
      "Accept": "application/fhir+json",
    },
    body: JSON.stringify(observation),
  });
  return r.status >= 200 && r.status < 300;
}

export const ehrSubmitProm = functions
  .runWith({minInstances: 0, memory: "512MB", timeoutSeconds: 60})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (applyRateLimit(req, res, "clinician-dashboard-read")) return;
    const uid = await authorizeUid(req, "ehrSubmitProm");
    if (!uid) {
      res.status(401).json({error: "unauthenticated"});
      return;
    }
    const validated = validatePromCompletion(req.body);
    if (!validated.ok) {
      res.status(400).json({error: validated.error});
      return;
    }
    const body = validated.body;
    const endpoint = endpointById(body.endpointId);
    if (endpoint === null) {
      res.status(400).json({error: "unknown_endpoint"});
      return;
    }

    const observation = buildPromObservation({
      instrument: body.instrument,
      score: body.score,
      effectiveAtIso: body.effectiveAtIso,
      patientFhirRef: body.patientFhirRef,
      practitionerFhirRef: body.practitionerFhirRef,
    });

    const idempotencyKey = outboxIdempotencyKey({
      endpointId: body.endpointId,
      resourceType: "Observation",
      subjectKey: body.subjectKey,
      eventKey: body.eventKey,
    });

    const tenantId = uid; // solo-practice invariant — tid == uid.
    const outboxRef = admin
      .firestore()
      .collection("ehr_outbox")
      .doc(tenantId)
      .collection("entries")
      .doc(idempotencyKey);

    // If we already have a sent row, return success without retrying —
    // the EHR has the data, the client doesn't need to know we replayed.
    const existing = await outboxRef.get();
    if (existing.exists && (existing.data() ?? {}).status === "sent") {
      res.json({status: "duplicate_sent", idempotencyKey});
      return;
    }

    await outboxRef.set(
      {
        idempotency_key: idempotencyKey,
        tenant_id: tenantId,
        clinician_id: uid,
        patient_id: body.patientFhirRef,
        resource_type: "Observation",
        endpoint_id: body.endpointId,
        payload: observation,
        status: "queued",
        attempts: 0,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        last_attempt_at: null,
      },
      {merge: true},
    );

    const send = await retryWithBackoff(
      async () => postObservation(endpoint.baseUrl, observation),
      3,
    );

    await outboxRef.set(
      {
        status: send.status === "sent" ? "sent" : "failed",
        attempts: send.attempts,
        last_attempt_at: admin.firestore.FieldValue.serverTimestamp(),
        final_error: send.finalError ?? null,
      },
      {merge: true},
    );

    if (send.status === "sent") {
      res.json({status: "sent", idempotencyKey, attempts: send.attempts});
    } else {
      res.status(502).json({
        status: "failed",
        idempotencyKey,
        attempts: send.attempts,
        error: send.finalError ?? null,
      });
    }
  });
