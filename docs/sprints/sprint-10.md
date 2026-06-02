# PsyClinicAI — Sprint 10 Plan (Compliance close-out + cross-device safety)

**Yazıldığı tarih:** 2026-06-02
**Önceki durum:** Sprint 9 + skill-review kapatıldı; 449 Dart + 16 Jest test
yeşil, 0 error, backend posture **A−**.
**Hazırlayan lens:** `senior-security`, `gdpr-dsgvo-expert`, `hipaa-compliance`,
`healthcare-cdss-patterns`, `senior-frontend`, `a11y-audit`.

---

## 1. Bağlam — açık kalan teknik borç

Sprint 9 close-out 7 P2 item'ını kapadı, ancak üç borç içeride kaldı:

1. **DPIA / TIA referans dosyaları yok.** RoPA registry üç döküman'a
   path yazıyor (`docs/compliance/DPIA_AI_ASSISTANCE.md`,
   `TIA_ANTHROPIC.md`, `TIA_STRIPE.md`) — denetimde "TIA nerede?"
   sorusuna referans gösterip dosya açılmazsa rapor güvenilirliğini
   kaybeder.
2. **C-SSRS imminent soft-lock cross-device yok.** Sprint 9 plan
   `EscalationSoftLock` RAM-only — başka klinisyenin dashboard'unda
   "imminent dismissal" görünmez. "Kritik başarı kriteri" olarak
   işaretlendi, hâlâ açık.
3. **ARB stringleri koda bağlı değil.** EN+TR çevirileri var, parity
   testi geçiyor, ama supervision queue + portal landing kod tarafı
   literal İngilizce kullanıyor → TR kullanıcı İngilizce görür.

---

## 2. Multi-skill perspektif — Sprint 10 öncelikleri

### gdpr-dsgvo-expert
- **DPIA AI assistance** (Art. 35): risk değerlendirmesi, mitigation,
  residual risk, DPO sign-off tarihi.
- **TIA Anthropic** (Schrems II): hedef ülke (US) hukuk envanteri,
  Section 702 / Executive Order 14086 değerlendirmesi, supplementary
  measures (BYOK key custody, redaction, audit).
- **TIA Stripe**: PCI DSS overlap + Stripe DPA Schedule 3 + EU SCC
  Module 2.

### hipaa-compliance
- **C-SSRS cross-device persistence** (§164.312(b) audit + §164.308
  workforce security): bir klinisyen "I'll handle this manually" dedi
  ise nöbetteki klinisyen 24 saat içinde aynı dashboard'da soft-lock
  görmeli. RAM-only restart ile silinir, audit trail kaybolur.

### senior-security
- **Patient auth scope** (`UserRole.patient`) eklenmeli — Sprint 9'da
  portal_landing_screen "clinician profile null ise patient view"
  varsayımı yapıyor. Gerçek auth ile bu varsayım çöker.

### senior-frontend / a11y-audit
- **ARB string binding** — `AppLocalizations.of(context).supervisionQueueTitle`
  kullanımı supervision_queue_screen + portal_landing_screen
  ekranlarında. EN baseline + TR fallback.

### healthcare-cdss-patterns
- **C-SSRS soft-lock follow-up çağrısı** sadece soft-lock state'i
  değil, follow-up rationale + supervisor handoff alanlarını da
  içermeli (kim devraldı?).

---

## 3. Sprint 10 plan (3 hafta)

### Hafta 1 — Compliance artefaktları (DPIA + TIA × 2)

**Yeni dosyalar:**
- `docs/compliance/DPIA_AI_ASSISTANCE.md` — Art. 35 değerlendirmesi.
  Risk grids, residual risk after mitigation, sign-off table.
- `docs/compliance/TIA_ANTHROPIC.md` — Schrems II envanteri,
  destination jurisdiction analysis, supplementary measures, periodic
  review schedule.
- `docs/compliance/TIA_STRIPE.md` — aynı yapı, Stripe-spesifik
  PCI DSS overlap notu.

**Test:** `test/compliance_docs_parity_test.dart` — RoPA'daki her
`dpiaReference` ve `tiaReference` dosyası fiziksel olarak var mı.

---

### Hafta 2 — C-SSRS cross-device soft-lock

**Yeni dosyalar / değişiklikler:**
- `lib/models/escalation_soft_lock_record.dart` — `EscalationSoftLockRecord`
  (patientId, clinicId, dismissedAt, dismissReasonCode,
  dismissingClinicianId, followUpDueAt, supervisorHandoffId?).
- `lib/services/assessments/escalation_soft_lock.dart` — repository
  pattern'ine refactor; in-memory + Firestore-backed adapter.
- `firestore.rules` — `escalation_soft_locks` koleksiyon kuralları
  (clinic-scoped read; sadece dismissing clinician kendi entry'sini
  write edebilir, server tarafı immutable).
- `functions/src/escalation_soft_lock_cleanup.ts` — günlük cron, 24h
  geçmiş soft-lock'ları "stale" mark eder.
- `lib/widgets/crisis_escalation_card.dart` — soft-lock varsa banner.

**Test:** model + repository + Cloud Function pure helpers.

---

### Hafta 3 — Patient auth scope + ARB binding

**Düzenleme:**
- `lib/models/auth_models.dart` — `UserRole.patient` eklendi (5 → 6).
- `lib/screens/patient_portal/portal_landing_screen.dart` — gate
  artık `profile.roles.contains(UserRole.patient)` kontrol eder.
- `lib/screens/supervision/supervision_queue_screen.dart` —
  `AppLocalizations.of(context).supervisionQueueTitle` vb.
- `lib/screens/patient_portal/portal_landing_screen.dart` —
  AppLocalizations kullan.

**Test:** mevcut widget testleri AppLocalizations.delegate ile
sarmalanıyor, EN bekleniyor.

---

## 4. Test hedefi

| Metric | Sprint 9 sonu | Sprint 10 sonu |
|---|---|---|
| Dart test | 449 | ~470 |
| Cloud Function test (Jest) | 16 | ~22 |
| Error | 0 | 0 |
| Compliance posture | A− | A |
| Açık kritik klinik başarı kriteri | 1 (cross-device soft-lock) | 0 |

---

## 5. Sprint 11+ kapsamı (sonraki, bu sprint'te değil)

- Telehealth Daily.co gerçek entegrasyon
- Stripe deposit + no-show charge gerçek
- e-Rx EU eHDSI + TR MEDULA
- Patient portal gerçek aksiyon bağlantısı (DSAR self-service, PROM)
- SOC 2 Type I observation start
- Mobile (Flutter iOS + Android) app store hazırlığı
