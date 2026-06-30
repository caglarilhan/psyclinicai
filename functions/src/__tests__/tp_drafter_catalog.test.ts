import {
  TPD_LAST_REVIEWED,
  TPD_OUTPUT_SECTIONS,
  TPD_PROTOCOLS,
  TPD_SCHEMA_VERSION,
  TPD_SMART_GOAL_FIELDS,
  jsonSchemaForPlan,
  tpProtocolByKey,
} from "../lib/tp_drafter_catalog";

describe("TPD catalog invariants", () => {
  test("non-empty + unique (disorder, modality) tuples", () => {
    expect(TPD_PROTOCOLS.length).toBeGreaterThan(0);
    const seen = new Set<string>();
    for (const p of TPD_PROTOCOLS) {
      const k = `${p.disorder}_${p.modality}`;
      expect(seen.has(k)).toBe(false);
      seen.add(k);
    }
  });

  test("every protocol has guideline anchors", () => {
    for (const p of TPD_PROTOCOLS) {
      expect(p.guidelineAnchors.length).toBeGreaterThan(0);
    }
  });

  test("high-risk protocols require supervisor co-sign", () => {
    for (const p of TPD_PROTOCOLS) {
      if (
        p.disorder === "ptsd" ||
        p.disorder === "borderlinePersonalityDisorder" ||
        p.disorder === "alcoholUseDisorder"
      ) {
        expect(p.requiresSupervisorCoSign).toBe(true);
      }
    }
  });

  test("schemaVersion + lastReviewed shape", () => {
    expect(TPD_SCHEMA_VERSION).toBeGreaterThan(0);
    expect(TPD_LAST_REVIEWED).toMatch(/^\d{4}-\d{2}$/);
  });

  test("smart goal fields + sections non-empty + unique", () => {
    expect(TPD_SMART_GOAL_FIELDS.length).toBeGreaterThan(0);
    expect(new Set(TPD_SMART_GOAL_FIELDS).size).toBe(
      TPD_SMART_GOAL_FIELDS.length,
    );
    expect(TPD_OUTPUT_SECTIONS.length).toBeGreaterThan(0);
    expect(new Set(TPD_OUTPUT_SECTIONS).size).toBe(
      TPD_OUTPUT_SECTIONS.length,
    );
  });
});

describe("tpProtocolByKey", () => {
  test("returns matching", () => {
    const p = tpProtocolByKey({
      disorder: "majorDepressiveDisorder",
      modality: "cbt",
    });
    expect(p.recommendedSessions).toBe(16);
  });

  test("throws on unsupported tuple", () => {
    expect(() =>
      tpProtocolByKey({disorder: "insomniaDisorder", modality: "emdr"}),
    ).toThrow();
  });
});

describe("jsonSchemaForPlan", () => {
  test("required list matches output sections", () => {
    const schema = jsonSchemaForPlan() as {
      required: string[];
      properties: Record<string, unknown>;
      additionalProperties: boolean;
    };
    expect(schema.required.sort()).toEqual(
      [...TPD_OUTPUT_SECTIONS].sort(),
    );
    expect(schema.additionalProperties).toBe(false);
  });

  test("smart_goals items require every SMART field", () => {
    const schema = jsonSchemaForPlan() as {
      properties: {
        smart_goals: {items: {required: string[]}};
      };
    };
    expect(
      schema.properties.smart_goals.items.required.sort(),
    ).toEqual([...TPD_SMART_GOAL_FIELDS].sort());
  });
});
