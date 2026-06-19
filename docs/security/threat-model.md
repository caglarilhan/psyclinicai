# Threat model — PsyClinicAI

**Last reviewed:** 2026-06-19 (Sprint 30)
**Owner:** sec-team@psyclinicai.com
**Methodology:** STRIDE, applied per trust boundary; high-level harm
mapped via OWASP API Security Top 10, OWASP LLM Top 10, ASVS L2.

This document is the source of truth referenced by the IR runbook
(§ 4, panel sign-off) and the pentest scope (`docs/security/pentest-2026q3.md`).
Quarterly review or after any SEV1/SEV2 incident.

---

## 1. Assets ranked by impact

| Asset | Impact if compromised | Owners |
|---|---|---|
| ePHI (session notes, transcripts, assessments) | HIPAA + GDPR breach, customer trust loss | clinical-wg + sec-team |
| Audit hash-chain integrity | Loss of regulatory defensibility, SOC 2 failure | sec-team |
| Tenant claim assignment | Cross-tenant data leak (existential) | platform-wg |
| LLM proxy token budget | Financial loss (runaway spend) | ai-wg + cost-control |
| Stripe webhook integrity | Subscription state corruption, dispute risk | billing-wg |
| WebAuthn credential store | Account takeover surface | auth-wg |
| Backup blobs (restic) | Long-term PHI exfil if compromised | sre-wg |
| Source code + CI secrets | Supply-chain risk | platform-wg |

## 2. Trust boundaries

1. **Browser ↔ Firebase Hosting (`psyclinicai.web.app`).**
2. **Browser ↔ Cloud Functions (`/v1/rag/**`, `llmProxy`, `stripeWebhook`).**
3. **Cloud Functions ↔ psyrag hub (`https://rag.psyclinicai.com`).**
4. **psyrag hub ↔ Postgres + Qdrant + Ollama (intra-container).**
5. **psyrag hub ↔ Groq / Gemini / Anthropic API (egress, non-PHI only).**
6. **Operator workstation ↔ Hetzner VM (`ssh ragsvc@…`).**
7. **GitHub Actions ↔ Firebase / Hetzner (CI deploy).**

## 3. STRIDE walkthrough per boundary

### 3.1 Browser ↔ Hosting (boundary 1)
- **S**poofing — defended by Firebase Auth + WebAuthn (S-01 rate limit).
- **T**ampering — defended by Cache-Control + Sub-Resource Integrity
  on critical assets (open: SRI not yet enforced; tracked as polish).
- **R**epudiation — audit chain (F-008 closed); hash-chain verified by
  `accessReviewCron`.
- **I**nformation disclosure — Referrer-Policy `no-referrer` on
  `/portal/session/**` (S-02), CSP (S-07).
- **D**oS — Firebase Hosting absorbs; Turnstile gates `beta_signups`.
- **E**oP — Firestore rules + tenant claim (S-03).

### 3.2 Browser ↔ Cloud Functions (boundary 2)
- **S** — `authorizeUid` gate on every handler.
- **T** — JSON schema enforcement + idempotency (B-09).
- **R** — Audit log append on every state change.
- **I** — LLM proxy strips system prompt; jailbreak regex (S-08).
- **D** — Per-function `minInstances` keeps cost predictable; rate
  limit primitive in `rate_limit.ts`.
- **E** — Cross-tenant rules + `is_platform_admin` claim guard on
  `adminSetTenantClaim`.

### 3.3 Cloud Functions ↔ psyrag hub (boundary 3)
- **S** — Dual-auth: X-Api-Key + Firebase ID token (F-003 closed).
- **T** — TLS 1.3 only; Caddy enforces.
- **R** — `request_id` correlation (B-03) → hub audit_log.
- **I** — `phi_filter.assert_clean` on every request body before LLM.
- **D** — Per-tenant hourly rate + daily USD cap (B-01).
- **E** — Hub never holds Firebase admin credentials; cannot privilege
  escalate back into Firestore.

### 3.4 Hub ↔ Postgres / Qdrant / Ollama (boundary 4)
- **S** — Intra-network only; not exposed to host.
- **T** — `max_connections=100` + slow-query log (D-04).
- **R** — append-only audit_log + cost_log.
- **I** — Postgres + Qdrant volumes restic-encrypted at backup time.
- **D** — `minInstances` for the rag-service container.
- **E** — Postgres role minimal; no superuser to the app.

### 3.5 Hub ↔ External LLM (boundary 5)
- **S** — API key in `.env`, never logged.
- **T** — TLS pinned via httpx local-address IPv4 binding (workaround
  for the Hetzner IPv6 stall noted in `llm_router.py`).
- **R** — `cost_log` row per call.
- **I** — `has_phi=True` is hard-routed to local Ollama; external LLM
  never sees PHI.
- **D** — Daily USD cap (B-01) + GROQ paid kill-switch (D-09).
- **E** — Provider has no callback into our infra.

### 3.6 Operator ↔ Hetzner VM (boundary 6)
- **S** — SSH key-only; password auth disabled (install.sh §SSH).
- **T** — fail2ban; `MaxAuthTries 3`.
- **R** — `auth.log` weekly review (workforce training §8).
- **I** — Operator does not need to read PHI; production access
  least-privilege.
- **D** — `ufw` 22/80/443 only.
- **E** — `sudo` requires explicit ticket (workforce training §3).

### 3.7 GitHub Actions ↔ Firebase / Hetzner (boundary 7)
- **S** — OIDC where possible (Firebase token via official action).
- **T** — Pinned action SHAs for the security-sensitive actions
  (open: not all actions are SHA-pinned; tracked as polish).
- **R** — Per-deploy commit SHA in CHANGELOG link.
- **I** — Secrets fetched at runtime; never echoed.
- **D** — Concurrency group cancels in-flight redundant runs (`ci.yml`).
- **E** — Deploy workflow gated on protected branch + reviewers.

## 4. Out-of-scope (documented + risk-accepted)

| Threat | Why out of scope | Risk acceptance owner |
|---|---|---|
| Clinician workstation compromise | Outside our control; mitigated by on-device encryption + auto-logout | ciso-advisor |
| Pilot clinician phishing of patient | Clinician's own responsibility; we publish patient-portal best practice | clinical-wg |
| Firebase platform compromise | Trust Google's SOC 2; track public security advisories | sec-team |
| Anthropic / Groq API compromise | BYOK for PHI; non-PHI requests have zero patient data | ai-wg |

## 5. High-residual-risk items (open)

| Risk | Mitigation in flight | Tracked at |
|---|---|---|
| Qdrant single-node SPOF on CX22 | Migration plan in `docs/security/qdrant-spof.md` | Sprint 31 |
| Local DB SQLCipher fresh — needs regression test that grep'ing the file bytes does not reveal plaintext | `test/security/local_db_encryption_test.dart` queued | Sprint 30 P phase |
| SOC 2 evidence collector not yet automated | Quarterly manual snapshot for now | Sprint 31 |
| Turkish red-team — long tail of jailbreak phrasings | Continuous regex refresh (S-08) | Ongoing |
