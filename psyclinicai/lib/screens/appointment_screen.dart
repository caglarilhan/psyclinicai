import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../design_system.dart';
import '../services/ai_summary_service.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  String? _selectedPatientId;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _appointments = [];
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadAppointments();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await AISummaryService.getPatients();
      setState(() {
        _patients = patients;
      });
    } catch (e) {
      print('Hasta listesi yüklenemedi: $e');
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await AISummaryService.getAppointments();
      setState(() {
        _appointments = appointments;
        _events = _groupAppointments(appointments);
      });
    } catch (e) {
      print('Randevu listesi yüklenemedi: $e');
    }
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupAppointments(List<Map<String, dynamic>> appointments) {
    final events = <DateTime, List<Map<String, dynamic>>>{};
    
    for (final appointment in appointments) {
      final date = DateTime(
        appointment['start'].year,
        appointment['start'].month,
        appointment['start'].day,
      );
      
      if (events[date] == null) events[date] = [];
      events[date]!.add(appointment);
    }
    
    return events;
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null || _selectedDay == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startTime = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      final endTime = startTime.add(Duration(minutes: 50)); // 50 dakikalık seans
      
      await AISummaryService.saveAppointment(
        patientId: _selectedPatientId!,
        therapistId: 'current_user_id', // TODO: Get from auth
        start: startTime,
        end: endTime,
        noShowProbability: _calculateNoShowProbability(_selectedPatientId!),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Randevu başarıyla oluşturuldu')),
      );

      // Form'u temizle ve listeyi yenile
      _formKey.currentState!.reset();
      setState(() {
        _selectedPatientId = null;
        _selectedDay = null;
        _selectedTime = null;
      });
      
      await _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Randevu oluşturulamadı: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateNoShowProbability(String patientId) {
    // Placeholder no-show tahmini
    // Gerçek uygulamada hasta geçmişi, yaş, cinsiyet, önceki no-show'lar vb. kullanılacak
    return 0.15; // %15 no-show olasılığı
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Randevu Takvimi'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddAppointmentDialog(),
            tooltip: 'Yeni Randevu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Takvim
          Card(
            margin: EdgeInsets.all(AppSizes.paddingMedium),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          // Seçili günün randevuları
          if (_selectedDay != null) ...[
            Expanded(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      child: Text(
                        '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} Randevuları',
                        style: AppTextStyles.title,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _getEventsForDay(_selectedDay!).length,
                        itemBuilder: (context, index) {
                          final appointment = _getEventsForDay(_selectedDay!)[index];
                          final patient = _patients.firstWhere(
                            (p) => p['id'] == appointment['patient_id'],
                            orElse: () => {'name': 'Bilinmeyen'},
                          );
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                patient['name'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(patient['name']),
                            subtitle: Text(
                              '${appointment['start'].hour}:${appointment['start'].minute.toString().padLeft(2, '0')} - '
                              '${appointment['end'].hour}:${appointment['end'].minute.toString().padLeft(2, '0')}',
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: appointment['no_show_prediction'] > 0.3 
                                  ? Colors.orange 
                                  : Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(appointment['no_show_prediction'] * 100).toInt()}% no-show',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Randevu'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Danışan Seçimi
              DropdownButtonFormField<String>(
                value: _selectedPatientId,
                decoration: InputDecoration(labelText: 'Danışan'),
                items: _patients.map((patient) {
                  return DropdownMenuItem<String>(
                    value: patient['id'] as String,
                    child: Text('${patient['name']} (${patient['age']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPatientId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Lütfen danışan seçin';
                  return null;
                },
              ),
              
              SizedBox(height: AppSizes.paddingSmall),
              
              // Tarih Seçimi
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(_selectedDay == null 
                  ? 'Tarih Seç' 
                  : '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDay ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDay = picked;
                    });
                  }
                },
              ),
              
              // Saat Seçimi
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text(_selectedTime == null 
                  ? 'Saat Seç' 
                  : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
                onTap: _selectTime,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () async {
              await _saveAppointment();
              Navigator.of(context).pop();
            },
            child: _isLoading 
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
