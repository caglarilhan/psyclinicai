/**
 * `passkeyRegisterOptions` + `passkeyRegisterVerify` — WebAuthn /
 * FIDO2 enrolment. Sprint 26 W1.
 *
 * Flow:
 *   1. POST `/passkeyRegisterOptions { deviceLabel }`. We mint a
 *      32-byte challenge, write `webauthn_challenges/{uid}_register`
 *      with `expiresAt = now + 5 min`, and respond with WebAuthn
 *      PublicKeyCredentialCreationOptions.
 *   2. POST `/passkeyRegisterVerify { attestationResponse, transports }`.
 *      We rehydrate the challenge, hand it to the configured
 *      `AttestationVerifier`, and on success persist
 *      `users/{uid}/passkeys/{credentialId}`.
 *
 * Crypto sits behind a `Verifier` interface so unit tests inject a
 * deterministic fake; production wiring uses `@simplewebauthn/server`,
 * landed in a follow-up commit with the npm dep bump. No PHI ever
 * touches these handlers.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { applyCors, authorizeUid } from "./lib/auth";
import { rpIdFor, originFor } from "./lib/webauthn_env";

export interface AttestationVerifier {
  verifyRegistration(params: {
    response: unknown;
    expectedChallenge: string;
    expectedOrigin: string;
    expectedRpId: string;
  }): Promise<{
    verified: boolean;
    credentialId: string;
    publicKey: string;
    signCount: number;
    aaguid?: string;
  }>;
}

let _verifier: AttestationVerifier | null = null;

/** Test seam — swap the verifier in unit / integration tests. */
export function setAttestationVerifier(v: AttestationVerifier | null): void {
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

export const passkeyRegisterOptions = functions.https.onRequest(
  async (req, res) => {
    if (applyCors(req, res)) return;
    const uid = await authorizeUid(req, "passkeyRegisterOptions");
    if (!uid) {
      res.status(401).json({ error: "unauthenticated" });
      return;
    }
    const deviceLabel = String(
      (req.body as { deviceLabel?: string })?.deviceLabel ?? ""
    ).trim();
    if (deviceLabel.length === 0 || deviceLabel.length > 80) {
      res.status(400).json({ error: "device_label_required" });
      return;
    }
    const challenge = challengeBase64Url();
    const expiresAt = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 5 * 60_000)
    );
    await admin
      .firestore()
      .doc(`webauthn_challenges/${uid}_register`)
      .set({
        challenge,
        deviceLabel,
        expiresAt,
        kind: "register",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    res.json({
      challenge,
      rp: { name: "PsyClinicAI", id: rpIdFor(req) },
      user: { id: uid, name: uid, displayName: uid },
      pubKeyCredParams: [
        { type: "public-key", alg: -7 }, // ES256
        { type: "public-key", alg: -257 }, // RS256
      ],
      authenticatorSelection: {
        residentKey: "preferred",
        userVerification: "preferred",
      },
      timeout: 60_000,
      attestation: "none",
    });
  }
);

export const passkeyRegisterVerify = functions.https.onRequest(
  async (req, res) => {
    if (applyCors(req, res)) return;
    const uid = await authorizeUid(req, "passkeyRegisterVerify");
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
        attestationResponse?: unknown;
        transports?: string[];
      }) ?? {};

    // Defer verifier call into a transaction so two concurrent
    // requests cannot both consume the same challenge.
    const challengeRef = admin
      .firestore()
      .doc(`webauthn_challenges/${uid}_register`);

    let challengeData: {
      challenge: string;
      deviceLabel: string;
      expiresAt: admin.firestore.Timestamp;
    };
    try {
      challengeData = await admin
        .firestore()
        .runTransaction(async (tx) => {
          const snap = await tx.get(challengeRef);
          if (!snap.exists) {
            throw new HandlerError(400, "no_challenge");
          }
          const raw = snap.data();
          if (
            !raw ||
            typeof raw["challenge"] !== "string" ||
            typeof raw["deviceLabel"] !== "string" ||
            !(raw["expiresAt"] instanceof admin.firestore.Timestamp)
          ) {
            tx.delete(challengeRef);
            throw new HandlerError(500, "corrupt_challenge");
          }
          if ((raw["expiresAt"] as admin.firestore.Timestamp).toMillis() <
              Date.now()) {
            tx.delete(challengeRef);
            throw new HandlerError(400, "challenge_expired");
          }
          // Consume here — any racing request now hits no_challenge.
          tx.delete(challengeRef);
          return {
            challenge: raw["challenge"] as string,
            deviceLabel: raw["deviceLabel"] as string,
            expiresAt: raw["expiresAt"] as admin.firestore.Timestamp,
          };
        });
    } catch (e) {
      if (e instanceof HandlerError) {
        res.status(e.status).json({ error: e.code });
        return;
      }
      throw e;
    }

    try {
      const result = await _verifier.verifyRegistration({
        response: body.attestationResponse,
        expectedChallenge: challengeData.challenge,
        expectedOrigin: originFor(req),
        expectedRpId: rpIdFor(req),
      });
      if (!result.verified) {
        res.status(400).json({ error: "attestation_failed" });
        return;
      }
      await admin
        .firestore()
        .doc(`users/${uid}/passkeys/${result.credentialId}`)
        .set({
          credential_id: result.credentialId,
          public_key: result.publicKey,
          sign_count: result.signCount,
          device_label: challengeData.deviceLabel,
          transports: Array.isArray(body.transports) ? body.transports : [],
          aaguid: result.aaguid ?? null,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      res.json({ ok: true, credentialId: result.credentialId });
    } catch (e) {
      functions.logger.error("passkeyRegisterVerify.error", {
        uid,
        error: e,
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
