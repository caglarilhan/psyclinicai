import 'package:flutter/material.dart';

import '../../models/treatment_plan_models.dart';
import '../../services/copilot/treatment_plan_ai_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/treatment_plan_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;

/// `/treatment_plan` — the Golden Thread: a patient's diagnosis → SMART goals
/// → progress, all in one auditable plan. Goals can be AI-drafted (BYOK) and
/// are surfaced into the live session so notes tie back to the plan.
class TreatmentPlanScreen extends StatefulWidget {
  const TreatmentPlanScreen({super.key, required this.args});
  final PatientDetailArgs args;

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  final _svc = TreatmentPlanService();
  final _ai = TreatmentPlanAiService();
  bool _loading = true;
  bool _busy = false;
  TreatmentPlan? _plan;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _ai.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _svc.initialize();
    _plan = _svc.getTreatmentPlanForPatient(widget.args.id);
    if (mounted) setState(() => _loading = false);
  }

  void _reload() {
    _plan = _svc.getTreatmentPlanForPatient(widget.args.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/patients',
      title: 'Treatment plan',
      subtitle: '${widget.args.name} · diagnosis → goals → progress',
      breadcrumbs: [
        const Crumb('Home', '/dashboard'),
        const Crumb('Patients', '/patients'),
        Crumb(widget.args.name, null),
        const Crumb('Treatment plan', null),
      ],
      primaryAction: (_plan == null || _busy)
          ? null
          : FilledButton.icon(
              onPressed: _addGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add goal'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
              ),
            ),
      scrollable: true,
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()))
          : _plan == null
              ? _NoPlan(theme: theme, cs: cs, onCreate: _createPlanDialog)
              : _planView(theme, cs, _plan!),
    );
  }

  Widget _planView(ThemeData theme, ColorScheme cs, TreatmentPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DiagnosisCard(theme: theme, cs: cs, plan: plan),
        const SizedBox(height: PsySpacing.xl),
        Row(
          children: [
            Text('Goals (${plan.goals.length})',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _busy ? null : _draftWithAi,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_busy ? 'Drafting…' : 'Draft goals with AI'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.md),
        if (plan.goals.isEmpty)
          _EmptyGoals(theme: theme, cs: cs)
        else
          ...plan.goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: PsySpacing.md),
                child: _GoalCard(
                  goal: g,
                  theme: theme,
                  cs: cs,
                  onUpdate: (p) => _updateProgress(g, p),
                ),
              )),
      ],
    );
  }

  // --- actions -------------------------------------------------------------

  Future<void> _createPlanDialog() async {
    final res = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _CreatePlanDialog(),
    );
    if (res == null) return;
    final clinicianId =
        FirebaseAuthService.instance.profile?.userId ?? 'demo_clinician';
    await _svc.createTreatmentPlan(
      patientId: widget.args.id,
      clinicianId: clinicianId,
      primaryDiagnosis: res.$1,
      clinicalFormulation: res.$2,
    );
    _reload();
  }

  Future<void> _addGoalDialog() async {
    final res = await showDialog<_GoalDraftInput>(
      context: context,
      builder: (_) => const _AddGoalDialog(),
    );
    if (res == null || _plan == null) return;
    await _svc.addTreatmentGoal(
      treatmentPlanId: _plan!.id,
      description: res.description,
      category: res.category,
      priority: res.priority,
      targetDate: DateTime.now().add(Duration(days: res.targetWeeks * 7)),
      measurementMethod: res.measurement,
    );
    _reload();
  }

  Future<void> _draftWithAi() async {
    if (_plan == null) return;
    setState(() => _busy = true);
    try {
      final drafts = await _ai.draftGoals(
        diagnosis: _plan!.primaryDiagnosis,
        formulation: _plan!.clinicalFormulation,
      );
      for (final d in drafts) {
        await _svc.addTreatmentGoal(
          treatmentPlanId: _plan!.id,
          description: d.description,
          category: d.category,
          priority: d.priority,
          targetDate: DateTime.now().add(Duration(days: d.targetWeeks * 7)),
          measurementMethod: d.measurement,
        );
      }
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('${drafts.length} goals drafted — review and edit.')));
      }
    } on TreatmentPlanAiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'))
            : null,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updateProgress(TreatmentGoal goal, int progress) async {
    if (_plan == null) return;
    await _svc.updateGoalProgress(
      treatmentPlanId: _plan!.id,
      goalId: goal.id,
      progress: progress,
    );
    _reload();
  }
}

