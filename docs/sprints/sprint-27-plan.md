# Sprint 27 — Pentest Remediation + RAG Hub Live (2 hafta)

**Tarih:** 2026-06-17 → 2026-07-01
**Önceki:** Sprint 26 — WebAuthn + PWA shell + iOS Hand-off + App Store paket + Pentest pre-engagement (bkz. `sprint-26-closeout.md`)
**Hedef:** Pre-vendor pentest hijyeni + Clinical RAG hub canlı + EHR write Bridge MVP + Lighthouse 90
**Skill panel hedef:** 9.0 → **9.2** (pre-vendor self-cert pass)

---

## Öncelik özeti

| Sıra | İş | DRI | Süre | Bağımlı bulgu |
|---|---|---|---|---|
| P0 | LLM proxy prompt fencing + per-tenant quota | ai-wg + senior-security | 3g | F-001 (High) |
| P0 | RAG key Cloud Functions proxy (key web bundle'dan çıkar) | ai-wg + senior-backend | 2g | F-003 (High) |
| P0 | psyrag hub Hetzner deploy + RAG_BASE_URL/RAG_API_KEY canlı | senior-devops | 2g | Risk #1 |
| P1 | PWA service worker auth-aware cache + clients.claim() | patient-portal-wg | 2g | F-009 (High) |
| P1 | EHR FHIR R4 write Bridge MVP (Observation + DocumentReference POST) | senior-backend | 4g | Sprint 26 carryover |
| P1 | 837P denial reason → CARC mapping completion | billing-wg | 3g | Sprint 26 carryover |
| P2 | Audit hash-chain accessReviewCron entegrasyonu | sec-team | 1g | F-008 (Medium) |
| P2 | Patient invite tek-kullanım + 24h TTL | patient-portal-wg | 1g | F-012 (Low) |
| P2 | Lighthouse 90+ — bundle split + image lazy + LCP <1.2s | senior-frontend | 3g | Sprint 26 carryover |

---

## W1 (2026-06-17 → 2026-06-24) — Pentest Highs + RAG Live

### 1. LLM proxy prompt fencing + per-tenant quota ⚡ (F-001 close)
**Süre:** 3g · **DRI:** ai-wg + senior-security
- `functions/src/llm_proxy.ts` — system prompt fence: `<<SYSTEM_FROZEN>>` sentinel + post-response strip
- "Ignore previous instructions" + 30 jailbreak pattern reject list (reject before model)
- Per-tenant rate budget — Firestore `tenant_quota/{tid}` doc, 1k req/h hard cap, 429 + retry-after
- Anthropic key Vault'tan al, sadece function memory'de
- 8 jailbreak unit test (red team kit) + 2 budget exhaustion test
- **Çıktı:** F-001 status `fixed_pending_retest`, evidence `docs/security/evidence/2026q3/F-001/`

### 2. RAG key Cloud Functions proxy ⚡ (F-003 close)
**Süre:** 2g · **DRI:** ai-wg + senior-backend
- `functions/src/rag_proxy.ts` — `/v1/rag/{analyze,query,feedback,health}` reverse proxy
- `RAG_HUB_URL` + `RAG_HUB_KEY` secrets Vault'tan, **client'a hiç sızmaz**
- `RagClient` Flutter tarafı `baseUrl: BuildConfig.backendUrl + '/v1/rag'`, header `Authorization: Bearer <Firebase ID token>` (tenant claim ile)
- proxy tenant doğrulaması + audit log entry per request
- `BuildConfig.ragApiKey` field deprecate ve `// removed` placeholder + sonraki sprint sil
- **Çıktı:** F-003 status `fixed_pending_retest`

### 3. psyrag hub Hetzner deploy ⚡
**Süre:** 2g · **DRI:** senior-devops
- CX22 ephemeral → CX22 prod (1 vCPU / 2GB / 40GB SSD) — yeterli MVP için
- `rag.psyclinic.ai` A record Hostinger DNS → static IP
- Caddy reverse proxy + auto-TLS
- Groq API key (ücretsiz tier) → `GROQ_API_KEY` env
- `psyrag/docker-compose.yml` up; healthcheck `https://rag.psyclinic.ai/api/rag/health` 200
- **Çıktı:** RAG console artık canlı; smoke test E2E

### 4. PWA service worker auth-aware cache (F-009 close)
**Süre:** 2g · **DRI:** patient-portal-wg
- `web/sw.js` — auth-required routes `/portal/inbox`, `/portal/appointments`, `/portal/messages` için `network-first` + `cache: 'no-store'`
- Logout → `caches.delete()` + `clients.claim()` ile tüm tab'lerde temizle
- Kiosk modu için "shared device" toggle (settings) + auto-logout 5dk
- 2 widget test + manuel kiosk senaryosu (2 farklı tarayıcıda peş peşe login)
- **Çıktı:** F-009 status `fixed_pending_retest`

---

## W2 (2026-06-24 → 2026-07-01) — EHR Write + Billing + Lighthouse

### 5. EHR FHIR R4 write Bridge MVP
**Süre:** 4g · **DRI:** senior-backend
- `functions/src/ehr_bridge.ts` — POST `/Observation` (PHQ-9/GAD-7 score) + POST `/DocumentReference` (session note PDF)
- Endpoint allowlist (Epic FHIR sandbox + Cerner sandbox + 1 EU EHR sandbox)
- SMART on FHIR backend client (mTLS + JWT bearer)
- Retry idempotent + Firestore `ehr_outbox/{id}` queue
- 5 integration test (sandbox karşı)
- Settings UI: clinician token enroll + per-patient consent gate

### 6. 837P denial reason → CARC mapping completion
**Süre:** 3g · **DRI:** billing-wg
- `lib/services/billing/carc_mapping.dart` — top 50 CARC kod tablosu + remediation hint
- Insurance claim board "Denial reason" sütunu hint chip
- 1-click split — partial pay + appeal draft kombosu
- `feat/denial-oneclick-split` branch'i merge

### 7. Lighthouse 90+ web
**Süre:** 3g · **DRI:** senior-frontend
- Web bundle split: `flutter build web --split-debug-info=symbols/ --tree-shake-icons`
- Hero LCP image preload + WebP/AVIF fallback
- Landing page kritik CSS inline + non-critical defer
- Font subset (Inter sadece kullanılan glyph)
- Programmatic SEO landing 50 sayfa için CLS <0.1 audit
- **Çıktı:** Mobile + desktop Lighthouse Performance ≥90, Accessibility ≥95, SEO 100

### 8. Audit hash-chain accessReviewCron entegrasyonu (F-008 close)
**Süre:** 1g · **DRI:** sec-team
- `functions/src/access_review_cron.ts` — başlangıçta `verifyAuditChain()` çağrısı, hash mismatch → cron abort + PagerDuty incident
- 1 unit test + 1 chaos test (chain corruption simulation)

### 9. Patient invite tek-kullanım + 24h TTL (F-012 close)
**Süre:** 1g · **DRI:** patient-portal-wg
- Firestore `invites/{id}` — `consumed_at`, `expires_at` (created + 24h)
- Consume on first portal open; ikinci tıklama → friendly 410 sayfası + "Request a new link"
- 2 unit test + 1 e2e

---

## Risk + bağımlılıklar

- **Hetzner CX22 hazır olma**: kullanıcı tarafında ödeme + provisioning bağlı. Pending status'ünde Sprint 27 P0 #3 W1'den W2'ye kayar.
- **EHR sandbox erişimi**: Epic + Cerner sandbox başvuru süresi 5-7g. Sprint 27 başlangıcında başvuru gönderilmeli.
- **App Store review feedback**: Sprint 26'da gönderilen submission Sprint 27 W1'de yanıtlanabilir; reviewer notes ek soruları olursa W1'den 0.5g cebimizden çıkar.
- **Mollie EU + Stripe US çatallanması**: Sprint 28'e ertelendi (ödeme sponsoru kararı).

---

## Tanım: Done

Sprint 27 "Done" sayılır eğer:
- [ ] Pentest F-001, F-003, F-008, F-009, F-012 → `fixed_pending_retest` veya `closed`
- [ ] psyrag hub `https://rag.psyclinic.ai/api/rag/health` 200 + smoke E2E geçer
- [ ] `BuildConfig.ragApiKey` deprecate, RAG isteği Cloud Functions üzerinden gider (web bundle'da plaintext key **yok**)
- [ ] FHIR Bridge MVP sandbox karşı 5/5 entegrasyon test geçer
- [ ] CARC mapping 50/50 satır kapanır, denial board chip canlı
- [ ] Lighthouse Performance ≥90 (mobile + desktop)
- [ ] `flutter analyze` 0 error, 0 warning; `flutter test` EXIT=0
- [ ] OWASP ASVS L2 self-audit ≥%92 (pentest vendor önü açık)

---

## Skill panel hedefi

| Skill | 26 sonu | 27 hedef | Bağımlı iş |
|---|---|---|---|
| `senior-security` | 9.3 | 9.4 | F-001/F-003/F-008/F-009/F-012 close |
| `ai-security` | 8.5 | 9.0 | Prompt fencing + jailbreak red-team kit |
| `senior-backend` | 8.8 | 9.1 | RAG proxy + FHIR Bridge MVP |
| `senior-frontend` | 9.0 | 9.2 | Lighthouse 90 + PWA cache discipline |
| `senior-devops` | 8.7 | 9.0 | psyrag deploy + Caddy auto-TLS |
| `code-reviewer` | 9.2 | 9.3 | F-001 + RAG proxy diff disciplines |
| **Ortalama** | **9.0** | **9.2** | Pre-vendor self-cert pass |
