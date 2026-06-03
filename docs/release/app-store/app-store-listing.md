# App Store Connect — App Information

**Bundle id:** `ai.psyclinic.app`
**Primary category:** Medical
**Secondary category:** Productivity
**Age rating:** 17+ (Frequent/Intense Medical/Treatment Information)
**Pricing:** Free with in-app purchases (Stripe-billed subscriptions
managed outside the App Store; document for App Review)

## Promotional text (≤170 chars)

> The clinical co-pilot for therapists and psychiatrists. HIPAA + GDPR
> compliant. Notes, scales, scheduling, telehealth — all in one
> private workspace.

## Description (App Store Connect, ≤4000 chars)

PsyClinicAI is the clinical co-pilot built for therapists, psychologists,
and psychiatrists in the United States and the European Union.

We help you do the work that matters — talking to patients — by removing
the friction around everything else.

WHAT YOU GET
• Structured session notes (SOAP / BIRP / DAP) with AI-assisted drafts.
• Validated scales out of the box: PHQ-9, GAD-7, C-SSRS, PCL-5, AUDIT,
  WHO-5. Scoring + automated escalation to safety planning when
  appropriate.
• Treatment plans tied to ICD-10 / DSM-5-TR diagnoses, with measurable
  SMART goals and progress tracking.
• Telehealth video with informed-consent capture and audit-logged
  session metadata.
• Caseload dashboard with no-show prediction, intake queue, and
  superbill / 837P claim generation.
• Patient self-service portal: PROM completion, secure messaging,
  appointment management, GDPR Art. 15 data export.

PRIVACY & SECURITY FIRST
• HIPAA (United States) and GDPR (European Union) compliant.
• SOC 2 Type I evidence binder available on request; Type II in
  progress.
• EU data stays in EU; US data stays in US. No cross-region transfer.
• End-to-end field-level encryption of all patient records.
• Phishing-resistant FIDO2 passkeys + TOTP MFA on every clinician
  account.
• Bring-your-own-key (Anthropic Claude) — your AI runs on your bill
  and your keys, never aggregated with other clinics' prompts.

WHO IT IS FOR
PsyClinicAI is licensed only to licensed clinicians and supervised
trainees. The Patient self-service portal is invite-only and bound to
a treating clinician.

PsyClinicAI is software for clinical decision support. It is not a
medical device. The clinician remains the sole decision-maker for any
diagnosis, treatment plan, or prescription.

CONTACT
Support: support@psyclinic.ai
Privacy: privacy@psyclinic.ai
Trust Center: https://psyclinic.ai/trust

## What's New in This Version (≤4000 chars)

Sprint 26 — Launch readiness:
• WebAuthn / FIDO2 passkey enrolment for clinicians — phishing-
  resistant sign-in across iPhone, iPad, Mac, and the web app.
• Patient self-service portal (preview) — appointments,
  questionnaires, secure inbox, and a Right of Access entry point.
• iOS Lock Screen + Dynamic Island Live Activity during sessions —
  PHI-safe; only an opaque session label and elapsed timer.
• iOS Hand-off — start a session on one device and continue it on
  another with one tap.
• Statuspage-backed public health endpoint.
• Internal: closed the FIDO2 cloning defence (sign-count regression
  auto-revokes the credential), origin / RP-id suffix hardening,
  per-kind email token allow-lists.

## Marketing URL

https://psyclinic.ai

## Support URL

https://psyclinic.ai/support

## Privacy Policy URL

https://psyclinic.ai/privacy

## End-User Licence Agreement (EULA)

We use the standard Apple EULA. The clinician-side terms of service
are accepted in-app on first launch and again at every breaking
change (audit-logged).
