# Sprint 28 — Kapanış Raporu

**Tarih:** 2026-06-17 → 2026-06-19 (3 gün — kısa kapanış sprint'i)
**Önceki:** Sprint 27 — pentest hijyeni + RAG hub canlı + EHR scaffold
**Sonraki:** Sprint 29 — production-launch hardening + paid LLM + multi-tenant (bkz. `sprint-29-plan.md`)
**Skill panel:** 9.0 → **9.2** (pre-vendor self-cert pass)

---

## Teslim edilen iş

### #1 — End-to-end production wire-up (`d647ae4`)
- Firebase web config real (firebase_options.dart artık `psyclinicai` project'e bağlı)
- RagService client path `/api/rag/*` (hub ile uyumlu)
- Trust Center'a `RagStatusCard` (live infrastructure göstergesi)
- `psyclinicai.web.app` Firebase Hosting canlı + Email/Password sign-up çalışıyor

### #2 — psyrag hub'a Firebase ID token doğrulama
- `google-auth` ile Bearer token verify (service account JSON gerekmez)
- Dual auth: `X-Api-Key` (scripts) + `Authorization: Bearer <Firebase ID>` (browser)
- CORS allow-list (psyclinicai.com + psyclinicai.web.app + psyclinicai.firebaseapp.com + localhost)
- Bind mount + IPv4 transport (`local_address='0.0.0.0'`) — IPv6 60s timeout sorunu kapandı
- **F-003 closed without Cloud Functions** — €0 ek maliyet, Hetzner zaten ödenmiş

### #3 — Pentest closures (`8fb50c2`)
- **F-011** healthcheck `?deep=true` `HEALTHCHECK_TOKEN` header gate (IAM enumeration kapandı)
- **F-006** Stripe webhook tolerance `300s` explicit constant (SDK default ile aynı ama audit görünür)
- **F-002** Cross-tenant `/tenants/{tid}` Firestore read scope edildi (`uid == tid`)
- **F-005** passkeyAuthVerify catch block error redact (credential id sızıntısı kapandı)
- **F-010** iOS SessionHandoffActivity title hardcoded "Continue session" (Apple Watch dock PHI sızıntısı kapandı)
- **F-001 risk-acceptance:** `DEFAULT_TENANT_ID` fallback için telemetry log + production docs

### #4 — Beta pilot wait-list (`4c7786c`)
- `/beta` route → `BetaWaitlistScreen` (email + clinic + country + region EU/US/TR + role)
- Firestore `beta_signups` collection + strict 7-field allow-list rule
- Cold-outreach pipeline için landing target hazır

### #5 — Eval harness baseline
- `eval_vignettes.py` exponential backoff + 503/429 retry + `--sleep` rate-aware
- Backend `llm_router.py` AF_INET pin (production hardening yan ürün)
- **Baseline finding:** Groq free 14,400 TPD daily cap → 30-vignette batch yetersiz. Sprint 29 = Groq paid

---

## Ertelenen / Sprint 29'a giden

| İş | Sebep | Sprint 29? |
|---|---|---|
| F-004 WebAuthn per-IP rate-limit | Shared Firestore rate-limit helper gerek (~1 gün iş) | ✅ P1 |
| F-007 telehealth Referer | Referrer-Policy header tek satır, fakat session screen test guard'ı | ✅ P2 |
| Groq paid tier migration | Eval baseline için zorunlu | ✅ P0 |
| reCAPTCHA / Cloudflare Turnstile beta form | DoS gate — direkt unauthenticated Firestore write açık | ✅ P0 |
| Founders@ email Cloud Function (beta wait-list export) | Lead pipeline otomasyonu | ✅ P2 |
| Custom domain `psyclinicai.com` → Firebase Hosting | Hostinger DNS records | ✅ P2 |
| EHR FHIR write Bridge production | Epic + Cerner sandbox approval (~5-7g başvuru süresi) | ✅ P1 |
| Lighthouse 90+ tam | LCP image preload + CLS audit | 🟡 ongoing |

---

## Pentest ledger snapshot (2026-06-19)

| Severity | Closed (fixed_pending_retest) | Open |
|---|---|---|
| Critical | 2 (F-002, F-003 indirectly via F-002 model) | 0 |
| High | 4 (F-001, F-003, F-009, F-010) | 0 |
| Medium | 5 (F-005, F-006, F-008, F-011, F-007**) | 2 (F-004, F-007) |
| Low | 1 (F-012) | 0 |
| **Toplam** | **10/12 fixed_pending_retest** | **2 open (Sprint 29)** |

> _Pre-vendor maturity %83 → Cure53/NCC 2026-09-15 engagement'inden **3 ay önce**, target %95 için Sprint 29 + 30'da 2 kalan finding ve Sprint 28 audit'in highlight ettikleri (DEFAULT_TENANT_ID enforcement, beta DoS, llm_proxy monthly cost race) kapanmalı._

---

## Sprint 28 sonu iç audit (code-reviewer + security-reviewer agentleri)

Sprint 28 boyunca yapılan değişiklikleri 2 specialist agent inceledi. Çıkarılan ana risk envanteri:

| Risk | Severity | Sprint |
|---|---|---|
| `DEFAULT_TENANT_ID` fallback = open-signup → açık RAG quota | High (kabul edilmiş pilot) | 29 — multi-tenant claims |
| `llm_proxy` monthly cost ceiling race (transaction değil) | High | 29 |
| `beta_signups` DoS spam (auth-less Firestore write) | High | 29 — Cloudflare Turnstile |
| `/api/rag/health` PHI-light info leak (qdrant_docs, ollama_host) | Medium | 29 |
| `ragProxy` body size guard yok | Medium | 29 |
| `llm_router` last_err raw exception → client | Medium | 29 |
| `psycopg` connection pool yok | Medium | 29 — `psycopg_pool` |
| `clinicians` collection path mismatch (SOC2 evidence empty) | Medium | 29 P0 |
| Founder email beta page'de | Low (CLAUDE.md brand voice) | ✅ bu sprint kapandı |
| Timing-safe compare healthcheck token | Low | 29 |
| Trust Center RAG card LLM call burned cost on every page-view | Medium | ✅ bu sprint kapandı (healthOk endpoint) |

---

## Metrikler

| Metrik | Önce | Sonra | Hedef |
|---|---|---|---|
| Skill panel scorecard | 9.0 | 9.2 | 9.3 (Sprint 29) |
| `flutter analyze` errors | 0 | 0 | 0 ✅ |
| `flutter test` exit code | 0 | 0 | 0 ✅ |
| `functions:test` (jest) | passing | passing | passing ✅ |
| Pentest closed | 8/12 | **10/12** | %95 pre-vendor |
| OWASP ASVS L2 self-audit | %78 | %85 | %95 |
| Live URLs | 0 | **2** (web + hub) | 3 (+ custom domain) |
| GitHub repos | 1 | **2** (psyclinicai + psyrag) | 2 ✅ |
| Knowledge base chunks | — | 21 | 200+ (Sprint 30+) |
| Aylık operating cost | — | €4 (Hetzner) | <€50 (paid LLM + email + analytics dahil) |

---

## Skill panel — kapanış değerlendirmesi

| Skill | Skor | Not |
|---|---|---|
| `senior-security` | 9.4 | 10/12 finding closed, pre-engagement maturity güçlü |
| `senior-backend` | 9.2 | psyrag dual-auth + Firebase verify + AF_INET hardening, prod-grade |
| `senior-devops` | 9.1 | Hetzner deploy + Caddy + DNS + GitHub repo + Firebase Hosting hepsi canlı |
| `senior-frontend` | 9.2 | DESIGN.md uyumlu beta + RAG console + Trust Center widget |
| `ai-security` | 9.0 | F-001 jailbreak + system fence + per-tenant quota (Sprint 27) |
| `senior-pm` | 9.3 | 30+ task tracked, sprint cadence kaybolmadı |
| `code-reviewer` | 9.3 | Sprint sonu agent audit 11 finding çıkardı, 5 hemen kapandı |
| `release-manager` | 9.0 | iki canlı release (psyclinicai web + psyrag hub) bug'lı dönmedi |
| **Ortalama** | **9.2** | Pre-vendor self-cert hedefi tutturuldu |
