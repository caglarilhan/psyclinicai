# PsyClinicAI — Sprint 11 Plan (Telehealth + Stripe deposit)

**Yazıldığı tarih:** 2026-06-02
**Önceki durum:** Sprint 10 kapatıldı; 461 Dart + 20 Jest yeşil,
compliance posture **A**.

---

## 1. Bağlam — neden bu sprint

Sprint 10 sonrası iki kritik ürün açığı:

1. **Telehealth** — bugün `/settings/telehealth` ekranı sadece
   Daily.co kayıt ekranı. Klinisyen oda açıp katılamıyor; HIPAA / GDPR
   uyumlu görüntülü görüşme akışı henüz yok.
2. **Stripe deposit + no-show charge** — randevu deposit + no-show
   tahsilat modeli yok.

Sprint 11 her iki domain için **iskelet** kuruyor — model, repository,
Cloud Function relay. Gerçek Daily.co + Stripe canlı bağlantısı
Sprint 12+ kullanıcı kabul testi sonrası.

---

## 2. Multi-skill perspektif

### senior-security
- Telehealth oda token'ı asla client'a expose edilmez — Cloud Function
  expiring meeting token üretir.
- Stripe deposit PaymentIntent her zaman server-side oluşturulur.

### healthcare-cdss-patterns
- Recording consent her seansta yeniden alınır (HIPAA §164.508 + GDPR
  Art. 9). Model'de `recordingConsent: enum(notAsked, granted,
  declined)` + `consentAt:Timestamp`.
- No-show charge en az 24 saat öncesinden iptal politikası ile bağlı.

### gdpr-dsgvo-expert
- Daily.co EU subprocessor — RoPA'ya yeni activity Sprint 12'de
  eklenecek.

---

## 3. Sprint 11 plan (3 hafta)

### Hafta 1 — Telehealth iskelet
- `lib/models/telehealth_session.dart` — TelehealthSession +
  RecordingConsent enum.
- `lib/services/telehealth/telehealth_service.dart` — abstract.
- `functions/src/telehealth_room.ts` — POST /telehealth/room create
  Daily.co room + meeting token, auth-gated.
- `firestore.rules` — `telehealth_sessions/{id}` clinic-scoped.

### Hafta 2 — Stripe deposit + no-show
- `lib/models/deposit_charge.dart` — DepositCharge + DepositStatus
  enum.
- `functions/src/deposit_handler.ts` — POST /deposit/intent + capture.
- `firestore.rules` — `deposit_charges/{id}` clinic-scoped.

### Hafta 3 — Integration + screen wiring (Sprint 12 backlog)

---

## 4. Test hedefi

| Metric | Sprint 10 sonu | Sprint 11 sonu |
|---|---|---|
| Dart test | 461 | ~478 |
| Cloud Function test (Jest) | 20 | ~28 |
| Error | 0 | 0 |
