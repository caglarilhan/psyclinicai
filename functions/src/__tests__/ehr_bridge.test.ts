import {
  EHR_ENDPOINT_ALLOWLIST,
  backoffSchedule,
  buildEncounterResource,
  buildPatientResource,
  buildPromObservation,
  buildSessionNoteDocRef,
  endpointById,
  outboxIdempotencyKey,
  retryWithBackoff,
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

// ── Sprint 31 P1 — Patient + Encounter + retry ─────────────────────

describe("buildPatientResource (Sprint 31 P1)", () => {
  it("stamps an MRN identifier under the psyclinicai system", () => {
    const r = buildPatientResource({
      mrn: "MRN-2026-001",
      familyName: "TestFamily",
      givenNames: ["Pilot", "A."],
      birthDateIso: "1985-04-12",
      countryCode: "DE",
    });
    expect(r.resourceType).toBe("Patient");
    const ids = (r as Record<string, unknown>).identifier as Array<
      Record<string, unknown>
    >;
    expect(ids[0]).toMatchObject({
      system: "https://psyclinicai.com/fhir/identifier/mrn",
      value: "MRN-2026-001",
    });
  });

  it("defaults gender to 'unknown' so the FHIR validator accepts it", () => {
    const r = buildPatientResource({
      mrn: "MRN-2026-002",
      familyName: "TestFamily",
      givenNames: ["X"],
      birthDateIso: "1990-01-01",
    });
    expect(r.gender).toBe("unknown");
  });

  it("omits address when no country code is provided", () => {
    const r = buildPatientResource({
      mrn: "MRN-2026-003",
      familyName: "TestFamily",
      givenNames: ["X"],
      birthDateIso: "1990-01-01",
    });
    expect((r as Record<string, unknown>).address).toBeUndefined();
  });
});

describe("buildEncounterResource (Sprint 31 P1)", () => {
  it("status = 'in-progress' while endedAtIso is missing", () => {
    const r = buildEncounterResource({
      encounterId: "enc-1",
      patientFhirRef: "Patient/synthetic_1",
      practitionerFhirRef: "Practitioner/synthetic_1",
      class: "VR",
      startedAtIso: "2026-07-10T10:00:00Z",
    });
    expect(r.status).toBe("in-progress");
    expect((r.class as Record<string, unknown>).code).toBe("VR");
  });

  it("status flips to 'finished' once endedAtIso is provided", () => {
    const r = buildEncounterResource({
      encounterId: "enc-2",
      patientFhirRef: "Patient/synthetic_2",
      practitionerFhirRef: "Practitioner/synthetic_2",
      class: "AMB",
      startedAtIso: "2026-07-10T10:00:00Z",
      endedAtIso: "2026-07-10T10:50:00Z",
    });
    expect(r.status).toBe("finished");
  });

  it("emits ICD-10-CM reason coding when supplied", () => {
    const r = buildEncounterResource({
      encounterId: "enc-3",
      patientFhirRef: "Patient/synthetic_3",
      practitionerFhirRef: "Practitioner/synthetic_3",
      class: "AMB",
      startedAtIso: "2026-07-10T10:00:00Z",
      reasonCode: "F32.1",
      reasonDisplay: "Major depressive disorder, single episode, moderate",
    });
    const reason = (r as Record<string, unknown>).reasonCode as Array<
      Record<string, unknown>
    >;
    const coding = (reason[0].coding as Array<Record<string, unknown>>)[0];
    expect(coding.code).toBe("F32.1");
    expect(coding.system).toBe("http://hl7.org/fhir/sid/icd-10-cm");
  });
});

describe("retryWithBackoff (Sprint 31 P1)", () => {
  it("backoffSchedule caps at 4 s and grows exponentially", () => {
    expect(backoffSchedule(5)).toEqual([250, 500, 1000, 2000, 4000]);
  });

  it("returns 'sent' as soon as doSend resolves true", async () => {
    let calls = 0;
    const r = await retryWithBackoff(
      async () => {
        calls += 1;
        return calls >= 2;
      },
      4,
      async () => {} // skip real sleep
    );
    expect(r.status).toBe("sent");
    expect(r.attempts).toBe(2);
  });

  it("returns 'failed' with the last error after exhausting attempts",
      async () => {
    const r = await retryWithBackoff(
      async () => {
        throw new Error("EHR sandbox 503");
      },
      3,
      async () => {}
    );
    expect(r.status).toBe("failed");
    expect(r.attempts).toBe(3);
    expect(r.finalError).toContain("503");
  });
});
