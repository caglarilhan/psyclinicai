/// N24 wire-up — Express middleware that emits the pinned security
/// headers from `lib/services/security/security_headers_catalog.dart`
/// on every Cloud Functions response.
///
/// Source of truth lives on the Dart side (the catalog). This module
/// MIRRORS those values. A parity test in
/// `test/security_headers_catalog_ts_parity_test.dart` reads this
/// file at flutter-test time and asserts every value matches the
/// catalog — drift fails the build.
///
/// **Out of scope** (separate PRs): Firebase Hosting header block
/// in `firebase.json` is configured separately because Hosting CDN
/// can't run an Express middleware. Both must stay in sync; the
/// parity test covers both paths.

import type { Request, Response, NextFunction } from 'express';

/**
 * Headers mirrored from the Dart catalog. Adding / changing a header
 * here requires the corresponding change on the Dart side, otherwise
 * the parity test will fail the build.
 */
export const SECURITY_HEADERS: Record<string, string> = {
  'Strict-Transport-Security':
    'max-age=63072000; includeSubDomains; preload',
  'Content-Security-Policy':
    "default-src 'self'; script-src 'self' 'strict-dynamic'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'; upgrade-insecure-requests",
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy':
    'camera=(), microphone=(self), geolocation=(), payment=(), usb=(), accelerometer=(), gyroscope=(), magnetometer=()',
  'Cross-Origin-Opener-Policy': 'same-origin',
  'Cross-Origin-Embedder-Policy': 'require-corp',
};

/**
 * Express middleware. Apply early in the chain so headers are set
 * before any route handler can override them (override is a defect,
 * not a feature — pen test will probe for this).
 *
 * Usage in `functions/src/index.ts`:
 * ```ts
 * import { securityHeaders } from './middleware/security_headers';
 * app.use(securityHeaders);
 * ```
 */
export function securityHeaders(
  _req: Request,
  res: Response,
  next: NextFunction,
): void {
  for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
    res.setHeader(name, value);
  }
  next();
}
