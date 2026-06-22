/// Display widgets for `/treatment_plan` — the diagnosis card,
/// per-goal cards with progress + a tap-to-edit progress dialog,
/// and the two empty states (no plan yet / no goals on the plan).
///
/// All four are stateless beyond the [GoalCard]'s internal
/// progress-edit dialog, which still pops back through the
/// `onUpdate` callback so the screen owns the actual mutation.
///
/// HIGH-4 (audit 2026-06-21): slice A of the
/// treatment_plan_screen.dart split.
library;

import 'package:flutter/material.dart';

import '../../models/treatment_plan_models.dart';
import '../../theme/tokens.dart';

String goalCategoryLabel(GoalCategory c) => switch (c) {
  GoalCategory.symptomReduction => 'Symptom reduction',
  GoalCategory.functionalImprovement => 'Functional',
  GoalCategory.skillDevelopment => 'Skill-building',
  GoalCategory.relationshipImprovement => 'Relationships',
  GoalCategory.medicationCompliance => 'Med adherence',
  GoalCategory.lifestyleChange => 'Lifestyle',
  GoalCategory.crisisPrevention => 'Crisis prevention',
  GoalCategory.other => 'Other',
};

String goalPriorityLabel(GoalPriority p) => switch (p) {
  GoalPriority.critical => 'Critical',
  GoalPriority.high => 'High',
  GoalPriority.medium => 'Medium',
  GoalPriority.low => 'Low',
};

class DiagnosisCard extends StatelessWidget {
  const DiagnosisCard({
    super.key,
    required this.theme,
    required this.cs,
    required this.plan,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final TreatmentPlan plan;

  @override
  Widget build(BuildContext context) {
    final pct = plan.overallProgress.round();
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 18, color: cs.primary),
              const SizedBox(width: PsySpacing.sm),
              Expanded(
                child: Text(
                  plan.primaryDiagnosis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$pct% overall',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: cs.primary.withValues(alpha: 0.12),
              color: cs.primary,
            ),
          ),
          if (plan.clinicalFormulation.isNotEmpty) ...[
            const SizedBox(height: PsySpacing.md),
            Text(
              plan.clinicalFormulation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.theme,
    required this.cs,
    required this.onUpdate,
  });
  final TreatmentGoal goal;
  final ThemeData theme;
  final ColorScheme cs;
  final ValueChanged<int> onUpdate;

  Color get _priorityColor => switch (goal.priority) {
    GoalPriority.critical => const Color(0xFFDC2626),
    GoalPriority.high => const Color(0xFFD97706),
    GoalPriority.medium => cs.primary,
    GoalPriority.low => cs.onSurface.withValues(alpha: 0.5),
  };

  @override
  Widget build(BuildContext context) {
    final met = goal.status == GoalStatus.completed || goal.progress >= 100;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                met ? Icons.check_circle : Icons.flag_outlined,
                size: 18,
                color: met ? const Color(0xFF16A34A) : _priorityColor,
              ),
              const SizedBox(width: PsySpacing.sm),
              Expanded(
                child: Text(
                  goal.description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: met ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Wrap(
            spacing: PsySpacing.sm,
            runSpacing: PsySpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _chip(goalCategoryLabel(goal.category), cs.secondary),
              _chip(goalPriorityLabel(goal.priority), _priorityColor),
              if (goal.measurementMethod != null &&
                  goal.measurementMethod!.isNotEmpty)
                Text(
                  '· ${goal.measurementMethod}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: goal.progress / 100,
                    minHeight: 6,
                    backgroundColor: cs.outlineVariant,
                    color: met ? const Color(0xFF16A34A) : cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Text(
                '${goal.progress}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Update progress',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.tune, size: 18),
                onPressed: () => _editProgress(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: PsySpacing.sm, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(PsyRadius.full),
    ),
    child: Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Future<void> _editProgress(BuildContext context) async {
    var value = goal.progress.toDouble();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Update progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${value.round()}%',
                style: Theme.of(ctx).textTheme.headlineMedium,
              ),
              Slider(
                value: value,
                max: 100,
                divisions: 20,
                label: '${value.round()}%',
                onChanged: (v) => setLocal(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(100),
              child: const Text('Mark met'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(value.round()),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result != null) onUpdate(result);
  }
}

class NoPlanCard extends StatelessWidget {
  const NoPlanCard({
    super.key,
    required this.theme,
    required this.cs,
    required this.onCreate,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 44,
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: PsySpacing.md),
            Text(
              'No treatment plan yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: PsySpacing.xs),
            Text(
              'Capture the diagnosis and formulation, then draft SMART goals.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: PsySpacing.lg),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create treatment plan'),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyGoalsCard extends StatelessWidget {
  const EmptyGoalsCard({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.xl,
        vertical: PsySpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        'No goals yet — add one or draft with AI.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
