# PsyClinicAI Yol Haritası — Sprint 21-24

**Tarih:** 2026-06-02 (akşam)
**Referans denetimler:** rapor 07/08/09 (ekran), rapor 10 (web), rapor 11 (mobile), rapor 12 (10-skill panel)
**Bu plan:** kalan açıkları skill-by-skill bir araya getirir + 4 sprint backlog + bekleyen mimari kararlar + go-live takvim.

---

## 1. Şu ana kadar kapanan / hala açık (skill-by-skill)

| Skill | Önceki skor | Bugün | Hâlâ açık |
|---|---|---|---|
| `senior-frontend` | 7.0 | **7.8** | Sticky right-rail; Cmd+K palette; max-width content lockup |
| `apple-hig-expert` | 5.5 | **7.0** | Sheet medium/large detents; Live Activity; Lock-screen widget; Watch glance; Continuity Camera |
| `senior-architect` | 6.5 | **6.5** | Inbox/Tasks toplevel; Org switcher; SSO (SAML/OIDC); Webhook console |
| `senior-security` | 5.0 | **7.2** | Biometric/App-lock; LLM proxy deployment (interface var, server yok); clipboard PHI guard global |
| `healthcare-reviewer` | 6.5 | **8.5** | C-SSRS mode toggle UI wire; 3-psikiyatrist vignette validation |
| `a11y-audit` | 6.0 | **7.0** | Dynamic Type ramp test; skip-to-content link; VPAT taslak |
| `ux-researcher-designer` | 7.0 | **8.0** | Patient CSV import wizard; tooltip/hint sistemi; bulk send |
| `design-system` | 6.5 | **8.0** | Storybook + Figma library; density preference; semantic typography 4 katman |
| `cpo-advisor` / `product-strategist` | 7.5 | **8.2** | Stripe KYC iş günü; Daily.co BAA; No-show prediction; Patient PWA M5 |
| `seo-audit` | 5.5 | **7.5** | Meta/OG/JSON-LD enjeksiyon; sitemap.xml/robots.txt; programmatic SEO |

**Ağırlıklı ortalama:** 6.3 → **7.6 / 10**

---

## 2. Hâlâ açık 25 feature — kategorize backlog

### 🔴 Release-blocker (canlıya çıkmadan kapanmalı)

1. **LLM proxy server endpoint** — interface + stub var; gerçek `/v1/ai/llm` Cloud Function + Vault KMS-wrap + per-tenant cost ledger
2. **Stripe Connect KYC tamamlanması** — sandbox account onboarding + production keys + webhook subscription
3. **Daily.co BAA imzası** — vendor sözleşme + recording S3 bucket eu-central-1 sertifikası
4. **Biometric / App-lock** — `local_auth` paketi + 5dk idle timeout + PIN fallback
5. **Audit log row drawer + verify chain** — prev_hash/this_hash + payload diff + Verify CTA backend
6. **Per-tenant Firestore region rules guard** — `region == tenants/{tid}.region` write-time invariant + cron drift check
7. **MFA TOTP backend persistence** — UI + service var; Firestore `mfa_enrolments/{uid}` doc + recovery code hash whitelist

### 🟠 Yüksek değer (Sprint 21-22)

8. **Org / Tenant switcher** — multi-clinic top-right dropdown + RBAC per tenant + cross-tenant isolation tests
9. **SSO (SAML / OIDC)** — Workspace / Azure AD / Okta entegrasyonu
10. **Inbox / Tasks** — patient mesaj + lab sonuç + ekip task ünitesi + sidebar destinasyon
11. **Insurance Claim Board (837P)** — submitted/accepted/denied/paid kanban + clearinghouse adapter
12. **EHR sync console (HL7 FHIR R4)** — Epic/Cerner/Medistar bağlantı + conflict resolver UI
13. **No-show prediction** — historik no-show ML model + appointment risk skoru + AI reminder cascade
14. **Patient self-service PWA (M5)** — hasta tarafı ayrı bottom-tab (Home/Forms/Messages/Visits)
15. **Bulk patient CSV import wizard** — clinic onboarding'in en kritik aşaması; mapping + dry-run + rollback

