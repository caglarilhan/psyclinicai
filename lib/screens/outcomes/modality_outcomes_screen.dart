/// `/outcomes/modalities` — clinician-self-view of modality
/// outcomes across the caseload.
///
/// Three tabs, one per modality:
///   - CBT — `intensityDelta` (sum-of-emotions before − after) over
///     time. Positive delta = patient ended better; line trends up.
///   - DBT — Suicidal-ideation peak per week (0-5). Bar height per
///     diary card. Self-harm-act weeks are tinted red.
///   - EMDR — SUDS arc per session (sudsStart → sudsEnd). Each
///     session is a vertical pair of bars (start lighter, end
///     filled); a short filled bar means desensitization landed.
///
/// All telemetry-clean — no PHI, only counts/deltas. The chart
/// helpers in this file (`buildCbtDeltaSeries`,
/// `buildDbtSiPeakSeries`, `buildEmdrSudsArcs`) are unit-tested.
library;

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/modalities/cbt_thought_record.dart';
import '../../models/modalities/dbt_diary_card.dart';
import '../../models/modalities/emdr_session_tracker.dart';
import '../../services/data/modality_session_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';

class ModalityOutcomesScreen extends StatefulWidget {
  const ModalityOutcomesScreen({super.key, this.patientId, this.repository});

  /// When non-null, scope all three tabs to a single patient (used
  /// from the patient chart). Null = caseload aggregate across all
  /// the clinician's modality records.
  final String? patientId;
  final ModalitySessionRepository? repository;

  @override
  State<ModalityOutcomesScreen> createState() => _ModalityOutcomesScreenState();
}

