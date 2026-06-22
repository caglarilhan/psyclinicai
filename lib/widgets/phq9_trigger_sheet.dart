import 'package:flutter/material.dart';

import '../models/crisis_resource.dart';
import '../services/assessments/phq9_item9_router.dart';
import '../services/crisis/crisis_resource_registry.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// Bottom sheet surfaced after a PHQ-9 submission when the item-9
/// router returns anything other than `Phq9Item9Action.none`.
///
/// The clinician sees the recommended action chain (open C-SSRS,
/// safety plan, crisis modal), the patient-friendly reason, and
/// region-aware crisis hotlines pulled from
/// `crisis_resource_registry.dart`.
class Phq9TriggerSheet extends StatelessWidget {
  const Phq9TriggerSheet({
    super.key,
    required this.recommendation,
    this.locale,
    this.onOpenCssrs,
    this.onOpenSafetyPlan,
    this.onShowCrisisModal,
    this.onDocument,
  });

  final Phq9Item9Recommendation recommendation;
  final Locale? locale;

  final VoidCallback? onOpenCssrs;
  final VoidCallback? onOpenSafetyPlan;
  final VoidCallback? onShowCrisisModal;
  final VoidCallback? onDocument;

  /// Convenience presenter — opens the sheet with a single call.
  static Future<void> show(
    BuildContext context, {
    required Phq9Item9Recommendation recommendation,
    Locale? locale,
    VoidCallback? onOpenCssrs,
    VoidCallback? onOpenSafetyPlan,
    VoidCallback? onShowCrisisModal,
    VoidCallback? onDocument,
  }) async {
    if (recommendation.primaryAction == Phq9Item9Action.none) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Phq9TriggerSheet(
        recommendation: recommendation,
        locale: locale,
        onOpenCssrs: onOpenCssrs,
        onOpenSafetyPlan: onOpenSafetyPlan,
        onShowCrisisModal: onShowCrisisModal,
        onDocument: onDocument,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final resources = CrisisResourceRegistry.forLocale(locale);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: PsyColors.warning,
                ),
                const SizedBox(width: PsySpacing.sm),
                Expanded(
                  child: Text(
                    'PHQ-9 item 9 flagged',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.sm),
            Text(recommendation.reason, style: t.bodyMedium),
            const SizedBox(height: PsySpacing.md),
            _ActionList(
              recommendation: recommendation,
              onOpenCssrs: onOpenCssrs,
              onOpenSafetyPlan: onOpenSafetyPlan,
              onShowCrisisModal: onShowCrisisModal,
            ),
            const SizedBox(height: PsySpacing.md),
            Text('Crisis resources', style: t.titleSmall),
            const SizedBox(height: PsySpacing.xs),
            for (final r in resources.take(4))
              _ResourceRow(resource: r, foreground: cs.onSurfaceVariant),
            const SizedBox(height: PsySpacing.md),
            FilledButton.tonalIcon(
              onPressed: onDocument,
              icon: const Icon(Icons.edit_note),
              label: const Text('Document the decision'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList({
    required this.recommendation,
    required this.onOpenCssrs,
    required this.onOpenSafetyPlan,
    required this.onShowCrisisModal,
  });

  final Phq9Item9Recommendation recommendation;
  final VoidCallback? onOpenCssrs;
  final VoidCallback? onOpenSafetyPlan;
  final VoidCallback? onShowCrisisModal;

  @override
  Widget build(BuildContext context) {
    final actions = <Phq9Item9Action>[
      recommendation.primaryAction,
      ...recommendation.secondaryActions,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final a in actions)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.xs),
            child: _actionButton(context, a),
          ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, Phq9Item9Action a) {
    switch (a) {
      case Phq9Item9Action.openCssrs:
        return FilledButton.icon(
          onPressed: onOpenCssrs,
          icon: const Icon(Icons.psychology_alt),
          label: const Text('Open C-SSRS'),
        );
      case Phq9Item9Action.openSafetyPlan:
        return OutlinedButton.icon(
          onPressed: onOpenSafetyPlan,
          icon: const Icon(Icons.shield_outlined),
          label: const Text('Open safety plan'),
        );
      case Phq9Item9Action.showCrisisModal:
        return FilledButton.icon(
          onPressed: onShowCrisisModal,
          icon: const Icon(Icons.emergency_outlined),
          label: const Text('Show crisis resources'),
        );
      case Phq9Item9Action.none:
        return const SizedBox.shrink();
    }
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource, required this.foreground});
  final CrisisResource resource;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.phone_in_talk_outlined, size: 16),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Text(
              '${resource.name} · ${resource.displayNumber}',
              style: t.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