### 🟡 Mobile-native UX (Sprint 22-23, iOS-native uzman gerek)

16. **Live Activity / Dynamic Island** — telehealth + AI rec için "Session live · 23:14"
17. **Lock Screen Widget** — Today's first session countdown + emergency C-SSRS quick action
18. **Apple Pencil / Finger signature pad** — note sign-off ekranı (iPad pencil pressure)
19. **Continuity Camera** — desktop session + phone doc cam birleşik akışı
20. **Hand-off (NSUserActivity)** — desktop'ta açık session'a mobile'dan devam

### 🟡 Growth + Marketing (Sprint 22-24)

21. **Programmatic SEO** — `psyclinicai.com/usa/{state}/therapists-software`, `eu/{country}/...` 50+ landing
22. **Schema.org JSON-LD** — `SoftwareApplication` + `MedicalOrganization` + `FAQPage` script enjeksiyon
23. **Sitemap / robots / canonical / hreflang** — flutter web static assets
24. **Email template editor + sequence builder** — appointment reminder + no-show + intake link
25. **Webhook console** — partner entegrasyon (M15 roadmap)

---

## 3. Sprint takvimi

### Sprint 21 (2 hafta) — Release-blocker temizlik

| W | İş | DRI | Süre |
|---|---|---|---|
| 1 | LLM proxy Cloud Function + Vault KMS-wrap + cost ledger | senior-backend + ciso | 5g |
| 1 | Biometric / App-lock (local_auth + PIN fallback + idle timeout) | FE + senior-security | 3g |
| 1 | Audit log row drawer + verify chain backend | FE + BE | 3g |
| 2 | Stripe Connect KYC + production webhook | senior-backend | 4g |
| 2 | Daily.co BAA imzası + recording S3 bucket sertifikasyon | ciso + PM | 4g (legal) |
| 2 | Firestore region rules guard + drift cron | senior-architect | 3g |
| 2 | MFA TOTP backend persistence | senior-security | 3g |

**Toplam:** ~25 dev-gün × 2 engineer + 1 ciso = 1 sprint.

### Sprint 22 (2 hafta) — Multi-tenant enterprise + mobile native

| W | İş | DRI | Süre |
|---|---|---|---|
| 1 | Org / Tenant switcher + RBAC per tenant | senior-architect + FE | 4g |
| 1 | SSO (SAML + OIDC) Workspace + Azure AD | senior-security | 5g |
| 1 | Inbox / Tasks toplevel + sidebar destinasyon | FE | 3g |
| 2 | Live Activity / Dynamic Island (iOS native) | iOS-native uzman | 4g |
| 2 | Lock Screen Widget + Apple Pencil signature pad | iOS-native uzman | 3g |
| 2 | Bulk patient CSV import wizard + dry-run | FE + BE | 3g |

**Toplam:** ~22 dev-gün × 2 + 1 iOS native = 1 sprint.

### Sprint 23 (2 hafta) — Klinik akış genişletme + AI tuning

| W | İş | DRI | Süre |
|---|---|---|---|
| 1 | Insurance Claim Board (837P) + clearinghouse adapter | senior-backend + FE | 5g |
| 1 | EHR sync console (HL7 FHIR R4) + conflict resolver | senior-architect + FE | 5g |
| 1 | No-show prediction ML model + risk skoru | ml-engineer | 4g |
| 2 | 3-psikiyatrist AI diagnosis vignette validation | klinik danışman | 2 hafta paralel |
| 2 | Patient self-service PWA (M5) — Home + Forms tab | FE | 5g |
| 2 | C-SSRS UI mode toggle wire + AUDIT band rendering | FE | 2g |

### Sprint 24 (2 hafta) — Growth + a11y polish

