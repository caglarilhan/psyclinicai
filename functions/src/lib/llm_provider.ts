/**
 * LLM provider strategy (audit 2026-06-21, M2/M3 deliverable).
 *
 * The audit flagged that we have one provider (Anthropic) on a single
 * BYOK key. When Anthropic is unreachable or the proxy key is paused,
 * every copilot path goes silent — patient-safety-impacting for the
 * Tier-2 risk classifier and clinician-experience-impacting for the
 * SOAP generator. This strategy lets the relay try multiple providers
 * in order with consistent input/output contracts.
 *
 * Today's wiring (M3 ship): Anthropic primary, Azure OpenAI BAA
 * fallback when `AZURE_OPENAI_*` env vars are set. The strategy is
 * structured so additional providers (Bedrock Claude, on-prem Llama)
 * can land without touching the call sites.
 *
 * The contract intentionally keeps the request shape close to
 * Anthropic's `messages` API so the existing Dart prompts do not
 * have to be rewritten per provider. Azure provider adapts internally.
 */
import * as functions from "firebase-functions";

export interface LlmMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

export interface LlmRequest {
  model?: string;
  maxTokens?: number;
  temperature?: number;
  system?: string;
  messages: LlmMessage[];
}

export interface LlmResponse {
  text: string;
  provider: string;
  model: string;
  inputTokens?: number;
  outputTokens?: number;
}

export type LlmFailureReason =
  | "missing_credentials"
  | "upstream_unreachable"
  | "upstream_4xx"
  | "upstream_5xx"
  | "malformed_response";

export class LlmProviderError extends Error {
  constructor(
    public reason: LlmFailureReason,
    message: string,
    public statusCode?: number
  ) {
    super(message);
    this.name = "LlmProviderError";
  }
}

export interface LlmProvider {
  /** Stable wire name. Logged + returned in [LlmResponse.provider]. */
  readonly id: string;

  /** True when the provider's required credentials are present. */
  readonly configured: boolean;

  /**
   * Invoke the model. Throw [LlmProviderError] on any failure so the
   * strategy below can decide whether to fall over to the next
   * provider or bubble the error.
   */
  invoke(req: LlmRequest): Promise<LlmResponse>;
}

/**
 * Anthropic Claude provider. Reads `ANTHROPIC_PROXY_API_KEY` from env.
 * Used by `anthropicRelay` + `llmProxy`.
 */
export class AnthropicProvider implements LlmProvider {
  readonly id = "anthropic";

  constructor(private readonly apiKey: string | undefined) {}

  get configured(): boolean {
    return !!this.apiKey;
  }

  async invoke(req: LlmRequest): Promise<LlmResponse> {
    if (!this.apiKey) {
      throw new LlmProviderError(
        "missing_credentials",
        "ANTHROPIC_PROXY_API_KEY not set"
      );
    }
    const model = req.model ?? "claude-haiku-4-5";
    let resp: Response;
    try {
      resp = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-api-key": this.apiKey,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model,
          max_tokens: req.maxTokens ?? 1024,
          temperature: req.temperature ?? 0.2,
          ...(req.system ? {system: req.system} : {}),
          messages: req.messages,
        }),
      });
    } catch (e) {
      throw new LlmProviderError(
        "upstream_unreachable",
        `Anthropic fetch failed: ${String(e)}`
      );
    }
    if (!resp.ok) {
      const body = await resp.text();
      throw new LlmProviderError(
        resp.status >= 500 ? "upstream_5xx" : "upstream_4xx",
        `Anthropic ${resp.status}: ${body.slice(0, 200)}`,
        resp.status
      );
    }
    const payload = (await resp.json()) as Record<string, unknown>;
    const contentArr = Array.isArray(payload.content) ?
      (payload.content as Array<Record<string, unknown>>) :
      [];
    const textBlock = contentArr.find((c) => c.type === "text");
    const text = ((textBlock as {text?: string} | undefined)?.text ?? "").trim();
    if (!text) {
      throw new LlmProviderError(
        "malformed_response",
        "Anthropic returned empty content"
      );
    }
    const usage = (payload.usage as {
      input_tokens?: number;
      output_tokens?: number;
    } | undefined) || {};
    return {
      text,
      provider: this.id,
      model,
      inputTokens: usage.input_tokens,
      outputTokens: usage.output_tokens,
    };
  }
}

