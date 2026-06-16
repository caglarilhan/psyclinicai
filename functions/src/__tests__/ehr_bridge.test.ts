import {
  EHR_ENDPOINT_ALLOWLIST,
  buildPromObservation,
  buildSessionNoteDocRef,
  endpointById,
  outboxIdempotencyKey,
} from "../ehr_bridge";

describe("endpoint allow-list (Sprint 27 W2 — EHR FHIR Bridge)", () => {
  it("ships at least three sandbox endpoints", () => {
    expect(EHR_ENDPOINT_ALLOWLIST.length).toBeGreaterThanOrEqual(3);
  });

  it("includes Epic R4 + Cerner Code + a EU endpoint", () => {
    const ids = EHR_ENDPOINT_ALLOWLIST.map((e) => e.id);
    expect(ids).toContain("epic-r4-sandbox");
    expect(ids).toContain("cerner-codecloud-sandbox");
    expect(EHR_ENDPOINT_ALLOWLIST.some((e) => e.region === "EU")).toBe(true);
  });

  it("endpointById rejects unknown ids", () => {
    expect(endpointById("epic-r4-sandbox")?.region).toBe("US");
    expect(endpointById("attacker-controlled-host")).toBeNull();
  });
});

describe("FHIR resource builders", () => {
  it("buildPromObservation emits LOINC for PHQ-9", () => {
    const r = buildPromObservation({
      instrument: "PHQ-9",
      score: 14,
      effectiveAtIso: "2026-06-16T12:00:00Z",
      patientFhirRef: "Patient/synthetic_1",
      practitionerFhirRef: "Practitioner/synthetic_1",
    });
    expect(r.resourceType).toBe("Observation");
    const code = (r as Record<string, unknown>).code as Record<string, unknown>;
    const coding = (code.coding as Array<Record<string, unknown>>)[0];
    expect(coding.system).toBe("http://loinc.org");
    expect(coding.code).toBe("44261-6");
    const valueQ = (r as Record<string, unknown>).valueQuantity as
      Record<string, unknown>;
    expect(valueQ.value).toBe(14);
  });

  it("buildPromObservation emits LOINC for GAD-7", () => {
    const r = buildPromObservation({
      instrument: "GAD-7",
      score: 9,
      effectiveAtIso: "2026-06-16T12:00:00Z",
      patientFhirRef: "Patient/synthetic_2",
      practitionerFhirRef: "Practitioner/synthetic_1",
    });
    const code = (r as Record<string, unknown>).code as Record<string, unknown>;
    const coding = (code.coding as Array<Record<string, unknown>>)[0];
    expect(coding.code).toBe("70274-6");
  });

  it("buildSessionNoteDocRef ships PDF metadata + optional encounter ref",
      () => {
    const r = buildSessionNoteDocRef({
      patientFhirRef: "Patient/synthetic_1",
      practitionerFhirRef: "Practitioner/synthetic_1",
      pdfSha256: "deadbeef",
      pdfSizeBytes: 12345,
      pdfUrl: "https://example.test/n.pdf",
      createdAtIso: "2026-06-16T12:00:00Z",
      encounterFhirRef: "Encounter/synthetic_42",
    });
    expect(r.resourceType).toBe("DocumentReference");
    expect((r as Record<string, unknown>).context).toBeDefined();
  });
});

describe("outboxIdempotencyKey (replay protection)", () => {
  it("is deterministic for the same tuple", () => {
    const a = outboxIdempotencyKey({
      endpointId: "epic-r4-sandbox",
      resourceType: "Observation",
      subjectKey: "Patient/synthetic_1",
      eventKey: "phq9:2026-06-16T12:00:00Z",
    });
    const b = outboxIdempotencyKey({
      endpointId: "epic-r4-sandbox",
      resourceType: "Observation",
      subjectKey: "Patient/synthetic_1",
      eventKey: "phq9:2026-06-16T12:00:00Z",
    });
    expect(a).toBe(b);
  });

  it("differs when the subject or event differs", () => {
    const a = outboxIdempotencyKey({
      endpointId: "epic-r4-sandbox",
      resourceType: "Observation",
      subjectKey: "Patient/synthetic_1",
      eventKey: "phq9:2026-06-16T12:00:00Z",
    });
    const b = outboxIdempotencyKey({
      endpointId: "epic-r4-sandbox",
      resourceType: "Observation",
      subjectKey: "Patient/synthetic_2",
      eventKey: "phq9:2026-06-16T12:00:00Z",
    });
    expect(a).not.toBe(b);
  });
});
