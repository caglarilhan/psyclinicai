# Sprint 31 — Wave A closed beta + paid LLM + EHR sandbox + vendor pentest prep

**Tarih:** 2026-07-05 → 2026-07-19 (2 hafta)
**Önceki:** Sprint 29 + 30 D-day (bkz. `docs/launch/LAUNCH-READINESS-PUNCHLIST.md` execution log — A–T fazları, **848/848 test**, 60+ launch-item shipped).
**Hedef:** Wave A kapalı beta (≤25 pilot) canlı, paid LLM rails ısınmış, EHR FHIR R4 sandbox 2 endpoint'le bağlı, Cure53/NCC 2026-09-15 engagement öncesi pentest maturity **%95'e taşı (şu an %83)**.
**Skill panel hedef:** 9.3 → **9.4**

---

## 0. Önceki sprintten taşınanlar (already shipped, regression bekçisi)

Code-side bitti, vendor unlock bekliyor. Bunlara dokunmuyoruz — sadece smoke test ediyoruz Wave A açılırken.

- F-01 Loom URL placeholder kapalı — kayıt + URL `DemoModal.loomUrl`'a geçirilecek
- P-04 Stripe live key + Reserve-seat payment link
- P-02 BAA + DPA gerçek hukukçu içerik
- Vendor: Hetzner Storage Box, PostHog DSN, Sendgrid template, Turnstile site key, Workspace alias, Sentry DSN × 3

İcra sıralaması ve adımlar `docs/launch/vendor-unlocks.md`'de hazır.

---

## Öncelik özeti

| Sıra | İş | DRI | Süre | Bağlı bulgu / persona |
|---|---|---|---|---|
| **P0** | Wave A closed beta açılışı — ilk 5 pilot onboarding | founder + customer-success | 2g | release-manager + cs-onboard |
| **P0** | First-SOAP activation funnel doğrula (PostHog) | growth-wg | 1g | saas-metrics-coach + product-analytics |
| **P0** | Vendor unlock checklist tamam — Stripe live, Sendgrid, PostHog, Sentry, Storage Box | founder | 2g (paralel) | founder-coach |
| **P0** | F-001 retest — LLM jailbreak + Turkish refresh red-team run | sec-team | 1g | ai-security + red-team |
| **P0** | F-002, F-005, F-006, F-008, F-009, F-010, F-011, F-012 retest evidence collect | sec-team | 2g | security-pen-testing |
| **P1** | EHR FHIR R4 sandbox — Epic + Cerner endpoint, 2 resource (Patient + Encounter) | senior-backend | 4g | rag-architect + healthcare-emr-patterns |
| **P1** | Groq paid tier cutover — `GROQ_PAID_TIER_ENABLED=true` ramp + cost dashboard | ai-wg | 1g | llm-cost-optimizer |
| **P1** | Qdrant daily snapshot → restic + alert on snapshot age | sre-wg | 1g | senior-devops + qdrant-spof.md §4 |
| **P1** | StatusPage.io live + Caddy /metrics scrape → Grafana Cloud | senior-devops | 2g | observability-designer |
| **P1** | SOC 2 evidence registry skeleton + first quarter snapshot | ciso-advisor | 2g | soc2-compliance |
| **P2** | F-013 (SQLCipher) re-key migration test (`test/security/local_db_encryption_test.dart`) | mobile-wg | 1g | tdd-guide + senior-security |
| **P2** | In-app onboarding tour beacons (`/session` first-launch) | senior-frontend | 1.5g | onboarding-cro + apple-hig-expert |
| **P2** | 1200×630 OG social-preview image + WebP variants | design | async | brand-guidelines |
| **P2** | Cure53 / NCC engagement letter — finalize scope + signed contract | ciso-advisor + counsel | async | (vendor engagement 2026-09-15) |
| **P3** | LinkedIn / X founder outreach — 20 personalised pilot emails | founder | 2g (paralel) | cmo-advisor + cold-email |

---

## W1 (2026-07-05 → 2026-07-12) — Wave A açılışı + paid LLM

### 1. Vendor unlocks paralel başlat ⚡ (D1 sabahı)
- founder Hetzner Storage Box order et → RESTIC_REPOSITORY + RESTIC_PASSWORD vault'a
- Stripe activation KYC submit
- PostHog EU project create → POSTHOG_KEY GitHub Actions secret
- Sendgrid create + domain auth (SPF + DKIM DNS kayıtları)
- Workspace alias support@/security@/founders@/pentest@
- Sentry × 3 project (Dart + Node + Python)
- Cloudflare Turnstile site/secret key
- Loom 90-sec demo kayıt (forecast docs/marketing/launch-kit.md §7 senaryosu)

