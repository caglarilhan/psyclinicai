import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/theme.dart';
import '../../models/appointment_models.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appointment/appointment_card_widget.dart';
import '../../widgets/appointment/ai_scheduler_widget.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() => _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  bool _isLoading = true;
  List<Appointment> _appointments = [];
  Map<DateTime, List<Appointment>> _events = {};
  
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getAppointments();
      _appointments = appointments;
      _events = _groupAppointments(appointments);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Randevular yüklenirken hata: $e')),
        );
      }
    }
  }

  Map<DateTime, List<Appointment>> _groupAppointments(List<Appointment> appointments) {
    final events = <DateTime, List<Appointment>>{};
    
    for (final appointment in appointments) {
      final date = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );
      
      if (events[date] == null) events[date] = [];
      events[date]!.add(appointment);
    }
    
    return events;
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  List<Appointment> _getEventsForRange(DateTime start, DateTime end) {
    final events = <Appointment>[];
    
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i));
      events.addAll(_getEventsForDay(date));
    }
    
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Destekli Randevu Takvimi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAppointmentDialog,
            tooltip: 'Yeni Randevu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // AI Scheduler Widget
                Container(
                  margin: const EdgeInsets.all(16),
                  child: const AISchedulerWidget(),
                ),
                
                // Takvim
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TableCalendar<Appointment>(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _getEventsForDay,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      holidayTextStyle: const TextStyle(color: Colors.red),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                      rangeHighlightColor: AppTheme.primaryColor.withOpacity(0.3),
                      rangeStartDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Seçili gün randevuları
                Expanded(
                  child: _buildSelectedDayEvents(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Randevu'),
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    if (_selectedDay == null) {
      return _buildNoSelectionMessage();
    }

    final events = _getEventsForDay(_selectedDay!);
    
    if (events.isEmpty) {
      return _buildNoEventsMessage();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${events.length} randevu bulundu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final appointment = events[index];
                return AppointmentCardWidget(
                  appointment: appointment,
                  onTap: () => _showAppointmentDetails(appointment),
                  onEdit: () => _showEditAppointmentDialog(appointment),
                  onDelete: () => _showDeleteAppointmentDialog(appointment),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Takvimden bir gün seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Randevuları görüntülemek için bir tarih seçin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bu günde randevu yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni randevu eklemek için + butonuna tıklayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddAppointmentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Randevu Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddAppointmentDialog(),
    ).then((_) => _loadAppointments());
  }

  void _showEditAppointmentDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => EditAppointmentDialog(appointment: appointment),
    ).then((_) => _loadAppointments());
  }

  void _showDeleteAppointmentDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => DeleteAppointmentDialog(appointment: appointment),
    ).then((_) => _loadAppointments());
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDetailsDialog(appointment: appointment),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }
}

// Yeni randevu ekleme dialog'u
class AddAppointmentDialog extends StatefulWidget {
  const AddAppointmentDialog({super.key});

  @override
  State<AddAppointmentDialog> createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<AddAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  AppointmentType _selectedType = AppointmentType.individual;
  AppointmentStatus _selectedStatus = AppointmentStatus.scheduled;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Randevu'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Randevu Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Danışan Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Danışan adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Tarih'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Saat'),
                      subtitle: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppointmentType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Randevu Türü',
                  border: OutlineInputBorder(),
                ),
                items: AppointmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAppointmentTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppointmentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Durum',
                  border: OutlineInputBorder(),
                ),
                items: AppointmentStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getAppointmentStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        clientName: _clientNameController.text,
        dateTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        type: _selectedType,
        status: _selectedStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await AppointmentService().addAppointment(appointment);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Randevu başarıyla eklendi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Randevu eklenirken hata: $e')),
          );
        }
      }
    }
  }

  String _getAppointmentTypeText(AppointmentType type) {
    switch (type) {
      case AppointmentType.individual:
        return 'Bireysel';
      case AppointmentType.group:
        return 'Grup';
      case AppointmentType.emergency:
        return 'Acil';
      case AppointmentType.followUp:
        return 'Takip';
    }
  }

  String _getAppointmentStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Planlandı';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
      case AppointmentStatus.noShow:
        return 'Gelmedi';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }
}