class _ModalityOutcomesScreenState extends State<ModalityOutcomesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final ModalitySessionRepository _repo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _repo = widget.repository ?? ModalitySessionRepository();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<ModalityRecord> _scoped(ModalityKind kind) {
    final all = widget.patientId == null
        ? _repo.all.where((r) => r.kind == kind).toList()
        : _repo.forPatientOfKind(widget.patientId!, kind);
    return all..sort((a, b) => a.sortDate.compareTo(b.sortDate));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/outcomes',
      title: 'Modality outcomes',
      subtitle: widget.patientId == null
          ? 'Caseload-level outcomes for the modality templates you '
                'use.'
          : 'Per-patient outcomes across the modality templates this '
                'patient has data for.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Outcomes', '/outcomes'),
        Crumb('Modalities', null),
      ],
      scrollable: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabs,
                  tabs: const [
                    Tab(text: 'CBT'),
                    Tab(text: 'DBT'),
                    Tab(text: 'EMDR'),
                  ],
                ),
                const SizedBox(height: PsySpacing.lg),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _CbtTab(records: _scoped(ModalityKind.cbt)),
                      _DbtTab(records: _scoped(ModalityKind.dbt)),
                      _EmdrTab(records: _scoped(ModalityKind.emdr)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pure helpers — unit-tested in `test/modality_outcomes_test.dart`.

/// CBT trend points: x = record index (chronological), y = intensity
/// delta. Empty input → empty list.
List<FlSpot> buildCbtDeltaSeries(List<CbtThoughtRecord> records) => [
  for (var i = 0; i < records.length; i++)
    FlSpot(i.toDouble(), records[i].intensityDelta.toDouble()),
];

/// DBT bar entries — one per diary card, y = SI peak that week.
/// Helper carries the `selfHarmAct` flag so the renderer can tint
/// self-harm-act weeks red.
class DbtBar {
  const DbtBar({
    required this.weekStart,
    required this.siPeak,
    required this.selfHarmAct,
  });
  final DateTime weekStart;
  final int siPeak;
  final bool selfHarmAct;
}

List<DbtBar> buildDbtSiPeakSeries(List<DbtDiaryCard> cards) => [
  for (final c in cards)
    DbtBar(
      weekStart: c.weekStart,
      siPeak: c.suicidalIdeationPeakOfWeek,
      selfHarmAct: c.selfHarmActOccurred,
    ),
];

/// EMDR per-session arc: start vs end SUDS.
class EmdrArc {
  const EmdrArc({
    required this.recordedAt,
    required this.sudsStart,
    required this.sudsEnd,
  });
  final DateTime recordedAt;
  final int sudsStart;
  final int? sudsEnd;

  int? get delta => sudsEnd == null ? null : sudsEnd! - sudsStart;
  bool get reduced => delta != null && delta! <= 0;
}

List<EmdrArc> buildEmdrSudsArcs(List<EmdrSessionTracker> sessions) => [
  for (final s in sessions)
    EmdrArc(
      recordedAt: s.updatedAt ?? s.createdAt,
      sudsStart: s.sudsStart,
      sudsEnd: s.sudsEnd,
    ),
];

// ---------------------------------------------------------------------------
// Tabs

class _CbtTab extends StatelessWidget {
  const _CbtTab({required this.records});
  final List<ModalityRecord> records;

  @override
  Widget build(BuildContext context) {
    final cbt = [
      for (final r in records)
        if (r.cbtRecord != null) r.cbtRecord!,
    ];
    if (cbt.isEmpty) {
      return const PsyEmptyState(
        icon: Icons.show_chart_outlined,
        title: 'No CBT records yet',
        body:
            'Save a thought record in a session and the intensity-delta '
            'trend lights up here.',
      );
    }
    final spots = buildCbtDeltaSeries(cbt);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ListView(
      children: [
        PsyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Intensity delta — sum(before) − sum(after) per record. '
                'Positive = patient ended better.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        color: cs.primary,
                        isCurved: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        for (final r in cbt.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.md),
            child: PsyCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _date(r.recordedAt),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.situation.isEmpty ? '(no situation)' : r.situation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PsySpacing.md),
                  _DeltaPill(value: r.intensityDelta),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DbtTab extends StatelessWidget {
  const _DbtTab({required this.records});
  final List<ModalityRecord> records;

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final r in records)
        if (r.dbtCard != null) r.dbtCard!,
    ];
    if (cards.isEmpty) {
      return const PsyEmptyState(
        icon: Icons.calendar_view_week_outlined,
        title: 'No DBT diary cards yet',
        body: 'Once a diary card lands, this tab shows weekly SI peaks.',
      );
    }
    final bars = buildDbtSiPeakSeries(cards);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ListView(
      children: [
        PsyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Suicidal ideation peak per week (0-5). Red bars = a '
                'self-harm act was logged that week.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: 5,
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < bars.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: bars[i].siPeak.toDouble(),
                              color: bars[i].selfHarmAct
                                  ? cs.error
                                  : cs.primary,
                              width: 14,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        for (final c in cards.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.md),
            child: PsyCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week of ${_date(c.weekStart)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${c.filledDays}/7 days logged · SI peak '
                          '${c.suicidalIdeationPeakOfWeek}/5',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (c.selfHarmActOccurred)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'NSSI act',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmdrTab extends StatelessWidget {
  const _EmdrTab({required this.records});
  final List<ModalityRecord> records;

  @override
  Widget build(BuildContext context) {
    final sessions = [
      for (final r in records)
        if (r.emdrSession != null) r.emdrSession!,
    ];
    if (sessions.isEmpty) {
      return const PsyEmptyState(
        icon: Icons.timeline_outlined,
        title: 'No EMDR sessions yet',
        body: 'After a session, the SUDS arc per session shows up here.',
      );
    }
    final arcs = buildEmdrSudsArcs(sessions);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ListView(
      children: [
        PsyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SUDS per session — light bar = start, filled bar = end. '
                'A short filled bar means desensitization landed; a tall '
                'filled bar means SUDS held high.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: PsySpacing.md),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: 10,
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < arcs.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: arcs[i].sudsStart.toDouble(),
                              color: cs.primary.withValues(alpha: 0.25),
                              width: 14,
                            ),
                            BarChartRodData(
                              toY: (arcs[i].sudsEnd ?? arcs[i].sudsStart)
                                  .toDouble(),
                              color: arcs[i].reduced ? cs.primary : cs.error,
                              width: 14,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        for (final s in sessions.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.md),
            child: PsyCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _date(s.updatedAt ?? s.createdAt),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.targetMemory.isEmpty
                              ? '(no target memory recorded)'
                              : s.targetMemory,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PsySpacing.md),
                  _SudsArcPill(
                    arc: EmdrArc(
                      recordedAt: s.updatedAt ?? s.createdAt,
                      sudsStart: s.sudsStart,
                      sudsEnd: s.sudsEnd,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final positive = value >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: positive
            ? cs.primary.withValues(alpha: 0.12)
            : cs.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_down : Icons.trending_up,
            size: 14,
            color: positive ? cs.primary : cs.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${value.abs()}',
            style: TextStyle(
              color: positive ? cs.primary : cs.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SudsArcPill extends StatelessWidget {
  const _SudsArcPill({required this.arc});
  final EmdrArc arc;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final end = arc.sudsEnd;
    final theme = Theme.of(context);
    if (end == null) {
      return Text(
        '${arc.sudsStart} → —',
        style: theme.textTheme.labelLarge?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.7),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: arc.reduced
            ? cs.primary.withValues(alpha: 0.12)
            : cs.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${arc.sudsStart} → $end',
        style: TextStyle(
          color: arc.reduced ? cs.primary : cs.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _date(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
