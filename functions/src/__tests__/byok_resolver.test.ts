import {ByokRow, buildByokChain} from "../lib/byok_resolver";

describe("buildByokChain", () => {
  test("no BYOK keys → free-tier chain (Groq first)", () => {
    const chain = buildByokChain({});
    expect(chain.length).toBe(4);
    expect(chain[0].id).toBe("groq");
    expect(chain[1].id).toBe("gemini");
    expect(chain[2].id).toBe("anthropic");
    expect(chain[3].id).toBe("azure_openai");
  });

  test("BYOK Anthropic set → Anthropic first (BAA-bearing)", () => {
    const row: ByokRow = {anthropic_key: "sk-ant-fake"};
    const chain = buildByokChain(row);
    expect(chain[0].id).toBe("anthropic");
    expect(chain[1].id).toBe("groq");
    expect(chain[2].id).toBe("gemini");
  });

  test("BYOK Groq only → still free-tier order", () => {
    const row: ByokRow = {groq_key: "gsk_fake"};
    const chain = buildByokChain(row);
    expect(chain[0].id).toBe("groq");
    expect(chain[2].id).toBe("anthropic");
  });

  test("BYOK Anthropic + Groq → Anthropic first", () => {
    const row: ByokRow = {
      anthropic_key: "sk-ant-fake",
      groq_key: "gsk_fake",
    };
    const chain = buildByokChain(row);
    expect(chain[0].id).toBe("anthropic");
  });

  test("Anthropic key from .env (no BYOK) is honoured", () => {
    const orig = process.env.ANTHROPIC_PROXY_API_KEY;
    process.env.ANTHROPIC_PROXY_API_KEY = "sk-ant-env";
    try {
      const chain = buildByokChain({});
      expect(chain[2].id).toBe("anthropic");
      expect(chain[2].configured).toBe(true);
    } finally {
      if (orig === undefined) {
        delete process.env.ANTHROPIC_PROXY_API_KEY;
      } else {
        process.env.ANTHROPIC_PROXY_API_KEY = orig;
      }
    }
  });
});
