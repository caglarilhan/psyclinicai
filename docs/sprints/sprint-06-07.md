# PsyClinicAI — Sprint 6 + 7 Plan

**Yazıldığı tarih:** 2026-06-01
**Önceki durum:** Sprint 1–5 tamamlandı, 340/340 test geçti, 0 error.
**Hazırlayan lens:** `senior-security`, `ai-security`, `healthcare-cdss-patterns`,
`hipaa-compliance`, `gdpr-dsgvo-expert`, `a11y-audit` skill perspektifleri.

---

## 1. Bağlam — niye yeni plan?

Sprint 1–5 boyunca **clinical safety çekirdek + compliance utility + UI
çekirdek** tamamlandı (340 test, 0 error). Ancak çoklu skill perspektif
ile yapılan eksik kontrolde **24 bulgu** çıktı (3 kritik, 10 yüksek, 9
orta, 2 düşük). Bu plan kritik+yüksek bulguları Sprint 6 ve 7'ye
dağıtır.

**Üst tema:** yapı kuruldu, **gate'ler eksik** — modeller PHI'yi
doğru asserterle koruyor ama runtime'da gerçek karar noktaları
gate'lenmiyor (AI consent enforcement, C-SSRS patient binding, audit
retention job).

---

## 2. Kritik bulgular (P0, Sprint 6 ilk hafta)

### B1 — AI consent enforcement gerçek değil
**Konum:** `lib/screens/patients/intake_form_screen.dart` (consent
captured), `lib/services/copilot/*` (kullanım), runtime gate eksik.
**Risk:** **kritik** — GDPR Art. 7 / Art. 9(2)(a) ihlali. Hasta
"AI assistance" rıza vermese de copilot rotaları çağrılabiliyor.
**Aksiyon:**
1. `ConsentGuard` servisi: `bool aiAllowed(patientId) → ConsentRecord
   yükle + aiAssistanceConsent kontrol`.
2. `SafetyPlanAiService`, `TreatmentPlanAiService`, AI Diagnosis
   çağrılarının her giriş noktası gate'e bağlanır; false ise
   `ConsentDeniedException` fırlatır.
3. UI'da "AI consent yok" banner — clinician toggle açabilmesi için
   patient consent screen'e link.
4. Test: gate negative path; analytics event `ai.consent_blocked`.

### B2 — C-SSRS escalation patient context doğrulanmıyor
**Konum:** `lib/screens/assessments/clinical_scale_screen.dart` →
`/safety_plan` push.
**Risk:** **kritik** — Klinisyen seans hastasıyla ölçeği başlatıyor
ama screen kendi `patientId`'ye fallback `demo-1` kullanıyor; yanlış
hasta dosyası açılabilir.
**Aksiyon:**
1. `ClinicalScaleScreen.patientId` zorunlu yap (nullable kaldır).
2. Dashboard'dan / patient detail'den başlatım: her zaman explicit
   `PatientDetailArgs`.
3. Demo route argümansız çağrılırsa kullanıcıya "Pick patient first"
   blocker; demo-1 fallback yalnız test fixture'ında.
4. Widget test: patientId null ile çağrı → assertion / blocker.

### B3 — C-SSRS imminent modal "I'll handle this manually" çok kolay
**Konum:** `lib/widgets/crisis_escalation_card.dart`
(`showCrisisEscalationModal`).
**Risk:** **kritik** — `imminent` (item 6 = behavior) tier'da
modal "manually" tıklayıp geçilebilir. Klinisyenin nedeni
kayıt altına alınmıyor.
**Aksiyon:**
1. `imminent` tier'da dismissal için **reason picker zorunlu** (3+
   gerekçe seç).
2. Dismissal sonrası **soft-lock**: dashboard'a 24 saat boyunca
   "high-risk handoff outstanding" banner; supervisor notify.
3. Telemetry: `cssrs_escalation_dismissed_imminent` ayrı event +
   reason kodu.
4. Test: imminent tier dismiss → reason zorunlu, soft-lock state.

---

## 3. Yüksek bulgular (P1, Sprint 6)

