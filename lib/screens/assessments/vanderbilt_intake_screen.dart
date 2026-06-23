/// `/assessments/vanderbilt` — NICHQ Vanderbilt ADHD intake screen.
///
/// One screen per respondent (parent or teacher). The clinician
/// toggles respondent at the top, then walks through the
/// 0 (Never) / 1 (Occasionally) / 2 (Often) / 3 (Very Often) items
/// for inattention + hyperactivity + (parent only) ODD + conduct
/// + anxiety/depression, plus the 1-5 performance section. Live
/// scoring panel at the right shows DSM-5 cutoff helpers.
///
/// Saves through `VanderbiltRepository` (PR #15) with telemetry
/// hint shape (counts + enums only — never the item answers
/// themselves).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/vanderbilt_assessment.dart';
import '../../services/data/telemetry_service.dart';
import '../../services/data/vanderbilt_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/ds/saving_indicator.dart';

class VanderbiltIntakeScreen extends StatefulWidget {
  const VanderbiltIntakeScreen({
    super.key,
    required this.patientId,
    required this.clinicianId,
    this.repository,
    this.initial,
  });

  final String patientId;
  final String clinicianId;
  final VanderbiltRepository? repository;
  final VanderbiltAssessment? initial;

  @override
  State<VanderbiltIntakeScreen> createState() => VanderbiltIntakeScreenState();
}

class VanderbiltIntakeScreenState extends State<VanderbiltIntakeScreen> {
  late final VanderbiltRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  late VanderbiltAssessment _a;

  VanderbiltAssessment get assessment => _a;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? VanderbiltRepository();
    _saveCtrl = SavingIndicatorController();
    _a = _normalise(
      widget.initial ??
          VanderbiltAssessment(
            id: 'vb-${DateTime.now().microsecondsSinceEpoch}-${widget.patientId}',
            patientId: widget.patientId,
            clinicianId: widget.clinicianId,
            respondent: VanderbiltRespondent.parent,
            capturedAt: DateTime.now().toUtc(),
          ),
    );
    unawaited(_repo.initialize());
  }

  /// Pads any empty section list to its full length so the form
  /// can index every cell without RangeError. Empty is the
  /// model's "not captured yet" sentinel; the panel renders it
  /// as all-zeros (all-1 for performance).
  VanderbiltAssessment _normalise(VanderbiltAssessment a) {
    return a.copyWith(
      inattention: a.inattention.isEmpty
          ? List<int>.filled(9, 0)
          : a.inattention,
      hyperactivity: a.hyperactivity.isEmpty
          ? List<int>.filled(9, 0)
          : a.hyperactivity,
      oppositional: a.oppositional.isEmpty
          ? List<int>.filled(8, 0)
          : a.oppositional,
      conduct: a.conduct.isEmpty ? List<int>.filled(14, 0) : a.conduct,
      anxietyDepression: a.anxietyDepression.isEmpty
          ? List<int>.filled(7, 0)
          : a.anxietyDepression,
      performance: a.performance.isEmpty
          ? List<int>.filled(8, 1)
          : a.performance,
    );
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    super.dispose();
  }

  void setSymptom(VanderbiltSection section, int i, int value) {
    setState(() {
      switch (section) {
        case VanderbiltSection.inattn:
          final next = [..._a.inattention]..[i] = value;
          _a = _a.copyWith(inattention: next);
        case VanderbiltSection.hyper:
          final next = [..._a.hyperactivity]..[i] = value;
          _a = _a.copyWith(hyperactivity: next);
        case VanderbiltSection.odd:
          final next = [..._a.oppositional]..[i] = value;
          _a = _a.copyWith(oppositional: next);
        case VanderbiltSection.conduct:
          final next = [..._a.conduct]..[i] = value;
          _a = _a.copyWith(conduct: next);
        case VanderbiltSection.anxDep:
          final next = [..._a.anxietyDepression]..[i] = value;
          _a = _a.copyWith(anxietyDepression: next);
        case VanderbiltSection.perf:
          final next = [..._a.performance]..[i] = value;
          _a = _a.copyWith(performance: next);
      }
    });
  }

  void setRespondent(VanderbiltRespondent r) {
    if (_a.respondent == r) return;
    setState(() {
      _a = VanderbiltAssessment(
        id: _a.id,
        patientId: _a.patientId,
        clinicianId: _a.clinicianId,
        respondent: r,
        capturedAt: _a.capturedAt,
        inattention: _a.inattention,
        hyperactivity: _a.hyperactivity,
        oppositional: _a.oppositional,
        conduct: _a.conduct,
        anxietyDepression: _a.anxietyDepression,
        performance: _a.performance,
        notes: _a.notes,
      );
    });
  }

  Future<void> save() async {
    _saveCtrl.startSaving();
    try {
      await _repo.upsert(_a);
      _saveCtrl.markSaved();
      if (mounted) {
        PsySnack.success(
          context,
          'Vanderbilt assessment saved.',
          hint: 'vanderbilt.save',
        );
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'vanderbilt.save_failed',
        ),
      );
      _saveCtrl.markError(onRetry: save);
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save — please retry.',
          hint: 'vanderbilt.save_failed',
        );
      }
    }
  }

  bool get _isParent => _a.respondent == VanderbiltRespondent.parent;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/assessments/vanderbilt',
      title: 'NICHQ Vanderbilt — ADHD screening',
      subtitle:
          'Public-domain DSM-5 ADHD screening tool. Parent + teacher forms; '
          'both are usually needed for a diagnostic call.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Assessments', '/assessments'),
        Crumb('Vanderbilt', null),
      ],
      primaryAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SavingIndicator(controller: _saveCtrl),
          const SizedBox(width: PsySpacing.sm),
          FilledButton.icon(
            onPressed: save,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 1100;
          final form = _FormColumn(
            state: this,
            isParent: _isParent,
            assessment: _a,
          );
          final score = _ScorePanel(a: _a);
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: form),
                const SizedBox(width: PsySpacing.lg),
                SizedBox(width: 340, child: score),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              score,
              const SizedBox(height: PsySpacing.lg),
              form,
            ],
          );
        },
      ),
    );
  }
}

