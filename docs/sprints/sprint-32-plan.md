# Sprint 32 — Wave B public launch + native mobile shell + Cure53 prep close-out

**Tarih:** 2026-07-20 → 2026-08-02 (2 hafta)
**Önceki:** Sprint 31 — Wave A closed beta + paid LLM cutover + EHR sandbox + pentest retest (bkz. `sprint-31-plan.md`)
**Hedef:** Wave A funnel %40+ activation kanıtladıysa **public Wave B launch** (ProductHunt + HN + IH); pentest maturity %95'i sabitle ve Cure53 engagement kit final; native iOS shell ilk binary; Cohere reranker production ramp.
**Skill panel hedef:** 9.4 → **9.5**

> **Master gate (release-manager + product-strategist):** Wave B launch yalnızca Sprint 31 Wave A funnel'i §Tanım: Done §saas-metrics-coach kriterini geçerse açılır. Aksi takdirde Wave B → Sprint 33, bu sprintte sadece UX-fix + activation tuning yapılır. Karar **D1 sabahı** verilir, retroactif değiştirilmez.

---

## 0. Sprint 31'den taşınanlar (regression bekçisi)

Sprint 31 P0/P1'lerin Wave A öğrenmesini bekleyenler:
- PostHog activation cohort (D7) verisi
- Pentest retest evidence (`docs/security/evidence/2026q3/F-XXX/`) 10/12 verified
- Groq paid tier cost dashboard 2-hafta gerçek harcama
- EHR FHIR R4 sandbox Patient + Encounter çalışıyor

Bunlara dokunmayız — Wave B bunların üstüne kurulur.

---

## Karar matrisi (D1 sabahı, sprint-32 kickoff)

| Wave A sonucu | Sprint 32 yönü |
|---|---|
| Activation **≥ 60 %** | ⚡ Public Wave B launch (Track A, aşağıdaki tüm P0/P1 ship eder) |
| Activation **40-59 %** | 🟡 Soft Wave B — yalnızca PostHog/email tabanlı outreach, no PH/HN; UX iterasyonu paralel |
| Activation **< 40 %** | 🔴 Wave B ertelendi → Sprint 33; tüm bu sprint UX-fix + onboarding rewrite + pilot derinleşme |

**Karar kayıtçısı:** founder-coach + saas-metrics-coach birlikte 09:00 UTC karar verir, `docs/sprints/sprint-32-closeout.md` § karar bölümünde nedenleri imzalar.

---

## Öncelik özeti (Track A — full launch)

| Sıra | İş | DRI | Süre | Bağlı persona |
|---|---|---|---|---|
| **P0** | Cure53 engagement kit final (evidence + scope + signed letter) | ciso-advisor + counsel | 2g | senior-security + adversarial-reviewer |
| **P0** | Public Wave B launch — PH + HN + IH coordinated drop | founder + cmo-advisor | 2g | launch-strategy + cmo-advisor |
| **P0** | StatusPage.io live + on-call rotation aktif | senior-devops | 1g | incident-commander |
| **P0** | Wave A → Wave B graduation flow (Stripe trial → paid otomatik geçiş) | senior-backend | 2g | finance-billing-ops |
| **P1** | Native iOS shell — Flutter codebase reuse, App Store Connect kayıt | senior-frontend + apple-hig-expert | 4g | app-store-optimization |
| **P1** | Cohere reranker production ramp + eval delta evidence | rag-architect + ai-wg | 1.5g | senior-ml-engineer |
| **P1** | Sentry release tracking + source map upload otomasyonu | observability-designer | 1g | senior-devops |
| **P1** | EHR FHIR R4 — 3. resource (Observation: PHQ-9/GAD-7 export) | senior-backend | 2g | healthcare-emr-patterns |
| **P1** | Activation tour beacons A/B test (`/session` first-launch) | senior-frontend | 1g | onboarding-cro + ab-test-setup |
| **P2** | Multi-jurisdiction legal engine UI — state-by-state alerts (US Phase 1: CA + NY + TX) | senior-fullstack | 3g | gdpr-dsgvo-expert + healthcare-cdss-patterns |
| **P2** | BYOK key rotation UX — Stripe Customer-Portal-tarzı "rotate now" flow | senior-frontend | 1.5g | env-secrets-manager |
| **P2** | Lighthouse 95+ all categories (Performance + A11y + Best Practices + SEO) | senior-frontend | 1g | seo-audit + a11y-audit |
| **P3** | Discord community açılış — pilot Slack çıkış stratejisi | founder + customer-success | 1g | community-building |
| **P3** | Translation rollout: DE + FR EU pilot için (PHQ-9 / GAD-7 validation review) | senior-frontend | async | intl-expansion |

