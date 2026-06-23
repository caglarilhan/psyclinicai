/// `/portal/history` — patient-facing read-only view of their
/// therapy work across modalities.
///
/// Three sections (no tabs — patient nav stays linear):
///   1. **CBT thought records** — each entry as a card: the
///      situation, the balanced thought, "how much you felt
///      better" (intensityDelta turned into a friendly sentence).
///      Clinician-only notes are hidden.
///   2. **DBT diary cards** — one card per week with days-logged
///      progress + a gentle "you logged X days this week" line.
///      SI peaks are not surfaced to the patient (clinician-only
///      triage signal). Self-harm-act weeks are flagged as
///      "tough week" without diagnostic language.
///   3. **EMDR sessions** — each session as a card showing the
///      target memory (if the patient consented to share it back),
///      and the SUDS arc as a plain sentence — "you started at X
///      out of 10 and ended at Y".
///
/// This is **read-only** for the patient and does not surface any
/// clinician-only notes (`clinicianNotes` field). The auth scope
/// (Sprint 27+ patient-side Firebase project) flips the
/// repository to a Firestore-permissioned reader; until then the
/// PWA reads the same local SharedPreferences (works in dev
/// + on a device that's shared with the clinician).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/modalities/cbt_thought_record.dart';
import '../../models/modalities/dbt_diary_card.dart';
import '../../models/modalities/emdr_session_tracker.dart';
import '../../services/data/modality_session_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';

class PortalModalityHistoryScreen extends StatefulWidget {
  const PortalModalityHistoryScreen({
    super.key,
    required this.patientId,
    this.repository,
  });

  final String patientId;
  final ModalitySessionRepository? repository;

  @override
  State<PortalModalityHistoryScreen> createState() =>
      _PortalModalityHistoryScreenState();
}

class _PortalModalityHistoryScreenState
    extends State<PortalModalityHistoryScreen> {
  late final ModalitySessionRepository _repo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ModalitySessionRepository();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<CbtThoughtRecord> get _cbt => _repo
      .forPatientOfKind(widget.patientId, ModalityKind.cbt)
      .map((r) => r.cbtRecord!)
      .toList();

  List<DbtDiaryCard> get _dbt => _repo
      .forPatientOfKind(widget.patientId, ModalityKind.dbt)
      .map((r) => r.dbtCard!)
      .toList();

  List<EmdrSessionTracker> get _emdr => _repo
      .forPatientOfKind(widget.patientId, ModalityKind.emdr)
      .map((r) => r.emdrSession!)
      .toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Your therapy history')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(PsySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    const SizedBox(height: PsySpacing.xl),
                    _CbtSection(records: _cbt),
                    const SizedBox(height: PsySpacing.xl),
                    _DbtSection(cards: _dbt),
                    const SizedBox(height: PsySpacing.xl),
                    _EmdrSection(sessions: _emdr),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A picture of your work',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This page shows your thought records, weekly diary cards, '
            'and EMDR sessions. We surface what you wrote together with '
            'your clinician. Anything they wrote privately stays '
            'private.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CbtSection extends StatelessWidget {
  const _CbtSection({required this.records});
  final List<CbtThoughtRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thought records',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        if (records.isEmpty)
          const PsyEmptyState(
            icon: Icons.psychology_outlined,
            title: 'No thought records yet',
            body:
                'When you and your clinician write a thought record in a '
                'session, it will show up here.',
            compact: true,
          )
        else
          for (final r in records.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _ThoughtRecordCard(r: r),
            ),
      ],
    );
  }
}

class _ThoughtRecordCard extends StatelessWidget {
  const _ThoughtRecordCard({required this.r});
  final CbtThoughtRecord r;

  String _outcomeSentence() {
    final delta = r.intensityDelta;
    if (r.emotionsBefore.isEmpty || r.emotionsAfter.isEmpty) {
      return 'You captured the situation and the thought — give it time.';
    }
    if (delta > 0) {
      return 'You ended this record feeling lighter than you started.';
    }
    if (delta == 0) {
      return 'Your feelings stayed steady through the record.';
    }
    return 'Your feelings ran higher at the end — your clinician can '
        'walk this one with you next session.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _date(r.recordedAt),
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          if (r.situation.isNotEmpty) ...[
            Text(
              'What happened:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(r.situation, style: theme.textTheme.bodyMedium),
            const SizedBox(height: PsySpacing.sm),
          ],
          if (r.balancedThought.isNotEmpty) ...[
            Text(
              'The balanced thought you wrote:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '"${r.balancedThought}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: PsySpacing.sm),
          ],
          Text(
            _outcomeSentence(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DbtSection extends StatelessWidget {
  const _DbtSection({required this.cards});
  final List<DbtDiaryCard> cards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly diary cards',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        if (cards.isEmpty)
          const PsyEmptyState(
            icon: Icons.calendar_view_week_outlined,
            title: 'No diary cards yet',
            body:
                'Your weekly diary card will appear here once one is on '
                'file.',
            compact: true,
          )
        else
          for (final c in cards.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _DiaryCardTile(card: c),
            ),
      ],
    );
  }
}

class _DiaryCardTile extends StatelessWidget {
  const _DiaryCardTile({required this.card});
  final DbtDiaryCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tough = card.selfHarmActOccurred;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week of ${_date(card.weekStart)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You logged ${card.filledDays} of 7 days.',
            style: theme.textTheme.bodyMedium,
          ),
          if (tough) ...[
            const SizedBox(height: PsySpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.md,
                vertical: PsySpacing.sm,
              ),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(PsyRadius.md),
                border: Border.all(color: cs.error.withValues(alpha: 0.4)),
              ),
              child: Text(
                'This was a tough week. We saw the day you marked, and '
                'your clinician knows. If you need someone now, please '
                'reach out — your safety plan is in /portal/inbox.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmdrSection extends StatelessWidget {
  const _EmdrSection({required this.sessions});
  final List<EmdrSessionTracker> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMDR sessions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        if (sessions.isEmpty)
          const PsyEmptyState(
            icon: Icons.timeline_outlined,
            title: 'No EMDR sessions yet',
            body:
                'Once you and your clinician complete an EMDR session, the '
                'summary lands here.',
            compact: true,
          )
        else
          for (final s in sessions.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: _EmdrSessionTile(s: s),
            ),
      ],
    );
  }
}

class _EmdrSessionTile extends StatelessWidget {
  const _EmdrSessionTile({required this.s});
  final EmdrSessionTracker s;

  String _arcSentence() {
    final end = s.sudsEnd;
    if (end == null) {
      return 'You started this session at ${s.sudsStart} out of 10. '
          'Your clinician will close the loop in the next session.';
    }
    if (end <= s.sudsStart) {
      return 'You started at ${s.sudsStart} out of 10 and ended at '
          '$end. The work moved.';
    }
    return 'You started at ${s.sudsStart} out of 10 and ended at $end. '
        'Sometimes processing surfaces more before it settles — your '
        'clinician will pick it back up next session.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _date(s.updatedAt ?? s.createdAt),
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
          if (s.positiveCognition.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'The belief you want to live with:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '"${s.positiveCognition}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: PsySpacing.sm),
          Text(
            _arcSentence(),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

String _date(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
