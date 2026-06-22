# Changelog

All notable changes to PsyClinicAI ship here.
Format follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Beta cohort releases tag as `1.0.0-beta.N`; first public release is `1.0.0`.

## [Unreleased]

### Added
- **Sprint 29 (Production hardening)** — disaster-recovery RTO/RPO tier table (`docs/STATUS.md`), backup retention policy (HIPAA §164.316(b) 6-y), `CHANGELOG.md` + SemVer release process.
- CI: Firestore rules now deploy alongside the web bundle in `deploy_web.yml` (single source of truth, no drift).
- Postgres: hard `max_connections=100` cap and 1 000 ms slow-query log threshold for SLO triage (`psyrag/docker-compose.yml`).
- Launch-readiness punch list under `docs/launch/LAUNCH-READINESS-PUNCHLIST.md` — 19 blockers, 22 important, 19 polish across 5 tracks.
- **B-01** Per-tenant LLM daily cost cap (`psyrag/backend/cost_ledger.py`, new Postgres `cost_log` table + `clients.daily_cost_cap_usd` column, HTTP 429 gate in `verify_auth`).
- **B-02** Alembic forward migration scaffold (`psyrag/alembic.ini`, `alembic/env.py`, `versions/0001_baseline_stamp.py`) + `alembic upgrade head` step in `deploy/install.sh`.
- **B-03** `request_id` correlation middleware (`psyrag/backend/main.py`) — UUID stamped on every request, surfaced in `X-Request-Id` header + error envelopes + structured logs.
- **B-06** Python observability dependencies (`sentry-sdk[fastapi]==2.18.0`, `python-json-logger==2.0.7`, `prometheus-client==0.21.0`).
- **S-01** WebAuthn per-IP rate-limit primitive (`functions/src/lib/rate_limit.ts`) wired into `passkeyAuthOptions` + `passkeyAuthVerify` (20 req / 15 min / IP, F-004 close).
- **S-02** Telehealth `Referrer-Policy: no-referrer` + `Permissions-Policy` on `/portal/session/**` (F-007 close).
- **S-03** `setTenantClaim` Cloud Function (`functions/src/setTenantClaim.ts`) — Auth `onCreate` assigns `tenant_id` claim; `adminSetTenantClaim` HTTPS callable for re-bind.
- **S-04** Incident-response runbook (`docs/security/incident-response.md`) — HIPAA §164.308(a)(6) + GDPR Art. 32, SEV1–4 matrix, skill-panel sign-off.
- **S-06** SQLCipher + keychain audit (`docs/security/sqlcipher-keychain-audit.md`) + F-013 ledger row.
- **S-08** Turkish jailbreak regex refresh in `functions/src/lib/llm_safety.ts` (5 new patterns: role-strip, system-prompt leak, sıfırla / boş ver verbs).
- **D-07** Sentry SDK init in `psyrag/backend/main.py` (no-op until `SENTRY_DSN` set, env- and release-tagged).
- **D-08** Prometheus `/metrics` endpoint on the RAG hub (`psyrag_requests_total`, `psyrag_request_seconds`, `psyrag_llm_cost_usd_total`).
- **D-09** `GROQ_PAID_TIER_ENABLED` kill-switch (default OFF) in `psyrag/backend/llm_router.py`; free-tier model when paid disabled.
- **D-10** `runWith({minInstances:1, region:"europe-west1"})` on `ragProxy` + `llmProxy` (cold-start UX + EU residency).
- **B-04** `audit_logs` Firestore rule hardened with schema-shape assertions (`clinic_id is string`, `event_type is string`, `ts is timestamp`); new `webauthn_rate_limits` + `processed_webhooks` collections locked deny-all client.
- **B-09** Stripe webhook idempotency via `processed_webhooks/{event.id}` transactional ledger in `functions/src/stripe_connect.ts`.
- **F-01** Loom placeholder URL removed from `lib/widgets/landing/demo_modal.dart` (pre-launch CTA pair preserved).
- **F-02** Web PWA manifest rebranded (`web/manifest.json`): name, description, brand colours, `categories: ["medical","productivity","health"]`, 3 shortcuts.
- **F-04** Hero "Watch 90-sec demo" TextButton padded to 18 pt vertical + `minimumSize: Size(0, 48)` (WCAG 2.5.5 / Apple HIG 44 pt).
- **F-06** Dashboard KPI cards now render `KpiState.{loading|data|error}` explicitly with animated skeleton + Retry action.
- **P-01** Telemetry funnel taxonomy extended (`landing.visit`, `landing.beta_waitlist_submitted`, `session.first_soap_generated`, `session.soap_generated`, `billing.payment_initiated/succeeded/failed`).
- **P-02** Landing route map fixed — `/baa` and `/dpa` reach dedicated pages instead of redirecting to `/privacy`; `/roadmap`, `/help` routed correctly.
- **P-05** Hero copy tightened for ICP: "The AI co-pilot for therapists and psychiatrists" + DSM-aligned condition list.
- **P-07** Founding Member Pilot Agreement template (`docs/PILOT-AGREEMENT.md`) confirmed present, linked from punch list.
- **P-08** Sendgrid welcome triggers (`functions/src/waitlist_email.ts`) — `onLandingWaitlistCreate` + `onBetaSignupCreate`; no-op until secrets set.
- **P-09** Public `/roadmap` page (`lib/screens/static/roadmap_page.dart`) — Wave A / Wave B / Compliance / Differentiators / GA milestones + "not shipping in 2026" section.
- Vendor unlocks checklist (`docs/launch/vendor-unlocks.md`) — Hetzner Storage Box, Stripe, PostHog, Sendgrid, Turnstile, Workspace, Loom, counsel, custom domain, Sentry ×3.

