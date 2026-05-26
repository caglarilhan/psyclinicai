import 'package:flutter/material.dart';

import '../../services/data/assessment_repository.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';
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
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Send screener'),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              PsyButton(
                label: 'PHQ-9',
                icon: Icons.psychology_outlined,
                size: PsyButtonSize.sm,
                onPressed: () => Navigator.of(context)
                    .pushNamed('/assessments/phq9'),
              ),
              const SizedBox(width: PsySpacing.md),
              PsyButton(
                label: 'GAD-7',
                icon: Icons.spa_outlined,
                size: PsyButtonSize.sm,
                variant: PsyButtonVariant.secondary,
                onPressed: () => Navigator.of(context)
                    .pushNamed('/assessments/gad7'),
              ),
              const Spacer(),
              PsyButton(
                label: 'View trend',
                icon: Icons.show_chart,
                size: PsyButtonSize.sm,
                variant: PsyButtonVariant.ghost,
                onPressed: () => Navigator.of(context)
                    .pushNamed('/outcomes', arguments: args),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.xxl),
          const _SectionTitle('Treatment plan'),
          const SizedBox(height: PsySpacing.md),
          PsyButton(
            label: 'Open treatment plan',
            icon: Icons.assignment_outlined,
            size: PsyButtonSize.sm,
            onPressed: () => Navigator.of(context)
                .pushNamed('/treatment_plan', arguments: args),
          ),
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
  const _Header(
      {required this.args, required this.theme, required this.cs});
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
                Text(args.name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
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
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ));
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
      return _emptyCard(context, 'Sign in to load assessments.');
    }
    return StreamBuilder<List<AssessmentDoc>>(
      stream: AssessmentRepository.instance
          .watchForPatient(profile.clinicId, patientId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(PsySpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final list = snap.data ?? const <AssessmentDoc>[];
        if (list.isEmpty) {
          return _emptyCard(context,
              'No assessments yet. Send a PHQ-9 or GAD-7 to start the trend.');
        }
        return Column(
          children: list
              .map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: PsySpacing.md),
                    child: _AssessmentTile(a: a),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _demoAssessments(BuildContext context) {
    return Column(
      children: const [
        _DemoAssessmentTile(
            type: 'phq9',
            score: 14,
            severity: 'Moderate',
            date: '2026-05-09',
            tone: PsyBadgeTone.warning),
        SizedBox(height: PsySpacing.md),
        _DemoAssessmentTile(
            type: 'phq9',
            score: 9,
            severity: 'Mild',
            date: '2026-05-16',
            tone: PsyBadgeTone.info),
        SizedBox(height: PsySpacing.md),
        _DemoAssessmentTile(
            type: 'gad7',
            score: 6,
            severity: 'Mild',
            date: '2026-05-16',
            tone: PsyBadgeTone.info),
      ],
    );
  }

  Widget _emptyCard(BuildContext context, String body) => PsyCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PsySpacing.lg),
          child: Center(
            child: Text(body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    )),
          ),
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
            a.type == 'phq9'
                ? Icons.psychology_outlined
                : Icons.spa_outlined,
            color: cs.primary,
            size: 22,
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a.type.toUpperCase()} · score ${a.score}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (a.completedAt != null) ...[
                  const SizedBox(height: PsySpacing.xxs),
                  Text(
                    'Completed ${_fmt(a.completedAt!)}',
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
                icon: Icons.warning_amber_rounded),
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

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
            type == 'phq9'
                ? Icons.psychology_outlined
                : Icons.spa_outlined,
            color: cs.primary,
            size: 22,
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${type.toUpperCase()} · score $score',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: PsySpacing.xxs),
                Text('Completed $date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    )),
              ],
            ),
          ),
          PsyBadge(label: severity, tone: tone),
        ],
      ),
    );
  }
}
