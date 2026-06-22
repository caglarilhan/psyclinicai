import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// One row on the day-view agenda. Kept here (not under models/)
/// because the data shape is UI-only; production data lives in
/// `appointment_model.dart`.
class AppointmentSlot {
  const AppointmentSlot({
    required this.id,
    required this.patientName,
    required this.startsAt,
    required this.durationMinutes,
    required this.kind,
    this.cancelled = false,
    this.noShow = false,
  });

  final String id;
  final String patientName;
  final DateTime startsAt;
  final int durationMinutes;

  /// "therapy" / "intake" / "review" / "telehealth".
  final String kind;

  final bool cancelled;
  final bool noShow;
}

/// Day-view agenda (plan §4) — hourly rows from 08:00 to 20:00 with
/// the day's slots positioned by their start hour. Stateless; the
/// parent owns the slot list and the focused day.
class AppointmentsDayView extends StatelessWidget {
  const AppointmentsDayView({
    super.key,
    required this.day,
    required this.slots,
    this.startHour = 8,
    this.endHour = 20,
    this.onTap,
  });

  final DateTime day;
  final List<AppointmentSlot> slots;
  final int startHour;
  final int endHour;
  final ValueChanged<AppointmentSlot>? onTap;

  List<AppointmentSlot> _slotsForHour(int hour) {
    return slots
        .where(
          (s) =>
              s.startsAt.year == day.year &&
              s.startsAt.month == day.month &&
              s.startsAt.day == day.day &&
              s.startsAt.hour == hour,
        )
        .toList(growable: false)
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(
      endHour - startHour + 1,
      (i) => startHour + i,
    );
    return ListView.builder(
      itemCount: hours.length,
      itemBuilder: (context, i) {
        final h = hours[i];
        final hourSlots = _slotsForHour(h);
        return _HourRow(hour: h, slots: hourSlots, onTap: onTap);
      },
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.slots,
    required this.onTap,
  });
  final int hour;
  final List<AppointmentSlot> slots;
  final ValueChanged<AppointmentSlot>? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (slots.isEmpty)
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: cs.outlineVariant)),
                    ),
                  )
                else
                  for (final s in slots) _SlotCard(slot: s, onTap: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, required this.onTap});
  final AppointmentSlot slot;
  final ValueChanged<AppointmentSlot>? onTap;

  Color _kindColor() {
    switch (slot.kind) {
      case 'intake':
        return PsyColors.info;
      case 'telehealth':
        return PsyColors.primary;
      case 'review':
        return PsyColors.warning;
      case 'therapy':
      default:
        return PsyColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final color = slot.cancelled
        ? cs.outlineVariant
        : slot.noShow
        ? PsyColors.danger
        : _kindColor();
    final tag = slot.cancelled
        ? 'cancelled'
        : slot.noShow
        ? 'no-show'
        : slot.kind;
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(slot),
      child: Container(
        margin: const EdgeInsets.only(bottom: PsySpacing.xs),
        padding: const EdgeInsets.all(PsySpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(PsyRadius.md),
        ),
        child: Row(
          children: [
            Text(
              '${slot.startsAt.hour.toString().padLeft(2, '0')}:'
              '${slot.startsAt.minute.toString().padLeft(2, '0')}',
              style: t.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: PsySpacing.sm),
            Expanded(child: Text(slot.patientName, style: t.bodyMedium)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$tag · ${slot.durationMinutes} min',
                style: t.labelSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