### Changed
- CI test job (`.github/workflows/ci.yml`) is now strict — `flutter test` failures fail the build. Sprint 3 `continue-on-error` workaround removed.
- `psyrag/backend/auth.py` fails fast in production when `DEFAULT_TENANT_ID` is non-empty (open-signup posture must be explicit dev/pilot only). Open-signup fallback now WARN-logs every fire.

### Security
- Pentest ledger appended F-013 (offline_service.dart plaintext SQLite — Wave A risk-accepted, Sprint 30 fix planned).
- See `docs/security/findings.csv` for full pentest ledger. Sprint 29 closes F-004 (WebAuthn per-IP rate limit) and F-007 (telehealth Referrer-Policy).

### Added (Sprint 30 — Phases L–O)
- **F-05** Inline validation on patient intake form (email + phone + emergency contact).
- **F-03 (partial)** `Semantics(label:)` wrapper on landing founding-access pill for screen readers.
- **F-02 dark PWA** — `theme-color` meta now media-queried so dark mode renders correctly.
- **S-06** SQLCipher real fix — `LocalDbKeyService` (keychain-backed passphrase) + `offline_service.dart` swapped to `sqflite_sqlcipher` (v2 DB filename so plaintext file is never reused as encrypted). HIPAA §164.312(a)(2)(iv) satisfied on-device.
- **S-07** CSP meta `Content-Security-Policy` reinstated in `web/index.html` with Flutter Web's minimum directives (script-src self + wasm-unsafe-eval; connect-src self + Firebase + hub + Sentry + PostHog + Stripe).
- **S-05** GDPR Art. 28 Annex II subprocessor matrix published at `docs/legal/SUBPROCESSORS.md` (12 subprocessors across infra / AI / payments / observability / ops).
- **B-05** 25 new clinical vignettes (PSY-EV-031..055) covering PTSD, OCD, ADHD, bipolar, eating disorders, postpartum, peri-menopausal, sleep, ICD-10-CM/CPT coding, HIPAA/GDPR, suicide screening, Ryan Haight Act, FBT. Total 55.
- **B-05** Cohere reranker scaffold in `psyrag/backend/rag.py` (`_cohere_rerank` no-op without `COHERE_API_KEY`; 3× over-fetch then rerank).
- **B-08** Monthly restore drill — `ragsvc-restore-drill.sh` + systemd `.service` + `.timer` (first Monday 04:15 UTC) + install.sh wires it.
- **Firestore indexes** — `patients(status, updatedAt)`, `audit_logs(clinic_id, ts)`, `beta_signups(region, created_at)`.
- **Slack signup hook** — `functions/src/slack_notify.ts` `onBetaSignupSlack` (no-op without `SLACK_SIGNUP_WEBHOOK`).
- **Caddy cert expiry monitor** — `psyrag/deploy/check-cert-expiry.sh` (cron-friendly, append-only log).

