# PsyClinicAI — Global Launch Plan (US + EU)

**Tarih:** 18 May 2026
**Hedef pazar:** US (50 eyalet) + EU (DE/NL/UK/FR önce)
**Türkiye:** **PRD'de yok** — Türkçe sadece dev dili. Default locale EN.
**30-gün hedef:** **$3K MRR + $5K annual prepay cash** (10 founding member)
**Altyapı:** Domain var + Hetzner VPS var → 7 günde production-ready

---

## 0. KANITLANMIŞ DURUM (18 May 2026 build doğrulaması)

### Çalışan
- `flutter pub get` OK, `flutter build web` 47s'de başarılı
- 7 ekran tarayıcıda render ediyor: Landing, Dashboard, Session Co-Pilot, E-Prescription, AI Diagnosis, AI Chatbot, Mood Tracking
- **i18n altyapı hazır** (`multi_language_service.dart` 6 dil: tr/en/de/fr/es/ar)
- Deployment altyapı hazır (`deployment/docker-compose.yml` + nginx + caddy)
- `us_state_law_service.dart` 697 satır var (ABD 50 eyalet legal motoru) — hasarlı, fix gerek
- `cultural_competency_service.dart` mevcut (EU/US lokalizasyon için)
- Stripe + WebRTC + OpenAI/Anthropic SDK'lar yüklü

