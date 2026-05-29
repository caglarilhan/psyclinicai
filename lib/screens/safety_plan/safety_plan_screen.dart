import 'package:flutter/material.dart';

import '../../models/safety_plan.dart';
import '../../services/copilot/safety_plan_ai_service.dart';
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
  final _ai = SafetyPlanAiService();
  bool _loading = true;
  bool _busy = false;

  final _warning = <String>[];
  final _coping = <String>[];
  final _social = <String>[];
  final _support = <String>[];
  final _pros = <String>[];
  final _crisis = <String>[];
  final _means = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _ai.dispose();
    _means.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _repo.initialize();
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
        meansSafety: _means.text.trim(),
      );

  Future<void> _save() async {
    await _repo.save(_current());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Safety plan saved')));
    }
  }

  Future<void> _draftAi() async {
    setState(() => _busy = true);
    try {
      final p = await _ai.draft(
        patientId: widget.args.id,
        context: 'Patient ${widget.args.name}. Draft starter items for a '
            'collaborative crisis safety plan.',
      );
      setState(() => _apply(p));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Starter plan drafted — review and edit WITH the client.')));
      }
    } on SafetyPlanAiException catch (e) {
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
              child: Center(child: CircularProgressIndicator()))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(PsySpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(PsyRadius.lg),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety_outlined,
                          color: Color(0xFFDC2626)),
                      const SizedBox(width: PsySpacing.md),
                      Expanded(
                        child: Text(
                          'Complete this WITH the client. Decision-support '
                          'scaffold — not a clinical risk assessment.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.8)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _draftAi,
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Draft with AI'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),
                _Section(
                    title: '1 · Warning signs',
                    items: _warning,
                    onChanged: () => setState(() {})),
                _Section(
                    title: '2 · Coping strategies (on my own)',
                    items: _coping,
                    onChanged: () => setState(() {})),
                _Section(
                    title: '3 · Social distractions (people & places)',
                    items: _social,
                    onChanged: () => setState(() {})),
                _Section(
                    title: '4 · People I can ask for help',
                    items: _support,
                    onChanged: () => setState(() {})),
                _Section(
                    title: '5 · Professionals / agencies',
                    items: _pros,
                    onChanged: () => setState(() {})),
                _Section(
                    title: '6 · Crisis lines / emergency',
                    items: _crisis,
                    onChanged: () => setState(() {})),
                const SizedBox(height: PsySpacing.md),
                Text('7 · Making the environment safe',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
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
    );
  }
}

class _Section extends StatefulWidget {
  const _Section(
      {required this.title, required this.items, required this.onChanged});
  final String title;
  final List<String> items;
  final VoidCallback onChanged;

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
          Text(widget.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          ...widget.items.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.chevron_right,
                        size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                    Expanded(
                        child:
                            Text(e.value, style: theme.textTheme.bodyMedium)),
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
              )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctl,
                  onSubmitted: (_) => _add(),
                  decoration: const InputDecoration(
                      isDense: true, hintText: 'Add an item…'),
                ),
              ),
              const SizedBox(width: PsySpacing.sm),
              IconButton.filledTonal(
                  onPressed: _add, icon: const Icon(Icons.add)),
            ],
          ),
        ],
      ),
    );
  }
}
