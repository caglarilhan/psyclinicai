// Sprint 32 P1 — pure-logic tests for the Observation handler.
// HTTP / Firestore integration is covered by the manual sandbox replay
// in `docs/runbooks/ehr-observation-replay.md` (born on first use).

jest.mock("firebase-admin", () => ({
  firestore: {
    FieldValue: {
      serverTimestamp: () => "__SERVER_TS__",
    },
  },
}));
jest.mock("firebase-functions", () => {
  const onRequest = (fn: unknown) => fn;
  const region = () => ({https: {onRequest}});
  const runWith = () => ({region});
  return {
    logger: {warn: jest.fn(), error: jest.fn(), info: jest.fn()},
    https: {onRequest},
    runWith,
    region,
  };
});
jest.mock("../lib/auth", () => ({
  applyCors: jest.fn(() => false),
  authorizeUid: jest.fn(),
}));

import {
  postObservation,
  validatePromCompletion,
} from "../ehr_observation_handler";

describe("validatePromCompletion", () => {
  const valid = {
    endpointId: "epic-r4-sandbox",
    instrument: "PHQ-9",
    score: 14,
    effectiveAtIso: "2026-07-15T12:30:00Z",
    patientFhirRef: "Patient/synthetic_1",
    practitionerFhirRef: "Practitioner/synthetic_1",
    subjectKey: "patient_42",
    eventKey: "phq9:2026-07-15",
  };

  it("accepts a fully-formed body", () => {
    const r = validatePromCompletion(valid);
    expect(r.ok).toBe(true);
    if (r.ok) expect(r.body.instrument).toBe("PHQ-9");
  });

  it("rejects non-object inputs", () => {
    expect(validatePromCompletion(null).ok).toBe(false);
    expect(validatePromCompletion("string").ok).toBe(false);
    expect(validatePromCompletion(42).ok).toBe(false);
  });

  it("flags each missing required field by name", () => {
    const keys = [
      "endpointId",
      "instrument",
      "score",
      "effectiveAtIso",
      "patientFhirRef",
      "practitionerFhirRef",
      "subjectKey",
      "eventKey",
    ];
    for (const k of keys) {
      const partial = {...valid};
      delete (partial as Record<string, unknown>)[k];
      const r = validatePromCompletion(partial);
      expect(r.ok).toBe(false);
      if (!r.ok) expect(r.error).toBe(`missing_${k}`);
    }
  });

  it("rejects unsupported instruments", () => {
    const r = validatePromCompletion({...valid, instrument: "MADRS"});
    expect(r.ok).toBe(false);
    if (!r.ok) expect(r.error).toBe("unsupported_instrument");
  });

  it("rejects scores outside 0..27", () => {
    expect(validatePromCompletion({...valid, score: -1}).ok).toBe(false);
    expect(validatePromCompletion({...valid, score: 28}).ok).toBe(false);
    expect(validatePromCompletion({...valid, score: "14"}).ok).toBe(false);
  });

  it("rejects malformed effectiveAtIso", () => {
    const r = validatePromCompletion({
      ...valid,
      effectiveAtIso: "2026-07-15",
    });
    expect(r.ok).toBe(false);
    if (!r.ok) expect(r.error).toBe("effective_at_not_iso");
  });
});

describe("postObservation", () => {
  it("returns true on 2xx", async () => {
    const fakeFetch = jest.fn().mockResolvedValue({status: 201} as Response);
    const ok = await postObservation(
      "https://fhir.example.test/r4",
      {resourceType: "Observation"},
      fakeFetch as unknown as typeof fetch,
    );
    expect(ok).toBe(true);
    expect(fakeFetch).toHaveBeenCalledTimes(1);
    const call = fakeFetch.mock.calls[0];
    expect(call[0]).toBe("https://fhir.example.test/r4/Observation");
    expect((call[1] as RequestInit).method).toBe("POST");
    const headers = (call[1] as RequestInit).headers as Record<string, string>;
    expect(headers["Content-Type"]).toBe("application/fhir+json");
  });

  it("returns false on 5xx", async () => {
    const fakeFetch = jest.fn().mockResolvedValue({status: 502} as Response);
    const ok = await postObservation(
      "https://fhir.example.test/r4",
      {resourceType: "Observation"},
      fakeFetch as unknown as typeof fetch,
    );
    expect(ok).toBe(false);
  });
});
