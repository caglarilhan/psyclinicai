import {
  SOAP_LAST_REVIEWED,
  SOAP_SCHEMA_VERSION,
  SOAP_SECTION_TEMPERATURE,
  SOAP_SECTIONS,
  jsonSchemaForSection,
  soapSectionByName,
} from "../lib/soap_section_catalog";

describe("SOAP catalog invariants", () => {
  test("contains the four canonical sections, in order", () => {
    expect(SOAP_SECTIONS.map((s) => s.section)).toEqual([
      "subjective",
      "objective",
      "assessment",
      "plan",
    ]);
  });

  test("every section has at least one required field", () => {
    for (const spec of SOAP_SECTIONS) {
      const reqs = spec.fields.filter((f) => f.required);
      expect(reqs.length).toBeGreaterThan(0);
    }
  });

  test("every section has a non-empty regulatoryRefs anchor", () => {
    for (const spec of SOAP_SECTIONS) {
      expect(spec.regulatoryRefs.length).toBeGreaterThan(0);
    }
  });

  test("every section has temperature in [0,1]", () => {
    for (const spec of SOAP_SECTIONS) {
      const t = SOAP_SECTION_TEMPERATURE[spec.section];
      expect(t).toBeGreaterThanOrEqual(0);
      expect(t).toBeLessThanOrEqual(1);
    }
  });

  test("field keys are unique within each section", () => {
    for (const spec of SOAP_SECTIONS) {
      const seen = new Set<string>();
      for (const f of spec.fields) {
        expect(seen.has(f.key)).toBe(false);
        seen.add(f.key);
      }
    }
  });

  test("schema version pinned to a positive integer", () => {
    expect(Number.isInteger(SOAP_SCHEMA_VERSION)).toBe(true);
    expect(SOAP_SCHEMA_VERSION).toBeGreaterThan(0);
  });

  test("lastReviewed is YYYY-MM", () => {
    expect(SOAP_LAST_REVIEWED).toMatch(/^\d{4}-\d{2}$/);
  });

  test("assessment.risk_assessment is required + citation-required", () => {
    const spec = soapSectionByName("assessment");
    const risk = spec.fields.find((f) => f.key === "risk_assessment");
    expect(risk).toBeDefined();
    expect(risk?.required).toBe(true);
    expect(risk?.citationRequired).toBe(true);
  });

  test("plan carries safety_plan_reference", () => {
    const spec = soapSectionByName("plan");
    expect(spec.fields.find((f) => f.key === "safety_plan_reference"))
      .toBeDefined();
  });
});

describe("jsonSchemaForSection", () => {
  test("emits required-only keys for the section", () => {
    const spec = soapSectionByName("subjective");
    const schema = jsonSchemaForSection(spec) as {
      required: string[];
      properties: Record<string, unknown>;
    };
    expect(schema.required.sort()).toEqual([
      "chief_complaint",
      "history_present_illness",
      "patient_reported_symptoms",
    ]);
    expect(Object.keys(schema.properties).length).toBe(spec.fields.length);
  });

  test("citation-required fields require transcript_spans", () => {
    const spec = soapSectionByName("subjective");
    const schema = jsonSchemaForSection(spec) as {
      properties: Record<string, { required: string[] }>;
    };
    const cc = schema.properties["chief_complaint"];
    expect(cc.required).toEqual(["value", "transcript_spans"]);
  });

  test("non-citation fields only require value", () => {
    const spec = soapSectionByName("objective");
    const schema = jsonSchemaForSection(spec) as {
      properties: Record<string, { required: string[] }>;
    };
    const oms = schema.properties["outcome_measure_scores"];
    expect(oms.required).toEqual(["value"]);
  });
});

describe("soapSectionByName", () => {
  test("throws on unknown", () => {
    expect(() =>
      soapSectionByName("nonsense" as unknown as "plan"),
    ).toThrow();
  });
});