---

## W1 (2026-07-20 → 2026-07-27) — Cure53 kit + Wave B salvosu

### 1. D1 sabahı — Wave A retro + karar (saas-metrics-coach + founder-coach)
**Süre:** 2 h · **DRI:** founder + growth-wg
- PostHog cohort: 5 pilot için D7 activation %X (target ≥60)
- Sentry release `v1.0.0-beta.1` error rate < 1% 14 gün soak
- Stripe (Wave A free) → trial conversion intent sayısı
- Pilot NPS quick survey (1 soru, 7 günde 1 cevap)

**Karar dokümante:** Track A / B / C — yukarıdaki matrise göre. Sprint geri kalanı bu karara bağlanır.

### 2. Cure53 engagement kit final ⚡ P0
**Süre:** 2g · **DRI:** ciso-advisor + counsel
- Cure53 scope letter v2 (Sprint 31'de v1 imzalandıysa) → final signature
- Pre-engagement evidence package:
  - `docs/security/findings.csv` — 11/12 closed, 1 risk-accepted
  - `docs/security/evidence/2026q3/F-XXX/` — 10 retest klasörü tam
  - `docs/security/threat-model.md` — güncel
  - `docs/security/incident-response.md` — Sprint 31 IR drill log eklenmiş
  - `docs/legal/SUBPROCESSORS.md` — Cohere ve PostHog güncel
- `docs/security/cure53-prep.md` (yeni) — Cure53 engineer'larına onboarding rehberi
- PGP key publish (`pentest@psyclinicai.com`) — keys.openpgp.org doğrulama
- Kickoff toplantısı 2026-09-15 takvime gir + 4 haftalık iş takvimi

**DoD:** Cure53'ten "we have everything we need" yazılı confirm.

### 3. Public Wave B launch ⚡ P0 (sadece Track A)
**Süre:** 2g · **DRI:** founder + cmo-advisor
**Persona:** launch-strategy + cmo-advisor + cmo-advisor + brand-voice + marketing-psychology
- D-2 dry-run: hunter, hook, gallery GIF, OG image final
- D-1 sabahı: ProductHunt poster kaydı, HN hesabı warm-up, Indie Hackers post
- D-day 12:01 AM PT: PH post → 5 dakika içinde first comment + 3 GIF
- 04:00 PT: X / LinkedIn / Reddit r/therapy + r/psychiatry + r/Entrepreneur drop
- 08:30 AM PT: HN Show HN
- 09:00 AM PT: Indie Hackers post + IH founder badge
- 4 saat boyunca founder her yorumu < 5 dakika cevaplar
- Slack `#launches` channel'da her sign-up gerçek zamanlı (onBetaSignupSlack + onBetaSignupFoundersEmail çalışıyor)
- D+1 post-mortem: PH ranking, HN puanı, gelen sign-up sayısı

**Risk acceptance:** PH ranking #1-3 garanti değil; PostHog'da `landing.visit` spike + `signup.completed` conversion'a bak, sıralama değil.

### 4. StatusPage + on-call ⚡ P0
**Süre:** 1g · **DRI:** senior-devops + incident-commander
- StatusPage.io public dashboard: Web, Cloud Functions, RAG hub, Stripe
- Maintenance window template (Wave B sırasında deploy yapılırsa)
- PagerDuty veya OpsGenie (free tier yetiyor) → founder telefon + Slack #incidents
- IR runbook §1 detection sources son test — Sentry alert + Grafana threshold + accessReviewCron hash break

### 5. Wave A → Wave B billing geçişi ⚡ P0
**Süre:** 2g · **DRI:** senior-backend + finance-billing-ops
- Wave A pilot'lar 6-ay free; Wave B'den itibaren $49 founding rate
- Stripe `trial_end` (Wave A pilot için 2026-12-31'e kadar) → trial bittikten sonra otomatik invoice
- Customer Portal entegrasyonu: pilot kendi card'ını ekleyebilsin
- Email sequence: T-14 / T-7 / T-1 "trial ends" reminders (Sendgrid template)
- Failed payment hook: dunning email 3-day window

### 6. Native iOS shell 🍎 P1
**Süre:** 4g · **DRI:** senior-frontend + apple-hig-expert
- `flutter build ios --release` çalışıyor mu test
- App Store Connect account setup
- App icon + launch screen + privacy disclosures (App Privacy section: Health & Fitness, no advertising, no tracking)
- TestFlight'a ilk build push
- 5 pilot beta tester davet (App Store Connect TestFlight)
- iOS-specific UX: SF Symbols, Dynamic Type, Continuity Camera support
- Apple Health integration scope: yalnızca PHQ-9 / GAD-7 skorlarını yazma yetkisi (`HKQuantityTypeIdentifier...`)

**DoD:** TestFlight build canlı, 5 pilot iOS'ta session açabilsin.

### 7. Cohere reranker production ramp 🎯 P1
**Süre:** 1.5g · **DRI:** rag-architect + ai-wg
- Sprint 30 scaffold (`_cohere_rerank`) `COHERE_API_KEY` env set + production .env
- Eval harness Wave A vignettes × 55 → baseline vs reranked karşılaştırma
- Metrics: `key_concept_match`, `source_coverage`, `citation_count` her metrik için delta tablo
- Hedef: precision@k ~%30 iyileşme (literature ile uyumlu)
- Cost panel: `psyrag_cohere_cost_usd_total` Prometheus
- Kill-switch: `COHERE_API_KEY` boşaltırsan no-op fallback (zaten kodda var)

---

## W2 (2026-07-27 → 2026-08-02) — Mobile + multi-juris + Lighthouse

### 8. Sentry release tracking automation 📊 P1
**Süre:** 1g · **DRI:** observability-designer + senior-devops
- `sentry-cli releases new v1.0.0-beta.X` CI'da automate
- Source map upload (Dart + Node + Python tarafından)
- `sentry-cli releases set-commits --auto` ile GitHub commit linking
- Release health: crash-free user % → Slack alert eğer < 99.5%

### 9. EHR FHIR R4 — Observation resource 🩺 P1
**Süre:** 2g · **DRI:** senior-backend + healthcare-emr-patterns
- Sprint 31'de Patient + Encounter shipped → bu sprint Observation eklenir
- PHQ-9 / GAD-7 sonuçları LOINC code ile FHIR Observation'a yaz
- Outbox pattern devam: `ehr_outbox/{tenantId}/observations/{id}`
- Test: 1 sandbox patient için 4-haftalık PHQ-9 trend export → Epic sandbox'da görünüyor

### 10. Activation tour A/B test 🧪 P1
**Süre:** 1g · **DRI:** senior-frontend + ab-test-setup
- Sprint 31'de tour beacons shipped → bu sprint A/B test başlat
- Hipotez: 4-beacon tour > 0-beacon control'den %20+ activation iyileştiriyor
- PostHog feature flag: `onboarding_tour_enabled` (50/50 split)
- Min sample: 40 signup (haftada ~20 sign-up varsayım, 2 hafta)
- Statistical significance: PostHog Funnel Insights

### 11. Multi-jurisdiction legal engine UI 🌍 P2
**Süre:** 3g · **DRI:** senior-fullstack + gdpr-dsgvo-expert + healthcare-cdss-patterns
- Phase 1: 3 US state (CA + NY + TX) — sik kullanım, regulatory delta var
- `lib/services/legal/us_state_law_service.dart` (mevcut scaffold üzerine)
- Clinician her seans başında state seçer → applicable alerts:
  - Mandatory reporting (child + elder abuse thresholds)
  - Confidentiality limits (Tarasoff variant her state'de)
  - Telehealth licensure (cross-state restrictions)
- Settings → "My licensed states" → multi-select
- Sprint 33'te EU country expansion (DE + UK)

### 12. BYOK key rotation UX 🔑 P2
**Süre:** 1.5g · **DRI:** senior-frontend + env-secrets-manager
- Settings → API Keys → "Rotate now" button her BYOK provider için
- Eski key'i 24 saat grace period'la tutmaya yarayan rotation flow
- Audit log: `byok.rotation_requested`, `byok.rotation_completed`
- Email confirm: "your key was rotated at YYYY-MM-DD HH:MM UTC"

### 13. Lighthouse 95+ 🚦 P2
**Süre:** 1g · **DRI:** senior-frontend + seo-audit + a11y-audit
- Performance: bundle size analysis (`flutter build web --analyze-size`), font subset optimization
- A11y: 100/100 hedef — `axe-core` GitHub Action CI'a ekle
- Best Practices: Console errors 0, HTTPS everywhere, no deprecated APIs
- SEO: meta description + structured data validated by Schema.org validator
- `npm run lighthouse:ci` workflow CI step

### 14. Discord community 💬 P3
**Süre:** 1g · **DRI:** founder + customer-success
- Discord server: #welcome, #wave-a-pilots, #wave-b-launch, #feature-requests, #incidents-public, #ama-with-founder
- Pilot Slack çıkışı (Wave A pilot'lar Discord'a taşınır, kanal arşivlenir)
- Onboarding bot: yeni üye → Welcome DM + Pilot Agreement linki
- Weekly AMA founder ile (Wed 16:00 CET)

### 15. DE + FR translation 🌐 P3 (async)
**Süre:** async · **DRI:** senior-frontend + intl-expansion
- PHQ-9 + GAD-7 + C-SSRS resmi validated translation kullan (NICE / EMA cited versions)
- Tüm UI strings DE + FR locale dosyalarına `lib/l10n/` → `arb` veya `intl_translation`
- Native speaker review (paid translator, ~$500 budget)

---

## Risk + bağımlılıklar

| Risk | Olasılık | Etki | Mitigation |
|---|---|---|---|
| Wave A activation < 40% — Wave B iptal | M | Sprint scope %50 değişir | Track C plan hazır, UX-fix sprint'e dönüştür |
| PH ranking < #5 — launch trafik düşük | M | Wave B momentum kayıp | HN+IH+X kanalları paralel; ranking değil sign-up'a bak |
| Apple App Store review red — TestFlight gecikir | M | iOS shelf'te kalır | Privacy disclosures önceden ChatGPT'ye review ettir |
| Cure53 evidence eksik — engagement kaymaz ama sound bite ucuz | L | Sprint 32 cure53 prep tam | Evidence collection paralel, son anda paniklemez |
| Stripe trial conversion < 20% | M | Wave A pilot'lar kalıcılaşmaz | Customer success ile 1-on-1 retention call |
| EHR sandbox Epic gecikir (Sprint 31'den taşınmış) | M | EHR demosu yok | Cerner ile devam, Epic Sprint 33'e öneri |

---

## Tanım: Done

Sprint 32 sonu için (skill panel veto kurallarıyla):

- [ ] **release-manager:** v1.0.0 GA tag (Track A) veya v1.0.0-beta.3 (Track B/C) + GitHub Release notes
- [ ] **product-strategist:** Wave A → Wave B karar dokümante (`sprint-32-closeout.md` § karar)
- [ ] **cmo-advisor:** PH/HN/IH coordinated drop, post-mortem yazılı; veya neden ertelendi yazılı
- [ ] **saas-metrics-coach:** Yeni cohort (Wave B veya Wave A iteration 2) PostHog'da canlı
- [ ] **ciso-advisor:** Cure53 evidence kit "ready" confirm
- [ ] **rag-architect:** Cohere reranker eval delta ölçüldü, kanıt yayında
- [ ] **senior-architect:** EHR Observation çalışıyor, outbox 3 resource için aktif
- [ ] **senior-frontend:** TestFlight iOS build kanlı, 5 pilot iOS'ta session
- [ ] **senior-devops:** StatusPage public, PagerDuty/OpsGenie on-call rotation aktif, Sentry release otomasyonu çalışıyor
- [ ] **observability-designer:** Lighthouse 95+ all categories (sadece Track A için zorunlu)
- [ ] **change-management:** Discord community public veya plan kaydedildi, pilot Slack çıkış stratejisi yazılı
- [ ] **brand-voice:** Tüm launch surface'leri (PH copy, HN comment, X thread) "we / our team" sesinde

**Pentest maturity hedef:** %95 sabit (Sprint 31'den geliyor); Cure53 engagement %85 prep complete.

---

## Sprint 33 ön-sinyalleri (planlama notu)

- Cure53 / NCC pentest engagement → 2026-09-15 kickoff → 4 hafta → 2026-10-13 ilk raporlar
- EU country expansion (DE + UK + FR translation production) — DE + FR çevirileri bu sprintte hazır olursa Sprint 33'te ship
- Multi-jurisdiction EU phase (DE + UK + AT) — multi-jurisdiction engine US'i geçecek
- Native Android shell — iOS shell Sprint 32'de hazırsa Sprint 33 Android
- Wave B growth oranı haftalık 5+ yeni pilot ise: Sprint 33'te SOC 2 Type II evidence collection ramp
- Cohere alternatif değerlendirme: Voyage AI veya BGE-rerank-v2 (cost / latency trade-off)

---

## Skill panel hedefi

| Persona | W1 katkı | W2 katkı |
|---|---|---|
| **release-manager** | v1.0.0 tag (Track A) | Release health, rollback drill |
| **product-strategist** | Wave A → B karar | Sprint 33 plan draft |
| **founder-coach** | PH+HN launch driving | Pilot retention coaching |
| **cmo-advisor** | Public launch coordinate | Discord + community plan |
| **brand-voice** | Launch copy audit | Founder identity check |
| **ciso-advisor** | Cure53 evidence kit | SOC 2 evidence quarter 2 ramp |
| **senior-security** | Threat model güncel tut | Cure53 onboarding doc |
| **adversarial-reviewer** | Cohere reranker red-team | Multi-juris legal engine red-team |
| **rag-architect** | Cohere production ramp | Eval delta evidence |
| **senior-ml-engineer** | Cohere config | Voyage AI compare (Sprint 33) |
| **senior-backend** | Stripe trial-to-paid | EHR Observation resource |
| **senior-frontend** | iOS shell + tour A/B | Lighthouse 95+ + BYOK rotation UX |
| **senior-fullstack** | Multi-juris US Phase 1 | EU expansion plan |
| **senior-devops** | StatusPage + PagerDuty | Sentry release auto |
| **observability-designer** | Crash-free user metric | Lighthouse CI |
| **apple-hig-expert** | iOS-specific UX audit | App Store review prep |
| **app-store-optimization** | App Store screenshots | ASO copy + keywords |
| **healthcare-emr-patterns** | EHR Observation FHIR | Apple Health integration |
| **gdpr-dsgvo-expert** | EU translation review | Multi-juris EU phase |
| **healthcare-cdss-patterns** | US state-specific alerts | Cross-state telehealth licensure |
| **onboarding-cro** | Tour A/B test | Conversion review |
| **ab-test-setup** | Statistical significance | Sample size review |
| **seo-audit** | Lighthouse SEO | Schema.org validate |
| **a11y-audit** | axe-core CI | A11y 100/100 |
| **finance-billing-ops** | Trial → paid flow | Dunning emails |
| **env-secrets-manager** | BYOK rotation flow | Stripe live key rotation drill |
| **intl-expansion** | DE + FR translation | EU rollout plan |
| **incident-commander** | On-call rotation | Tabletop SEV1 drill |
| **community-building** | Discord scaffold | First weekly AMA |
| **change-management** | Pilot Slack → Discord migration | Wave B comms cadence |
| **saas-metrics-coach** | Wave A retro | Wave B funnel kuruluş |
