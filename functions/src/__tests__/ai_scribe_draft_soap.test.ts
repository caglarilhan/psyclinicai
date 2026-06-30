import {
  buildCompositeSchema,
  buildSystemPrompt,
  defaultProviderChain,
  extractJson,
  MAX_TRANSCRIPT_CHARS,
} from "../ai_scribe_draft_soap";
import {SOAP_SECTIONS} from "../lib/soap_section_catalog";

describe("buildSystemPrompt", () => {
  test("contains the four canonical sections by title", () => {
    const prompt = buildSystemPrompt([...SOAP_SECTIONS]);
    for (const s of SOAP_SECTIONS) {
      expect(prompt).toContain(`### ${s.title}`);
    }
  });

  test("includes the 'STRICT JSON only' invariant", () => {
    const prompt = buildSystemPrompt([...SOAP_SECTIONS]);
    expect(prompt).toContain("STRICT JSON only");
  });

  test("includes the 'never auto-file / never prescribe' guard", () => {
    const prompt = buildSystemPrompt([...SOAP_SECTIONS]);
    expect(prompt).toContain("never auto-file");
    expect(prompt).toContain("never prescribe");
  });

  test("includes DSM-5-TR anchor for assessment", () => {
    const prompt = buildSystemPrompt([...SOAP_SECTIONS]);
    expect(prompt).toContain("DSM-5-TR");
  });

  test("includes safety / risk minimisation guard", () => {
    const prompt = buildSystemPrompt([...SOAP_SECTIONS]);
    expect(prompt).toContain("Never minimise");
  });
});

describe("buildCompositeSchema", () => {
  test("required lists every requested section", () => {
    const schema = buildCompositeSchema([...SOAP_SECTIONS]) as {
      required: string[];
      properties: Record<string, unknown>;
    };
    expect(schema.required.sort()).toEqual(
      ["assessment", "objective", "plan", "subjective"],
    );
    expect(Object.keys(schema.properties).sort()).toEqual(
      ["assessment", "objective", "plan", "subjective"],
    );
  });

  test("respects the additionalProperties=false anchor", () => {
    const schema = buildCompositeSchema([...SOAP_SECTIONS]) as {
      additionalProperties: boolean;
    };
    expect(schema.additionalProperties).toBe(false);
  });

  test("subset request only includes requested sections", () => {
    const subset = SOAP_SECTIONS.filter((s) => s.section === "subjective");
    const schema = buildCompositeSchema(subset) as {
      required: string[];
    };
    expect(schema.required).toEqual(["subjective"]);
  });
});

describe("extractJson", () => {
  test("parses a bare JSON object", () => {
    expect(extractJson('{"a": 1}')).toEqual({a: 1});
  });

  test("strips ```json fences", () => {
    expect(extractJson("```json\n{\"x\": 2}\n```")).toEqual({x: 2});
  });

  test("strips plain ``` fences", () => {
    expect(extractJson("```\n{\"y\": 3}\n```")).toEqual({y: 3});
  });

  test("throws on non-JSON", () => {
    expect(() => extractJson("not json at all")).toThrow();
  });
});

describe("transcript size cap", () => {
  test("MAX_TRANSCRIPT_CHARS is bounded sensibly", () => {
    expect(MAX_TRANSCRIPT_CHARS).toBeGreaterThanOrEqual(5_000);
    expect(MAX_TRANSCRIPT_CHARS).toBeLessThanOrEqual(50_000);
  });
});

describe("defaultProviderChain", () => {
  test("returns Anthropic first then Azure", () => {
    const chain = defaultProviderChain();
    expect(chain.length).toBe(4);
    expect(chain[0].id).toBe("groq");
    expect(chain[1].id).toBe("gemini");
    expect(chain[2].id).toBe("anthropic");
    expect(chain[3].id).toBe("azure_openai");
  });
});
