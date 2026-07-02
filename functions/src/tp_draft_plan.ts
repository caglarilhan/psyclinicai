/**
 * `tpDraftPlan` — Evidence-Based Treatment Plan Drafter CF
 * (PILAR 4 / PR-2).
 *
 * Contract:
 *   POST /tpDraftPlan
 *   Headers: Authorization: Bearer <Firebase ID token>
 *   Body:    {
 *     tenantId, patientId?, disorder, modality,
 *     presentingProblems: string[],   // brief clinician input
 *     extraContext?: string,           // optional history / risk notes
 *   }
 *   Reply: {
 *     schemaVersion, generatedAt, provider, model,
 *     protocolLabel, requiresSupervisorCoSign,
 *     plan: { presenting_problems, smart_goals, session_plan, ... },
 *     phiRedactions
 *   }
 *
 * Safety posture:
 *   - Clinician-only auth.
 *   - Catalog whitelist for (disorder, modality).
 *   - N24 + N25 (ai-copilot-inference).
 *   - Consent gate + jailbreak reject + PHI scrub + LLM provider fallback.
 *   - Strict JSON parse, 502 on failure.
 *   - Audit row: counts + hashes only (no PHI, no draft bytes).
 *   - Output is a *draft*; clinician + supervisor (when required)
 *     sign before persistence — FDA CDS non-device §520(o)(1)(E).
 */
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as functions from "firebase-functions";

import {applyCors, authorizeClinicianUid} from "./lib/auth";
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";
import {checkAiConsent, extractPatientId} from "./lib/consent_gate";
import {env} from "./lib/env";
import {detectJailbreak} from "./lib/llm_safety";
import {scrubPhiInString} from "./lib/phi_scrub";
import {
  AnthropicProvider,
  AzureOpenAIProvider,
  invokeWithFallback,
  LlmProvider,
  LlmProviderError,
} from "./lib/llm_provider";
import {hourBucket, reserveHourlyQuota} from "./llm_proxy";
import {
  jsonSchemaForPlan,
  TPD_SCHEMA_VERSION,
  TpDisorderId,
  TpModality,
  tpProtocolByKey,
} from "./lib/tp_drafter_catalog";

interface DraftBody {
  tenantId: string;
  patientId?: string;
  disorder: TpDisorderId;
  modality: TpModality;
  presentingProblems: string[];
  extraContext?: string;
  /**
   * Client asserts the payload contains ONLY synthetic vignette text
   * — no PHI. Default `false` filters the LLM chain to BAA-bearing
   * providers only (Anthropic + Azure). When `true`, free-tier Groq /
   * Gemini stay eligible.
   */
  demoMode?: boolean;
}

export const MAX_PROBLEMS = 12;
export const MAX_EXTRA_CONTEXT_CHARS = 2_000;
const DEFAULT_HOURLY_REQUEST_CAP = 1000;
const PLAN_MAX_OUTPUT_TOKENS = 3_000;

export function buildSystemPrompt(
  protocolLabel: string,
  guidelineAnchors: ReadonlyArray<string>,
): string {
  return [
    "You are a clinical care-planning assistant for licensed mental-health clinicians.",
    "",
    `You will draft ONE evidence-based treatment plan for: ${protocolLabel}.`,
    "",
    "Output rules (HIPAA §164.526 accuracy of PHI, 21 CFR §11 records integrity):",
    "1. Return STRICT JSON only — no preamble, no markdown fences.",
    "2. Conform exactly to the JSON schema provided in the user message.",
    "3. Every smart_goals[i].cited_guideline MUST be a verbatim string from the supplied anchor list — pick the one that best fits the goal.",
    "4. SMART goals: each goal must populate specific / measurable / achievable / relevant / time_bound — concise (one sentence each), patient-friendly.",
    "5. Session plan: emit recommendedSessions entries, indexed 1..N, each with focus + intervention list + concrete homework.",
    "6. Outcome reassessment: use the outcome instrument supplied (PHQ-9 / GAD-7 / PCL-5 / AUDIT etc.) + a cadence label.",
    "7. Risk review cadence: state plainly when the clinician should re-screen for risk (e.g. C-SSRS at every visit for PTSD).",
    "8. NEVER prescribe medication or specify dosages. Refer to the prescriber for any pharmacotherapy.",
    "9. NEVER auto-file — the clinician edits + signs before this plan persists.",
    "",
    `Guideline anchors (cite verbatim): ${guidelineAnchors.join(" | ")}`,
  ].join("\n");
}

export function extractJson(text: string): unknown {
  const stripped = text
    .replace(/^\s*```(?:json)?\s*/i, "")
    .replace(/\s*```\s*$/i, "")
    .trim();
  return JSON.parse(stripped);
}

function sha256Hex(input: string): string {
  return crypto.createHash("sha256").update(input).digest("hex");
}

export function defaultProviderChain(): LlmProvider[] {
  return [
    new AnthropicProvider(process.env.ANTHROPIC_PROXY_API_KEY),
    new AzureOpenAIProvider(
      process.env.AZURE_OPENAI_ENDPOINT,
      process.env.AZURE_OPENAI_API_KEY,
      process.env.AZURE_OPENAI_DEPLOYMENT,
    ),
  ];
}

let _providerChainFactory: () => LlmProvider[] = defaultProviderChain;

export function setProviderChainFactoryForTest(
  factory: () => LlmProvider[],
): void {
  _providerChainFactory = factory;
}
export function resetProviderChainFactoryForTest(): void {
  _providerChainFactory = defaultProviderChain;
}