Bekleme süresinde aşağıdaki kod işleri paralel.

### 2. Wave A onboarding flow ⚡ P0
**Süre:** 2g · **DRI:** founder + customer-success
- 5 named pilot LinkedIn/email outreach (docs/marketing/launch-kit.md §6 listesinden warm leads)
- Pilot Agreement (P-07) PDF — counsel red-line beklerken pre-sign template gönder
- Onboarding email sequence:
  - T+0  welcome + Loom + setup guide
  - T+1  "did your first session go well?" check-in
  - T+3  show first SOAP funnel result (PostHog `session.first_soap_generated`)
  - T+7  activation review — 60% pilot first_soap reached mı?
- Each pilot için `clinics/{uid}` Firestore doc manuel verify
- `setTenantClaim` `assignTenantOnCreate` trigger her pilot için fire ettiğini logla
- Slack `#launches` channel pilot bilgisi gerçek zamanlı (P-08 onBetaSignupSlack hazır)

**DoD:** 5 pilot signed-in + `first_soap_generated` ≤ 7 gün için 3/5 + zero SEV1/SEV2 in 48 h soak.

### 3. PostHog funnel + activation kanıt ⚡ P0
**Süre:** 1g · **DRI:** growth-wg
- `landing.visit → signup.completed → onboarding.finished → session.first_soap_generated` funnel kur
- Cohort: "Wave A pilot" (created_at ≥ 2026-07-05)
- Retention dashboard: WAC = ≥1 `session.started` in trailing 7d
- Activation bar: **60% hedef** (skill panel kuralı); <40% UX problem flag
- Sentry release `v1.0.0-beta.1` ile cross-reference

### 4. Groq paid tier cutover ⚡ P1
**Süre:** 1g · **DRI:** ai-wg
- `GROQ_PAID_TIER_ENABLED=true` env değişkeni `/opt/rag-service/.env`'ye + redeploy
- Free tier (8B) → paid tier (70B) — paid model `GROQ_MODEL=llama-3.3-70b-versatile`
- Per-tenant `daily_cost_cap_usd` Wave A pilot için $5/gün ile başlat (içtenlik için)
- Eval harness Wave A'da haftalık çalıştır → `key_concept_match` skoru takip
- Grafana dashboard panel: `psyrag_llm_cost_usd_total` per tenant per day
- **Kill-switch test:** `GROQ_PAID_TIER_ENABLED=false` flip + paid model çağrısı fallback Gemini → Ollama

### 5. Pentest retest evidence collection ⚡ P0
**Süre:** 2g · **DRI:** sec-team
- F-001 LLM jailbreak — Turkish + EN red-team 50 prompt run; `detectJailbreak` hit rate ≥ 95%
- F-002 cross-tenant: 2 farklı uid ile login → `/tenants/{other_uid}` 403 kanıt
- F-003 RAG API key: web bundle grep `RAG_API_KEY` → 0 hit kanıt
- F-005 PHI in logs: passkey verify error path simulate → uid + credential_id 120-char strip kanıt
- F-006 Stripe webhook replay: replay attack 600s eski timestamp ile → reject kanıt
- F-008 audit chain: `accessReviewCron` integrity break test → SRE alert kanıt
- F-009 patient PWA cache: kiosk logout → `/portal/inbox` 401 cache miss kanıt
- F-010 iOS Hand-off: NSUserActivity title "Continue session" sabit kanıt
- F-011 healthcheck deep: unauth `?deep=true` → 401 kanıt
- F-012 patient invite: token 24h sonra reuse → 410 Gone kanıt

Her bulgu için `docs/security/evidence/2026q3/F-XXX/retest-evidence.{png,sh,md}`.

### 6. F-013 re-key migration test ⚡ P2
**Süre:** 1g · **DRI:** mobile-wg
- `test/security/local_db_encryption_test.dart`: SQLCipher DB'ye known string yaz → ham dosya bytes oku → string DEĞIL var assert
- migrate plaintext v1 → encrypted v2: known plaintext row v1'de var, v2'de aynen var, v1 dosyası silinmiş

