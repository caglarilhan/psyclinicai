/// In-session EMDR Session Tracker panel.
///
/// Shapiro's 8-Phase protocol UI. Renders:
///   1. **Phase stepper** — current phase highlight + tap-to-jump.
///   2. **Assessment** (phase 3) — target image / NC / PC / VOC /
///      SUDS / body location.
///   3. **Desensitization** (phase 4) — BLS-set log: add a set, log
///      before/after SUDS + observation. Each set's SUDS trajectory
///      gets a `down` / `up` chip.
///   4. **Installation + body scan + closure** (phases 5–7).
///   5. **Abreaction safety gate** — closure (phase 7) is blocked
///      until the clinician confirms the stabilising resource (safe
///      place, RDI, container) when an abreaction occurred.
///
/// Saves through `ModalitySessionRepository`; telemetry hint
/// `emdr_session.saved` carries `{phase, blsSets, sudsDelta,
/// vocDelta, abreaction, closure_safe}` so the supervision
/// dashboard can monitor sessions that left the room with high
/// SUDS.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/modalities/emdr_session_tracker.dart';
import '../../../services/data/modality_session_repository.dart';
import '../../../services/data/telemetry_service.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ds/psy_badge.dart';
import '../../../widgets/ds/psy_card.dart';
import '../../../widgets/ds/psy_snack.dart';
import '../../../widgets/ds/saving_indicator.dart';

class EmdrSessionTrackerPanel extends StatefulWidget {
  const EmdrSessionTrackerPanel({
    super.key,
    required this.patientId,
    required this.clinicianId,
    this.initial,
    this.repository,
  });

  final String patientId;
  final String clinicianId;
  final EmdrSessionTracker? initial;
  final ModalitySessionRepository? repository;

  @override
  State<EmdrSessionTrackerPanel> createState() =>
      _EmdrSessionTrackerPanelState();
}

