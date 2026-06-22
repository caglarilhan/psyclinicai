# PsyClinicAI — Sprint 9 Plan (Backend İskelet)

**Yazıldığı tarih:** 2026-06-02
**Önceki durum:** Sprint 1–8 tamamlandı, 414/414 test geçiyor, 0 error.
Client-side compliance posture **A**. Backend posture henüz **B**.
**Hazırlayan lens:** `senior-security`, `senior-backend`,
`hipaa-compliance`, `gdpr-dsgvo-expert`, `healthcare-emr-patterns`,
`ciso-advisor`.

---

## 1. Bağlam — "asıl iskelet"

Sprint 1–8 boyunca client-side scope (Flutter app + utility'ler +
modeller) tamamen kapatıldı. Ancak iddialarımızın **gerçekten
çalışması için backend tarafı** gerekiyor:

- **Audit retention cron** (HIPAA §164.316 6 yıl) — utility var, cron
  yok. İddia yapıyoruz ama gerçekleşmiyor.
- **Account deletion purge** (GDPR Art. 17) — istek alıyoruz, 30 gün
  sonra silen scheduled job yok.
- **PHI Firestore-only** (B11) — utility var, repository hâlâ
  SecureStorage'a yazıyor; web branch'i implement edilmedi.
- **Consent withdrawal cascade** — `withdrawnAt` set olduğunda
  Firestore'da bağlı AI çağrılarını engelleyen sunucu-tarafı kontrol yok.
- **C-SSRS imminent soft-lock cross-device** — RAM-only; başka
  klinisyenin dashboard'unda görünmüyor.

**Sprint 9 tezi:** Backend altyapı **iskelet**tir; iyi kurulmazsa
client-side compliance bir illusion. Bu sprint backend'in temelini
atıyor.

---

## 2. Multi-skill perspektif — backend öncelikleri

### senior-security
1. **Cloud Function service account least-privilege** — şu an default
   permissions; her function'ın IAM rolü kendine özel olmalı.
2. **Firestore security rules audit** — `firestore.rules` mevcut ama
   audit log + consent record + intake için satır-bazlı RBAC kontrol
   gerek.
3. **Secret rotation** — Anthropic relay key, Stripe webhook secret;
   rotation log + 90-day reminder.

### senior-backend
1. **Cloud Functions monorepo structure** — `functions/src/` tek
   dosya 128 satır; modüler hale gelmeli (`auth/`, `audit/`,
   `billing/`, `ai/`).
2. **Idempotency keys** — Stripe webhook duplicate event guard yok.
3. **Structured logging** — `firebase-functions/logger` consistent
   `severity` + `trace_id`.

### hipaa-compliance
1. **§164.316(b)(2)(i) 6-year retention** — purge cron + pseudonymize
   (chain hash kalır, PHI içerik temizlenir).
2. **§164.312(c)(2) audit log integrity** — append-only Firestore
   rule + hash chain validation Cloud Function (daily).
3. **§164.404 breach notification template** — incident response
   ekranında yer alıyor; runbook'a bağlı email template Sprint 9.

### gdpr-dsgvo-expert
1. **Art. 17 erasure** — 30-day grace sonrası scheduled purge.
2. **Art. 7(3) withdrawal propagation** — consent çekildiğinde tüm
   AI audit log entry'leri "consent_revoked_after_use" işaretle.
3. **Art. 30 ROPA** — sub-processor + retention + processing
   activities Firestore document; trust center bunu okur.

### healthcare-emr-patterns
1. **Patient portal** — PROM completion, randevu görüntüleme, DSAR
   self-service. Mevcut yok; scaffold + Sprint 10 gerçek.
2. **Group session** — multi-patient roster model + session note her
   patient için ayrı kayıt (HIPAA gerek — başka hastalar görmemeli).
3. **Supervisor co-sign** — trainee session note'u, supervisor onayı
   bekleyen kuyruk.

### ciso-advisor
1. **SOC 2 Type I gözlem dönemi** — Cloud Functions audit log toplaması
   + access reviews + change management Q3 2026.
2. **ISO 27001 yıl-bir hazırlığı** — Annex A registry zaten var (Sprint
   3), şimdi sertifika owner + audit hazırlık dokümanları.
3. **Disaster recovery** — Firestore export günlük; recovery time
   testi 90-day cadence.

---

