/// In-session DBT Diary Card panel.
///
/// Linehan's 7-day weekly card. Renders three sections:
///   1. **Week grid** — 7 columns × N rows (target behaviours +
///      emotions + skills) with day filled-state pills, tap a day to
///      open the editor.
///   2. **Day editor** — bottom sheet to fill target ratings,
///      emotion ratings, skill chips, free-text notes.
///   3. **Summary strip** — SI peak this week, self-harm act
///      occurred y/n, days filled / 7, skills practised count.
///
/// Saves through `ModalitySessionRepository` — same telemetry +
/// SavingIndicator pattern as the CBT panel.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/modalities/dbt_diary_card.dart';
import '../../../services/data/modality_session_repository.dart';
import '../../../services/data/telemetry_service.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ds/psy_badge.dart';
import '../../../widgets/ds/psy_card.dart';
import '../../../widgets/ds/psy_snack.dart';
import '../../../widgets/ds/saving_indicator.dart';

class DbtDiaryCardPanel extends StatefulWidget {
  const DbtDiaryCardPanel({
    super.key,
    required this.patientId,
    required this.clinicianId,
    this.initial,
    this.repository,
  });

  final String patientId;
  final String clinicianId;
  final DbtDiaryCard? initial;
  final ModalitySessionRepository? repository;

  @override
  State<DbtDiaryCardPanel> createState() => _DbtDiaryCardPanelState();
}

