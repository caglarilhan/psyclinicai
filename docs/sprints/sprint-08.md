# PsyClinicAI — Sprint 8 Plan

**Yazıldığı tarih:** 2026-06-02
**Önceki durum:** Sprint 6 + 7 (core + UI çekirdek) tamamlandı.
392/392 test geçiyor, 0 error. Compliance posture **A−**.
**Hazırlayan lens:** Sprint 6/7 multi-skill review'in geriye bıraktığı 5
bulgu (B6, B10, B11, B17, B18) + Sprint 7'den taşınan B20.

---

## 1. Bağlam

Sprint 6 + 7 boyunca **kritik (B1-B3) + yüksek (B4, B5, B7-B9, B12, B13)
+ orta (B14, B19)** bulguların hepsi kapatıldı. Şu an açık kalanlar:

- **B6** — DSAR encrypted download (büyük: archive paketi)
- **B10** — Audit log retention cron (backend: Cloud Function)
- **B11** — Web PHI storage decision (Firestore-only adapter)
- **B17** — i18n .arb dosyaları (7 dil × 100+ string)
- **B18** — Account deletion repository persistent (Firestore)
- **B20** — Outcomes dashboard binding (mevcut 569-satır ekran refactor)

Bunların hepsi yapılabilir ama her biri tek başına 0.5–2 günlük iş.
Sprint 8 (2 hafta) bu altı maddeyi kapsar.

---

## 2. Sprint 8 plan (2 hafta) — son compliance + UI olgunluk

### Hafta 1 — Compliance derinleştirme

#### B6 — DSAR encrypted download
**Risk:** **yüksek** — DSAR clipboard'a PHI yazıyor; web'de browser history,
native'de paste-buffer süre boyunca PHI bırakır.

**Aksiyon:**
1. `pubspec.yaml`: `archive: ^3.6.0` + `crypto: ^3.0.3` (zaten var).
2. `lib/utils/dsar_export_zip.dart`:
   - `Uint8List buildEncryptedZip(Map<String, dynamic> bundle, String password)`
   - AES-256-CBC (archive paketinde) + 12-char password
   - Filename: `psyclinicai-export-{patientId}-{YYYYMMDD}.zip`
3. `data_export_screen.dart`:
   - "Copy JSON" → "Download encrypted ZIP" (native) / "Copy +
     password" (web with warning banner)
   - Password ekranda gösterilir + clipboard'a kopyalanır; bir kerelik
     dialog.
4. `path_provider` + `share_plus` (zaten var) ile native paylaşım.
5. Telemetry: `compliance.dsar_export_zip` (PHI-free, sadece byte size).

**Test:**
- `dsar_export_zip_test.dart` — encrypt+decrypt round-trip
- Password karmaşıklık kontrolü (≥12 char, alfanümerik + sembol)
- Empty bundle → empty zip (graceful)

**Tahmini test eklenmesi:** +6

---

#### B10 — Audit log retention cron (backend)
**Risk:** **yüksek (mevcut iddiamızı yerine getiremiyoruz)** — HIPAA
§164.316 6 yıl + GDPR retention principle. Şu an manuel.

**Aksiyon:** PsyClinicAI'nin client-only kapsamı bu repoda — Cloud
Function başka repo. Bu sprint'te:
1. `functions/audit_retention_purge.ts` (Firebase Cloud Function):
   - Scheduled `every 24 hours`
   - `findExpiredEntries` mantığını burada uygula (TS port)
   - Eski satırları pseudonymize → audit chain bozulmasın
2. Test çalıştırması: `firebase emulators:start` + cron tetik
3. `docs/RETENTION_RUNBOOK.md` — operatör için

**Test eklenmesi:** Cloud Function TS testleri (Jest); bu repoya
girmez ama runbook ile entegre.

---

#### B11 — Web PHI storage adapter
**Risk:** **yüksek** — Web'de `FlutterSecureStorage` localStorage
backend kullanır; şifresiz, fingerprintable.

