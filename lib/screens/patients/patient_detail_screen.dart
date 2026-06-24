import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/medication.dart';
import '../../services/data/assessment_repository.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/medication_repository.dart';
import '../../services/data/patient_pin_repository.dart';
import '../../theme/tokens.dart';
import '../../utils/time_format.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/clinical_brief_card.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';
import '../../widgets/ds/psy_skeleton.dart';
import 'patient_list_screen.dart' show PatientDetailArgs;

/// `/patient/detail` — single-patient chart: header + assessments timeline.
class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key, required this.args});

  final PatientDetailArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/patients',
      title: args.name,
      subtitle: 'Patient chart — screeners, trend, and recent activity.',
      breadcrumbs: [
        const Crumb('Home', '/dashboard'),
        const Crumb('Patients', '/patients'),
        Crumb(args.name, null),
      ],
      scrollable: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(args: args, theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          ClinicalBriefCard(patientId: args.id, patientName: args.name),
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: PsyButton(
              label: 'Start session',
              icon: Icons.mic_none,
              onPressed: () =>
                  Navigator.of(context).pushNamed('/session', arguments: args),
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Send screener'),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              PsyButton(
                label: 'PHQ-9',
                icon: Icons.psychology_outlined,
                size: PsyButtonSize.sm,
                onPressed: () =>
                    Navigator.of(context).pushNamed('/assessments/phq9'),
              ),
              const SizedBox(width: PsySpacing.md),
              PsyButton(
                label: 'GAD-7',
                icon: Icons.spa_outlined,
                size: PsyButtonSize.sm,
                variant: PsyButtonVariant.secondary,
                onPressed: () =>
                    Navigator.of(context).pushNamed('/assessments/gad7'),
              ),
              const Spacer(),
              PsyButton(
                label: 'View trend',
                icon: Icons.show_chart,
                size: PsyButtonSize.sm,
                variant: PsyButtonVariant.ghost,
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed('/outcomes', arguments: args),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Intake & consent'),
          const SizedBox(height: PsySpacing.md),
          PsyButton(
            label: 'Open intake form',
            icon: Icons.assignment_ind_outlined,
            size: PsyButtonSize.sm,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed('/patients/intake', arguments: args),
          ),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Treatment plan'),
          const SizedBox(height: PsySpacing.md),
          PsyButton(
            label: 'Open treatment plan',
            icon: Icons.assignment_outlined,
            size: PsyButtonSize.sm,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed('/treatment_plan', arguments: args),
          ),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Crisis safety plan'),
          const SizedBox(height: PsySpacing.md),
          PsyButton(
            label: 'Open safety plan',
            icon: Icons.health_and_safety_outlined,
            size: PsyButtonSize.sm,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed('/safety_plan', arguments: args),
          ),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Medications'),
          const SizedBox(height: PsySpacing.md),
          _MedicationsSection(patientId: args.id),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Recent assessments'),
          const SizedBox(height: PsySpacing.md),
          _AssessmentList(patientId: args.id),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.args, required this.theme, required this.cs});
  final PatientDetailArgs args;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.primary,
            child: Text(
              args.name.isNotEmpty ? args.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: PsySpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PsySpacing.xs),
                Text(
                  'Patient ID · ${args.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
          _PinButton(patientId: args.id),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _AssessmentList extends StatelessWidget {
  const _AssessmentList({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) {
    if (!PsyFirebase.isReady) {
      return _demoAssessments(context);
    }
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return _emptyCard(
        context,
        title: 'Sign in required',
        body: 'Sign in to load assessments.',
      );
    }
    return StreamBuilder<List<AssessmentDoc>>(
      stream: AssessmentRepository.instance.watchForPatient(
        profile.clinicId,
        patientId,
      ),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const PsySkeletonGroup(
            child: Padding(
              padding: EdgeInsets.all(PsySpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PsySkeletonLine(width: 140),
                  SizedBox(height: PsySpacing.md),
                  PsySkeletonBlock(height: 180),
                ],
              ),
            ),
          );
        }
        final list = snap.data ?? const <AssessmentDoc>[];
        if (list.isEmpty) {
          return _emptyCard(
            context,
            title: 'No assessments yet',
            body: 'Send a PHQ-9 or GAD-7 to start the trend.',
          );
        }
        return Column(
          children: list
              .map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: PsySpacing.md),
                  child: _AssessmentTile(a: a),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _demoAssessments(BuildContext context) {
    return const Column(
      children: [
        _DemoAssessmentTile(
          type: 'phq9',
          score: 14,
          severity: 'Moderate',
          date: '2026-05-09',
          tone: PsyBadgeTone.warning,
        ),
        SizedBox(height: PsySpacing.md),
        _DemoAssessmentTile(
          type: 'phq9',
          score: 9,
          severity: 'Mild',
          date: '2026-05-16',
          tone: PsyBadgeTone.info,
        ),
        SizedBox(height: PsySpacing.md),
        _DemoAssessmentTile(
          type: 'gad7',
          score: 6,
          severity: 'Mild',
          date: '2026-05-16',
          tone: PsyBadgeTone.info,
        ),
      ],
    );
  }

  Widget _emptyCard(
    BuildContext context, {
    required String title,
    required String body,
  }) => PsyCard(
    child: PsyEmptyState(
      icon: Icons.assessment_outlined,
      title: title,
      body: body,
      compact: true,
    ),
  );
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({required this.a});
  final AssessmentDoc a;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tone = _toneFor(a.severity);
    return PsyCard(
      child: Row(
        children: [
          Icon(
            a.type == 'phq9' ? Icons.psychology_outlined : Icons.spa_outlined,
            color: cs.primary,
            size: 22,
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${a.type.toUpperCase()} · score ${a.score}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (a.completedAt != null) ...[
                  const SizedBox(height: PsySpacing.xxs),
                  Text(
                    'Completed ${TimeFormat.relativeDay(a.completedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PsyBadge(label: a.severity, tone: tone),
          if (a.selfHarmFlag) ...[
            const SizedBox(width: PsySpacing.sm),
            const PsyBadge(
              label: 'RISK FLAG',
              tone: PsyBadgeTone.danger,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ],
      ),
    );
  }

  static PsyBadgeTone _toneFor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('severe')) return PsyBadgeTone.danger;
    if (s.contains('moderately')) return PsyBadgeTone.danger;
    if (s.contains('moderate')) return PsyBadgeTone.warning;
    if (s.contains('mild')) return PsyBadgeTone.info;
    return PsyBadgeTone.success;
  }
}

class _DemoAssessmentTile extends StatelessWidget {
  const _DemoAssessmentTile({
    required this.type,
    required this.score,
    required this.severity,
    required this.date,
    required this.tone,
  });
  final String type;
  final int score;
  final String severity;
  final String date;
  final PsyBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Row(
        children: [
          Icon(
            type == 'phq9' ? Icons.psychology_outlined : Icons.spa_outlined,
            color: cs.primary,
            size: 22,
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${type.toUpperCase()} · score $score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PsySpacing.xxs),
                Text(
                  'Completed $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          PsyBadge(label: severity, tone: tone),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Medications (psychiatry / prescriber workflow) — manual entry only.
// ---------------------------------------------------------------------------

class _MedicationsSection extends StatefulWidget {
  const _MedicationsSection({required this.patientId});
  final String patientId;

  @override
  State<_MedicationsSection> createState() => _MedicationsSectionState();
}

class _MedicationsSectionState extends State<_MedicationsSection> {
  final _repo = MedicationRepository();
  bool _loading = true;
  List<Medication> _meds = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    await _repo.initialize();
    if (mounted) {
      setState(() {
        _meds = _repo.forPatient(widget.patientId);
        _loading = false;
      });
    }
  }

  Future<void> _add() async {
    final med = await showDialog<Medication>(
      context: context,
      builder: (_) => _MedicationDialog(patientId: widget.patientId),
    );
    if (med == null) return;
    await _repo.add(med);
    if (mounted) setState(() => _meds = _repo.forPatient(widget.patientId));
  }

  Future<void> _toggle(Medication m) async {
    await _repo.toggleActive(m.id);
    if (mounted) setState(() => _meds = _repo.forPatient(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (_loading) {
      return const PsySkeletonGroup(
        child: Padding(
          padding: EdgeInsets.all(PsySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PsySkeletonBlock(height: 60),
              SizedBox(height: PsySpacing.sm),
              PsySkeletonBlock(height: 60),
              SizedBox(height: PsySpacing.sm),
              PsySkeletonBlock(height: 60),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_meds.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PsySpacing.lg),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(PsyRadius.lg),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              'No medications recorded.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          ..._meds.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.sm),
              child: _MedTile(
                med: m,
                theme: theme,
                cs: cs,
                onToggle: () => _toggle(m),
              ),
            ),
          ),
        const SizedBox(height: PsySpacing.md),
        PsyButton(
          label: 'Add medication',
          icon: Icons.medication_outlined,
          size: PsyButtonSize.sm,
          variant: PsyButtonVariant.secondary,
          onPressed: _add,
        ),
      ],
    );
  }
}

class _MedTile extends StatelessWidget {
  const _MedTile({
    required this.med,
    required this.theme,
    required this.cs,
    required this.onToggle,
  });
  final Medication med;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final detail = [
      med.dose,
      med.frequency,
    ].where((s) => s.isNotEmpty).join(' · ');
    return Container(
      padding: const EdgeInsets.all(PsySpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication,
            size: 20,
            color: med.active
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: med.active ? null : TextDecoration.lineThrough,
                    color: med.active
                        ? null
                        : cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onToggle,
            child: Text(med.active ? 'Discontinue' : 'Restart'),
          ),
        ],
      ),
    );
  }
}

class _MedicationDialog extends StatefulWidget {
  const _MedicationDialog({required this.patientId});
  final String patientId;

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _freq = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _freq.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Medication (e.g. Sertraline)',
              ),
            ),
            const SizedBox(height: PsySpacing.md),
            TextField(
              controller: _dose,
              decoration: const InputDecoration(labelText: 'Dose (e.g. 50 mg)'),
            ),
            const SizedBox(height: PsySpacing.md),
            TextField(
              controller: _freq,
              decoration: const InputDecoration(
                labelText: 'Frequency (e.g. once daily)',
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
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(
                  Medication(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    patientId: widget.patientId,
                    name: _name.text.trim(),
                    dose: _dose.text.trim(),
                    frequency: _freq.text.trim(),
                    startedOn: DateTime.now(),
                  ),
                ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Self-contained star button. Owns its own [PatientPinRepository]
/// so the parent header can stay a pure StatelessWidget. The set is
/// shared with the patient list because the underlying SP key
/// (`patient_pins_v1`) is the same.
class _PinButton extends StatefulWidget {
  const _PinButton({required this.patientId});
  final String patientId;

  @override
  State<_PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<_PinButton> {
  final PatientPinRepository _repo = PatientPinRepository();

  @override
  void initState() {
    super.initState();
    unawaited(_repo.initialize());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: _repo.listenable,
      builder: (context, pinned, _) {
        final isPinned = pinned.contains(widget.patientId);
        return IconButton(
          tooltip: isPinned ? 'Unpin from roster top' : 'Pin to roster top',
          onPressed: () => unawaited(_repo.toggle(widget.patientId)),
          icon: Icon(
            isPinned ? Icons.star : Icons.star_outline,
            color: isPinned
                ? const Color(0xFFD97706)
                : cs.onSurface.withValues(alpha: 0.55),
          ),
        );
      },
    );
  }
}
