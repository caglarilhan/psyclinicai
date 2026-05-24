import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/changelog` — public release notes.
class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  static const List<_Release> _releases = [
    _Release(
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
    _Release(
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
    _Release(
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
    _Release(
      version: '0.2.0',
      date: '2026-05-15',
      tag: 'Sprint 2 — Measurement-Based Care',
      bullets: [
        'PHQ-9 (Kroenke 2001) with severity bands + self-harm flag.',
        'GAD-7 (Spitzer 2006) with severity bands.',
        'Assessment screen with one-question-at-a-time flow + severity result card.',
      ],
    ),
    _Release(
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

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Release notes',
      title: 'Changelog',
      lede:
          'Every meaningful change we ship. Older entries are preserved — we '
          'do not edit history.',
      lastUpdated: DateTime(2026, 5, 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _releases.map((r) => _ReleaseCard(release: r)).toList(),
      ),
    );
  }
}

class _Release {
  const _Release({
    required this.version,
    required this.date,
    required this.tag,
    required this.bullets,
  });
  final String version;
  final String date;
  final String tag;
  final List<String> bullets;
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.release});
  final _Release release;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: PsySpacing.xl),
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: PsySpacing.md,
            runSpacing: PsySpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: PsySpacing.md, vertical: PsySpacing.xs),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(PsyRadius.full),
                  border: Border.all(
                      color: cs.primary.withValues(alpha: 0.30)),
                ),
                child: Text(
                  'v${release.version}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                release.date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              Text(
                release.tag,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.lg),
          ...release.bullets.map((b) => StaticBullet(b)),
        ],
      ),
    );
  }
}
