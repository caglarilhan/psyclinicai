import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import { resolveCorsOrigin } from "./env";

/**
 * Verify the Firebase ID token on the request. Returns the uid on
 * success, `null` when the token is missing or invalid. Logged with
 * [logTag] so every handler keeps a clear telemetry namespace.
 */
/**
 * Pull the bearer token off the Authorization header without a regex
 * (CodeQL flagged the prior `/^Bearer\s+(.+)$/i` as polynomial on
 * uncontrolled input). The HTTP/1.1 grammar permits one or more spaces
 * after the scheme; a tight `startsWith` + `slice` covers the common
 * case while bounding the worst-case cost to O(n).
 */
function extractBearerToken(req: functions.https.Request): string | null {
  const header = (req.headers.authorization as string | undefined) ?? "";
  // Cap so a 10 MB header can't even start the comparison.
  if (header.length === 0 || header.length > 8 * 1024) return null;
  const prefix = "bearer ";
  if (header.length <= prefix.length) return null;
  if (header.slice(0, prefix.length).toLowerCase() !== prefix) return null;
  // Tokens have no whitespace; collapse the rare double-space header.
  const token = header.slice(prefix.length).trim();
  return token.length > 0 ? token : null;
}

export async function authorizeUid(
  req: functions.https.Request,
  logTag: string,
): Promise<string | null> {
  const token = extractBearerToken(req);
  if (!token) return null;
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    return decoded.uid;
  } catch (e) {
    functions.logger.warn(`${logTag}.bad_token`, { reason: String(e) });
    return null;
  }
}

/**
 * Verify the caller is an authenticated **clinician** (has the
 * `clinician: true` custom claim). Returns null on missing / patient
 * tokens. Sprint 11+ telehealth gate uses this to refuse meeting
 * tokens to patient sessions.
 */
export async function authorizeClinicianUid(
  req: functions.https.Request,
  logTag: string,
): Promise<string | null> {
  const token = extractBearerToken(req);
  if (!token) return null;
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    if (decoded.clinician !== true) {
      functions.logger.warn(`${logTag}.non_clinician`, {
        uid: decoded.uid,
      });
      return null;
    }
    return decoded.uid;
  } catch (e) {
    functions.logger.warn(`${logTag}.bad_token`, { reason: String(e) });
    return null;
  }
}

/**
 * Apply the standard CORS preflight handshake. Returns `true` when
 * the handler should return early (the response is already finalised
 * for OPTIONS / forbidden-origin cases).
 */
export function applyCors(
  req: functions.https.Request,
  res: functions.Response,
): boolean {
  const requestOrigin = req.headers.origin as string | undefined;
  const allowed = resolveCorsOrigin(requestOrigin);
  if (allowed === null) {
    res.status(403).json({ error: "forbidden_origin" });
    return true;
  }
  res.set("Access-Control-Allow-Origin", allowed);
  res.set("Vary", "Origin");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}