**DoD:** test passes; F-013 status `findings.csv`'de `open` → `fixed_pending_retest`.

---

## W2 (2026-07-12 → 2026-07-19) — EHR + monitoring + SOC 2

### 7. EHR FHIR R4 sandbox 🩺 P1
**Süre:** 4g · **DRI:** senior-backend
- `functions/src/ehr_bridge.ts` (Sprint 27 scaffold) — Epic test endpoint (`https://fhir.epic.com/.../api/FHIR/R4/`) + Cerner test endpoint
- 2 resource implement:
  - `Patient` — read by ID + search by identifier
  - `Encounter` — read by Patient ID
- `outbox` Firestore collection: `ehr_outbox/{tenantId}/{resourceId}` — write-once, encrypted snapshot
- `endpoint_allowlist` env: yalnızca whitelisted FHIR base URL'ler
- Retry policy: exp backoff, max 5 retries, 24h deadline
- Test: 3 sandbox Patient çek → outbox'a yaz, SOC2 audit trail kanıtı

### 8. Qdrant daily snapshot + alert 🛡 P1
**Süre:** 1g · **DRI:** sre-wg
- `ragsvc-backup.sh` — Qdrant snapshot frekansı haftalık → günlük (cron OnCalendar `*-*-* 03:00:00 UTC`)
- Snapshot age metric: `ragsvc_qdrant_snapshot_age_seconds` → Prometheus
- Grafana alert: `ragsvc_qdrant_snapshot_age_seconds > 86400 * 1.5` → Slack `#incidents`
- `docs/security/qdrant-spof.md` Option 2 (daily snapshot) statusunu **shipped** olarak güncelle

### 9. StatusPage.io + Grafana Cloud 📊 P1
**Süre:** 2g · **DRI:** senior-devops
- StatusPage.io (free tier) signup → public uptime: psyclinicai.web.app, rag.psyclinicai.com, Cloud Functions europe-west1
- Caddy `/metrics` reverse-proxy → Grafana Cloud agent push
- Grafana dashboard 4 panel: p95 latency, error rate, LLM cost per tenant, request rate
- Alert rule: error_rate > 5% 5min → Slack
- IR runbook §1 detection sources doğrulama (`docs/security/incident-response.md`)

### 10. SOC 2 evidence registry 📋 P1
**Süre:** 2g · **DRI:** ciso-advisor
- `docs/compliance/SOC2_EVIDENCE_REGISTRY.md` — CC1-CC9 trust service criteria mapping
- İlk evidence snapshot için 5 control:
  - CC6.1 logical access (Firestore rules + setTenantClaim)
  - CC6.7 transmission (TLS 1.3 enforce)
  - CC7.1 detection (Sentry + audit_log)
  - CC7.4 evaluation (quarterly access review)
  - CC8.1 changes (CI deploy pipeline)
- `scripts/collect-soc2-evidence.sh` — quarterly cron script that snapshots Firestore export + audit_log + access_review_cron output

### 11. In-app onboarding tour beacons 🧭 P2
**Süre:** 1.5g · **DRI:** senior-frontend
- `/session` first-open: 4-beacon tour
  - "1. Paste transcript or click Live STT"
  - "2. Review draft SOAP"
  - "3. Sign + export PDF"
  - "4. Triage alerts panel"
- `flutter_local_notifications` veya in-house overlay widget (no extra dep)
- Telemetry: `onboarding.tour_started`, `onboarding.tour_completed`, `onboarding.tour_skipped`

### 12. F-001 + F-007 retest 🛡 P0
**Süre:** 0.5g · **DRI:** sec-team
- F-001 Turkish jailbreak (S-08 5 yeni regex) — Cure53 red-team scripti çalıştır, 0 hit kanıt
- F-007 telehealth Referrer-Policy — `curl -I /portal/session/test` → `Referrer-Policy: no-referrer` kanıt
- Findings ledger status: `fixed_pending_retest` → `fixed_verified`

### 13. Cure53 / NCC engagement letter ✍️ P2
**Süre:** async · **DRI:** ciso-advisor + counsel
- Cure53 (öncelik) + NCC Group (yedek) scope letter:
  - Web bundle + Cloud Functions + psyrag hub
  - WebAuthn + Stripe + EHR bridge
  - 4 hafta engagement, kickoff 2026-09-15
- Pentest scope: `docs/security/pentest-2026q3.md` + threat-model.md §3 verilecek
- Pre-engagement evidence package: findings.csv + retest evidence + IR runbook + SOC 2 registry

