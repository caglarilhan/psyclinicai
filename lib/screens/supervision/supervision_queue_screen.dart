import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/supervision_review.dart';
import '../../services/supervision_review_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';

/// `/supervision/queue` — trainee → supervisor co-sign queue (Sprint 9).
///
/// The supervisor sees pending notes and can approve, request changes,
/// or co-sign. Scaffold-grade: it shows the queue, the lifecycle, and
/// the empty state so a clinic owner can see how the workflow lands
/// before we wire it to real session notes (Sprint 10).
class SupervisionQueueScreen extends StatefulWidget {
  const SupervisionQueueScreen({super.key, this.supervisorId = 'sup-demo'});

  final String supervisorId;

  @override
  State<SupervisionQueueScreen> createState() => _SupervisionQueueScreenState();
}

class _SupervisionQueueScreenState extends State<SupervisionQueueScreen> {
  final _repo = InMemorySupervisionReviewRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChange);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _seed() {
    _repo.submit(
      clinicId: 'clinic-demo',
      traineeId: 'trainee-${DateTime.now().millisecondsSinceEpoch % 100}',
      supervisorId: widget.supervisorId,
      sessionNoteId: 'note-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void _decide(SupervisionReview row, SupervisionReviewStatus next) {
    final messenger = ScaffoldMessenger.of(context);
    final blocked = row.transitionBlockedReason(next);
    if (blocked != null) {
      messenger.showSnackBar(SnackBar(content: Text(blocked)));
      return;
    }
    _repo.decide(id: row.id, next: next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final open = _repo.openQueueFor(widget.supervisorId);
    final closed = _repo
        .allFor(widget.supervisorId)
        .where((r) => !r.isOpen)
        .toList(growable: false);

    return AppShell(
      routeName: '/supervision/queue',
      title: l.supervisionQueueTitle,
      subtitle: l.supervisionQueueSubtitle,
      primaryAction: FilledButton.icon(
        onPressed: _seed,
        icon: const Icon(Icons.add),
        label: const Text('Add demo submission'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CoSignDisclaimerBanner(),
          const SizedBox(height: PsySpacing.md),
          _SectionHeader(
            label: '${l.supervisionOpenSection} (${open.length})',
            description:
                'Pending decisions. A co-sign converts the note into a '
                'countersigned clinical record.',
          ),
          if (open.isEmpty)
            _EmptyState(message: l.supervisionEmptyOpen)
          else
            ...open.map(
              (r) => _ReviewCard(
                row: r,
                onApprove: () => _decide(r, SupervisionReviewStatus.approved),
                onChanges: () =>
                    _decide(r, SupervisionReviewStatus.changesRequested),
                onCoSign: () => _decide(r, SupervisionReviewStatus.coSigned),
              ),
            ),
          const SizedBox(height: PsySpacing.lg),
          _SectionHeader(
            label: '${l.supervisionClosedSection} (${closed.length})',
            description:
                'Decisions on the record. Final entries are immutable — '
                'open a new review if anything changes.',
          ),
          if (closed.isEmpty)
            _EmptyState(message: l.supervisionEmptyClosed)
          else
            ...closed.map(
              (r) => _ReviewCard(
                row: r,
                onApprove: null,
                onChanges: null,
                onCoSign: null,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.description});
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(description, style: t.bodySmall),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.row,
    required this.onApprove,
    required this.onChanges,
    required this.onCoSign,
  });

  final SupervisionReview row;
  final VoidCallback? onApprove;
  final VoidCallback? onChanges;
  final VoidCallback? onCoSign;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: PsySpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Note ${row.sessionNoteId}', style: t.titleSmall),
                ),
                _StatusChip(status: row.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Trainee ${row.traineeId} · submitted '
              '${row.requestedAt.toLocal().toIso8601String().substring(0, 16)}',
              style: t.bodySmall,
            ),
            if (row.supervisorComment.isNotEmpty) ...[
              const SizedBox(height: PsySpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PsySpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(row.supervisorComment, style: t.bodySmall),
              ),
            ],
            if (onApprove != null) ...[
              const SizedBox(height: PsySpacing.md),
              Builder(
                builder: (ctx) {
                  final l = AppLocalizations.of(ctx);
                  return Wrap(
                    spacing: PsySpacing.sm,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check),
                        label: Text(l.supervisionActionApprove),
                      ),
                      OutlinedButton.icon(
                        onPressed: onChanges,
                        icon: const Icon(Icons.edit_note),
                        label: Text(l.supervisionActionChanges),
                      ),
                      FilledButton.icon(
                        onPressed: onCoSign,
                        icon: const Icon(Icons.draw),
                        label: Text(l.supervisionActionCoSign),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final SupervisionReviewStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Each status gets BOTH a colour and an icon so the chip is
    // distinguishable for colour-blind clinicians (red/green is the
    // most common CVD axis — never rely on hue alone).
    // `changesRequested` deliberately uses tertiaryContainer (amber),
    // not errorContainer (red): a change request is a routine
    // editorial step, not a clinical alarm.
    final (label, color, icon) = switch (status) {
      SupervisionReviewStatus.pending => (
        'Pending',
        cs.secondaryContainer,
        Icons.hourglass_top_outlined,
      ),
      SupervisionReviewStatus.changesRequested => (
        'Changes requested',
        cs.tertiaryContainer,
        Icons.edit_note_outlined,
      ),
      SupervisionReviewStatus.approved => (
        'Approved',
        cs.surfaceContainerHighest,
        Icons.check_circle_outlined,
      ),
      SupervisionReviewStatus.coSigned => (
        'Co-signed',
        cs.primaryContainer,
        Icons.verified_outlined,
      ),
    };
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CoSignDisclaimerBanner extends StatelessWidget {
  const _CoSignDisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.tertiary),
      ),
      child: Row(
        children: [
          Icon(Icons.gpp_maybe_outlined, color: cs.onTertiaryContainer),
          const SizedBox(width: PsySpacing.sm),
          Expanded(
            child: Text(
              l.supervisionCoSignDisclaimer,
              style: t.bodySmall?.copyWith(color: cs.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.lg),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
