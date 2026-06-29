# Phase 2 — middleware wire-up plan

After the 80 catalog PRs land on main (`bash
docs/handoff/merge-all-clean.sh`), these are the next PRs that
convert *policy* (the const tables) into *enforcement* (runtime
middleware). Each is small (~150-300 lines), independent, and ships
with its own integration test.

Execution order:

## P1 — Security headers emitter (consumes N24)

**Branch**: `feat/wire-security-headers-middleware`

**Files touched**:
- `functions/src/middleware/security_headers.ts` (NEW) — reads
  `SecurityHeadersCatalog.records` (via codegen at build time or
  manual port) and emits headers on every Cloud Functions response.
- `web/index.html` (EDIT) — meta http-equiv mirrors for client-rendered
  routes; HSTS / CSP already shippable as response headers from
  Firebase Hosting `firebase.json` `headers` block.
- `firebase.json` (EDIT) — append the static-headers block from N24.
- `functions/src/__tests__/security_headers.test.ts` (NEW) — verify
  every response contains every catalog header with the pinned value.

**Done when**:
- E2E test: `curl -I https://app.psyclinicai.com/` returns all 8 N24
  headers with exact pinned values.
- Integration test: a synthetic request through Cloud Functions
  asserts each header is set.

## P2 — Rate limiter (consumes N25)

**Branch**: `feat/wire-rate-limit-middleware`

**Files touched**:
- `functions/src/middleware/rate_limit.ts` (NEW) — token-bucket per
  `(tenantId, endpointClass)`, backed by Firestore (or Redis if the
  count grows). Reads `ApiRateLimitCatalog.byEndpointClass(c)` for
  the cap + burst.
- `functions/src/middleware/auth_login_lockout.ts` (NEW) — N25's
  `bruteForceSensitive=true` triggers lockout-after-5 (account + IP)
  alongside the throttle.
- `functions/src/__tests__/rate_limit.test.ts` (NEW) — fires 11
  requests in 60 seconds on `auth-login` endpoint, asserts request
  11 is 429.

**Done when**:
- Penetration test on auth-login → throttle fires after 10
  requests/min/tenant.
- Integration test passes with synthetic clock.

## P3 — CORS gate (consumes N27)

**Branch**: `feat/wire-cors-middleware`

**Files touched**:
- `functions/src/middleware/cors.ts` (NEW) — reads
  `CorsAllowedOriginCatalog.forSlot(currentSlot)`. Slot detected
  from `process.env.DEPLOYMENT_SLOT` (added to O9 if missing).
- `functions/src/__tests__/cors.test.ts` (NEW) — synthetic Origin
  header from every allowed + 1 disallowed origin; asserts the
  response Access-Control-Allow-Origin header.

**Done when**:
- Synthetic origin from `https://evil.example.com` → no
  Access-Control-Allow-Origin header in response.
- Synthetic origin from `https://app.psyclinicai.com` →
  Access-Control-Allow-Credentials: true + correct Origin echoed.

## P4 — Scheduled job runner (consumes O10)

**Branch**: `feat/wire-scheduled-jobs`

**Files touched**:
- `functions/src/scheduled/index.ts` (NEW) — one Cloud Function per
  `ScheduledJobCatalog.records` entry, scheduled via `pubsub.schedule`
  with the cadence label parsed to cron.
- Each job is an idempotent stub that increments a counter +
  publishes a metric (real implementations follow in family PRs).
- `functions/src/__tests__/scheduled_jobs.test.ts` (NEW) — every
  catalog entry has a corresponding Cloud Function exported; cadence
  label parses cleanly to a cron expression.

**Done when**:
- All 8 scheduled-job catalog entries map to deployed Cloud Functions.
- Their first synthetic run logs the expected metric.

## P5 — Trust center catalog renderer (consumes everything)

**Branch**: `feat/trust-center-catalog-page`

**Files touched**:
- `lib/screens/static/trust_center_catalogs_page.dart` (NEW) —
  reads `docs/handoff/CATALOG-INDEX.md` (or rebuilds from imports)
  and renders the same table at `/trust/catalogs`.
- `lib/widgets/trust/catalog_card.dart` (NEW) — single-row presenter
  with the `lastReviewed` "needs review" badge logic baked in.

**Done when**:
- `/trust/catalogs` route loads + shows all 77+ catalogs with their
  regulatory anchors.
- `lastReviewed > 12 months ago` → warning badge surfaces.

## Estimated effort

- P1: ~2 hours (smallest; headers are static)
- P2: ~4 hours (state-keeping + lockout logic)
- P3: ~2 hours (similar to P1 but request-side)
- P4: ~3 hours (8 cron functions + tests)
- P5: ~4 hours (UI + cards + a11y review)

**Sequential total**: ~15 hours. Parallel: P1 + P3 together (no
dependency overlap), then P2 + P4, then P5.

## Why this order

P1 first because it has zero state-keeping — pure const-to-header
mapping. Lands fastest, unblocks others. P2-P4 build state. P5
consumes the merged main + the wire-up PRs as evidence.

## Done with all 5 = production ready

When P1-P5 are merged:
- Every catalog has both its policy table AND its runtime
  enforcement.
- The trust center page renders the live policy index.
- Pen test against the deployed Cloud Functions verifies each
  policy is enforced (not just documented).

That is the moment to manually trigger `deploy_web.yml` (Hetzner
VPS prod). Demo at GitHub Pages already auto-publishes on every
main push (see `.github/workflows/pages.yml`).
