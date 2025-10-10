import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import '../../services/client_service.dart';
import '../../models/client_model.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment;
  final DateTime? selectedDate;

  const AppointmentFormScreen({super.key, this.appointment, this.selectedDate});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  Client? _selectedClient;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String _selectedType = 'Bireysel Terapi';
  String _selectedStatus = 'Scheduled';
  bool _isLoading = false;

  final AppointmentService _appointmentService = AppointmentService();
  final ClientService _clientService = ClientService();
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
    if (widget.appointment != null) {
      _fillFormWithAppointmentData(widget.appointment!);
    } else if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      await _clientService.initialize();
      final clients = _clientService.getActiveClients();
      setState(() {
        _clients = clients;
      });
    } catch (e) {
      print('Error loading clients: $e');
    }
  }

  void _fillFormWithAppointmentData(Appointment appointment) {
    _selectedClient = _clients.firstWhere(
      (client) => client.id == appointment.clientId,
      orElse: () => Client(
        id: appointment.clientId,
        firstName: appointment.clientName.split(' ').first,
        lastName: appointment.clientName.split(' ').last,
        email: '',
        phone: '',
        dateOfBirth: DateTime.now(),
        gender: '',
        address: '',
        emergencyContact: '',
        emergencyPhone: '',
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    _selectedDate = appointment.startTime;
    _selectedStartTime = TimeOfDay.fromDateTime(appointment.startTime);
    _selectedEndTime = TimeOfDay.fromDateTime(appointment.endTime);
    _selectedType = appointment.type;
    _selectedStatus = appointment.status;
    _notesController.text = appointment.notes;
    _locationController.text = appointment.location;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
        // Auto-set end time to 1 hour later
        _selectedEndTime = TimeOfDay(
          hour: (picked.hour + 1) % 24,
          minute: picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasta seçilmelidir'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarih ve saat bilgileri eksik'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );
      
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      final appointment = Appointment(
        id: widget.appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.fullName,
        startTime: startDateTime,
        endTime: endDateTime,
        type: _selectedType,
        status: _selectedStatus,
        notes: _notesController.text.trim(),
        location: _locationController.text.trim(),
        createdAt: widget.appointment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.appointment != null) {
        success = await _appointmentService.updateAppointment(appointment);
      } else {
        success = await _appointmentService.addAppointment(appointment);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.appointment != null 
                  ? 'Randevu başarıyla güncellendi' 
                  : 'Randevu başarıyla oluşturuldu'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Randevu kaydedilemedi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment != null ? 'Randevu Düzenle' : 'Yeni Randevu'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveAppointment,
              child: const Text(
                'Kaydet',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hasta Seçimi
              _buildSectionHeader('Hasta Bilgileri'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<Client>(
                value: _selectedClient,
                decoration: const InputDecoration(
                  labelText: 'Hasta *',
                  border: OutlineInputBorder(),
                ),
                items: _clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(client.fullName),
                  );
                }).toList(),
                onChanged: (client) {
                  setState(() {
                    _selectedClient = client;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Hasta seçilmelidir';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Tarih ve Saat
              _buildSectionHeader('Tarih ve Saat'),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Tarih seçin',
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Başlangıç Saati *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedStartTime != null
                              ? _selectedStartTime!.format(context)
                              : 'Saat seçin',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Bitiş Saati *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedEndTime != null
                              ? _selectedEndTime!.format(context)
                              : 'Saat seçin',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Randevu Detayları
              _buildSectionHeader('Randevu Detayları'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Randevu Türü *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Bireysel Terapi', child: Text('Bireysel Terapi')),
                  DropdownMenuItem(value: 'Grup Terapisi', child: Text('Grup Terapisi')),
                  DropdownMenuItem(value: 'Aile Terapisi', child: Text('Aile Terapisi')),
                  DropdownMenuItem(value: 'Konsültasyon', child: Text('Konsültasyon')),
                  DropdownMenuItem(value: 'Takip', child: Text('Takip')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Durum *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Scheduled', child: Text('Planlandı')),
                  DropdownMenuItem(value: 'Confirmed', child: Text('Onaylandı')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('İptal Edildi')),
                  DropdownMenuItem(value: 'Completed', child: Text('Tamamlandı')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Konum',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Kaydet Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.appointment != null ? 'Güncelle' : 'Kaydet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }
}