### Changed (Sprint 30)
- `lib/config/build_config.dart` removed deprecated `ragBaseUrl` + `ragApiKey` (no consumer).
- `psyrag/backend/llm_router.py` `_call_groq` now returns `(answer, model)` so the cost ledger can record the actual model used.

### Security (Sprint 30)
- F-013 — code fix in flight: S-06 SQLCipher + key service shipped; next step is the re-key migration test (`test/security/local_db_encryption_test.dart`).

### Added (Sprint 30 — Phases Q–S)
- **SEO** — sitemap.xml now lists 19 routes (added /roadmap, /faq, /pricing, /compare, /baa, /dpa, /beta, /trust); robots.txt blocks GPTBot / ClaudeBot / anthropic-ai / CCBot / Google-Extended training crawlers; disallow PHI surfaces (/portal, /superbill, /session, /api/).
- **Schema.org** — FAQPage rich-result + Organization knowledge-graph in `web/index.html` (3 ld+json blocks now).
- **Marketing** — Public launch kit at `docs/marketing/launch-kit.md` (ProductHunt + HN Show + Indie Hackers + X + LinkedIn templates + 12 press outlets).
- **Compliance** — Workforce security training programme (`docs/security/workforce-training.md`, 8 modules + sanctions matrix) addressing HIPAA §164.308(a)(5).
- **Compliance** — STRIDE threat model (`docs/security/threat-model.md`) per the 7 trust boundaries.
- **Compliance** — Qdrant SPOF migration plan (`docs/security/qdrant-spof.md`) — 5 options compared, Sprint 31 daily-snapshot recommendation.
- **Test coverage** — `test/security/local_db_key_service_test.dart` — 6/6 tests covering S-06 key service (idempotent, 32-byte key, base64Url-safe, rotation, fresh-store entropy).
- **Founders email CF** — `functions/src/founders_email.ts` `onBetaSignupFoundersEmail`; Sendgrid template + plain-text fallback so it ships value pre-template.
- **Cert expiry sentinel timer** — `psyrag/deploy/systemd/ragsvc-cert-check.{service,timer}` + install.sh enables it (daily 04:17 UTC).
- **Total test count** rose from 842 → 848 (+6 LocalDbKeyService).

## [1.0.0-beta.0] — 2026-06-18

### Added
- **Sprint 28** — `psyrag` hub live at `rag.psyclinicai.com` with Firebase ID-token dual-auth, Trust Center `RagStatusCard`, public `/beta` wait-list.
- Eval harness baseline (`psyrag/scripts/eval_vignettes.py`).

### Security
- F-006 (Stripe webhook replay window), F-011 (healthcheck DoS) closed → `fixed_pending_retest`.
- Internal audit (code-reviewer + security-reviewer) closed 5/11 critical+high items.

## [0.27.0] — 2026-06-10

### Added
- **Sprint 27 deploy** — wire psyrag hub live, real Firebase web config in `lib/firebase_options.dart`.
- CARC top-50 denial-hint mapping; EHR FHIR R4 bridge scaffold (endpoint allowlist + outbox key).
- Patient portal service worker + kiosk auto-logout (F-009 closed).
- Single-use 24-h patient invite token (F-012 closed).

### Security
- F-001 LLM jailbreak reject + `SYSTEM_FROZEN` fence + per-tenant hourly quota.
- F-003 RAG API-key moved to Cloud Functions proxy (no more `--dart-define` plaintext).
- F-008 audit-chain verify in `accessReviewCron`.

[Unreleased]: https://github.com/caglarilhan/psyclinicai/compare/v1.0.0-beta.0...HEAD
[1.0.0-beta.0]: https://github.com/caglarilhan/psyclinicai/compare/v0.27.0...v1.0.0-beta.0
[0.27.0]: https://github.com/caglarilhan/psyclinicai/releases/tag/v0.27.0
