# Sprint 18-20 Production-Hardening Plan

Plan dosyası `~/Downloads/psyclinicai-sprint-17/plan/09-FINAL-SCREEN-AUDIT.md` denetimine cevap.
UI + compliance vitrini Sprint 17'de A seviyesine geldi; bu plan **gerçek backend wiring** + **3rd party legal** + **clinical validation** zincirlerini sıraya koyar.

---

## Neden Sprint 17 sonu hâlâ "feature complete" değil

Her eksik özelliğin gerçek blokeri yazılım hızı değil — bekleyen üç ana kategori:

1. **3rd-party legal / onboarding** — sözleşme + KYC bekleme süresi
2. **Clinical validation** — klinisyen review döngüsü + regulatory pathway
3. **Mimari karar** — Sprint 0 kapısı henüz açılmadı

---

## Sprint 18 — Backend wiring + 3rd party başlatma (2 hafta)

### W1 (hafta 1)

| # | İş | Önceki blok | DRI | Süre |
|---|---|---|---|---|
| 1 | **Stripe Connect onboarding flow** — `/api/stripe/connect/onboard` + `Account.create` + return URL + `account.updated` webhook | KYC 3-5 iş günü Stripe tarafında bekleme; UI Sprint 17'de hazır | senior-backend | 3 gün |
| 2 | **Mollie SEPA mandate webhook** — `mandate.created` → Firestore + idempotency store | Mollie EU domain doğrulama 2 gün | senior-backend | 2 gün |
| 3 | **MFA TOTP enrolment akışı** — Firebase `multiFactor.session` + QR generate + verify + recovery code PDF | Firebase Web SDK TOTP hâlâ beta; Android/iOS code path ayrı | FE + BE | 3 gün |
| 4 | **`02-login` post-sign-in MFA interceptor** — `mustEnrolMfa: true` → `/settings/mfa` redirect; tenant policy enforce | (1.3 sonrası) | FE | 0.5 gün |

### W2 (hafta 2)

| # | İş | Önceki blok | DRI | Süre |
|---|---|---|---|---|
| 5 | **Daily.co server-side oda mintleme** — `room.create` + recording consent gate runtime + EU-only S3 bucket (eu-central-1) BAA-li | Daily.co BAA imzası 2-4 hafta — paralel başlatılır | BE + ciso | 5 gün |
| 6 | **`38-payments` UI ↔ backend wiring** — Stripe Connect status kart + plan picker + invoice listesi + saved payment methods | (1) → (6) | FE | 3 gün |
| 7 | **`53-status` per-tenant region pin** — Firestore rules + KMS region pin + cross-region drift guard cron | mimari karar gerekli | architect + BE | 4 gün |

**Sprint 18 toplam:** ~20 dev-gün × 2 engineer = 10 iş günü = 2 hafta.
**Legal paralel:** Stripe Connect KYC + Mollie EU verify + Daily.co BAA aynı anda başlat (PM owner).

### Sprint 18 çıktısı
- Real payment lifecycle: deposit hold → no-show capture → refund
- MFA enrolment çalışır (TOTP + recovery)
- Daily.co odası gerçekten açılır (BAA imzalı tenant için)
- "EU residency" iddiası teknik olarak doğrulanabilir

---

## Sprint 19 — AI + güvenlik mimarisi (2 hafta)

### W1

| # | İş | Önceki blok | Süre |
|---|---|---|---|
| 8 | **LLM proxy `/v1/ai/llm`** — Vault/Secret Manager KMS-wrap + per-tenant request signing + cold-start <300ms | mimari: Vault vs Google Secret Manager karar gerekli | 4 gün |
| 9 | **Presidio-style PHI redaction** — patient identifier + locale-aware (TR isim listesi + DE umlaut) + transcript pre-LLM scrub | (8) → (9) | 3 gün |
| 10 | **`34-api_keys` proxy mode toggle** — "BYOK direct" (legacy) vs "Server-side (recommended)" + tenant cost meter widget | (8) → (10) | 2 gün |

### W2

| # | İş | Önceki blok | Süre |
|---|---|---|---|
| 11 | **`21-ai_diagnosis` structured output** — Anthropic tool-use JSON schema (`differential_candidate[]`) + candidate card renderer + accept/reject + audit log entry | Clinical validation: 3 psikiyatrist gold standard 20 vignette — paralel 2 hafta | 4 gün |
| 12 | **Risk escalation modal otomasyonu** — PHQ-9.q9 → C-SSRS prompt → safety plan trigger → push alert chain | model layer Sprint 17'de var | 4 gün |
| 13 | **`26-cssrs` + `27-audit` desktop responsive + clinician/self mode toggle** | AppShell wrap refactor | 2 gün |

