# Sprint 33 — Cure53 engagement live + EU launch + Android shell + GA prep

**Tarih:** 2026-08-03 → 2026-08-16 (2 hafta)
**Önceki:** Sprint 32 — Wave B karar günü + native iOS shell + Cohere reranker (bkz. `sprint-32-plan.md`)
**Hedef:** Cure53 engagement (Eylül 15 kickoff) için son hazırlık + EU pilot Phase 2 (DE + UK + AT canlı) + native Android shell + GA tag v1.0.0 hazırlığı.
**Skill panel hedef:** 9.5 → **9.6**

> **Master gate (release-manager + ciso-advisor):** Sprint 32 Wave B Track A geçtiyse v1.0.0 GA bu sprint sonu hedef. Track B/C geçtiyse Sprint 33 = UX tuning + Cure53 prep + EU expansion paralel, GA Sprint 34'e kayar.

---

## 0. Önceki sprintlerden taşınanlar

Sprint 31 + 32'de yazılan ama vendor unlock bekleyenler (artık dönmüş olmalı):
- Stripe live key + trial→paid graduation (`stripeSubscriptionWebhook` Sprint 32 P0)
- PostHog DSN bağlı, Wave A activation cohort verisi mevcut
- Sentry release tracking otomatik (Sprint 32 W2 P1)
- Sendgrid welcome + dunning email template'leri imzalı
- TestFlight iOS shell (Sprint 32 P1) — 5 pilot iOS'ta çalışıyor

EU Phase 2 service code (`EuCountryLawService` DE+UK+AT) Sprint 32+33 hazır; bu sprintte UI'a bağlanıyor.

---

## Öncelik özeti

| Sıra | İş | DRI | Süre | Bağlı persona |
|---|---|---|---|---|
| **P0** | Cure53 engagement kit final → 2026-09-15 kickoff onayı | ciso-advisor + counsel | 2g | senior-security |
| **P0** | EU pilot Phase 2 onboarding — DE + UK + AT ilk 3 pilot | founder + customer-success | 2g | cmo-advisor + intl-expansion |
| **P0** | Pentest retest evidence kit 10/12 imzalı (F-001..F-012) | sec-team | 2g | adversarial-reviewer |
| **P0** | Wave B funnel sağlık kontrolü — D7 activation ≥ 60 % sürdürülüyor mu? | growth-wg | 1g | saas-metrics-coach |
| **P1** | Native Android shell — Google Play Console kayıt + ilk binary | senior-frontend | 4g | kotlin-patterns + app-store-optimization |
| **P1** | DE + FR translation production — NICE/EMA validated PHQ-9/GAD-7 strings | senior-frontend + intl-expansion | 3g | gdpr-dsgvo-expert |
| **P1** | EU pilot UI: country selector + alerts banner (`EuCountryLawService` hook) | senior-fullstack | 2g | healthcare-cdss-patterns |
| **P1** | EHR FHIR R4 outbox reconciliation cron — failed → retry hourly | senior-backend | 1.5g | healthcare-emr-patterns |
| **P1** | SOC 2 evidence registry quarter 2 snapshot çalıştır | ciso-advisor | 1g | soc2-compliance |
| **P2** | v1.0.0 GA tag + GitHub Release + customer email | release-manager + founder | 1g | brand-voice |
| **P2** | Customer Portal UI — pilot kart bilgisini Stripe Customer Portal'da güncelleyebilir | senior-frontend | 2g | finance-billing-ops |
| **P2** | Cohere reranker eval delta evidence yayını | rag-architect | 1g | senior-ml-engineer |
| **P3** | Voyage AI vs Cohere reranker karşılaştırma çalışması | senior-ml-engineer | 2g (async) | adversarial-reviewer |
| **P3** | Multi-jurisdiction US Phase 2 — FL + IL + WA eklemesi | senior-fullstack | 2g | healthcare-cdss-patterns |

---

## W1 (2026-08-03 → 2026-08-10) — Cure53 + EU pilots + Android

