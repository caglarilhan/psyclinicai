# iOS launch prep — TestFlight → App Store

**Target Sprint:** 32 P1 + carry to Sprint 33 (Apple Dev account dependent)
**Owner:** senior-frontend + apple-hig-expert + healthcare-phi-compliance
**Status:** Info.plist + privacy disclosures shipped; Apple Developer enrollment + provisioning profile remain a founder action.

The Flutter codebase already builds for iOS via `flutter build ios --release`. The blockers are administrative (Apple), not technical. This doc lists every Apple-side checkbox between today and a TestFlight invite to the first five pilots.

---

## 1. Apple Developer Program enrollment (founder action, 24–48 h)

- [ ] Enroll the Wave A operating entity at https://developer.apple.com/programs/enroll/ ($99/yr).
- [ ] Choose the *Organization* tier — gives BAA + DUNS visibility for hospital procurement.
- [ ] Verify D-U-N-S number (Dun & Bradstreet); takes 24–48 h.
- [ ] Two-factor authentication mandatory on the Apple ID — use the founder phone + hardware key.
- [ ] Add the second engineer as a developer-tier team member when onboard.

## 2. App Store Connect record (10 min after enrolment)

- [ ] App name: `PsyClinicAI` (already reserved as a placeholder).
- [ ] Bundle id: `com.psyclinicai.app` (matches `ios/Runner/Info.plist:CFBundleIdentifier`).
- [ ] Primary language: English (US).
- [ ] Category — Primary: **Medical**. Secondary: **Productivity**.
- [ ] Subtitle (30 chars): "AI co-pilot for therapists".
- [ ] Promotional text (170 chars): "Cut session notes from 90 minutes to 5. On-device transcription. BYOK Claude. HIPAA + GDPR. EU residency by default."
- [ ] Support URL: https://psyclinicai.com/contact
- [ ] Marketing URL: https://psyclinicai.com/
- [ ] Privacy Policy URL: https://psyclinicai.com/privacy (required for Medical apps).

## 3. App Privacy disclosures (App Store Connect → App Privacy)

The Info.plist usage descriptions cover the iOS *runtime* prompts. App Store Connect separately asks "what data does your app collect?". Answers below match what the code actually does:

| Question | Answer | Linked to identity? | Used for tracking? |
|---|---|---|---|
| Health & Fitness (Mental health) | Yes — PHQ-9, GAD-7 scores | Yes | No |
| Contact Info — Email Address | Yes — clinician sign-up | Yes | No |
| Contact Info — Phone Number | Yes — patient intake (optional) | Yes | No |
| Contact Info — Physical Address | No | — | — |
| Health & Fitness — Audio Data | No (on-device only, never collected) | — | — |
| Health & Fitness — Photos or Videos | No | — | — |
| Identifiers — User ID | Yes — Firebase Auth uid | Yes | No |
| Diagnostics — Crash Data | Yes (Sentry, redacted) | No | No |
| Diagnostics — Performance Data | Yes (Sentry traces, no PHI) | No | No |
| Usage Data — Product Interaction | Yes (PostHog funnel events) | No | No |

Tracking declaration: **No** — we do not use `AppTrackingTransparency` because we do not run cross-app advertising.

## 4. HealthKit entitlement + capability

When the Apple Developer enrolment clears:

- [ ] Xcode → Signing & Capabilities → **+ Capability → HealthKit**.
- [ ] Enable *Clinical Health Records* = **No** (we only read PROM scores, not EHR data via HealthKit).
- [ ] Add data-type identifiers in `ios/Runner/Runner.entitlements` once we have the provisioning profile.

## 5. TestFlight prerequisites

- [ ] App icon set (1024×1024 master) — Sprint 30 polish row.
- [ ] Launch screen (LaunchScreen.storyboard) — already shipped.
- [ ] Demo account credentials for App Review — create `appreview@psyclinicai.com` with a seeded patient.
- [ ] Demo notes for App Review — paste of the manual session walkthrough so the reviewer reaches `first_soap_generated` in under 3 minutes.
- [ ] Test information page covering: "this is a clinician-facing app; reviewer must use the demo account".

## 6. Reviewer notes (paste into App Store Connect)

```
PsyClinicAI is a clinical co-pilot for licensed therapists and psychiatrists.
It is not intended for direct patient use.

Demo account:
  email:    appreview@psyclinicai.com
  password: see App Review Notes
  pilot:    pre-seeded as 'Pilot Reviewer'

End-to-end demo path:
  1. Sign in.
  2. Tap any patient → Start Session.
  3. Paste the supplied transcript (in Test Information).
  4. Co-pilot drafts a SOAP note.
  5. Tap Sign + Export to write the audit chain + PDF.

PHI handling:
  - Audio is transcribed on-device via Apple Speech.
  - Transcripts are sent over TLS 1.3 to our EU Cloud Functions
    (europe-west1) only after the clinician taps "Generate".
  - We hold a BAA + EU GDPR Article 28 DPA on file.

Trust Center: https://psyclinicai.com/trust
Privacy: https://psyclinicai.com/privacy
Security incident: security@psyclinicai.com
```

## 7. Carrier rules (per Apple guidelines we're flagged against)

- **HIPAA / GDPR**: We are HIPAA-aligned + GDPR Article 28 DPA available. Mention BAA-on-request in App Review notes; Apple flags Medical apps without it.
- **Healthcare guidance**: App Store Review Guideline 1.4.1 requires accurate medical info — we cite NICE / APA / DSM-5 + display "not a diagnosis" disclaimers in the AI output.
- **In-App Purchase**: clinician subscriptions are sold via Stripe outside the app. We do NOT use IAP — make this explicit in App Review notes per Guideline 3.1.3(b) (Reader app exception for healthcare professional services).

## 8. Post-launch monitoring

- [ ] Sentry release tagged with iOS build number.
- [ ] Crash-free user metric ≥ 99.5 % alert in Sentry → Slack `#incidents`.
- [ ] App Store Connect crash dashboard cross-checked weekly.
- [ ] TestFlight feedback inbox routed to `support@psyclinicai.com`.

## 9. Apple-side timeline (founder)

| Day | Action |
|---|---|
| **D1** | Apple Developer enrolment submit; D-U-N-S verify |
| **D2** | App Store Connect record + bundle id + privacy disclosures |
| **D3** | Engineer adds Capabilities + Provisioning Profile + first TestFlight build |
| **D4-5** | TestFlight Internal review (~24 h) |
| **D6** | TestFlight invite first 5 pilot iOS testers |
| **D14** | App Store Review submission |
| **D17-20** | Apple review (24–48 h typical) → live |
