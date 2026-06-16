/**
 * `ragProxy` — server-side reverse proxy for the Clinical RAG Hub
 * (psyrag). Closes Sprint 26 pentest finding F-003 (High): the
 * per-tenant RAG hub key used to ship inside the Flutter web bundle
 * via `--dart-define=RAG_API_KEY=...`, so anyone could pull it out
 * of `main.dart.js` and call the hub directly.
 *
 * After this proxy lands the key only ever exists in Firebase
 * Functions runtime env (`RAG_HUB_KEY`). The browser only ever
 * carries a short-lived Firebase ID token; tenant identity comes
 * from the verified custom claim, never from the request body.
 *
 * Contract:
 *   POST/GET /ragProxy/<op>
 *   <op> ∈ { analyze, query, feedback, health }
 *   Headers: Authorization: Bearer <Firebase ID token>
 *   Body:    upstream payload (forwarded verbatim, minus PHI in audit)
 *   Reply:   upstream JSON
 *
 * Side effects:
 *   - Writes `rag_proxy_calls/{auto}` audit doc per call (no PHI body,
 *     just op + tenant + uid + status + latency).
 *   - Refuses on missing/forged token, missing tenant claim, or op
 *     outside the allow-list.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

import {applyCors} from "./lib/auth";
import {env, resolveCorsOrigin} from "./lib/env";

type RagOp = "analyze" | "query" | "feedback" | "health";

const ALLOWED_OPS: ReadonlySet<RagOp> = new Set<RagOp>([
  "analyze",
  "query",
  "feedback",
  "health",
]);

interface VerifiedCaller {
  uid: string;
  tenantId: string;
}

/** Extract the trailing op segment from `req.path` (`/analyze` → `analyze`). */
export function extractOp(reqPath: string): RagOp | null {
  const last = reqPath.split("/").filter((s) => s.length > 0).pop() ?? "";
  return ALLOWED_OPS.has(last as RagOp) ? (last as RagOp) : null;
}

/**
 * Verify the Firebase ID token AND require a `tenantId` custom claim.
 * Returns `null` when the caller is not authenticated or the tenant
 * claim is absent — the proxy refuses rather than fall back to a
 * body-supplied tenant (body-supplied = forgeable).
 */
async function verifyCaller(
  req: functions.https.Request,
): Promise<VerifiedCaller | null> {
  const header = (req.headers.authorization as string | undefined) ?? "";
  const m = header.match(/^Bearer\s+(.+)$/i);
  if (!m) return null;
  let decoded: admin.auth.DecodedIdToken;
  try {
    decoded = await admin.auth().verifyIdToken(m[1]);
  } catch (e) {
    functions.logger.warn("ragProxy.bad_token", {reason: String(e)});
    return null;
  }
  const tenantId = (decoded.tenantId ?? decoded.tenant_id) as
    | string
    | undefined;
  if (!tenantId || typeof tenantId !== "string") {
    functions.logger.warn("ragProxy.missing_tenant_claim", {uid: decoded.uid});
    return null;
  }
  return {uid: decoded.uid, tenantId};
}

export const ragProxy = functions.https.onRequest(async (req, res) => {
  if (applyCors(req, res)) return;

  const op = extractOp(req.path);
  if (op === null) {
    res.status(404).json({error: "unknown_op"});
    return;
  }

  const caller = await verifyCaller(req);
  if (!caller) {
    res.status(401).json({error: "unauthorized"});
    return;
  }

  const hubUrl = env.RAG_HUB_URL;
  const hubKey = env.RAG_HUB_KEY;

  const upstreamUrl = `${hubUrl.replace(/\/$/, "")}/api/rag/${op}`;
  const isGet = op === "health" || req.method === "GET";
  const startMs = Date.now();

  let upstream: Response;
  try {
    upstream = await fetch(upstreamUrl, {
      method: isGet ? "GET" : "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": hubKey,
        "x-tenant-id": caller.tenantId,
      },
      ...(isGet ? {} : {body: JSON.stringify(req.body ?? {})}),
    });
  } catch (e) {
    functions.logger.error("ragProxy.upstream_unreachable", {
      op,
      error: String(e),
    });
    await writeAudit(caller, op, 502, Date.now() - startMs);
    res.status(502).json({error: "upstream_unreachable"});
    return;
  }

  const latencyMs = Date.now() - startMs;
  const text = await upstream.text();
  await writeAudit(caller, op, upstream.status, latencyMs);

  res.status(upstream.status);
  res.set("content-type",
    upstream.headers.get("content-type") ?? "application/json");
  res.send(text);
});

async function writeAudit(
  caller: VerifiedCaller,
  op: RagOp,
  status: number,
  latencyMs: number,
): Promise<void> {
  try {
    await admin.firestore().collection("rag_proxy_calls").add({
      tenant_id: caller.tenantId,
      uid: caller.uid,
      op,
      status,
      latency_ms: latencyMs,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (e) {
    functions.logger.warn("ragProxy.audit_write_failed", {
      reason: String(e),
    });
  }
}

export {resolveCorsOrigin};
