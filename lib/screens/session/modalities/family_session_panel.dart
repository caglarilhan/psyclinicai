/// In-session family-therapy note panel.
///
/// Renders the FamilySessionNote model (PR #18) as a 7-section
/// form: approach + subsystem pickers, attendees chip rail,
/// presenting dynamic, interventions, homework, relational-shift
/// slider, clinician notes. Persists through
/// `ModalitySessionRepository` (`ModalityKind.family`). Mirrors
/// the CBT / DBT / EMDR panel layout so the clinician picks up
/// the same vocabulary across modalities.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/modalities/family_session_note.dart';
import '../../../services/data/modality_session_repository.dart';
import '../../../services/data/telemetry_service.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ds/psy_card.dart';
import '../../../widgets/ds/psy_snack.dart';
import '../../../widgets/ds/saving_indicator.dart';

class FamilySessionPanel extends StatefulWidget {
  const FamilySessionPanel({
    super.key,
    required this.patientId,
    required this.clinicianId,
    this.initial,
    this.repository,
    this.linkedGenogramId,
  });

  final String patientId;
  final String clinicianId;

  /// Existing note to edit. If null, the panel creates a new one.
  final FamilySessionNote? initial;
  final ModalitySessionRepository? repository;

  /// Pre-populate `genogramId` when the family already has a
  /// genogram document. The panel still renders without it.
  final String? linkedGenogramId;

  @override
  State<FamilySessionPanel> createState() => _FamilySessionPanelState();
}

class _FamilySessionPanelState extends State<FamilySessionPanel> {
  late final ModalitySessionRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  late final TextEditingController _attendee;
  late final TextEditingController _presenting;
  late final TextEditingController _interventions;
  late final TextEditingController _homework;
  late final TextEditingController _notes;
  late FamilySessionNote _note;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ModalitySessionRepository();
    _saveCtrl = SavingIndicatorController();
    _note =
        widget.initial ??
        FamilySessionNote(
          id: 'family-${DateTime.now().microsecondsSinceEpoch}-${widget.patientId}',
          patientId: widget.patientId,
          clinicianId: widget.clinicianId,
          sessionDate: DateTime.now().toUtc(),
          genogramId: widget.linkedGenogramId ?? '',
        );
    _attendee = TextEditingController();
    _presenting = TextEditingController(text: _note.presentingDynamic);
    _interventions = TextEditingController(text: _note.interventions);
    _homework = TextEditingController(text: _note.homework);
    _notes = TextEditingController(text: _note.notes);
    unawaited(_repo.initialize());
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    _attendee.dispose();
    _presenting.dispose();
    _interventions.dispose();
    _homework.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _rebindFromControllers() {
    _note = _note.copyWith(
      presentingDynamic: _presenting.text.trim(),
      interventions: _interventions.text.trim(),
      homework: _homework.text.trim(),
      notes: _notes.text.trim(),
    );
  }

