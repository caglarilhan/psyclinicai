# Sprint 26 — Kapanış Raporu

**Tarih:** 2026-06-03 → 2026-06-17
**Önceki:** Sprint 25 — Launch Prep (deploy wrapper, SSO, a11y, programmatic SEO, Cmd+K)
**Sonraki:** Sprint 27 — Pentest remediation + RAG hub live (bkz. `sprint-27-plan.md`)
**Skill panel:** 8.7 → **9.0** (hedef 9.1; -0.1 — vendor sertifikasyonu pentest sonrası kapanacak)

---

## Teslim edilen iş

### W1 (`3546aea` — 2026-06-09)

- **WebAuthn passkeys end-to-end**
  - `passkey_register.ts` + `passkey_authenticate.ts` transaction-based challenge consume
  - Sign-count regression auto-revoke (kloning savunması)
  - Origin / RP-id rigid validation (`webauthn_env.ts` + 7 unit test)
  - Mobile MFA: 2FA artık opsiyonel (passkey = phishing-resistant ana faktör)
- **Patient self-service PWA shell** (`/portal`)
  - Landing + appointments + inbox + PROM screens (read-only first cut)
  - Service worker (TODO: kiosk cache kapsamı — pentest finding F-009)
  - Invite-link flow (tek-kullanım dönüşümü Sprint 27'de — finding F-012)

### W2 (`7a6280d` — 2026-06-13)

- **iOS Hand-off** — `SessionHandoffActivity.swift` + Flutter `handoff_channel.dart` (cihazlar arası session devamı)
- **App Store submission paketi** — `docs/release/app-store/*` (listing, screenshots, ASO keywords, review notes, Play Data Safety, Privacy Nutrition Label)
- **Pentest 2026 Q3 iskeleti** — `docs/security/pentest-2026q3.md` + `findings.csv` (boş header)

### Audit close (`4ccb237` + `3a25f62`)

- **8 P0 release blocker** kapatıldı (6 skill paneli)
- **P1 silent-failure + busy-guard** bulguları kapatıldı (auth retry, telemetry consent eksiği, claim board loading flag)

### Bu PR (`d5a9e6e` — 2026-06-14, Sprint 26 dışı +1 commit)

- Clinical RAG client wiring (RagClient + RagService + RagConsoleScreen + 9 test)
- Pentest 2026 Q3 pre-engagement ledger (12 self-audit finding + vendor shortlist + window 2026-09-15..09-26)

---

## Ertelenen / kapsam dışı

| İş | Sebep | Sprint 27'ye taşındı mı |
|---|---|---|
| EHR write-back (FHIR R4 PUT/POST) | Read-only console yeterli oldu pilotlar için; write Bridge MVP'ye Sprint 27 | ✅ |
| 837P denial reason → CARC mapping completion | 60% bitti; payer-specific mapping table eksik | ✅ |
| Lighthouse 90+ web | Şu an 78 (LCP 1.6s). Görsel ağırlığı + bundle split eksik | ✅ |
| Beta tenant onboarding (5 klinik) | Pentest beklemesinde — Q3 sonrası kapı | ❌ (Q4) |
| psyrag hub deployment | Hetzner CX22 sipariş edildi, DNS + Groq key pending | ✅ (Sprint 27 P0) |
| Stripe Connect Express onboarding flow polish | Sponsor kararı: Mollie EU + Stripe US split — bir sonraki tarifeden | ❌ (Sprint 28+) |

---

## Risk kütüğü (Sprint 27'ye giren)

1. **psyrag hub henüz canlı değil** — RAG console şu an `disabled notice` gösteriyor. Kullanıcı etkisi yok ama "Coming soon" rozetiyle hayal kırıklığı yaratabilir. **Azaltıcı:** Sprint 27 P0; CX22 hazır olur olmaz `--dart-define` enjekte + deploy.
2. **Pentest F-001 (LLM prompt exfiltration)** — `copilotRelay` endpoint sandbox'ta exploit edildi. **Azaltıcı:** Sprint 27 W1 P0 — system prompt fencing + her tenant için ayrı OpenAI quota.
3. **Pentest F-003 (RAG key in web bundle)** — `--dart-define=RAG_API_KEY=plaintext` web build içine girer. **Azaltıcı:** Cloud Functions üzerinden RAG proxy (Sprint 27 W1).
4. **F-009 (PWA service worker PHI cache)** — kiosk paylaşımında risk. **Azaltıcı:** Service worker `clients.claim()` + auth-aware cache kuralları (Sprint 27 W2).
5. **App Store review SLA** — iOS Hand-off, ActivityKit + AppIntents privacy declarations gerektirir. **Azaltıcı:** Reviewer notes hazır, ama ilk submission feedback round'unu W1'de bekliyoruz.

---

## Metrikler

| Metrik | Önce | Sonra | Hedef |
|---|---|---|---|
| Skill panel scorecard | 8.7 | 9.0 | 9.1 |
| `flutter analyze` errors | 0 | 0 | 0 ✅ |
| `flutter analyze` infos | ~315 | ~330 | <100 (Sprint 28) |
| Test suite count | ~750 | ~759 | — |
| Test exit code | 0 | 0 | 0 ✅ |
| Audit log integrity coverage | %72 | %88 | %100 (Sprint 27 F-008) |
| App Store readiness | %60 | %95 | %100 (submission round 1 sonrası) |
| OWASP ASVS L2 self-audit | %58 | %78 | %95 pre-vendor |

---

## Skill panel — kapanış değerlendirmesi

| Skill | Skor | Not |
|---|---|---|
| `senior-security` | 9.3 | WebAuthn rigid validation + pentest pre-engagement ledger güçlü sinyaller |
| `senior-frontend` | 9.0 | DESIGN.md uyumlu RagConsoleScreen + AppShell disiplini sürüyor |
| `senior-backend` | 8.8 | Passkey functions clean, ama copilotRelay LLM01 jailbreak'i pas geçti |
| `ai-security` | 8.5 | Prompt fencing eksik; Sprint 27 W1'de kapanacak |
| `senior-devops` | 8.7 | App Store paketi + deploy wrapper tam; psyrag deploy pending |
| `senior-pm` | 9.1 | Backlog yönetimi temiz; 30 commit tek PR'a paketlendi |
| `code-reviewer` | 9.2 | Audit close PR'ları (s25-s26) 6 paneli pas geçti, P0/P1 sıfır leak |
| **Ortalama** | **9.0** | Hedef 9.1, eksik 0.1 = pentest vendor sertifikasyonu (Q3) |