export const tpDraftPlan = functions
  .runWith({minInstances: 0, memory: "1GB", timeoutSeconds: 60})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (applyRateLimit(req, res, "ai-copilot-inference")) return;
    if (req.method !== "POST") {
      res.status(405).json({error: "post_only"});
      return;
    }

    const uid = await authorizeClinicianUid(req, "tpDraftPlan");
    if (!uid) {
      res.status(401).json({error: "unauthorized"});
      return;
    }

    let body: DraftBody;
    try {
      body = req.body as DraftBody;
      if (
        !body ||
        typeof body.tenantId !== "string" ||
        typeof body.disorder !== "string" ||
        typeof body.modality !== "string" ||
        !Array.isArray(body.presentingProblems) ||
        body.presentingProblems.length === 0
      ) {
        throw new Error(
          "missing tenantId / disorder / modality / presentingProblems",
        );
      }
    } catch (e) {
      res.status(400).json({error: "bad_request", detail: String(e)});
      return;
    }
    if (body.presentingProblems.length > MAX_PROBLEMS) {
      res.status(413).json({error: "too_many_problems", max: MAX_PROBLEMS});
      return;
    }
    if (
      typeof body.extraContext === "string" &&
      body.extraContext.length > MAX_EXTRA_CONTEXT_CHARS
    ) {
      res.status(413).json({
        error: "extra_context_too_long",
        max: MAX_EXTRA_CONTEXT_CHARS,
      });
      return;
    }

    let protocol;
    try {
      protocol = tpProtocolByKey({
        disorder: body.disorder,
        modality: body.modality,
      });
    } catch {
      res.status(400).json({
        error: "unsupported_protocol",
        disorder: body.disorder,
        modality: body.modality,
      });
      return;
    }

    const db = admin.firestore();

    const patientId = extractPatientId(body);
    if (patientId !== null) {
      const decision = await checkAiConsent({db, clinicId: uid, patientId});
      if (!decision.ok) {
        functions.logger.warn("tpDraftPlan.consent_denied", {
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

    const joinedText =
      body.presentingProblems.join("\n") +
      "\n" +
      (body.extraContext ?? "");
    const hit = detectJailbreak(joinedText);
    if (hit) {
      functions.logger.warn("tpDraftPlan.jailbreak_blocked", {
        tenant: body.tenantId,
        uid,
        pattern: hit.source.slice(0, 80),
      });
      res.status(400).json({error: "jailbreak_blocked"});
      return;
    }

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

    const scrubbed = scrubPhiInString(joinedText);

    const schema = jsonSchemaForPlan();
    const system = buildSystemPrompt(
      protocol.label,
      protocol.guidelineAnchors,
    );
    const userPrompt = [
      "SCHEMA:",
      JSON.stringify(schema),
      "",
      "PROTOCOL META:",
      JSON.stringify({
        recommendedSessions: protocol.recommendedSessions,
        outcomeInstrument: protocol.outcomeInstrument,
      }),
      "",
      "PRESENTING PROBLEMS:",
      ...body.presentingProblems.map((p, i) => `${i + 1}. ${p}`),
      body.extraContext ? "\nADDITIONAL CONTEXT:\n" + scrubbed.text : "",
    ].join("\n");

    let llmResp;
    try {
      // Runtime PHI gate — real plans (demoMode !== true) skip
      // Groq/Gemini via the phiSafe filter so PHI never crosses to a
      // vendor we do NOT hold a BAA with.
      llmResp = await invokeWithFallback(
        _providerChainFactory(),
        {
          system,
          maxTokens: PLAN_MAX_OUTPUT_TOKENS,
          temperature: 0.25,
          messages: [{role: "user", content: userPrompt}],
        },
        {requireBaa: body.demoMode !== true},
      );
    } catch (e) {
      const err = e as LlmProviderError;
      functions.logger.error("tpDraftPlan.upstream_failed", {
        reason: err.reason,
        status: err.statusCode,
      });
      res.status(502).json({error: "upstream_failed", reason: err.reason});
      return;
    }

    let parsed: Record<string, unknown>;
    try {
      parsed = extractJson(llmResp.text) as Record<string, unknown>;
    } catch (e) {
      functions.logger.error("tpDraftPlan.parse_failed", {
        error: String(e),
        preview: llmResp.text.slice(0, 200),
      });
      res.status(502).json({error: "draft_parse_failed"});
      return;
    }

    const generatedAt = admin.firestore.Timestamp.now();
    const promptsHash = sha256Hex(joinedText);

    await db.collection("tp_drafted_plans").add({
      tenant_id: body.tenantId,
      clinic_id: uid,
      patient_id: patientId,
      disorder: body.disorder,
      modality: body.modality,
      schema_version: TPD_SCHEMA_VERSION,
      provider: llmResp.provider,
      model: llmResp.model,
      input_tokens: llmResp.inputTokens ?? 0,
      output_tokens: llmResp.outputTokens ?? 0,
      phi_redactions: scrubbed.totalRemoved,
      requires_co_sign: protocol.requiresSupervisorCoSign,
      presenting_problems_hash: promptsHash,
      hour_bucket: hourBucket(new Date()),
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      schemaVersion: TPD_SCHEMA_VERSION,
      generatedAt: generatedAt.toMillis(),
      provider: llmResp.provider,
      model: llmResp.model,
      protocolLabel: protocol.label,
      requiresSupervisorCoSign: protocol.requiresSupervisorCoSign,
      plan: parsed,
      phiRedactions: scrubbed.totalRemoved,
    });
  });
