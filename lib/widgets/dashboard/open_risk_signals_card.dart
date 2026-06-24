/// Dashboard tile that surfaces the top 3 unacknowledged
/// elevated / high-severity risk signals across the clinician's
/// caseload. Hidden when the open list is empty so the dashboard
/// stays clean.
///
/// "Review all" links to /admin/risk_coverage where the leadership
/// panel shows the full ledger + Acknowledge / Acknowledge-all
/// affordances.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/copilot/risk_coverage_stats.dart';
import '../../services/copilot/risk_signal_service.dart' show RiskCategory;
import '../../services/data/risk_signal_repository.dart';
import '../../theme/tokens.dart';
import '../../utils/time_format.dart';
import '../ds/psy_badge.dart';
import '../ds/psy_card.dart';

class OpenRiskSignalsCard extends StatefulWidget {
  const OpenRiskSignalsCard({super.key, this.repo});

  /// Override for tests; production wires a default
  /// [RiskSignalRepository].
  final RiskSignalRepository? repo;

  @override
  State<OpenRiskSignalsCard> createState() => _OpenRiskSignalsCardState();
}

class _OpenRiskSignalsCardState extends State<OpenRiskSignalsCard> {
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    final open = _report.unacknowledgedHighSeverity;
    if (open.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shown = open.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Open risk signals (${open.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/admin/risk_coverage'),
              icon: const Icon(Icons.shield_outlined, size: 18),
              label: const Text('Review all'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.md),
        for (final s in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.sm),
            child: _SignalTile(signal: s, theme: theme, cs: cs),
          ),
        if (open.length > shown.length)
          Padding(
            padding: const EdgeInsets.only(top: PsySpacing.xs),
            child: Text(
              '+ ${open.length - shown.length} more on the coverage panel.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({
    required this.signal,
    required this.theme,
    required this.cs,
  });

  final PersistedRiskSignal signal;
  final ThemeData theme;
  final ColorScheme cs;

  String get _categoryLabel => switch (signal.category) {
    RiskCategory.suicidalIdeation => 'Suicidal ideation',
    RiskCategory.selfHarm => 'Self-harm',
    RiskCategory.harmToOthers => 'Harm to others',
    RiskCategory.substanceUse => 'Substance use',
    RiskCategory.hopelessness => 'Hopelessness',
  };

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      onTap: () => Navigator.of(context).pushNamed('/admin/risk_coverage'),
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
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
                        label: _categoryLabel,
                        tone: PsyBadgeTone.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: PsySpacing.xs),
                  Text(
                    signal.snippet,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PsySpacing.xxs),
                  Text(
                    '${TimeFormat.relativeDay(signal.at)} '
                    '${TimeFormat.localClock(signal.at)} · session '
                    '${signal.sessionId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
