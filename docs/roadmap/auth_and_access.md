# Kimlik & Yetkilendirme Yol Haritası

## Mevcut Durum Özeti
- `lib/services/auth_service.dart` yalnızca mock oturum açmayı simüle ediyor.
- Rol, klinik veya izin modeli bulunmuyor; `MultiProvider` katmanında statik servis enjekte ediliyor.
- Oturum yenileme, şifre sıfırlama, OTP/2FA veya biyometrik akışı yok.

## Hedeflenen MVP+ Gereksinimleri
1. **Çoklu Rol Desteği**
   - Roller: `admin`, `clinic_owner`, `therapist`, `assistant`, `finance`, `dpo`.
   - Rol tabanlı izin matrisi: ekranlar ve servis metodları için guard.
2. **Çoklu Klinik / Tenant**
   - `tenant_id` ile ayrıştırma; kullanıcı-tenant pivot tablosu.
   - Admin paneli ile klinik oluşturma, davet akışı.
3. **Kimlik Sağlayıcıları**
   - E-posta/şifre (primary) + SSO (Google/Microsoft) için modüler adapter.
   - OAuth 2.1 + PKCE desteği.
4. **Oturum Yönetimi**
   - Refresh token + access token (JWT) çiftleri.
   - Sessiz yenileme, aktif oturum listesi, zorunlu çıkış.
5. **Şifre Sıfırlama**
   - Magic link + OTP kodu.
6. **Çok Faktörlü Kimlik Doğrulama**
   - E-posta/SMS OTP, Authenticator TOTP, cihaz biyometri (LocalAuth).
7. **Denetim & Güvenlik**
   - Oturum ve yetkilendirme olayları için denetim logu.
   - PII maskeleme (örn. log mask policies).

## Önerilen Mimari Bileşenler
- `lib/services/auth/` altında modüler servisler:
  - `auth_repository.dart`: API arayüzü.
  - `session_manager.dart`: token ömrü, yenileme, cache.
  - `role_guard.dart`: yetkilendirme yardımcıları.
  - `mfa_service.dart`: OTP/TOTP/Biometrik yönetimi.
- Ortak modeller `lib/models/auth/` klasörüne taşınacak.
- `AuthService` mevcut basit haliyle `AuthFacade` olarak yeniden yazılacak.
- Arka uç varsayımı: OAuth2 + OpenID Connect uyumlu bir identity provider (örn. Supabase Auth, Auth0, Cognito).

## API Sözleşmesi Taslağı
- `/auth/login` (POST) → `{ email, password, tenantId }`.
- `/auth/token/refresh` (POST) → `{ refreshToken }`.
- `/auth/logout` (POST) → `{ sessionId }`.
- `/auth/mfa/challenge` & `/auth/mfa/verify`.
- `/roles` & `/permissions` endpointleri.

## UI / State Yönetimi
- `AuthWrapper` güncellenecek: splash → session restore → mfa → role guard.
- `Provider` yerine `Riverpod` veya `Bloc` değerlendirmesi (modüler test için).
- GuardedRoute helper: rol+kullanıcı durumu kontrolü.

## Adım Adım Plan
1. **Model & Repository**
   - `UserProfile`, `Tenant`, `Role`, `Permission` modelleri.
   - `auth_repository.dart` HTTP/mock implementasyonu.
2. **Session Layer**
   - Güvenli depolama (SecureStorage/Keychain) + token yenileme.
   - Uygulama açılışında sessiz yenileme.
3. **UI Akışları**
   - Login ekranında tenant seçimi/opak auto-detect.
   - MFA challenge ekranı.
   - Şifre sıfırlama wizard.
4. **Rol Bazlı Guard**
   - Route-level guardlar, widget-level directives.
   - Dashboard modüllerinin role aware hale getirilmesi.
5. **Audit & Logging**
   - `AuditLogService` ile oturum olaylarının kaydı.
   - Log maskeleme helper (örn. `RedactionLogger`).
6. **Biyometrik + 2FA**
   - `BiometricAuthService` ile `SessionManager` entegrasyonu.
   - 2FA zorunluluk politikasını rol bazlı ayarlama.
7. **Test**
   - Unit: session manager, token yenileme.
   - Widget: login/MFA ekranları.
   - Integration: rol guard akışı.

## Açık Sorular
- Identity provider olarak hangi çözüm tercih edilecek?
- Tenant onboarding UI’si mobil mi web mi öncelikli?
- MFA için SMS sağlayıcısı?

Bu doküman, kimlik/rol gereksinimlerinin geliştirilmesi için referans oluşturur.
