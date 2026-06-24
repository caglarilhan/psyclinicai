/// `/admin/risk_coverage` — clinical-leadership view of the risk
/// signal ledger. Surfaces: overall coverage rate, per-category
/// breakdown, and the unacknowledged high-severity short list with
/// inline [Acknowledge] buttons.
///
/// Read path uses [RiskSignalRepository] for the snapshot and
/// [RiskCoverageStats] for the aggregation; write path goes
/// straight through the repo's [RiskSignalRepository.acknowledge]
/// so the ledger remains the single source of truth.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/copilot/risk_coverage_stats.dart';
import '../../services/copilot/risk_signal_service.dart' show RiskCategory;
import '../../services/data/auth_service.dart';
import '../../services/data/risk_signal_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';

class RiskCoverageScreen extends StatefulWidget {
  const RiskCoverageScreen({super.key, this.repo});

  /// Override for tests / future DI; production wires a default
  /// [RiskSignalRepository] (SharedPreferences bucket).
  final RiskSignalRepository? repo;

  @override
  State<RiskCoverageScreen> createState() => _RiskCoverageScreenState();
}

class _RiskCoverageScreenState extends State<RiskCoverageScreen> {
  late final RiskSignalRepository _repo = widget.repo ?? RiskSignalRepository();
  bool _loading = true;
  RiskCoverageReport _report = const RiskCoverageReport(
    total: 0,
    acknowledged: 0,
    breakdown: [],
    unacknowledgedHighSeverity: [],
    sessionsImpacted: <String>{},
  );

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() {
      _report = RiskCoverageStats.summarise(_repo.all);
      _loading = false;
    });
  }

  Future<void> _acknowledge(PersistedRiskSignal s) async {
    final actor =
        FirebaseAuthService.instance.profile?.email ??
        'unknown@psyclinicai.com';
    await _repo.acknowledge(s.id, actor: actor);
    if (!mounted) return;
    setState(() => _report = RiskCoverageStats.summarise(_repo.all));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/admin/risk_coverage',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Risk coverage', null),
      ],
      title: 'Risk signal coverage',
      subtitle: 'Were the signals raised this period acted on?',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _Body(report: _report, onAck: _acknowledge),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report, required this.onAck});

  final RiskCoverageReport report;
  final Future<void> Function(PersistedRiskSignal) onAck;

  @override
  Widget build(BuildContext context) {
    if (report.total == 0) {
      return const PsyEmptyState(
        icon: Icons.shield_outlined,
        title: 'No signals recorded yet',
        body:
            'When a live session surfaces a risk indicator, it shows up here '
            'so leadership can confirm follow-up.',
      );
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final coveragePct = (report.coverageRate * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Kpi(
                label: 'Total signals',
                value: report.total.toString(),
                cs: cs,
                theme: theme,
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: _Kpi(
                label: 'Acknowledged',
                value: '${report.acknowledged}',
                cs: cs,
                theme: theme,
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: _Kpi(
                label: 'Coverage rate',
                value: '$coveragePct%',
                cs: cs,
                theme: theme,
                tone: coveragePct >= 80
                    ? PsyBadgeTone.success
                    : coveragePct >= 50
                    ? PsyBadgeTone.warning
                    : PsyBadgeTone.danger,
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: _Kpi(
                label: 'Sessions impacted',
                value: report.sessionsImpacted.length.toString(),
                cs: cs,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.xl),
        Text(
          'Per-category breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        for (final b in report.breakdown.where((b) => b.total > 0))
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.sm),
            child: _CategoryRow(breakdown: b, cs: cs, theme: theme),
          ),
        const SizedBox(height: PsySpacing.xl),
        Text(
          'Open high-severity signals (${report.unacknowledgedHighSeverity.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        if (report.unacknowledgedHighSeverity.isEmpty)
          PsyCard(
            child: Padding(
              padding: const EdgeInsets.all(PsySpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: cs.primary),
                  const SizedBox(width: PsySpacing.md),
                  Text(
                    'Nothing open — every elevated and high signal is acknowledged.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          for (final s in report.unacknowledgedHighSeverity)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _OpenRow(signal: s, cs: cs, theme: theme, onAck: onAck),
            ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.cs,
    required this.theme,
    this.tone = PsyBadgeTone.brand,
  });

  final String label;
  final String value;
  final ColorScheme cs;
  final ThemeData theme;
  final PsyBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: PsySpacing.sm),
            Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: PsySpacing.sm),
                if (tone != PsyBadgeTone.brand)
                  PsyBadge(label: tone.name, tone: tone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.breakdown,
    required this.cs,
    required this.theme,
  });

  final CategoryBreakdown breakdown;
  final ColorScheme cs;
  final ThemeData theme;

  String get _label => switch (breakdown.category) {
    RiskCategory.suicidalIdeation => 'Suicidal ideation',
    RiskCategory.selfHarm => 'Self-harm',
    RiskCategory.harmToOthers => 'Harm to others',
    RiskCategory.substanceUse => 'Substance use',
    RiskCategory.hopelessness => 'Hopelessness',
  };

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${breakdown.acknowledged} / ${breakdown.total}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(PsyRadius.full),
              child: LinearProgressIndicator(
                value: breakdown.coverageRate,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(
                  breakdown.coverageRate >= 0.8
                      ? Colors.green
                      : breakdown.coverageRate >= 0.5
                      ? const Color(0xFFD97706)
                      : cs.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenRow extends StatelessWidget {
  const _OpenRow({
    required this.signal,
    required this.cs,
    required this.theme,
    required this.onAck,
  });

  final PersistedRiskSignal signal;
  final ColorScheme cs;
  final ThemeData theme;
  final Future<void> Function(PersistedRiskSignal) onAck;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.flag, color: cs.error),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: PsySpacing.sm,
                    runSpacing: PsySpacing.xs,
                    children: [
                      PsyBadge(
                        label: signal.severity.name,
                        tone: PsyBadgeTone.danger,
                      ),
                      PsyBadge(
                        label: signal.category.name,
                        tone: PsyBadgeTone.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: PsySpacing.sm),
                  Text(
                    signal.snippet,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PsySpacing.xs),
                  Text(
                    'Session ${signal.sessionId} · ${signal.at.toLocal()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            FilledButton.icon(
              onPressed: () => unawaited(onAck(signal)),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Acknowledge'),
            ),
          ],
        ),
      ),
    );
  }
}
