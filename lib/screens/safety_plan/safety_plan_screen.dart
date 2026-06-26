import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/safety_plan.dart';
import '../../services/compliance/consent_guard.dart';
import '../../services/copilot/safety_plan_ai_service.dart';
import '../../services/crisis/crisis_resource_registry.dart';
import '../../services/data/intake_repository.dart';
import '../../services/data/safety_plan_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/copilot/ai_disclaimer.dart';
import '../../widgets/ds/psy_save_shortcut.dart';
import '../../widgets/ds/psy_skeleton.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/ds/saving_indicator.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;

/// `/safety_plan` — collaborative Stanley-Brown crisis safety plan. Pairs with
/// the real-time risk co-pilot: when risk is flagged, build a safety plan WITH
/// the client. Decision-support scaffold; the clinician owns the plan.
class SafetyPlanScreen extends StatefulWidget {
  const SafetyPlanScreen({super.key, required this.args});
  final PatientDetailArgs args;

  @override
  State<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends State<SafetyPlanScreen> {
  final _repo = SafetyPlanRepository();
  final _intakes = IntakeRepository();
  // Production-wired ConsentGuard: AI may only run for a patient whose
  // intake records an explicit AI-assistance consent. Fail-closed by
  // default when no record exists.
  late final SafetyPlanAiService _ai = SafetyPlanAiService(
    consentGuard: ConsentGuard(
      consentLookup: (id) => _intakes.forPatient(id)?.consent,
    ),
  );
  bool _loading = true;
  bool _busy = false;

  final _warning = <String>[];
  final _coping = <String>[];
  final _social = <String>[];
  final _support = <String>[];
  final _pros = <String>[];
  final _crisis = <String>[];
  final _reasons = <String>[];
  final _means = TextEditingController();

  /// Save status pill — invisible until the clinician taps Save, then
  /// cycles through saving → saved (auto-fades) or saving → error
  /// (sticky with tap-to-retry). Threaded into the AppShell header
  /// row below the primary CTA.
  final _saveCtrl = SavingIndicatorController();

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    _ai.dispose();
    _means.dispose();
    _saveCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _repo.initialize();
    // Consent guard reads from the intake repo; initialise it before
    // any AI entry point fires.
    await _intakes.initialize();
    final p = _repo.forPatient(widget.args.id);
    if (p != null) _apply(p);
    if (mounted) setState(() => _loading = false);
  }

  void _apply(SafetyPlan p) {
    _set(_warning, p.warningSigns);
    _set(_coping, p.copingStrategies);
    _set(_social, p.socialDistractions);
    _set(_support, p.supportContacts);
    _set(_pros, p.professionals);
    _set(_crisis, p.crisisLines);
    _set(_reasons, p.reasonsForLiving);
    _means.text = p.meansSafety;
  }

  void _set(List<String> target, List<String> src) {
    target
      ..clear()
      ..addAll(src);
  }

  SafetyPlan _current() => SafetyPlan(
    patientId: widget.args.id,
    warningSigns: List.of(_warning),
    copingStrategies: List.of(_coping),
    socialDistractions: List.of(_social),
    supportContacts: List.of(_support),
    professionals: List.of(_pros),
    crisisLines: List.of(_crisis),
    reasonsForLiving: List.of(_reasons),
    meansSafety: _means.text.trim(),
  );

  /// Pre-fill the crisis lines list with the locale-appropriate hotlines.
  /// Never overwrites items the clinician already entered; only appends ones
  /// the registry knows about that aren't already in the list.
  void _suggestCrisisLines() {
    final locale = Localizations.maybeLocaleOf(context);
    final suggestions = CrisisResourceRegistry.forLocale(locale)
        .map((r) => '${r.name} — ${r.displayNumber}')
        .where((line) => !_crisis.contains(line))
        .toList();
    if (suggestions.isEmpty) {
      PsySnack.info(
        context,
        'No new suggestions for this locale.',
        hint: 'safety_plan.crisis_suggest_empty',
      );
      return;
    }
    setState(() => _crisis.addAll(suggestions));
    PsySnack.success(
      context,
      'Added ${suggestions.length} regional crisis lines — review and '
      'edit as needed.',
      hint: 'safety_plan.crisis_suggest_added',
    );
  }

  Future<void> _save() async {
    _saveCtrl.startSaving();
    try {
      await _repo.save(_current());
      _saveCtrl.markSaved();
      if (!mounted) return;
      PsySnack.success(context, 'Safety plan saved.', hint: 'safety_plan.save');
    } catch (e, st) {
      // A crisis plan that failed to persist must NOT report success.
      // Telemetry capture (PHI-scrubbed inside captureError) +
      // sticky SavingIndicator with tap-to-retry + an error PsySnack
      // give the clinician three layered cues that the write didn't
      // land — the worst place to be subtle is a Stanley-Brown save
      // during an active suicidality flag.
      unawaited(
        TelemetryService.instance.captureError(e, st, hint: 'safety_plan.save'),
      );
      _saveCtrl.markError(onRetry: _save);
      if (!mounted) return;
      PsySnack.error(
        context,
        'Could not save the safety plan — please retry.',
        hint: 'safety_plan.save_failed',
        action: SnackBarAction(label: 'Retry', onPressed: _save),
      );
    }
  }

