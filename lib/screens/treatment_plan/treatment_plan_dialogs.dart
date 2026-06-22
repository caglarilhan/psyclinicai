/// Dialogs that drive the `/treatment_plan` write path:
/// - [CreatePlanDialog]: minimal new-plan form (diagnosis +
///   formulation), pops a `(dx, formulation)` record back through
///   Navigator.pop.
/// - [GoalDraftInput]: value object the SMART goal dialog pops back
///   so the screen can persist the goal + a notes-formatted SMART
///   markdown block.
/// - [AddGoalDialog]: full SMART form (Specific, Measurable —
///   baseline + target —, Achievable, Relevant, Time-bound,
///   category + priority) used by both manual goal entry and the
///   AI-drafted flow.
///
/// HIGH-4 (audit 2026-06-21): slice C of the
/// treatment_plan_screen.dart split. After this slice the screen
/// file owns its state machine + label switch + render only;
/// every dialog body lives outside it.
library;

import 'package:flutter/material.dart';

import '../../models/treatment_plan_models.dart';
import '../../theme/tokens.dart';
import '../../utils/smart_goal_notes.dart';
import 'treatment_plan_cards.dart';

class CreatePlanDialog extends StatefulWidget {
  const CreatePlanDialog({super.key});
  @override
  State<CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends State<CreatePlanDialog> {
  final _dx = TextEditingController();
  final _formulation = TextEditingController();

  @override
  void dispose() {
    _dx.dispose();
    _formulation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New treatment plan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _dx,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Primary diagnosis (e.g. MDD, F32.1)',
              ),
            ),
            const SizedBox(height: PsySpacing.md),
            TextField(
              controller: _formulation,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Clinical formulation',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _dx.text.trim().isEmpty
              ? null
              : () => Navigator.of(
                  context,
                ).pop((_dx.text.trim(), _formulation.text.trim())),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class GoalDraftInput {
  GoalDraftInput({
    required this.description,
    required this.category,
    required this.priority,
    required this.measurement,
    required this.targetWeeks,
    this.baseline = '',
    this.targetValue = '',
    this.achievability = '',
    this.relevance = '',
  });

  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final String measurement;
  final int targetWeeks;

  /// Where the patient is starting from (e.g. "PHQ-9 = 18, no exercise").
  final String baseline;

  /// What "achieved" looks like in concrete terms (e.g. "PHQ-9 ≤ 9, walk
  /// 30 min × 3 / week").
  final String targetValue;

  /// One-line check that the goal is realistic given the patient's
  /// resources, support, and stage of change.
  final String achievability;

  /// Why this goal matters to the patient's diagnosis or stated values.
  final String relevance;

  /// SMART markdown stored on [TreatmentGoal.notes]. Delegates to
  /// [formatSmartGoalNotes] so the formatting rule has a single test point.
  String toNotesMarkdown() => formatSmartGoalNotes(
    baseline: baseline,
    target: targetValue,
    achievability: achievability,
    relevance: relevance,
  );
}

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});
  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _desc = TextEditingController();
  final _measure = TextEditingController();
  final _baseline = TextEditingController();
  final _target = TextEditingController();
  final _achievable = TextEditingController();
  final _relevant = TextEditingController();
  GoalCategory _cat = GoalCategory.symptomReduction;
  GoalPriority _pri = GoalPriority.medium;
  int _weeks = 12;

  @override
  void dispose() {
    _desc.dispose();
    _measure.dispose();
    _baseline.dispose();
    _target.dispose();
    _achievable.dispose();
    _relevant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PsyRadius.lg),
      ),
      insetPadding: const EdgeInsets.all(PsySpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(PsySpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_outlined, color: cs.primary),
                  const SizedBox(width: PsySpacing.sm),
                  Expanded(
                    child: Text(
                      'Add a SMART goal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PsySpacing.xs),
              Text(
                'Specific · Measurable · Achievable · Relevant · Time-bound.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _smartHeader(theme, 'S', 'Specific'),
                      TextField(
                        controller: _desc,
                        onChanged: (_) => setState(() {}),
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Concrete behaviour the patient will change.',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: PsySpacing.md),
                      _smartHeader(theme, 'M', 'Measurable'),
                      TextField(
                        controller: _measure,
                        decoration: const InputDecoration(
                          hintText:
                              'How will progress be measured? (e.g. PHQ-9)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: PsySpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _baseline,
                              decoration: const InputDecoration(
                                labelText: 'Baseline',
                                hintText: 'PHQ-9 = 18',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: PsySpacing.sm),
                          Expanded(
                            child: TextField(
                              controller: _target,
                              decoration: const InputDecoration(
                                labelText: 'Target',
                                hintText: 'PHQ-9 ≤ 9',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: PsySpacing.md),
                      _smartHeader(theme, 'A', 'Achievable'),
                      TextField(
                        controller: _achievable,
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText:
                              'Is this realistic given the patient\'s '
                              'resources and stage of change?',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: PsySpacing.md),
                      _smartHeader(theme, 'R', 'Relevant'),
                      TextField(
                        controller: _relevant,
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText:
                              'Why does this matter to the patient '
                              'and their diagnosis?',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: PsySpacing.md),
                      _smartHeader(theme, 'T', 'Time-bound'),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _weeks.toDouble(),
                              min: 1,
                              max: 52,
                              divisions: 51,
                              label: '$_weeks wk',
                              onChanged: (v) =>
                                  setState(() => _weeks = v.round()),
                            ),
                          ),
                          SizedBox(
                            width: 64,
                            child: Text(
                              '$_weeks wk',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: PsySpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<GoalCategory>(
                              initialValue: _cat,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: GoalCategory.values
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(goalCategoryLabel(c)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _cat = v ?? _cat),
                            ),
                          ),
                          const SizedBox(width: PsySpacing.sm),
                          Expanded(
                            child: DropdownButtonFormField<GoalPriority>(
                              initialValue: _pri,
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: GoalPriority.values
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(goalPriorityLabel(p)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _pri = v ?? _pri),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PsySpacing.lg),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _desc.text.trim().isEmpty
                        ? null
                        : () => Navigator.of(context).pop(
                            GoalDraftInput(
                              description: _desc.text.trim(),
                              category: _cat,
                              priority: _pri,
                              measurement: _measure.text.trim(),
                              targetWeeks: _weeks,
                              baseline: _baseline.text,
                              targetValue: _target.text,
                              achievability: _achievable.text,
                              relevance: _relevant.text,
                            ),
                          ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smartHeader(ThemeData theme, String letter, String label) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.xs),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsyRadius.sm),
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: PsySpacing.sm),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