  Future<void> _save() async {
    _rebindFromControllers();
    _saveCtrl.startSaving();
    try {
      await _repo.upsert(
        ModalityRecord(kind: ModalityKind.family, payload: _note),
      );
      _saveCtrl.markSaved();
      unawaited(
        TelemetryService.instance.capture(
          'family_session_note.saved',
          properties: {
            'approach': _note.approach.id,
            'subsystem': _note.subsystem.id,
            'attendees': _note.attendees.length,
            'has_genogram': _note.genogramId.isNotEmpty,
            'relational_shift': _note.relationalShift,
            'has_shift': _note.hasShiftRecorded,
          },
        ),
      );
      if (mounted) {
        PsySnack.success(
          context,
          'Family session note saved.',
          hint: 'family_session_note.save',
        );
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'family_session_note.save_failed',
        ),
      );
      _saveCtrl.markError(onRetry: _save);
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save the family session note — please retry.',
          hint: 'family_session_note.save_failed',
        );
      }
    }
  }

  void _addAttendee() {
    final label = _attendee.text.trim();
    if (label.isEmpty) return;
    setState(() {
      _note = _note.copyWith(attendees: [..._note.attendees, label]);
      _attendee.clear();
    });
  }

  void _removeAttendee(int i) {
    setState(() {
      final next = [..._note.attendees]..removeAt(i);
      _note = _note.copyWith(attendees: next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Family session note',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SavingIndicator(controller: _saveCtrl),
            const SizedBox(width: PsySpacing.sm),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.sm),
        Text(
          'McGoldrick / Bowen / structural vocabulary. Pick the lens, '
          'record what shifted; partial notes save fine.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: PsySpacing.xl),

        _SectionCard(
          step: '1',
          title: 'Approach',
          subtitle: 'Lens that drove this session.',
          child: DropdownButtonFormField<FamilyTherapyApproach>(
            initialValue: _note.approach,
            isExpanded: true,
            items: [
              for (final a in FamilyTherapyApproach.values)
                DropdownMenuItem(value: a, child: Text(a.label)),
            ],
            onChanged: (a) {
              if (a == null) return;
              setState(() => _note = _note.copyWith(approach: a));
            },
          ),
        ),

        _SectionCard(
          step: '2',
          title: 'Subsystem',
          subtitle: 'Which slice of the family was the focus.',
          child: Wrap(
            spacing: PsySpacing.sm,
            runSpacing: PsySpacing.sm,
            children: [
              for (final s in FamilySubsystem.values)
                ChoiceChip(
                  label: Text(_subsystemLabel(s)),
                  selected: _note.subsystem == s,
                  onSelected: (sel) {
                    if (!sel) return;
                    setState(() => _note = _note.copyWith(subsystem: s));
                  },
                ),
            ],
          ),
        ),

        _SectionCard(
          step: '3',
          title: 'Attendees',
          subtitle:
              'Who was in the room. Tap chip to remove. When a '
              'genogram exists, you can link IDs from there.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_note.attendees.isNotEmpty)
                Wrap(
                  spacing: PsySpacing.sm,
                  runSpacing: PsySpacing.sm,
                  children: [
                    for (var i = 0; i < _note.attendees.length; i++)
                      InputChip(
                        label: Text(_note.attendees[i]),
                        onDeleted: () => _removeAttendee(i),
                      ),
                  ],
                ),
              if (_note.attendees.isNotEmpty)
                const SizedBox(height: PsySpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _attendee,
                      decoration: const InputDecoration(
                        hintText: 'e.g. partner A, partner B, son (age 12)',
                      ),
                      onSubmitted: (_) => _addAttendee(),
                    ),
                  ),
                  const SizedBox(width: PsySpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _addAttendee,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              if (_note.genogramId.isNotEmpty) ...[
                const SizedBox(height: PsySpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 16,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Linked to genogram ${_note.genogramId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        _SectionCard(
          step: '4',
          title: 'Presenting dynamic',
          subtitle:
              'One-line summary of what the family arrived with — '
              'pattern, not interpretation.',
          child: TextField(
            controller: _presenting,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'e.g. "Mother-daughter conflict pulls father into '
                  'triangulation; daughter withdraws after."',
            ),
          ),
        ),

        _SectionCard(
          step: '5',
          title: 'Interventions',
          subtitle:
              'What the clinician did — joining, unbalancing, reframe, '
              'enactment, externalising, etc.',
          child: TextField(
            controller: _interventions,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'e.g. "Unbalanced toward father; coached differentiation '
                  'language; blocked rescue."',
            ),
          ),
        ),

        _SectionCard(
          step: '6',
          title: 'Homework',
          subtitle: 'Between-session task. Optional.',
          child: TextField(
            controller: _homework,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText:
                  'e.g. "Mother + daughter take a 20-minute walk twice '
                  'this week, no problem-solving."',
            ),
          ),
        ),

        _SectionCard(
          step: '7',
          title: 'Relational shift',
          subtitle:
              'How different does the family feel vs. start of session? '
              '0 = no shift, 10 = transformative.',
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _note.relationalShift.toDouble(),
                  max: 10,
                  divisions: 10,
                  label: '${_note.relationalShift}',
                  onChanged: (v) {
                    setState(
                      () => _note = _note.copyWith(relationalShift: v.round()),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${_note.relationalShift}',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        _SectionCard(
          step: '8',
          title: 'Clinician notes',
          subtitle: 'Audit + supervision context — not visible to family.',
          child: TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'e.g. supervision flags, hypotheses to test next session.',
            ),
          ),
        ),
      ],
    );
  }

  String _subsystemLabel(FamilySubsystem s) => switch (s) {
    FamilySubsystem.couple => 'Couple',
    FamilySubsystem.parentChild => 'Parent–child',
    FamilySubsystem.sibling => 'Sibling',
    FamilySubsystem.wholeFamily => 'Whole family',
    FamilySubsystem.extended => 'Extended',
  };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String step;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    step,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: PsySpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: PsySpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
