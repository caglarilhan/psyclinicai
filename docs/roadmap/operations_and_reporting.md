# Faturalama, Klinik Dokümantasyon, Raporlama & DevOps Yol Haritası

## Faturalama / Ödeme
- **Sağlayıcı**: Stripe (küresel) + Adyen/Mollie opsiyonu.
- **Özellikler**:
  - Kart saklama (tokenization), sigorta ödemeleri, abonelik planları.
  - ICD-10 / HCPCS kod eşlemesi; sigorta onayı durum izleme.
  - Webhook doğrulama (imza, sıralama numarası) → `PaymentWebhookService`.
  - Çok para birimi ve vergi motoru (`TaxService`, konum/tenant bazlı KDV).
  - Iade/sorun kaydı (charge dispute) akışı.
- **UI**: Finans dashboard genişletme, ödeme durumu timeline.

## Klinik Dokümantasyon
- **Immutable Seans Notu**:
  - `NoteLockService`: kilitleme sonrası hash + audit trail.
  - Versiyonlama (`NoteVersion` kaydı, diff görünümü).
- **Şablon Yönetimi**:
  - SOAP, DAP, EMDR, CBT vs. için dynamic schema builder.
  - Tenant bazlı özelleştirilebilir alanlar (JSON schema tabanlı).
  - `TemplateMarketplace` (ön tanımlı şablonlar, import/export).

## Raporlama & Analitik
- **KPI Dashboard**: doluluk oranı, no-show yüzdesi, tedavi başarı metriği.
- **Veri Kaynakları**: Postgres materialized views + BI feed.
- **Exportlar**: CSV/Excel/PDF; filtre kriterleri (tarih, klinik, therapist).
- **Self-Service BI**: Looker/Data Studio konektörleri.

## Test / DevOps
- **Test Katmanları**:
  - Unit (repository, services), Widget (UI akışları), Integration (API), e2e (teleterapi, ödeme, PDF).
  - Golden tests for UI temaları.
- **Tooling**:
  - `melos` workspace + module bazlı paketler.
  - Mock server (Prism/PACT) ile contract test.
- **CI/CD**:
  - GitHub Actions: format/analyze/test → build (Android/iOS/Web).
  - Artifact dağıtımı (Firebase App Distribution/TestFlight/internal track).
  - Crash/analytics: Sentry + Firebase Crashlytics.
- **Versiyonlama**:
  - SemVer + changelog otomasyonu (`git-cliff`).
  - Feature flags (remote config).

## Yol Haritası Adımları
1. **Ödeme Entegrasyon Katmanı**: backend proxy + Flutter `payments` modulü.
2. **Dokümantasyon Motoru**: template builder, note locking, audit pipeline.
3. **Analitik & Export**: API + UI; csv/excel generator.
4. **Test Suite Revizyonu**: coverage hedefi >70%, e2e senaryolar.
5. **CI/CD Pipeline**: tam otomasyon, kalite kapıları.
6. **Sentry/Telemetry**: release health, incident correlation.

## Bağımlılıklar & Riskler
- Stripe/Adyen onayı, PCI requirements.
- Immutable notlar için storage maliyetleri.
- Raporlama için veri anonimleştirme.
