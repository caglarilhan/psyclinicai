/// Status widgets at the top of `/settings/audit_log`:
/// - [ExportTile]: a single bordered InkWell row with icon + label
///   + copy affordance, used twice (CSV + JSON exports).
/// - [IntegrityCard]: append-only · hash-chained · tamper-evident
///   attestation block with 6-year retention badge.
///
/// HIGH-class refactor (audit 2026-06-21): extracted from
/// audit_log_screen.dart so the screen file owns its state machine
/// + audit row rendering only.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/ds/psy_card.dart';

class ExportTile extends StatelessWidget {
  const ExportTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.lg,
            vertical: PsySpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsyRadius.md),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.copy_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class IntegrityCard extends StatelessWidget {
  const IntegrityCard({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    const attestations = [
      _Attest(
        Icons.add_box_outlined,
        'Append-only',
        'No row update or delete is possible — only new entries.',
      ),
      _Attest(
        Icons.link,
        'Hash-chained',
        'Every entry stores SHA-256 of the previous row.',
      ),
      _Attest(
        Icons.fingerprint,
        'Tamper-evident',
        'Any retroactive change invalidates the downstream chain.',
      ),
    ];
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
              Icon(Icons.shield_outlined, color: cs.primary, size: 20),
              const SizedBox(width: PsySpacing.sm),
              Text(
                'Integrity attestation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '6-year retention',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          for (var i = 0; i < attestations.length; i++) ...[
            if (i > 0) const SizedBox(height: PsySpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(attestations[i].icon, size: 16, color: cs.primary),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attestations[i].title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attestations[i].body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Attest {
  const _Attest(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}
