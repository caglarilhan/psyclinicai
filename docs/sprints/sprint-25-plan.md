# Sprint 25 — Launch Prep (2 hafta)

**Tarih:** 2026-06-03 → 2026-06-17
**Önceki:** Sprint 24 — Insurance kanban + EHR console + Inbox + Dark theme
**Hedef:** "Beklenen" go-live yolunda (2026-07-29) ilk 2 haftalık launch-prep paketi
**Skill panel hedef:** 8.7 → 9.1

---

## W1 (2026-06-03 → 2026-06-10) — Backend live + SEO + a11y

### 1. Cloud Functions production deploy ⚡
**Süre:** 2g · **DRI:** senior-backend + DevOps
- `llmProxy` — Anthropic key Vault'tan al, `/v1/ai/llm` prod URL
- `stripeConnectOnboard` + `stripeConnectWebhook` — production keys + webhook subscribe
- `telehealthRoom` — Daily.co prod API key (BAA imzalanır imzalanmaz)
- `auditRetentionPurge` schedule deploy (6-yıl HIPAA §164.316)
- `accessReviewCron` schedule (SOC 2 CC6.1)
- `escalationSoftLockCleanup` saatlik cron
- `accountDeletionPurge` (GDPR Art. 17 grace window expire)
- Firestore rules deploy
- Sentry + Datadog production project setup

### 2. SAML SSO + OIDC entegrasyon 🔐
**Süre:** 4g · **DRI:** senior-security
- `lib/services/data/sso_provider_registry.dart` — IdP metadata + ACS URL builder
- Workspace SAML SP config + signing certificate
- Azure AD app registration + claim mapping
- Okta OIDC client setup
- `/settings/sso` admin screen — IdP picker + test login + JIT toggle
- Tenant-level "Require SSO" enforce policy

### 3. A11y baseline + VPAT taslak ♿
**Süre:** 3g · **DRI:** a11y-audit + senior-frontend
- `<a id="skip-to-content">` Flutter web `web/index.html` injection
- Visible focus ring theme override
- Dynamic Type ramp test (iOS + Android + web)
- Aria-live polite zones — AI streaming, risk modal, claim board
- VoiceOver + TalkBack keyboard nav E2E (5 saat manuel)
- VPAT 2.4 Rev 508 taslak
- EU Web Accessibility Directive self-assessment

### 4. Programmatic SEO 50+ landing 🌱
**Süre:** 3g · **DRI:** seo-specialist + senior-frontend
- `lib/screens/landing/programmatic/state_landing_template.dart` generic template
- US 50 state landing (`/usa/california/therapists-software` vs.)
- EU 27 country landing (`/eu/germany/...`)
- Per-page schema.org `LocalBusiness` + `SoftwareApplication`
- `web/sitemap.xml` 77+ URL generator (build-time script)
- `web/robots.txt` + canonical + hreflang injection
- Core Web Vitals tune — LCP <1.2s

---

## W2 (2026-06-10 → 2026-06-17) — Growth + Release engineering + Beta

### 5. E2E Playwright suite 🧪
**Süre:** 4g · **DRI:** QA + senior-frontend
- `e2e/journeys/clinician-signup.spec.ts` (signup → MFA → first patient)
- `e2e/journeys/session-flow.spec.ts` (start → SOAP → sign → superbill)
- `e2e/journeys/risk-escalation.spec.ts` (PHQ-9 q9 → CSSRS → safety plan)
- `e2e/journeys/data-export.spec.ts` (DSAR bundle JSON + PDF)
- `e2e/journeys/account-deletion.spec.ts` (GDPR Art. 17 30-day grace)
- 50+ assertion total
- CI integration

### 6. iOS Live Activity + Lock Widget (Swift) 📱
**Süre:** 3g · **DRI:** iOS-native uzman
- `ios/Runner/LiveActivities/SessionLiveActivity.swift` — Dynamic Island view
- `ios/Runner/Widgets/TodaySessionWidget.swift` — Lock screen widget
- `ActivityKit` integration with Flutter via method channel
- "Session live · 23:14" Dynamic Island prototype
- TestFlight internal build