| W | İş | DRI | Süre |
|---|---|---|---|
| 1 | Programmatic SEO 50+ landing + schema JSON-LD | seo-specialist | 5g |
| 1 | Email template editor + sequence builder | FE + BE | 4g |
| 1 | Sitemap / robots / canonical / hreflang | FE | 1g |
| 1 | Cmd+K command palette | FE | 2g |
| 2 | A11y QA pass — Dynamic Type + skip-to-content + VPAT | a11y-audit + FE | 5g |
| 2 | Storybook + Figma library senkron | design-system | 4g |
| 2 | Continuity Camera + Hand-off | iOS-native uzman | 3g |

---

## 4. Bekleyen mimari kararlar (Sprint 21 öncesi karar gerekli)

1. **LLM secret store:** Vault Enterprise vs Google Secret Manager + KMS Envelope. CTO + CISO karar oturumu.
2. **EHR adapter stratejisi:** Notified-body sertifikalı third-party (Redox / Lyniate) vs in-house FHIR client.
3. **Multi-tenant Auth backend:** Firebase Auth devam vs Keycloak self-hosted (KVKK için TR data residency).
4. **MDR Class IIa CDSS pathway:** TÜV SÜD vs BSI notified body seçimi + Class I → IIa upgrade roadmap.
5. **Recording retention default:** Daily.co video 30g / 90g / opt-in only.

---

## 5. Realist go-live takvim

| Yol | Süre | Tarih | Koşul |
|---|---|---|---|
| **Optimistik** | 8 hafta (Sprint 21-24 tam ritim) | 2026-07-28 | LLM proxy + Stripe KYC + Daily.co BAA paralel hızlanır |
| **Beklenen** | 10 hafta | 2026-08-11 | 1 hafta legal slip + 1 hafta clinical validation tekrar tur |
| **Konservatif** | 12 hafta | 2026-08-25 | Vault mimari kararı +1 hafta + EHR adapter karar gecikir |

**Sprint 24 sonu hedef skill panel ortalaması:** 7.6 → **8.8 / 10**

---

## 6. Mevcut sayılar (Sprint 21 başlangıç anchor)

- **Test:** 711/711 yeşil
- **Analyzer:** 0 error · 214 info
- **Lib dosya sayısı:** ~120 (Sprint 9 başlangıcı: ~40)
- **Ekran sayısı:** 57 unique route
- **Compliance:** HIPAA-aligned · GDPR Art. 28 DPA + 30 RoPA + 35 DPIA · KVKK
- **Public legal sayfalar:** privacy, security, ToS, DPA, BAA, about, changelog, contact, press, status, **pricing**, **compare**, **faq**, trust, trust/subprocessors, trust/security_controls, trust/incident_response

---

## 7. Risk listesi

| Risk | Olasılık | Etki | Mitigation |
|---|---|---|---|
| Daily.co BAA gecikir (>4 hafta) | Orta | Telehealth launch gecikir | Whereby / Zoom Healthcare alternatif sözleşme paralel |
| Stripe KYC reddedilir (EU entity) | Düşük | Payments tamamen blok | Mollie SEPA + Adyen alternatif paralel |
| LLM proxy cold-start >500ms | Orta | UX yarar | Cloudflare Workers edge + warm pool |
| Vault Enterprise lisans maliyeti | Orta | Bütçe aşımı | Google Secret Manager fallback |
| MDR Class IIa CE marking gecikir | Yüksek | AI Diagnosis EU launch gecikir | Class I claim ile launch + Class IIa upgrade roadmap |
| Klinik validation vignette fail (<80% gold standard) | Düşük | AI Diagnosis backlog'a düşer | Prompt iterasyon + Opus 4.7 default |

---

**Hazırlık durumu:** Sprint 21-24 backlog tanımlı. Mimari kararlar #1-#5 1 hafta içinde yapılmalı; aksi halde Sprint 21 W1'in 2 maddesi blok.
