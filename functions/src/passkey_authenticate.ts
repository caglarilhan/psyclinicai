/**
 * `passkeyAuthOptions` + `passkeyAuthVerify` — WebAuthn assertion
 * (step-up auth + future password-less sign-in). Sprint 26 W1.
 *
 * On verify we atomically:
 *   - reject when `signCount` regresses (cloning defence — HIPAA
 *     §164.312(d) and FIDO2 best practice — and lock the credential),
 *   - bump the stored `sign_count`,
 *   - stamp `last_used_at`.
 *
 * No PHI touches this code path.
 */
import * as admin from "firebase-admin";
import * as crypto from "crypto";
import * as functions from "firebase-functions";
import { applyCors, authorizeUid } from "./lib/auth";
import { enforceOrReply } from "./lib/rate_limit";
import { applySecurityHeaders } from "./lib/security_chain";
import { rpIdFor, originFor } from "./lib/webauthn_env";

// Sprint 29 S-01 (F-004 close) — 20 requests / 15 minutes per IP defends
// the credential-id enumeration timing attack on the assertion endpoints.
const PASSKEY_AUTH_RATE_LIMIT = {
  bucketName: "passkey_auth",
  windowMs: 15 * 60_000,
  maxRequests: 20,
} as const;

/**
 * Returns a 16-char SHA-256 hex prefix of the credential id so logs
 * keep a stable correlation handle without pairing the hardware id to
 * the uid in plain text (HIPAA minimum-necessary).
 */
export function hashCredentialId(credentialId: string): string {
  return crypto
    .createHash("sha256")
    .update(credentialId)
    .digest("hex")
    .slice(0, 16);
}

/**
 * FIDO2 §6.1 step 17 — treat as cloning evidence when the
 * authenticator's reported sign count fails to advance. Equality at
 * non-zero is replay; equality at zero is the legitimate
 * "this authenticator pins signCount at 0" case.
 */
export function isCloningEvidence(
  storedSignCount: number,
  receivedSignCount: number,
): boolean {
  if (receivedSignCount < storedSignCount) return true;
  if (receivedSignCount === storedSignCount && receivedSignCount !== 0) {
    return true;
  }
  return false;
}

export interface AssertionVerifier {
  verifyAuthentication(params: {
    response: unknown;
    expectedChallenge: string;
    expectedOrigin: string;
    expectedRpId: string;
    storedPublicKey: string;
    storedSignCount: number;
  }): Promise<{ verified: boolean; newSignCount: number }>;
}

let _verifier: AssertionVerifier | null = null;

export function setAssertionVerifier(v: AssertionVerifier | null): void {
  _verifier = v;
}

function challengeBase64Url(): string {
  const arr = new Uint8Array(32);
  const cryptoApi =
    (globalThis as { crypto?: { getRandomValues: (a: Uint8Array) => void } })
      .crypto ??
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    (require("crypto").webcrypto as {
      getRandomValues: (a: Uint8Array) => void;
    });
  cryptoApi.getRandomValues(arr);
  return Buffer.from(arr)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

export const passkeyAuthOptions = functions.https.onRequest(
  async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    // S-01 — rate-limit BEFORE authorizeUid so an unauthenticated
    // attacker cannot enumerate credential ids via timing differences.
    if (await enforceOrReply(req, res, PASSKEY_AUTH_RATE_LIMIT)) return;
    const uid = await authorizeUid(req, "passkeyAuthOptions");
    if (!uid) {
      res.status(401).json({ error: "unauthenticated" });
      return;
    }
    const passkeys = await admin
      .firestore()
      .collection(`users/${uid}/passkeys`)
      .get();
    const allow = passkeys.docs
      .map((d) => d.data() as { [k: string]: unknown })
      .filter((d) => !d.revoked_at)
      .map((d) => ({
        id: d.credential_id as string,
        type: "public-key" as const,
        transports: Array.isArray(d.transports)
          ? (d.transports as string[])
          : [],
      }));
    if (allow.length === 0) {
      res.status(400).json({ error: "no_passkeys_enrolled" });
      return;
    }
    const challenge = challengeBase64Url();
    const expiresAt = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 5 * 60_000)
    );
    await admin
      .firestore()
      .doc(`webauthn_challenges/${uid}_auth`)
      .set({
        challenge,
        expiresAt,
        kind: "auth",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    res.json({
      challenge,
      rpId: rpIdFor(req),
      allowCredentials: allow,
      userVerification: "preferred",
      timeout: 60_000,
    });
  }
);

