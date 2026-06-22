/**
 * Telehealth room minting (Sprint 11, hardened Sprint 14 review).
 *
 * Mints a Daily.co meeting room + short-lived meeting token. The API
 * key never leaves the server. The client receives only the room
 * handle (for the WebRTC widget) and the meeting token (used in
 * memory; never persisted).
 *
 * Hardening highlights (post-review):
 *   • Auth is **clinician-only** — `authorizeClinicianUid` rejects
 *     patient sessions before any upstream call (prevents owner-token
 *     escalation from a stolen patient JWT).
 *   • Per-uid sliding-window rate limit (5 rooms / 5 minutes) — the
 *     counter row is in Firestore so it survives Cloud Functions
 *     cold-starts.
 *   • `scheduledFor` is clamped to seven days into the future so a
 *     malicious caller cannot mint a long-lived recording-enabled
 *     room.
 *
 * Pure helpers (deriveRoomName, computeTokenExpiry, withinSchedule
 * Horizon) are exported for unit tests.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import { applyCors, authorizeClinicianUid } from "./lib/auth";
import { env } from "./lib/env";

const DAILY_API_BASE = "https://api.daily.co/v1";
const RATE_LIMIT_COLLECTION = "telehealth_rate_limits";
const RATE_LIMIT_WINDOW_MS = 5 * 60 * 1000;
const RATE_LIMIT_MAX = 5;
const SCHEDULE_HORIZON_MS = 7 * 24 * 60 * 60 * 1000;

/**
 * Build the canonical Daily.co room slug. Deterministic — the same
 * (clinicId, sessionId) pair always resolves to the same room so a
 * reconnect lands the clinician in the same waiting area as the
 * patient.
 */
export function deriveRoomName(clinicId: string, sessionId: string): string {
  // Bound the pre-regex length so an attacker-controlled clinicId
  // can't trigger pathological backtracking (CodeQL "Polynomial
  // regular expression on uncontrolled data" PR #2 finding).
  // Real IDs are <64 chars; cap at 256 for defence in depth.
  const sanitize = (s: string) =>
    s
      .slice(0, 256)
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "");
  const c = sanitize(clinicId).slice(0, 14);
  const s = sanitize(sessionId).slice(0, 20);
  return `psy-${c}-${s}`.slice(0, 41);
}

/** 15-min nbf, 90-min exp window — fits a standard 50-min session + margin. */
export function computeTokenExpiry(scheduledFor: Date): {
  notBefore: Date;
  expiresAt: Date;
} {
  const start = scheduledFor.getTime();
  return {
    notBefore: new Date(start - 15 * 60 * 1000),
    expiresAt: new Date(start + 90 * 60 * 1000),
  };
}

/**
 * Refuse `scheduledFor` more than 7 days out — meeting tokens with
 * very long `exp` claims undermine the audit trail and pull
 * recording-enabled rooms forward in time.
 */
export function withinScheduleHorizon(scheduledFor: Date, now: Date): boolean {
  const delta = scheduledFor.getTime() - now.getTime();
  return delta >= 0 && delta <= SCHEDULE_HORIZON_MS;
}

/**
 * Atomic rate-limit check. Returns true when the caller may proceed.
 * The Firestore transaction guarantees we never double-count under
 * concurrent invocations.
 */
async function checkRateLimit(uid: string, now: Date): Promise<boolean> {
  const db = admin.firestore();
  const ref = db.collection(RATE_LIMIT_COLLECTION).doc(uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const cutoff = now.getTime() - RATE_LIMIT_WINDOW_MS;
    const previous =
      (snap.exists ? (snap.data() as { timestamps?: number[] }).timestamps : []) ??
      [];
    const fresh = previous.filter((t) => t > cutoff);
    if (fresh.length >= RATE_LIMIT_MAX) {
      return false;
    }
    fresh.push(now.getTime());
    tx.set(ref, { timestamps: fresh });
    return true;
  });
}

export const telehealthRoom = functions.https.onRequest(async (req, res) => {
  if (applyCors(req, res)) return;
  if (req.method !== "POST") return void res.status(405).send("POST only");

  const uid = await authorizeClinicianUid(req, "telehealthRoom");
  if (!uid) return void res.status(401).json({ error: "unauthorized" });

  const sessionId = String(req.body?.sessionId ?? "");
  const patientId = String(req.body?.patientId ?? "");
  const scheduledFor = String(req.body?.scheduledFor ?? "");
  if (!sessionId || !patientId || !scheduledFor) {
    return void res.status(400).json({ error: "missing_fields" });
  }

  const when = new Date(scheduledFor);
  if (Number.isNaN(when.getTime())) {
    return void res.status(400).json({ error: "bad_scheduledFor" });
  }
  if (!withinScheduleHorizon(when, new Date())) {
    return void res.status(400).json({ error: "schedule_out_of_horizon" });
  }

  const allowed = await checkRateLimit(uid, new Date());
  if (!allowed) {
    return void res.status(429).json({ error: "rate_limited" });
  }

  const roomName = deriveRoomName(uid, sessionId);
  const { notBefore, expiresAt } = computeTokenExpiry(when);

  try {
    const roomResp = await fetch(`${DAILY_API_BASE}/rooms`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${env.DAILY_API_KEY}`,
      },
      body: JSON.stringify({
        name: roomName,
        privacy: "private",
        properties: {
          exp: Math.floor(expiresAt.getTime() / 1000),
          enable_recording: "cloud",
          eject_at_room_exp: true,
        },
      }),
    });
    if (!roomResp.ok && roomResp.status !== 409) {
      functions.logger.error("telehealth.room_create_failed", {
        status: roomResp.status,
      });
      return void res.status(502).json({ error: "room_create_failed" });
    }

    const tokenResp = await fetch(`${DAILY_API_BASE}/meeting-tokens`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${env.DAILY_API_KEY}`,
      },
      body: JSON.stringify({
        properties: {
          room_name: roomName,
          user_id: uid,
          is_owner: true,
          nbf: Math.floor(notBefore.getTime() / 1000),
          exp: Math.floor(expiresAt.getTime() / 1000),
        },
      }),
    });
    if (!tokenResp.ok) {
      functions.logger.error("telehealth.token_mint_failed", {
        status: tokenResp.status,
      });
      return void res.status(502).json({ error: "token_mint_failed" });
    }
    const payload = await tokenResp.json();
    const token =
      typeof payload === "object" &&
      payload !== null &&
      typeof (payload as { token?: unknown }).token === "string"
        ? (payload as { token: string }).token
        : null;
    if (!token) {
      functions.logger.error("telehealth.token_mint_unexpected_shape");
      return void res.status(502).json({ error: "token_mint_failed" });
    }

    res.json({
      roomName,
      meetingToken: token,
      expiresAt: expiresAt.toISOString(),
    });
  } catch (e) {
    functions.logger.error("telehealth.unexpected", {
      reason: String(e),
    });
    res.status(502).json({ error: "telehealth_failed" });
  }
});
