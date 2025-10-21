import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/patient_service.dart';
import '../telemedicine/telemedicine_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/data_export_service.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
// Web'de gerçek dart:html, diğer platformlarda stub
import '../../utils/html_stub.dart' if (dart.library.html) 'dart:html' as html;
import '../../services/homework_service.dart';
import 'dart:typed_data';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTime;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  AppointmentStatus? _statusFilter;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      patientName: 'Ahmet Yılmaz',
      patientId: '1',
      date: DateTime(2024, 2, 15, 10, 0),
      duration: 60,
      type: AppointmentType.therapy,
      status: AppointmentStatus.scheduled,
      notes: 'Depresyon tedavisi - 3. seans',
      therapistName: 'Dr. Ayşe Demir',
    ),
    Appointment(
      id: '2',
      patientName: 'Ayşe Demir',
      patientId: '2',
      date: DateTime(2024, 2, 15, 14, 30),
      duration: 45,
      type: AppointmentType.consultation,
      status: AppointmentStatus.scheduled,
      notes: 'Anksiyete konsültasyonu',
      therapistName: 'Dr. Mehmet Kaya',
    ),
    Appointment(
      id: '3',
      patientName: 'Mehmet Kaya',
      patientId: '3',
      date: DateTime(2024, 2, 16, 9, 0),
      duration: 60,
      type: AppointmentType.followUp,
      status: AppointmentStatus.completed,
      notes: 'PTSD takip seansı - tamamlandı',
      therapistName: 'Dr. Ayşe Demir',
    ),
    Appointment(
      id: '4',
      patientName: 'Fatma Özkan',
      patientId: '4',
      date: DateTime(2024, 2, 16, 11, 0),
      duration: 30,
      type: AppointmentType.assessment,
      status: AppointmentStatus.cancelled,
      notes: 'İlk değerlendirme - iptal edildi',
      therapistName: 'Dr. Mehmet Kaya',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAppointmentDialog,
          ),
          IconButton(
            tooltip: 'CSV Dışa Aktar',
            icon: const Icon(Icons.table_view),
            onPressed: _exportCsv,
          ),
          IconButton(
            tooltip: 'HTML Dışa Aktar',
            icon: const Icon(Icons.html),
            onPressed: _exportHtml,
          ),
          IconButton(
            tooltip: 'ICS (Takvim) Dışa Aktar',
            icon: const Icon(Icons.event_available),
            onPressed: _exportIcs,
          ),
          IconButton(
            tooltip: 'ICS (Tümü)',
            icon: const Icon(Icons.cloud_download),
            onPressed: _exportIcsAll,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Takvim
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar<Appointment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          // Ödevlerim Paneli
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HomeworkPanel(),
          ),
          const SizedBox(height: 8),
          
          // Seçilen günün randevuları
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Bir gün seçin'))
                : _buildAppointmentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _exportCsv() async {
    final data = await DataExportService().exportData(
      type: ExportType.appointments,
      format: ExportFormat.csv,
      filters: {'day': _selectedDay?.toIso8601String(), 'status': _statusFilter?.name, 'q': _searchQuery},
    );
    await Clipboard.setData(ClipboardData(text: data));
    if (kIsWeb) {
      final bytes = Uint8List.fromList(data.codeUnits);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute('download', 'randevular.csv')..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = XFile.fromData(Uint8List.fromList(data.codeUnits), name: 'randevular.csv', mimeType: 'text/csv');
      await Share.shareXFiles([file], text: 'Randevular CSV');
    }
  }

  Future<void> _exportHtml() async {
    final json = await DataExportService().exportData(
      type: ExportType.appointments,
      format: ExportFormat.json,
      filters: {'day': _selectedDay?.toIso8601String(), 'status': _statusFilter?.name, 'q': _searchQuery},
    );
    final htmlStr = '<html><body><h2>Randevular</h2><pre>${json}</pre></body></html>';
    await Clipboard.setData(ClipboardData(text: htmlStr));
    if (kIsWeb) {
      final bytes = Uint8List.fromList(htmlStr.codeUnits);
      final blob = html.Blob([bytes], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute('download', 'randevular.html')..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = XFile.fromData(Uint8List.fromList(htmlStr.codeUnits), name: 'randevular.html', mimeType: 'text/html');
      await Share.shareXFiles([file], text: 'Randevular HTML');
    }
  }

  Future<void> _exportIcs() async {
    final day = _selectedDay ?? DateTime.now();
    final events = _appointments.where((a)=> isSameDay(a.date, day)).toList();
    final sb = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//PsyClinicAI//Appointments//TR');
    for(final a in events){
      final dtStart = DateFormat("yyyyMMdd'T'HHmmss").format(a.date.toUtc());
      final dtEnd = DateFormat("yyyyMMdd'T'HHmmss").format(a.date.add(Duration(minutes: a.duration)).toUtc());
      sb
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${a.id}@psyclinicai')
        ..writeln('DTSTAMP:${DateFormat("yyyyMMdd'T'HHmmss").format(DateTime.now().toUtc())}Z')
        ..writeln('DTSTART:${dtStart}Z')
        ..writeln('DTEND:${dtEnd}Z')
        ..writeln('SUMMARY:${a.patientName} - ${_getTypeText(a.type)}')
        ..writeln('DESCRIPTION:${a.notes.replaceAll('\n',' ')}')
        ..writeln('END:VEVENT');
    }
    sb.writeln('END:VCALENDAR');
    final ics = sb.toString();
    final bytes = Uint8List.fromList(ics.codeUnits);
    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/calendar');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute('download', 'randevular.ics')..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = XFile.fromData(bytes, name: 'randevular.ics', mimeType: 'text/calendar');
      await Share.shareXFiles([file], text: 'Randevular ICS');
    }
  }

  Future<void> _exportIcsAll() async {
    final events = _appointments.toList();
    final sb = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//PsyClinicAI//Appointments//TR');
    for(final a in events){
      final dtStart = DateFormat("yyyyMMdd'T'HHmmss").format(a.date.toUtc());
      final dtEnd = DateFormat("yyyyMMdd'T'HHmmss").format(a.date.add(Duration(minutes: a.duration)).toUtc());
      sb
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${a.id}@psyclinicai')
        ..writeln('DTSTAMP:${DateFormat("yyyyMMdd'T'HHmmss").format(DateTime.now().toUtc())}Z')
        ..writeln('DTSTART:${dtStart}Z')
        ..writeln('DTEND:${dtEnd}Z')
        ..writeln('SUMMARY:${a.patientName} - ${_getTypeText(a.type)}')
        ..writeln('DESCRIPTION:${a.notes.replaceAll('\n',' ')}')
        ..writeln('END:VEVENT');
    }
    sb.writeln('END:VCALENDAR');
    final ics = sb.toString();
    final bytes = Uint8List.fromList(ics.codeUnits);
    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/calendar');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute('download', 'randevular_tumu.ics')..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final file = XFile.fromData(bytes, name: 'randevular_tumu.ics', mimeType: 'text/calendar');
      await Share.shareXFiles([file], text: 'Randevular ICS (Tümü)');
    }
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _appointments.where((appointment) {
      return isSameDay(appointment.date, day);
    }).toList();
  }

  void _filterToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = DateTime(now.year, now.month, now.day);
      _focusedDay = _selectedDay!;
    });
  }

  void _filterTomorrow() {
    final t = DateTime.now().add(const Duration(days: 1));
    setState(() {
      _selectedDay = DateTime(t.year, t.month, t.day);
      _focusedDay = _selectedDay!;
    });
  }

  Widget _buildAppointmentsList() {
    final selected = _selectedDay!;
    final weekStart = selected.subtract(Duration(days: selected.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final dayAppointments = _appointments.where((appointment) {
      bool matchDay = isSameDay(appointment.date, selected);
      if (_rangeStart != null || _rangeEnd != null) {
        final start = _rangeStart ?? DateTime(1900);
        final end = _rangeEnd ?? DateTime(2100);
        matchDay = appointment.date.isAfter(start.subtract(const Duration(days: 1))) && appointment.date.isBefore(end.add(const Duration(days: 1)));
      }
      final matchText = _searchQuery.isEmpty || appointment.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) || appointment.therapistName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchDay && matchText;
    }).toList();

    if (dayAppointments.isEmpty && _searchQuery.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Bu gün için randevu yok',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDay!),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Hasta veya terapist ara...'),
              onChanged: (v){ setState(()=> _searchQuery = v.trim()); },
            )),
            const SizedBox(width: 8),
            DropdownButton<AppointmentStatus?>(
              value: _statusFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Tümü')),
                DropdownMenuItem(value: AppointmentStatus.scheduled, child: Text('Planlandı')),
                DropdownMenuItem(value: AppointmentStatus.completed, child: Text('Tamamlandı')),
                DropdownMenuItem(value: AppointmentStatus.cancelled, child: Text('İptal')),
                DropdownMenuItem(value: AppointmentStatus.noShow, child: Text('Gelmedi')),
              ],
              onChanged: (v){ setState(()=> _statusFilter = v); },
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _filterToday, child: const Text('Bugün')),
            const SizedBox(width: 4),
            OutlinedButton(onPressed: _filterTomorrow, child: const Text('Yarın')),
            const SizedBox(width: 4),
            OutlinedButton(
              onPressed: (){
                final selected = _selectedDay!;
                final weekStart = selected.subtract(Duration(days: selected.weekday - 1));
                setState((){
                  _rangeStart = weekStart;
                  _rangeEnd = weekStart.add(const Duration(days: 4));
                });
              },
              child: const Text('Hafta İçi'),
            ),
            const SizedBox(width: 4),
            OutlinedButton(
              onPressed: (){
                final selected = _selectedDay!;
                final weekStart = selected.subtract(Duration(days: selected.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 6));
                setState((){
                  _rangeStart = weekStart.add(const Duration(days: 5));
                  _rangeEnd = weekEnd;
                });
              },
              child: const Text('Hafta Sonu'),
            ),
            const SizedBox(width: 8),
            if (_rangeStart != null && _rangeEnd != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(children: [
                  const Icon(Icons.filter_alt, size: 14, color: Colors.deepPurple),
                  const SizedBox(width: 4),
                  Text('${DateFormat('dd.MM').format(_rangeStart!)} - ${DateFormat('dd.MM').format(_rangeEnd!)}', style: const TextStyle(color: Colors.deepPurple)),
                  const SizedBox(width: 6),
                  GestureDetector(onTap: (){ setState(()=> {_rangeStart=null, _rangeEnd=null}); }, child: const Icon(Icons.close, size: 14, color: Colors.deepPurple)),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        // Görünüm geçişi: Ay / 2 Hafta / Hafta
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ToggleButtons(
                isSelected: [
                  _calendarFormat == CalendarFormat.month,
                  _calendarFormat == CalendarFormat.twoWeeks,
                  _calendarFormat == CalendarFormat.week,
                ],
                onPressed: (i){
                  setState((){
                    _calendarFormat = i == 0 ? CalendarFormat.month : i == 1 ? CalendarFormat.twoWeeks : CalendarFormat.week;
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Ay')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('2 Hafta')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Hafta')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _rangeStart ?? _selectedDay ?? DateTime.now(), firstDate: DateTime(2020,1,1), lastDate: DateTime(2035,12,31));
                if(d!=null){ setState(()=> _rangeStart = d); }
              },
              icon: const Icon(Icons.date_range),
              label: Text(_rangeStart==null? 'Başlangıç' : DateFormat('dd.MM.yyyy').format(_rangeStart!)),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _rangeEnd ?? _selectedDay ?? DateTime.now(), firstDate: DateTime(2020,1,1), lastDate: DateTime(2035,12,31));
                if(d!=null){ setState(()=> _rangeEnd = d); }
              },
              icon: const Icon(Icons.event),
              label: Text(_rangeEnd==null? 'Bitiş' : DateFormat('dd.MM.yyyy').format(_rangeEnd!)),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: (){ setState((){ _rangeStart=null; _rangeEnd=null; }); }, child: const Text('Temizle')),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dayAppointments.length,
            itemBuilder: (context, index) {
              final appointment = dayAppointments[index];
              if (_statusFilter != null && appointment.status != _statusFilter) { return const SizedBox.shrink(); }
              return _buildAppointmentCard(appointment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(appointment.type),
                    color: _getStatusColor(appointment.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.therapistName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(appointment.status),
                const SizedBox(width: 4),
                _statusMenu(appointment),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(appointment.date),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${appointment.duration} dk',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getTypeText(appointment.type),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                appointment.notes,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: (){
                    setState((){
                      final idx = _appointments.indexWhere((a)=> a.id == appointment.id);
                      if(idx>=0){
                        _appointments[idx] = Appointment(
                          id: appointment.id,
                          patientName: appointment.patientName,
                          patientId: appointment.patientId,
                          date: appointment.date,
                          duration: appointment.duration,
                          type: appointment.type,
                          status: appointment.status == AppointmentStatus.completed ? AppointmentStatus.scheduled : AppointmentStatus.completed,
                          notes: appointment.notes,
                          therapistName: appointment.therapistName,
                        );
                      }
                    });
                  },
                  child: Text(appointment.status == AppointmentStatus.completed ? 'Geri Al' : 'Tamamla'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=> TelemedicineScreen(initialPatientName: appointment.patientName, initialPatientId: appointment.patientId)));
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Telemedicine'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showAppointmentDetails(appointment),
                  child: const Text('Detaylar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleAppointmentAction('edit', appointment),
                  child: const Text('Düzenle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color color;
    String text;

    switch (status) {
      case AppointmentStatus.scheduled:
        color = Colors.blue;
        text = 'Planlandı';
        break;
      case AppointmentStatus.completed:
        color = Colors.green;
        text = 'Tamamlandı';
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        text = 'İptal';
        break;
      case AppointmentStatus.noShow:
        color = Colors.orange;
        text = 'Gelmedi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }

  PopupMenuButton<String> _statusMenu(Appointment appointment){
    return PopupMenuButton<String>(
      onSelected: (v){
        setState((){
          final idx = _appointments.indexWhere((a)=> a.id == appointment.id);
          if(idx>=0){
            _appointments[idx] = Appointment(
              id: appointment.id,
              patientName: appointment.patientName,
              patientId: appointment.patientId,
              date: appointment.date,
              duration: appointment.duration,
              type: appointment.type,
              status: v=='done'? AppointmentStatus.completed : v=='cancel'? AppointmentStatus.cancelled : AppointmentStatus.noShow,
              notes: appointment.notes,
              therapistName: appointment.therapistName,
            );
          }
        });
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'done', child: Text('Tamamlandı')), 
        PopupMenuItem(value: 'cancel', child: Text('İptal')), 
        PopupMenuItem(value: 'noshow', child: Text('Gelmedi')),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  IconData _getTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.therapy:
        return Icons.psychology;
      case AppointmentType.consultation:
        return Icons.medical_services;
      case AppointmentType.followUp:
        return Icons.update;
      case AppointmentType.assessment:
        return Icons.assessment;
    }
  }

  String _getTypeText(AppointmentType type) {
    switch (type) {
      case AppointmentType.therapy:
        return 'Terapi';
      case AppointmentType.consultation:
        return 'Konsültasyon';
      case AppointmentType.followUp:
        return 'Takip';
      case AppointmentType.assessment:
        return 'Değerlendirme';
    }
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Randevu'),
        content: _AddAppointmentForm(onSaved: (patientId, date, duration, type, notes){
          final p = context.read<PatientService>().getById(patientId);
          if (p == null) return;
          setState((){
            _appointments.add(Appointment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              patientName: p.name,
              patientId: p.id,
              date: date,
              duration: duration,
              type: type,
              status: AppointmentStatus.scheduled,
              notes: notes ?? '',
              therapistName: 'Klinisyen',
            ));
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Randevu oluşturuldu')));
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

// _AddAppointmentForm sınıfları aşağıya taşındı (State dışına)

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: const Text('Randevu filtreleri burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showWeekToggleInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hafta İçi/Hafta Sonu'),
        content: const Text('Hızlı filtreler yakında: Seçili haftanın sadece hafta içi veya hafta sonu randevularını göstereceğiz.'),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.patientName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tarih', DateFormat('dd.MM.yyyy HH:mm').format(appointment.date)),
              _buildDetailRow('Süre', '${appointment.duration} dakika'),
              _buildDetailRow('Tür', _getTypeText(appointment.type)),
              _buildDetailRow('Durum', _getStatusText(appointment.status)),
              _buildDetailRow('Terapist', appointment.therapistName),
              if (appointment.notes.isNotEmpty)
                _buildDetailRow('Notlar', appointment.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAppointmentAction('edit', appointment);
            },
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Planlandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
      case AppointmentStatus.noShow:
        return 'Gelmedi';
    }
  }

  void _handleAppointmentAction(String action, Appointment appointment) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appointment.patientName} randevusu düzenleme özelliği yakında eklenecek')),
        );
        break;
      case 'cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appointment.patientName} randevusu iptal etme özelliği yakında eklenecek')),
        );
        break;
      case 'complete':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appointment.patientName} randevusu tamamlama özelliği yakında eklenecek')),
        );
        break;
    }
  }
}

