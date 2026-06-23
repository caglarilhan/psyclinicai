/// `/assessments/aseba` — ASEBA score-only intake screen.
///
/// The CBCL / TRF / YSR items are proprietary — clinicians score
/// them externally on the official ASEBA tool and bring the
/// T-scores back into the chart for trending. This screen is that
/// entry surface: form picker at the top, three T-score sections
/// (8 syndrome scales, 6 DSM-oriented scales, 3 broad-band
/// composites), live cutoff-band badges so the clinician sees
/// borderline/clinical flags as they type.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/aseba_score_record.dart';
import '../../services/data/aseba_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/ds/saving_indicator.dart';

class AsebaIntakeScreen extends StatefulWidget {
  const AsebaIntakeScreen({
    super.key,
    required this.patientId,
    required this.clinicianId,
    this.repository,
    this.initial,
  });

  final String patientId;
  final String clinicianId;
  final AsebaRepository? repository;
  final AsebaScoreRecord? initial;

  @override
  State<AsebaIntakeScreen> createState() => AsebaIntakeScreenState();
}

class AsebaIntakeScreenState extends State<AsebaIntakeScreen> {
  late final AsebaRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  late AsebaForm _form;
  late Map<AsebaSyndromeScale, int> _syndromeT;
  late Map<AsebaDsmScale, int> _dsmT;
  late Map<AsebaCompositeScale, int> _compositeT;
  late final TextEditingController _notes;
  late String _recordId;
  late DateTime _capturedAt;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AsebaRepository();
    _saveCtrl = SavingIndicatorController();
    final init = widget.initial;
    if (init != null) {
      _recordId = init.id;
      _capturedAt = init.capturedAt;
      _form = init.form;
      _syndromeT = Map.of(init.syndromeT);
      _dsmT = Map.of(init.dsmT);
      _compositeT = Map.of(init.compositeT);
      _notes = TextEditingController(text: init.notes);
    } else {
      final now = DateTime.now().toUtc();
      _recordId = 'aseba-${now.microsecondsSinceEpoch}-${widget.patientId}';
      _capturedAt = now;
      _form = AsebaForm.cbclParent;
      _syndromeT = {};
      _dsmT = {};
      _compositeT = {};
      _notes = TextEditingController();
    }
    unawaited(_repo.initialize());
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    _notes.dispose();
    super.dispose();
  }

  AsebaScoreRecord _build() => AsebaScoreRecord(
    id: _recordId,
    patientId: widget.patientId,
    clinicianId: widget.clinicianId,
    form: _form,
    capturedAt: _capturedAt,
    syndromeT: Map.of(_syndromeT),
    dsmT: Map.of(_dsmT),
    compositeT: Map.of(_compositeT),
    notes: _notes.text.trim(),
  );

  Future<void> _save() async {
    _saveCtrl.startSaving();
    try {
      await _repo.upsert(_build());
      _saveCtrl.markSaved();
      if (mounted) {
        PsySnack.success(context, 'ASEBA scores saved.', hint: 'aseba.save');
      }
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'aseba.save_failed',
        ),
      );
      _saveCtrl.markError(onRetry: _save);
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save — please retry.',
          hint: 'aseba.save_failed',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = _build();
    return AppShell(
      routeName: '/assessments/aseba',
      title: 'ASEBA — score-only intake',
      subtitle:
          'Externally-computed T-scores from CBCL / TRF / YSR. The item '
          'set is licensed; only the totals live here for trending.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Assessments', '/assessments'),
        Crumb('ASEBA', null),
      ],
      primaryAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SavingIndicator(controller: _saveCtrl),
          const SizedBox(width: PsySpacing.sm),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormPicker(form: _form, onChanged: (f) => setState(() => _form = f)),
          const SizedBox(height: PsySpacing.md),
          _SummaryCard(record: record),
          const SizedBox(height: PsySpacing.md),

          _ScaleSection<AsebaSyndromeScale>(
            title: '8 syndrome scales',
            subtitle:
                'Empirically-derived dimensions. Cutoff: T < 65 normal, '
                '65-69 borderline, at least 70 clinical.',
            scales: AsebaSyndromeScale.values,
            label: (s) => s.label,
            values: _syndromeT,
            onChanged: (s, v) => setState(() {
              if (v == null) {
                _syndromeT.remove(s);
              } else {
                _syndromeT[s] = v;
              }
            }),
            band: AsebaScoreRecord.subscaleBand,
          ),
          _ScaleSection<AsebaDsmScale>(
            title: '6 DSM-oriented scales',
            subtitle:
                'Items regrouped to map onto DSM-5. Same cutoffs as the '
                'syndrome scales.',
            scales: AsebaDsmScale.values,
            label: (s) => s.label,
            values: _dsmT,
            onChanged: (s, v) => setState(() {
              if (v == null) {
                _dsmT.remove(s);
              } else {
                _dsmT[s] = v;
              }
            }),
            band: AsebaScoreRecord.subscaleBand,
          ),
          _ScaleSection<AsebaCompositeScale>(
            title: '3 broad-band composites',
            subtitle:
                'Composite cutoff: T < 60 normal, 60-63 borderline, '
                'at least 64 clinical.',
            scales: AsebaCompositeScale.values,
            label: (s) => s.label,
            values: _compositeT,
            onChanged: (s, v) => setState(() {
              if (v == null) {
                _compositeT.remove(s);
              } else {
                _compositeT[s] = v;
              }
            }),
            band: AsebaScoreRecord.compositeBand,
          ),

          PsyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clinician audit / supervision context. Not visible to '
                  'family.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: PsySpacing.md),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. CBCL administered by paediatrician on '
                        '2026-06-22 and emailed.',
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

