/**
 * `llmProxy` — model-aware, audit-logged, cost-metered relay over
 * Anthropic. Closes the senior-security finding in rapor 12: the
 * BYOK browser-direct path is fine for self-serve but enterprise
 * tenants need server-side key custody + per-tenant cost ceilings.
 *
 * Sprint 27 / F-001 close adds three guards in front of the model:
 *  1. Jailbreak reject list — refuse before paying for inference.
 *  2. SYSTEM_FROZEN sentinel fence around the system prompt + post-
 *     response strip so a leaking sentinel never reaches the client.
 *  3. Per-tenant hourly request budget (default 1000/h) — 429 with
 *     Retry-After when the bucket is exhausted.
 *
 * Contract:
 *   POST /llmProxy
 *   Headers: Authorization: Bearer <Firebase ID token>
 *   Body:    { tenantId, model, prompt, systemPrompt?, tools?,
 *              maxTokens?, temperature? }
 *   Reply:   { text, model, inputTokens, outputTokens,
 *              tenantUsdCost, toolUse? }
 *
 * Side effects:
 *   - Writes `llm_proxy_calls/{auto}` audit doc (no PHI).
 *   - Increments `tenant_cost_ledger/{tenantId}_{yyyymm}.total_usd`.
 *   - Increments `tenant_quota/{tenantId}_{yyyymmddhh}.count`.
 *   - Refuses when the monthly USD ceiling OR the hourly request
 *     cap is exceeded.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {applyCors, authorizeUid} from "./lib/auth";
import {env} from "./lib/env";
import {
  detectJailbreak,
  fenceSystemPrompt,
  stripFence,
} from "./lib/llm_safety";

interface LlmProxyBody {
  tenantId: string;
  model: string;
  prompt: string;
  systemPrompt?: string;
  tools?: unknown;
  maxTokens?: number;
  temperature?: number;
}

const MODEL_USD_PER_5MIN: Record<string, number> = {
  "claude-haiku-4-5": 0.001,
  "claude-sonnet-4-6": 0.004,
  "claude-opus-4-7": 0.015,
};

const DEFAULT_MONTHLY_CEILING_USD = 250;
const DEFAULT_HOURLY_REQUEST_CAP = 1000;

function monthKey(d: Date): string {
  const y = d.getUTCFullYear();
  const m = (d.getUTCMonth() + 1).toString().padStart(2, "0");
  return `${y}${m}`;
}

export function hourBucket(d: Date): string {
  const y = d.getUTCFullYear();
  const m = (d.getUTCMonth() + 1).toString().padStart(2, "0");
  const day = d.getUTCDate().toString().padStart(2, "0");
  const h = d.getUTCHours().toString().padStart(2, "0");
  return `${y}${m}${day}${h}`;
}

export function secondsToNextHour(d: Date): number {
  const ms =
    (60 - d.getUTCMinutes()) * 60_000 -
    d.getUTCSeconds() * 1_000 -
    d.getUTCMilliseconds();
  return Math.max(1, Math.ceil(ms / 1_000));
}

interface QuotaResult {
  ok: boolean;
  retryAfter: number;
  used: number;
  cap: number;
}

/**
 * Atomic check-and-increment of the hourly request bucket. Returns
 * `ok: false` when the increment would push the count above `cap`.
 * Exposed for unit tests.
 */
