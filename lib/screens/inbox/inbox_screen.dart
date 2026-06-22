import 'package:flutter/material.dart';

import '../../models/inbox_item.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/inbox` — Inbox + Tasks toplevel (rapor 12 §3 finding).
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  InboxItemKind? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.utc(2026, 6, 3, 9);
    final items = _demoItems(now);
    final filtered = _filter == null
        ? items
        : items.where((i) => i.kind == _filter).toList();
    final unread = items.where((i) => i.unread).length;
    final overdue = items.where((i) => i.isOverdue(at: now)).length;

    return AppShell(
      routeName: '/inbox',
      title: 'Inbox',
      subtitle:
          'Patient messages, lab results, team notes, tasks — '
          'everything that needs you in one queue.',
      scrollable: false,
      breadcrumbs: const [Crumb('Home', '/dashboard'), Crumb('Inbox', null)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StatChip(
                label: 'Unread',
                value: '$unread',
                tone: PsyBadgeTone.info,
                cs: cs,
                theme: theme,
              ),
              const SizedBox(width: PsySpacing.sm),
              _StatChip(
                label: 'Overdue',
                value: '$overdue',
                tone: overdue == 0
                    ? PsyBadgeTone.success
                    : PsyBadgeTone.warning,
                cs: cs,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          _FilterBar(
            current: _filter,
            onChanged: (k) => setState(() => _filter = k),
            cs: cs,
          ),
          const SizedBox(height: PsySpacing.md),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No items in this view.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: PsySpacing.sm),
                    itemBuilder: (_, i) => _ItemRow(
                      item: filtered[i],
                      now: now,
                      theme: theme,
                      cs: cs,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<InboxItem> _demoItems(DateTime now) {
    return [
      InboxItem(
        id: 'i-1',
        kind: InboxItemKind.patientMessage,
        fromUid: 'p-1',
        subject: 'John Demo · Question about meds',
        bodyPreview:
            'Should I take my morning dose with food? My stomach has been '
            'sensitive this week.',
        receivedAt: now.subtract(const Duration(hours: 2)),
        subjectPatientId: 'demo-1',
      ),
      InboxItem(
        id: 'i-2',
        kind: InboxItemKind.labResult,
        fromUid: 'lab',
        subject: 'Lab · CBC complete · Maria Sample',
        bodyPreview: 'All values within range. Hb 13.1 g/dL.',
        receivedAt: now.subtract(const Duration(hours: 6)),
        subjectPatientId: 'demo-2',
        readAt: now.subtract(const Duration(hours: 1)),
      ),
      InboxItem(
        id: 'i-3',
        kind: InboxItemKind.task,
        fromUid: 'system',
        subject: 'Co-sign trainee SOAP note · Sven Müller',
        bodyPreview:
            'Trainee draft from 2026-06-02 awaiting supervisor co-sign.',
        receivedAt: now.subtract(const Duration(days: 1)),
        subjectPatientId: 'demo-3',
        dueAt: now.subtract(const Duration(hours: 3)),
      ),
      InboxItem(
        id: 'i-4',
        kind: InboxItemKind.teamNote,
        fromUid: 'admin',
        subject: 'Region migration — please confirm by Friday',
        bodyPreview:
            'Operations team is reviewing the EU → US region migration '
            'request. Please confirm or cancel from /settings/region.',
        receivedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.tone,
    required this.cs,
    required this.theme,
  });
  final String label;
  final String value;
  final PsyBadgeTone tone;
  final ColorScheme cs;
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.md,
        vertical: PsySpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(PsyRadius.md),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: PsySpacing.sm),
          PsyBadge(label: value, tone: tone),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.current,
    required this.onChanged,
    required this.cs,
  });
  final InboxItemKind? current;
  final ValueChanged<InboxItemKind?> onChanged;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: PsySpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: current == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final k in InboxItemKind.values)
          ChoiceChip(
            label: Text(k.label),
            selected: current == k,
            onSelected: (_) => onChanged(k),
          ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.now,
    required this.theme,
    required this.cs,
  });
  final InboxItem item;
  final DateTime now;
  final ThemeData theme;
  final ColorScheme cs;

  IconData _iconFor(InboxItemKind k) {
    switch (k) {
      case InboxItemKind.patientMessage:
        return Icons.chat_bubble_outline;
      case InboxItemKind.labResult:
        return Icons.science_outlined;
      case InboxItemKind.teamNote:
        return Icons.group_outlined;
      case InboxItemKind.task:
        return Icons.check_box_outline_blank;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue = item.isOverdue(at: now);
    return PsyCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Icon(
              _iconFor(item.kind),
              color: cs.onPrimaryContainer,
              size: 18,
            ),
          ),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.subject,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: item.unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (item.unread)
                      const PsyBadge(label: 'New', tone: PsyBadgeTone.info),
                    if (overdue) ...[
                      const SizedBox(width: 4),
                      const PsyBadge(
                        label: 'Overdue',
                        tone: PsyBadgeTone.warning,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.bodyPreview,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.kind.label} · '
                  '${item.receivedAt.toIso8601String().split("T").first}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
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
