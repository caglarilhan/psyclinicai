/// Dashboard tile that surfaces the clinician's three most recent
/// audit log entries from today. Hidden when the ledger is empty
/// for today so the dashboard stays clean on a fresh-install or
/// quiet day.
///
/// "View audit log" routes to `/settings/audit` where the full
/// table + integrity verification lives.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/audit_log_entry.dart';
import '../../services/data/audit_log_repository.dart';
import '../../theme/tokens.dart';
import '../../utils/time_format.dart';
import '../ds/psy_badge.dart';
import '../ds/psy_card.dart';

class RecentAuditTile extends StatefulWidget {
  const RecentAuditTile({super.key, this.repo, this.actor});

  /// Override for tests; production wires a default
  /// [AuditLogRepository].
  final AuditLogRepository? repo;

  /// Filter to this actor's rows only. When null we render every
  /// row from today (admin view).
  final String? actor;

  @override
  State<RecentAuditTile> createState() => _RecentAuditTileState();
}

class _RecentAuditTileState extends State<RecentAuditTile> {
  late final AuditLogRepository _repo = widget.repo ?? AuditLogRepository();
  bool _loading = true;
  List<AuditLogEntry> _todays = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    final now = DateTime.now().toUtc();
    final dayStart = DateTime.utc(now.year, now.month, now.day);
    final actor = widget.actor;
    final candidates = actor == null ? _repo.all : _repo.forActor(actor);
    final filtered = candidates
        .where((e) => !e.timestampUtc.isBefore(dayStart))
        .toList(growable: false);
    setState(() {
      _todays = filtered;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_todays.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final shown = _todays.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Today's audit activity (${_todays.length})",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/settings/audit'),
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('View audit log'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.md),
        for (final e in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.sm),
            child: _AuditRow(entry: e, theme: theme, cs: cs),
          ),
        if (_todays.length > shown.length)
          Padding(
            padding: const EdgeInsets.only(top: PsySpacing.xs),
            child: Text(
              '+ ${_todays.length - shown.length} more in the audit log.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.entry, required this.theme, required this.cs});

  final AuditLogEntry entry;
  final ThemeData theme;
  final ColorScheme cs;

  PsyBadgeTone get _resultTone => switch (entry.result) {
    AuditResult.success => PsyBadgeTone.success,
    AuditResult.failure => PsyBadgeTone.danger,
    AuditResult.denied => PsyBadgeTone.warning,
  };

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      onTap: () => Navigator.of(context).pushNamed('/settings/audit'),
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.history_outlined, color: cs.primary, size: 20),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PsyBadge(label: entry.kind, tone: PsyBadgeTone.info),
                      const SizedBox(width: PsySpacing.sm),
                      PsyBadge(label: entry.result.name, tone: _resultTone),
                    ],
                  ),
                  const SizedBox(height: PsySpacing.xs),
                  Text(
                    '${entry.action} · ${entry.entity}',
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: PsySpacing.xxs),
                  Text(
                    '${TimeFormat.localClock(entry.timestampUtc)} · '
                    '${entry.actor}',
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