// Randevu düzenleme dialog'u
class EditAppointmentDialog extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentDialog({
    super.key,
    required this.appointment,
  });

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _clientNameController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late AppointmentType _selectedType;
  late AppointmentStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.appointment.title);
    _descriptionController = TextEditingController(text: widget.appointment.description);
    _clientNameController = TextEditingController(text: widget.appointment.clientName);
    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);
    _selectedType = widget.appointment.type;
    _selectedStatus = widget.appointment.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Randevu Düzenle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Randevu Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Danışan Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Danışan adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Tarih'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Saat'),
                      subtitle: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppointmentType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Randevu Türü',
                  border: OutlineInputBorder(),
                ),
                items: AppointmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAppointmentTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppointmentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Durum',
                  border: OutlineInputBorder(),
                ),
                items: AppointmentStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getAppointmentStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _updateAppointment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Güncelle'),
        ),
      ],
    );
  }

  void _updateAppointment() async {
    if (_formKey.currentState!.validate()) {
      final updatedAppointment = widget.appointment.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        clientName: _clientNameController.text,
        dateTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        type: _selectedType,
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      try {
        await AppointmentService().updateAppointment(updatedAppointment);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Randevu başarıyla güncellendi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Randevu güncellenirken hata: $e')),
          );
        }
      }
    }
  }

  String _getAppointmentTypeText(AppointmentType type) {
    switch (type) {
      case AppointmentType.individual:
        return 'Bireysel';
      case AppointmentType.group:
        return 'Grup';
      case AppointmentType.emergency:
        return 'Acil';
      case AppointmentType.followUp:
        return 'Takip';
    }
  }

  String _getAppointmentStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Planlandı';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
      case AppointmentStatus.noShow:
        return 'Gelmedi';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }
}

// Randevu silme dialog'u
class DeleteAppointmentDialog extends StatelessWidget {
  final Appointment appointment;

  const DeleteAppointmentDialog({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Randevu Sil'),
      content: Text(
        '${appointment.title} randevusunu silmek istediğinizden emin misiniz?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await AppointmentService().deleteAppointment(appointment.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Randevu başarıyla silindi')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Randevu silinirken hata: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sil'),
        ),
      ],
    );
  }
}

// Randevu detayları dialog'u
class AppointmentDetailsDialog extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsDialog({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appointment.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Danışan', appointment.clientName),
            _buildDetailRow('Tarih', _formatDate(appointment.dateTime)),
            _buildDetailRow('Saat', _formatTime(appointment.dateTime)),
            _buildDetailRow('Tür', _getAppointmentTypeText(appointment.type)),
            _buildDetailRow('Durum', _getAppointmentStatusText(appointment.status)),
            if (appointment.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Açıklama:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(appointment.description),
            ],
            const SizedBox(height: 16),
            _buildDetailRow('Oluşturulma', _formatDateTime(appointment.createdAt)),
            _buildDetailRow('Güncellenme', _formatDateTime(appointment.updatedAt)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  String _getAppointmentTypeText(AppointmentType type) {
    switch (type) {
      case AppointmentType.individual:
        return 'Bireysel';
      case AppointmentType.group:
        return 'Grup';
      case AppointmentType.emergency:
        return 'Acil';
      case AppointmentType.followUp:
        return 'Takip';
    }
  }

  String _getAppointmentStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Planlandı';
      case AppointmentStatus.confirmed:
        return 'Onaylandı';
      case AppointmentStatus.completed:
        return 'Tamamlandı';
      case AppointmentStatus.cancelled:
        return 'İptal Edildi';
      case AppointmentStatus.noShow:
        return 'Gelmedi';
    }
  }
}
