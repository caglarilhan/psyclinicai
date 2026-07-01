jest.mock("firebase-functions", () => ({
  logger: {
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

import {
  AnthropicProvider,
  AzureOpenAIProvider,
  LlmProvider,
  LlmProviderError,
  LlmRequest,
  classifyStatus,
  fetchWithTimeout,
  invokeWithFallback,
} from "../lib/llm_provider";

// Mock global fetch for these tests. Restore between cases.
const realFetch = global.fetch;
afterEach(() => {
  global.fetch = realFetch;
  jest.clearAllMocks();
});

function mockFetch(
  impl: (url: string, init: RequestInit) => Promise<Response> | Response
) {
  (global as unknown as {fetch: typeof fetch}).fetch = jest.fn(
    impl as unknown as typeof fetch
  ) as unknown as typeof fetch;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {"content-type": "application/json"},
  });
}

function anthropicTextResponse(text: string, status = 200): Response {
  return jsonResponse(
    {
      content: [{type: "text", text}],
      usage: {input_tokens: 12, output_tokens: 7},
    },
    status
  );
}

function azureTextResponse(text: string, status = 200): Response {
  return jsonResponse(
    {
      choices: [{message: {content: text}}],
      usage: {prompt_tokens: 5, completion_tokens: 3},
    },
    status
  );
}

const baseReq: LlmRequest = {
  messages: [{role: "user", content: "Summarise the session"}],
};

describe("AnthropicProvider", () => {
  it("invokes /v1/messages with x-api-key + claude headers", async () => {
    mockFetch(async (url, init) => {
      expect(url).toBe("https://api.anthropic.com/v1/messages");
      expect((init.headers as Record<string, string>)["x-api-key"]).toBe("sk-x");
      const body = JSON.parse(init.body as string);
      expect(body.messages).toEqual(baseReq.messages);
      return anthropicTextResponse("summary");
    });
    const p = new AnthropicProvider("sk-x");
    const r = await p.invoke(baseReq);
    expect(r.text).toBe("summary");
    expect(r.provider).toBe("anthropic");
    expect(r.inputTokens).toBe(12);
    expect(r.outputTokens).toBe(7);
  });

  it("throws missing_credentials when api key absent", async () => {
    const p = new AnthropicProvider(undefined);
    expect(p.configured).toBe(false);
    await expect(p.invoke(baseReq)).rejects.toMatchObject({
      reason: "missing_credentials",
    });
  });

  it("throws upstream_5xx on a 503 + preserves status", async () => {
    mockFetch(async () => new Response("down", {status: 503}));
    const p = new AnthropicProvider("sk-x");
    await expect(p.invoke(baseReq)).rejects.toMatchObject({
      reason: "upstream_5xx",
      statusCode: 503,
    });
  });

  it("throws malformed_response when content array is empty", async () => {
    mockFetch(async () => jsonResponse({content: []}));
    const p = new AnthropicProvider("sk-x");
    await expect(p.invoke(baseReq)).rejects.toMatchObject({
      reason: "malformed_response",
    });
  });
});

describe("AzureOpenAIProvider", () => {
  it("adapts messages + system prompt to chat/completions shape", async () => {
    mockFetch(async (url, init) => {
      expect(url).toContain("/openai/deployments/dep-1/chat/completions");
      const body = JSON.parse(init.body as string);
      expect(body.messages[0]).toEqual({role: "system", content: "be safe"});
      expect(body.messages[1].role).toBe("user");
      return azureTextResponse("azure summary");
    });
    const p = new AzureOpenAIProvider(
      "https://az.example.com",
      "az-key",
      "dep-1"
    );
    const r = await p.invoke({...baseReq, system: "be safe"});
    expect(r.text).toBe("azure summary");
    expect(r.provider).toBe("azure_openai");
    expect(r.model).toBe("dep-1");
    expect(r.inputTokens).toBe(5);
    expect(r.outputTokens).toBe(3);
  });

  it("is not configured when any env var is missing", () => {
    expect(
      new AzureOpenAIProvider(undefined, "k", "d").configured
    ).toBe(false);
    expect(
      new AzureOpenAIProvider("e", undefined, "d").configured
    ).toBe(false);
    expect(
      new AzureOpenAIProvider("e", "k", undefined).configured
    ).toBe(false);
  });
});

describe("invokeWithFallback", () => {
  function p(id: string, opts: {
    configured: boolean;
    response?: string;
    throwReason?: LlmProviderError["reason"];
  }): LlmProvider {
    return {
      id,
      configured: opts.configured,
      invoke: async () => {
        if (opts.throwReason) {
          throw new LlmProviderError(opts.throwReason, `${id} failed`);
        }
        return {
          text: opts.response ?? "",
          provider: id,
          model: "m",
        };
      },
    };
  }

  it("uses the first configured provider that succeeds", async () => {
    const r = await invokeWithFallback(
      [
        p("primary", {configured: true, response: "ok-primary"}),
        p("secondary", {configured: true, response: "ok-secondary"}),
      ],
      baseReq
    );
    expect(r.provider).toBe("primary");
    expect(r.text).toBe("ok-primary");
  });

  it("falls over to the secondary when primary throws upstream error", async () => {
    const r = await invokeWithFallback(
      [
        p("primary", {configured: true, throwReason: "upstream_5xx"}),
        p("secondary", {configured: true, response: "from-secondary"}),
      ],
      baseReq
    );
    expect(r.provider).toBe("secondary");
    expect(r.text).toBe("from-secondary");
  });

  it("skips unconfigured providers without raising", async () => {
    const r = await invokeWithFallback(
      [
        p("primary", {configured: false}),
        p("secondary", {configured: true, response: "took-secondary"}),
      ],
      baseReq
    );
    expect(r.provider).toBe("secondary");
  });

  it("rethrows the last error when every provider fails", async () => {
    await expect(
      invokeWithFallback(
        [
          p("primary", {configured: true, throwReason: "upstream_5xx"}),
          p("secondary", {configured: true, throwReason: "upstream_4xx"}),
        ],
        baseReq
      )
    ).rejects.toMatchObject({reason: "upstream_4xx"});
  });

  it("throws missing_credentials when nobody is configured", async () => {
    await expect(
      invokeWithFallback(
        [p("a", {configured: false}), p("b", {configured: false})],
        baseReq
      )
    ).rejects.toMatchObject({reason: "missing_credentials"});
  });

  it("falls over on rate_limited (429) so Gemini can pick up", async () => {
    const r = await invokeWithFallback(
      [
        p("groq", {configured: true, throwReason: "rate_limited"}),
        p("gemini", {configured: true, response: "picked-up-by-gemini"}),
      ],
      baseReq
    );
    expect(r.provider).toBe("gemini");
    expect(r.text).toBe("picked-up-by-gemini");
  });

  it("falls over on timeout so the next provider gets a shot", async () => {
    const r = await invokeWithFallback(
      [
        p("groq", {configured: true, throwReason: "timeout"}),
        p("gemini", {configured: true, response: "gemini-after-timeout"}),
      ],
      baseReq
    );
    expect(r.provider).toBe("gemini");
  });
});

describe("classifyStatus", () => {
  it("maps 429 to rate_limited so ops can distinguish it from other 4xx", () => {
    expect(classifyStatus(429)).toBe("rate_limited");
  });

  it("keeps other 4xx as upstream_4xx", () => {
    expect(classifyStatus(400)).toBe("upstream_4xx");
    expect(classifyStatus(401)).toBe("upstream_4xx");
    expect(classifyStatus(403)).toBe("upstream_4xx");
    expect(classifyStatus(404)).toBe("upstream_4xx");
  });

  it("keeps 5xx as upstream_5xx", () => {
    expect(classifyStatus(500)).toBe("upstream_5xx");
    expect(classifyStatus(502)).toBe("upstream_5xx");
    expect(classifyStatus(503)).toBe("upstream_5xx");
  });
});

describe("fetchWithTimeout", () => {
  it("returns the response when the fetch resolves before the deadline", async () => {
    mockFetch(async () => new Response("ok", {status: 200}));
    const r = await fetchWithTimeout(
      "https://example.com",
      {method: "GET"},
      1000,
      "test-provider"
    );
    expect(r.status).toBe(200);
  });

  it(
    "throws LlmProviderError with reason 'timeout' when the deadline hits",
    async () => {
      // Simulate a hung fetch that resolves only after the timeout —
      // AbortController.abort() will cause the fetch to reject with an
      // AbortError, which fetchWithTimeout rewrites as timeout.
      mockFetch(
        (_url, init) =>
          new Promise((_resolve, reject) => {
            const signal = init.signal as AbortSignal | undefined;
            signal?.addEventListener("abort", () =>
              reject(new DOMException("aborted", "AbortError"))
            );
          })
      );
      await expect(
        fetchWithTimeout(
          "https://example.com",
          {method: "GET"},
          20,
          "groq"
        )
      ).rejects.toMatchObject({
        reason: "timeout",
        message: expect.stringContaining("groq"),
      });
    },
    5000
  );
});

describe("AnthropicProvider — 429 classification", () => {
  it("throws rate_limited for a 429 response", async () => {
    mockFetch(async () => new Response("slow down", {status: 429}));
    const p = new AnthropicProvider("sk-x");
    await expect(p.invoke(baseReq)).rejects.toMatchObject({
      reason: "rate_limited",
      statusCode: 429,
    });
  });
});
