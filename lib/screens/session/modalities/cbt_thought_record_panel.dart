/// In-session CBT Thought Record panel.
///
/// Renders the Beck/Padesky 7-column model as a single scrollable
/// form, designed so a clinician can fill it mid-session without
/// breaking eye contact with the patient. Saves through
/// `ModalitySessionRepository`; surface state via
/// `SavingIndicator` + telemetry hint
/// `cbt_thought_record.save_*`.
///
/// Wired into `session_screen.dart` as one of three modality panels
/// (CBT / DBT / EMDR); the clinician picks the modality at session
/// start.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/modalities/cbt_thought_record.dart';
import '../../../services/data/modality_session_repository.dart';
import '../../../services/data/telemetry_service.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ds/psy_card.dart';
import '../../../widgets/ds/psy_snack.dart';
import '../../../widgets/ds/saving_indicator.dart';

class CbtThoughtRecordPanel extends StatefulWidget {
  const CbtThoughtRecordPanel({
    super.key,
    required this.patientId,
    required this.clinicianId,
    this.initial,
    this.repository,
  });

  /// Patient under treatment (clinic-scoped).
  final String patientId;

  /// Clinician filing the record — recorded for audit / supervision.
  final String clinicianId;

  /// Existing record to edit; if null, the panel creates a new one
  /// scoped to this patient + clinician.
  final CbtThoughtRecord? initial;

  /// Injected for tests; defaults to a fresh repository instance
  /// that initialises on first save.
  final ModalitySessionRepository? repository;

  @override
  State<CbtThoughtRecordPanel> createState() => _CbtThoughtRecordPanelState();
}

class _CbtThoughtRecordPanelState extends State<CbtThoughtRecordPanel> {
  late final ModalitySessionRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  late final TextEditingController _situation;
  late final TextEditingController _newThoughtText;
  late int _newThoughtBelief;
  late final TextEditingController _newEmotionBefore;
  late int _newEmotionBeforeIntensity;
  late final TextEditingController _evidenceFor;
  late final TextEditingController _evidenceAgainst;
  late final TextEditingController _balanced;
  late int _balancedBelief;
  late final TextEditingController _newEmotionAfter;
  late int _newEmotionAfterIntensity;
  late final TextEditingController _clinicianNotes;

