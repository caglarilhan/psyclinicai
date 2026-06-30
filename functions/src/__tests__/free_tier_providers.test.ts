import {
  GeminiProvider,
  GroqProvider,
  invokeWithFallback,
  LlmProviderError,
} from "../lib/llm_provider";

describe("GroqProvider", () => {
  test("configured = false when key missing", () => {
    const p = new GroqProvider(undefined);
    expect(p.configured).toBe(false);
  });

  test("configured = true when key set", () => {
    const p = new GroqProvider("gsk_test");
    expect(p.configured).toBe(true);
  });

  test("id is 'groq'", () => {
    expect(new GroqProvider("k").id).toBe("groq");
  });

  test("throws missing_credentials when invoked without key", async () => {
    const p = new GroqProvider(undefined);
    await expect(
      p.invoke({messages: [{role: "user", content: "hi"}]}),
    ).rejects.toMatchObject({reason: "missing_credentials"});
  });
});

describe("GeminiProvider", () => {
  test("configured = false when key missing", () => {
    expect(new GeminiProvider(undefined).configured).toBe(false);
  });

  test("configured = true when key set", () => {
    expect(new GeminiProvider("AIza_test").configured).toBe(true);
  });

  test("id is 'gemini'", () => {
    expect(new GeminiProvider("k").id).toBe("gemini");
  });

  test("throws missing_credentials when invoked without key", async () => {
    const p = new GeminiProvider(undefined);
    await expect(
      p.invoke({messages: [{role: "user", content: "hi"}]}),
    ).rejects.toMatchObject({reason: "missing_credentials"});
  });
});

describe("invokeWithFallback with free-tier-only chain", () => {
  test("rejects with last error when every provider is unconfigured", async () => {
    const chain = [
      new GroqProvider(undefined),
      new GeminiProvider(undefined),
    ];
    await expect(
      invokeWithFallback(chain, {
        messages: [{role: "user", content: "hi"}],
      }),
    ).rejects.toBeInstanceOf(LlmProviderError);
  });
});
