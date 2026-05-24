# ADR-0001: BYOK (Bring Your Own Key) for Anthropic API

- **Date:** 2026-05-18
- **Status:** Accepted
- **Deciders:** Çağlar Ilhan
- **Supersedes:** —

## Context

PsyClinicAI's core differentiator is an ambient AI co-pilot that turns a live
therapy session into a structured SOAP / DAP / BIRP note. We need a Large
Language Model. The choice is:

1. **Build a server-side LLM gateway.** PsyClinicAI owns the API key, billing
   accumulates centrally, and the LLM call is opaque to the clinician. This
   is what SimplePractice's Care Aide and TherapyNotes' TherapyFuel do.
2. **BYOK — the clinician supplies their own Anthropic key.** The Flutter
   client calls the Anthropic REST API directly with the clinician's key.

We are a solo-founder pilot. We have no Anthropic Enterprise BAA yet. Per-
session inference cost on Claude Haiku 3.5 is ~$0.001, but a popular hosted
EHR could see > 100k sessions / month — that is $100 / month of inference we
would need to either eat or pass through.

## Decision

For the **pilot phase (Sprint 0-6)** we ship **BYOK**:

- Anthropic key stored in `flutter_secure_storage` (OS keychain),
- key sent via `x-api-key` header on each request directly from the browser,
- a settings screen (`/settings/api_keys`) explicitly tells the clinician
  the key never leaves their device,
- a security banner reinforces the same message.

We will reconsider this for the GA phase (Sprint 12+) once we either (a) sign
an Anthropic enterprise BAA, or (b) move inference behind a Cloud Functions
proxy where we can centrally enforce rate limits and audit.

## Consequences

**Pros**

- We are not in the Anthropic per-token billing path during the pilot.
- HIPAA conversation simpler: clinician already has their own AI vendor
  relationship; PsyClinicAI is a "BAA-aligned" facilitator, not an AI
  re-seller. Clinician's existing Anthropic BAA covers the transcript.
- Pricing experiments cleaner: we charge for the practice-management
  features, not per token.

**Cons**

- Onboarding friction: clinician must create an Anthropic account before
  using the AI features. Mitigation: one-click instructions + link to
  `console.anthropic.com`.
- We cannot centrally audit / rate-limit LLM calls in the pilot.
- A misconfigured CORS / dangerous-direct-browser-access header on
  Anthropic's side could break us. We pin `anthropic-version: 2023-06-01`
  and monitor their changelog.

## Alternatives considered

- **Server-side LLM gateway from day one.** Rejected: we would need an
  Anthropic enterprise contract before the first pilot, and we would be on
  the hook for inference cost while the pilot is still free.
- **OpenAI primary.** Rejected: GPT-4 is more expensive per token for this
  workload, and Anthropic's safety posture / longer context window better
  suits clinical text. OpenAI remains an optional secondary provider.

## Links

- `lib/services/copilot/api_key_storage.dart`
- `lib/services/copilot/soap_generator_service.dart`
- `lib/screens/settings/api_keys_screen.dart`
