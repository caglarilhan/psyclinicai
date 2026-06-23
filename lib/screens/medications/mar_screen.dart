/// `/medications/mar` — Medication Administration Record.
///
/// Psychiatry-grade daily dose log: scheduled doses by day, with
/// taken / missed / skipped status, side-effect attachment, and a
/// rolling adherence summary so the clinician can spot drift
/// before the patient walks in for a quarterly med visit.
///
/// Two surfaces in one screen:
///   - **Adherence header** — 7-day rolling adherence % + the
///     count of taken / missed / skipped doses. Red badge when
///     adherence drops below 80 %.
///   - **Daily list** — every scheduled dose for the selected
///     date, joined against the regimen (`Medication`) so the
///     clinician sees the drug + dose + frequency alongside
///     the slot. Tap a row to mark taken / missed / skipped and
///     attach side-effect notes.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/medication.dart';
import '../../models/medication_dose_log.dart';
import '../../models/medication_side_effect.dart';
import '../../services/data/medication_dose_repository.dart';
import '../../services/data/medication_repository.dart';
import '../../services/data/medication_side_effect_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/ds/saving_indicator.dart';
import 'side_effect_sheet.dart';

class MarScreen extends StatefulWidget {
  const MarScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.doseRepository,
    this.medicationRepository,
    this.sideEffectRepository,
    this.clinicianId,
  });

  final String patientId;
  final String patientName;
  final MedicationDoseRepository? doseRepository;
  final MedicationRepository? medicationRepository;
  final MedicationSideEffectRepository? sideEffectRepository;

  /// Recorded on every SE event for audit / supervision. Falls back
  /// to `demo_clinician` when unset (matches the rest of the app's
  /// local-first sentinel).
  final String? clinicianId;

  @override
  State<MarScreen> createState() => _MarScreenState();
}

class _MarScreenState extends State<MarScreen> {
  late final MedicationDoseRepository _doses;
  late final MedicationRepository _meds;
  late final MedicationSideEffectRepository _seRepo;
  late final SavingIndicatorController _saveCtrl;
  late DateTime _selectedDay;
  bool _loading = true;

  String get _clinicianId => widget.clinicianId ?? 'demo_clinician';

  @override
  void initState() {
    super.initState();
    _doses = widget.doseRepository ?? MedicationDoseRepository();
    _meds = widget.medicationRepository ?? MedicationRepository();
    _seRepo = widget.sideEffectRepository ?? MedicationSideEffectRepository();
    _saveCtrl = SavingIndicatorController();
    final now = DateTime.now().toUtc();
    _selectedDay = DateTime.utc(now.year, now.month, now.day);
    unawaited(_load());
  }

  Future<void> _load() async {
    await Future.wait([
      _doses.initialize(),
      _meds.initialize(),
      _seRepo.initialize(),
    ]);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    super.dispose();
  }

  Medication? _medFor(String id) {
    for (final m in _meds.forPatient(widget.patientId)) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> _setStatus(MedicationDoseLog dose, DoseStatus next) async {
    _saveCtrl.startSaving();
    try {
      final updated = dose.copyWith(
        status: next,
        takenAt: next == DoseStatus.taken
            ? DateTime.now().toUtc()
            : dose.takenAt,
      );
      await _doses.upsert(updated);
      _saveCtrl.markSaved();
      if (mounted) setState(() {});
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'mar.set_status_failed',
        ),
      );
      _saveCtrl.markError(onRetry: () => _setStatus(dose, next));
      if (mounted) {
        PsySnack.error(
          context,
          'Could not update dose — please retry.',
          hint: 'mar.set_status_failed',
        );
      }
    }
  }

  Future<void> _addSideEffect(MedicationDoseLog dose) async {
    final draft = await showModalBottomSheet<MedicationSideEffect>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SideEffectSheet(
        patientId: widget.patientId,
        medicationId: dose.medicationId,
        clinicianId: _clinicianId,
      ),
    );
    if (draft == null) return;

    _saveCtrl.startSaving();
    try {
      await _seRepo.upsert(draft);
      // Also append a short label to the dose log's free-text list
      // so the existing inline chip view keeps surfacing what was
      // captured today (mar_screen scans this list to badge the
      // dose row). Source of truth is the SE repo from now on.
      final label = draft.severity.value > 1
          ? '${draft.symptom} (${draft.severity.label.toLowerCase()})'
          : draft.symptom;
      final updated = dose.copyWith(sideEffects: [...dose.sideEffects, label]);
      await _doses.upsert(updated);
      _saveCtrl.markSaved();
      unawaited(
        TelemetryService.instance.capture(
          'mar.side_effect_logged',
          properties: {
            'system': draft.system.id,
            'severity': draft.severity.value,
            'significant': draft.isClinicallySignificant,
          },
        ),
      );
      if (mounted) setState(() {});
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'mar.side_effect_failed',
        ),
      );
      _saveCtrl.markError(onRetry: () => _addSideEffect(dose));
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save side effect — please retry.',
          hint: 'mar.side_effect_failed',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toUtc();
    final weekStart = today.subtract(const Duration(days: 6));
    final weeklyDoses = _loading
        ? const <MedicationDoseLog>[]
        : _doses.forPatientInRange(widget.patientId, weekStart, today);
    final summary = AdherenceSummary.compute(
      start: weekStart,
      end: today,
      doses: weeklyDoses,
    );
    final dayDoses = _loading
        ? const <MedicationDoseLog>[]
        : _doses.forPatientOnDate(widget.patientId, _selectedDay);

    return AppShell(
      routeName: '/patients',
      title: 'MAR — ${widget.patientName}',
      subtitle:
          'Medication Administration Record. Daily doses, side '
          'effects, rolling adherence.',
      breadcrumbs: [
        const Crumb('Home', '/dashboard'),
        const Crumb('Patients', '/patients'),
        Crumb(widget.patientName, null),
        const Crumb('MAR', null),
      ],
      primaryAction: SavingIndicator(controller: _saveCtrl),
      scrollable: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _AdherenceHeader(summary: summary),
                const SizedBox(height: PsySpacing.xl),
                _DayPicker(
                  selected: _selectedDay,
                  onChange: (d) => setState(() => _selectedDay = d),
                ),
                const SizedBox(height: PsySpacing.lg),
                if (dayDoses.isEmpty)
                  const PsyEmptyState(
                    icon: Icons.medication_outlined,
                    title: 'No doses scheduled this day',
                    body:
                        'When the regimen is written or seeded, scheduled '
                        'slots show up here for the patient or caregiver '
                        'to mark off.',
                  )
                else
                  for (final dose in dayDoses)
                    _DoseRow(
                      dose: dose,
                      medication: _medFor(dose.medicationId),
                      onStatus: (s) => _setStatus(dose, s),
                      onSideEffect: () => _addSideEffect(dose),
                    ),
              ],
            ),
    );
  }
}

