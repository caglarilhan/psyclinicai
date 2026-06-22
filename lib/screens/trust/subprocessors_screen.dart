import 'package:flutter/material.dart';

import '../../models/subprocessor.dart';
import '../../services/compliance/subprocessor_registry.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_snack.dart';

/// `/trust/subprocessors` — the live GDPR Article 28(2) list.
///
/// Reads from [SubprocessorRegistry] so the trust center and procurement
/// review always see exactly the vendors the build was tested against.
/// CI enforces that any vendor addition first lands in the registry and
/// bumps [SubprocessorRegistry.lastReviewed].
class SubprocessorsScreen extends StatelessWidget {
  const SubprocessorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const entries = SubprocessorRegistry.entries;
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
        onPressed: () => PsySnack.info(
          context,
          'Subscribe to subprocessor change notices at legal@psyclinicai.com.',
          hint: 'trust.subprocessors_subscribe',
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
                const SizedBox(width: PsySpacing.sm),
                PsyBadge(label: '${entries.length} vendors'),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          for (final s in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _SubRow(sub: s, theme: theme, cs: cs),
            ),
          const SizedBox(height: PsySpacing.lg),
          Text(
            'Last reviewed ${SubprocessorRegistry.lastReviewed}. SCC (EU '
            'Standard Contractual Clauses) executed with every non-EU '
            'sub-processor handling personal data.',
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
  final Subprocessor sub;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.lg,
        vertical: PsySpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sub.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PsyBadge(label: _riskLabel(sub.risk), tone: _riskTone(sub.risk)),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          _kv(theme, cs, 'Purpose', sub.purpose),
          _kv(theme, cs, 'Data', sub.data),
          _kv(theme, cs, 'Location', sub.location),
          _kv(theme, cs, 'Transfer mechanism', sub.transferMechanism),
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
            child: Text(
              k,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.88),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _riskLabel(SubprocessorRisk r) => switch (r) {
  SubprocessorRisk.low => 'Low risk',
  SubprocessorRisk.medium => 'Medium risk',
  SubprocessorRisk.high => 'High risk',
};

PsyBadgeTone _riskTone(SubprocessorRisk r) => switch (r) {
  SubprocessorRisk.low => PsyBadgeTone.success,
  SubprocessorRisk.medium => PsyBadgeTone.warning,
  SubprocessorRisk.high => PsyBadgeTone.danger,
};
