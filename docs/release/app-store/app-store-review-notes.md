# Notes for App Review — PsyClinicAI

App Store Connect → App Review Information → Notes.

## Demo credentials

We provide a sandboxed clinician account that exposes every feature
without touching production data:

```
Email:     demo-clinician@psyclinic.ai
Password:  See "Demo password" secret in 1Password vault
Tenant:    Demo Clinic (read-only patient roster pre-seeded)
```

Patient self-service portal demo:

```
Email:     demo-patient@psyclinic.ai
Magic link: Auto-sent on tap from the Sign-in screen
```

## Why we use sign-in for full review

Clinical record-keeping cannot be reviewed without a clinician
account. The marketing surface (https://psyclinic.ai) shows the
public Trust Center and pricing.

## Why subscriptions are not in-app

Subscriptions are sold to clinics, not individual consumers — billing
is per-seat, invoiced monthly, with Stripe Connect Express handling
clinician payouts in the United States and Mollie SEPA / iDEAL /
SOFORT in the European Union. This is a documented Apple exception
for B2B / enterprise medical software (Apple App Review Guideline
3.1.3(b) — "Multiplatform Services"). No in-app purchase surface
appears anywhere in the app.

## Why we ask for the camera + microphone

Telehealth video sessions only. The clinician must explicitly start a
session; the camera + microphone are released the moment the session
ends. Recording is opt-in per-session with on-screen disclosure.

## Why we ask for notifications

Session reminders, no-show alerts, and incoming patient messages to
the clinician account only. Patient-side notifications are deferred
until the public PWA ships outside the App Store.

## Privacy + HIPAA

Privacy policy: https://psyclinic.ai/privacy
Sub-processors: https://psyclinic.ai/sub-processors
DPA + BAA (PDF): https://psyclinic.ai/dpa, https://psyclinic.ai/baa
Trust Center: https://psyclinic.ai/trust

## Live Activity / Lock Screen disclosure

The session Live Activity displays *no* protected health information
on the lock screen — only an opaque session label, modality
(In-person / Telehealth), clinician display name, and elapsed
timer. We document this in the in-app Live Activity opt-in.

## Why category is Medical

This app supports the clinical workflow of licensed psychiatrists,
psychologists, and therapists. It is not a wellness or self-help
product.