// ---------------------------------------------------------------------------
// Labels
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Views
// ---------------------------------------------------------------------------

class _DiagnosisCard extends StatelessWidget {
  const _DiagnosisCard(
      {required this.theme, required this.cs, required this.plan});
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
                child: Text(plan.primaryDiagnosis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Text('$pct% overall',
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w700)),
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
            Text(plan.clinicalFormulation,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75), height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard(
      {required this.goal,
      required this.theme,
      required this.cs,
      required this.onUpdate});
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
              Icon(met ? Icons.check_circle : Icons.flag_outlined,
                  size: 18,
                  color: met ? const Color(0xFF16A34A) : _priorityColor),
              const SizedBox(width: PsySpacing.sm),
              Expanded(
                child: Text(goal.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: met ? TextDecoration.lineThrough : null,
                    )),
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
                Text('· ${goal.measurementMethod}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6))),
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
              Text('${goal.progress}%',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
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
        padding:
            const EdgeInsets.symmetric(horizontal: PsySpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(PsyRadius.full),
        ),
        child: Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600)),
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
              Text('${value.round()}%',
                  style: Theme.of(ctx).textTheme.headlineMedium),
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
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(100),
                child: const Text('Mark met')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(value.round()),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result != null) onUpdate(result);
  }
}

class _NoPlan extends StatelessWidget {
  const _NoPlan(
      {required this.theme, required this.cs, required this.onCreate});
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
            Icon(Icons.assignment_outlined,
                size: 44, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(height: PsySpacing.md),
            Text('No treatment plan yet',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: PsySpacing.xs),
            Text(
                'Capture the diagnosis and formulation, then draft SMART goals.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55))),
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

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.xl, vertical: PsySpacing.xxl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text('No goals yet — add one or draft with AI.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------------

class _CreatePlanDialog extends StatefulWidget {
  const _CreatePlanDialog();
  @override
  State<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends State<_CreatePlanDialog> {
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
                  labelText: 'Primary diagnosis (e.g. MDD, F32.1)'),
            ),
            const SizedBox(height: PsySpacing.md),
            TextField(
              controller: _formulation,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                  labelText: 'Clinical formulation',
                  alignLabelWithHint: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _dx.text.trim().isEmpty
              ? null
              : () => Navigator.of(context)
                  .pop((_dx.text.trim(), _formulation.text.trim())),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _GoalDraftInput {
  _GoalDraftInput(
      {required this.description,
      required this.category,
      required this.priority,
      required this.measurement,
      required this.targetWeeks});
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final String measurement;
  final int targetWeeks;
}

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();
  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _desc = TextEditingController();
  final _measure = TextEditingController();
  GoalCategory _cat = GoalCategory.symptomReduction;
  GoalPriority _pri = GoalPriority.medium;

  @override
  void dispose() {
    _desc.dispose();
    _measure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _desc,
              onChanged: (_) => setState(() {}),
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: 'Goal (SMART)', alignLabelWithHint: true),
            ),
            const SizedBox(height: PsySpacing.md),
            TextField(
              controller: _measure,
              decoration:
                  const InputDecoration(labelText: 'Measurement (optional)'),
            ),
            const SizedBox(height: PsySpacing.md),
            DropdownButtonFormField<GoalCategory>(
              initialValue: _cat,
              decoration: const InputDecoration(labelText: 'Category'),
              items: GoalCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(goalCategoryLabel(c))))
                  .toList(),
              onChanged: (v) => setState(() => _cat = v ?? _cat),
            ),
            const SizedBox(height: PsySpacing.md),
            DropdownButtonFormField<GoalPriority>(
              initialValue: _pri,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: GoalPriority.values
                  .map((p) => DropdownMenuItem(
                      value: p, child: Text(goalPriorityLabel(p))))
                  .toList(),
              onChanged: (v) => setState(() => _pri = v ?? _pri),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _desc.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_GoalDraftInput(
                    description: _desc.text.trim(),
                    category: _cat,
                    priority: _pri,
                    measurement: _measure.text.trim(),
                    targetWeeks: 12,
                  )),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
