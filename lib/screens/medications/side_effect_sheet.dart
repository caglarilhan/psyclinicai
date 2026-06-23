/// BottomSheet that captures a structured `MedicationSideEffect`
/// event (PR #16). Used from the MAR row "Side effect" action and,
/// later, from the patient portal.
///
/// Captures: symptom (free text), body-system bucket, severity
/// (0-4), optional Naranjo score (-4..13). Pre-fills onset to
/// "now" so the clinician only types when the patient says the
/// effect started earlier.
library;

import 'package:flutter/material.dart';

import '../../models/medication_side_effect.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_card.dart';

class SideEffectSheet extends StatefulWidget {
  const SideEffectSheet({
    super.key,
    required this.patientId,
    required this.medicationId,
    required this.clinicianId,
    this.initial,
  });

  final String patientId;
  final String medicationId;
  final String clinicianId;

  /// Optional initial draft when editing an existing row from the
  /// SE history. Null when capturing a new one.
  final MedicationSideEffect? initial;

  @override
  State<SideEffectSheet> createState() => _SideEffectSheetState();
}

class _SideEffectSheetState extends State<SideEffectSheet> {
  late final TextEditingController _symptom;
  late final TextEditingController _action;
  late final TextEditingController _notes;
  late SideEffectSystem _system;
  late SideEffectSeverity _severity;
  int? _naranjo;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _symptom = TextEditingController(text: i?.symptom ?? '');
    _action = TextEditingController(text: i?.actionTaken ?? '');
    _notes = TextEditingController(text: i?.notes ?? '');
    _system = i?.system ?? SideEffectSystem.other;
    _severity = i?.severity ?? SideEffectSeverity.mild;
    _naranjo = i?.naranjoScore;
  }

  @override
  void dispose() {
    _symptom.dispose();
    _action.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _canSave => _symptom.text.trim().isNotEmpty;

  MedicationSideEffect _build() {
    final now = DateTime.now().toUtc();
    return MedicationSideEffect(
      id:
          widget.initial?.id ??
          'se-${now.microsecondsSinceEpoch}-${widget.patientId}',
      patientId: widget.patientId,
      medicationId: widget.medicationId,
      clinicianId: widget.clinicianId,
      reportedAt: widget.initial?.reportedAt ?? now,
      symptom: _symptom.text.trim(),
      system: _system,
      severity: _severity,
      naranjoScore: _naranjo,
      onsetAt: widget.initial?.onsetAt ?? now,
      resolvedAt: widget.initial?.resolvedAt,
      actionTaken: _action.text.trim(),
      notes: _notes.text.trim(),
    );
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
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(PsySpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Log side effect',
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
                const SizedBox(height: PsySpacing.sm),
                Text(
                  'Structured event tied to this medication. The patient '
                  'pulse + tolerability tile read from this log — keep it '
                  'tight, the patient can flesh it out via the portal.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),

                const _SectionLabel(text: 'Symptom'),
                TextField(
                  controller: _symptom,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'e.g. dry mouth, drowsiness, headache',
                  ),
                ),
                const SizedBox(height: PsySpacing.md),

                const _SectionLabel(text: 'Body system'),
                Wrap(
                  spacing: PsySpacing.sm,
                  runSpacing: PsySpacing.sm,
                  children: [
                    for (final s in SideEffectSystem.values)
                      ChoiceChip(
                        label: Text(_systemLabel(s)),
                        selected: _system == s,
                        onSelected: (sel) {
                          if (!sel) return;
                          setState(() => _system = s);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: PsySpacing.md),

                const _SectionLabel(text: 'Severity'),
                SegmentedButton<SideEffectSeverity>(
                  showSelectedIcon: false,
                  segments: [
                    for (final s in SideEffectSeverity.values)
                      ButtonSegment(value: s, label: Text(s.label)),
                  ],
                  selected: {_severity},
                  onSelectionChanged: (s) =>
                      setState(() => _severity = s.first),
                ),
                if (_severity.value >= SideEffectSeverity.moderate.value) ...[
                  const SizedBox(height: PsySpacing.sm),
                  PsyCard(
                    tinted: true,
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: cs.error,
                        ),
                        const SizedBox(width: PsySpacing.sm),
                        Expanded(
                          child: Text(
                            'Moderate+ events flag the patient pulse '
                            'tolerability tile.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: PsySpacing.md),

                const _SectionLabel(
                  text: 'Naranjo causality (optional, -4 to 13)',
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: (_naranjo ?? 0).toDouble(),
                        min: -4,
                        max: 13,
                        divisions: 17,
                        label: _naranjo?.toString() ?? 'not set',
                        onChanged: (v) => setState(() => _naranjo = v.round()),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(
                        _naranjo == null
                            ? '—'
                            : '$_naranjo · ${_naranjoBucket(_naranjo!)}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                if (_naranjo != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _naranjo = null),
                      child: const Text('Clear Naranjo'),
                    ),
                  ),
                const SizedBox(height: PsySpacing.md),

                const _SectionLabel(text: 'Action taken'),
                TextField(
                  controller: _action,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. dose reduced, drug stopped, watchful waiting',
                  ),
                ),
                const SizedBox(height: PsySpacing.md),

                const _SectionLabel(text: 'Notes'),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Audit + supervision context.',
                  ),
                ),
                const SizedBox(height: PsySpacing.xl),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: PsySpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _canSave
                            ? () => Navigator.of(context).pop(_build())
                            : null,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save side effect'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _systemLabel(SideEffectSystem s) => switch (s) {
    SideEffectSystem.gastrointestinal => 'GI',
    SideEffectSystem.neurological => 'Neuro',
    SideEffectSystem.cardiovascular => 'Cardio',
    SideEffectSystem.metabolic => 'Metabolic',
    SideEffectSystem.dermatologic => 'Skin',
    SideEffectSystem.sexual => 'Sexual',
    SideEffectSystem.psychiatric => 'Psych',
    SideEffectSystem.sleep => 'Sleep',
    SideEffectSystem.other => 'Other',
  };

  String _naranjoBucket(int score) =>
      NaranjoCategory.fromScore(score).id.replaceAll('_', ' ');
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