### 1. Cure53 engagement kit final ⚡ P0
**Süre:** 2g · **DRI:** ciso-advisor + counsel
- Sprint 32 W1'de imzalanan scope letter → final dokümantasyon paketi
- Pre-engagement evidence package son hali:
  - `docs/security/findings.csv` 10/12 verified
  - `docs/security/evidence/2026q3/F-XXX/` 10 retest klasörü full
  - `docs/security/threat-model.md` Sprint 33 öncesi review
  - `docs/security/incident-response.md` IR drill log eklenmiş
  - `docs/legal/SUBPROCESSORS.md` Cohere + Voyage + new payments güncel
  - `docs/security/workforce-training.md` Q3 training-completion CSV güncel
  - `docs/security/cure53-prep.md` — engineer onboarding rehberi (yeni)
- PGP key publish (`pentest@psyclinicai.com`) — keys.openpgp.org doğrulama
- Cure53 kickoff toplantısı 2026-09-15 Calendar invite + Slack #cure53 channel açık

**DoD:** Cure53 "we have everything we need" yazılı confirm.

### 2. EU pilot Phase 2 onboarding ⚡ P0
**Süre:** 2g · **DRI:** founder + customer-success
- DE + UK + AT'dan 3 pilot klinisyen onboard
- Pilot Agreement'in DE + UK + AT yasal incelemesi (counsel — DE Berufsgeheimnis, UK GMC, AT § 121 StGB clauses)
- EU pilotlara `EuCountryLawService` alert banner'ı görünür
- Onboarding email DE + UK + AT lokalizasyonu
- Activation funnel + D7 cohort EU pilot için ayrı segment

**DoD:** 3 EU pilot signed-in + first_soap_generated ≤ 7d + zero SEV1/SEV2 in 48 h soak.

### 3. Pentest retest evidence imzalama ⚡ P0
**Süre:** 2g · **DRI:** sec-team
- Sprint 32 MM'de 4 finding evidence kit (F-001, F-002, F-006, F-008) hazırdı
- Kalan 6: F-005, F-007, F-009, F-010, F-011, F-012 — aynı template ile somut curl + screenshot + log
- Her birinde 3-persona sign-off
- `docs/security/findings.csv` 10/12 → `fixed_verified`

**DoD:** Pentest ledger %95+ maturity sabit.

### 4. Native Android shell 🤖 P1
**Süre:** 4g · **DRI:** senior-frontend
- `flutter build apk --release` test
- Google Play Console account setup
- Internal testing track build push
- 5 pilot beta tester davet
- Android-specific UX: Material You theming, Predictive Back gesture
- Android Health Connect entegrasyonu scope
- App Bundle signing + Play App Signing

**DoD:** Internal testing build canlı, 5 pilot Android'de session açabilsin.

