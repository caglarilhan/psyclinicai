/// N27 wire-up — Express middleware that enforces the CORS
/// allow-origin policy from
/// `lib/services/security/cors_allowed_origin_catalog.dart`.
///
/// Reads the requesting Origin header, checks it against the
/// per-deployment-slot allowlist, and only emits
/// `Access-Control-Allow-Origin` (+ `Access-Control-Allow-Credentials`
/// when applicable) for entries in the catalog. Wildcard `*` is
/// never emitted — that defeats CORS for credentialled requests.
///
/// Source of truth is the Dart catalog. Drift between this file
/// and the catalog is caught at flutter-test time by
/// `test/cors_wire_parity_test.dart`.
///
/// **Out of scope** (separate PRs):
///   * `index.ts` wiring `app.use(cors)` into the Express chain.
///   * Per-route Access-Control-Allow-Methods narrowing (today the
///     reflected methods are the browser preflight default).
///   * Preflight cache TTL tuning via Access-Control-Max-Age.

import type { Request, Response, NextFunction } from 'express';

export type DeploymentSlot = 'local' | 'preview' | 'staging' | 'production';

interface CorsOrigin {
  readonly origin: string;
  readonly slots: ReadonlySet<DeploymentSlot>;
  readonly allowCredentials: boolean;
}

/**
 * Allowlist mirrored from the Dart catalog. Any change here MUST be
 * mirrored on the Dart side; parity test catches drift.
 */
export const CORS_ALLOWED_ORIGINS: ReadonlyArray<CorsOrigin> = [
  {
    origin: 'https://app.psyclinicai.com',
    slots: new Set(['production']),
    allowCredentials: true,
  },
  {
    origin: 'https://www.psyclinicai.com',
    slots: new Set(['production']),
    allowCredentials: false,
  },
  {
    origin: 'https://staging.psyclinicai.com',
    slots: new Set(['staging']),
    allowCredentials: true,
  },
  {
    origin: 'https://preview.psyclinicai.com',
    slots: new Set(['preview']),
    allowCredentials: true,
  },
  {
    origin: 'http://localhost:8080',
    slots: new Set(['local']),
    allowCredentials: true,
  },
];

/**
 * Resolves the active deployment slot from env. Default = 'local'
 * for safety (least privilege — never assume prod).
 */
export function currentSlot(): DeploymentSlot {
  const raw = (process.env.DEPLOYMENT_SLOT ?? 'local').toLowerCase();
  if (
    raw === 'local' ||
    raw === 'preview' ||
    raw === 'staging' ||
    raw === 'production'
  ) {
    return raw;
  }
  return 'local';
}

/**
 * Returns true when the origin is allowed for the given slot.
 */
export function isOriginAllowed(
  origin: string,
  slot: DeploymentSlot,
): boolean {
  for (const entry of CORS_ALLOWED_ORIGINS) {
    if (entry.origin === origin && entry.slots.has(slot)) return true;
  }
  return false;
}

/**
 * Express middleware. Apply after `securityHeaders` so its headers
 * are still set on disallowed origins (defense-in-depth).
 *
 * Usage in `functions/src/index.ts`:
 * ```ts
 * import { cors } from './middleware/cors';
 * app.use(cors);
 * ```
 */
export function cors(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const origin = (req.headers.origin as string | undefined) ?? '';
  const slot = currentSlot();

  if (origin === '') {
    // Same-origin request (browser does not send Origin). Continue
    // without emitting any Access-Control headers.
    next();
    return;
  }

  if (!isOriginAllowed(origin, slot)) {
    // Disallowed origin — do not echo it, do not allow credentials.
    // Preflight will fail at the browser; non-preflight reads will
    // fail the CORS check.
    if (req.method === 'OPTIONS') {
      res.status(403).end();
      return;
    }
    next();
    return;
  }

  // Allowed — echo Origin (not '*'), set Vary so caches don't merge
  // responses across origins.
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin');

  const entry = CORS_ALLOWED_ORIGINS.find((e) => e.origin === origin)!;
  if (entry.allowCredentials) {
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }

  if (req.method === 'OPTIONS') {
    const reqMethod = req.headers['access-control-request-method'] as
      | string
      | undefined;
    const reqHeaders = req.headers['access-control-request-headers'] as
      | string
      | undefined;
    if (reqMethod) {
      res.setHeader(
        'Access-Control-Allow-Methods',
        reqMethod.toUpperCase(),
      );
    }
    if (reqHeaders) {
      res.setHeader('Access-Control-Allow-Headers', reqHeaders);
    }
    res.setHeader('Access-Control-Max-Age', '600');
    res.status(204).end();
    return;
  }

  next();
}
