/**
 * `aiScribeDraftSoap` — Ambient Clinical Scribe SOAP draft generator
 * (PILAR 1 / PR-2).
 *
 * Contract:
 *   POST /aiScribeDraftSoap
 *   Headers: Authorization: Bearer <Firebase ID token>
 *   Body:    {
 *     tenantId: string,
 *     sessionId: string,
 *     transcript: string,         // raw session transcript (gets PHI-scrubbed before egress)
 *     patientId?: string,         // triggers consent gate
 *     sections?: SoapSection[],   // default = all four
 *   }
 *   Reply:   {
 *     sessionId, schemaVersion, generatedAt, provider, model,
 *     sections: { subjective: {...}, objective: {...}, ... }
 *   }
 *
 * Safety posture:
 *   - Clinician-only auth (`authorizeClinicianUid`).
 *   - Consent gate when patientId is present.
 *   - Jailbreak rejection on the transcript before paying for inference.
 *   - PHI scrubber on the transcript before egress (HIPAA §164.514(b)).
 *   - System prompt + JSON schema built server-side from
 *     `SOAP_SECTIONS` — the client cannot inject prompt overrides.
 *   - LLM provider fallback (Anthropic → Azure BAA).
 *   - Strict JSON parse; on parse failure return 502 not silent retry.
 *   - Audit row in `ai_scribe_drafts` with counts + transcript hash
 *     (no PHI bytes).
 *   - Hourly request cap (shared with llmProxy budget infra).
 *   - Output is a *draft* — the clinician edits + e-signs in the UI
 *     before it persists to the encounter (FDA CDS non-device).
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
  jsonSchemaForSection,
  SOAP_SCHEMA_VERSION,
  SOAP_SECTION_TEMPERATURE,
  SOAP_SECTIONS,
  SoapSection,
  SoapSectionSpec,
  soapSectionByName,
} from "./lib/soap_section_catalog";

interface ScribeBody {
  tenantId: string;
  sessionId: string;
  transcript: string;
  patientId?: string;
  sections?: SoapSection[];
  /**
   * Client asserts the transcript contains ONLY synthetic vignette
   * text — no PHI. When true, `invokeWithFallback` accepts non-phiSafe
   * providers (Groq / Gemini) so the free-tier demo path stays open.
   * When false (default), the chain filters down to Anthropic + Azure
   * OpenAI — the two providers we hold a BAA with.
   */
  demoMode?: boolean;
}

// Sprint 30 PILAR1 — keep transcript ingest bounded so a runaway
// recording (or a malformed paste) does not blow the LLM context
// window. Real 50-min therapy transcripts run ~5-8k chars; cap is
// 20k so an extreme session still fits but a 1MB blob is rejected.
export const MAX_TRANSCRIPT_CHARS = 20_000;

// Default hourly cap for scribe (shared with llmProxy budget infra).
const DEFAULT_HOURLY_REQUEST_CAP = 1000;

/**
 * Builds the system prompt the LLM receives. Pure function — no PHI,
 * no env reads — exported so tests can pin the prompt verbatim.
 */
