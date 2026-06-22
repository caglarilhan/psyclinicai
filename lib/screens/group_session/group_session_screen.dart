import 'package:flutter/material.dart';

import '../../models/group_session.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';

/// `/group_session` — multi-patient group therapy roster (Sprint 9
/// model wired to UI in Sprint 17).
///
/// HIPAA constraint surfaced visually: each roster row carries a
/// per-patient sub-note pointer rather than a shared text area, so
/// one patient's note never leaks into another's chart. The capacity
/// chip mirrors `GroupSession.maxRosterSize = 8`.
class GroupSessionScreen extends StatelessWidget {
  const GroupSessionScreen({super.key, this.session});

  /// Optional injected session for tests / preview. Production wires
  /// this in via the Sprint 17 group repository.
  final GroupSession? session;

  GroupSession _demo() => GroupSession(
    id: 'gs-demo',
    clinicId: 'c-demo',
    modalityLabel: 'DBT skills group · Thursdays',
    scheduledAt: DateTime.utc(2026, 6, 11, 17),
    roster: const [
      GroupSessionAttendance(
        patientId: 'p-001',
        subNoteId: 'note-001',
        attended: true,
      ),
      GroupSessionAttendance(
        patientId: 'p-002',
        subNoteId: 'note-002',
        attended: true,
        notes: 'arrived 10 min late',
      ),
      GroupSessionAttendance(patientId: 'p-003', subNoteId: 'note-003'),
    ],
    facilitatorNote: 'opened with grounding exercise',
  );

  @override
  Widget build(BuildContext context) {
    final s = session ?? _demo();
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return AppShell(
      routeName: '/group_session',
      title: s.modalityLabel,
      subtitle: 'Scheduled ${s.scheduledAt.toIso8601String().substring(0, 16)}',
      primaryAction: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: s.isAtCapacity
              ? PsyColors.warning.withValues(alpha: 0.15)
              : cs.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${s.roster.length} / ${GroupSession.maxRosterSize}'
          '${s.isAtCapacity ? ' · cap' : ''}',
          style: t.labelMedium?.copyWith(
            color: s.isAtCapacity ? PsyColors.warning : cs.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.facilitatorNote.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PsySpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_outlined, color: cs.onSurfaceVariant),
                    const SizedBox(width: PsySpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Facilitator note', style: t.labelMedium),
                          const SizedBox(height: 2),
                          Text(s.facilitatorNote, style: t.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: PsySpacing.sm),
          Text('Roster', style: t.titleSmall),
          const SizedBox(height: PsySpacing.xs),
          for (final row in s.roster) _RosterRow(row: row),
          const SizedBox(height: PsySpacing.md),
          Container(
            padding: const EdgeInsets.all(PsySpacing.sm),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(PsyRadius.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: cs.onTertiaryContainer,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Per-patient subjective notes live in each '
                    "patient's own chart. This roster only carries "
                    'PHI-light operational fields.',
                    style: t.bodySmall?.copyWith(color: cs.onTertiaryContainer),
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

class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.row});
  final GroupSessionAttendance row;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: row.attended
                    ? PsyColors.success.withValues(alpha: 0.15)
                    : PsyColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                row.attended ? 'attended' : 'absent',
                style: t.labelSmall?.copyWith(
                  color: row.attended ? PsyColors.success : PsyColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.patientId, style: t.titleSmall),
                  if (row.notes.isNotEmpty)
                    Text(
                      row.notes,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new),
              label: const Text('Sub-note'),
            ),
          ],
        ),
      ),
    );
  }
}