**Sprint 19 toplam:** ~19 dev-gün × 2 engineer = ~10 iş günü.
**Clinical paralel:** 3-psikiyatrist vignette review (TR + DE + US advisor) — 2 hafta.

### Sprint 19 çıktısı
- Browser'da Anthropic API anahtarı YOK
- AI diagnosis structured output, accept/reject + audit
- Risk escalation otomatik zinciri çalışır
- Tüm assessment ekranları desktop responsive

---

## Sprint 20 — Polish + lokalizasyon + analytics (2 hafta)

| # | İş | Süre |
|---|---|---|
| 14 | `05-dashboard` metric kartları gerçek Firestore sorgu (today/pending/at-risk/$outstanding) | 3 gün |
| 15 | `06-patients` filter chip bar + saved view (Risk/Insurer/Last seen/Status) | 2 gün |
| 16 | `25-assessments-result` 30/90/365-day trend chart (`fl_chart`) + severity color encoding fix | 3 gün |
| 17 | `35-audit_log` row detail drawer + Verify chain CTA + payload diff | 3 gün |
| 18 | `31-settings` 6 eksik section (Security/Notifications/Data&Privacy/Billing&Plan/Team&Roles/Legal) | 3 gün |
| 19 | `17-treatment_plan` template picker + SMART goal builder + version history | 4 gün |
| 20 | `13-session` End→Save dialog + autosave göstergesi | 1 gün |
| 21 | `14-session_management` ya kaldır ya ana app'e bağla | 1 gün |
| 22 | **A11y pass** — WCAG 2.2 AA kontrast, label, focus order, semantics, screen reader | 4 gün |
| 23 | **Lokalizasyon başlat** — TR + DE (`flutter_localizations` + ARB) | 3 gün |
| 24 | `41-trust-subprocessors` Last reviewed + DPA signed date + SCC module | 1 gün |
| 25 | `42-trust-security_controls` evidence link + last verified date | 1 gün |

**Sprint 20 toplam:** ~29 dev-gün × 2 engineer = ~15 iş günü = 3 hafta (4 advisor + 2 engineer).

---

## Realist Go-Live

| Yol | Süre | Tarih |
|---|---|---|
| **Optimistik** — N-11 region pin Sprint 18'de, Stripe KYC ilk hafta biter, Daily.co BAA paralel hızlanır | 6 hafta | 2026-07-14 |
| **Beklenen** — Stripe + Daily.co legal 3-4 hafta sürer, Sprint 18 yarısı bekler, Sprint 19'a kayma | 8 hafta | 2026-07-28 |
| **Konservatif** — Vault mimari kararı +1 hafta, clinical validation tekrar tur | 10 hafta | 2026-08-11 |

---

## Bekleyen Mimari Kararlar (Sprint 0 kapısı)

1. **LLM secret store:** Vault Enterprise vs Google Secret Manager vs HashiCorp OSS + EnvelopeKMS. Karar gerekli, CTO + CISO oturumu.
2. **Multi-tenant Firestore region strategy:** Per-tenant single-region pin (önerilen) vs dual-region with selective sync.
3. **MDR Class IIa CDSS pathway:** AI Diagnosis CE marking — Class I başla + Class IIa upgrade plan, notified body seçimi (TÜV SÜD vs BSI).
4. **Recording retention default:** Daily.co video recording 30g vs 90g vs opt-in only — tenant tercihi + GDPR Art. 5 storage limitation.

Bu 4 karar verilmeden Sprint 18'in `7` ve Sprint 19'un `8`, `11` blok.

---

## Test + CI Coverage Sprint 17 Sonu

- **Unit + widget tests:** 639/639 yeşil
- **Analyzer:** 0 error · 186 info (mostly `prefer_const_constructors`)
- **Coverage hedef:** 80%+ — şu an ~%72 (lib/ statements)
- **E2E:** Playwright headless 54 route capture ✅ (görsel regresyon baseline)
- **Lighthouse:** henüz koşulmadı — Sprint 20'de a11y pass ile birlikte