export function buildSystemPrompt(sections: SoapSectionSpec[]): string {
  const sectionDescriptions = sections
    .map(
      (s) =>
        `### ${s.title}\n` +
        `Purpose: ${s.purpose}\n` +
        `Fields: ${s.fields
          .map(
            (f) =>
              `\`${f.key}\` (${f.required ? "required" : "optional"}` +
              `${f.citationRequired ? ", cite transcript spans" : ""})`,
          )
          .join(", ")}`,
    )
    .join("\n\n");

  return [
    "You are a clinical documentation assistant for licensed mental-health clinicians.",
    "",
    "Your job: draft one SOAP note from the supplied session transcript. The clinician will REVIEW, EDIT and SIGN every field before it persists. You never auto-file. You never prescribe.",
    "",
    "Output rules (HIPAA §164.526 accuracy of PHI, 21 CFR §11 records integrity):",
    "1. Return STRICT JSON only — no preamble, no markdown fences.",
    "2. Conform exactly to the JSON schema provided in the user message.",
    "3. Every citation-required field MUST attach `transcript_spans` (start_ms, end_ms) for every claim. If you cannot cite a span, leave the field empty.",
    "4. Never invent facts. If the transcript is silent on a field, set value to empty string (or empty list) — do not guess.",
    "5. Use DSM-5-TR codes + plain-language labels for Assessment.working_diagnoses.",
    "6. If the transcript contains language suggesting imminent risk (suicide, harm-to-others, abuse), reflect it in `risk_assessment` with rationale + a non-low level. Never minimise.",
    "7. Do not include any medications you would prescribe. Note only what was discussed in `medication_discussion`. The prescriber's eRx system handles prescriptions.",
    "8. Identify yourself as AI-assisted in the encounter footer is the UI's job — you do not need to add disclaimers.",
    "",
    "Sections you must populate (order, purpose, fields):",
    "",
    sectionDescriptions,
    "",
    "Return: one JSON object with keys `subjective`, `objective`, `assessment`, `plan` (only the keys the schema asks for).",
  ].join("\n");
}

/**
 * Composite JSON schema for the requested sections. Pure function.
 */
export function buildCompositeSchema(
  sections: SoapSectionSpec[],
): Record<string, unknown> {
  const properties: Record<string, unknown> = {};
  const required: string[] = [];
  for (const spec of sections) {
    properties[spec.section] = jsonSchemaForSection(spec);
    required.push(spec.section);
  }
  return {
    type: "object",
    properties,
    required,
    additionalProperties: false,
  };
}

function highestTemperature(sections: SoapSectionSpec[]): number {
  let t = 0;
  for (const s of sections) {
    const v = SOAP_SECTION_TEMPERATURE[s.section];
    if (v > t) t = v;
  }
  return t;
}

function sumMaxOutputTokens(sections: SoapSectionSpec[]): number {
  let sum = 0;
  for (const s of sections) sum += s.maxOutputTokens;
  return sum + 400; // citation overhead per section
}

/** Pulls the strict JSON the LLM was asked to emit. */
export function extractJson(text: string): unknown {
  // Models occasionally wrap JSON in ```json ... ``` fences despite
  // being told not to. Strip the most common fence forms before parse.
  const stripped = text
    .replace(/^\s*```(?:json)?\s*/i, "")
    .replace(/\s*```\s*$/i, "")
    .trim();
  return JSON.parse(stripped);
}

function sha256Hex(input: string): string {
  return crypto.createHash("sha256").update(input).digest("hex");
}

/**
 * Default provider chain. Reads env via `process.env` directly because
 * the `env` proxy throws on missing keys + the Azure trio is intentionally
 * optional (BAA fallback only kicks in when configured).
 */
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

/** Test seam — swap the provider chain in unit tests. */
export function setProviderChainFactoryForTest(
  factory: () => LlmProvider[],
): void {
  _providerChainFactory = factory;
}
export function resetProviderChainFactoryForTest(): void {
  _providerChainFactory = defaultProviderChain;
}

export const aiScribeDraftSoap = functions
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

    const uid = await authorizeClinicianUid(req, "aiScribeDraftSoap");
    if (!uid) {
      res.status(401).json({error: "unauthorized"});
      return;
    }

    let body: ScribeBody;
    try {
      body = req.body as ScribeBody;
      if (
        !body ||
        typeof body.tenantId !== "string" ||
        typeof body.sessionId !== "string" ||
        typeof body.transcript !== "string" ||
        body.transcript.trim().length === 0
      ) {
        throw new Error("missing tenantId / sessionId / transcript");
      }
    } catch (e) {
      res.status(400).json({error: "bad_request", detail: String(e)});
      return;
    }

    if (body.transcript.length > MAX_TRANSCRIPT_CHARS) {
      res.status(413).json({
        error: "transcript_too_long",
        max: MAX_TRANSCRIPT_CHARS,
        got: body.transcript.length,
      });
      return;
    }

    const requestedSections: SoapSectionSpec[] =
      Array.isArray(body.sections) && body.sections.length > 0
        ? body.sections.map((s) => soapSectionByName(s))
        : [...SOAP_SECTIONS];

    const db = admin.firestore();

    // Consent gate — same enforcement as llmProxy / anthropicRelay.
    const patientId = extractPatientId(body);
    if (patientId !== null) {
      const decision = await checkAiConsent({db, clinicId: uid, patientId});
      if (!decision.ok) {
        functions.logger.warn("aiScribeDraftSoap.consent_denied", {
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

    // Jailbreak reject on the transcript so an attacker recording a
    // prompt-injection monologue cannot redirect the model.
    const hit = detectJailbreak(body.transcript);
    if (hit) {
      functions.logger.warn("aiScribeDraftSoap.jailbreak_blocked", {
        tenant: body.tenantId,
        uid,
        pattern: hit.source.slice(0, 80),
      });
      res.status(400).json({error: "jailbreak_blocked"});
      return;
    }

    // Hourly request budget (shared with llmProxy ledger).
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

    // PHI scrub the transcript before it leaves the perimeter.
    const scrub = scrubPhiInString(body.transcript);

    const schema = buildCompositeSchema(requestedSections);
    const system = buildSystemPrompt(requestedSections);
    const userPrompt = [
      "SCHEMA:",
      JSON.stringify(schema),
      "",
      "TRANSCRIPT:",
      scrub.text,
    ].join("\n");

    let llmResp;
    try {
      // Runtime PHI gate — real transcripts (demoMode !== true) skip
      // Groq/Gemini via the phiSafe filter so PHI never crosses to a
      // vendor we do NOT hold a BAA with. Demo-mode requests keep the
      // free-tier chain intact.
      llmResp = await invokeWithFallback(
        _providerChainFactory(),
        {
          system,
          maxTokens: sumMaxOutputTokens(requestedSections),
          temperature: highestTemperature(requestedSections),
          messages: [{role: "user", content: userPrompt}],
        },
        {requireBaa: body.demoMode !== true},
      );
    } catch (e) {
      const err = e as LlmProviderError;
      functions.logger.error("aiScribeDraftSoap.upstream_failed", {
        reason: err.reason,
        status: err.statusCode,
      });
      res.status(502).json({
        error: "upstream_failed",
        reason: err.reason,
      });
      return;
    }

    let parsed: Record<string, unknown>;
    try {
      parsed = extractJson(llmResp.text) as Record<string, unknown>;
    } catch (e) {
      functions.logger.error("aiScribeDraftSoap.parse_failed", {
        error: String(e),
        preview: llmResp.text.slice(0, 200),
      });
      res.status(502).json({error: "draft_parse_failed"});
      return;
    }

    const generatedAt = admin.firestore.Timestamp.now();
    const transcriptHash = sha256Hex(body.transcript);

    // Audit row — counts + hashes, never the transcript or the draft bytes.
    await db.collection("ai_scribe_drafts").add({
      tenant_id: body.tenantId,
      session_id: body.sessionId,
      uid,
      patient_id: patientId,
      schema_version: SOAP_SCHEMA_VERSION,
      provider: llmResp.provider,
      model: llmResp.model,
      input_tokens: llmResp.inputTokens ?? 0,
      output_tokens: llmResp.outputTokens ?? 0,
      transcript_char_count: body.transcript.length,
      transcript_sha256: transcriptHash,
      phi_redactions: scrub.totalRemoved,
      sections_generated: requestedSections.map((s) => s.section),
      hour_bucket: hourBucket(new Date()),
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      sessionId: body.sessionId,
      schemaVersion: SOAP_SCHEMA_VERSION,
      generatedAt: generatedAt.toMillis(),
      provider: llmResp.provider,
      model: llmResp.model,
      sections: parsed,
      phiRedactions: scrub.totalRemoved,
    });
  });
