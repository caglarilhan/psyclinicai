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
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";
import {checkAiConsent, extractPatientId} from "./lib/consent_gate";
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
  // M-2 (audit 2026-06-21) — optional PHI patient pointer. Present when
  // the prompt is bound to a real patient (note, plan, copilot reply).
  // Triggers the server-side consent gate before the model is invoked.
  patientId?: string;
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

interface CeilingReservation {
  ok: boolean;
  used: number;
  cap: number;
}

/**
 * M-3 fix (audit 2026-06-21): the monthly USD ceiling was previously
 * read with `ledger.get()` and then mutated separately, so two
 * concurrent requests near the cap could both pass the check and both
 * push the ledger past the cap. This helper runs the check + reserve
 * in a single Firestore transaction so the total never exceeds [cap].
 *
 * Returns `ok: false` (with the current `used`) when the reservation
 * would breach the cap; callers must then return 402 to the client.
 * Exposed for unit tests.
 */
export async function reserveMonthlyCeiling(
  db: admin.firestore.Firestore,
  tenantId: string,
  cost: number,
  cap: number,
  now: Date,
): Promise<CeilingReservation> {
  const month = monthKey(now);
  const ref = db.collection("tenant_cost_ledger").doc(`${tenantId}_${month}`);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const used = (snap.exists ? snap.data()?.total_usd : 0) ?? 0;
    if (used + cost > cap) {
      return {ok: false, used, cap};
    }
    tx.set(
      ref,
      {
        tenant_id: tenantId,
        month,
        total_usd: admin.firestore.FieldValue.increment(cost),
        call_count: admin.firestore.FieldValue.increment(1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
    );
    return {ok: true, used: used + cost, cap};
  });
}

// Sprint 29 D-10 — minInstances=1 + EU region (cold-start UX + EU
// residency for LLM proxy). 1024 MB because Anthropic SDK + audit
// chain hashing peaks ~600 MB on a busy session.
export const llmProxy = functions
  .runWith({minInstances: 1, memory: "1GB", timeoutSeconds: 60})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
  applySecurityHeaders(res);
  if (applyCors(req, res)) return;
  if (applyRateLimit(req, res, "ai-copilot-inference")) return;
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

  const db = admin.firestore();

  // M-2 (audit 2026-06-21) — consent gate. When the caller binds the
  // prompt to a patient we MUST have a non-withdrawn consent_records
  // row with aiAssistanceConsent == true before any model invocation.
  // Calls without a patient (e.g. generic template drafts) pass through
  // because the UI surface guards those upstream. Same enforcement as
  // anthropicRelay (index.ts:220) so the two LLM paths stay equivalent.
  const patientId = extractPatientId(body);
  if (patientId !== null) {
    const decision = await checkAiConsent({db, clinicId: uid, patientId});
    if (!decision.ok) {
      functions.logger.warn("llmProxy.consent_denied", {
        uid,
        reason: decision.reason,
      });
      res.status(403).json({
        error: "consent_required",
        reason: decision.reason,
      });
      return;
    }
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

  const cap = Number(
    env.LLM_PROXY_MONTHLY_CEILING_USD || DEFAULT_MONTHLY_CEILING_USD,
  );

  // M-3 fix (audit 2026-06-21): atomic check-and-reserve so two
  // concurrent calls near the cap cannot both pass and breach it.
  const reservation = await reserveMonthlyCeiling(
    db,
    body.tenantId,
    cost,
    cap,
    new Date(),
  );
  if (!reservation.ok) {
    res.status(402).json({
      error: "monthly_ceiling_exceeded",
      used: reservation.used,
      cap: reservation.cap,
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

  // M-3 fix: ledger was already incremented inside reserveMonthlyCeiling
  // above (atomic check + reserve). The double-write that used to live
  // here would push the total past the cap whenever the cap check was
  // borderline. Telemetry row below is the per-call audit trail.

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
