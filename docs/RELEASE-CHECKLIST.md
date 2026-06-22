# PsyClinicAI — Release Checklist & Backlog (2026-06-03)

## Sprint 9-24 sonu mevcut durum

- **Test:** 768 yeşil · **Analyzer:** 0 error
- **Route:** 60 unique · **Lib:** ~138 dosya · **Cloud Functions:** 10 export
- **Compliance:** HIPAA aligned · GDPR Art. 28/30/35 · KVKK · SOC 2 evidence
- **Public legal:** 17 sayfa (privacy / ToS / DPA / BAA / pricing / compare / faq / trust / 9 daha)
- **Skill panel ortalama:** 6.3 → ~8.7
- **Web + Mobile baseline:** 61 + 61 PNG (Downloads sync)

Tüm "yazılım hızıyla çözülebilir" maddeler kapandı. Aşağıdaki backlog **dış bağımlılık + insanlık iş + native uzman** ister.

---

## A. Third-party / Legal (kod değil, sözleşme + onboarding)

| Madde | Süre | Blokladığı |
|---|---|---|
| Daily.co BAA + recording S3 eu-central-1 sertifikasyon | 2-4 hafta | Telehealth canlı |
| Stripe Connect KYC (production keys) | 3-5 iş günü/tenant | Payments lifecycle |
| Mollie EU domain verify | 2 iş günü | SEPA + iDEAL + SOFORT |
| Anthropic data policy + DPA imzası | 1 hafta | LLM proxy commercial |
| MDR Class IIa CDSS notified body (TÜV SÜD veya BSI) | 9-14 ay | AI Diagnosis EU launch (Class I claim ile geçici) |
| SOC 2 Type II audit period başlatma | 6 ay | Enterprise satış stempel |
| ISO 27001:2022 roadmap | 12-18 ay | Kamu sektörü RFP |
| HIPAA BAA kendi tarafımız (PsyClinic GmbH legal entity) | 2 hafta | US PHI alımı |
| Cyber liability insurance (kendi tarafımız) | 3-5 iş günü | Genel risk |

**Kritik path:** Daily.co BAA + Stripe KYC + Anthropic DPA paralel başlatılırsa 4-6 hafta.

---

## B. iOS-native (Flutter dışı Swift kod — 1 native uzman gerek)

| Madde | Süre | Etki |
|---|---|---|
| Live Activity / Dynamic Island | 4g | "Session live · 23:14" — pazarlama altın madde |
| Lock Screen Widget | 2g | Today's first session + emergency C-SSRS QA |
| Apple Watch glance | 5g | "Running late" → SMS template tek tap |
| Continuity Camera | 2g | Desktop session + phone doc cam |
| Hand-off (NSUserActivity) | 3g | Desktop'taki session'ı mobile'da aç |
| CarPlay companion | 5g | V2 (post-launch) |
| Push Notification Permission Primer | 1g | iOS HIG primer modal |
| App Tracking Transparency (ATT) | 0.5g | iOS 14.5+ zorunlu |
| Privacy Nutrition Label preview | 1g | App Store submission |

**Toplam:** ~25 dev-gün × 1 iOS-native = 5 hafta (post-launch acceptable).

---

## C. Backend deployment (Cloud Functions live)

| Madde | Süre | Durum |
|---|---|---|
| `llmProxy` production deploy + Vault KMS-wrap + Anthropic key | 1g | Kod var, env değil |
| `stripeConnectOnboard` + `stripeConnectWebhook` production URL | 1g | Stripe sandbox → prod keys |
| `telehealthRoom` Daily.co prod API key | 0.5g | Stub var, real API yok |
| `accessReviewCron` schedule + IAM permissions | 0.5g | Kod var, deploy yok |
| Firestore rules deploy (`firebase deploy --only firestore:rules`) | 0.5g | Rules dosyası güncel |
| `auditRetentionPurge` 6-yıl retention test | 1g | Leap-safe sixYearsBefore implement edildi |
| `escalationSoftLockCleanup` saatlik cron deploy | 0.5g | Kod var |
| Stackdriver / Sentry ayarı + error budget alerting | 1g | — |

**Toplam:** ~6 dev-gün × 1 DevOps = 1 hafta.

---

## D. Auth / Identity (enterprise pazar için)

| Madde | Süre | Hedef pazar |
|---|---|---|
| SAML SP config (Workspace + Azure AD) | 3g | Enterprise klinik grupları |
| OIDC (Okta + Auth0 + Keycloak) | 3g | Mid-size practices |
| Just-in-time (JIT) provisioning + SCIM | 4g | 100+ klinisyenli grup |
| WebAuthn / Passkey enrolment | 3g | MFA upgrade Sprint 25 |
| Org switcher RBAC enforce (sunucu tarafı) | 2g | Tenant isolation E2E |