export async function reserveHourlyQuota(
  db: admin.firestore.Firestore,
  tenantId: string,
  cap: number,
  now: Date,
): Promise<QuotaResult> {
  const bucket = hourBucket(now);
  const ref = db.collection("tenant_quota").doc(`${tenantId}_${bucket}`);
  const retryAfter = secondsToNextHour(now);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const used = (snap.exists ? snap.data()?.count : 0) ?? 0;
    if (used + 1 > cap) {
      return {ok: false, retryAfter, used, cap};
    }
    tx.set(
      ref,
      {
        tenant_id: tenantId,
        bucket,
        count: admin.firestore.FieldValue.increment(1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    return {ok: true, retryAfter, used: used + 1, cap};
  });
}

export const llmProxy = functions.https.onRequest(async (req, res) => {
  if (applyCors(req, res)) return;
  const uid = await authorizeUid(req, "llmProxy");
  if (!uid) {
    res.status(401).json({error: "unauthorized"});
    return;
  }

  let body: LlmProxyBody;
  try {
    body = req.body as LlmProxyBody;
    if (!body || typeof body.tenantId !== "string" ||
        typeof body.model !== "string" ||
        typeof body.prompt !== "string") {
      throw new Error("missing fields");
    }
  } catch (e) {
    res.status(400).json({error: "bad_request", detail: String(e)});
    return;
  }

  // F-001 guard #1: jailbreak reject — refuse before paying for the model.
  const hit = detectJailbreak(body.prompt) ??
    (body.systemPrompt ? detectJailbreak(body.systemPrompt) : null);
  if (hit) {
    functions.logger.warn("llmProxy.jailbreak_blocked", {
      tenant: body.tenantId,
      uid,
      pattern: hit.source.slice(0, 80),
    });
    res.status(400).json({error: "jailbreak_blocked"});
    return;
  }

  const cost = MODEL_USD_PER_5MIN[body.model];
  if (cost === undefined) {
    res.status(400).json({error: "unknown_model", model: body.model});
    return;
  }

  const db = admin.firestore();

  // F-001 guard #2: per-tenant hourly request cap.
  const hourlyCap = Number(
    env.LLM_PROXY_HOURLY_QUOTA || DEFAULT_HOURLY_REQUEST_CAP,
  );
  const quota = await reserveHourlyQuota(
    db,
    body.tenantId,
    hourlyCap,
    new Date(),
  );
  if (!quota.ok) {
    res.set("Retry-After", String(quota.retryAfter));
    res.status(429).json({
      error: "hourly_quota_exceeded",
      used: quota.used,
      cap: quota.cap,
      retry_after_seconds: quota.retryAfter,
    });
    return;
  }

  const ledgerRef = db
    .collection("tenant_cost_ledger")
    .doc(`${body.tenantId}_${monthKey(new Date())}`);

  const cap = Number(
    env.LLM_PROXY_MONTHLY_CEILING_USD || DEFAULT_MONTHLY_CEILING_USD,
  );

  const ledger = await ledgerRef.get();
  const used = (ledger.exists ? ledger.data()?.total_usd : 0) ?? 0;
  if (used + cost > cap) {
    res.status(402).json({
      error: "monthly_ceiling_exceeded",
      used,
      cap,
    });
    return;
  }

  const apiKey = env.ANTHROPIC_PROXY_API_KEY;
  if (!apiKey) {
    res.status(500).json({error: "proxy_misconfigured"});
    return;
  }

  // F-001 guard #3: wrap the system prompt in the SYSTEM_FROZEN fence
  // so the model is told the instructions are invisible/non-echoable.
  const fencedSystem = body.systemPrompt
    ? fenceSystemPrompt(body.systemPrompt)
    : undefined;

  let upstream;
  try {
    upstream = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: body.model,
        max_tokens: body.maxTokens ?? 1024,
        temperature: body.temperature ?? 0.2,
        ...(fencedSystem ? {system: fencedSystem} : {}),
        messages: [{role: "user", content: body.prompt}],
        ...(body.tools ? {tools: body.tools} : {}),
      }),
    });
  } catch (e) {
    functions.logger.error("llmProxy.upstream_unreachable", {
      error: String(e),
    });
    res.status(502).json({error: "upstream_unreachable"});
    return;
  }

  if (!upstream.ok) {
    const txt = await upstream.text();
    functions.logger.error("llmProxy.upstream_failed", {
      status: upstream.status,
      tenant: body.tenantId,
    });
    res.status(502).json({
      error: "upstream_failed",
      status: upstream.status,
      detail: txt.slice(0, 200),
    });
    return;
  }

  const payload = (await upstream.json()) as Record<string, unknown>;
  const usage =
    (payload.usage as {input_tokens?: number; output_tokens?: number} |
      undefined) || {};
  const contentArr = Array.isArray(payload.content) ?
    (payload.content as Array<Record<string, unknown>>) :
    [];
  const textBlock = contentArr.find((c) => c.type === "text");
  const rawText = (textBlock as {text?: string} | undefined)?.text ?? "";
  const text = stripFence(rawText);
  const toolUse = contentArr.find((c) => c.type === "tool_use");

  await ledgerRef.set(
    {
      tenant_id: body.tenantId,
      month: monthKey(new Date()),
      total_usd: admin.firestore.FieldValue.increment(cost),
      call_count: admin.firestore.FieldValue.increment(1),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true},
  );

  await db.collection("llm_proxy_calls").add({
    tenant_id: body.tenantId,
    uid,
    model: body.model,
    input_tokens: usage.input_tokens ?? 0,
    output_tokens: usage.output_tokens ?? 0,
    cost_usd: cost,
    has_tool_use: Boolean(toolUse),
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({
    text,
    model: body.model,
    inputTokens: usage.input_tokens ?? 0,
    outputTokens: usage.output_tokens ?? 0,
    tenantUsdCost: cost,
    ...(toolUse ?
      {toolUse: (toolUse as {input?: unknown}).input} :
      {}),
  });
});
