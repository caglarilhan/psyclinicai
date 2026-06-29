// Helper wrappers that let existing Cloud Functions HTTPS handlers
// opt into the N24 + N25 + N27 wire-up modules with two added lines
// at the top of each handler:
//
//   applySecurityHeaders(res);
//   if (await applyRateLimit(req, res, 'ai-copilot-inference')) return;
//
// The existing `applyCors(req, res)` call from lib/auth.ts stays —
// we don't rip out an already-deployed CORS surface in the same PR.
// CORS migration to the N27 dynamic allowlist ships separately.
//
// Out of scope (separate PRs):
//   * Migrate every HTTPS handler from inline lib/env.ts allow-list
//     to the N27 dynamic catalog. ragProxy + llmProxy are the only
//     opt-in users for now.
//   * Bind N25 lockout-after-N to the auth handler's failure path.

import type { Request, Response } from 'express';

import { SECURITY_HEADERS } from '../middleware/security_headers';
import {
  rateLimitFor,
  type EndpointClass,
} from '../middleware/rate_limit';

/**
 * Emit the 8 pinned security headers on the response. Always safe
 * to call early — headers are buffered until the response body is
 * flushed.
 */
export function applySecurityHeaders(res: Response): void {
  for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
    res.setHeader(name, value);
  }
}

/**
 * Apply the N25 rate-limit policy for the given endpoint class.
 * Returns `true` when the request was throttled / locked out + the
 * 429 response was already sent (caller should `return` immediately).
 * Returns `false` when the request is allowed through.
 */
export function applyRateLimit(
  req: Request,
  res: Response,
  endpointClass: EndpointClass,
): boolean {
  let throttled = true;
  const next = () => {
    throttled = false;
  };
  rateLimitFor(endpointClass)(req, res, next);
  return throttled;
}