**Toplam:** ~15 dev-gün = 1.5 sprint. Enterprise launch path; günlük tenant için kritik değil.

---

## E. Clinical validation (insanlık iş — paralel başlatılabilir)

| Madde | Süre | Hedef |
|---|---|---|
| 3-psikiyatrist AI diagnosis 20-vignette gold standard | 2 hafta | Sensitivity ≥80%, Specificity ≥80%, Halüsinasyon <%5 |
| C-SSRS validation by Columbia Lighthouse | 1 hafta | Klinik akış sign-off |
| Safety plan Stanley-Brown 6-step review | 3 gün | Standart compliance |
| Sub-clinical liability sigortası | 2 hafta | Genel risk |
| TR clinician advisory board (5 hekim) | 4 hafta | TR launch için |
| EU AI Act compliance — "limited risk" classification doc | 1 hafta | EU launch için |
| Clinician onboarding video (10 min) | 1 hafta | Conversion ramp |

**Toplam:** 5-6 hafta paralel (engineering iş değil).

---

## F. A11y polish (WCAG 2.2 AA + VPAT)

| Madde | Süre |
|---|---|
| Dynamic Type axxl test — overflow yok | 2g |
| Skip-to-content link (Flutter web `<a id="skip">`) | 0.5g |
| Visible focus ring audit + theme update | 2g |
| Aria-live for AI streaming + risk modal (kısmen var) | 1g |
| Keyboard nav E2E (`Tab` cycle every route) | 3g |
| Screen reader test (VoiceOver + TalkBack 5 saat) | 2g |
| VPAT 2.4 Rev 508 taslak | 3g |
| EU Web Accessibility Directive (2018) self-assessment | 1g |
| Captions/transcript altyazı for telehealth | 4g |

**Toplam:** ~18 dev-gün + 1 a11y consultant = 4 hafta.

---

## G. Growth + SEO + Marketing surface

| Madde | Süre | Hedef |
|---|---|---|
| Programmatic SEO 50+ landing (`/usa/{state}/...`, `/eu/{country}/...`) | 5g | Organic acquisition |
| Schema.org JSON-LD enjeksiyon (SoftwareApplication + MedicalOrganization + FAQPage) | 1g | SERP rich snippet |
| Sitemap.xml + robots.txt (Flutter `web/` static) | 0.5g | Crawl |
| Canonical + hreflang (EN / TR / DE / IT / NL / FR / ES) | 1g | Multi-region SEO |
| Core Web Vitals tune — LCP <1.2s, CLS <0.1, INP <200ms | 3g | Search ranking |
| Email template editor + sequence builder UI | 4g | Marketing ops |
| Webhook console + partner API key mint | 3g | Integrations |
| Lead magnet — "EU clinic compliance starter pack" PDF | 2g | Top-of-funnel |
| Cmd+K command palette | 2g | Power-user retention |
| ProductHunt launch kit | 1g | Launch day |

**Toplam:** ~22 dev-gün = 1 sprint.

---

## H. Release engineering + QA

| Madde | Süre |
|---|---|
| E2E test suite — Playwright 50+ user journey | 5g |
| Load test — k6 / Artillery (1000 concurrent clinician) | 3g |
| Penetration test — third-party (Cobalt / Bishop Fox) | 3 hafta (vendor) |
| Disaster recovery drill — region failover + audit log integrity | 2g |
| iOS App Store submission + Apple Review | 1-2 hafta Apple |
| Google Play Store submission + Review | 3-7 gün Google |
| Status page (statuspage.io / instatus) entegrasyon | 1g |
| PR + Press kit dağıtım | 1g |
| Beta cohort onboarding — 25 US + 10 EU clinician | 4g |
| Production observability — Sentry + Datadog + PagerDuty | 2g |
| Runbook + on-call rotation | 2g |
| Backup verification + retention policy job | 1g |

**Toplam:** ~24 dev-gün + 3-5 hafta vendor/store bekleme.

---

## I. Türkçe pazara özel (KVKK + MEDULA + advisory)

| Madde | Süre |
|---|---|
| TR locale full coverage (UI + clinical scales validated translations) | 5g |
| MEDULA / SGK e-Reçete entegrasyon (SOAP) | 10g |
| Sağlık Bakanlığı e-Reçete API | 5g |
| KVKK VERBİS kayıt | 2 hafta (legal) |
| TR clinician advisory board (5 hekim) | 4 hafta |
| TR DPA + KVKK Madde 28 işleyen sözleşmesi | 1 hafta |
| TR landing + pricing TRY üzerinden | 2g |

