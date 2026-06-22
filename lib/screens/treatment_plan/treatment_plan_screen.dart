import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/homework_item.dart';
import '../../models/treatment_plan_models.dart';
import '../../services/compliance/consent_guard.dart';
import '../../services/copilot/treatment_plan_ai_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/homework_repository.dart';
import '../../services/data/intake_repository.dart';
import '../../services/treatment_plan_service.dart';
import '../../theme/tokens.dart';
import '../../utils/smart_goal_notes.dart';
import '../../widgets/app_shell.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;
import 'treatment_plan_cards.dart';
import 'treatment_plan_homework.dart';

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
  final _intakes = IntakeRepository();
  // Production-wired ConsentGuard reads the patient's recorded
  // AI-assistance consent from the local intake repository. The guard
  // is fail-closed by default — no consent record on file blocks the
  // AI service.
  late final TreatmentPlanAiService _ai = TreatmentPlanAiService(
    consentGuard: ConsentGuard(
      consentLookup: (id) => _intakes.forPatient(id)?.consent,
    ),
  );
  final _homeworkRepo = HomeworkRepository();
  bool _loading = true;
  bool _busy = false;
  TreatmentPlan? _plan;
  List<HomeworkItem> _homework = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    _ai.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _svc.initialize();
    await _homeworkRepo.initialize();
    // ConsentGuard reads from this repo; loading it before any AI
    // entry point means the gate never fails for a stale snapshot.
    await _intakes.initialize();
    _plan = _svc.getTreatmentPlanForPatient(widget.args.id);
    _homework = _homeworkRepo.forPatient(widget.args.id);
    if (mounted) setState(() => _loading = false);
  }

  void _reload() {
    _plan = _svc.getTreatmentPlanForPatient(widget.args.id);
    _homework = _homeworkRepo.forPatient(widget.args.id);
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
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          : _plan == null
          ? NoPlanCard(theme: theme, cs: cs, onCreate: _createPlanDialog)
          : _planView(theme, cs, _plan!),
    );
  }

  Widget _planView(ThemeData theme, ColorScheme cs, TreatmentPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DiagnosisCard(theme: theme, cs: cs, plan: plan),
        const SizedBox(height: PsySpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _draftLetter,
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text('Reimbursement letter (EU)'),
          ),
        ),
        const SizedBox(height: PsySpacing.xl),
        Row(
          children: [
            Text(
              'Goals (${plan.goals.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _busy ? null : _draftWithAi,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_busy ? 'Drafting…' : 'Draft goals with AI'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.md),
        if (plan.goals.isEmpty)
          EmptyGoalsCard(theme: theme, cs: cs)
        else
          ...plan.goals.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: GoalCard(
                goal: g,
                theme: theme,
                cs: cs,
                onUpdate: (p) => _updateProgress(g, p),
              ),
            ),
          ),
        const SizedBox(height: PsySpacing.xxl),
        Row(
          children: [
            Text(
              'Homework (${_homework.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _busy ? null : _suggestHomework,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Suggest (AI)'),
            ),
            const SizedBox(width: PsySpacing.sm),
            TextButton.icon(
              onPressed: _addHomework,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.md),
        if (_homework.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.xl,
              vertical: PsySpacing.xl,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(PsyRadius.lg),
              border: Border.all(color: cs.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Text(
              'No homework yet — add one or suggest with AI.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          ..._homework.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.sm),
              child: HomeworkTile(
                item: h,
                theme: theme,
                cs: cs,
                onToggle: () => _toggleHomework(h),
              ),
            ),
          ),
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
    final notes = res.toNotesMarkdown();
    await _svc.addTreatmentGoal(
      treatmentPlanId: _plan!.id,
      description: res.description,
      category: res.category,
      priority: res.priority,
      targetDate: DateTime.now().add(Duration(days: res.targetWeeks * 7)),
      measurementMethod: res.measurement,
      notes: notes.isEmpty ? null : notes,
    );
    _reload();
  }

  Future<void> _draftWithAi() async {
    if (_plan == null) return;
    setState(() => _busy = true);
    try {
      final drafts = await _ai.draftGoals(
        patientId: widget.args.id,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${drafts.length} goals drafted — review and edit.'),
          ),
        );
      }
    } on TreatmentPlanAiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
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

  Future<void> _addHomework() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const HomeworkDialog(),
    );
    if (title == null || title.trim().isEmpty) return;
    await _homeworkRepo.add(
      HomeworkItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        patientId: widget.args.id,
        title: title.trim(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
    );
    _reload();
  }

  Future<void> _toggleHomework(HomeworkItem h) async {
    await _homeworkRepo.toggleDone(h.id);
    _reload();
  }

  Future<void> _suggestHomework() async {
    final plan = _plan;
    if (plan == null) return;
    final goals = plan.activeGoals.map((g) => g.description).toList();
    if (goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a goal first — homework ties to goals.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final ideas = await _ai.suggestHomework(
        patientId: widget.args.id,
        diagnosis: plan.primaryDiagnosis,
        goals: goals,
      );
      for (final t in ideas) {
        await _homeworkRepo.add(
          HomeworkItem(
            id: '${DateTime.now().microsecondsSinceEpoch}${t.hashCode}',
            patientId: widget.args.id,
            title: t,
            dueDate: DateTime.now().add(const Duration(days: 7)),
            linkedGoal: goals.first,
          ),
        );
      }
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${ideas.length} homework ideas added — review and edit.',
            ),
          ),
        );
      }
    } on TreatmentPlanAiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _draftLetter() async {
    final plan = _plan;
    if (plan == null) return;
    setState(() => _busy = true);
    try {
      final letter = await _ai.draftReimbursementLetter(
        patientId: widget.args.id,
        patientName: widget.args.name,
        diagnosis: plan.primaryDiagnosis,
        goals: plan.activeGoals.map((g) => g.description).toList(),
      );
      if (!mounted) return;
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => LetterSheet(letter: letter),
        ),
      );
    } on TreatmentPlanAiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

class _GoalDraftInput {
  _GoalDraftInput({
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

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();
  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
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
                            _GoalDraftInput(
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

