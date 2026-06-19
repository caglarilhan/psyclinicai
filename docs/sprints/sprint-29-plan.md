# Sprint 29 — Production Hardening + Paid LLM + Multi-Tenant Plan

**Tarih:** 2026-06-20 → 2026-07-04 (2 hafta)
**Önceki:** Sprint 28 — psyrag canlı + 10/12 pentest closed + beta wait-list (bkz. `sprint-28-closeout.md`)
**Hedef:** Pre-vendor pentest %95'e taşı + Groq paid + ilk 10 pilot klinisyen onboard + multi-tenant claims
**Skill panel hedef:** 9.2 → **9.3**

---

## Öncelik özeti

| Sıra | İş | DRI | Süre | Bağlı bulgu |
|---|---|---|---|---|
| P0 | Groq paid tier migration + eval baseline | ai-wg | 0.5g | Sprint 28 carry-over |
| P0 | Multi-tenant claims (DEFAULT_TENANT_ID risk-acceptance fix) | platform-wg | 3g | F1 audit |
| P0 | `clinicians` collection path mismatch — SOC2 evidence boş | sec-team | 1g | code-review audit |
| P0 | `beta_signups` Cloudflare Turnstile + Cloud Function moderation | growth-wg | 2g | beta DoS audit |
| P1 | F-004 WebAuthn per-IP rate-limit (shared Firestore helper) | auth-wg | 1.5g | Pentest carry-over |
| P1 | F-007 telehealth Referrer-Policy header | platform-wg | 0.5g | Pentest carry-over |
| P1 | EHR FHIR R4 sandbox connect (Epic + Cerner) | senior-backend | 4g | Sprint 27 carry-over |
| P1 | LLM proxy monthly cost ceiling transaction-wrap | ai-wg | 1g | F3 audit |
| P1 | First 10 pilot clinician outreach (manual + beta form) | founder | 1g | growth |
| P2 | Custom domain `psyclinicai.com` → Firebase Hosting | senior-devops | 0.5g | Hostinger DNS |
| P2 | Founders@ email Cloud Function (beta wait-list digest) | senior-backend | 1g | Sprint 28 carry-over |
| P2 | `psycopg_pool` connection pool — psyrag scalability | senior-backend | 1g | F4 audit |
| P2 | Lighthouse 90+ tamamlama | senior-frontend | 2g | Sprint 27 carry-over |

---

## W1 (2026-06-20 → 2026-06-27) — Production hardening + paid LLM

### 1. Groq paid tier migration ⚡
**Süre:** 0.5g · **DRI:** ai-wg
- Groq Dashboard → billing add card → paid tier ($0.59/1M input, $0.79/1M output Llama-3.3-70B)
- Production usage estimate: 1000 query/gün × 1500 token = 1.5M token/gün = ~$3/gün = **~$90/ay** for first 50 pilot users
- `psyrag/.env` GROQ_API_KEY rotate (paid tier key)
- Re-run eval harness → gerçek baseline yazdır + Sprint 30'a hedef pass rate koy

### 2. Multi-tenant claims + DEFAULT_TENANT_ID fix ⚡ (F1 close)
**Süre:** 3g · **DRI:** platform-wg
- `functions/src/setTenantClaim.ts` yeni Cloud Function — admin SDK ile yeni kayıt → `tenant_id` custom claim atar
- `psyrag/.env` DEFAULT_TENANT_ID="" (production) + startup assertion
- `firestore.rules` `users/{uid}` collection — claim status doğrulama
- 3 test: claim absent → 401, claim present → OK, claim invalid → 401

### 3. `clinicians` collection path mismatch ⚡ (audit P0)
**Süre:** 1g · **DRI:** sec-team
- `access_review_cron.ts:114-118` `clinicians` top-level yerine `/clinics/{cid}/clinicians/{uid}` iterate
- Veya doğru top-level path tanımla (firestore.rules update)
- Test: cron snapshot non-zero roster döner

### 4. Beta wait-list Cloudflare Turnstile ⚡ (audit P0)
**Süre:** 2g · **DRI:** growth-wg
- Cloudflare Turnstile (Google reCAPTCHA alternatif, GDPR-friendly) — beta page'e widget
- `functions/src/verifyBetaSignup.ts` Cloud Function — Turnstile token doğrula + Firestore'a yaz
- Firestore rules: `beta_signups` artık unauthenticated **DİREKT WRITE'A KAPALI**, sadece function via admin SDK
- Test: form submit → Turnstile challenge → server-side verify → Firestore write

### 5. F-001 LLM proxy monthly cost race fix
**Süre:** 1g · **DRI:** ai-wg
- `llm_proxy.ts:186-194` `db.runTransaction` ile cost ledger read+write atomic
- 2 test: paralel 10 request → toplam cost <= cap (race kanıt)

---

## W2 (2026-06-27 → 2026-07-04) — Beta launch + EHR + carry-over