export const passkeyAuthVerify = functions.https.onRequest(
  async (req, res) => {
    applySecurityHeaders(res);
    if (applyCors(req, res)) return;
    if (await enforceOrReply(req, res, PASSKEY_AUTH_RATE_LIMIT)) return;
    const uid = await authorizeUid(req, "passkeyAuthVerify");
    if (!uid) {
      res.status(401).json({ error: "unauthenticated" });
      return;
    }
    if (!_verifier) {
      res.status(500).json({ error: "verifier_not_configured" });
      return;
    }
    const body =
      (req.body as {
        credentialId?: string;
        assertionResponse?: unknown;
      }) ?? {};
    const credentialId = String(body.credentialId ?? "").trim();
    if (credentialId.length === 0) {
      res.status(400).json({ error: "credential_id_required" });
      return;
    }
    const challengeRef = admin
      .firestore()
      .doc(`webauthn_challenges/${uid}_auth`);
    const credRef = admin
      .firestore()
      .doc(`users/${uid}/passkeys/${credentialId}`);

    let challengeData: {
      challenge: string;
      expiresAt: admin.firestore.Timestamp;
    };
    let credData: {
      public_key: string;
      sign_count: number;
      revoked_at?: admin.firestore.Timestamp | null;
    };

    try {
      const consumed = await admin.firestore().runTransaction(async (tx) => {
        const challengeSnap = await tx.get(challengeRef);
        if (!challengeSnap.exists) {
          throw new HandlerError(400, "no_challenge");
        }
        const rawChallenge = challengeSnap.data();
        if (
          !rawChallenge ||
          typeof rawChallenge["challenge"] !== "string" ||
          !(rawChallenge["expiresAt"] instanceof admin.firestore.Timestamp)
        ) {
          tx.delete(challengeRef);
          throw new HandlerError(500, "corrupt_challenge");
        }
        if ((rawChallenge["expiresAt"] as admin.firestore.Timestamp)
            .toMillis() < Date.now()) {
          tx.delete(challengeRef);
          throw new HandlerError(400, "challenge_expired");
        }
        const credSnap = await tx.get(credRef);
        if (!credSnap.exists) {
          throw new HandlerError(404, "credential_not_found");
        }
        const rawCred = credSnap.data();
        if (
          !rawCred ||
          typeof rawCred["public_key"] !== "string" ||
          typeof rawCred["sign_count"] !== "number"
        ) {
          throw new HandlerError(500, "corrupt_credential");
        }
        if (rawCred["revoked_at"]) {
          throw new HandlerError(403, "credential_revoked");
        }
        // Consume the challenge atomically with the read so a racing
        // request hits no_challenge instead of double-spending it.
        tx.delete(challengeRef);
        return {
          challenge: rawChallenge["challenge"] as string,
          expiresAt:
              rawChallenge["expiresAt"] as admin.firestore.Timestamp,
          public_key: rawCred["public_key"] as string,
          sign_count: rawCred["sign_count"] as number,
        };
      });
      challengeData = {
        challenge: consumed.challenge,
        expiresAt: consumed.expiresAt,
      };
      credData = {
        public_key: consumed.public_key,
        sign_count: consumed.sign_count,
      };
    } catch (e) {
      if (e instanceof HandlerError) {
        res.status(e.status).json({ error: e.code });
        return;
      }
      throw e;
    }
    try {
      const result = await _verifier.verifyAuthentication({
        response: body.assertionResponse,
        expectedChallenge: challengeData.challenge,
        expectedOrigin: originFor(req),
        expectedRpId: rpIdFor(req),
        storedPublicKey: credData.public_key,
        storedSignCount: credData.sign_count,
      });
      if (!result.verified) {
        res.status(400).json({ error: "assertion_failed" });
        return;
      }
      // FIDO2 §6.1 step 17 — see isCloningEvidence.
      const newCount = result.newSignCount;
      if (isCloningEvidence(credData.sign_count, newCount)) {
        functions.logger.error("passkeyAuthVerify.sign_count_regression", {
          uid,
          credentialIdHashHex: hashCredentialId(credentialId),
          stored: credData.sign_count,
          received: newCount,
        });
        await credRef.update({
          revoked_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        res.status(400).json({ error: "cloning_detected" });
        return;
      }
      await credRef.update({
        sign_count: result.newSignCount,
        last_used_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      res.json({ ok: true, signCount: result.newSignCount });
    } catch (e) {
      // Sprint 28 audit (F-005 close): the FIDO2 verification library
      // sometimes embeds the raw credential id in its error messages.
      // Strip + cap to 120 chars so a leaking credential id never lands
      // in Cloud Logging. The uid stays — it is in many other audit
      // rows already, the credential id is the secret-equivalent here.
      functions.logger.error("passkeyAuthVerify.error", {
        uid,
        error: String(e).slice(0, 120),
      });
      res.status(400).json({ error: "verification_error" });
    }
  }
);

class HandlerError extends Error {
  constructor(public status: number, public code: string) {
    super(code);
  }
}
