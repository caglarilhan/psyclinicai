# Vendor unlocks — kullanıcı aksiyon listesi

Sprint 29 D-day kodu bitti. Kalan iş **vendor hesabı açma, key alma, counsel review**. Her satır 5–30 dk işin + bekleme süresi. Sıralı yap — paralel başlat, kod tarafı bitsin diye bekleme.

> **Master rule (founder-coach persona):** D1 sabahı hepsini başlat. Bekleme süresinde kod paralel çalışmıştı; şimdi onların sırası.

---

## 1. Hetzner Storage Box (HIPAA backup retention — D-02)

**Niçin:** Postgres + Qdrant yedeği `restic` üzerinden EU AES-256 encrypted retention. 6 yıl HIPAA §164.316(b).

**Adımlar:**
1. https://accounts.hetzner.com → Storage Box order (BX11, 1 TB, €3.97/ay, EU).
2. Storage Box username + REST URL alacaksın (`https://uxxxxxxx.your-storagebox.de`).
3. SSH'la hub'a: `ssh ragsvc@46.225.181.130`
4. `/opt/rag-service/.env` dosyasına ekle:
   ```
   RESTIC_REPOSITORY=rest:https://uxxxxxxx.your-storagebox.de:23/restic-psyrag
   RESTIC_PASSWORD=<rastgele 40 karakter, 1Password'a kaydet>
   ```
5. `sudo /usr/local/bin/ragsvc-backup.sh` → manuel ilk push.
6. `restic check --no-cache` → "no errors were found" beklenir.
7. `systemctl status ragsvc-backup.timer` → next-run gözüksün.

**Bekleme süresi:** Hetzner provisioning 5–10 dk.

---

## 2. Stripe live keys + payment link (P-04)

**Niçin:** Reserve-seat CTA'sı çalışsın, Wave A pilot ödeme alabilsin.

**Adımlar:**
1. https://dashboard.stripe.com → Activate account (Türkiye business KYC). 24–48 saat sürebilir.
2. Activation sonrası **Live mode**'a geç.
3. Products → 3 ürün oluştur:
   - **Solo Founding Member** $49/ay (recurring monthly, 6-month minimum)
   - **Practice Founding Member** $149/ay
   - **Group Founding Member** $299/ay
4. Her ürün için Payment Link oluştur — `success_url=https://psyclinicai.web.app/onboarding`.
5. Firebase Functions secret olarak ekle:
   ```
   firebase functions:secrets:set STRIPE_LIVE_SK
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
   firebase functions:secrets:set STRIPE_PRICE_SOLO STRIPE_PRICE_PRACTICE STRIPE_PRICE_GROUP
   ```
