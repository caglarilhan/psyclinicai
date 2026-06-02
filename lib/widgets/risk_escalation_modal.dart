import 'package:flutter/material.dart';

import '../models/crisis_resource.dart';
import '../services/assessments/phq9_item9_router.dart';
import '../services/assessments/risk_escalation_chain.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';
import 'ds/psy_badge.dart';

/// Auto-modal that fires when a clinical scale (C-SSRS Q3+, PHQ-9
/// item-9) crosses the escalation threshold. Closes the §8 finding
/// from the rapor 09 audit + the healthcare-reviewer note in rapor
/// 12: a positive ideation answer MUST open this surface and let the
/// clinician push the chain forward.
class RiskEscalationModal extends StatelessWidget {
  const RiskEscalationModal({
    super.key,
    required this.trigger,
    required this.chain,
    required this.crisisResources,
    required this.onOpenCssrs,
    required this.onOpenSafetyPlan,
    required this.onAcknowledge,
    this.onClose,
  });

  final Phq9Item9Recommendation trigger;
  final RiskEscalationChain chain;
  final List<CrisisResource> crisisResources;
  final VoidCallback onOpenCssrs;
  final VoidCallback onOpenSafetyPlan;
  final VoidCallback onAcknowledge;
  final VoidCallback? onClose;

  static Future<RiskEscalationChain?> show(
    BuildContext context, {
    required Phq9Item9Recommendation trigger,
    required RiskEscalationChain chain,
    required List<CrisisResource> crisisResources,
    required VoidCallback onOpenCssrs,
    required VoidCallback onOpenSafetyPlan,
    required VoidCallback onAcknowledge,
  }) {
    return showModalBottomSheet<RiskEscalationChain>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: RiskEscalationModal(
          trigger: trigger,
          chain: chain,
          crisisResources: crisisResources,
          onOpenCssrs: onOpenCssrs,
          onOpenSafetyPlan: onOpenSafetyPlan,
          onAcknowledge: onAcknowledge,
          onClose: () => Navigator.of(ctx).pop(chain),
        ),
      ),
    );
  }

  bool get _isCritical =>
      trigger.primaryAction == Phq9Item9Action.showCrisisModal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(PsySpacing.xl, PsySpacing.lg,
            PsySpacing.xl, PsySpacing.xl),
        child: Semantics(
          liveRegion: true,
          container: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(PsySpacing.sm),
                    decoration: BoxDecoration(
                      color: (_isCritical ? cs.error : PsyColors.warning)
                          .withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(PsyRadius.md),
                    ),
                    child: Icon(
                      _isCritical
                          ? Icons.warning_amber_rounded
                          : Icons.shield_outlined,
                      color: _isCritical ? cs.error : PsyColors.warning,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: PsySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCritical
                              ? 'Imminent safety concern detected'
                              : 'Safety planning recommended',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(trigger.reason,
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  PsyBadge(
                    label: trigger.severity.name,
                    tone: _isCritical
                        ? PsyBadgeTone.danger
                        : PsyBadgeTone.warning,
                  ),
                ]),
                const SizedBox(height: PsySpacing.lg),
                Text('Clinical next steps',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: PsySpacing.sm),
                _StepRow(
                  done: chain.state.index >=
                      RiskEscalationState.cssrsAdministered.index,
                  label: 'Administer the C-SSRS now',
                  cta: 'Open C-SSRS',
                  onTap: onOpenCssrs,
                  cs: cs,
                ),
                const SizedBox(height: PsySpacing.xs),
                _StepRow(
                  done: chain.state.index >=
                      RiskEscalationState.safetyPlanDrafted.index,
                  label: 'Draft a Stanley-Brown safety plan',
                  cta: 'Open safety plan',
                  onTap: onOpenSafetyPlan,
                  cs: cs,
                ),
                const SizedBox(height: PsySpacing.xs),
                _StepRow(
                  done: chain.state.index >=
                      RiskEscalationState.clinicianAcknowledged.index,
                  label: 'Acknowledge with your clinician signature',
                  cta: 'Acknowledge',
                  onTap: onAcknowledge,
                  cs: cs,
                ),
                const SizedBox(height: PsySpacing.lg),
                if (crisisResources.isNotEmpty) ...[
                  Text('Region crisis resources',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: PsySpacing.sm),
                  for (final r in crisisResources)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Icon(Icons.support_agent,
                            color: cs.primary, size: 18),
                        const SizedBox(width: PsySpacing.sm),
                        Expanded(child: Text(r.name)),
                        SelectableText(r.displayNumber,
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                color: cs.primary)),
                      ]),
                    ),
                  const SizedBox(height: PsySpacing.lg),
                ],
                Container(
                  padding: const EdgeInsets.all(PsySpacing.md),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(PsyRadius.sm),
                  ),
                  child: Row(children: [
                    Icon(Icons.lock_outline,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(
                      child: Text(
                        'Every action above writes an immutable entry to '
                        'the risk-escalation chain (HIPAA audit). The '
                        'chain cannot be deleted once resolved.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: PsySpacing.lg),
                if (onClose != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onClose,
                      child: const Text('Close'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.done,
    required this.label,
    required this.cta,
    required this.onTap,
    required this.cs,
  });
  final bool done;
  final String label;
  final String cta;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
      ),
      const SizedBox(width: PsySpacing.sm),
      Expanded(child: Text(label)),
      const SizedBox(width: PsySpacing.sm),
      FilledButton.tonal(
        onPressed: done ? null : onTap,
        child: Text(cta),
      ),
    ]);
  }
}
