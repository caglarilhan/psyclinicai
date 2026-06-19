# PsyClinicAI — Live System Status

> One-page snapshot of what's running, who reaches it, and how the
> stack hangs together. Update at each sprint closeout.

**Last updated:** 2026-06-19 (Sprint 28 closeout)
**Skill panel:** 9.2 / 10
**Live URLs:** 2 production, 0 staging
**Monthly cost:** €4 (Hetzner CX22) — Firebase + Groq free tier covers the rest

---

## Live surfaces

| Layer | URL | Provider | Status |
|---|---|---|---|
| Web app | https://psyclinicai.web.app | Firebase Hosting (psyclinicai) | ✅ 200 |
| Web app `/beta` wait-list | https://psyclinicai.web.app/#/beta | Firebase Hosting | ✅ 200 |
| Web app `/ai/rag` console | https://psyclinicai.web.app/#/ai/rag | Firebase Hosting | ✅ behind Email/Password auth |
| Clinical RAG hub | https://rag.psyclinicai.com/api/rag/health | Hetzner CX22 (Nuremberg) | ✅ 200, qdrant_docs: 21 |
| GitHub repo — app | https://github.com/caglarilhan/psyclinicai | private | active branch `feat/sprint-26-close-rag-pentest` (PR #2) |
| GitHub repo — hub | https://github.com/caglarilhan/psyrag | private | branch `main` |

---

## Stack diagram

```
                      ┌──────────────────────────────────────┐
  EU / US clinicians  │  psyclinicai.web.app (Firebase Host) │
        │             │  - Email/Password sign-in            │
        ▼             │  - RAG console (/ai/rag)             │
  Firebase Auth ◄──────┤  - Patient portal PWA (Sprint 26)   │
        │             │  - Trust Center (Sprint 28 status)   │
        │             │  - Beta wait-list (/beta)            │
        ▼             └──────────┬───────────────────────────┘
   ID token                      │ Authorization: Bearer
        │                        ▼
        │      ┌────────────────────────────────────────┐
        │      │  rag.psyclinicai.com (Hetzner CX22)    │
        │      │  Caddy (auto-TLS) ──► uvicorn/FastAPI  │
        │      │  Dual-auth (X-Api-Key OR Bearer)       │
        │      │  CORS allow-list: web.app, .com, .fb   │
        │      └──┬──────────────┬──────────────┬───────┘
        │         │              │              │
        │      Qdrant         Postgres        Groq
        │      (vector,       (clients,      (Llama 3.3
        │      21 chunks)     audit,         70B free tier
        │                     feedback,      → Sprint 29
        │                     rate)          paid)
        │
        └──► Firestore (psyclinicai project)
             - users, beta_signups, audit_logs
             - rules: cross-tenant locked Sprint 28 (F-002)
```

---

## Pentest posture (pre-vendor maturity)

**External vendor:** Cure53 / NCC Group / Doyensec (shortlist) — engagement 2026-09-15.

| Severity | Closed (`fixed_pending_retest`) | Open |
|---|---|---|
| Critical | 2 | 0 |
| High | 4 | 0 |
| Medium | 5 | 2 |
| Low | 1 | 0 |
| **Total** | **10/12 (83%)** | **2** |

**Open:** F-004 (WebAuthn per-IP rate-limit), F-007 (telehealth Referrer-Policy). Both Sprint 29 P1.

**Sprint 28 internal audit (code-reviewer + security-reviewer)** raised 11 new items — top 5 already fixed this sprint; rest tracked in `sprint-29-plan.md`.

---

## What "production" can already do

