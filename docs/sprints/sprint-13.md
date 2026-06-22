# PsyClinicAI — Sprint 13 Plan (Patient portal DSAR + PROM wiring)

**Yazıldığı tarih:** 2026-06-02
**Önceki durum:** Sprint 12 kapatıldı; e-Rx EU + TR + DDI checker yeşil.

---

## 1. Bağlam

Sprint 9'da portal landing iskeleti kondu — DSAR + PROM kartları
`onTap: null` ile placeholder. Sprint 13 bu kartlara veri modeli +
repository + alt-ekran iskeleti bağlıyor. Gerçek Firestore adapter
Sprint 14'te.

---

## 2. Multi-skill perspektif

### gdpr-dsgvo-expert
- Art. 12(3) — 30 gün fulfilment window; `isOverdue` UI'da kırmızı
  banner gösterir.
- Erasure request `account_deletion_purge` Cloud Function'a delege
  edilir (Sprint 9 backend hazır).

### healthcare-cdss-patterns
- PROM completion clinical context kaybetmemek için
  `requestedByClinicianId` opsiyonel — patient self-initiated PROM'lar
  klinisyene push edilir ama "instrument out-of-context" uyarısı
  alır.

### senior-frontend
- Yeni alt-ekranlar ARB'a bağlı (Sprint 10 binding paterni).

---

## 3. Sprint 13 plan (3 hafta)

### Hafta 1 — Modeller + repository
- `lib/models/portal_dsar_request.dart`
- `lib/models/prom_submission.dart`
- `lib/services/portal/portal_dsar_repository.dart`
- Test.

### Hafta 2 — Portal alt-ekranlar (Sprint 14 backlog)

### Hafta 3 — Firestore adapter (Sprint 14 backlog)