### 7. Email template editor + sequence builder 📧
**Süre:** 3g · **DRI:** senior-frontend + content
- `lib/models/email_template.dart` — kind enum (reminder_24h / no_show / intake_link)
- Mustache token preview (`{{patient_name}}`, `{{session_time}}`)
- WYSIWYG editor (`flutter_quill`)
- Sequence builder — drag-to-reorder + conditional branches
- A/B test toggle per template

### 8. Cmd+K command palette ⌨️
**Süre:** 2g · **DRI:** senior-frontend
- Global `Shortcuts` + `Actions` widget'lar
- Fuzzy search across route + patient + action
- Recent + starred sections
- Keyboard-only navigation (arrow + Enter)
- Notion/Linear-style modal overlay

### 9. Status page + observability 📊
**Süre:** 1g · **DRI:** DevOps
- statuspage.io subscribe widget (Trust Center entegrasyon)
- Sentry + Datadog production project
- Per-service health endpoints (`/health/llm`, `/health/stripe`)
- Alerting — PagerDuty rota + error budget burn rate
- Runbook + on-call rotation doc

### 10. Beta cohort onboarding 🎯
**Süre:** 2g · **DRI:** PM + senior-frontend
- 25 US + 10 EU clinician davet listesi
- Onboarding email sequence (welcome + first-week + feedback)
- Slack / Discord feedback kanalı
- In-app "Beta feedback" floating button
- Weekly digest report (Typeform + Notion sync)

---

## Toplam

**Engineering:** 27 dev-gün × 2 engineer = 14 iş günü = 2 hafta. Tight ama paralel akışlarla yetişir.

**Paralel insan iş:**
- 3-psikiyatrist AI diagnosis vignette validation (clinical, 2 hafta)
- Daily.co BAA negotiation (legal, 2-4 hafta)
- Stripe Connect KYC clinic #1 (vendor, 3-5 iş günü)
- Penetration test (Cobalt onboarding, 3 hafta)

---

## Sprint 25 sonu hedef

- **Test:** 768 → 850+ (E2E + yeni unit testler)
- **Skill panel ortalama:** 8.7 → **9.1 / 10**
- **Public route:** 60 → **130+** (programmatic SEO landing'leri)
- **Backend:** 10 Cloud Function → tümü production
- **Auth:** Firebase + SAML + OIDC + JIT
- **iOS:** Dynamic Island + Lock Widget (TestFlight)
- **Beta:** 35 clinician onboarded

---

## Sprint 26 önyolu (referans)

- Patient self-service PWA (M5 mobile)
- Continuity Camera + Hand-off (iOS native)
- WebAuthn / Passkey enrolment
- TR full locale + MEDULA entegrasyon
- Pentest remediation
- App Store submission

---

## Risk + blocker

| Risk | Olasılık | Mitigation |
|---|---|---|
| Vault enterprise lisansı 1 hafta gecik | Orta | Google Secret Manager fallback |
| Daily.co BAA 4+ hafta sürer | Orta | Whereby Healthcare paralel sözleşme başlat |
| iOS-native uzman bulunmaz | Yüksek | Swift kontrat freelance (~5g) |
| SAML config 1 round retry | Düşük | Workspace + Azure AD paralel POC |
| Programmatic SEO indexing 4-8 hafta | Yüksek | Ahead-of-launch deploy + lighthouse opt |

---

## En kritik 3 madde (W1 başlangıç gün 1)

1. **Cloud Functions prod deploy** — diğer her şey bunun üstüne biner
2. **SAML SSO** — enterprise satışın gating maddesi
3. **A11y baseline** — VPAT + EU Web Accessibility için pre-launch zorunluluk

Bu üçü W1 sonu yetişirse, Sprint 25 başarı garantili.
