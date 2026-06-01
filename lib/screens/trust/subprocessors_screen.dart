import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/trust/subprocessors` — the live GDPR Article 28(2) list.
///
/// Every IT-procurement review begins here. Each row carries the
/// purpose, the data, the location, and a risk classification so
/// reviewers can decide which entries need a deeper dive without
/// leaving the page.
class SubprocessorsScreen extends StatelessWidget {
  const SubprocessorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/trust/subprocessors',
      title: 'Subprocessors',
      subtitle:
          'GDPR Article 28(2) — sub-processors with 30-day change notice.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('Trust Center', '/trust'),
        Crumb('Subprocessors', null),
      ],
      primaryAction: OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Subscribe to subprocessor change notices at legal@psyclinicai.com.'),
          ),
        ),
        icon: const Icon(Icons.notifications_active_outlined, size: 18),
        label: const Text('Subscribe'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PsyCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary, size: 20),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    'We notify customers 30 days before adding or replacing '
                    'any sub-processor. Object during that window without '
                    'penalty.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          for (final s in _subs)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _SubRow(sub: s, theme: theme, cs: cs),
            ),
          const SizedBox(height: PsySpacing.lg),
          Text(
            'Last updated 2026-06-01. SCC (EU Standard Contractual Clauses) '
            'executed with every non-EU sub-processor handling personal data.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({required this.sub, required this.theme, required this.cs});
  final _Sub sub;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(sub.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              PsyBadge(label: sub.risk.label, tone: sub.risk.tone),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          _kv(theme, cs, 'Purpose', sub.purpose),
          _kv(theme, cs, 'Data', sub.data),
          _kv(theme, cs, 'Location', sub.location),
          _kv(theme, cs, 'Transfer mechanism', sub.transfer),
        ],
      ),
    );
  }

  Widget _kv(ThemeData theme, ColorScheme cs, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(k,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                )),
          ),
          Expanded(
            child: Text(v,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.88),
                  height: 1.45,
                )),
          ),
        ],
      ),
    );
  }
}

enum _Risk { low, medium, high }

extension on _Risk {
  String get label => switch (this) {
        _Risk.low => 'Low risk',
        _Risk.medium => 'Medium risk',
        _Risk.high => 'High risk',
      };
  PsyBadgeTone get tone => switch (this) {
        _Risk.low => PsyBadgeTone.success,
        _Risk.medium => PsyBadgeTone.warning,
        _Risk.high => PsyBadgeTone.danger,
      };
}

class _Sub {
  const _Sub({
    required this.name,
    required this.purpose,
    required this.data,
    required this.location,
    required this.transfer,
    required this.risk,
  });
  final String name;
  final String purpose;
  final String data;
  final String location;
  final String transfer;
  final _Risk risk;
}

// Curated list — mirrors the production subprocessors registry.
const _subs = <_Sub>[
  _Sub(
    name: 'Hetzner Online GmbH',
    purpose: 'Primary application + database hosting',
    data: 'All clinical data at rest',
    location: 'Frankfurt, DE (eu-central-1)',
    transfer: 'EU/EEA — no transfer mechanism required',
    risk: _Risk.low,
  ),
  _Sub(
    name: 'Google Firebase (Auth)',
    purpose: 'Authentication, password-reset emails',
    data: 'Email, hashed password, sign-in metadata',
    location: 'EU multi-region',
    transfer: 'EU SCCs in place',
    risk: _Risk.medium,
  ),
  _Sub(
    name: 'Anthropic PBC',
    purpose: 'AI inference — only when clinician supplies BYOK key',
    data: 'Session transcript text (no audio)',
    location: 'US',
    transfer: 'EU SCCs + DPA · BYOK opt-in per workspace',
    risk: _Risk.medium,
  ),
  _Sub(
    name: 'Sentry (Functional Software)',
    purpose: 'Crash + error reporting',
    data: 'Error stack traces, opaque user id · sendDefaultPii=false',
    location: 'US',
    transfer: 'EU SCCs + DPA',
    risk: _Risk.low,
  ),
  _Sub(
    name: 'AWS SES (planned Q3 2026)',
    purpose: 'Transactional email (receipts, password reset)',
    data: 'Email address, message metadata',
    location: 'EU-West-1 (Ireland)',
    transfer: 'EU/EEA — no transfer mechanism required',
    risk: _Risk.low,
  ),
];