### 5. Wave B funnel sağlık kontrolü ⚡ P0
**Süre:** 1g · **DRI:** growth-wg
- PostHog: D7 activation hala ≥ 60 % mı?
- Sentry: error rate < 1 % 7-gün soak
- Stripe: trial → paid conversion (Wave A'dan dönenler için)
- Pilot NPS quick survey — Wave B cohort
- Karar: GA tag'i bu sprint sonu mu, Sprint 34'e mi kayıyor

**DoD:** Sprint-33-closeout.md §karar imzalı.

---

## W2 (2026-08-10 → 2026-08-16) — Translation + EHR + GA tag

### 6. DE + FR production translation 🌐 P1
**Süre:** 3g · **DRI:** senior-frontend + intl-expansion
- Sprint 32 P3'te seed olan `intl_de.arb` + `intl_fr.arb` clinical strings doldurulur
- NICE/EMA + APA validated PHQ-9 + GAD-7 + C-SSRS translation kullan
- Native speaker review (paid translator — ~$500 budget kaldı)
- `flutter gen-l10n` regenerate
- E2E test DE + FR locale'de "first SOAP generated" akışı

### 7. EU pilot country selector + alerts UI 🌍 P1
**Süre:** 2g · **DRI:** senior-fullstack
- Settings → "My licensed countries" → multi-select (DE, UK, AT, US states)
- Seans başında banner: `EuCountryLawService.hasCriticalAlert()` true ise red banner
- Telemetry: `legal.country_selected`, `legal.alert_viewed`, `legal.alert_dismissed`
- Test: 3 EU pilot için doğru alerts gösteriliyor

### 8. EHR FHIR R4 outbox reconciliation cron 🩺 P1
**Süre:** 1.5g · **DRI:** senior-backend
- `functions/src/ehr_outbox_reconciler.ts` — hourly cron
- `ehr_outbox/{tenant}/entries` where `status=failed` → retry up to 24 h
- 24 h sonra hala failed → `tenants/{tid}/private/ehr_failed` + Slack alert
- Test: 10 sandbox outbox satırı, network blip simulate, 8 sent / 2 failed kalır

### 9. SOC 2 evidence Q2 snapshot 📋 P1
**Süre:** 1g · **DRI:** ciso-advisor
- Sprint 32 collect-soc2-evidence.sh çalıştır
- Manual TODO: CC1.5, CC2.3, CC3.4
- Audit trail row yazılır
- Cure53 evidence package'a CC6.7 + CC7.5 ekleniyor

### 10. v1.0.0 GA tag 🎉 P2 (Track A only)
**Süre:** 1g · **DRI:** release-manager + founder
- Wave B funnel ≥ 60 % activation kanıtlandıysa
- `git tag -a v1.0.0 -m 'GA release — Wave B activation proven'`
- GitHub Release notes — CHANGELOG.md `[Unreleased]` → `[1.0.0]`
- Stripe artık `founding rate` lifetime locked, `regular rate` yeni signup'lara
- Customer email blast: "We're GA — your founding rate is locked"
- ProductHunt + HN "v1.0 milestone" post

### 11. Customer Portal UI 💳 P2
**Süre:** 2g · **DRI:** senior-frontend
- Settings → Billing → "Manage subscription" button
- Stripe Customer Portal redirect (no in-app card-edit — PCI scope dışında)
- Telemetry: `billing.customer_portal_opened`, `billing.invoice_downloaded`

### 12. Cohere reranker eval delta yayını 🎯 P2
**Süre:** 1g · **DRI:** rag-architect
- 4 hafta gerçek data: baseline (vector only) vs reranked precision@8 delta
- `docs/eval/2026-Q3-rerank-results.md` yayınla
- Cure53 evidence package'a dahil et

---

## Risk + bağımlılıklar

| Risk | Olasılık | Etki | Mitigation |
|---|---|---|---|
| Cure53 engagement letter onayı gecikir | M | Eylül 15 kayar | NCC yedek opsiyon zaten letter signed |
| EU pilot < 3 signed | M | EU GTM zayıf | UK + DE + AT outreach Sprint 32'de başlamıştı |
| Google Play review red | L | Android shelf'te kalır | iOS Sprint 32'de geçtiyse Android için Play Console policy compliance pre-review |
| DE + FR translator gecikir | M | Production locale yarım | Wave A için EN fallback hâlâ çalışıyor |
| GA criteria miss (Track B/C) | M | v1.0.0 Sprint 34'e kayar | release-manager veto |
| Cohere maliyet patlaması | L | $200+ aşırı fatura | Sprint 30 cost cap ledger Cohere için extend |

---

## Tanım: Done

Sprint 33 sonu için (skill panel veto kurallarıyla):

- [ ] **release-manager:** v1.0.0 GA tag (Track A) veya v1.0.0-beta.4 (Track B/C); GitHub Release notes
- [ ] **founder-coach:** 3 EU pilot signed-in (DE + UK + AT en az birer)
- [ ] **ciso-advisor:** Cure53 evidence package "ready" + 10/12 finding `fixed_verified`
- [ ] **product-strategist:** Sprint 34 plan draft
- [ ] **cmo-advisor:** v1.0 launch announcement ya da retro
- [ ] **saas-metrics-coach:** EU cohort PostHog'da ayrı, Wave B kohortu D14 retention ≥ 70 %
- [ ] **senior-frontend:** Android Internal testing build, 5 pilot davet; DE + FR locale
- [ ] **senior-fullstack:** EU country selector + alerts UI üretimde
- [ ] **senior-backend:** EHR outbox reconciler cron çalışıyor
- [ ] **rag-architect:** Cohere eval delta evidence yayında
- [ ] **healthcare-cdss-patterns:** EU pilot için kritik alert banner görünüyor
- [ ] **adversarial-reviewer:** Sprint 33 sonu red-team run 0 hit
- [ ] **brand-voice:** v1.0 launch surface'leri "we / EU-based" sesinde

**Pentest maturity:** %95 sabit; Cure53 engagement %100 prep complete.

---

## Sprint 34 ön-sinyalleri (planlama notu)

- Cure53 engagement Eylül 15 başlar → Sprint 34 ortasında interim rapor
- Multi-jurisdiction US Phase 2 (FL + IL + WA) — Sprint 33 sonu polish
- Voyage AI vs Cohere karşılaştırma sonucu Sprint 34'te alternative ramp
- Apple Health + Google Health Connect entegrasyon
- HIPAA + GDPR audit-prep deep (eIDAS qualified e-signature, Sprint 35)
- Founder coaching panel — Wave B → Series Seed pre-flight (Sprint 35)

---

## Skill panel hedefi

| Persona | W1 katkı | W2 katkı |
|---|---|---|
| **release-manager** | Cure53 letter final + Track karar | v1.0.0 GA tag + Release notes |
| **product-strategist** | EU expansion ICP | Sprint 34 plan draft |
| **founder-coach** | EU pilot outreach + onboarding | GA launch comms |
| **cmo-advisor** | EU GTM + launch retro | v1.0 announcement |
| **brand-voice** | EU translation surface audit | GA launch copy review |
| **ciso-advisor** | Cure53 evidence final + IR drill | SOC 2 Q2 snapshot |
| **senior-security** | Pentest retest 10/12 imzalı | Cohere reranker red-team |
| **adversarial-reviewer** | DE + TR jailbreak refresh | EU country selector red-team |
| **rag-architect** | Cohere eval delta ölçümü | Voyage AI spike planning |
| **senior-ml-engineer** | Cohere prod stability | Voyage compare proposal |
| **senior-backend** | EHR outbox reconciler | Customer Portal redirect endpoint |
| **senior-frontend** | Android shell scaffolding | DE+FR locale + Country selector UI |
| **senior-fullstack** | Multi-juris EU UI wire | US Phase 2 (FL+IL+WA) planning |
| **senior-devops** | GA release CI gate | Sentry release v1.0.0 tag |
| **observability-designer** | Crash-free user metric for GA | EU cohort segmentation |
| **kotlin-patterns** | Android shell idioms | Play Store review prep |
| **app-store-optimization** | Play Store listing copy | iOS + Android cross-promo |
| **healthcare-emr-patterns** | EHR Observation outbox reconcile | Apple/Google Health roadmap |
| **gdpr-dsgvo-expert** | DE + FR translation validation | EU pilot DPA addendum |
| **healthcare-cdss-patterns** | EU pilot critical alert banner | US Phase 2 state law planning |
| **intl-expansion** | DE + FR production translation | Multi-jurisdiction EU expansion plan |
| **finance-billing-ops** | Stripe trial → paid live trafik | Customer Portal verify |
| **saas-metrics-coach** | Wave B Retention D14 | EU cohort funnel D7 |
| **change-management** | EU pilot comms | v1.0 launch comms cadence |
| **incident-commander** | IR drill + Cure53 onboarding | GA day war-room plan |
| **soc2-compliance** | Q2 evidence + audit trail | Q3 ramp |
| **tdd-guide** | EU service + UI test coverage | GA regression suite |
| **community-building** | EU pilot Discord welcome | v1.0 AMA |