class _AdherenceHeader extends StatelessWidget {
  const _AdherenceHeader({required this.summary});
  final AdherenceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pct = summary.adherencePct;
    final low = pct < 80;
    return PsyCard(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '7-day adherence',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: PsySpacing.sm),
              PsyBadge(
                label: '$pct%',
                tone: low ? PsyBadgeTone.danger : PsyBadgeTone.success,
              ),
              if (low) ...[
                const SizedBox(width: PsySpacing.sm),
                Text(
                  'below 80% — surface at next visit',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                ),
              ],
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Row(
            children: [
              _Stat(label: 'Scheduled', value: '${summary.scheduled}'),
              const SizedBox(width: PsySpacing.lg),
              _Stat(
                label: 'Taken',
                value: '${summary.taken}',
                color: cs.primary,
              ),
              const SizedBox(width: PsySpacing.lg),
              _Stat(
                label: 'Missed',
                value: '${summary.missed}',
                color: summary.missed > 0
                    ? cs.error
                    : cs.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: PsySpacing.lg),
              _Stat(label: 'Skipped', value: '${summary.skipped}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

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

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onChange});
  final DateTime selected;
  final ValueChanged<DateTime> onChange;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toUtc();
    final start = today.subtract(const Duration(days: 6));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: PsySpacing.sm),
        itemBuilder: (_, i) {
          final d = DateTime.utc(
            start.year,
            start.month,
            start.day,
          ).add(Duration(days: i));
          final isSelected =
              d.year == selected.year &&
              d.month == selected.month &&
              d.day == selected.day;
          return InkWell(
            borderRadius: BorderRadius.circular(PsyRadius.md),
            onTap: () => onChange(d),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.md,
                vertical: PsySpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary
                    : cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(PsyRadius.md),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekday(d.weekday),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? cs.onPrimary : cs.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? cs.onPrimary : cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekday(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[w - 1];
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({
    required this.dose,
    required this.medication,
    required this.onStatus,
    required this.onSideEffect,
  });
  final MedicationDoseLog dose;
  final Medication? medication;
  final ValueChanged<DoseStatus> onStatus;
  final VoidCallback onSideEffect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = medication?.name ?? '(unknown medication)';
    final doseLabel = medication?.dose ?? '';
    final overdue = dose.isOverdue;
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _formatTime(dose.scheduledAt),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleMedium),
                      if (doseLabel.isNotEmpty)
                        Text(
                          doseLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusPill(status: dose.status, overdue: overdue),
              ],
            ),
            if (dose.sideEffects.isNotEmpty) ...[
              const SizedBox(height: PsySpacing.sm),
              Wrap(
                spacing: PsySpacing.sm,
                runSpacing: 4,
                children: [
                  for (final se in dose.sideEffects)
                    PsyBadge(label: se, tone: PsyBadgeTone.warning),
                ],
              ),
            ],
            const SizedBox(height: PsySpacing.md),
            Wrap(
              spacing: PsySpacing.sm,
              runSpacing: PsySpacing.sm,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Taken'),
                  onPressed: dose.status == DoseStatus.taken
                      ? null
                      : () => onStatus(DoseStatus.taken),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Missed'),
                  onPressed: dose.status == DoseStatus.missed
                      ? null
                      : () => onStatus(DoseStatus.missed),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.do_not_disturb_alt, size: 18),
                  label: const Text('Skip'),
                  onPressed: dose.status == DoseStatus.skipped
                      ? null
                      : () => onStatus(DoseStatus.skipped),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_alert_outlined, size: 18),
                  label: const Text('Side effect'),
                  onPressed: onSideEffect,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final local = d.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.overdue});
  final DoseStatus status;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DoseStatus.taken:
        return const PsyBadge(label: 'Taken', tone: PsyBadgeTone.success);
      case DoseStatus.missed:
        return const PsyBadge(label: 'Missed', tone: PsyBadgeTone.danger);
      case DoseStatus.skipped:
        return const PsyBadge(label: 'Skipped');
      case DoseStatus.pending:
        return PsyBadge(
          label: overdue ? 'Overdue' : 'Pending',
          tone: overdue ? PsyBadgeTone.warning : PsyBadgeTone.brand,
        );
    }
  }
}