**Toplam:** TR launch için ayrı 6-8 hafta paralel.

---

## J. Documentation + onboarding

| Madde | Süre |
|---|---|
| OpenAPI viewer + developer portal | 4g |
| Storybook + Figma library sync | 5g |
| CHANGELOG.md full retroactive (v0.1 → v1.0) | 1g |
| Clinician quickstart video (10 min) | 1 hafta (production) |
| Help center / knowledge base (Notion + custom domain) | 5g |
| API rate-limit doc + auth doc | 2g |

**Toplam:** ~3 hafta.

---

## Minimum Viable Go-Live (MVG) — 6 hafta plan

Sırasıyla paralel:

### Hafta 1-2 (legal kickoff + backend deploy)
- A: Daily.co BAA başlat · Stripe KYC clinic 1 · Anthropic DPA
- C: Tüm Cloud Functions production deploy
- E: 3-psikiyatrist vignette başlat
- H: Penetration test vendor onboarding başlat
- F: A11y QA başlat (paralel)

### Hafta 3-4 (Auth + Growth + iOS)
- D: SAML + OIDC entegrasyon
- G: Programmatic SEO + JSON-LD + sitemap + Core Web Vitals
- B: Live Activity + Lock Screen Widget + Hand-off (1 native uzman)
- H: E2E + load test

### Hafta 5-6 (QA + Beta cohort + Launch)
- E: Vignette validation tamam, klinik sign-off
- F: VPAT taslak yayınla
- H: iOS App Store + Google Play submission
- H: 25 US + 10 EU beta cohort onboarding
- J: Quickstart video + help center

### Hafta 7-8 (Buffer + soft launch)
- Beta feedback iterasyonu
- Penetration test rapor + remediation
- Status page live
- PR + ProductHunt launch kit

---

## Realist go-live tahmin

| Yol | Süre | Tarih | Koşul |
|---|---|---|---|
| **Optimistik** | 6 hafta | 2026-07-15 | Daily.co BAA + Stripe KYC tek seferde geçer |
| **Beklenen** | 8 hafta | 2026-07-29 | Penetration test 1 round remediation |
| **Konservatif** | 10 hafta | 2026-08-12 | App Store ikinci submission |

**Hedef skill panel ortalaması Sprint 28 sonu:** 8.7 → **9.4 / 10**

---

## Acil mimari kararlar (1 hafta içinde verilecek)

1. **LLM secret store:** Vault Enterprise vs Google Secret Manager + EnvelopeKMS — Sprint 25 deploy için karar lazım.
2. **EHR adapter:** Redox / Lyniate third-party vs in-house FHIR client — Sprint 26 maliyet vs hız.
3. **Multi-tenant Auth backend:** Firebase Auth devam vs Keycloak self-hosted — SAML + KVKK için kritik.
4. **MDR Class IIa CDSS pathway:** TÜV SÜD vs BSI notified body seçimi.
5. **Recording retention default:** Daily.co 30g / 90g / opt-in only.
6. **iOS-native uzman:** İç ekip yetiştir vs freelance kontrat (4-8 hafta) vs Sprint 25 erte.

---

## Risk matrisi

| Risk | Olasılık | Etki | Mitigation |
|---|---|---|---|
| Daily.co BAA >4 hafta | Orta | Telehealth gecik | Whereby Healthcare / Zoom HIPAA paralel |
| Stripe KYC EU entity reddi | Düşük | Payments blok | Mollie SEPA + Adyen alternatif |
| LLM proxy cold-start >500ms | Orta | UX | Cloudflare Workers edge + warm pool |
| Vault Enterprise lisans aşımı | Orta | Bütçe | Google Secret Manager fallback |
| MDR Class IIa gecik | Yüksek | AI EU launch | Class I claim + roadmap |
| Vignette validation fail (<80%) | Düşük | AI backlog | Prompt iterate + Opus 4.7 default |
| iOS App Review red | Düşük | App Store gecik | Privacy doc proactive review |
| Pentest critical bulgu | Orta | Launch gecik | Remediation 1 sprint buffer |
| Beta cohort UX feedback negatif | Düşük | Soft launch erte | 2 hafta iterasyon buffer |
| Cyber liability sigortası reddi | Düşük | General risk | Lloyd's + Beazley alternatif quote |

---

**Toplam kalan iş:** ~120 engineering-gün + ~5-8 hafta external bekleme.
**Tek dev-day ile:** minimum 6 hafta, full kapsamla 12 hafta.

**En kritik dış bağımlılık:** Daily.co BAA (en uzun lead time). Bugün başlatılırsa 2026-07-29 beklenen launch'a yetişir.
