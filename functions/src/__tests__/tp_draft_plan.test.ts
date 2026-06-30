import {
  MAX_EXTRA_CONTEXT_CHARS,
  MAX_PROBLEMS,
  buildSystemPrompt,
  defaultProviderChain,
  extractJson,
} from "../tp_draft_plan";

describe("buildSystemPrompt", () => {
  test("contains protocol label + STRICT JSON guard", () => {
    const p = buildSystemPrompt("CBT for Major Depressive Disorder", [
      "NICE CG90 depression in adults",
    ]);
    expect(p).toContain("CBT for Major Depressive Disorder");
    expect(p).toContain("STRICT JSON only");
  });

  test("never-prescribe + never-auto-file guards present", () => {
    const p = buildSystemPrompt("any", ["any"]);
    expect(p).toContain("NEVER prescribe");
    expect(p).toContain("NEVER auto-file");
  });

  test("guideline anchors appear verbatim", () => {
    const anchors = ["NICE NG116 post-traumatic stress disorder"];
    const p = buildSystemPrompt("any", anchors);
    expect(p).toContain(anchors[0]);
  });

  test("instructs verbatim citation from anchor list", () => {
    const p = buildSystemPrompt("any", ["a", "b"]);
    expect(p).toContain("verbatim string from the supplied anchor list");
  });
});

describe("extractJson", () => {
  test("parses a bare JSON object", () => {
    expect(extractJson('{"a": 1}')).toEqual({a: 1});
  });

  test("strips ```json fences", () => {
    expect(extractJson('```json\n{"x":2}\n```')).toEqual({x: 2});
  });

  test("strips plain ``` fences", () => {
    expect(extractJson('```\n{"y":3}\n```')).toEqual({y: 3});
  });

  test("throws on non-JSON", () => {
    expect(() => extractJson("not json at all")).toThrow();
  });
});

describe("size caps", () => {
  test("bounded sensibly", () => {
    expect(MAX_PROBLEMS).toBeGreaterThanOrEqual(5);
    expect(MAX_PROBLEMS).toBeLessThanOrEqual(20);
    expect(MAX_EXTRA_CONTEXT_CHARS).toBeGreaterThanOrEqual(500);
    expect(MAX_EXTRA_CONTEXT_CHARS).toBeLessThanOrEqual(10_000);
  });
});

describe("defaultProviderChain", () => {
  test("returns Groq-first bootstrap chain", () => {
    const chain = defaultProviderChain();
    expect(chain.length).toBe(4);
    expect(chain[0].id).toBe("groq");
    expect(chain[1].id).toBe("gemini");
    expect(chain[2].id).toBe("anthropic");
    expect(chain[3].id).toBe("azure_openai");
  });
});
