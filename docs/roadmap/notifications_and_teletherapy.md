# Bildirim & Teleterapi Yol Haritası

## Push Bildirimleri
- **Sağlayıcı**: Özel proxy (APNs/FCM) → backend → uygulama.
- **Mesaj Tipleri**: randevu hatırlatması, no-show uyarısı, olay/incident, DPO bildirimleri.
- **Sessiz Saat Politikası**: tenant + kullanıcı bazlı `communication_preferences` tablosu.
- **İzin Yönetimi**: in-app preference center (kanal, saat, dil).
- **Failover**: e-posta/SMS fallback, yeniden deneme kuyruğu.
- **Denetim**: her bildirim için `notification_log`.
- **Test**: emülatör mock push (firebase emulator veya local APNs sandbox).

## No-Show Akışı
1. Randevu başlamadan X dakika önce hatırlatma.
2. Oturum başlamadıysa otomatik no-show flag + therapist bildirim.
3. Çoklu no-show durumunda finans ve supervisor alert.

## Teleterapi (WebRTC)
- **Mimari**: WebRTC + SFU (örn. LiveKit, Janus). Mobil ve web istemcileri.
- **E2E Şifreleme**: Insertable Streams / SFrame (platform desteğine göre fallback).
- **Oturum Öncesi Rıza**: Zorunlu onam ekranı + kimlik doğrulama.
- **Oturum Politikaları**: kayıt opsiyonu, saklama süresi, redaksiyon.
- **Kayıt Depolama**: şifreli S3 bucket + anahtar yönetimi.
- **Queue Yönetimi**: bekleme odası, terapist onayı.
- **QoS/Monitoring**: WebRTC stats, network adaptasyon.

## Gereken Servisler
- `NotificationOrchestratorService`: tenant bazlı kural motoru.
- `CommunicationPreferenceService`: sessiz saatler, dil, kanal.
- `TeletherapySessionService`: WebRTC handshake, token üretimi.
- `ConsentGateService`: oturum öncesi rıza doğrulaması.
- `ComplianceRecordingService`: kayıt yönetişimi.

## UI Akışları
- Bildirim tercih ekranı (profil modülü).
- Teleterapi lobisi, kimlik doğrulama, E2E durum badge.
- Oturum sonrası rapor ekranı.

## Yol Haritası Adımları
1. Push proxy API tasarımı + backend köprüsü.
2. Flutter tarafında `NotificationChannel` modeli, izin senaryoları.
3. Communication prefs UI + storage.
4. Teleterapi POC: LiveKit SDK + custom theming.
5. E2E şifreleme & kayıt yönetimi.
6. Otomatik no-show kural motoru.
7. Monitoring + alert entegrasyonu.

## Riskler
- iOS background sınırlamaları.
- WebRTC SFU seçimi (vendor lock-in).
- Ses/video E2E desteğinin platform farklılıkları.