class _FormPicker extends StatelessWidget {
  const _FormPicker({required this.form, required this.onChanged});
  final AsebaForm form;
  final ValueChanged<AsebaForm> onChanged;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick the paper-form the externally-computed T-scores '
            'came from.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: PsySpacing.md),
          SegmentedButton<AsebaForm>(
            showSelectedIcon: false,
            segments: [
              for (final f in AsebaForm.values)
                ButtonSegment(value: f, label: Text(f.label)),
            ],
            selected: {form},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.record});
  final AsebaScoreRecord record;

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
            'Live summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Counts of subscales at clinical cutoff + total-problems '
            'flag. Updates as you type.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Wrap(
            spacing: PsySpacing.sm,
            runSpacing: PsySpacing.sm,
            children: [
              PsyBadge(
                label: 'Syndrome clinical: ${record.syndromeClinicalCount} / 8',
                tone: record.syndromeClinicalCount > 0
                    ? PsyBadgeTone.warning
                    : PsyBadgeTone.success,
              ),
              PsyBadge(
                label: 'DSM clinical: ${record.dsmClinicalCount} / 6',
                tone: record.dsmClinicalCount > 0
                    ? PsyBadgeTone.warning
                    : PsyBadgeTone.success,
              ),
              PsyBadge(
                label: record.totalProblemsClinical
                    ? 'Total problems: clinical'
                    : 'Total problems: below cutoff',
                tone: record.totalProblemsClinical
                    ? PsyBadgeTone.danger
                    : PsyBadgeTone.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScaleSection<T> extends StatelessWidget {
  const _ScaleSection({
    required this.title,
    required this.subtitle,
    required this.scales,
    required this.label,
    required this.values,
    required this.onChanged,
    required this.band,
  });
  final String title;
  final String subtitle;
  final List<T> scales;
  final String Function(T) label;
  final Map<T, int> values;
  final void Function(T scale, int? value) onChanged;
  final AsebaBand Function(int) band;

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
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: PsySpacing.md),
            for (var i = 0; i < scales.length; i++) ...[
              _ScaleRow<T>(
                label: label(scales[i]),
                value: values[scales[i]],
                onChanged: (v) => onChanged(scales[i], v),
                band: band,
              ),
              if (i < scales.length - 1) const Divider(height: PsySpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScaleRow<T> extends StatefulWidget {
  const _ScaleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.band,
  });
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final AsebaBand Function(int) band;

  @override
  State<_ScaleRow<T>> createState() => _ScaleRowState<T>();
}

class _ScaleRowState<T> extends State<_ScaleRow<T>> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant _ScaleRow<T> old) {
    super.didUpdateWidget(old);
    final next = widget.value?.toString() ?? '';
    if (_ctrl.text != next) _ctrl.text = next;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final band = v == null ? null : widget.band(v);
    final color = band == null
        ? cs.onSurface.withValues(alpha: 0.55)
        : band == AsebaBand.clinical
        ? cs.error
        : band == AsebaBand.borderline
        ? cs.secondary
        : cs.tertiary;
    return Row(
      children: [
        Expanded(child: Text(widget.label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: PsySpacing.sm),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'T-score',
              isDense: true,
            ),
            onChanged: (txt) {
              if (txt.trim().isEmpty) {
                widget.onChanged(null);
                return;
              }
              final n = int.tryParse(txt.trim());
              if (n == null) return;
              widget.onChanged(n.clamp(0, 100));
            },
          ),
        ),
        const SizedBox(width: PsySpacing.sm),
        SizedBox(
          width: 96,
          child: Text(
            band == null
                ? '—'
                : band == AsebaBand.clinical
                ? 'Clinical'
                : band == AsebaBand.borderline
                ? 'Borderline'
                : 'Normal',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