/**
 * Azure OpenAI provider. Reads `AZURE_OPENAI_ENDPOINT`,
 * `AZURE_OPENAI_API_KEY`, `AZURE_OPENAI_DEPLOYMENT` from env. Azure
 * signs a HIPAA BAA covering OpenAI inference, so this acts as the
 * managed-key fallback for tenants that refuse BYOK Anthropic.
 *
 * The adapter converts Anthropic's `messages` shape to OpenAI's
 * `chat/completions` shape: system prompt becomes a leading `system`
 * message; assistant + user roles map 1-to-1.
 */
export class AzureOpenAIProvider implements LlmProvider {
  readonly id = "azure_openai";

  constructor(
    private readonly endpoint: string | undefined,
    private readonly apiKey: string | undefined,
    private readonly deployment: string | undefined,
    private readonly apiVersion: string = "2024-02-15-preview"
  ) {}

  get configured(): boolean {
    return !!this.endpoint && !!this.apiKey && !!this.deployment;
  }

  async invoke(req: LlmRequest): Promise<LlmResponse> {
    if (!this.configured) {
      throw new LlmProviderError(
        "missing_credentials",
        "Azure OpenAI env vars not set"
      );
    }
    const url =
      `${this.endpoint}/openai/deployments/${this.deployment}` +
      `/chat/completions?api-version=${this.apiVersion}`;
    const messages: Array<{role: string; content: string}> = [];
    if (req.system) messages.push({role: "system", content: req.system});
    for (const m of req.messages) {
      messages.push({role: m.role, content: m.content});
    }

    let resp: Response;
    try {
      resp = await fetch(url, {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "api-key": this.apiKey!,
        },
        body: JSON.stringify({
          messages,
          max_tokens: req.maxTokens ?? 1024,
          temperature: req.temperature ?? 0.2,
        }),
      });
    } catch (e) {
      throw new LlmProviderError(
        "upstream_unreachable",
        `Azure OpenAI fetch failed: ${String(e)}`
      );
    }
    if (!resp.ok) {
      const body = await resp.text();
      throw new LlmProviderError(
        resp.status >= 500 ? "upstream_5xx" : "upstream_4xx",
        `Azure OpenAI ${resp.status}: ${body.slice(0, 200)}`,
        resp.status
      );
    }
    const payload = (await resp.json()) as {
      choices?: Array<{message?: {content?: string}}>;
      usage?: {prompt_tokens?: number; completion_tokens?: number};
    };
    const text = payload.choices?.[0]?.message?.content?.trim() ?? "";
    if (!text) {
      throw new LlmProviderError(
        "malformed_response",
        "Azure OpenAI returned empty content"
      );
    }
    return {
      text,
      provider: this.id,
      model: this.deployment!,
      inputTokens: payload.usage?.prompt_tokens,
      outputTokens: payload.usage?.completion_tokens,
    };
  }
}

/**
 * Run [req] against [providers] in order. Each provider may throw
 * [LlmProviderError]; the next configured provider gets a shot. If
 * every provider fails the last error is rethrown.
 *
 * `missing_credentials` is treated as "skip" so an unconfigured Azure
 * key does not abort the chain. Network / upstream errors trigger
 * fallover. A 4xx with body (auth, validation) also fallovers — the
 * primary may be misconfigured while the secondary is fine.
 */
export async function invokeWithFallback(
  providers: LlmProvider[],
  req: LlmRequest
): Promise<LlmResponse> {
  if (providers.length === 0) {
    throw new LlmProviderError(
      "missing_credentials",
      "no LLM providers configured"
    );
  }

  let lastError: LlmProviderError | null = null;
  for (const provider of providers) {
    if (!provider.configured) {
      functions.logger.debug("llm_provider.skipped_unconfigured", {
        provider: provider.id,
      });
      continue;
    }
    try {
      const res = await provider.invoke(req);
      if (lastError) {
        functions.logger.info("llm_provider.fellover", {
          to: provider.id,
          previous_reason: lastError.reason,
        });
      }
      return res;
    } catch (e) {
      const err = e instanceof LlmProviderError ?
        e :
        new LlmProviderError("upstream_unreachable", String(e));
      lastError = err;
      functions.logger.warn("llm_provider.failed", {
        provider: provider.id,
        reason: err.reason,
        status: err.statusCode,
      });
    }
  }
  throw lastError ?? new LlmProviderError(
    "missing_credentials",
    "all providers unconfigured"
  );
}