### B4 — Telemetry PHI sızdırıyor
`password_reset_screen.dart` `TelemetryEvents.passwordResetSent` çağrısı
default property'ler içinde mail içeriyor olabilir. `MfaSetupScreen`
`security.mfa_early_access_requested` properties.email plaintext.
**Aksiyon:** `_redactEmail()` yardımcısını telemetry'ye taşı; email
property'ler local part'ı maskele (`j***@example.com`). Tüm yeni
event'leri tarayıcı script ile audit.

### B5 — Audit log export default redaction yapmıyor
`audit_log_screen.dart` export bottom-sheet `redactForSiem` çağırıyor
✓ ama bu davranış opt-out edilemiyor; aksine bazı dış tüketiciler
unredacted CSV isteyebilir → ayrım "Redact PHI" toggle.
**Aksiyon:** BottomSheet'e checkbox ekle (default ON). Toggle OFF
seçilirse `auth.audit_log_export_unredacted` event + ekran üzerinde
"PHI in file" uyarı.

### B6 — DSAR export sadece clipboard
`data_export_screen.dart` clipboard. Encrypted download yok; web'de
clipboard'a yazılan PHI history'de kalır.
**Aksiyon:**
- Native: file_picker ile `.zip` (AES-256 password). Şifre kullanıcıya
  ayrı kanal (email / SMS).
- Web: `share_plus` veya `<a download>` + clipboard kopyalama warning.
- Audit log entry her export.

### B7 — Prompt injection fencing yetersiz
`safety_plan_ai_service.dart`, AI Diagnosis prompt: sistem prompt'unda
"data-only block" fence yok; transkript injection yapabilir.
**Aksiyon:**
- `lib/utils/prompt_safety.dart`'da mevcut `fence()` zaten var (test
  edildi). Tüm AI call sites'lar bunu kullanmalı (grep ile audit, eksik
  yerleri patch).

### B8 — AI diagnosis audit consent context yok
`ai_diagnosis_audit.dart` model `aiConsentVersion` taşımıyor.
**Aksiyon:** Modele `consentPolicyVersion: String` ekle (intake'ten
gelen); audit log girişi consent verisi olmadan kabul edilmesin.

### B9 — Safety plan 7-step validation yok
`safety_plan_repository.dart` save herhangi bir alan boş olsa bile
geçer. Klinik kalite kontrol: warning signs + coping + at least 1
crisis line minimum.
**Aksiyon:** `SafetyPlan.isClinicallyComplete` getter (warning signs ≥1
AND coping ≥1 AND (support ≥1 OR professionals ≥1) AND crisis line
≥1). UI save action'ı bu getter false ise uyarı verir.

### B10 — Audit log retention auto-purge cron yok
`audit_log_exporter.dart` `findExpiredEntries` utility var ama nightly
job yok — HIPAA 6yr sonrası purge çalışmıyor.
**Aksiyon:**
- Cloud Function (Firebase Scheduled): günlük çalış, expired entries
  pseudonymize (delete değil, audit chain bozulmasın).
- Run'ı kendisi audit log'a yazar (`retention.purge_run`).
- Alert: 30 günden uzun başarısız job.

