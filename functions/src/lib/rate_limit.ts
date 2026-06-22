/**
 * Sprint 29 S-01 (F-004 close) — per-IP rate limit primitive backed by
 * Firestore. Keeps a sliding 15-minute bucket per IP and lets callers
 * cap themselves at N requests / window.
 *
 * The bucket key hashes the IP with a server-side salt so Firestore is
 * never asked to store raw client IPs. Bucket docs auto-expire 1 h
 * later via a Firestore TTL policy on the `expires_at` field.
 */

import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as functions from "firebase-functions";

const SALT =
  process.env.RATE_LIMIT_IP_SALT ??
  // Fail-safe default — works for any deploy but should be overridden in
  // prod so an attacker who reads a bucket doc cannot rainbow-table back
  // to the IP without first stealing the salt.
  "psyclinicai-default-rate-salt-2026";

export interface RateLimitConfig {
  /** Unique action name — e.g. "passkey_auth_options". */
  bucketName: string;
  /** Window length in milliseconds (e.g. 15 * 60_000). */
  windowMs: number;
  /** Max requests inside the window. */
  maxRequests: number;
}

export interface RateLimitResult {
  /** True when the request is over the cap. */
  blocked: boolean;
  /** Current count after this request (capped at maxRequests + 1). */
  count: number;
  /** Window reset time, ms epoch. */
  resetAt: number;
}

function hashIp(ip: string): string {
  return crypto
    .createHash("sha256")
    .update(`${SALT}:${ip}`)
    .digest("hex")
    .slice(0, 32);
}

function extractIp(req: functions.https.Request): string {
  // Firebase Hosting passes the real IP via x-forwarded-for; the last
  // entry in the chain is the client because Google's edge appends
  // proxies in order. Fall back to req.ip when the header is missing.
  const xff = req.headers["x-forwarded-for"];
  if (typeof xff === "string" && xff.length > 0) {
    const parts = xff.split(",").map((s) => s.trim()).filter(Boolean);
    if (parts.length > 0) return parts[parts.length - 1];
  }
  if (Array.isArray(xff) && xff.length > 0) {
    return String(xff[xff.length - 1]);
  }
  return req.ip ?? "0.0.0.0";
}

export async function consumeRequest(
  req: functions.https.Request,
  cfg: RateLimitConfig,
): Promise<RateLimitResult> {
  const now = Date.now();
  const ip = extractIp(req);
  const ipHash = hashIp(ip);
  const bucketStart = now - (now % cfg.windowMs);
  const resetAt = bucketStart + cfg.windowMs;
  const docId = `${cfg.bucketName}_${ipHash}_${bucketStart}`;
  const ref = admin
    .firestore()
    .collection("webauthn_rate_limits")
    .doc(docId);

  const result = await admin.firestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    let nextCount = 1;
    if (snap.exists) {
      const data = snap.data() ?? {};
      const prev = typeof data["count"] === "number" ? data["count"] : 0;
      nextCount = prev + 1;
    }
    tx.set(
      ref,
      {
        bucket_name: cfg.bucketName,
        ip_hash: ipHash,
        bucket_start: admin.firestore.Timestamp.fromMillis(bucketStart),
        count: nextCount,
        expires_at: admin.firestore.Timestamp.fromMillis(
          resetAt + 60 * 60_000, // TTL 1h after window close
        ),
      },
      { merge: false },
    );
    return nextCount;
  });

  const blocked = result > cfg.maxRequests;
  if (blocked) {
    functions.logger.warn("rate_limit.blocked", {
      bucket: cfg.bucketName,
      ipHashPrefix: ipHash.slice(0, 8),
      count: result,
      max: cfg.maxRequests,
    });
  }
  return { blocked, count: result, resetAt };
}

/**
 * Apply the limit and answer with 429 when blocked. Returns true when
 * the caller should stop processing.
 */
export async function enforceOrReply(
  req: functions.https.Request,
  res: functions.Response,
  cfg: RateLimitConfig,
): Promise<boolean> {
  const r = await consumeRequest(req, cfg);
  if (r.blocked) {
    res
      .status(429)
      .set("Retry-After", String(Math.ceil((r.resetAt - Date.now()) / 1000)))
      .json({
        error: "rate_limited",
        bucket: cfg.bucketName,
        max: cfg.maxRequests,
      });
    return true;
  }
  return false;
}