## 3. Sprint 9 plan (3 hafta — backend ağırlıklı)

### Hafta 1 — Audit + deletion cron (B10 + B18 backend)

**Yeni dosyalar:**
- `functions/src/audit_retention_purge.ts`
  - Scheduled `every 24 hours at 02:00 UTC`
  - 6-year cutoff; rows older are pseudonymized (actor, entity, ip
    null; hash kalır)
  - Purge action kendi `retention.purge_run` audit log entry'sini yazar
- `functions/src/account_deletion_purge.ts`
  - Scheduled `every 1 hour`
  - `account_deletions` collection scan: `grace_ends_at < now AND
    cancelled_at IS NULL AND completed_at IS NULL`
  - Mark `completed_at`, trigger fan-out: intake, safety_plan,
    session_notes, assessments collections — pseudonymize patient
    rows (HIPAA audit log entries stay)
  - Audit log: `deletion.purge_completed` entry
- `functions/src/index.ts` — yeni functions export

**Test:** Cloud Function emulator + Jest (separate test infra; bu Dart
test sayacına girmez).

---

### Hafta 1 — Firestore security rules sıkılaştırma

**Düzenleme:** `firestore.rules`
- `audit_logs`: write only via Cloud Function service account (admin
  SDK); user read kendi clinicId'siyle sınırlı.
- `consent_records`: write own patient; `withdrawnAt` set olunca
  immutable (rule guard).
- `account_deletions`: user kendi userId'ye yazar; admin tüm
  yazabilir.
- `audit_logs`: `request.time` rule ile `created_at` arasında ≤30sn
  drift; sahte zamandamga koruması.

---

### Hafta 2 — Group therapy + Supervisor review (Dart side)

**Yeni Dart dosyaları:**
- `lib/models/group_session.dart` — `GroupSession` + roster (≤8
  patient) + per-patient sub-note ref.
- `lib/models/supervision_review.dart` — `SupervisionReview` + status
  (pending / approved / changes_requested / co_signed).
- `lib/services/supervision_review_repository.dart` — in-memory.
- `lib/screens/supervision/supervision_queue_screen.dart` — trainee
  notları + supervisor onay akışı.
- Test'ler: model round-trip, status transitions.

---

### Hafta 2 — Patient portal scaffold

**Yeni Dart dosyaları:**
- `lib/screens/patient_portal/portal_landing_screen.dart` —
  transparency-first scaffold (intake link, PROM, DSAR self-service,
  appointment self-view). MFA + early-access gate'leri Sprint 10'da.
- Route: `/portal` (patient-side auth ile, clinician portal'dan ayrı).

---

### Hafta 3 — B20 outcomes refactor + ROPA registry

**Düzenleme:**
- `lib/screens/outcomes/outcomes_dashboard_screen.dart` — `_delta`
  private kod yerine `buildCaseloadMetrics` çağırır; yeni widget
  `CaseloadOutcomesPanel` 3 metrik kartı.

**Yeni:**
- `lib/services/compliance/ropa_registry.dart` — GDPR Art. 30
  processing activities; trust center bunu okur. Pure data + test.

---

## 4. Test hedefi

| Metric | Şu an | Sprint 9 sonu |
|---|---|---|
| Dart test | 414 | ~445 |
| Cloud Function test (Jest) | 0 | ~25 |
| Error | 0 | 0 |
| Backend posture | B | A− |
| ROPA tablo | yok | live |

---

## 5. Skill review takım çağrısı

Sprint 9 sonrası planlanan bağımsız skill review (third-party gözü):
- `senior-security` — Cloud Function least-privilege denetimi
- `hipaa-compliance` — retention + audit chain integrity
- `red-team` — Cloud Function injection / SSRF surface

---

## 6. Sprint 10+ kapsamı (sonraki)

- Telehealth gerçek Daily.co entegrasyonu
- Payment gerçek Stripe + Mollie (deposit, no-show, SEPA)
- e-Rx EU eHDSI + TR MEDULA
- Patient portal gerçek (PROM, DSAR self-service, secure messaging)
- SOC 2 Type I observation start
- Mobile (Flutter iOS + Android) app store hazırlığı

---

**Kritik başarı kriteri:** Sprint 9 sonunda, klinisyen review
session'ında "C-SSRS imminent soft-lock başka clinician'ın
dashboard'unda görünüyor mu?" sorusunun cevabı **EVET** olmalı.
