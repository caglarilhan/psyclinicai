import 'package:flutter/material.dart';

import '../models/differential_candidate.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// One card per DSM-5 differential candidate (plan §23).
///
/// Surfaces the AI's structured output (code, confidence, criteria
/// matrix) **and** the sticky clinician-owns-the-diagnosis disclaimer.
/// Designed to live inside a vertically scrolling list on
/// `ai_diagnosis_screen.dart`.
class DifferentialCandidateCard extends StatelessWidget {
  const DifferentialCandidateCard({
    super.key,
    required this.candidate,
    this.onAcceptPrimary,
    this.onAddToDifferential,
    this.onReject,
  });

  final DifferentialCandidate candidate;
  final VoidCallback? onAcceptPrimary;
  final VoidCallback? onAddToDifferential;
  final VoidCallback? onReject;

  Color _bandColor(ConfidenceBand b) {
    switch (b) {
      case ConfidenceBand.low:
        return PsyColors.warning;
      case ConfidenceBand.moderate:
        return PsyColors.info;
      case ConfidenceBand.high:
        return PsyColors.success;
      case ConfidenceBand.veryHigh:
        return PsyColors.primary;
    }
  }

  String _bandLabel(ConfidenceBand b) {
    switch (b) {
      case ConfidenceBand.low:
        return 'low confidence';
      case ConfidenceBand.moderate:
        return 'moderate';
      case ConfidenceBand.high:
        return 'high';
      case ConfidenceBand.veryHigh:
        return 'very high';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final band = candidate.band;
    final color = _bandColor(band);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PsySpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(candidate.code, style: t.labelLarge),
                ),
                const SizedBox(width: PsySpacing.sm),
                Expanded(
                  child: Text(candidate.name, style: t.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.sm),
            _ConfidenceBar(
              value: candidate.confidence,
              color: color,
              label:
                  '${(candidate.confidence * 100).toStringAsFixed(0)}% · '
                  '${_bandLabel(band)}',
            ),
            const SizedBox(height: PsySpacing.md),
            if (candidate.criteriaMet.isNotEmpty)
              _CriteriaList(
                title: 'Criteria met',
                icon: Icons.check_circle_outline,
                color: PsyColors.success,
                items: candidate.criteriaMet,
              ),
            if (candidate.criteriaMissing.isNotEmpty)
              _CriteriaList(
                title: 'Still to clarify',
                icon: Icons.help_outline,
                color: PsyColors.warning,
                items: candidate.criteriaMissing,
              ),
            if (candidate.differentialFrom.isNotEmpty) ...[
              const SizedBox(height: PsySpacing.sm),
              Text(
                'Rule out: ${candidate.differentialFrom.join(' · ')}',
                style: t.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: PsySpacing.md),
            Wrap(
              spacing: PsySpacing.sm,
              runSpacing: PsySpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: onAcceptPrimary,
                  icon: const Icon(Icons.bookmark_added_outlined),
                  label: const Text('Accept as primary'),
                ),
                OutlinedButton.icon(
                  onPressed: onAddToDifferential,
                  icon: const Icon(Icons.add),
                  label: const Text('Add to differential'),
                ),
                TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.sm),
            _DisclaimerStrip(
              cs: cs,
              t: t,
              text:
                  'Decision support only. The clinician owns the '
                  'final diagnosis.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({
    required this.value,
    required this.color,
    required this.label,
  });
  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: t.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

class _CriteriaList extends StatelessWidget {
  const _CriteriaList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: PsySpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.labelMedium),
          const SizedBox(height: 4),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Expanded(child: Text(i, style: t.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DisclaimerStrip extends StatelessWidget {
  const _DisclaimerStrip({
    required this.cs,
    required this.t,
    required this.text,
  });
  final ColorScheme cs;
  final TextTheme t;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.sm),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 16, color: cs.onTertiaryContainer),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: t.bodySmall?.copyWith(color: cs.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
