/// BottomSheet that shows every submission attempt for one claim
/// (PR #32 ClaimAttemptRepository) with outcome chips, CARC code,
/// appeal-letter pointer, and the per-attempt timeline.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/claim_attempt.dart';
import '../../services/billing/carc_fix_playbook.dart';
import '../../services/billing/carc_mapping.dart';
import '../../services/billing/claim_attempt_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';

class ClaimAttemptHistorySheet extends StatefulWidget {
  const ClaimAttemptHistorySheet({
    super.key,
    required this.claimId,
    this.repository,
  });

  final String claimId;
  final ClaimAttemptRepository? repository;

  @override
  State<ClaimAttemptHistorySheet> createState() =>
      _ClaimAttemptHistorySheetState();
}

class _ClaimAttemptHistorySheetState extends State<ClaimAttemptHistorySheet> {
  late final ClaimAttemptRepository _repo;
  bool _loading = true;
  ClaimAttemptHistory? _history;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ClaimAttemptRepository();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() {
      _history = _repo.historyFor(widget.claimId);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(PsySpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Claim attempt history',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Claim ${widget.claimId} — every original + resubmission '
                  'attempt with outcome + appeal pointer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_history == null || _history!.attempts.isEmpty)
                  const PsyEmptyState(
                    icon: Icons.history_toggle_off_outlined,
                    title: 'No attempts logged yet',
                    body:
                        'The first 837P submission will appear here once '
                        'it is recorded.',
                    compact: true,
                  )
                else
                  _HistoryBody(history: _history!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.history});
  final ClaimAttemptHistory history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PsyCard(
          tinted: true,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${history.attemptCount} attempt(s)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PsyBadge(
                label: history.isResolved ? 'Resolved' : 'Open',
                tone: history.isResolved
                    ? PsyBadgeTone.success
                    : PsyBadgeTone.warning,
              ),
              if (history.hasAppeal) ...[
                const SizedBox(width: PsySpacing.sm),
                const PsyBadge(label: 'Appealed', tone: PsyBadgeTone.brand),
              ],
              if (history.recoveredAfterDenial) ...[
                const SizedBox(width: PsySpacing.sm),
                const PsyBadge(label: 'Recovered', tone: PsyBadgeTone.success),
              ],
            ],
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        for (final a in history.attempts) ...[
          _AttemptTile(attempt: a, isLatest: a.id == history.latest?.id),
          const SizedBox(height: PsySpacing.sm),
        ],
        if (history.attempts.any((a) => a.denialReasonCode != null)) ...[
          const SizedBox(height: PsySpacing.md),
          Text(
            'Playbook',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Next-step guidance per CARC code on this claim.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final a in history.attempts.where(
            (a) => a.denialReasonCode != null,
          ))
            _PlaybookCard(code: a.denialReasonCode!),
        ],
      ],
    );
  }
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({required this.attempt, required this.isLatest});
  final ClaimAttempt attempt;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      tinted: isLatest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attempt #${attempt.attemptNumber}'
                  '${attempt.isAppealResubmission ? ' · appeal' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PsyBadge(
                label: attempt.outcome.label,
                tone: _toneFor(attempt.outcome),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Submitted ${_fmtDate(attempt.submittedAt)}'
            '${attempt.refNumber == null ? '' : ' · ref ${attempt.refNumber}'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (attempt.denialReasonCode != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Wrap(
              spacing: PsySpacing.sm,
              children: [
                PsyBadge(
                  label: 'CARC ${attempt.denialReasonCode!}',
                  tone: PsyBadgeTone.danger,
                ),
                if (carcLookup(attempt.denialReasonCode!) != null)
                  Tooltip(
                    message: carcLookup(attempt.denialReasonCode!)!.hint,
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
          if (attempt.appealLetterId != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(
              'Appeal letter ${attempt.appealLetterId!}',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.primary),
            ),
          ],
          if (attempt.notes.isNotEmpty) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(attempt.notes, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  PsyBadgeTone _toneFor(ClaimAttemptOutcome o) => switch (o) {
    ClaimAttemptOutcome.pending => PsyBadgeTone.neutral,
    ClaimAttemptOutcome.accepted => PsyBadgeTone.info,
    ClaimAttemptOutcome.paid => PsyBadgeTone.success,
    ClaimAttemptOutcome.denied => PsyBadgeTone.danger,
    ClaimAttemptOutcome.upheld => PsyBadgeTone.danger,
    ClaimAttemptOutcome.overturned => PsyBadgeTone.success,
  };

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

class _PlaybookCard extends StatelessWidget {
  const _PlaybookCard({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final entry = CarcFixPlaybook.forCode(code);
    final theme = Theme.of(context);
    if (entry == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.sm),
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PsyBadge(label: code, tone: PsyBadgeTone.danger),
                const SizedBox(width: PsySpacing.sm),
                Expanded(
                  child: Text(
                    entry.immediateFix.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(entry.immediateFix.detail, style: theme.textTheme.bodySmall),
            const SizedBox(height: PsySpacing.sm),
            Text(
              entry.resubmitStep.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(entry.resubmitStep.detail, style: theme.textTheme.bodySmall),
            const SizedBox(height: PsySpacing.sm),
            Text(
              entry.appealAngle.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(entry.appealAngle.detail, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