enum VanderbiltSection { inattn, hyper, odd, conduct, anxDep, perf }

class _FormColumn extends StatelessWidget {
  const _FormColumn({
    required this.state,
    required this.isParent,
    required this.assessment,
  });
  final VanderbiltIntakeScreenState state;
  final bool isParent;
  final VanderbiltAssessment assessment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RespondentToggle(
          respondent: assessment.respondent,
          onChanged: state.setRespondent,
        ),
        const SizedBox(height: PsySpacing.md),

        _SymptomSection(
          title: '1. Inattention',
          subtitle:
              'DSM-5 symptom threshold: at least 6 items rated 2 (Often) or 3 (Very Often).',
          items: _kInattnItems,
          values: assessment.inattention,
          onChange: (i, v) => state.setSymptom(VanderbiltSection.inattn, i, v),
        ),
        _SymptomSection(
          title: '2. Hyperactivity / Impulsivity',
          subtitle:
              'DSM-5 symptom threshold: at least 6 items rated 2 (Often) or 3 (Very Often).',
          items: _kHyperItems,
          values: assessment.hyperactivity,
          onChange: (i, v) => state.setSymptom(VanderbiltSection.hyper, i, v),
        ),
        if (isParent) ...[
          _SymptomSection(
            title: '3. Oppositional / Defiant',
            subtitle: 'Positive screen: at least 4 items rated 2 or 3.',
            items: _kOddItems,
            values: assessment.oppositional,
            onChange: (i, v) => state.setSymptom(VanderbiltSection.odd, i, v),
          ),
          _SymptomSection(
            title: '4. Conduct',
            subtitle: 'Positive screen: at least 3 items rated 2 or 3.',
            items: _kConductItems,
            values: assessment.conduct,
            onChange: (i, v) =>
                state.setSymptom(VanderbiltSection.conduct, i, v),
          ),
          _SymptomSection(
            title: '5. Anxiety / Depression',
            subtitle: 'Positive screen: at least 3 items rated 2 or 3.',
            items: _kAnxDepItems,
            values: assessment.anxietyDepression,
            onChange: (i, v) =>
                state.setSymptom(VanderbiltSection.anxDep, i, v),
          ),
        ],
        _PerformanceSection(
          values: assessment.performance,
          onChange: (i, v) => state.setSymptom(VanderbiltSection.perf, i, v),
        ),
      ],
    );
  }
}

