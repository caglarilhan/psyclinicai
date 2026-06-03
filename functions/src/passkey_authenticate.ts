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
import * as functions from "firebase-functions";
import { applyCors, authorizeUid } from "./lib/auth";
import { rpIdFor, originFor } from "./lib/webauthn_env";

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
    if (applyCors(req, res)) return;
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
    if (applyCors(req, res)) return;
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
    const challengeDoc = await admin
      .firestore()
      .doc(`webauthn_challenges/${uid}_auth`)
      .get();
    if (!challengeDoc.exists) {
      res.status(400).json({ error: "no_challenge" });
      return;
    }
    const challengeData = challengeDoc.data() as {
      challenge: string;
      expiresAt: admin.firestore.Timestamp;
    };
    if (challengeData.expiresAt.toMillis() < Date.now()) {
      await challengeDoc.ref.delete();
      res.status(400).json({ error: "challenge_expired" });
      return;
    }
    const credRef = admin
      .firestore()
      .doc(`users/${uid}/passkeys/${credentialId}`);
    const credSnap = await credRef.get();
    if (!credSnap.exists) {
      res.status(404).json({ error: "credential_not_found" });
      return;
    }
    const credData = credSnap.data() as {
      public_key: string;
      sign_count: number;
      revoked_at?: admin.firestore.Timestamp | null;
    };
    if (credData.revoked_at) {
      res.status(403).json({ error: "credential_revoked" });
      return;
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
      if (result.newSignCount < credData.sign_count) {
        functions.logger.error("passkeyAuthVerify.sign_count_regression", {
          uid,
          credentialId,
          stored: credData.sign_count,
          received: result.newSignCount,
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
      await challengeDoc.ref.delete();
      res.json({ ok: true, signCount: result.newSignCount });
    } catch (e) {
      functions.logger.error("passkeyAuthVerify.error", {
        uid,
        reason: String(e),
      });
      res.status(400).json({ error: "verification_error" });
    }
  }
);
