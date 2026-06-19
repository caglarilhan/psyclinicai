/**
 * `healthcheck` — public liveness + dependency probe.
 * statuspage.io poll target. Sprint 25 W2 closes the static-status-
 * page finding.
 */
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

const RELEASE_VERSION =
  process.env.K_REVISION || process.env.FUNCTION_TARGET || "dev";
const BOOTED_AT = Date.now();

interface Dependency {
  name: string;
  status: "ok" | "degraded" | "outage";
  latency_ms: number;
  error_code?: string;
}

function errorCodeOf(e: unknown): string {
  if (typeof e === "object" && e !== null && "code" in e) {
    const code = (e as { code?: unknown }).code;
    if (typeof code === "string") return code;
    if (typeof code === "number") return String(code);
  }
  return "unknown";
}

async function pingFirestore(): Promise<Dependency> {
  const started = Date.now();
  try {
    await admin.firestore().doc("system/health-probe").get();
    return {
      name: "firestore",
      status: "ok",
      latency_ms: Date.now() - started,
    };
  } catch (e) {
    const code = errorCodeOf(e);
    functions.logger.error("healthcheck.firestore_outage", { code, error: e });
    return {
      name: "firestore",
      status: "outage",
      latency_ms: Date.now() - started,
      error_code: code,
    };
  }
}

async function pingAuth(): Promise<Dependency> {
  const started = Date.now();
  try {
    await admin.auth().listUsers(1);
    return {
      name: "firebase_auth",
      status: "ok",
      latency_ms: Date.now() - started,
    };
  } catch (e) {
    const code = errorCodeOf(e);
    functions.logger.error("healthcheck.auth_outage", { code, error: e });
    return {
      name: "firebase_auth",
      status: "outage",
      latency_ms: Date.now() - started,
      error_code: code,
    };
  }
}

export const healthcheck = functions.https.onRequest(
  async (req, res) => {
    // Strict opt-in: `?deep=true` or `?deep=1`; anything else (incl.
    // `?deep=false`) skips the dependency probes.
    const deepRaw = String(req.query.deep ?? "").toLowerCase();
    const deep = deepRaw === "true" || deepRaw === "1";
    const dependencies: Dependency[] = [];
    if (deep) {
      // Sprint 28 / F-011 close: deep probe hits `admin.auth().listUsers(1)`
      // which is a privileged IAM call. Unauthenticated callers could time
      // its variance to enumerate the clinician roster. Gate behind a shared
      // header that statuspage / our SRE on-call holds.
      const expected = process.env.HEALTHCHECK_TOKEN;
      const provided = req.headers["x-healthcheck-token"];
      if (!expected || provided !== expected) {
        res.set("Cache-Control", "no-store, max-age=0");
        res.status(401).json({
          status: "unauthorized",
          error: "deep_probe_requires_x-healthcheck-token_header",
        });
        return;
      }
      const results = await Promise.all([pingFirestore(), pingAuth()]);
      dependencies.push(...results);
    }
    const anyOutage = dependencies.some((d) => d.status === "outage");
    const anyDegraded =
      dependencies.some((d) => d.latency_ms > 800) ||
      dependencies.some((d) => d.status === "degraded");
    const status: Dependency["status"] = anyOutage
      ? "outage"
      : anyDegraded
        ? "degraded"
        : "ok";
    res.set("Cache-Control", "no-store, max-age=0");
    res.json({
      status,
      region: process.env.FUNCTION_REGION || "us-central1",
      released_at: RELEASE_VERSION,
      uptime_seconds: Math.round((Date.now() - BOOTED_AT) / 1000),
      dependencies,
    });
  }
);