// Randevu modeli
class Appointment {
  final String id;
  final String patientName;
  final String patientId;
  final DateTime date;
  final int duration;
  final AppointmentType type;
  final AppointmentStatus status;
  final String notes;
  final String therapistName;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.date,
    required this.duration,
    required this.type,
    required this.status,
    required this.notes,
    required this.therapistName,
  });
}

enum AppointmentType {
  therapy,
  consultation,
  followUp,
  assessment,
}

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  noShow,
}

// Ödev paneli: State dışına taşındı
class _HomeworkPanel extends StatelessWidget {
  const _HomeworkPanel({super.key});
  static final ValueNotifier<String?> _filterNotifier = ValueNotifier<String?>(null); // null: Tümü, 'done', 'todo'
  @override
  Widget build(BuildContext context) {
    final svc = context.watch<HomeworkService>();
    final items = svc.assignments;
    final now = DateTime.now();
    final todayCount = items.where((a)=> a.dueDate!=null && a.dueDate!.year==now.year && a.dueDate!.month==now.month && a.dueDate!.day==now.day && !a.isCompleted).length;
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekCount = items.where((a){
      if (a.dueDate==null || a.isCompleted) return false;
      return !a.dueDate!.isBefore(weekStart) && !a.dueDate!.isAfter(weekEnd);
    }).length;
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: const [Icon(Icons.task_alt_outlined), SizedBox(width: 8), Text('Ödev bulunmuyor')]),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.list_alt), 
            const SizedBox(width: 8), 
            Expanded(child: Text('Ödevlerim (${items.where((x)=> !x.isCompleted).length}/${items.length})')), 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.today, size: 12, color: Colors.orange), 
                const SizedBox(width: 2), 
                Text('${todayCount}', style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ]),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.date_range, size: 12, color: Colors.blue), 
                const SizedBox(width: 2), 
                Text('${weekCount}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _filterNotifier,
                  builder: (context, value, _) => DropdownButton<String?>(
                    value: value,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tümü')),
                      DropdownMenuItem(value: 'todo', child: Text('Bekleyen')),
                      DropdownMenuItem(value: 'done', child: Text('Tamamlanan')),
                    ],
                    onChanged: (v)=> _filterNotifier.value = v,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: (){ context.read<HomeworkService>().completeAll(); }, 
                icon: const Icon(Icons.done_all, size: 16), 
                label: const Text('Hepsini Tamamla', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.where((a){
            final f = _filterNotifier.value;
            if (f == 'todo') return !a.isCompleted;
            if (f == 'done') return a.isCompleted;
            return true;
          }).map((a)=> ListTile(
            leading: Icon(a.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: a.isCompleted ? Colors.green : Colors.grey),
            title: Text(a.title),
            subtitle: Text('${a.customInstructions?.isEmpty == true ? '—' : a.customInstructions ?? '—'}${a.dueDate != null ? ' • Son: ' + DateFormat('dd.MM').format(a.dueDate) : ''}'),
            trailing: TextButton(
              onPressed: ()=> context.read<HomeworkService>().toggleCompleted(a.id),
              child: Text(a.isCompleted ? 'Geri Al' : 'Tamamla'),
            ),
            tileColor: (!a.isCompleted && a.dueDate != null && a.dueDate!.isBefore(DateTime.now())) ? Colors.red.withOpacity(0.06) : null,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: (!a.isCompleted && a.dueDate != null && a.dueDate!.isBefore(DateTime.now())) ? Colors.redAccent : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          )),
        ]),
      ),
    );
  }
}
// Form widget: State dışına taşındı
class _AddAppointmentForm extends StatefulWidget {
  final void Function(String patientId, DateTime date, int duration, AppointmentType type, String? notes) onSaved;
  const _AddAppointmentForm({required this.onSaved});
  @override
  State<_AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<_AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  String? _patientId;
  DateTime _date = DateTime.now();
  int _duration = 45;
  AppointmentType _type = AppointmentType.therapy;
  final TextEditingController _notes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final patients = context.read<PatientService>().patients;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _patientId,
            decoration: const InputDecoration(labelText: 'Hasta'),
            items: patients.map((p)=> DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
            validator: (v)=> v==null? 'Hasta seçin' : null,
            onChanged: (v)=> setState(()=> _patientId = v),
          ),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Tarih/Saat', border: OutlineInputBorder()),
            child: Row(
              children: [
                Expanded(child: Text(DateFormat('dd.MM.yyyy HH:mm').format(_date))),
                TextButton(onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d!=null){
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
                    if(t!=null){ setState(()=> _date = DateTime(d.year, d.month, d.day, t.hour, t.minute)); }
                  }
                }, child: const Text('Seç')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Expanded(child: DropdownButtonFormField<AppointmentType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tür'),
                items: const [
                  DropdownMenuItem(value: AppointmentType.therapy, child: Text('Terapi')),
                  DropdownMenuItem(value: AppointmentType.consultation, child: Text('Konsültasyon')),
                  DropdownMenuItem(value: AppointmentType.followUp, child: Text('Takip')),
                  DropdownMenuItem(value: AppointmentType.assessment, child: Text('Değerlendirme')),
                ],
                onChanged: (v)=> setState(()=> _type = v ?? AppointmentType.therapy),
              )),
              Expanded(child: DropdownButtonFormField<int>(
                value: _duration,
                decoration: const InputDecoration(labelText: 'Süre (dk)'),
              items: const [30,45,60,90].map((m)=> DropdownMenuItem(value: m, child: Text('$m'))).toList(),
              onChanged: (v)=> setState(()=> _duration = v ?? 45),
            )),
          ]),
          const SizedBox(height: 8),
          TextFormField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notlar (opsiyonel)')),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: (){
                if(_formKey.currentState!.validate()){
                  widget.onSaved(_patientId!, _date, _duration, _type, _notes.text.trim().isEmpty? null : _notes.text.trim());
                }
              },
              child: const Text('Kaydet'),
            ),
          )
        ],
      ),
    );
  }
}