class _RespondentToggle extends StatelessWidget {
  const _RespondentToggle({required this.respondent, required this.onChanged});
  final VanderbiltRespondent respondent;
  final ValueChanged<VanderbiltRespondent> onChanged;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Respondent',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Parent form covers all sections; teacher form covers '
            'inattention + hyperactivity + performance only.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: PsySpacing.md),
          SegmentedButton<VanderbiltRespondent>(
            segments: const [
              ButtonSegment(
                value: VanderbiltRespondent.parent,
                label: Text('Parent'),
                icon: Icon(Icons.family_restroom, size: 18),
              ),
              ButtonSegment(
                value: VanderbiltRespondent.teacher,
                label: Text('Teacher'),
                icon: Icon(Icons.school_outlined, size: 18),
              ),
            ],
            selected: {respondent},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}

class _SymptomSection extends StatelessWidget {
  const _SymptomSection({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.values,
    required this.onChange,
  });
  final String title;
  final String subtitle;
  final List<String> items;
  final List<int> values;
  final void Function(int index, int value) onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: PsySpacing.md),
            for (var i = 0; i < items.length; i++) ...[
              _SymptomRow(
                index: i,
                label: items[i],
                value: values[i],
                onChange: (v) => onChange(i, v),
              ),
              if (i < items.length - 1) const Divider(height: PsySpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  const _SymptomRow({
    required this.index,
    required this.label,
    required this.value,
    required this.onChange,
  });
  final int index;
  final String label;
  final int value;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 0, label: Text('0')),
              ButtonSegment(value: 1, label: Text('1')),
              ButtonSegment(value: 2, label: Text('2')),
              ButtonSegment(value: 3, label: Text('3')),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChange(s.first),
          ),
        ),
      ],
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.values, required this.onChange});
  final List<int> values;
  final void Function(int index, int value) onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance (academic + interpersonal)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '1 = above average to 5 = problematic. Functional-impairment '
              'criterion: any item rated 4 or 5.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: PsySpacing.md),
            for (var i = 0; i < _kPerfItems.length; i++) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _kPerfItems[i],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 1, label: Text('1')),
                        ButtonSegment(value: 2, label: Text('2')),
                        ButtonSegment(value: 3, label: Text('3')),
                        ButtonSegment(value: 4, label: Text('4')),
                        ButtonSegment(value: 5, label: Text('5')),
                      ],
                      selected: {values[i]},
                      onSelectionChanged: (s) => onChange(i, s.first),
                    ),
                  ),
                ],
              ),
              if (i < _kPerfItems.length - 1)
                const Divider(height: PsySpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.a});
  final VanderbiltAssessment a;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live scoring',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'DSM-5 / NICHQ cutoffs. Clinical interpretation, never a '
            'diagnostic call on its own.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _ScoreRow(
            label: 'Inattention',
            value: '${a.inattentionSymptomCount} / 9',
            met: a.meetsInattentionThreshold,
            metHint: 'at least 6 symptomatic',
          ),
          _ScoreRow(
            label: 'Hyperactivity',
            value: '${a.hyperactivitySymptomCount} / 9',
            met: a.meetsHyperactivityThreshold,
            metHint: 'at least 6 symptomatic',
          ),
          if (a.respondent == VanderbiltRespondent.parent) ...[
            _ScoreRow(
              label: 'Oppositional',
              value: '${a.oppositionalSymptomCount} / 8',
              met: a.oppositionalPositiveScreen,
              metHint: 'at least 4 symptomatic',
            ),
            _ScoreRow(
              label: 'Conduct',
              value: '${a.conductSymptomCount} / 14',
              met: a.conductPositiveScreen,
              metHint: 'at least 3 symptomatic',
            ),
            _ScoreRow(
              label: 'Anxiety / Depression',
              value: '${a.anxietyDepressionSymptomCount} / 7',
              met: a.anxietyDepressionPositiveScreen,
              metHint: 'at least 3 symptomatic',
            ),
          ],
          _ScoreRow(
            label: 'Functional impairment',
            value: a.hasFunctionalImpairment ? 'Yes' : 'No',
            met: a.hasFunctionalImpairment,
            metHint: 'any performance item rated 4 or 5',
          ),
          const Divider(height: PsySpacing.xl),
          Text(
            'Subtype call',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _subtypeLabel(a.subtype),
            style: theme.textTheme.titleMedium?.copyWith(
              color: a.subtype == VanderbiltSubtype.none
                  ? cs.onSurface
                  : cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (a.subtype != VanderbiltSubtype.none) ...[
            const SizedBox(height: 4),
            Text(
              'Pair with the other respondent before a diagnostic call.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _subtypeLabel(VanderbiltSubtype s) => switch (s) {
    VanderbiltSubtype.none => 'No threshold met',
    VanderbiltSubtype.inattentive => 'Predominantly inattentive',
    VanderbiltSubtype.hyperactiveImpulsive =>
      'Predominantly hyperactive / impulsive',
    VanderbiltSubtype.combined => 'Combined presentation',
  };
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.met,
    required this.metHint,
  });
  final String label;
  final String value;
  final bool met;
  final String metHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 18,
            color: met ? cs.error : cs.onSurface.withValues(alpha: 0.55),
          ),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  metHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: met ? cs.error : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// NICHQ Vanderbilt item labels — public domain.