**Aksiyon:**
1. `IntakeRepository` + `SafetyPlanRepository` — `kIsWeb` kontrolü.
2. Web branch: SecureStorage'ı bypass et, sadece Firestore-only mode
   (in-session cache; persist Firestore'a yaz).
3. Banner: web build'de `data_export_screen` + `intake_form_screen`
   "Web build does not cache PHI locally" notify.
4. Test: `WebPhiPolicy` enum + `isLocalCacheAllowed(bool isWeb)` pure
   utility.

**Test eklenmesi:** +5

---

#### B18 — Account deletion repository persistent
**Risk:** **orta** — in-memory state restart'ta kayboluyor; başka
clinician göremiyor.

**Aksiyon:**
1. `AccountDeletionRepository`:
   - Firestore: `account_deletions/{userId}`
   - Read: `current(userId) → AccountDeletionRequest?`
   - Write: `request()`, `cancel()`, `complete()` (admin)
2. `AccountDeletionState` ValueNotifier yerine repository
   observer wrapper.
3. Scheduled purge: Sprint 8 B10 cron'una `account_deletions` koleksiyon
   da dahil edilir.
4. Audit log entry her transition.

**Test eklenmesi:** +8 (in-memory implementation tests; Firestore
integration test runner)

---

### Hafta 2 — UI olgunluk + i18n

#### B17 — i18n .arb dosyaları (7 dil)
**Risk:** **orta** — supportedLocales var ama .arb yok; gerçek
çevrime yok.

**Aksiyon:**
1. `flutter_localizations` + `intl` zaten ekli; `l10n.yaml`
   yapılandırması ekle.
2. `lib/l10n/intl_en.arb` — temel, 50 anahtar (ekran başlıkları,
   ölçek sorularının başlıkları, crisis hotline labels, "Save",
   "Cancel" gibi).
3. `intl_tr.arb`, `intl_de.arb`, `intl_fr.arb`, `intl_nl.arb`,
   `intl_it.arb`, `intl_es.arb` — TR önce (insider review), diğerleri
   profesyonel çevirmen + PHQ-9 / GAD-7 / C-SSRS validasyonlu mevcut
   çeviriler.
4. `MaterialApp` `localizationsDelegates` + `supportedLocales` bağla.
5. Tüm hard-coded "Crisis resources" / "Patient" / "Save" string'leri
   `S.of(context).savePlan` formuna çevir.

**Test eklenmesi:** +5 (i18n missing-key test; her dil için ana
anahtarların varlığı)

**Tahmini iş:** **2 gün** — çevirmen turn-around dahil edilirse
gerçekçi olmaz; minimum viable: EN + TR.

---

#### B20 — Outcomes dashboard binding
**Risk:** **orta** — `buildCaseloadMetrics` utility var ama
`outcomes_dashboard_screen.dart` (569 satır) kendi `_delta` mantığını
yürütüyor; iki kaynak doğruluğu kaybediyor.

**Aksiyon:**
1. `outcomes_dashboard_screen.dart` özel `_delta` kodunu kaldır.
2. `CaseloadOutcomesPanel` adlı yeni widget — `buildCaseloadMetrics`
   çağırır, 3 metrik kartı (delta + improvement + no-show rate)
   render eder.
3. Dashboard'da `_DeltaSummary` yerine panel.
4. Widget test: snapshot input → 3 kart doğru rakamla.

**Test eklenmesi:** +4

---

## 3. Tahmini etki

| Metric | Şu an | Sprint 8 sonu |
|---|---|---|
| Test | 392 | ~420 |
| Error | 0 | 0 |
| Critical/High bulgu | 0 | 0 |
| Medium bulgu | 6 | 0–1 |
| Compliance posture | A− | A |
| i18n kapsam | EN-only | EN + TR (min) |

---

## 4. Sıralama önerisi

Hafta 1: **B6 → B11 → B18 → B10 (paralel runbook)**
Hafta 2: **B17 (EN + TR) → B20**

Kritik başarı kriteri: Sprint 8 sonunda DSAR encrypted hand-off
gerçek bir hasta verisi için klinisyen review ile test edilmiş
olmalı — clipboard yolu artık opsiyonel/alt-tier olarak işaretlenmeli.

---

## 5. Sprint 9+ kapsamı (backlog)

Sprint 8 sonrası kalanlar (Sprint 1–8 tamamlandığında):
- Group therapy session
- Supervisor review queue (trainee notları + co-sign)
- Patient portal (PROM completion, appointment self-view)
- Telehealth video gerçek entegrasyon (Daily.co)
- Payment gerçek entegrasyon (Stripe + Mollie + SEPA)
- e-Rx EU eHDSI / TR MEDULA roadmap
- SOC 2 Type I attestation (3-ay observation window)
- ISO 27001 yıl-bir sertifika hazırlığı

Bunlar her biri kendi sprint'ini hak ediyor — Sprint 9 ve sonrasında
toplu plan dosyası yazılacak.
