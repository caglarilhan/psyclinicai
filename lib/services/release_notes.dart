/// Canonical release-note ledger. One source of truth for both the
/// public `/changelog` page and the in-app "What's new" sheet.
///
/// Every meaningful release ships an entry here, newest first. The
/// in-app sheet pops on the next sign-in whenever
/// `currentVersion != lastSeenVersion`; the public page renders the
/// full history.
library;

class Release {
  const Release({
    required this.version,
    required this.date,
    required this.tag,
    required this.bullets,
  });

  /// Semver string, e.g. `0.6.0`.
  final String version;

  /// ISO date, e.g. `2026-06-24`.
  final String date;

  /// One-line label that sits next to the version pill.
  final String tag;

  /// Bulleted change list.
  final List<String> bullets;
}

class ReleaseNotes {
  ReleaseNotes._();

  /// Releases newest first. Always keep [latest] in sync — the
  /// in-app sheet reads `releases.first`.
  static const List<Release> releases = <Release>[
    Release(
      version: '0.7.0',
      date: '2026-06-24',
      tag: 'Interop + risk leadership + URL pseudonymization',
      bullets: [
        'HL7 FHIR R4 Patient + Observation (PHQ-9 LOINC 44249-1, GAD-7 LOINC 69737-5) + Bundle serializer — the foundation for EHR sync and DSAR interop bundles.',
        'Risk signal coverage: persistent ledger + per-category aggregate + leadership panel at /admin/risk_coverage with inline Acknowledge.',
        'Cmd+K / Ctrl+K command palette wired across every screen — 15 destinations including audit log, risk coverage, API keys, changelog.',
        'In-app system status banner — degraded Anthropic / Firestore / Stripe / email surfaces a colour-coded ribbon on every screen.',
        'PatientSlug helper (HIPAA §164.514) — 12-char Crockford-lite pseudonymized slug ready to replace raw Firestore doc ids in URLs.',
        'TimeFormat canonical helpers (ISO UTC, relative, day) adopted across patient list/detail, risk coverage, portal modality history.',
      ],
    ),
    Release(
      version: '0.6.0',
      date: '2026-06-24',
      tag: 'Clinical safety + immutable audit',
      bullets: [
        'AI decision-support disclaimer wired across every copilot surface — SOAP draft, supervision report, clinical lens, treatment goals, session insights.',
        'Append-only audit log with SHA-256 hash chain (HIPAA §164.312(b)) — every PHI access leaves a tamper-evident row.',
        'Patient list: 250 ms search debounce + 50-item page cap with "Load more" for caseloads above 50.',
        'Brand logo refresh — mint gear-in-head on login + sidebar.',
        'Reusable AiDisclaimer widget (compact / full / footer) with surface-id telemetry coverage audit.',
      ],
    ),
    Release(
      version: '0.5.0',
      date: '2026-05-23',
      tag: 'Design system + static pages',
      bullets: [
        'Brand palette (deep teal + indigo), Inter typography, motion/spacing tokens.',
        'PsyTheme.light / PsyTheme.dark factories — single source of truth.',
        'Static pages: /security, /about, /changelog, /status.',
        'Landing hero now shows a 3-panel animated browser mockup.',
        'Hover lift on feature + pricing cards. Watch Demo modal replaces snackbar.',
      ],
    ),
    Release(
      version: '0.4.0',
      date: '2026-05-22',
      tag: 'Sprint 3 backend',
      bullets: [
        'Firestore schema + multi-tenant security rules.',
        'Repositories: patient / session / assessment / superbill.',
        'Real Firebase Auth (sign-in, sign-up with role, password reset).',
        'Session note → SOAP save to Firestore. Superbill PDF + persist. PHQ-9 / GAD-7 save.',
        'Graceful degradation: app keeps running in demo mode until firebase_options.dart is configured.',
      ],
    ),
    Release(
      version: '0.3.0',
      date: '2026-05-21',
      tag: 'Landing v2 + enterprise foundation',
      bullets: [
        '13-section modular landing (built-for, problem, gallery, comparison, FAQ, pricing).',
        'analysis_options.yaml strict-casts + strict-inference enabled.',
        'README + ARCHITECTURE + CONTRIBUTING + SECURITY + 5 ADRs.',
        '3-job CI pipeline (analyze + test + build with bundle budget).',
      ],
    ),
    Release(
      version: '0.2.0',
      date: '2026-05-15',
      tag: 'Sprint 2 — Measurement-Based Care',
      bullets: [
        'PHQ-9 (Kroenke 2001) with severity bands + self-harm flag.',
        'GAD-7 (Spitzer 2006) with severity bands.',
        'Assessment screen with one-question-at-a-time flow + severity result card.',
      ],
    ),
    Release(
      version: '0.1.0',
      date: '2026-05-10',
      tag: 'Sprint 0–1 — AI Co-Pilot + Superbill',
      bullets: [
        'BYOK Anthropic Claude key storage + Settings screen.',
        'On-device transcription (speech_to_text). No audio ever leaves the device.',
        'Live AI panel: 5-state machine, SOAP / DAP / BIRP generation.',
        'Superbill PDF generator — 12 CPT codes, 35 ICD-10, CMS-1500 aligned.',
      ],
    ),
  ];

  /// Most recent release — what the in-app sheet shows.
  static Release get latest => releases.first;
}
