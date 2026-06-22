import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/analytics/caseload_outcomes_metrics.dart';
import '../../services/data/assessment_repository.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_repository.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_skeleton.dart';
import '../../widgets/outcomes/caseload_outcomes_panel.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;

/// `/outcomes` — PHQ-9 + GAD-7 trend dashboard.
class OutcomesDashboardScreen extends StatefulWidget {
  const OutcomesDashboardScreen({super.key, this.args});

  final PatientDetailArgs? args;

  @override
  State<OutcomesDashboardScreen> createState() =>
      _OutcomesDashboardScreenState();
}

class _OutcomesDashboardScreenState extends State<OutcomesDashboardScreen> {
  PatientDetailArgs? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.args;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final args = _picked;
    final patientName = args?.name ?? 'Select a patient';
    final canPickLive = PsyFirebase.isReady;

    return AppShell(
      routeName: '/outcomes',
      title: 'Outcomes',
      subtitle: args != null
          ? 'PHQ-9 + GAD-7 trends with severity bands · ${args.name}'
          : 'PHQ-9 + GAD-7 trends with severity bands — pick a patient to begin.',
      scrollable: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Lede(theme: theme, cs: cs, patientName: patientName),
          const SizedBox(height: PsySpacing.xl),
          // B20 (Sprint 9) — caseload roll-up. Demo data lives ONLY in
          // demo mode; in live mode we hide the panel until the
          // assessment repository streams a real roster (Sprint 10),
          // so a clinician never sees fabricated aggregate numbers
          // alongside a real patient's chart.
          if (!canPickLive) ...[
            CaseloadOutcomesPanel(
              instrumentLabel: 'PHQ-9 · demo caseload roll-up',
              metrics: buildCaseloadMetrics(
                instrument: 'phq9',
                series: const [
                  PatientOutcomeSeries(
                    patientId: 'demo-1',
                    instrument: 'phq9',
                    scores: [18, 14, 11, 9, 7],
                  ),
                  PatientOutcomeSeries(
                    patientId: 'demo-2',
                    instrument: 'phq9',
                    scores: [15, 12, 10],
                  ),
                  PatientOutcomeSeries(
                    patientId: 'demo-3',
                    instrument: 'phq9',
                    scores: [22, 17, 12, 8],
                  ),
                ],
              ),
            ),
            const SizedBox(height: PsySpacing.lg),
          ],
          if (canPickLive)
            _PatientPicker(
              picked: args,
              onPick: (p) => setState(() => _picked = p),
              theme: theme,
              cs: cs,
            ),
          const SizedBox(height: PsySpacing.lg),
          if (!canPickLive || args == null)
            _DemoChartCard(theme: theme, cs: cs)
          else
            _LiveChartCard(theme: theme, cs: cs, patientId: args.id),
          const SizedBox(height: PsySpacing.xxl),
          _LegendCard(theme: theme, cs: cs),
        ],
      ),
    );
  }
}

