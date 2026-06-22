# Apple Privacy Nutrition Label — PsyClinicAI

Fill these answers into App Store Connect → App Privacy. Wording
matches Apple's 2026 questionnaire. Every claim cross-references our
DPA + sub-processor list at https://psyclinic.ai/sub-processors.

## Data linked to the user

| Category | Specific types | Purpose |
|---|---|---|
| Contact info | Email, Name (clinician), Phone (optional) | Account management, Customer support |
| Health & Fitness | Patient health records the *clinician* enters (notes, scales, diagnoses, prescriptions) | App functionality (clinical record-keeping) |
| Identifiers | User ID (Firebase Auth uid), Device ID (for MFA + Live Activity) | App functionality, Authentication |
| Usage data | Product interaction (route view, feature use — clinician-only, never patient browsing) | Analytics, Product improvement |
| Diagnostics | Crash data, Performance data | Diagnostics |
| Financial info | Stripe customer id (clinician billing only — no patient payment data) | App functionality |

## Data not linked to the user

| Category | Specific types | Purpose |
|---|---|---|
| Identifiers | Anonymous correlation id for the unauthenticated marketing site only | Analytics |

## Data NOT collected

- Browsing history
- Search history (the in-app command palette runs locally only)
- Audio / video recordings outside an active telehealth session
- Photos / files outside an explicit clinician upload
- Sensors (location, motion) — none

## Data used to track you across other companies' apps and websites

**None.** We do not enable cross-site tracking. We disclose this as
"No tracking" in the questionnaire.

## Sensitive personal information disclosures

Yes — patient health records and diagnoses. Treatment is the lawful
basis under GDPR Art. 9(2)(h); HIPAA permits this as covered-entity
operations. Patient records never enter App Store / Google Play
analytics or crash dumps (redaction at the SDK boundary).