  late CbtThoughtRecord _record;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ModalitySessionRepository();
    _saveCtrl = SavingIndicatorController();
    _record =
        widget.initial ??
        CbtThoughtRecord(
          id:
              'cbt-${DateTime.now().microsecondsSinceEpoch}-${widget.patientId}',
          patientId: widget.patientId,
          clinicianId: widget.clinicianId,
          recordedAt: DateTime.now().toUtc(),
        );
    _situation = TextEditingController(text: _record.situation);
    _newThoughtText = TextEditingController();
    _newThoughtBelief = 75;
    _newEmotionBefore = TextEditingController();
    _newEmotionBeforeIntensity = 70;
    _evidenceFor = TextEditingController(text: _record.evidenceFor);
    _evidenceAgainst = TextEditingController(text: _record.evidenceAgainst);
    _balanced = TextEditingController(text: _record.balancedThought);
    _balancedBelief = _record.balancedBeliefPct;
    _newEmotionAfter = TextEditingController();
    _newEmotionAfterIntensity = 30;
    _clinicianNotes = TextEditingController(text: _record.clinicianNotes);
    unawaited(_repo.initialize());
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    _situation.dispose();
    _newThoughtText.dispose();
    _newEmotionBefore.dispose();
    _evidenceFor.dispose();
    _evidenceAgainst.dispose();
    _balanced.dispose();
    _newEmotionAfter.dispose();
    _clinicianNotes.dispose();
    super.dispose();
  }

  void _rebindFromControllers() {
    _record = _record.copyWith(
      situation: _situation.text.trim(),
      evidenceFor: _evidenceFor.text.trim(),
      evidenceAgainst: _evidenceAgainst.text.trim(),
      balancedThought: _balanced.text.trim(),
      balancedBeliefPct: _balancedBelief,
      clinicianNotes: _clinicianNotes.text.trim(),
    );
  }

  Future<void> _save() async {
    _rebindFromControllers();
    _saveCtrl.startSaving();
    try {
      await _repo.upsert(
        ModalityRecord(kind: ModalityKind.cbt, payload: _record),
      );
      _saveCtrl.markSaved();
      unawaited(
        TelemetryService.instance.capture(
          'cbt_thought_record.saved',
          properties: {
            'distortions': _record.distortions.length,
            'thoughts': _record.thoughts.length,
            'intensity_delta': _record.intensityDelta,
          },
        ),
      );
      if (mounted) {
        PsySnack.success(
          context,
          'Thought record saved.',
          hint: 'cbt_thought_record.save',
        );
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'cbt_thought_record.save_failed',
        ),
      );
      _saveCtrl.markError(onRetry: _save);
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save the thought record — please retry.',
          hint: 'cbt_thought_record.save_failed',
        );
      }
    }
  }

  void _addThought() {
    final text = _newThoughtText.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _record = _record.copyWith(
        thoughts: [
          ..._record.thoughts,
          CbtAutomaticThought(text: text, beliefPct: _newThoughtBelief),
        ],
      );
      _newThoughtText.clear();
      _newThoughtBelief = 75;
    });
  }

  void _removeThought(int index) {
    setState(() {
      _record = _record.copyWith(
        thoughts: [
          for (var i = 0; i < _record.thoughts.length; i++)
            if (i != index) _record.thoughts[i],
        ],
      );
    });
  }

  void _addEmotionBefore() {
    final text = _newEmotionBefore.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _record = _record.copyWith(
        emotionsBefore: [
          ..._record.emotionsBefore,
          CbtEmotionRating(
            emotion: text,
            intensity: _newEmotionBeforeIntensity,
          ),
        ],
      );
      _newEmotionBefore.clear();
      _newEmotionBeforeIntensity = 70;
    });
  }

  void _removeEmotionBefore(int index) {
    setState(() {
      _record = _record.copyWith(
        emotionsBefore: [
          for (var i = 0; i < _record.emotionsBefore.length; i++)
            if (i != index) _record.emotionsBefore[i],
        ],
      );
    });
  }

  void _addEmotionAfter() {
    final text = _newEmotionAfter.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _record = _record.copyWith(
        emotionsAfter: [
          ..._record.emotionsAfter,
          CbtEmotionRating(
            emotion: text,
            intensity: _newEmotionAfterIntensity,
          ),
        ],
      );
      _newEmotionAfter.clear();
      _newEmotionAfterIntensity = 30;
    });
  }

  void _removeEmotionAfter(int index) {
    setState(() {
      _record = _record.copyWith(
        emotionsAfter: [
          for (var i = 0; i < _record.emotionsAfter.length; i++)
            if (i != index) _record.emotionsAfter[i],
        ],
      );
    });
  }

  void _toggleDistortion(CbtCognitiveDistortion d) {
    setState(() {
      final next = [..._record.distortions];
      if (next.contains(d)) {
        next.remove(d);
      } else {
        next.add(d);
      }
      _record = _record.copyWith(distortions: next);
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
                'CBT Thought Record',
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
          'Beck/Padesky 7-column model. Fill what surfaces; partial '
          'records save fine.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: PsySpacing.xl),

        _SectionCard(
          step: '1',
          title: 'Situation / Trigger',
          subtitle: 'Where, when, with whom — concrete, not interpretive.',
          child: TextField(
            controller: _situation,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'e.g. "Boss returned my draft with red marks — Thursday, '
                  '4pm, in the open-plan office."',
            ),
          ),
        ),

        _SectionCard(
          step: '2',
          title: 'Automatic thoughts',
          subtitle:
              'Each thought + belief % (0–100). Surface the hottest one '
              'first.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _record.thoughts.length; i++)
                _ThoughtTile(
                  thought: _record.thoughts[i],
                  onDelete: () => _removeThought(i),
                ),
              if (_record.thoughts.isNotEmpty)
                const SizedBox(height: PsySpacing.md),
              TextField(
                controller: _newThoughtText,
                decoration: const InputDecoration(
                  hintText: 'New automatic thought…',
                ),
                onSubmitted: (_) => _addThought(),
              ),
              const SizedBox(height: PsySpacing.sm),
              _BeliefSlider(
                value: _newThoughtBelief,
                onChanged: (v) => setState(() => _newThoughtBelief = v),
              ),
              const SizedBox(height: PsySpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _addThought,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add thought'),
                ),
              ),
            ],
          ),
        ),

        _EmotionsCard(
          step: '3',
          title: 'Emotions — before',
          subtitle: 'Name each affect + intensity (0–100).',
          ratings: _record.emotionsBefore,
          textCtrl: _newEmotionBefore,
          intensity: _newEmotionBeforeIntensity,
          onIntensityChanged: (v) =>
              setState(() => _newEmotionBeforeIntensity = v),
          onAdd: _addEmotionBefore,
          onRemove: _removeEmotionBefore,
        ),

        _SectionCard(
          step: '4',
          title: 'Cognitive distortions',
          subtitle:
              'Burns 10 — multi-select; a hot thought commonly maps to 2 '
              'or 3.',
          child: Wrap(
            spacing: PsySpacing.sm,
            runSpacing: PsySpacing.sm,
            children: [
              for (final d in CbtCognitiveDistortion.values)
                FilterChip(
                  label: Text(d.label),
                  tooltip: d.description,
                  selected: _record.distortions.contains(d),
                  onSelected: (_) => _toggleDistortion(d),
                ),
            ],
          ),
        ),

        _SectionCard(
          step: '5 / 6',
          title: 'Evidence',
          subtitle:
              'Both directions. Put the strongest counter-evidence on the '
              'right.',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _evidenceFor,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Evidence for the thought',
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: TextField(
                  controller: _evidenceAgainst,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Evidence against the thought',
                  ),
                ),
              ),
            ],
          ),
        ),

        _SectionCard(
          step: '7',
          title: 'Balanced / alternative thought',
          subtitle: "In the patient's words. New belief % is the outcome "
              'signal.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _balanced,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. "The draft had real feedback I can act on; one '
                      "round of red marks isn't the same as failing.\"",
                ),
              ),
              const SizedBox(height: PsySpacing.sm),
              _BeliefSlider(
                value: _balancedBelief,
                label: 'New belief in the balanced thought',
                onChanged: (v) => setState(() => _balancedBelief = v),
              ),
            ],
          ),
        ),

        _EmotionsCard(
          step: '8',
          title: 'Emotions — after',
          subtitle:
              'Re-rate the same emotions. Delta is the session outcome.',
          ratings: _record.emotionsAfter,
          textCtrl: _newEmotionAfter,
          intensity: _newEmotionAfterIntensity,
          onIntensityChanged: (v) =>
              setState(() => _newEmotionAfterIntensity = v),
          onAdd: _addEmotionAfter,
          onRemove: _removeEmotionAfter,
        ),

        _SectionCard(
          step: 'Notes',
          title: 'Clinician-only notes',
          subtitle:
              'Not surfaced to the patient PWA. Use for supervision flags.',
          child: TextField(
            controller: _clinicianNotes,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText:
                  'e.g. "Defended the hot thought hard — return next session '
                  'with collaborative empiricism."',
            ),
          ),
        ),

        const SizedBox(height: PsySpacing.lg),
        _DeltaSummary(record: _record),
      ],
    );
  }
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

