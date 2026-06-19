import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/roadmap` — public product timeline. Sprint 29 P-09.
///
/// Purpose (change-management persona): pilot clinicians tolerate
/// roughness when they can see the timeline. We publish dated
/// commitments and an explicit "what's not shipping" section so
/// expectations stay calibrated.
class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key});

  static const List<_Milestone> _milestones = [
    _Milestone(
      window: '2026-Q2 (private beta, ≤ 25 pilots)',
      tag: 'Wave A',
      bullets: [
        'Session co-pilot → SOAP / DAP / BIRP draft in 30 s.',
        'PHQ-9, GAD-7, C-SSRS, PCL-5, AUDIT clinical-scale runner.',
        'Superbill (CMS-1500 fields) + Stripe checkout for pilot tier.',
        'Patient portal PWA, kiosk auto-logout, single-use invite tokens.',
        'Trust Center: live infra status, security controls, IR runbook.',
      ],
    ),
    _Milestone(
      window: '2026-07 → 2026-08 (public beta)',
      tag: 'Wave B',
      bullets: [
        'Groq paid tier + per-tenant daily cost cap.',
        'EHR FHIR R4 sandbox connect — Epic, Cerner test endpoints.',
        'Custom domain + StatusPage.io + Sentry release tracking.',
        'Multi-tenant claims via setTenantClaim Cloud Function.',
        'On-device PHI encryption (SQLCipher + biometric-bound keystore).',
      ],
    ),
    _Milestone(
      window: '2026-Q3',
      tag: 'Compliance',
      bullets: [
        'External pentest — Cure53 / NCC engagement (Sep 15).',
        'SOC 2 Type II evidence collection ramps.',
        'KVKK VERBİS registration (Turkey).',
        'GDPR Art. 28 Annex II subprocessor matrix published.',
      ],
    ),
    _Milestone(
      window: '2026-Q4',
      tag: 'Differentiators',
      bullets: [
        'Multi-jurisdiction legal engine — state-by-state alerts.',
        'Group-session co-pilot + supervisor handoff workflow.',
        'Outcome measurement (MBC) trend dashboards.',
        'e-Prescribing (US + EU formularies, region-gated).',
      ],
    ),
    _Milestone(
      window: '2027-Q1 (GA)',
      tag: 'GA',
      bullets: [
        '1.0 release tag.',
        'BAA + DPA template self-service for clinics.',
        'Mobile native apps (iOS + Android) on top of the Flutter codebase.',
      ],
    ),
  ];

  static const List<String> _notShipping = [
    'Direct-to-patient diagnosis or prescribing — clinician-support only.',
    'On-prem deployment in 2026 — managed cloud (Firebase EU + Hetzner EU).',
    'Free tier with real PHI — pilots are a 6-month founder-rate, no anonymous sign-ups.',
    'Audio recording of sessions — STT runs on-device, audio never leaves the room.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StaticPageShell(
      title: 'Roadmap',
      eyebrow: 'Updated every sprint close-out',
      lede:
          'Dated commitments for what we ship, what compliance milestones close, '
          'and what is deliberately out of scope.',
      lastUpdated: DateTime(2026, 6, 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in _milestones)
            _MilestoneCard(milestone: m, colorScheme: cs, theme: theme),
          _NotShippingCard(items: _notShipping, colorScheme: cs, theme: theme),
        ],
      ),
    );
  }
}

class _Milestone {
  const _Milestone({
    required this.window,
    required this.tag,
    required this.bullets,
  });

  final String window;
  final String tag;
  final List<String> bullets;
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.colorScheme,
    required this.theme,
  });

  final _Milestone milestone;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: PsySpacing.md),
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  milestone.tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.sm),
              Expanded(
                child: Text(
                  milestone.window,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final b in milestone.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(child: Text(b, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NotShippingCard extends StatelessWidget {
  const _NotShippingCard({
    required this.items,
    required this.colorScheme,
    required this.theme,
  });

  final List<String> items;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: PsySpacing.md),
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not shipping in 2026',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(child: Text(i, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
