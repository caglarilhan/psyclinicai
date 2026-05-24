<div align="center">

# PsyClinicAI

**The AI co-pilot for therapists & psychiatrists.**
Real-time session intelligence · auto-generated DSM-5 notes · HIPAA + GDPR compliant.

[![Build](https://img.shields.io/badge/build-passing-brightgreen.svg)](.github/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-Proprietary-lightgrey.svg)](#license)
[![HIPAA](https://img.shields.io/badge/HIPAA-aligned-blue.svg)](docs/legal/HIPAA-BAA.md)
[![GDPR](https://img.shields.io/badge/GDPR-Article%2028%20DPA-blue.svg)](docs/legal/GDPR-DPA.md)
[![Deploy](https://img.shields.io/badge/deploy-Hetzner%20EU-FF5733.svg)](https://psyclinicai.com)

[Live demo](https://psyclinicai.com) · [Architecture](ARCHITECTURE.md) · [Contributing](CONTRIBUTING.md) · [Security](SECURITY.md)

</div>

---

## Why PsyClinicAI

Mental-health practices spend **1-2 hours per evening** on session documentation.
Insurance reimbursement requires CPT + ICD-10 + outcome data that legacy EHRs
either don't capture or surface poorly. PsyClinicAI replaces 4 separate tools
with one ambient AI co-pilot:

| Problem | Today | With PsyClinicAI |
|---------|-------|------------------|
| Session notes | 30-90 min typing | **5 min** review of AI-generated SOAP / DAP / BIRP |
| Insurance billing | Manual CPT + ICD-10 lookup | One-click superbill PDF |
| Outcome tracking | Separate forms, no trend view | PHQ-9 / GAD-7 with longitudinal dashboard |
| Multi-jurisdiction compliance | Spreadsheet of state law | 50-state + GDPR + KVKK rule engine |

**Positioning:** SimplePractice + Otter.ai + Blueprint + ClinikEHR — in one product, BYOK AI, multi-tenant by design.

---

## Features

### Shipped (Sprint 0-2)
- **Live AI Co-Pilot** — on-device transcription + Anthropic Claude Haiku 3.5 → SOAP / DAP / BIRP in < 30 s.
- **Superbill PDF** — 12 mental-health CPT codes + 35 ICD-10 codes + CMS-1500-aligned PDF.
- **Measurement-Based Care** — PHQ-9 (depression) + GAD-7 (anxiety) with severity bands + clinical guidance.
- **E-prescription** — global drug database + TR Medula / e-Reçete integration.
- **Crisis detection** — risk language flagging in real time.
- **Telemedicine** — WebRTC video + signaling.
- **BYOK API keys** — Anthropic / OpenAI tokens encrypted in OS keychain; never leave the device.
- **Multi-jurisdiction compliance scaffolding** — 50 US states, EU GDPR, TR KVKK.
- **i18n** — EN / TR shipping; DE / FR / ES / AR scaffolded.

### Roadmap (Sprint 3-6, 16 days)
- Firebase Auth + Firestore multi-tenant persistence.
- Patient CRUD + session history.
- Outcome dashboard (PHQ-9 / GAD-7 longitudinal trends).
- Patient portal + e-signature.
- Sentry / PostHog observability.
- HIPAA BAA + GDPR DPA pre-signed templates.
- Stripe / Paddle live mode + onboarding wizard.
- Native mobile build (iOS / Android App Store).

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full technical roadmap and
[`docs/adr/`](docs/adr/) for each architecture decision.

---

## Architecture at a glance

```
                    PsyClinicAI Flutter Web
   Landing - Dashboard - Session Co-Pilot - Superbill - MBC -
   E-Rx - AI Diagnosis - Patient Portal - Settings
                  |                            |
                  | on-device                  | HTTPS / TLS 1.3
                  v                            v
        +------------------+         +------------------------+
        |  Native STT      |         |   Firebase             |
        |  (no audio leaves|         |  - Auth                |
        |   the device)    |         |  - Firestore (EU)      |
        +--------+---------+         |  - Storage             |
                 | transcript        |  - Cloud Functions     |
                 v                   +-----------+------------+
        +------------------+                     |
        |  Anthropic       |                     |
        |  Claude Haiku    |                     | per-tenant
        |  (BYOK,          |                     | security rules
        |   sub-$0.001/sn) |                     v
        +------------------+         +------------------------+
                                     |  Hetzner CX33 (DE)     |
                                     |  - Nginx + Let's Enc.  |
                                     |  - fail2ban + Cloud FW |
                                     |  - Docker multi-tenant |
                                     +------------------------+
```

Full deployment topology + data-flow diagrams in [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Quick start

### Prerequisites
- Flutter 3.38+ / Dart 3.10+
- Chrome 120+ (web target; iOS / Android / macOS also supported)
- A Firebase project (see [docs/runbooks/firebase-setup.md](docs/runbooks/firebase-setup.md))
- An Anthropic API key (clinician BYOK; obtain at <https://console.anthropic.com>)

### Run locally
```bash
git clone https://github.com/caglarilhan/psyclinicai.git
cd psyclinicai
flutter pub get

# Add your firebase_options.dart (see docs/runbooks/firebase-setup.md).
flutter run -d chrome
```

### Static analysis & tests
```bash
flutter analyze                  # 0 errors / 0 warnings on owned code
flutter test                     # unit + widget tests
flutter test integration_test/   # end-to-end happy paths
```

### Production build
```bash
flutter build web --release --no-tree-shake-icons
# Hetzner deploy script:
ssh root@your-host 'bash -s' < deploy/deploy-hetzner.sh
```

---

## Compliance

PsyClinicAI is privacy-first and compliance-aware from day one.

- **HIPAA** — BAA template at [`docs/legal/HIPAA-BAA.md`](docs/legal/HIPAA-BAA.md); clinician signs before any live PHI.
- **GDPR** — DPA Article 28 at [`docs/legal/GDPR-DPA.md`](docs/legal/GDPR-DPA.md); EU data residency (Frankfurt).
- **KVKK** — Turkish DPA at [`docs/legal/KVKK-DPA.md`](docs/legal/KVKK-DPA.md); VERBİS-ready.
- **Encryption** — TLS 1.3 in transit; AES-256 at rest (`sqflite_sqlcipher` local, Firestore native).
- **Audit log** — immutable, append-only, exportable on request.
- **Right to erasure** — 30-day scheduled deletion + audit trail.

Full security policy: [SECURITY.md](SECURITY.md).

---

## Tech stack

| Layer | Tool |
|-------|------|
| Frontend | Flutter 3.38 (web + iOS + Android + macOS) |
| State | Provider + ChangeNotifier (Riverpod migration planned Sprint 5) |
| Backend | Firebase Auth + Firestore (EU multi-region) |
| AI | Anthropic Claude Haiku 3.5 (BYOK), OpenAI optional |
| Speech-to-text | On-device (Apple Speech / Android SpeechRecognizer / Web Speech API) |
| Payments | Paddle MoR (planned Sprint 6); Cenoa for Turkish payouts |
| Hosting | Hetzner CX33 (Frankfurt) + Nginx + Let's Encrypt |
| Observability | Sentry (errors) + PostHog (product analytics), Sprint 5 |
| CI/CD | GitHub Actions ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) |
| Design | Material 3 + custom theme tokens |

---

## Contributing

We follow the [Conventional Commits](https://www.conventionalcommits.org/) spec
and require:
- `flutter analyze` clean (0 errors / 0 warnings on owned code)
- `flutter test` green
- A line in `docs/adr/` for every architecture decision

Full guidelines: [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

Proprietary. © 2026 PsyClinicAI. All rights reserved.

For pilot access, partnerships, or licensing inquiries: `caglarilhann@gmail.com`.
