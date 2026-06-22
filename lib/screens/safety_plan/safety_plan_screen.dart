import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/safety_plan.dart';
import '../../services/compliance/consent_guard.dart';
import '../../services/copilot/safety_plan_ai_service.dart';
import '../../services/crisis/crisis_resource_registry.dart';
import '../../services/data/intake_repository.dart';
import '../../services/data/safety_plan_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
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

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  @override
  void dispose() {
    _ai.dispose();
    _means.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new suggestions for this locale.')),
      );
      return;
    }
    setState(() => _crisis.addAll(suggestions));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${suggestions.length} regional crisis lines — review and '
          'edit as needed.',
        ),
      ),
    );
  }

  Future<void> _save() async {
    try {
      await _repo.save(_current());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Safety plan saved')));
    } catch (_) {
      // A crisis plan that failed to persist must NOT report success.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the safety plan — please retry.'),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Starter plan drafted — review and edit WITH the client.',
            ),
          ),
        );
      }
    } on ConsentDeniedException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'AI assistance is not consented for this patient. Update '
            'the intake form before drafting with AI.',
          ),
          action: SnackBarAction(
            label: 'Intake',
            onPressed: () => Navigator.of(
              context,
            ).pushNamed('/patients/intake', arguments: widget.args),
          ),
        ),
      );
    } on SafetyPlanAiException catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/patients',
      title: 'Safety plan',
      subtitle: '${widget.args.name} · crisis safety planning (Stanley-Brown)',
      breadcrumbs: [
        const Crumb('Home', '/dashboard'),
        const Crumb('Patients', '/patients'),
        Crumb(widget.args.name, null),
        const Crumb('Safety plan', null),
      ],
      primaryAction: _loading
          ? null
          : FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
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
                      final icon = const Icon(
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
                    hintText: 'Means-restriction steps agreed with the client…',
                  ),
                ),
                const SizedBox(height: PsySpacing.huge),
              ],
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
