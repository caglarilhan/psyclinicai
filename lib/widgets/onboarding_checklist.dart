import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'ds/psy_badge.dart';
import 'ds/psy_card.dart';

/// Sticky setup checklist for the dashboard — addresses the
/// ux-researcher-designer finding in rapor 12: new clinicians land
/// on an empty roster with no clue what to do first.
class OnboardingChecklistItem {
  const OnboardingChecklistItem({
    required this.id,
    required this.label,
    required this.body,
    required this.icon,
    required this.done,
    required this.onTap,
  });

  final String id;
  final String label;
  final String body;
  final IconData icon;
  final bool done;
  final VoidCallback onTap;
}

class OnboardingChecklist extends StatelessWidget {
  const OnboardingChecklist({
    super.key,
    required this.items,
    this.onDismiss,
  });

  final List<OnboardingChecklistItem> items;
  final VoidCallback? onDismiss;

  int get _doneCount => items.where((i) => i.done).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final allDone = _doneCount == items.length;
    return PsyCard(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.task_alt, color: cs.primary),
            const SizedBox(width: PsySpacing.sm),
            Text('Set up your practice',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: PsySpacing.sm),
            PsyBadge(
              label: '$_doneCount / ${items.length}',
              tone: allDone
                  ? PsyBadgeTone.success
                  : PsyBadgeTone.info,
            ),
            const Spacer(),
            if (onDismiss != null)
              IconButton(
                tooltip: 'Hide checklist',
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
              ),
          ]),
          const SizedBox(height: PsySpacing.sm),
          LinearProgressIndicator(
            value: items.isEmpty ? 0 : _doneCount / items.length,
            minHeight: 4,
            backgroundColor: cs.surfaceContainerHigh,
          ),
          const SizedBox(height: PsySpacing.md),
          for (final item in items) _Row(item: item, cs: cs, theme: theme),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.cs, required this.theme});
  final OnboardingChecklistItem item;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: Row(children: [
        Icon(
          item.done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: item.done
              ? cs.primary
              : cs.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: PsySpacing.sm),
        Icon(item.icon,
            size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: PsySpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: item.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.done
                          ? cs.onSurface.withValues(alpha: 0.5)
                          : cs.onSurface)),
              Text(item.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
        TextButton(
          onPressed: item.done ? null : item.onTap,
          child: Text(item.done ? 'Done' : 'Open'),
        ),
      ]),
    );
  }
}