6. Webhook endpoint: `https://europe-west1-psyclinicai.cloudfunctions.net/stripeWebhook` → Stripe Dashboard → Webhooks ekle. Events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`.
7. $1 test charge → kart numaranla canlı test → refund.

**Bekleme süresi:** KYC 24–48 h.

---

## 3. PostHog DSN (P-01)

**Niçin:** Funnel events (`landing.visit`, `signup.completed`, `session.first_soap_generated`, `billing.payment_succeeded`) görünür olsun.

**Adımlar:**
1. https://app.posthog.com → Sign up (EU instance, `eu.posthog.com`).
2. Project name: "PsyClinicAI Wave A".
3. Project API key (phc_…) kopyala.
4. Build env'e ekle (`web build` ve CI'da):
   ```bash
   --dart-define=POSTHOG_KEY=phc_xxxxx
   --dart-define=POSTHOG_HOST=https://eu.i.posthog.com
   ```
5. GitHub Actions secret olarak ekle: `POSTHOG_KEY`, `POSTHOG_HOST`.
6. PostHog Dashboard → Funnels → "Wave A activation": `landing.visit → signup.completed → onboarding.finished → session.first_soap_generated` (D7 window). Cohort: D7 activated.

**Bekleme süresi:** anında.

---

## 4. Sendgrid (waitlist email + IR comms — P-08, IR runbook)

**Niçin:** `landing_waitlist` Firestore trigger → "welcome to waitlist" email; SEV1 customer blast.

**Adımlar:**
1. https://signup.sendgrid.com → ücretsiz 100/gün tier yeter.
2. Sender Authentication → `psyclinicai.com` domain doğrula (SPF + DKIM DNS kayıtları).
3. API key oluştur: "Functions full access".
4. Firebase Functions secret: `firebase functions:secrets:set SENDGRID_API_KEY`.
5. Template oluştur: `welcome_to_waitlist` (dynamic template, `{{first_name}}`, `{{join_position}}` vars).

**Bekleme süresi:** DNS propagation 1–4 h.

---

## 5. Cloudflare Turnstile (beta wait-list anti-DoS — Sprint 29 W1 P0)

**Niçin:** `beta_signups` Firestore create'i bot/DoS'a kapansın.

**Adımlar:**
1. https://dash.cloudflare.com → Turnstile → "Add a site".
2. Hostname: `psyclinicai.web.app`, `psyclinicai.com`.
3. Site key + secret key kopyala.
4. Firebase Functions secret: `firebase functions:secrets:set TURNSTILE_SECRET`.
5. Build env: `--dart-define=TURNSTILE_SITE_KEY=0x4xxxxxxx`.
6. `lib/screens/landing/beta_waitlist_screen.dart` → invisible challenge widget (Sprint 30 ship — şimdilik key'i hazır tut).

**Bekleme süresi:** anında.

---

## 6. Workspace alias — `support@`, `security@`, `founders@`, `pentest@psyclinicai.com` (P-03, IR runbook)

**Niçin:** Pilot reach-out + güvenlik raporları + IR comms.

**Adımlar:**
1. Google Workspace Admin (`admin.google.com`) → Users → mevcut hesabına alias ekle (`support@`, `security@`, `founders@`, `pentest@`).
2. Auto-reply (Gmail Settings → Filters): `support@` için "We will reply within 24 h" + tag `pilot/support`.
3. `security@` için PGP key publish — keys.openpgp.org'a yükle; fingerprint'i `SECURITY.md`'ye yaz.
4. `pentest@` için ayrı PGP key (Cure53 / NCC engagement için) — vault `pentest/2026q3-pgp`.

**Bekleme süresi:** anında.

---

## 7. Loom 90-sec demo video (F-01)

**Niçin:** Cold email + landing demo CTA conversion ~3× artar.

**Senaryo (90 saniye):**
1. (10 s) Hero copy okuma + use-case açıklama.
2. (30 s) Session başlat → STT canlı → SOAP draft otomatik.
3. (20 s) Superbill PDF tek tıkla.
4. (15 s) Trust Center → "audio on-device, EU residency" göster.
5. (15 s) "Founding pilot, 50% off, lifetime rate" CTA + email yakalama.

**Adımlar:**
1. https://www.loom.com → free tier.
2. Kaydet → trim → public link al.
3. `lib/widgets/landing/demo_modal.dart` → `DemoModal()` constructor'a `loomUrl: 'https://www.loom.com/share/xxxx'` geç (default '' kalır).
4. Hero "Watch 90-sec demo" butonunda `loomUrl` props olarak modal'a geç.

**Bekleme süresi:** kayıt 30 dk + editing 30 dk.

---

## 8. Counsel review (S-04 IR runbook + P-07 Pilot Agreement + P-02 BAA/DPA)

**Niçin:** İlk pilot imzalamadan önce yasal docs onayı.

**Adımlar:**
1. Outside counsel'a 3 doc yolla:
   - `docs/security/incident-response.md` — IR runbook
   - `docs/legal/PILOT_AGREEMENT.md` (henüz oluşmadı — P-07 Sprint 29 W2)
   - `docs/legal/HIPAA-BAA.md` + `docs/legal/GDPR-DPA.md` — counsel revize edecek
2. Counsel'dan red-line bekle (3–5 iş günü).
3. Onaylı versiyonu commit'le; landing'in `/baa`, `/dpa` rotalarına bağlı static page content'i güncelle.

**Bekleme süresi:** 3–5 iş günü.

---

## 9. Custom domain `psyclinicai.com` (Sprint 29 P2)

**Niçin:** `web.app` subdomain pilot için yeterli; `psyclinicai.com` profesyonel.

**Adımlar:**
1. Firebase Console → Hosting → Add custom domain `psyclinicai.com`.
2. DNS provider'da A record + TXT verification kayıtları.
3. SSL auto-provision (24 h Let's Encrypt).
4. `lib/web/index.html` OG tags `psyclinicai.com` URL'lerine güncelle.

**Bekleme süresi:** DNS 1–24 h + SSL 1 h.

---

## 10. Sentry DSN ×3 (D-07)

**Niçin:** Dart + Node + Python tarafından crash/error capture; release tracking.

**Adımlar:**
1. https://sentry.io → 3 project oluştur:
   - `psyclinicai-flutter-web` (platform: flutter)
   - `psyclinicai-functions` (platform: node)
   - `psyrag-hub` (platform: python)
2. Her project'in DSN'ini al.
3. Secrets:
   - `firebase functions:secrets:set SENTRY_DSN_NODE`
   - Flutter: `--dart-define=SENTRY_DSN=https://...@sentry.io/...`
   - Hub `/opt/rag-service/.env`: `SENTRY_DSN=https://...@sentry.io/...`
4. Alert rule: `error_rate > 5%` 5 min → Slack `#incidents`.
5. Release tracking: `sentry-cli releases new v1.0.0-beta.1 && sentry-cli releases set-commits --auto v1.0.0-beta.1`.

**Bekleme süresi:** anında.

---

## Sıralı icra önerisi

| Gün | Vendor unlock |
|---|---|
| **D1 sabahı (paralel başlat)** | 1 Hetzner Storage Box + 3 PostHog + 4 Sendgrid + 5 Turnstile + 6 Workspace alias + 7 Loom kayıt + 10 Sentry ×3 |
| **D1 öğleden sonra** | 1 restic test push, 4 SPF/DKIM DNS, 6 PGP publish |
| **D2** | 2 Stripe activation submit (24–48 h bekleme), 8 counsel email gönder |
| **D2 sonu** | 9 Custom domain DNS başlat |
| **D3–D5** | Stripe + counsel + DNS dönüşü beklerken kod tarafındaki kalan polish (F-02..F-06, B-05, B-06, S-05, S-07, S-08) |

Bu listenin tamamı bitince [LAUNCH-READINESS-PUNCHLIST.md](LAUNCH-READINESS-PUNCHLIST.md) §5 acceptance gates kontrolüne geç.