class _EmdrSessionTrackerPanelState extends State<EmdrSessionTrackerPanel> {
  late final ModalitySessionRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  late final TextEditingController _targetMemory;
  late final TextEditingController _negativeCognition;
  late final TextEditingController _positiveCognition;
  late final TextEditingController _bodyLocation;
  late final TextEditingController _bodyScanNotes;
  late final TextEditingController _closureNotes;
  late final TextEditingController _reevaluation;
  late final TextEditingController _abreactionResource;
  late final TextEditingController _clinicianNotes;
  late final TextEditingController _newSetObs;
  late int _newSetSudsBefore;
  late int _newSetSudsAfter;
  late EmdrSessionTracker _session;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ModalitySessionRepository();
    _saveCtrl = SavingIndicatorController();
    _session =
        widget.initial ??
        EmdrSessionTracker(
          id: 'emdr-${DateTime.now().microsecondsSinceEpoch}-${widget.patientId}',
          patientId: widget.patientId,
          clinicianId: widget.clinicianId,
          createdAt: DateTime.now().toUtc(),
        );
    _targetMemory = TextEditingController(text: _session.targetMemory);
    _negativeCognition = TextEditingController(
      text: _session.negativeCognition,
    );
    _positiveCognition = TextEditingController(
      text: _session.positiveCognition,
    );
    _bodyLocation = TextEditingController(text: _session.bodyLocation);
    _bodyScanNotes = TextEditingController(text: _session.bodyScanNotes);
    _closureNotes = TextEditingController(text: _session.closureNotes);
    _reevaluation = TextEditingController(text: _session.reevaluationNotes);
    _abreactionResource = TextEditingController(
      text: _session.abreactionResource ?? '',
    );
    _clinicianNotes = TextEditingController(text: _session.clinicianNotes);
    _newSetObs = TextEditingController();
    _newSetSudsBefore = _session.sudsStart;
    _newSetSudsAfter = _session.sudsStart;
    unawaited(_repo.initialize());
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    _targetMemory.dispose();
    _negativeCognition.dispose();
    _positiveCognition.dispose();
    _bodyLocation.dispose();
    _bodyScanNotes.dispose();
    _closureNotes.dispose();
    _reevaluation.dispose();
    _abreactionResource.dispose();
    _clinicianNotes.dispose();
    _newSetObs.dispose();
    super.dispose();
  }

  void _rebindFromControllers() {
    _session = _session.copyWith(
      targetMemory: _targetMemory.text.trim(),
      negativeCognition: _negativeCognition.text.trim(),
      positiveCognition: _positiveCognition.text.trim(),
      bodyLocation: _bodyLocation.text.trim(),
      bodyScanNotes: _bodyScanNotes.text.trim(),
      closureNotes: _closureNotes.text.trim(),
      reevaluationNotes: _reevaluation.text.trim(),
      abreactionResource: _abreactionResource.text.trim().isEmpty
          ? null
          : _abreactionResource.text.trim(),
      clinicianNotes: _clinicianNotes.text.trim(),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _save() async {
    _rebindFromControllers();
    _saveCtrl.startSaving();
    try {
      await _repo.upsert(
        ModalityRecord(kind: ModalityKind.emdr, payload: _session),
      );
      _saveCtrl.markSaved();
      unawaited(
        TelemetryService.instance.capture(
          'emdr_session.saved',
          properties: {
            'phase': _session.currentPhase.id,
            'bls_sets': _session.blsSets.length,
            'suds_delta': _session.sudsDelta,
            'voc_delta': _session.vocDelta,
            'abreaction': _session.abreactionOccurred,
            'closure_safe': _session.isClosureSafe,
          },
        ),
      );
      if (mounted) {
        PsySnack.success(
          context,
          'EMDR session saved.',
          hint: 'emdr_session.save',
        );
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'emdr_session.save_failed',
        ),
      );
      _saveCtrl.markError(onRetry: _save);
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save the EMDR session — please retry.',
          hint: 'emdr_session.save_failed',
        );
      }
    }
  }

  void _setPhase(EmdrPhase p) {
    if (p == EmdrPhase.sevenClosure && !_session.isClosureSafe) {
      PsySnack.warning(
        context,
        'Closure blocked — record the stabilising resource (safe place '
        '/ RDI / container) before advancing.',
        hint: 'emdr_session.closure_blocked',
      );
      return;
    }
    setState(() {
      _session = _session.copyWith(currentPhase: p);
    });
  }

  void _addBlsSet() {
    final set = EmdrBlsSet(
      sequence: _session.blsSets.length + 1,
      sudsBefore: _newSetSudsBefore,
      sudsAfter: _newSetSudsAfter,
      observation: _newSetObs.text.trim(),
    );
    setState(() {
      _session = _session.withBlsSet(set);
      _newSetObs.clear();
      _newSetSudsBefore = _newSetSudsAfter;
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
                'EMDR Session Tracker',
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
          'Shapiro 8-Phase protocol. SUDS 0–10, VOC 1–7. Closure (phase '
          '7) is gated on abreaction safety.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: PsySpacing.xl),

        _PhaseStepper(current: _session.currentPhase, onTap: _setPhase),
        const SizedBox(height: PsySpacing.lg),

        _AssessmentCard(
          session: _session,
          targetCtrl: _targetMemory,
          ncCtrl: _negativeCognition,
          pcCtrl: _positiveCognition,
          bodyCtrl: _bodyLocation,
          onVocStartChanged: (v) =>
              setState(() => _session = _session.copyWith(vocStart: v)),
          onSudsStartChanged: (v) =>
              setState(() => _session = _session.copyWith(sudsStart: v)),
        ),
        const SizedBox(height: PsySpacing.lg),

        _DesensitizationCard(
          session: _session,
          obsCtrl: _newSetObs,
          newSudsBefore: _newSetSudsBefore,
          newSudsAfter: _newSetSudsAfter,
          onBeforeChanged: (v) => setState(() => _newSetSudsBefore = v),
          onAfterChanged: (v) => setState(() => _newSetSudsAfter = v),
          onAdd: _addBlsSet,
          onSudsEndChanged: (v) =>
              setState(() => _session = _session.copyWith(sudsEnd: v)),
        ),
        const SizedBox(height: PsySpacing.lg),

        _InstallationCard(
          session: _session,
          onVocEndChanged: (v) =>
              setState(() => _session = _session.copyWith(vocEnd: v)),
        ),
        const SizedBox(height: PsySpacing.lg),

        _AbreactionCard(
          session: _session,
          resourceCtrl: _abreactionResource,
          onToggle: (v) => setState(
            () => _session = _session.copyWith(abreactionOccurred: v),
          ),
        ),
        const SizedBox(height: PsySpacing.lg),

        _NotesCard(
          title: 'Body scan (phase 6)',
          subtitle: 'Hold target + PC; clear any residual body sensation.',
          ctrl: _bodyScanNotes,
        ),
        _NotesCard(
          title: 'Closure (phase 7)',
          subtitle: 'Stabilize; what the patient is taking with them.',
          ctrl: _closureNotes,
        ),
        _NotesCard(
          title: 'Reevaluation (phase 8 — next session)',
          subtitle: 'Did SUDS hold? Did VOC stay strong?',
          ctrl: _reevaluation,
        ),
        _NotesCard(
          title: 'Clinician-only notes',
          subtitle: 'Supervision flag, plan tweak — not patient-facing.',
          ctrl: _clinicianNotes,
        ),

        const SizedBox(height: PsySpacing.lg),
        _ArcSummary(session: _session),
      ],
    );
  }
}