class _ThoughtTile extends StatelessWidget {
  const _ThoughtTile({required this.thought, required this.onDelete});
  final CbtAutomaticThought thought;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(thought.text)),
          const SizedBox(width: PsySpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${thought.beliefPct}%',
              style: theme.textTheme.labelMedium?.copyWith(color: cs.primary),
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmotionsCard extends StatelessWidget {
  const _EmotionsCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.ratings,
    required this.textCtrl,
    required this.intensity,
    required this.onIntensityChanged,
    required this.onAdd,
    required this.onRemove,
  });
  final String step;
  final String title;
  final String subtitle;
  final List<CbtEmotionRating> ratings;
  final TextEditingController textCtrl;
  final int intensity;
  final ValueChanged<int> onIntensityChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      step: step,
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < ratings.length; i++)
            _EmotionTile(rating: ratings[i], onDelete: () => onRemove(i)),
          if (ratings.isNotEmpty) const SizedBox(height: PsySpacing.md),
          TextField(
            controller: textCtrl,
            decoration: const InputDecoration(
              hintText: 'Emotion (e.g. "anxiety", "shame")…',
            ),
            onSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: PsySpacing.sm),
          _BeliefSlider(
            value: intensity,
            label: 'Intensity',
            onChanged: onIntensityChanged,
          ),
          const SizedBox(height: PsySpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add emotion'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionTile extends StatelessWidget {
  const _EmotionTile({required this.rating, required this.onDelete});
  final CbtEmotionRating rating;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(rating.emotion)),
          const SizedBox(width: PsySpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${rating.intensity}/100',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.secondary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _BeliefSlider extends StatelessWidget {
  const _BeliefSlider({
    required this.value,
    required this.onChanged,
    this.label = 'Belief %',
  });
  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            max: 100,
            divisions: 20,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

class _DeltaSummary extends StatelessWidget {
  const _DeltaSummary({required this.record});
  final CbtThoughtRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final delta = record.intensityDelta;
    final pos = delta >= 0;
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          Icon(
            pos ? Icons.trending_down : Icons.trending_up,
            color: pos ? cs.primary : cs.error,
          ),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Text(
              'Outcome: emotional intensity '
              '${pos ? 'down' : 'up'} ${delta.abs()} '
              '(sum across emotions, 0–100 scale).',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
