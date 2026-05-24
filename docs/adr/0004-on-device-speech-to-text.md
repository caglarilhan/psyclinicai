# ADR-0004: On-device speech-to-text (no cloud STT)

- **Date:** 2026-05-19
- **Status:** Accepted

## Context

The AI co-pilot needs a continuous speech-to-text feed during a live therapy
session. Options:

1. **Cloud STT** (Whisper API, Google Cloud Speech-to-Text, AssemblyAI):
   highest accuracy, but every second of audio leaves the device and travels
   to a third-party vendor. Cost ~$0.024 / minute (Google) to ~$0.006 /
   minute (Whisper).
2. **On-device STT** (Apple Speech framework, Android SpeechRecognizer,
   Web Speech API): zero cost, audio never leaves the device, but accuracy
   is lower especially on accented English and non-English locales.

## Decision

**On-device STT via the `speech_to_text` Flutter package.** Default for
Sprint 0-6.

A cloud STT fallback may be added behind a feature flag (`ff.cloudStt`) for
clinicians who explicitly opt in to higher accuracy and accept the data-flow
implications.

## Consequences

**Pros**

- **HIPAA / GDPR posture dramatically simpler**: PsyClinicAI never sees raw
  audio, so there is nothing to lose if our servers are breached.
- $0 marginal cost per session.
- Works offline.

**Cons**

- Accuracy lower than Whisper on non-English locales; mitigated by the AI
  prompt explicitly telling Claude to handle ASR errors.
- Web Speech API quality varies by browser (Chrome best, Safari unstable).
  We surface a "supported locales" check in the UI and recommend Chrome.
- Microphone permission has to be granted per session.

## Alternatives considered

- **Whisper API via Anthropic / OpenAI proxy.** Rejected for the same reason
  as ADR-0001: we would need to either run a server-side proxy (more code,
  more compliance surface) or expose another BYOK provider.
- **Local Whisper.cpp WASM.** Considered. Bundle size > 100 MB makes the
  web build untenable. Revisit when distributing a native desktop app.

## Links

- `lib/services/copilot/transcription_service.dart`
- `pubspec.yaml` (`speech_to_text: ^7.3.0`)
