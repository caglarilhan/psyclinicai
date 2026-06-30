/**
 * `mbcDispatchLink` — clinician-only POST that mints a token-signed
 * URL the patient can use (no login) to submit one MBC assessment.
 * PILAR 2 / PR-2.
 *
 * Flow:
 *   1. Clinician posts {tenantId, patientId, scaleId, channel}.
 *   2. We look up the catalog rule, generate a 32-byte random token,
 *      write `mbc_dispatch/{auto}` with sha256(token) + expiry, and
 *      return `{ token, expiresAt, formUrl }` so the front-end can
 *      hand the link to the patient (or the channel adapter later).
 *
 * Safety posture:
 *   - Clinician-only auth (`authorizeClinicianUid`).
 *   - Consent gate when patientId is present.
 *   - N24 security headers + N25 rate limit (clinician-dashboard-read).
 *   - Token is **never** stored in the clear — only its sha256 — so a
 *     Firestore leak does not expose live links.
 *   - Token is 32 bytes (256 bits) of CSPRNG entropy; brute-forcing a
 *     single live link within its 72-hour lifetime is computationally
 *     infeasible.
 *   - Expiry is derived from the catalog `linkLifetimeHours`.
 */
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as functions from "firebase-functions";

import {applyCors, authorizeClinicianUid} from "./lib/auth";
import {checkAiConsent, extractPatientId} from "./lib/consent_gate";
import {
  mbcRuleByScaleId,
  tokenExpiryMillis,
  DispatchChannel,
} from "./lib/mbc_dispatch_catalog";
import {applyRateLimit, applySecurityHeaders} from "./lib/security_chain";

interface DispatchBody {
  tenantId: string;
  patientId: string;
  scaleId: string;
  channel?: DispatchChannel;
}

const PUBLIC_FORM_BASE =
  process.env.MBC_PUBLIC_FORM_BASE ??
  "https://psyclinicai.com/p/mbc";

/** Mint 32 bytes of CSPRNG entropy as a URL-safe base64 string. */
export function mintRawToken(): string {
  return crypto
    .randomBytes(32)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

export function hashToken(raw: string): string {
  return crypto.createHash("sha256").update(raw).digest("hex");
}

export function formUrlFor(token: string): string {
  return `${PUBLIC_FORM_BASE}/${token}`;
}

export const mbcDispatchLink = functions
  .runWith({memory: "256MB", timeoutSeconds: 30})
  .region("europe-west1")
  .https.onRequest(async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (applyRateLimit(req, res, "clinician-dashboard-read")) return;
    if (req.method !== "POST") {
      res.status(405).json({error: "post_only"});
      return;
    }

    const uid = await authorizeClinicianUid(req, "mbcDispatchLink");
    if (!uid) {
      res.status(401).json({error: "unauthorized"});
      return;
    }

    let body: DispatchBody;
    try {
      body = req.body as DispatchBody;
      if (
        !body ||
        typeof body.tenantId !== "string" ||
        typeof body.patientId !== "string" ||
        typeof body.scaleId !== "string"
      ) {
        throw new Error("missing tenantId / patientId / scaleId");
      }
    } catch (e) {
      res.status(400).json({error: "bad_request", detail: String(e)});
      return;
    }

    let rule;
    try {
      rule = mbcRuleByScaleId(body.scaleId);
    } catch (e) {
      res.status(400).json({error: "unknown_scale", scaleId: body.scaleId});
      return;
    }
    if (!rule.publicSubmit) {
      res.status(400).json({error: "scale_not_public_submittable"});
      return;
    }
    const channel = body.channel ?? rule.channels[0];
    if (!rule.channels.includes(channel)) {
      res.status(400).json({
        error: "channel_not_allowed",
        allowed: rule.channels,
      });
      return;
    }

    const db = admin.firestore();

    // Consent gate — same enforcement as llmProxy / scribe.
    const patientId = extractPatientId({patientId: body.patientId});
    if (patientId !== null) {
      const decision = await checkAiConsent({db, clinicId: uid, patientId});
      if (!decision.ok) {
        functions.logger.warn("mbcDispatchLink.consent_denied", {
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

    const token = mintRawToken();
    const tokenHash = hashToken(token);
    const dispatchedAtMillis = Date.now();
    const expiresAtMillis = tokenExpiryMillis({
      rule,
      dispatchedAtMillis,
    });

    const ref = await db.collection("mbc_dispatch").add({
      tenant_id: body.tenantId,
      clinic_id: uid,
      patient_id: body.patientId,
      scale_id: body.scaleId,
      token_hash: tokenHash,
      channel,
      dispatched_at: admin.firestore.Timestamp.fromMillis(dispatchedAtMillis),
      expires_at: admin.firestore.Timestamp.fromMillis(expiresAtMillis),
      submitted_at: null,
      reminded_at: null,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({
      dispatchId: ref.id,
      token,
      formUrl: formUrlFor(token),
      expiresAt: expiresAtMillis,
      scaleId: body.scaleId,
      channel,
    });
  });