const _kInattnItems = [
  'Fails to give attention to details / makes careless mistakes.',
  'Has difficulty sustaining attention to tasks or activities.',
  'Does not seem to listen when spoken to directly.',
  'Does not follow through on instructions; fails to finish work.',
  'Has difficulty organising tasks and activities.',
  'Avoids tasks requiring sustained mental effort.',
  'Loses things needed for tasks or activities.',
  'Easily distracted by extraneous stimuli.',
  'Forgetful in daily activities.',
];

const _kHyperItems = [
  'Fidgets with hands or feet, squirms in seat.',
  'Leaves seat when remaining seated is expected.',
  'Runs about or climbs in inappropriate situations.',
  'Has difficulty playing quietly.',
  'On the go or acts as if driven by a motor.',
  'Talks excessively.',
  'Blurts out answers before questions are completed.',
  'Has difficulty waiting turn.',
  'Interrupts or intrudes on others.',
];

const _kOddItems = [
  'Argues with adults.',
  'Loses temper.',
  'Actively defies / refuses to comply with rules.',
  'Deliberately annoys people.',
  'Blames others for own mistakes.',
  'Is touchy / easily annoyed by others.',
  'Is angry and resentful.',
  'Is spiteful or vindictive.',
];

const _kConductItems = [
  'Bullies, threatens, or intimidates others.',
  'Initiates physical fights.',
  'Has used a weapon that can cause serious harm.',
  'Has been physically cruel to people.',
  'Has been physically cruel to animals.',
  'Has stolen while confronting a victim.',
  'Has forced someone into sexual activity.',
  'Has deliberately engaged in fire-setting with intent to damage.',
  "Has deliberately destroyed others' property.",
  "Has broken into someone else's house, building, or car.",
  'Lies to obtain goods or favours / to avoid obligations.',
  'Has stolen items of nontrivial value without confronting a victim.',
  'Often stays out at night despite parental prohibitions.',
  'Has run away from home overnight at least twice.',
];

const _kAnxDepItems = [
  'Is fearful, anxious, or worried.',
  'Is afraid to try new things.',
  'Feels worthless or inferior.',
  'Blames self for problems; feels guilty.',
  'Feels lonely, unwanted, or unloved.',
  'Is sad, unhappy, or depressed.',
  'Is self-conscious or easily embarrassed.',
];

const _kPerfItems = [
  'Reading.',
  'Mathematics.',
  'Written expression.',
  'Relationship with parents.',
  'Relationship with siblings.',
  'Relationship with peers.',
  'Participation in organised activities (e.g. sports).',
  'Overall academic performance.',
];
