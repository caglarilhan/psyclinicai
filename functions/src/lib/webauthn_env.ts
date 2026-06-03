/**
 * WebAuthn RP-id / origin helpers. Sprint 26 W1.
 *
 * The Relying Party id MUST match the registrable domain the credential
 * is bound to. We accept the request's `Origin` header in dev (where it
 * may be `http://localhost:8000`) and fall back to the prod RP id when
 * the origin is missing or unrecognised.
 */
import * as functions from "firebase-functions";

const PROD_RP_ID = "psyclinic.ai";
const ALLOWED_ORIGINS = new Set<string>([
  "https://psyclinic.ai",
  "https://app.psyclinic.ai",
  "https://us.psyclinic.ai",
  "https://eu.psyclinic.ai",
  "http://localhost:8000",
  "http://localhost:5000",
]);

export function rpIdFor(req: functions.https.Request): string {
  const origin = (req.headers.origin as string | undefined) ?? "";
  if (origin === "http://localhost:8000" || origin === "http://localhost:5000") {
    return "localhost";
  }
  try {
    const u = new URL(origin);
    // Anchor on the dot so `evil-psyclinic.ai` cannot pass as a subdomain.
    if (u.hostname === PROD_RP_ID ||
        u.hostname.endsWith(`.${PROD_RP_ID}`)) {
      return PROD_RP_ID;
    }
  } catch (_) {
    // fall through to prod default
  }
  return PROD_RP_ID;
}

export function originFor(req: functions.https.Request): string {
  const origin = (req.headers.origin as string | undefined) ?? "";
  if (ALLOWED_ORIGINS.has(origin)) return origin;
  return `https://${PROD_RP_ID}`;
}