### B11 — Web build secure storage yetersiz
`intake_repository.dart` `FlutterSecureStorage` iOS keychain / Android
encrypted prefs. Web'de localStorage backend — şifresiz.
**Aksiyon:**
- Web'de `FlutterSecureStorage` web plugin → `webOptions:
  WebOptions(dbName, publicKey)` aslında WebCrypto kullanır ama
  documentation güvenli kullanım için **server-side BLOB** öneriyor.
- Geçici: web'de intake / consent / safety plan PHI saklamayalım;
  sadece Firestore'a anında yaz, local cache yok.

### B12 — Consent withdrawal audit trail eksik
GDPR Art. 7(3): consent geri çekildiğinde *withdrawal* zaman damgalı
log gerekir; mevcut intake screen consent'i `false`'a çevirirse
sessizce güncellenir.
**Aksiyon:**
- `ConsentRecord.withdrawnAt: DateTime?` field ekle.
- Repository: yeni consent kaydederken eskisini "withdrawn" olarak
  arşivle; audit log entry.
- Schema version bump.

### B13 — Anthropic BYOK workspace gate gerçek değil
`subprocessor_registry.dart` BYOK opt-in iddiası var ama runtime'da
workspace-level toggle yok; clinician kişisel key girdiyse "BYOK
mode" iddiası geçersiz.
**Aksiyon:**
- `Workspace.aiProviderMode: 'byok' | 'platform' | 'disabled'` flag
  Firestore'da.
- `byok` mode'da platform fallback key'i kullanılmaz (env'de
  `PSY_PLATFORM_AI_KEY` set olsa bile).
- Tenant admin UI'da explicit seçim.

---

## 4. Orta öncelik (P2, Sprint 7)

### B14 — WCAG 2.2 focus state coverage
Yeni eklenen ekranlardaki tüm interactive widget'ların `focus ring`
test edilmedi. Custom InkWell'lerin focus indication'ı belirsiz.
**Aksiyon:** `wcag_contrast.dart` utility ile design system audit;
focus ring 2px teal-500, AA-large kontrast şartlı.

### B15 — Color contrast doğrulama
PsyColors.n400 (muted grey) caption olarak kullanılıyor; bazı
ekranlarda body text olarak kullanım var (intake hint metinleri).
**Aksiyon:** `passesWcagAa` ile renk-çiftleri taraması; n400 body'de
kullanılıyorsa n600'a (slate-700) çevir.

### B16 — Empty-state çeşitliliği
DSAR boş bundle "no records yet" generic; intake olmayan demo
hastalar için onboarding hint daha iyi.

### B17 — Locale fallback kapsamı
`supportedLocales` resmi ama gerçek `.arb` dosyaları yok.
**Aksiyon:** `flutter_localizations` + 7 dil için `intl_*.arb`
oluştur; öncelikli ölçek başlıkları + crisis hotline labels.

### B18 — Account deletion in-memory state persist edilmiyor
`AccountDeletionState` singleton; uygulama restart'ında reset.
**Aksiyon:** Firestore document + scheduled purge job + ekrana
"requested at" persist.

### B19 — Insurance pre-auth UI eksik
Model + test var ama hiçbir ekran yok; superbill'de pre-auth status
chip yok.
**Aksiyon:**
- `lib/screens/billing/preauth_screen.dart` listing + form
- Superbill ekranında "Pre-auth: REF-001 ✓ approved" chip

### B20 — Reports/outcomes dashboard render eksik
`buildCaseloadMetrics` utility var ama outcomes_screen'e bağlı değil.
**Aksiyon:** outcomes_screen `caseload_outcomes.dart`'tan veri çek;
"delta" + "reliable improvement" + "no-show rate" 3 metrik kartı.

### B21 — Group therapy + Supervisor review tasarımı yok
Plan'ın P2 maddesi; bu sprint için sadece tasarım dokümanı.

### B22 — Patient portal (hasta-tarafı) yok
PROM completion + appointment self-view + DSAR self-service.
Sprint 8'e ertelendi.

---

## 5. Düşük (P3, backlog)

### B23 — Test coverage raporlaması yok
`lcov` veya `coverage` package ile CI'de coverage threshold.

### B24 — Sub-processor change-notification email akışı simulation
Sub-processor registry değişimi otomatik email yollamıyor (manual).

---

## 6. Sprint 6 plan (2 hafta) — Critical + High

### Hafta 1 — Critical gate'ler
- B1: ConsentGuard servisi + AI call site gate'leri (3 file)
- B2: ClinicalScaleScreen patientId zorunlu + caller'lar
- B3: imminent modal reason picker + soft-lock banner

### Hafta 2 — High priority
- B4: Telemetry PHI redaction
- B5: Audit export "Redact PHI" toggle
- B6: DSAR encrypted download (native) + clipboard warning (web)
- B7: Prompt injection fencing tüm AI call site
- B8: ai_diagnosis_audit consent version field
- B9: SafetyPlan.isClinicallyComplete

**Test eklenmesi:** her bulgu için ≥3 test. Hedef: +35 test (375 total).

---

## 7. Sprint 7 plan (2 hafta) — Compliance derinleştirme + UI olgunluk

### Hafta 1 — Compliance gate'ler
- B10: Audit log retention cron (Firebase Scheduled Function)
- B11: Web PHI storage kararı + Firestore-only
- B12: Consent withdrawal audit trail
- B13: Workspace AI mode flag

### Hafta 2 — UI olgunluk
- B14: Focus state design system audit
- B15: Color contrast tarama
- B17: i18n .arb dosyaları (en/tr/de/fr/nl/it/es)
- B18: AccountDeletionRepository persistent
- B19: Insurance pre-auth UI
- B20: Outcomes dashboard veri bağlama

**Test eklenmesi:** ≥30 test (~410 total).

---

## 8. Doğrulama matrisi

| # | Bulgu | Test stratejisi | Eski-yeni karşılaştırma |
|---|---|---|---|
| B1 | Consent gate | aiAllowed → false döndüğünde SafetyPlanAiService throws | Önce sessiz çağrı / şimdi ConsentDeniedException |
| B2 | Patient ID | ClinicalScaleScreen(patientId: null) → assertion | Önce demo-1 fallback / şimdi blocker |
| B3 | Imminent dismiss | Reason picker + soft-lock state | Önce tek tıkla kapat / şimdi 3 reason zorunlu |
| B4 | Telemetry redaction | property.email → `j***@example.com` | Plaintext → maskeli |
| B5 | Export redact | UI checkbox + event split | Otomatik redact / opt-out |
| B6 | DSAR encrypted | Native: .zip + AES; Web: warning | Clipboard → şifreli dosya |
| B7 | Fence | grep audit; her AI call site fence() | Bazı yerlerde ham prompt / her yerde fence |
| B8 | Audit consent version | Model assert | Eksik / zorunlu |
| B9 | Safety plan complete | Getter unit test + UI snackbar | Boş kaydedilebilir / uyarı |
| B10 | Retention cron | Cloud Function integration test | Manuel / nightly |
| B11 | Web PHI | Storage adapter web stub | localStorage / Firestore-only |
| B12 | Withdrawal log | ConsentRecord round-trip + audit entry | Sessizce / log entry |
| B13 | BYOK | Workspace flag test | Server fallback / strict gate |

---

## 9. Skill review notları (özet)

**senior-security:**
- Telemetry sızıntıları (B4)
- Audit retention job (B10)
- BYOK enforcement (B13)

**ai-security:**
- Consent gate (B1)
- Prompt injection fencing (B7)
- AI audit consent context (B8)

**healthcare-cdss-patterns:**
- C-SSRS patient binding (B2)
- Imminent escalation hard-lock (B3)
- Safety plan completeness (B9)

**hipaa-compliance:**
- Audit retention 6yr cron (B10)
- DSAR encrypted hand-off (B6)
- Consent withdrawal log (B12)

**gdpr-dsgvo-expert:**
- Art. 7 — AI consent enforcement (B1)
- Art. 7(3) — withdrawal log (B12)
- Art. 17 — purge job (B10)

**a11y-audit:**
- Focus states yeni ekranlar (B14)
- Color contrast n400 body text (B15)
- i18n .arb (B17)

---

## 10. Tahmini etki (sonra)

| Metric | Şu an | Sprint 6 sonu | Sprint 7 sonu |
|---|---|---|---|
| Test | 340 | ~375 | ~410 |
| Error | 0 | 0 | 0 |
| Critical bulgu | 3 | 0 | 0 |
| High bulgu | 10 | 0-2 | 0 |
| Compliance posture | B+ | A- | A |

**Critical başarı kriteri:** Sprint 6 sonunda C-SSRS imminent senaryosu
"reason picker zorunlu + soft-lock" akışı klinisyen ile birlikte
doğrulanmış olmalı (klinisyen review session).