### 6. EHR FHIR R4 sandbox connect
**Süre:** 4g · **DRI:** senior-backend
- Epic FHIR sandbox başvuru (https://fhir.epic.com/Developer/Apps) — 5-7g approval süresi (PARALEL başla)
- Cerner Code (https://code.cerner.com) sandbox
- `functions/src/ehr_bridge.ts` Observation + DocumentReference POST live test
- 5 integration test (sandbox karşı)

### 7. F-004 WebAuthn per-IP rate-limit (Pentest carry-over)
**Süre:** 1.5g · **DRI:** auth-wg
- `functions/src/lib/rate_limit.ts` yeni helper — Firestore counter per hashed IP per window
- passkey_register + passkey_authenticate'e uygula (20 req/IP/15dk)
- 3 test: under limit, over limit, window reset

### 8. F-007 telehealth Referrer-Policy
**Süre:** 0.5g · **DRI:** platform-wg
- Telehealth room iframe header: `Referrer-Policy: no-referrer`
- Session screen webview için aynı policy
- 1 e2e test (curl -I response check)

### 9. İlk 10 pilot klinisyen onboard
**Süre:** 1g (manuel outreach) · **DRI:** founder
- LinkedIn EU + Türkiye psikiyatri grupları + EUROPSY ağı → 50 cold reach
- Beta form'a 10+ aday hedef
- İlk 5 onboard'a hayata geçir, 15 dk haftalık feedback call schedule

### 10. Custom domain
**Süre:** 0.5g · **DRI:** senior-devops
- Firebase Hosting → Add custom domain `psyclinicai.com`
- Hostinger DNS → Firebase verification + A/CNAME records
- Cert provisioning ~24 saat
- redirect www.psyclinicai.com → psyclinicai.com

### 11. Founders@ email Cloud Function
**Süre:** 1g · **DRI:** senior-backend
- `functions/src/betaDigest.ts` — günlük cron, son 24h beta_signups → SendGrid email founders@ adresine
- Format: tablo (timestamp + region + role + clinic + country)
- Test: 1 mock signup + cron tetikle + email gelir

### 12. F8 + F-007 + audit cleanup
**Süre:** 1g · **DRI:** sec-team
- `psycopg_pool` integration (F4 audit)
- `/api/rag/health` strip qdrant_docs/ollama_host (F5 audit)
- `ragProxy` body size guard (F6 audit)
- `llm_router` error mesajı sanitize (F7 audit)
- healthcheck timing-safe compare (F11 audit follow-up)

---

## Risk + bağımlılıklar

- **Epic + Cerner sandbox approval**: 5-7g süresi. W1'de başvuru aç → W2'de connect.
- **Custom domain DNS**: TTL 300 ile 5 dk yayılma, fakat Firebase cert provision 24 saat. W2 ortasında başla.
- **Pilot recruitment**: LinkedIn'de günde 5 cold mesaj, hedef hafta 25 mesaj → 10 onboard (40% conversion). Çağrı agresif değil — pilot kalitesi miktarın üstünde.
- **Groq paid**: bir kerelik kart girişi + key rotate. Backup: Together.ai veya OpenRouter alternative.

---

## Tanım: Done

Sprint 29 "Done" sayılır eğer:
- [ ] Pentest 12/12 finding `fixed_pending_retest` veya `closed` (F-004 + F-007 kapanır)
- [ ] DEFAULT_TENANT_ID production'da `""`, multi-tenant claims live
- [ ] `clinicians` SOC2 evidence collection path düzeldi
- [ ] `beta_signups` artık unauthenticated write yapamaz (Turnstile + Cloud Function gate)
- [ ] Groq paid tier active, eval baseline %X pass rate ölçüldü (target: %50+ for 21 chunks)
- [ ] 5+ aktif pilot klinisyen feedback veriyor
- [ ] Custom domain `psyclinicai.com` Firebase Hosting'e bağlandı + cert provisioned
- [ ] Founders@ digest email haftada 5+ beta lead getiriyor
- [ ] OWASP ASVS L2 self-audit ≥%92 (pre-vendor target)

---

## Skill panel hedefi

| Skill | 28 sonu | 29 hedef | Bağımlı iş |
|---|---|---|---|
| `senior-security` | 9.4 | 9.5 | 12/12 finding + DEFAULT_TENANT_ID fix + Turnstile |
| `senior-backend` | 9.2 | 9.3 | EHR sandbox + multi-tenant claims + cost race fix |
| `senior-frontend` | 9.2 | 9.3 | Lighthouse 90 + Turnstile UI integration |
| `senior-devops` | 9.1 | 9.3 | Custom domain + Groq paid migration + connection pool |
| `growth/founder` | — | 8.5 | İlk 10 pilot onboard, feedback loop running |
| `ai-security` | 9.0 | 9.2 | Cost race fix + multi-tenant LLM quota |
| **Ortalama** | **9.2** | **9.3** | Pre-vendor %92, pilot-running, growth hattı açık |

---

## Sprint 30 ön-sinyalleri (planlama notu)

Sprint 29 bitince Sprint 30 (2026-07-04 → 2026-07-18) önemli hedefler:
1. Cure53/NCC vendor selection (2026-08-01 deadline)
2. Knowledge base ingest derinleştir (21 → 200+ chunk; lisanslı içerikler dahil)
3. Klinisyen feedback'lerden ilk DPO fine-tune denemesi (eğer 1000+ feedback toplanırsa)
4. Stripe Connect Express + Mollie EU prod
5. WebAuthn passkeys mobile native (iOS Hand-off entegre)
6. App Store iOS submission (Sprint 26 paketi var, sadece final review)