  Future<void> _draftAi() async {
    setState(() => _busy = true);
    try {
      final p = await _ai.draft(
        patientId: widget.args.id,
        context:
            'Patient ${widget.args.name}. Draft starter items for a '
            'collaborative crisis safety plan.',
      );
      setState(() => _apply(p));
      if (mounted) {
        PsySnack.success(
          context,
          'Starter plan drafted — review and edit WITH the client.',
          hint: 'safety_plan.ai_draft_ok',
        );
      }
    } on ConsentDeniedException catch (_) {
      if (!mounted) return;
      PsySnack.warning(
        context,
        'AI assistance is not consented for this patient. Update '
        'the intake form before drafting with AI.',
        hint: 'safety_plan.ai_draft_consent_denied',
        action: SnackBarAction(
          label: 'Intake',
          onPressed: () => Navigator.of(
            context,
          ).pushNamed('/patients/intake', arguments: widget.args),
        ),
      );
    } on SafetyPlanAiException catch (e, st) {
      // Capture network / parse / model-shape-drift errors so the AI
      // surface is observable in prod. `noKey` is intentionally
      // skipped — that's expected UX (user just hasn't configured a
      // key) and would be reporting noise.
      if (!e.noKey) {
        unawaited(
          TelemetryService.instance.captureError(
            e,
            st,
            hint: 'safety_plan.ai_draft',
          ),
        );
      }
      if (!mounted) return;
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey ? 'safety_plan.ai_draft_no_key' : 'safety_plan.ai_draft',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsySaveShortcut(
      onSave: _save,
      enabled: !_loading,
      child: AppShell(
        routeName: '/patients',
        title: 'Safety plan',
        subtitle:
            '${widget.args.name} · crisis safety planning (Stanley-Brown)',
        breadcrumbs: [
          const Crumb('Home', '/dashboard'),
          const Crumb('Patients', '/patients'),
          Crumb(widget.args.name, null),
          const Crumb('Safety plan', null),
        ],
        primaryAction: _loading
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SavingIndicator(controller: _saveCtrl),
                  const SizedBox(width: PsySpacing.md),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save'),
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
                padding: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PsySkeletonBlock(height: 64),
                    SizedBox(height: PsySpacing.lg),
                    PsySkeletonBlock(height: 120),
                    SizedBox(height: PsySpacing.lg),
                    PsySkeletonBlock(height: 120),
                    SizedBox(height: PsySpacing.lg),
                    PsySkeletonBlock(height: 96),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calmer notice: neutral surface tint + tight padding so
                  // the warning reads as guidance, not as a giant pink alarm.
                  // The red icon still carries the safety semantic. "Draft
                  // with AI" steps down to TextButton — pure secondary.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PsySpacing.md,
                      vertical: PsySpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(PsyRadius.md),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final compact = c.maxWidth < 560;
                        const icon = Icon(
                          Icons.health_and_safety_outlined,
                          color: Color(0xFFDC2626),
                          size: 20,
                        );
                        final body = Text(
                          'Complete this WITH the client. Decision-support '
                          'scaffold — not a clinical risk assessment.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.78),
                            height: 1.4,
                          ),
                        );
                        final draftButton = TextButton.icon(
                          onPressed: _busy ? null : _draftAi,
                          icon: _busy
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Draft with AI'),
                          style: TextButton.styleFrom(
                            foregroundColor: cs.primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        );
                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  icon,
                                  const SizedBox(width: PsySpacing.sm),
                                  Expanded(child: body),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: draftButton,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            icon,
                            const SizedBox(width: PsySpacing.md),
                            Expanded(child: body),
                            const SizedBox(width: PsySpacing.sm),
                            draftButton,
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: PsySpacing.md),
                  // L5 — sticky AI disclaimer above any AI-touched
                  // surface. Safety plan is the highest-risk AI flow
                  // (lethal-means context); the clinician must read
                  // every line.
                  AiDisclaimer.compact(surface: 'safety_plan_ai'),
                  const SizedBox(height: PsySpacing.xl),
                  _Section(
                    title: '1 · Warning signs',
                    items: _warning,
                    onChanged: () => setState(() {}),
                  ),
                  _Section(
                    title: '2 · Coping strategies (on my own)',
                    items: _coping,
                    onChanged: () => setState(() {}),
                  ),
                  _Section(
                    title: '3 · Social distractions (people & places)',
                    items: _social,
                    onChanged: () => setState(() {}),
                  ),
                  _Section(
                    title: '4 · People I can ask for help',
                    items: _support,
                    onChanged: () => setState(() {}),
                  ),
                  _Section(
                    title: '5 · Professionals / agencies',
                    items: _pros,
                    onChanged: () => setState(() {}),
                  ),
                  _Section(
                    title: '6 · Crisis lines / emergency',
                    items: _crisis,
                    onChanged: () => setState(() {}),
                    trailing: TextButton.icon(
                      onPressed: _suggestCrisisLines,
                      icon: const Icon(Icons.add_location_outlined, size: 16),
                      label: const Text('Suggest for this region'),
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  _Section(
                    title: '7 · Reasons to keep living',
                    items: _reasons,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: PsySpacing.md),
                  Text(
                    '8 · Making the environment safe',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: PsySpacing.sm),
                  TextField(
                    controller: _means,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Means-restriction steps agreed with the client…',
                    ),
                  ),
                  const SizedBox(height: PsySpacing.huge),
                ],
              ),
      ),
    );
  }
}

class _Section extends StatefulWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.onChanged,
    this.trailing,
  });
  final String title;
  final List<String> items;
  final VoidCallback onChanged;
  final Widget? trailing;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _add() {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    widget.items.add(t);
    _ctl.clear();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          ...widget.items.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: Text(e.value, style: theme.textTheme.bodyMedium),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      widget.items.removeAt(e.key);
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  onSubmitted: (_) => _add(),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Add an item…',
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.sm),
              IconButton.filledTonal(
                onPressed: _add,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
