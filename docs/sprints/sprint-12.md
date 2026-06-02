# PsyClinicAI — Sprint 12 Plan (e-Rx: EU eHDSI + TR MEDULA)

**Yazıldığı tarih:** 2026-06-02
**Önceki durum:** Sprint 11 kapatıldı; telehealth + Stripe deposit
iskeleti yeşil.

---

## 1. Bağlam

Mevcut `/e_prescription` ekranı US-centric (SureScripts/EPCS pattern)
ama EU eHDSI ve TR MEDULA için adapter yok. Sprint 12 üç yapı kuruyor:

1. `Prescription` + `PrescriptionItem` modeli — market-agnostic.
2. `ErxAdapter` arayüzü + `EhdsiAdapter` (EU NCPeH stub) +
   `MedulaAdapter` (TR Sağlık Bakanlığı SOAP stub).
3. `DdiChecker` — drug-drug interaction iskelet.

---

## 2. Multi-skill perspektif

### healthcare-cdss-patterns
- Her transmission'dan önce DDI + allergy check ZORUNLU. UI override
  edebilir ama "override reason" log'lanır.
- Signed prescription immutable. Düzeltme = yeni prescription +
  reference to cancelled one.

### gdpr-dsgvo-expert
- NCPeH cross-border patient ID matching — pseudonymisation katmanı
  gerek; gerçek implementation Sprint 14.
- MEDULA TR Sağlık Bakanlığı (KVKK Md. 5/2/c yasal yükümlülük).

### senior-security
- Signature hash SHA-256 over canonical JSON; clinician TOTP
  confirmation gerektirir (eIDAS QES Sprint 14).

---

## 3. Sprint 12 plan (3 hafta)

### Hafta 1 — Prescription + PrescriptionItem model
- `lib/models/prescription.dart` — Prescription + items + market enum
  + status enum.
- Test.

### Hafta 2 — Adapter arayüzü + iki stub
- `lib/services/erx/erx_adapter.dart` — abstract.
- `lib/services/erx/ehdsi_adapter.dart` — EU stub.
- `lib/services/erx/medula_adapter.dart` — TR stub.
- Test.

### Hafta 3 — DDI checker iskelet
- `lib/services/erx/ddi_checker.dart` — küçük lexicon (SSRI + MAOI =
  serotonin syndrome; benzo + opioid = respiratory depression; vb.)
- Test.

---

## 4. Test hedefi

| Metric | Sprint 11 sonu | Sprint 12 sonu |
|---|---|---|
| Dart test | ~472 | ~492 |
| Cloud Function test (Jest) | 34 | 34 |
| Error | 0 | 0 |