class _DbtDiaryCardPanelState extends State<DbtDiaryCardPanel> {
  late final ModalitySessionRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  late DbtDiaryCard _card;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ModalitySessionRepository();
    _saveCtrl = SavingIndicatorController();
    _card =
        widget.initial ??
        DbtDiaryCard.blank(
          id: 'dbt-${DateTime.now().microsecondsSinceEpoch}-${widget.patientId}',
          patientId: widget.patientId,
          clinicianId: widget.clinicianId,
        );
    unawaited(_repo.initialize());
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    _saveCtrl.startSaving();
    try {
      await _repo.upsert(
        ModalityRecord(kind: ModalityKind.dbt, payload: _card),
      );
      _saveCtrl.markSaved();
      unawaited(
        TelemetryService.instance.capture(
          'dbt_diary_card.saved',
          properties: {
            'filled_days': _card.filledDays,
            'si_peak': _card.suicidalIdeationPeakOfWeek,
            'sh_act': _card.selfHarmActOccurred,
          },
        ),
      );
      if (mounted) {
        PsySnack.success(
          context,
          'Diary card saved.',
          hint: 'dbt_diary_card.save',
        );
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'dbt_diary_card.save_failed',
        ),
      );
      _saveCtrl.markError(onRetry: _save);
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save the diary card — please retry.',
          hint: 'dbt_diary_card.save_failed',
        );
      }
    }
  }

  Future<void> _editDay(int index) async {
    final updated = await showModalBottomSheet<DbtDailyEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DayEditorSheet(
        entry: _card.days[index],
        targets: _card.targetBehaviors,
      ),
    );
    if (updated == null) return;
    setState(() {
      _card = _card.withDay(updated);
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
                'DBT Diary Card',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SavingIndicator(controller: _saveCtrl),
            const SizedBox(width: PsySpacing.md),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: PsySpacing.sm),
        Text(
          'Linehan adult card — week of ${_formatIsoDate(_card.weekStart)}. '
          'Tap any day to log target behaviours, emotions, skills.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: PsySpacing.xl),

        _SummaryStrip(card: _card),
        const SizedBox(height: PsySpacing.lg),

        _WeekGrid(card: _card, onDayTap: _editDay),
        const SizedBox(height: PsySpacing.lg),

        _ClinicianNotes(
          initial: _card.clinicianNotes,
          onChanged: (v) =>
              setState(() => _card = _card.copyWith(clinicianNotes: v)),
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.card});
  final DbtDiaryCard card;

  @override
  Widget build(BuildContext context) {
    final skillsCount = card.days.fold<int>(
      0,
      (acc, d) => acc + d.skillsUsed.length,
    );
    final cs = Theme.of(context).colorScheme;
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          _StatBubble(
            label: 'Days filled',
            value: '${card.filledDays}/7',
            color: cs.primary,
          ),
          const SizedBox(width: PsySpacing.lg),
          _StatBubble(
            label: 'SI peak',
            value: '${card.suicidalIdeationPeakOfWeek}/5',
            color: card.suicidalIdeationPeakOfWeek >= 3
                ? cs.error
                : cs.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: PsySpacing.lg),
          _StatBubble(
            label: 'Self-harm act',
            value: card.selfHarmActOccurred ? 'Yes' : 'No',
            color: card.selfHarmActOccurred ? cs.error : cs.primary,
          ),
          const SizedBox(width: PsySpacing.lg),
          _StatBubble(
            label: 'Skills used',
            value: '$skillsCount',
            color: cs.secondary,
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.card, required this.onDayTap});
  final DbtDiaryCard card;
  final ValueChanged<int> onDayTap;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Week',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 6 ? PsySpacing.sm : 0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(PsyRadius.md),
                      onTap: () => onDayTap(i),
                      child: Container(
                        padding: const EdgeInsets.all(PsySpacing.md),
                        decoration: BoxDecoration(
                          color: card.days[i].hasAnyData
                              ? cs.primary.withValues(alpha: 0.08)
                              : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(PsyRadius.md),
                          border: Border.all(
                            color: card.days[i].hasAnyData
                                ? cs.primary.withValues(alpha: 0.4)
                                : cs.outlineVariant,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dayLabels[i],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${card.days[i].date.day}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: PsySpacing.sm),
                            if (card.days[i].hasAnyData)
                              Row(
                                children: [
                                  PsyBadge(
                                    label: '${card.days[i].skillsUsed.length}',
                                    tone: PsyBadgeTone.brand,
                                  ),
                                ],
                              )
                            else
                              Text(
                                '— empty',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.45),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClinicianNotes extends StatefulWidget {
  const _ClinicianNotes({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_ClinicianNotes> createState() => _ClinicianNotesState();
}

class _ClinicianNotesState extends State<_ClinicianNotes> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Clinician-only notes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PsySpacing.sm),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Weekly chain-analysis cue, supervision flag, next-session '
                  'agenda…',
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class _DayEditorSheet extends StatefulWidget {
  const _DayEditorSheet({required this.entry, required this.targets});
  final DbtDailyEntry entry;
  final List<DbtTargetBehavior> targets;

  @override
  State<_DayEditorSheet> createState() => _DayEditorSheetState();
}

class _DayEditorSheetState extends State<_DayEditorSheet> {
  late Map<String, int> _targetRatings;
  late Map<DbtEmotion, int> _emotionRatings;
  late Set<DbtSkill> _skillsUsed;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _targetRatings = Map.of(widget.entry.targetBehaviorRatings);
    _emotionRatings = Map.of(widget.entry.emotionRatings);
    _skillsUsed = Set.of(widget.entry.skillsUsed);
    _notes = TextEditingController(text: widget.entry.notes);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop(
      widget.entry.copyWith(
        targetBehaviorRatings: _targetRatings,
        emotionRatings: _emotionRatings,
        skillsUsed: _skillsUsed,
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => Padding(
        padding: EdgeInsets.only(
          left: PsySpacing.xl,
          right: PsySpacing.xl,
          bottom: MediaQuery.of(context).viewInsets.bottom + PsySpacing.xl,
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _formatIsoDate(widget.entry.date),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PsySpacing.lg),
              _TargetSection(
                targets: widget.targets,
                ratings: _targetRatings,
                onChanged: (id, v) => setState(() => _targetRatings[id] = v),
              ),
              const SizedBox(height: PsySpacing.lg),
              _EmotionsSection(
                ratings: _emotionRatings,
                onChanged: (e, v) => setState(() => _emotionRatings[e] = v),
              ),
              const SizedBox(height: PsySpacing.lg),
              _SkillsSection(
                skills: _skillsUsed,
                onToggle: (s) => setState(() {
                  if (_skillsUsed.contains(s)) {
                    _skillsUsed.remove(s);
                  } else {
                    _skillsUsed.add(s);
                  }
                }),
              ),
              const SizedBox(height: PsySpacing.lg),
              PsyCard(
                child: TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'What happened today?',
                  ),
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
                    child: FilledButton(
                      onPressed: _close,
                      child: const Text('Save day'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PsySpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetSection extends StatelessWidget {
  const _TargetSection({
    required this.targets,
    required this.ratings,
    required this.onChanged,
  });
  final List<DbtTargetBehavior> targets;
  final Map<String, int> ratings;
  final void Function(String id, int value) onChanged;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Target behaviours',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final t in targets) ...[
            _TargetRow(
              target: t,
              value: ratings[t.id] ?? 0,
              onChanged: onChanged,
            ),
            const SizedBox(height: PsySpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.target,
    required this.value,
    required this.onChanged,
  });
  final DbtTargetBehavior target;
  final int value;
  final void Function(String id, int value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = target.isUrge ? 5 : 1;
    return Tooltip(
      message: target.helpText,
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(target.label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              max: max.toDouble(),
              divisions: max,
              label: target.isUrge ? '$value' : (value == 1 ? 'Yes' : 'No'),
              onChanged: (v) => onChanged(target.id, v.round()),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              target.isUrge ? '$value/$max' : (value == 1 ? 'Yes' : 'No'),
              textAlign: TextAlign.right,
              style: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionsSection extends StatelessWidget {
  const _EmotionsSection({required this.ratings, required this.onChanged});
  final Map<DbtEmotion, int> ratings;
  final void Function(DbtEmotion e, int value) onChanged;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Emotions (0–5)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final e in DbtEmotion.values)
            Row(
              children: [
                SizedBox(width: 120, child: Text(e.label)),
                Expanded(
                  child: Slider(
                    value: (ratings[e] ?? 0).toDouble(),
                    max: 5,
                    divisions: 5,
                    label: '${ratings[e] ?? 0}',
                    onChanged: (v) => onChanged(e, v.round()),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Text('${ratings[e] ?? 0}', textAlign: TextAlign.right),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills, required this.onToggle});
  final Set<DbtSkill> skills;
  final ValueChanged<DbtSkill> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byModule = <DbtSkillModule, List<DbtSkill>>{};
    for (final s in DbtSkill.values) {
      byModule.putIfAbsent(s.module, () => []).add(s);
    }
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Skills practised',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final module in DbtSkillModule.values) ...[
            Text(
              module.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: PsySpacing.xs),
            Wrap(
              spacing: PsySpacing.sm,
              runSpacing: PsySpacing.sm,
              children: [
                for (final s in byModule[module] ?? const <DbtSkill>[])
                  FilterChip(
                    label: Text(s.label),
                    selected: skills.contains(s),
                    onSelected: (_) => onToggle(s),
                  ),
              ],
            ),
            const SizedBox(height: PsySpacing.md),
          ],
        ],
      ),
    );
  }
}

String _formatIsoDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
