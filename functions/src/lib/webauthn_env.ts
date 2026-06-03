/**
 * WebAuthn RP-id / origin helpers. Sprint 26 W1.
 *
 * The Relying Party id MUST match the registrable domain the credential
 * is bound to. We accept the request's `Origin` header in dev and fall
 * back to the prod RP id when the origin is missing or unrecognised.
 *
 * The origin allow-list reads from `ALLOWED_ORIGINS` (the same env var
 * `resolveCorsOrigin` consumes) so a new subdomain only has to be
 * added once. `FALLBACK_ORIGINS` is the static dev allow-list used in
 * tests / when the env var is not set.
 */
import * as functions from "firebase-functions";

const PROD_RP_ID = "psyclinic.ai";

const FALLBACK_ORIGINS = new Set<string>([
  "https://psyclinic.ai",
  "https://app.psyclinic.ai",
  "https://us.psyclinic.ai",
  "https://eu.psyclinic.ai",
  "http://localhost:8000",
  "http://localhost:5000",
]);

function allowedOrigins(): Set<string> {
  const raw =
    process.env.ALLOWED_ORIGINS ?? process.env.APP_URL ?? "";
  const list = raw
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  if (list.length === 0) return FALLBACK_ORIGINS;
  return new Set(list);
}

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
  if (allowedOrigins().has(origin)) return origin;
  return `https://${PROD_RP_ID}`;
}
