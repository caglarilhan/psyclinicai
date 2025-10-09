# Veri Güvenliği & Uyumluluk Yol Haritası

## Gereksinim Başlıkları
1. **Şifreleme**
   - **At-Rest**: Mobil tarafında SQLCipher + iOS Keychain/Android Keystore. Sunucu tarafında disk encryption + KMS (örn. GCP KMS/AWS KMS).
   - **In-Transit**: mTLS veya TLS pinning (certificate pinning) + HSTS.
   - **Dosya Deposu**: S3/GCS benzeri depoda AES-256 server-side encryption ve signed URL.
2. **Log Maskeleme & PII Redaksiyon**
   - Log pipeline: `RedactionLogger` → PII pattern library.
   - Örnek maskeleme: TC Kimlik No, telefon, e-posta, ICD kodları.
   - Üç seviye log (debug, audit, incident) + global toggle.
3. **Uyumluluk Rolleri ve Süreçleri**
   - DPO rolü, veri erişim talepleri (DSAR) için workflow.
   - Incident response playbook: tespit → sınıflandırma → raporlama → kapanış.
   - İhlal rapor şablonları (KVKK, GDPR, HIPAA) PDF/CSV.
4. **Güvenlik Politika Modülü**
   - `SecurityPolicyService`: parola politikaları, MFA zorunluluğu, session timeout.
   - `ComplianceChecklist`: TR/US/EU paketleri.
5. **Denetim Kayıtları**
   - `AuditLogService` olay şeması: `eventType`, `actorId`, `tenantId`, `severity`, `payloadHash`.
   - Immutable append-only storage (örn. `objectbox`/`hive` + server replicasyon).
6. **Veri Koruma Talepleri**
   - DSAR portali: veri indirme, anonimleştirme, silme.
   - SLA takip paneli.
7. **Güvenlik Testleri**
   - Otomatik dependency scanning (Snyk/GitHub dependabot).
   - Mobil AppSec kontrolleri: jailbreak/root detection, screenshot disable opsiyonu.

## Teknik Bileşenler
- `lib/services/security/` klasörü:
  - `encryption_service.dart`: AES-GCM wrapper, anahtar yönetimi.
  - `secure_storage_service.dart`: Keychain/Keystore arabirimi.
  - `tls_pinning_service.dart`: sertifika fingerprint doğrulaması.
  - `redaction_logger.dart`: PII filtreleri.
  - `incident_response_service.dart`: süreç otomasyonları.
- `lib/models/compliance/`: `SecurityIncident`, `DPOReport`, `ComplianceChecklistItem`.
- Konfig `assets/config/security_policies.json` (region-specific ayarlar).

## Sertifika Pinning Süreci
1. Backend TLS sertifikasının SHA-256 fingerprint'i alınır.
2. Flutter tarafında `HttpClient` override içinde pin.
3. Sertifika rotasyonu için birden fazla pin desteklenir.

## Incident Response Akışı
1. İzleme servisleri (Sentry/SIEM) uyarı üretir.
2. `IncidentResponseService.createIncident` → olay kaydı.
3. Otomatik bildirim: DPO + admin + ops kanalı.
4. SLA timer, durum yönetimi (Open, Investigating, Contained, Reported, Closed).
5. Rapor şablonları `docs/templates/` altında saklanır.

## Redaksiyon Politikası
- Regex tabanlı + `PIIType` enum.
- Maskeleme örneği: `user@example.com` → `u***@example.com`.
- Log interceptor: `RedactionLogger.log(event)`; dev modda disable opsiyonu.

## Yol Haritası Adımları
1. **Temel Güvenli Depolama**: `SecureStorageService`, encryption util.
2. **Network Katmanı Sertifika Pinning**: `HttpOverrides` implementasyonu.
3. **Redaksiyon Pipeline**: log helper, policy config, unit test.
4. **Audit/Incident Modeli**: veri şemaları + persist katmanı (server/mock).
5. **DPO Dashboard**: izinli kullanıcılar için olay listesi, rapor üretimi.
6. **Rapor Şablonları**: Markdown → PDF generator.
7. **Test & Otomasyon**: security lint, dependency scanning script.

## Riskler & Açık Sorular
- Sertifika rotasyonu için mobil güncelleme gereksinimi.
- SQLCipher lisans ve Flutter plugin stabilitesi.
- Üç bölge (TR/US/EU) için farklı veri saklama süreleri.
