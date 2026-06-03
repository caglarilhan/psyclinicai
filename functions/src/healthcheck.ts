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
  } catch (_) {
    return {
      name: "firestore",
      status: "outage",
      latency_ms: Date.now() - started,
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
  } catch (_) {
    return {
      name: "firebase_auth",
      status: "outage",
      latency_ms: Date.now() - started,
    };
  }
}

export const healthcheck = functions.https.onRequest(
  async (req, res) => {
    const deep = req.query.deep !== undefined;
    const dependencies: Dependency[] = [];
    if (deep) {
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
