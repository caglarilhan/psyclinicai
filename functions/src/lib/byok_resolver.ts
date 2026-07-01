/**
 * BYOK ("Bring Your Own Key") resolver — Sprint 31 PR-C.
 *
 * Reads the calling clinician's per-user LLM keys from Firestore at
 * `clinicians/{uid}/api_keys/llm` and returns an LLM provider chain
 * that **prefers the user's keys** over the platform defaults from
 * `.env`.
 *
 * Logging posture: never log the raw key. Logs carry only an
 * `isSet` boolean + the last 4 chars for audit correlation.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {
  AnthropicProvider,
  AzureOpenAIProvider,
  GeminiProvider,
  GroqProvider,
  LlmProvider,
} from "./llm_provider";

export interface ByokRow {
  anthropic_key?: string;
  groq_key?: string;
  gemini_key?: string;
}

/**
 * Loads the BYOK row for [uid]. Returns an empty object when none is
 * stored. Pure for unit tests.
 */
export async function loadByokKeys(
  db: admin.firestore.Firestore,
  uid: string,
): Promise<ByokRow> {
  const snap = await db
    .collection("clinicians")
    .doc(uid)
    .collection("api_keys")
    .doc("llm")
    .get();
  if (!snap.exists) return {};
  const data = snap.data() ?? {};
  return {
    anthropic_key: typeof data["anthropic_key"] === "string"
      ? data["anthropic_key"]
      : undefined,
    groq_key: typeof data["groq_key"] === "string"
      ? data["groq_key"]
      : undefined,
    gemini_key: typeof data["gemini_key"] === "string"
      ? data["gemini_key"]
      : undefined,
  };
}

function maskedTail(key: string | undefined): string | undefined {
  if (!key || key.length < 4) return undefined;
  return key.slice(-4);
}

/**
 * Builds the LLM provider chain with BYOK precedence:
 *   - If the user pasted an Anthropic key → Anthropic FIRST (BAA-bearing).
 *   - Otherwise → Groq first (free demo tier).
 */
export function buildByokChain(byok: ByokRow): LlmProvider[] {
  const anthropic =
    byok.anthropic_key || process.env.ANTHROPIC_PROXY_API_KEY;
  const groq = byok.groq_key || process.env.GROQ_API_KEY;
  const gemini = byok.gemini_key || process.env.GEMINI_API_KEY;
  const azure = new AzureOpenAIProvider(
    process.env.AZURE_OPENAI_ENDPOINT,
    process.env.AZURE_OPENAI_API_KEY,
    process.env.AZURE_OPENAI_DEPLOYMENT,
  );

  if (byok.anthropic_key) {
    return [
      new AnthropicProvider(anthropic),
      new GroqProvider(groq),
      new GeminiProvider(gemini),
      azure,
    ];
  }
  return [
    new GroqProvider(groq),
    new GeminiProvider(gemini),
    new AnthropicProvider(anthropic),
    azure,
  ];
}

/**
 * Convenience: resolve the chain for a clinician + log a no-PHI
 * status line so the operator can see at a glance whether the
 * handler used BYOK or fell back to platform defaults.
 */
export async function resolveProviderChainForUser(
  db: admin.firestore.Firestore,
  uid: string,
  handlerName: string,
): Promise<LlmProvider[]> {
  const byok = await loadByokKeys(db, uid);
  functions.logger.info("byok.resolved", {
    handler: handlerName,
    uid,
    anthropic_set: !!byok.anthropic_key,
    anthropic_tail: maskedTail(byok.anthropic_key),
    groq_set: !!byok.groq_key,
    gemini_set: !!byok.gemini_key,
  });
  return buildByokChain(byok);
}
