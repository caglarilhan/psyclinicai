# Mobile release checklist (iOS + Android)

**Status:** Sprint 14 backlog ready, store submission Sprint 15+
**Owner:** PsyClinicAI Mobile lead
**Last reviewed:** 2026-06-02

This checklist is the bridge between a green CI build and the App
Store / Play Console upload. Anything left unchecked here is a
guaranteed reject from Apple Review.

---

## 1. Privacy disclosures

- [ ] **App Privacy questionnaire (App Store Connect)** — every data
      type the app collects mapped to a use case. Match it line-by-line
      to the RoPA registry (`lib/services/compliance/ropa_registry.dart`).
- [ ] **PrivacyInfo.xcprivacy** added to `ios/Runner/` listing every
      Required Reason API the runtime uses (file timestamp, user
      defaults, UIPasteboard if any).
- [ ] **Data Safety form (Play Console)** — same content, Google's
      taxonomy. Mark "Data is encrypted in transit" and "Users can
      request deletion" (both true via Sprint 9 backend).
- [ ] In-app privacy policy URL points to `https://psyclinicai.com/privacy`
      and the page is reachable without authentication.

## 2. App Store assets

- [ ] App icon 1024×1024 — clinical, no founder-personal imagery
      (CLAUDE.md brand-voice rule).
- [ ] Screenshots: 6.7" iPhone, 6.5" iPhone, 12.9" iPad, 13" iPad,
      Pixel 8, Pixel 8 Pro — six per locale (EN + TR).
- [ ] Promotional text uses "we / our team / the platform" (plural).
- [ ] Localised description for EN + TR markets (matches ARB i18n).

## 3. Build settings

- [ ] iOS: `CFBundleShortVersionString` = semantic version; build
      number = `git rev-list --count HEAD`.
- [ ] Android: `versionName` matches; `versionCode` strictly
      increasing.
- [ ] `applicationId` and `CFBundleIdentifier` use `com.psyclinicai.app`.
- [ ] ProGuard rules / R8 keep the data classes used by Firestore.
- [ ] iOS `Info.plist` includes:
      * `NSCameraUsageDescription` — telehealth video
      * `NSMicrophoneUsageDescription` — telehealth audio
      * `NSFaceIDUsageDescription` — biometric MFA (Sprint 15 backlog)

## 4. Runtime configuration

- [ ] Production `firebase_options.dart` ships only `eu-central-1`
      project; staging stays in a separate scheme.
- [ ] BYOK Anthropic key NEVER bundled — keys flow per clinic from
      Cloud Function.
- [ ] Sentry DSN comes from `--dart-define`, not the repo.

## 5. Compliance hand-offs

- [ ] DPIA `docs/compliance/DPIA_AI_ASSISTANCE.md` linked from the
      privacy page.
- [ ] TIA pair (`TIA_ANTHROPIC.md`, `TIA_STRIPE.md`) accessible to
      reviewers.
- [ ] RoPA last reviewed within 12 months (see
      `RopaRegistry.lastReviewed`).

## 6. Pre-submission smoke

- [ ] `flutter analyze` clean.
- [ ] `flutter test --reporter compact` all green.
- [ ] Cloud Functions `npm test` all green.
- [ ] Manual: sign-in, intake, session note, telehealth handshake,
      DSAR submission, account deletion request.
- [ ] Crash-free rate from `flutter run --release` smoke session
      >= 99.5%.

## 7. Rollout

- [ ] iOS phased rollout: 1% → 10% → 50% → 100% across 7 days.
- [ ] Android staged rollout matching cadence.
- [ ] Status page (`https://status.psyclinicai.com`) live, with a
      rollback runbook linked.
