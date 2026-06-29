/// N25 wire-up — Express rate-limit middleware mirroring the Dart
/// catalog `lib/services/security/api_rate_limit_catalog.dart`.
///
/// Token-bucket per (tenantId, endpointClass), in-process memory.
/// Production wiring switches the bucket store to Firestore / Redis
/// in a follow-up PR; the contract surface stays the same.
///
/// Source of truth is the Dart catalog. Drift between this file and
/// the catalog is caught at flutter-test time by
/// `test/rate_limit_wire_parity_test.dart`.
///
/// **Out of scope** (separate PRs):
///   * Firestore-backed bucket store for multi-instance scale.
///   * Adaptive throttle (tighten on attack signal).
///   * Per-tenant overage billing.
///   * index.ts route-by-route binding of rateLimitFor(...).

import type { Request, Response, NextFunction } from 'express';

export type EndpointClass =
  | 'auth-login'
  | 'public-unauthenticated'
  | 'clinician-dashboard-read'
  | 'ai-copilot-inference'
  | 'portal-dsar'
  | 'internal-admin'
  | 'webhook-ingestion';

interface RateLimitRecord {
  readonly perMinute: number;
  readonly burst: number;
  readonly bruteForceSensitive: boolean;
}

/**
 * Limits mirrored from the Dart catalog. Drift detector tests on the
 * Dart side enforce parity.
 */
export const RATE_LIMITS: Readonly<Record<EndpointClass, RateLimitRecord>> = {
  'auth-login': {
    perMinute: 10,
    burst: 0,
    bruteForceSensitive: true,
  },
  'public-unauthenticated': {
    perMinute: 60,
    burst: 30,
    bruteForceSensitive: false,
  },
  'clinician-dashboard-read': {
    perMinute: 600,
    burst: 300,
    bruteForceSensitive: false,
  },
  'ai-copilot-inference': {
    perMinute: 30,
    burst: 10,
    bruteForceSensitive: false,
  },
  'portal-dsar': {
    perMinute: 20,
    burst: 5,
    bruteForceSensitive: false,
  },
  'internal-admin': {
    perMinute: 300,
    burst: 100,
    bruteForceSensitive: false,
  },
  'webhook-ingestion': {
    perMinute: 600,
    burst: 600,
    bruteForceSensitive: false,
  },
};

const LOCKOUT_FAILURES = 5;
const LOCKOUT_WINDOW_MS = 60 * 1000;
const LOCKOUT_DURATION_MS = 15 * 60 * 1000;

interface Bucket {
  tokens: number;
  lastRefillMs: number;
}

interface LockoutState {
  failures: number;
  windowStartMs: number;
  lockedUntilMs: number;
}

const buckets: Map<string, Bucket> = new Map();
const lockouts: Map<string, LockoutState> = new Map();

/**
 * Clock injection for tests. Production reads Date.now().
 */
export let nowMs: () => number = () => Date.now();
export function setNowForTest(fn: () => number): void {
  nowMs = fn;
}
export function resetNow(): void {
  nowMs = () => Date.now();
}

export function resetStoreForTest(): void {
  buckets.clear();
  lockouts.clear();
}

/**
 * Resolves the tenantId for rate-limit scoping. Falls back to
 * request IP on unauthenticated endpoints (so a single IP can't
 * exhaust the public-unauthenticated bucket).
 */
function scopeKey(req: Request, endpointClass: EndpointClass): string {
  const tenant = (req as Request & { tenantId?: string }).tenantId;
  if (tenant) return `${endpointClass}:${tenant}`;
  const ip =
    (req.headers['x-forwarded-for'] as string | undefined)
      ?.split(',')[0]
      ?.trim() ?? req.ip ?? 'unknown';
  return `${endpointClass}:ip:${ip}`;
}

/**
 * Token-bucket consumer. Returns true when the request is allowed,
 * false when throttled.
 */
function tryConsume(
  key: string,
  perMinute: number,
  burst: number,
): boolean {
  const now = nowMs();
  const capacity = perMinute + burst;
  const refillRatePerMs = perMinute / 60_000;

  const bucket = buckets.get(key) ?? {
    tokens: capacity,
    lastRefillMs: now,
  };
  const elapsedMs = Math.max(0, now - bucket.lastRefillMs);
  bucket.tokens = Math.min(
    capacity,
    bucket.tokens + elapsedMs * refillRatePerMs,
  );
  bucket.lastRefillMs = now;

  if (bucket.tokens < 1) {
    buckets.set(key, bucket);
    return false;
  }
  bucket.tokens -= 1;
  buckets.set(key, bucket);
  return true;
}

/**
 * Lockout tracker for brute-force-sensitive endpoints.
 * Returns true when the key is currently locked out.
 */
function isLockedOut(key: string): boolean {
  const state = lockouts.get(key);
  if (!state) return false;
  return state.lockedUntilMs > nowMs();
}

/**
 * Record an authentication failure. Triggers lockout after
 * LOCKOUT_FAILURES failures within LOCKOUT_WINDOW_MS.
 *
 * Bind this to the auth handler when the credentials fail.
 */
export function recordAuthFailure(key: string): void {
  const now = nowMs();
  const state = lockouts.get(key) ?? {
    failures: 0,
    windowStartMs: now,
    lockedUntilMs: 0,
  };
  if (now - state.windowStartMs > LOCKOUT_WINDOW_MS) {
    state.failures = 0;
    state.windowStartMs = now;
  }
  state.failures += 1;
  if (state.failures >= LOCKOUT_FAILURES) {
    state.lockedUntilMs = now + LOCKOUT_DURATION_MS;
  }
  lockouts.set(key, state);
}

/**
 * Build the scope key the same way the middleware does — used by
 * the auth handler when calling `recordAuthFailure` so the key
 * matches the rate-limit scope.
 */
export function scopeKeyFor(
  req: Request,
  endpointClass: EndpointClass,
): string {
  return scopeKey(req, endpointClass);
}

/**
 * Express middleware factory. Returns a middleware bound to the
 * given endpoint class.
 *
 * Usage:
 * ```ts
 * import { rateLimitFor } from './middleware/rate_limit';
 * app.post('/login', rateLimitFor('auth-login'), loginHandler);
 * app.post('/copilot', rateLimitFor('ai-copilot-inference'), copilotHandler);
 * ```
 */
export function rateLimitFor(endpointClass: EndpointClass) {
  const limits = RATE_LIMITS[endpointClass];
  return function rateLimit(
    req: Request,
    res: Response,
    next: NextFunction,
  ): void {
    const key = scopeKey(req, endpointClass);
    if (limits.bruteForceSensitive && isLockedOut(key)) {
      res.setHeader('Retry-After', '900');
      res.status(429).json({
        error: 'locked_out',
        retryAfterSeconds: 900,
      });
      return;
    }
    if (!tryConsume(key, limits.perMinute, limits.burst)) {
      res.setHeader('Retry-After', '60');
      res.status(429).json({
        error: 'rate_limited',
        retryAfterSeconds: 60,
      });
      return;
    }
    next();
  };
}
