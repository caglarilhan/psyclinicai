import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/homework_item.dart';
import '../../models/treatment_plan_models.dart';
import '../../services/compliance/consent_guard.dart';
import '../../services/copilot/treatment_plan_ai_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/homework_repository.dart';
import '../../services/data/intake_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../services/treatment_plan_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/ds/saving_indicator.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;
import 'treatment_plan_cards.dart';
import 'treatment_plan_dialogs.dart';
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
  final _saveCtrl = SavingIndicatorController();
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
    _saveCtrl.dispose();
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
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SavingIndicator(controller: _saveCtrl),
                const SizedBox(width: PsySpacing.md),
                FilledButton.icon(
                  onPressed: _addGoalDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add goal'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: PsySpacing.xl,
                    ),
                  ),
                ),
              ],
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
      builder: (_) => const CreatePlanDialog(),
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
    final res = await showDialog<GoalDraftInput>(
      context: context,
      builder: (_) => const AddGoalDialog(),
    );
    if (res == null || _plan == null) return;
    final notes = res.toNotesMarkdown();
    _saveCtrl.startSaving();
    try {
      await _svc.addTreatmentGoal(
        treatmentPlanId: _plan!.id,
        description: res.description,
        category: res.category,
        priority: res.priority,
        targetDate: DateTime.now().add(Duration(days: res.targetWeeks * 7)),
        measurementMethod: res.measurement,
        notes: notes.isEmpty ? null : notes,
      );
      _saveCtrl.markSaved();
    } catch (_) {
      _saveCtrl.markError(onRetry: _addGoalDialog);
      rethrow;
    }
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
        PsySnack.success(
          context,
          '${drafts.length} goals drafted — review and edit.',
          hint: 'treatment_plan.ai_goals_drafted',
        );
      }
    } on TreatmentPlanAiException catch (e, st) {
      // Capture non-noKey errors so the AI surface is observable in
      // prod (parse drift, network, quota). noKey is expected UX —
      // the snackbar still nudges the user to the API-keys screen.
      if (!e.noKey) {
        unawaited(
          TelemetryService.instance.captureError(
            e,
            st,
            hint: 'treatment_plan.ai_call',
          ),
        );
      }
      if (!mounted) return;
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey
            ? 'treatment_plan.ai_draft_no_key'
            : 'treatment_plan.ai_draft_failed',
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'),
              )
            : null,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updateProgress(TreatmentGoal goal, int progress) async {
    if (_plan == null) return;
    _saveCtrl.startSaving();
    try {
      await _svc.updateGoalProgress(
        treatmentPlanId: _plan!.id,
        goalId: goal.id,
        progress: progress,
      );
      _saveCtrl.markSaved();
    } catch (_) {
      _saveCtrl.markError(onRetry: () => _updateProgress(goal, progress));
      rethrow;
    }
    _reload();
  }

  Future<void> _addHomework() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const HomeworkDialog(),
    );
    if (title == null || title.trim().isEmpty) return;
    _saveCtrl.startSaving();
    try {
      await _homeworkRepo.add(
        HomeworkItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          patientId: widget.args.id,
          title: title.trim(),
          dueDate: DateTime.now().add(const Duration(days: 7)),
        ),
      );
      _saveCtrl.markSaved();
    } catch (_) {
      _saveCtrl.markError(onRetry: _addHomework);
      rethrow;
    }
    _reload();
  }

  Future<void> _toggleHomework(HomeworkItem h) async {
    _saveCtrl.startSaving();
    try {
      await _homeworkRepo.toggleDone(h.id);
      _saveCtrl.markSaved();
    } catch (_) {
      _saveCtrl.markError(onRetry: () => _toggleHomework(h));
      rethrow;
    }
    _reload();
  }

  Future<void> _suggestHomework() async {
    final plan = _plan;
    if (plan == null) return;
    final goals = plan.activeGoals.map((g) => g.description).toList();
    if (goals.isEmpty) {
      PsySnack.info(
        context,
        'Add a goal first — homework ties to goals.',
        hint: 'treatment_plan.homework_no_goals',
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
        PsySnack.success(
          context,
          '${ideas.length} homework ideas added — review and edit.',
          hint: 'treatment_plan.homework_suggested',
        );
      }
    } on TreatmentPlanAiException catch (e, st) {
      // Capture non-noKey errors so the AI surface is observable in
      // prod (parse drift, network, quota). noKey is expected UX —
      // the snackbar still nudges the user to the API-keys screen.
      if (!e.noKey) {
        unawaited(
          TelemetryService.instance.captureError(
            e,
            st,
            hint: 'treatment_plan.ai_call',
          ),
        );
      }
      if (!mounted) return;
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey
            ? 'treatment_plan.homework_no_key'
            : 'treatment_plan.homework_failed',
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'),
              )
            : null,
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
    } on TreatmentPlanAiException catch (e, st) {
      // Capture non-noKey errors so the AI surface is observable in
      // prod (parse drift, network, quota). noKey is expected UX —
      // the snackbar still nudges the user to the API-keys screen.
      if (!e.noKey) {
        unawaited(
          TelemetryService.instance.captureError(
            e,
            st,
            hint: 'treatment_plan.ai_call',
          ),
        );
      }
      if (!mounted) return;
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey
            ? 'treatment_plan.letter_no_key'
            : 'treatment_plan.letter_failed',
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'),
              )
            : null,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