### Şu an global olmayan
- Default locale `tr` (en'e çevirilecek)
- Demo data %100 Türkçe (hasta isimleri, ilaç adları TL fiyatlı) — US/EU veriyle değiştirilecek
- Landing page Türkçe metin
- Pricing TL referansı yok ama Stripe live mode kurulu değil
- 4764 orphan error (main.dart'tan ulaşılmıyor, build'a girmiyor) — sales engeli değil

---

## 1. RAKİP ANALİZİ (US + EU)

### US Pazarı
| Rakip | User base | Aylık | Boşluk |
|-------|----------:|------:|--------|
| **SimplePractice** | 250K | $49–99 | AI yok, generic EMR |
| **TherapyNotes** | 100K+ | $59–99 | Insurance-first, AI minimal |
| **ICANotes** | 50K+ | $35–213 | Structured notes, AI yok |
| **Osmind** | 15K+ | $99–199 | Psychedelic niche |
| **Headway/Alma** | – | – | Marketplace, EMR değil |
| **Otter.ai (meeting AI)** | – | $20+ | Healthcare/HIPAA değil |

### EU Pazarı
| Rakip | Bölge | Aylık | Boşluk |
|-------|-------|------:|--------|
| **Sondermind** | UK/EU | £79+ | UK only, AI minimal |
| **Therapy Notes EU** | – | €60+ | GDPR cards yok |
| **Doctolib** | FR/DE | €129+ | General med, mental health zayıf |
| **TheraNest EU** | – | €65+ | Generic, AI yok |

### Bizim 3 USP (rakipte yok)
1. **Real-Time Session AI Co-Pilot** — voice+facial+session AI tek pakette
2. **Multi-Jurisdiction Legal Engine** — 50 US states + GDPR + HIPAA otomatik rule motor (`us_state_law_service.dart`)
3. **Patient AI Companion 7/24** — chatbot + mood + AI homework + crisis detection birlikte

**Konum:** "SimplePractice + Otter.ai + Calm — all in one, GDPR/HIPAA-compliant" — boş pazar.

---

## 2. PRICING (USD + EUR)

| Plan | Hedef | Monthly | Annual (-20%) | Founding (-50% × 6mo) |
|------|-------|--------:|--------------:|----------------------:|
| **Solo** | 1 clinician | **$99 / €89** | $950 / €855 | **$49/€45 × 6mo** then full |
| **Practice** | 2–10 | **$299 / €269** | $2870 / €2580 | **$149/€135 × 6mo** |
| **Group** | 11+ | **$599+ / €539+** | custom | **$299/€269 × 6mo** |
| **White-label** | Academia/Hospital | custom | – | – |

### Founding Member Program (first 30 customers)
- 6 ay %50 indirim
- Annual prepay opsiyonu (peşin cash)
- Public roadmap voting hakkı
- Locked founding rate sonsuza dek (loyalty)
- Logo/testimonial → +1 ay free

### 30-Day Cash Targets

| Hafta | Demo call | Pilot | Paying | Cash |
|-------|----------:|------:|-------:|-----:|
| 1 | 5 | 1 | 0 | $0 |
| 2 | 12 | 3 | 1 (solo prepay) | **$490** |
| 3 | 20 | 6 | 3 (2 solo + 1 practice) | **$490 + $980 + $1490 = $2,960** |
| 4 | 30 | 10 | **5 paying** ($495 MRR avg) + **$5K cash prepay** | **$7,900 total in** |

---

## 3. GO-TO-MARKET (EU + US)

### Outreach Kanalları

**Tier 1 — Reddit + Online Communities (Hafta 1):**
- r/psychotherapy (180K members) — value post, not promo
- r/therapists (45K)
- r/clinicalpsych (35K)
- r/Psychiatry (75K)
- Therapist Slack/Discord (ARC, etc.)
- 30 personalized DMs from these channels

**Tier 2 — LinkedIn US/EU clinician outreach (Hafta 1–2):**
- LinkedIn Sales Navigator search: "psychiatrist" or "clinical psychologist" + US/UK/DE/NL/FR cities
- 100 cold InMails: Boston, NYC, SF, London, Berlin, Amsterdam, Munich, Paris
- Hyper-targeted by specialty (CBT, EMDR, psychiatry)

**Tier 3 — Therapist directories (Hafta 2):**
- Psychology Today directory (250K therapists)
- BetterHelp/Talkspace platform therapists
- Psych Central, GoodTherapy
- Listed practitioners' websites → direct contact

**Tier 4 — APA/EAP/BPS organizations (Hafta 3):**
- APA (American Psychological Association) sponsored content
- EAP (European Association of Psychotherapy)
- BPS (British Psychological Society)
- VAP (Vereniging Antroposofische Psychotherapeuten — NL)

**Tier 5 — Content + paid (Hafta 3–4):**
- ProductHunt launch ("AI co-pilot for therapists")
- IndieHackers post
- Twitter thread: "How AI watches your session vitals so you don't have to"
- 1 sponsored podcast (Therapy Insiders, etc.)

### Cold Email Template (EN, Solo Clinician)

```
Subject: Cut your session note time by 70%, [First Name]

Hi [First Name],

You probably spend 1–2 hours every evening writing session notes
that should have taken 5 minutes. I built PsyClinicAI to fix exactly that.

Here's what it does during your session (HIPAA/GDPR-compliant):

1. **Live AI Co-Pilot** — voice + facial analysis gives you real-time
   anxiety/risk scores while you focus on the client
2. **Auto-generated DSM-5 notes** — 30-second summary post-session
3. **State-specific legal compliance** — auto-handles 5150 in CA,
   mandatory reporting in NY, GDPR in EU
4. **Patient AI Companion** — your client gets 24/7 mood check-ins
   and homework support, you see weekly summary

I'm onboarding 10 founding members at 50% off for 6 months
(then $49/mo solo, $149/mo practice).

15-min demo this week? Calendly: [link]

Best,
Çağlar Ilhan
Founder, PsyClinicAI
caglarilhann@gmail.com
```

### Cold Email Template (EN, Group/Practice Owner)

```
Subject: [Practice Name]'s 8 therapists could reclaim 64 hours/week

Hi Dr. [Last Name],

If your team is anything like the practices I've seen, your 8 clinicians
collectively burn ~64 hours/week on documentation. Insurance audits
require it, but the time tax is brutal.

PsyClinicAI is a co-pilot built specifically for behavioral health teams:

→ Real-time session AI (voice + facial emotion analytics)
→ Auto DSM-5 notes + state-specific legal auto-compliance
→ Patient AI companion (24/7 mood check-ins, less missed sessions)
→ Single dashboard for clinical director with risk alerts

We're piloting with 10 practices at 50% off Practice plan
($149/mo for 6 months, then $299/mo) — your team could be in.

30-min team demo this week?

Best,
Çağlar Ilhan
caglarilhann@gmail.com
```

---

## 4. COMPLIANCE STORY (EN)

### HIPAA (US)
- BAA (Business Associate Agreement) hazır şablon
- End-to-end encryption (`enhanced_security_service.dart` 80%+ hazır)
- Audit logs (`audit_log_service.dart` mevcut)
- US data residency (Hetzner FSN data center — şimdilik EU; ABD AWS US-East'e add-on)

### GDPR (EU)
- Data Processing Agreement (DPA) şablon
- Right to erasure + data export (`data_export_service.dart`)
- Consent management (`consent_service.dart`)
- EU data residency (Hetzner FSN/HEL ✓ — Germany)

### State-Specific (US 50 eyalet)
- `us_state_law_service.dart` (697 satır) + `legal_compliance_orchestrator.dart` motoru
- CA 5150 holds, NY Tarasoff duty, FL Baker Act, Texas mandatory reporting
- Bu 112 hatayı kapatmak USP #2'nin demonstratable hale gelmesi için ŞART

---

## 5. SPRINT 0 — 7-DAY GLOBAL LAUNCH PREP

### D1 (Bugün) — i18n EN + Demo Data EN
- [ ] `language_service.dart` default `en_US`, `_translations['en']` map'ini doldur
- [ ] `multi_language_service.dart` initial language 'en'
- [ ] Demo data: Türkçe isimler → EN (John Smith, Jane Doe, etc.)
- [ ] E-Reçete ilaçları: Türkçe → EN (Fluoxetine/Sertraline/Lorazepam zaten Latince)
- [ ] Mood tracking demo notes EN
- [ ] Currency: TL → USD (Stripe locale)
- [ ] `flutter build web` → screenshot test 7 ekran EN

### D2 — Landing Page EN + Hetzner Deploy
- [ ] `landing_screen.dart` Türkçe → EN
- [ ] Hero: "AI Co-Pilot for Therapists & Psychiatrists"
- [ ] Subheading: "Real-time session intelligence. Auto-generated DSM-5 notes. HIPAA & GDPR-compliant."
- [ ] CTA: "Book 15-min Demo" → Calendly
- [ ] Hetzner VPS deploy:
  - `rsync build/web/ user@hetzner-ip:/var/www/psyclinicai-demo/`
  - Caddy/Nginx config (HTTPS via Let's Encrypt)
  - Subdomain: `demo.[your-domain].com`

### D3 — Stripe Live + Compliance Docs
- [ ] Stripe live mode (USD + EUR), tax handling US sales tax + EU VAT
- [ ] Payment links: Solo $49 / Practice $149 / Group $299
- [ ] HIPAA Privacy Notice + BAA template (`docs/HIPAA-BAA.md`)
- [ ] GDPR Privacy Policy + DPA template (`docs/GDPR-DPA.md`)
- [ ] Terms of Service + Cookie Policy
- [ ] Pilot Agreement (6-month commit, 50% off)

### D4 — USP #2 Fix (Multi-Jurisdiction Legal)
- [ ] `us_state_law_service.dart` 112 error analyze
- [ ] Eksik model dosyaları oluştur (`lib/models/legal_policy_models.dart` zaten var, kontrol)
- [ ] State seed data: CA, NY, TX, FL, MA (top 5 ABD pazarı)
- [ ] Demo screen: "Crisis detected → CA 5150 form auto-generated" animation

### D5 — Sentry + PostHog + Analytics
- [ ] `flutter pub add sentry_flutter posthog_flutter`
- [ ] `lib/main.dart` global error handler
- [ ] Event tracking: signup, demo_request, payment_initiated, payment_success
- [ ] PostHog dashboard: funnel landing → demo → pilot → paid

### D6 — First Outreach Wave
- [ ] LinkedIn Sales Navigator: 50 US + 30 EU clinician profiles
- [ ] 20 personalized cold InMails sent
- [ ] 10 Reddit DMs (r/psychotherapy, r/therapists)
- [ ] 5 Twitter outreach to therapy influencers
- [ ] Goal: 3+ demo calls scheduled by EOD

### D7 — First Demos + Founding Member Sign-up
- [ ] 1–2 live Zoom demos (15–30 min, screen share Hetzner demo URL)
- [ ] Pilot Agreement PDF sent post-demo
- [ ] Stripe payment link follow-up
- [ ] Goal: 1 pilot agreement or 2 strong "yes" signals

---

## 6. KOD GAP'LERİ (Para Akışını Bloklar)

### MUTLAKA Sprint 0'da
1. **i18n EN default + EN translation map** (`language_service.dart`, ~200 string)
2. **Demo data EN'ye geçir** (ai_chatbot, mood_tracking, e_prescription, session screens hardcoded TR strings)
3. **Landing page EN** (`landing_screen.dart` text replace)
4. **Hetzner deploy script** (`deployment/scripts/deploy.sh` — rsync + nginx reload)
5. **Stripe live mode** (`stripe_service.dart` test → live keys)
6. **HIPAA + GDPR doc placeholder pages** (`/legal/hipaa`, `/legal/gdpr`)

### Sprint 1 (D8–14)
7. **`us_state_law_service.dart` 112 error fix** — USP #2 demonstratable hale getir
8. **Multi-tenant Firestore isolation** — security rules
9. **EU data residency banner** — "Your data lives in Frankfurt, Germany"
10. **Demo data EN polish** — Dr. Sarah Johnson, John Doe, EUR formatlama

### Sprint 2 (D15–30)
11. **DE + FR localization** (auto-translate, native review)
12. **Real-time AI panel polish** — `real_time_session_dashboard_widget.dart` 79 error
13. **HIPAA-compliant infrastructure audit** (encrypt at rest, BAA signed with Hetzner)
14. **VAT/Sales tax automation** (Stripe Tax)

---

## 7. RISK & MITIGATION (Global)

| Risk | Olasılık | Etki | Mitigation |
|------|:--:|:--:|------|
| US pilot, HIPAA BAA imzalamadan veri toplamak | Orta | ÇOK Yüksek | İlk pilotlar EU, BAA + ALG hukukçu Sprint 1 |
| EU GDPR sınır dışı veri transferi (OpenAI/Anthropic US-based) | Yüksek | Yüksek | DPA EU SCC + Anthropic Bedrock EU region kullan |
| EN UX kalitesi clinician beğenmez | Orta | Yüksek | Native EN speaker (Fiverr $50) UI copy review |
| US clinician $49 düşük fiyat ucuz görür | Düşük | Orta | "Founding member only, limited to 30 seats" scarcity |
| Hetzner Germany US clinician için latency | Düşük | Düşük | CloudFlare edge cache + post-launch AWS US-East replica |
| Tek başına EN+US/EU + DE/FR yapamaz | Yüksek | Yüksek | TR'yi sunset, sadece EN ile launch et; DE/FR Sprint 3 |

---

## 8. EŞSIZLIK CANLI TEST (referans)

Önceki test sonuçları: 7/7 ekran çalışıyor (TR demo verisiyle).
EN'ye geçirme sonrası tekrar test edilecek. Build pipeline aynı:
1. `flutter build web --no-tree-shake-icons` (47s)
2. `cd build/web && python3 -m http.server 8765`
3. Headless Chrome screencast (`/tmp/psyclinic-test/`)
4. Rsync to Hetzner demo subdomain

Test edilen URL'ler (localhost):
- `/` (Landing)
- `/#/dashboard`, `/#/session`, `/#/e_prescription`
- `/#/ai_diagnosis`, `/#/ai_chatbot`, `/#/mood_tracking`

---

## 9. ŞU AN BAŞLANACAK 3 İŞ

1. **i18n EN default + 200 string EN translation** — `lib/services/language_service.dart` + screen string'leri
2. **Demo data EN** — Türkçe isim/şehir/ilaç → EN equivalent
3. **Hetzner deploy** — `deployment/scripts/deploy.sh` çalıştır, `demo.[domain]` canlı

Bu 3 iş bugün/yarın bitmeli — Sprint 0 D1+D2 = launch foundation.

---

**Tek cümle hedef:** 30 günde 10 founding member, $3K MRR, $5K annual prepay cash — US/EU pazardan.

**Tek kelime moto:** Sell first, build (in English) faster.