class _PatientPicker extends StatelessWidget {
  const _PatientPicker({
    required this.picked,
    required this.onPick,
    required this.theme,
    required this.cs,
  });
  final PatientDetailArgs? picked;
  final ValueChanged<PatientDetailArgs?> onPick;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return PsyCard(
        child: Text(
          'Sign in to load your patient roster.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    return StreamBuilder<List<PatientDoc>>(
      stream: PatientRepository.instance.watch(profile.clinicId),
      builder: (ctx, snap) {
        final patients = snap.data ?? const <PatientDoc>[];
        if (patients.isEmpty) {
          return PsyCard(
            child: Row(
              children: [
                Icon(Icons.group_outlined, color: cs.primary, size: 20),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    'No patients yet. Add one from /patients to see live outcomes.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/patients'),
                  child: const Text('Open patients'),
                ),
              ],
            ),
          );
        }
        return PsyCard(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.xl,
            vertical: PsySpacing.md,
          ),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: cs.primary, size: 20),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  value: picked?.id,
                  hint: const Text('Select a patient'),
                  items: patients
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.fullName),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final p = patients.firstWhere((x) => x.id == id);
                    onPick(PatientDetailArgs(id: p.id, name: p.fullName));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Lede extends StatelessWidget {
  const _Lede({
    required this.theme,
    required this.cs,
    required this.patientName,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final String patientName;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outcome trend',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        Text(
          'PHQ-9 (depression) and GAD-7 (anxiety) scores plotted over '
          'time for $patientName. Lower is better; severity bands shaded.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _DemoChartCard extends StatelessWidget {
  const _DemoChartCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    const phq9 = [
      FlSpot(0, 18),
      FlSpot(1, 14),
      FlSpot(2, 11),
      FlSpot(3, 9),
      FlSpot(4, 7),
    ];
    const gad7 = [
      FlSpot(0, 13),
      FlSpot(1, 10),
      FlSpot(2, 8),
      FlSpot(3, 6),
      FlSpot(4, 5),
    ];
    return _ChartCard(
      theme: theme,
      cs: cs,
      phq9: phq9,
      gad7: gad7,
      isDemo: true,
    );
  }
}

class _LiveChartCard extends StatelessWidget {
  const _LiveChartCard({
    required this.theme,
    required this.cs,
    required this.patientId,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return PsyCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PsySpacing.xxl),
          child: Center(
            child: Text(
              'Sign in to load outcomes.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    return StreamBuilder<List<AssessmentDoc>>(
      stream: AssessmentRepository.instance.watchForPatient(
        profile.clinicId,
        patientId,
      ),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          // Skeleton mirrors the trend-card shape (PsyCard wrapper +
          // ~240 px chart canvas) so the page layout doesn't jump
          // between waiting and data.
          return const PsyCard(
            child: PsySkeletonGroup(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: PsySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PsySkeletonLine(width: 160),
                    SizedBox(height: PsySpacing.lg),
                    PsySkeletonBlock(height: 220),
                  ],
                ),
              ),
            ),
          );
        }
        final list = snap.data ?? const <AssessmentDoc>[];
        if (list.length < 2) {
          return PsyCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.show_chart,
                    color: cs.onSurface.withValues(alpha: 0.4),
                    size: 36,
                  ),
                  const SizedBox(height: PsySpacing.md),
                  Text(
                    'Need at least 2 datapoints to plot a trend.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }
        list.sort((a, b) {
          final ad = a.completedAt ?? DateTime(2000);
          final bd = b.completedAt ?? DateTime(2000);
          return ad.compareTo(bd);
        });
        final phq9 = <FlSpot>[];
        final gad7 = <FlSpot>[];
        for (var i = 0; i < list.length; i++) {
          final a = list[i];
          final x = i.toDouble();
          if (a.type == 'phq9') phq9.add(FlSpot(x, a.score.toDouble()));
          if (a.type == 'gad7') gad7.add(FlSpot(x, a.score.toDouble()));
        }
        return _ChartCard(
          theme: theme,
          cs: cs,
          phq9: phq9,
          gad7: gad7,
          isDemo: false,
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.theme,
    required this.cs,
    required this.phq9,
    required this.gad7,
    required this.isDemo,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final List<FlSpot> phq9;
  final List<FlSpot> gad7;
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.fromLTRB(
        PsySpacing.lg,
        PsySpacing.xl,
        PsySpacing.xl,
        PsySpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Last datapoints',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (isDemo)
                const PsyBadge(label: 'Demo data', tone: PsyBadgeTone.warning),
              const SizedBox(width: PsySpacing.sm),
              _legendDot(color: PsyColors.danger, label: 'PHQ-9'),
              const SizedBox(width: PsySpacing.md),
              _legendDot(color: PsyColors.info, label: 'GAD-7'),
            ],
          ),
          const SizedBox(height: PsySpacing.xl),
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 27,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: cs.outlineVariant, strokeWidth: 0.5),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'T${v.toInt() + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  _line(phq9, PsyColors.danger),
                  _line(gad7, PsyColors.info),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: cs.inverseSurface,
                    getTooltipItems: (items) => items
                        .map(
                          (s) => LineTooltipItem(
                            s.bar.color == PsyColors.danger
                                ? 'PHQ-9 · ${s.y.toInt()}'
                                : 'GAD-7 · ${s.y.toInt()}',
                            TextStyle(
                              color: cs.onInverseSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          _DeltaSummary(phq9: phq9, gad7: gad7, theme: theme, cs: cs),
        ],
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) => LineChartBarData(
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 2.6,
    dotData: FlDotData(
      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
        radius: 4,
        color: color,
        strokeWidth: 2,
        strokeColor: Colors.white,
      ),
    ),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );

  Widget _legendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: PsySpacing.xs),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DeltaSummary extends StatelessWidget {
  const _DeltaSummary({
    required this.phq9,
    required this.gad7,
    required this.theme,
    required this.cs,
  });
  final List<FlSpot> phq9;
  final List<FlSpot> gad7;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final dPhq9 = _delta(phq9);
    final dGad7 = _delta(gad7);
    return Row(
      children: [
        Expanded(child: _deltaTile('PHQ-9', dPhq9)),
        const SizedBox(width: PsySpacing.lg),
        Expanded(child: _deltaTile('GAD-7', dGad7)),
      ],
    );
  }

  Widget _deltaTile(String label, double? d) {
    final improving = d != null && d < 0;
    final color = d == null
        ? cs.onSurface
        : (improving ? PsyColors.success : PsyColors.warning);
    final icon = d == null
        ? Icons.remove
        : (improving ? Icons.trending_down : Icons.trending_up);
    return Container(
      padding: const EdgeInsets.all(PsySpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Text(
              d == null
                  ? '$label · not enough data'
                  : '$label · ${d.abs().toStringAsFixed(0)} point '
                        '${improving ? 'improvement' : 'increase'}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _delta(List<FlSpot> spots) {
    if (spots.length < 2) return null;
    return spots.last.y - spots.first.y;
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Severity bands',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _band('Minimal (0–4)', PsyColors.riskMinimal),
          _band('Mild (5–9)', PsyColors.riskMild),
          _band('Moderate (10–14)', PsyColors.riskModerate),
          _band('Severe (15+)', PsyColors.riskSevere),
        ],
      ),
    );
  }

  Widget _band(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(PsyRadius.xs),
            ),
          ),
          const SizedBox(width: PsySpacing.md),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
