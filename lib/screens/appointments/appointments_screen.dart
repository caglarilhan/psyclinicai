import 'dart:async';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_empty_state.dart';
import '../../widgets/ds/psy_skeleton.dart';

/// `/appointments` — month calendar + day agenda + quick scheduling.
///
/// Offline-capable (appointments persist via SharedPreferences). On mobile,
/// adding an appointment schedules 24h + 1h local reminders; on web that is a
/// no-op (see NotificationService). Telehealth video is intentionally out of
/// scope — it needs a signaling backend.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

const _typeLabels = {
  'individual': 'Individual',
  'group': 'Group',
  'followUp': 'Follow-up',
  'emergency': 'Emergency',
};

String _typeLabel(String t) => _typeLabels[t] ?? t;

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _svc = AppointmentService();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    await _svc.initialize();
    if (mounted) setState(() => _loading = false);
  }

  List<Appointment> _forSelected() {
    final list = _svc.getAppointmentsForDate(_selectedDay)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/appointments',
      title: 'Appointments',
      subtitle: 'Schedule sessions and get 24h + 1h reminders (mobile).',
      primaryAction: FilledButton.icon(
        onPressed: _loading ? null : _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('New appointment'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
        ),
      ),
      scrollable: false,
      child: _loading
          ? const PsySkeletonGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calendar grid placeholder (matches _CalendarCard
                  // 320 px footprint).
                  PsySkeletonBlock(height: 320),
                  SizedBox(height: PsySpacing.xl),
                  // 3 agenda row placeholders.
                  PsySkeletonBlock(),
                  SizedBox(height: PsySpacing.md),
                  PsySkeletonBlock(),
                  SizedBox(height: PsySpacing.md),
                  PsySkeletonBlock(),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalendarCard(
                  cs: cs,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  eventsFor: _svc.getAppointmentsForDate,
                  onSelected: (sel, foc) => setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  }),
                ),
                const SizedBox(height: PsySpacing.xl),
                Expanded(child: _agenda(theme, cs)),
              ],
            ),
    );
  }

  Widget _agenda(ThemeData theme, ColorScheme cs) {
    final items = _forSelected();
    final dateLabel = _fmtDate(_selectedDay);
    if (items.isEmpty) {
      return PsyEmptyState(
        icon: Icons.event_available_outlined,
        title: 'No appointments on $dateLabel',
        body: 'Schedule a session — reminders fire 24h and 1h before.',
        action: PsyEmptyStateAction(
          label: 'New appointment',
          icon: Icons.add,
          onTap: _openAdd,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: PsySpacing.sm),
            itemBuilder: (_, i) =>
                _AppointmentTile(appt: items[i], theme: theme, cs: cs),
          ),
        ),
      ],
    );
  }

  Future<void> _openAdd() async {
    final created = await showDialog<Appointment>(
      context: context,
      builder: (_) => _AddAppointmentDialog(initialDay: _selectedDay),
    );
    if (created == null) return;
    await _svc.addAppointment(created);
    if (mounted) setState(() {});
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.cs,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventsFor,
    required this.onSelected,
  });

  final ColorScheme cs;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<Appointment> Function(DateTime) eventsFor;
  final void Function(DateTime, DateTime) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: TableCalendar<Appointment>(
        firstDay: DateTime.utc(2024),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (d) => isSameDay(selectedDay, d),
        onDaySelected: onSelected,
        eventLoader: eventsFor,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: cs.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({
    required this.appt,
    required this.theme,
    required this.cs,
  });
  final Appointment appt;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final time =
        '${appt.startTime.hour.toString().padLeft(2, '0')}:${appt.startTime.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(PsySpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.md,
              vertical: PsySpacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            child: Text(
              time,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.clientName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (appt.notes.isNotEmpty)
                  Text(
                    appt.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.md,
              vertical: PsySpacing.xs,
            ),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsyRadius.full),
            ),
            child: Text(
              _typeLabel(appt.type),
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAppointmentDialog extends StatefulWidget {
  const _AddAppointmentDialog({required this.initialDay});
  final DateTime initialDay;

  @override
  State<_AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<_AddAppointmentDialog> {
  final _client = TextEditingController();
  final _notes = TextEditingController();
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  String _type = 'individual';

  @override
  void initState() {
    super.initState();
    _date = widget.initialDay;
  }

  @override
  void dispose() {
    _client.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New appointment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _client,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Client name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: PsySpacing.md),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: PsySpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule, size: 16),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PsySpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: _typeLabels.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _client.text.trim().isEmpty ? null : _save,
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final start = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final now = DateTime.now();
    final appt = Appointment(
      id: now.microsecondsSinceEpoch.toString(),
      clientId: '',
      clientName: _client.text.trim(),
      startTime: start,
      endTime: start.add(const Duration(minutes: 50)),
      type: _type,
      status: 'scheduled',
      notes: _notes.text.trim(),
      location: '',
      createdAt: now,
      updatedAt: now,
    );
    Navigator.of(context).pop(appt);
  }
}