---

## Risk + bağımlılıklar

| Risk | Olasılık | Etki | Mitigation |
|---|---|---|---|
| Stripe KYC 48h+ gecikir | M | Wave A ödeme bloke | Pilot'lara önce 6-ay free, fatura çıkarımı ay sonu |
| Counsel red-line gecikir | H | BAA/DPA imzasız | Pilot Agreement "no PHI yet" Pre-A süresinde imzala |
| Groq paid bill spike | L | $1000+ aşırı fatura | `daily_cost_cap_usd=$5` Wave A için + Grafana alert |
| Eval skorları düşer | M | RAG kalitesi şüphe | Cohere reranker (B-05 scaffold) aktive — `COHERE_API_KEY` set |
| Pilot < 5 signed Wave A | M | Cohort istatistiği zayıf | Founder cold outreach + LinkedIn paid ads ($500 budget) |
| EHR sandbox Epic registration gecikir | M | EHR demosu yok | Cerner sandbox ile başla, Epic Sprint 32 |

---

## Tanım: Done

Sprint 31 sonu için (skill panel veto kurallarıyla):

- [ ] **release-manager:** v1.0.0-beta.2 tag + GitHub Release + rollback path test
- [ ] **founder-coach:** 5 Wave A pilot signed-in, 3/5 first_soap_generated ≤ 7d
- [ ] **saas-metrics-coach:** PostHog funnel + retention cohort canlı
- [ ] **ciso-advisor:** 10/12 pentest finding `fixed_verified`, 2 risk-accepted, F-013 closed
- [ ] **cto-advisor:** Groq paid tier ramped, cost dashboard görünür, kill-switch çalıştığı test
- [ ] **senior-architect:** EHR bridge 2 resource çalışıyor, outbox audit kanıt
- [ ] **senior-devops:** StatusPage live, Grafana 4 panel, 1 alert fire test edilmiş
- [ ] **rag-architect:** Eval harness Wave A vignettes pass rate ≥ 70%
- [ ] **silent-failure-hunter:** Restore drill ≥ 1 kez başarıyla run, log GREEN
- [ ] **change-management:** `/roadmap` Wave B tarihi güncel, public roadmap commit
- [ ] **brand-voice:** Tüm Wave A surfaces "we / our team / EU-based" auditi

**Pentest maturity hedef:** %83 → **%95** (2 yeni close + 11 retest verified).

---

## Sprint 32 ön-sinyalleri (planlama notu)

- Public Wave B launch (ProductHunt + HN + IH) — kapalı beta funnel %40+ kanıtlanırsa
- Native mobile app shell (iOS first) — Flutter codebase reuse
- Multi-jurisdiction legal engine UI — state-by-state alerts (US 50 + EU 27)
- Cohere reranker production deploy + eval delta kanıt
- BYOK key rotation UX — Stripe Customer Portal benzeri "rotate now" flow
- Cure53 engagement Eylül 15 başlar → Sprint 32 ortasında interim rapor

---

## Skill panel hedefi

| Persona | W1 katkı | W2 katkı |
|---|---|---|
| **release-manager** | Wave A açılış, v1.0.0-beta.1 → beta.2 | Rollback path drill |
| **founder-coach** | Vendor unlocks, pilot outreach, ROE | Activation cohort review |
| **ciso-advisor** | Pentest retest, F-013 close | SOC 2 evidence first quarter, Cure53 letter |
| **ai-security** | Turkish jailbreak red-team run | F-001 verified close |
| **senior-backend** | Groq paid cutover | EHR FHIR R4 2 resource |
| **rag-architect** | Eval baseline measure | Cohere ramp (gated) |
| **senior-devops** | Restore drill verify | StatusPage + Grafana |
| **observability-designer** | Sentry release + alerts | Grafana 4 panel + alert |
| **saas-metrics-coach** | PostHog funnel kur | D7 activation cohort review |
| **cmo-advisor** | Wave A pilot outreach | Public roadmap update |
| **product-strategist** | Wave A scope koruyucu | Wave B plan draft |
| **change-management** | Pilot comms cadence | Wave B launch plan |
| **brand-voice** | Surface audit | Founder-identity recheck |
| **founder + customer-success** | 5 pilot onboarded | Retention check + activation review |
| **tdd-guide** | F-013 regression test | Eval pass-rate test scaffold |
