import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/theme.dart';
import '../../widgets/common/loading_widget.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() => _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Demo appointments
  final Map<DateTime, List<String>> _appointments = {};
  
  @override
  void initState() {
    super.initState();
    _initializeDemoAppointments();
  }

  void _initializeDemoAppointments() {
    final today = DateTime.now();
    _appointments[today] = ['09:00 - Dr. Ahmet ile Seans', '14:00 - Grup Terapisi'];
    _selectedDay = today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Takvimi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay =DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Randevu Takvimi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                      ),
                      Row(
                        children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                        });
                      },
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          // Calendar view
          Expanded(
            child: Column(
              children: [
                TableCalendar<String>(
                  firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                    defaultTextStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    weekendTextStyle: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                    ),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    formatButtonTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    titleTextStyle: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  selectedDayPredictTimeBuilder: (context, day) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                  const SizedBox(height: 16),
                // Selected day appointments
                if (_selectedDay != null) ...[
                  Expanded(
                    child: _buildAppointmentsList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final dayKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final appointments = _appointments[dayKey] ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} Randevuları',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Bu tarihte randevu yok',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
              ),
            )
          else
          Expanded(
            child: ListView.builder(
                itemCount: appointments.length,
              itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.event,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(appointments[index]),
                      subtitle: Text('Detaylar için tıklayın'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeAppointment(appointments[index]),
                      ),
                    ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _appointments[dayKey] ?? [];
  }

  void _showAddAppointmentDialog() {
    final timeController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Randevu Ekle'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            TextField(
              controller: timeController,
                decoration: const InputDecoration(
                labelText: 'Saat',
                hintText: 'örn: 14:00',
              ),
              ),
              const SizedBox(height: 16),
            TextField(
              controller: notesController,
                decoration: const InputDecoration(
                labelText: 'Notlar',
                hintText: 'Randevu detayları...',
              ),
              maxLines: 3,
            ),
          ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
            onPressed: () {
              if (timeController.text.isNotEmpty && notesController.text.isNotEmpty) {
                _addAppointment(timeController.text, notesController.text);
          Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('Ekle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addAppointment(String time, String notes) {
    if (_selectedDay != null) {
      final dayKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      final appointment = '$time - $notes';
      
      setState(() {
        _appointments[dayKey] = [...(_appointments[dayKey] ?? []), appointment];
      });
      
                ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Randevu eklendi: $appointment'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _removeAppointment(String appointment) {
    final dayKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    
    setState(() {
      _appointments[dayKey]?.remove(appointment);
      if (_appointments[dayKey]?.isEmpty == true) {
        _appointments.remove(dayKey);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Randevu silindi'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}