- **Real Firebase Auth** — clinician signs up with email+password, lands on dashboard.
- **Clinical RAG console** (`/ai/rag`) — guideline-grounded answers from ICD-11, NICE, EMA, NHS, GKV, PubMed (21 chunks). 1-3s Groq Llama-3.3-70B inference. EU/US region filter. PHI-flag chip. Citations with source/country/score. Audit ID per answer.
- **Feedback loop** — thumbs up/down + free-text note per answer → Firestore feedback row, ready for weekly eval roll-up + future DPO fine-tune signal.
- **Trust Center** (`/trust`) — public-facing compliance posture, live infrastructure card (real health probe, inference-free).
- **WebAuthn passkeys** (Sprint 26) — sign-count regression, origin/RP-id rigid validation, transaction-based challenge consume.
- **Patient self-service PWA** (`/portal`) — appointment + inbox + PROM screens (read-only first cut, service worker auth-aware).
- **iOS Hand-off** — session continuity across devices (title-PHI-free after Sprint 28 F-010 close).
- **Beta wait-list** (`/beta`) — cold-outreach landing target, Firestore-backed with strict rule, support@ contact in failure copy.
- **Multi-region data residency** — eu-central + us-central per-tenant pin.
- **Audit log hash chain** (Sprint 26) — tamper-evident; verified by accessReviewCron before quarterly access reviews (Sprint 27 F-008).

## What it cannot do yet (production gaps)

- **Multi-tenant claims** — every Firebase user currently maps to the single `psyclinicai` tenant via `DEFAULT_TENANT_ID` fallback (pilot posture; Sprint 29 P0 to gate).
- **Groq paid tier** — free tier 14,400 TPD cap blocks 30-vignette batch eval. Sprint 29 P0.
- **Beta DoS protection** — direct unauthenticated Firestore write. Sprint 29 P0 (Cloudflare Turnstile + Cloud Function gate).
- **EHR write** — FHIR R4 Bridge scaffold exists; sandbox connect Sprint 29 (Epic + Cerner).
- **Payment** — Stripe Connect + Mollie UI shells exist; production keys + webhook subscribe Sprint 29-30.
- **Custom domain** — `psyclinicai.com` still on Hostinger landing (Sprint 29 P2 to redirect to Firebase Hosting).
- **iOS App Store** — submission package ready (Sprint 26), final review pending.
- **Mobile Android** — pubspec + screens exist, no Play Store release build yet.

---

## Tracked metrics (raw — for the founder dashboard)

| Metric | Today (2026-06-19) | Sprint 29 target | Sprint 30 target |
|---|---|---|---|
| Live URLs | 2 | 3 (+ custom domain) | 3 |
| Pentest closure rate | 83% | 100% (12/12) | retest pass |
| OWASP ASVS L2 self-audit | 85% | 92% | 95% |
| Knowledge base chunks | 21 | 50 (ingest improvements) | 200+ (licensed) |
| Eval pass rate | _not yet measured_ (Groq TPD cap) | ≥50% baseline | ≥70% |
| Active pilot clinicians | 0 | 5+ | 20+ |
| Beta wait-list signups | 0 | 25+ | 100+ |
| Groq monthly cost | $0 (free tier) | ~$90 (50 users) | ~$200 (200 users) |
| Lighthouse Performance | 78 | 90+ | 95+ |
| `flutter analyze` errors | 0 | 0 | 0 |
| Skill panel score | 9.2 | 9.3 | 9.4 |

---

## Operational handles

- **Server SSH:** `ssh -i ~/.ssh/psyrag_ed25519 ragsvc@46.225.181.130`
- **Hub deploy:** `cd ~/psyrag && bash deploy/upload-and-install.sh` (see `~/psyrag/DEPLOY-RUNBOOK.md`)
- **Web deploy:** `cd ~/psyclinicai && flutter build web --release --dart-define=IS_DEMO=false --dart-define=BACKEND_URL=https://rag.psyclinicai.com && firebase deploy --only hosting --project psyclinicai`
- **Firestore rules deploy:** `firebase deploy --only firestore:rules --project psyclinicai`
- **Sprint docs:** `docs/sprints/sprint-<N>-{plan,closeout}.md`
- **Pentest ledger:** `docs/security/findings.csv` + `docs/security/pentest-2026q3.md`
- **Eval harness:** `cd ~/psyrag && python3 scripts/eval_vignettes.py --hub-url https://rag.psyclinicai.com --api-key <key>`