class _PhaseStepper extends StatelessWidget {
  const _PhaseStepper({required this.current, required this.onTap});
  final EmdrPhase current;
  final ValueChanged<EmdrPhase> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Wrap(
        spacing: PsySpacing.sm,
        runSpacing: PsySpacing.sm,
        children: [
          for (final p in EmdrPhase.values)
            InkWell(
              borderRadius: BorderRadius.circular(PsyRadius.md),
              onTap: () => onTap(p),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PsySpacing.md,
                  vertical: PsySpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: p == current
                      ? cs.primary
                      : cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(PsyRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${p.index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: p == current ? cs.onPrimary : cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    Text(
                      p.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: p == current ? cs.onPrimary : cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.session,
    required this.targetCtrl,
    required this.ncCtrl,
    required this.pcCtrl,
    required this.bodyCtrl,
    required this.onVocStartChanged,
    required this.onSudsStartChanged,
  });
  final EmdrSessionTracker session;
  final TextEditingController targetCtrl;
  final TextEditingController ncCtrl;
  final TextEditingController pcCtrl;
  final TextEditingController bodyCtrl;
  final ValueChanged<int> onVocStartChanged;
  final ValueChanged<int> onSudsStartChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assessment (phase 3)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          TextField(
            controller: targetCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Target memory (worst image)',
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: ncCtrl,
            decoration: const InputDecoration(
              labelText: 'Negative cognition (NC)',
              hintText: 'e.g. "I am not safe"',
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: pcCtrl,
            decoration: const InputDecoration(
              labelText: 'Positive cognition (PC)',
              hintText: 'e.g. "I can protect myself now"',
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              Expanded(
                child: _ScaleSlider(
                  label: 'VOC start (1–7)',
                  value: session.vocStart,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  onChanged: onVocStartChanged,
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: _ScaleSlider(
                  label: 'SUDS start (0–10)',
                  value: session.sudsStart,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: onSudsStartChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: bodyCtrl,
            decoration: const InputDecoration(
              labelText: 'Body location of distress',
              hintText: 'e.g. "tight chest", "throat", "stomach"',
            ),
          ),
        ],
      ),
    );
  }
}

class _DesensitizationCard extends StatelessWidget {
  const _DesensitizationCard({
    required this.session,
    required this.obsCtrl,
    required this.newSudsBefore,
    required this.newSudsAfter,
    required this.onBeforeChanged,
    required this.onAfterChanged,
    required this.onAdd,
    required this.onSudsEndChanged,
  });
  final EmdrSessionTracker session;
  final TextEditingController obsCtrl;
  final int newSudsBefore;
  final int newSudsAfter;
  final ValueChanged<int> onBeforeChanged;
  final ValueChanged<int> onAfterChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onSudsEndChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Desensitization (phase 4) — ${session.blsSets.length} BLS set'
            '${session.blsSets.length == 1 ? '' : 's'}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final s in session.blsSets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${s.sequence}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: PsySpacing.md),
                  Text('SUDS ${s.sudsBefore} → ${s.sudsAfter}'),
                  const SizedBox(width: PsySpacing.md),
                  PsyBadge(
                    label: s.movedDown ? 'down' : 'up',
                    tone: s.movedDown
                        ? PsyBadgeTone.success
                        : PsyBadgeTone.warning,
                  ),
                  if (s.observation.isNotEmpty) ...[
                    const SizedBox(width: PsySpacing.md),
                    Expanded(
                      child: Text(
                        s.observation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const Divider(height: PsySpacing.xl),
          Row(
            children: [
              Expanded(
                child: _ScaleSlider(
                  label: 'New set — SUDS before',
                  value: newSudsBefore,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: onBeforeChanged,
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: _ScaleSlider(
                  label: 'New set — SUDS after',
                  value: newSudsAfter,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: onAfterChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          TextField(
            controller: obsCtrl,
            decoration: const InputDecoration(
              labelText: 'Observation (what came up)',
              hintText: 'Image shift / body sensation / new association',
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Log BLS set'),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _ScaleSlider(
            label: 'SUDS end (closing the desensitization channel)',
            value: session.sudsEnd ?? session.sudsStart,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: onSudsEndChanged,
          ),
        ],
      ),
    );
  }
}

class _InstallationCard extends StatelessWidget {
  const _InstallationCard({
    required this.session,
    required this.onVocEndChanged,
  });
  final EmdrSessionTracker session;
  final ValueChanged<int> onVocEndChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Installation (phase 5)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Install the PC; re-rate VOC. Target: 6 or 7.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          _ScaleSlider(
            label: 'VOC end (1–7)',
            value: session.vocEnd ?? session.vocStart,
            min: 1,
            max: 7,
            divisions: 6,
            onChanged: onVocEndChanged,
          ),
        ],
      ),
    );
  }
}

class _AbreactionCard extends StatelessWidget {
  const _AbreactionCard({
    required this.session,
    required this.resourceCtrl,
    required this.onToggle,
  });
  final EmdrSessionTracker session;
  final TextEditingController resourceCtrl;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final safe = session.isClosureSafe;
    return PsyCard(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                safe ? Icons.shield_outlined : Icons.warning_amber,
                color: safe ? cs.primary : cs.error,
              ),
              const SizedBox(width: PsySpacing.sm),
              Text(
                'Abreaction safety',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'No patient leaves the room in an unresolved abreaction. If '
            'one occurred this session, record the stabilising resource '
            'used.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Abreaction occurred this session'),
            value: session.abreactionOccurred,
            onChanged: onToggle,
          ),
          if (session.abreactionOccurred)
            TextField(
              controller: resourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Stabilising resource used',
                hintText: 'Safe place / RDI / Container / Light Stream',
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({
    required this.title,
    required this.subtitle,
    required this.ctrl,
  });
  final String title;
  final String subtitle;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: PsySpacing.sm),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Notes…'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcSummary extends StatelessWidget {
  const _ArcSummary({required this.session});
  final EmdrSessionTracker session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final suds = session.sudsDelta;
    final voc = session.vocDelta;
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          Expanded(
            child: _StatBubble(
              label: 'SUDS arc',
              value: suds == null
                  ? '—'
                  : '${session.sudsStart} → ${session.sudsEnd}',
              color: suds == null
                  ? cs.onSurface.withValues(alpha: 0.6)
                  : (suds <= 0 ? cs.primary : cs.error),
            ),
          ),
          Expanded(
            child: _StatBubble(
              label: 'VOC arc',
              value: voc == null
                  ? '—'
                  : '${session.vocStart} → ${session.vocEnd}',
              color: voc == null
                  ? cs.onSurface.withValues(alpha: 0.6)
                  : (voc >= 0 ? cs.primary : cs.error),
            ),
          ),
          Expanded(
            child: _StatBubble(
              label: 'BLS sets',
              value: '${session.blsSets.length}',
              color: cs.secondary,
            ),
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

class _ScaleSlider extends StatelessWidget {
  const _ScaleSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$label — $value', style: theme.textTheme.labelMedium),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: divisions,
          label: '$value',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
