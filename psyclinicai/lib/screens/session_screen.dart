import 'package:flutter/material.dart';
import '../design_system.dart';
import '../services/ai_summary_service.dart';

class SessionScreen extends StatefulWidget {
  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  String? _selectedPatientId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isGeneratingSummary = false;
  
  List<Map<String, dynamic>> _patients = [];
  String? _aiSummary;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AISummaryService.saveSession(
        patientId: _selectedPatientId!,
        therapistId: 'current_user_id', // TODO: Get from auth
        notes: _notesController.text,
        date: _selectedDate!,
        time: _selectedTime!,
        aiSummary: _aiSummary,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seans başarıyla kaydedildi')),
      );

      // Form'u temizle
      _formKey.currentState!.reset();
      _notesController.clear();
      setState(() {
        _selectedPatientId = null;
        _selectedDate = null;
        _selectedTime = null;
        _aiSummary = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seans kaydedilemedi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAISummary() async {
    if (_notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Önce seans notu girin')),
      );
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      final patientName = _patients.firstWhere(
        (p) => p['id'] == _selectedPatientId,
        orElse: () => {'name': 'Bilinmeyen'},
      )['name'];

      final summary = await AISummaryService.generateSummary(
        _notesController.text,
        patientName,
        'Dr. Terapist', // TODO: Get from auth
      );

      setState(() {
        _aiSummary = summary;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI özeti oluşturuldu')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI özeti oluşturulamadı: $e')),
      );
    } finally {
      setState(() {
        _isGeneratingSummary = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seans Ekranı'),
        actions: [
          IconButton(
            icon: Icon(Icons.summarize),
            onPressed: _isGeneratingSummary ? null : _generateAISummary,
            tooltip: 'AI Özeti Oluştur',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Danışan Seçimi
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danışan Seçimi',
                        style: AppTextStyles.title,
                      ),
                      SizedBox(height: AppSizes.paddingSmall),
                      DropdownButtonFormField<String>(
                        value: _selectedPatientId,
                        decoration: InputDecoration(
                          labelText: 'Danışan',
                          border: OutlineInputBorder(),
                        ),
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
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Tarih ve Saat Seçimi
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarih ve Saat',
                        style: AppTextStyles.title,
                      ),
                      SizedBox(height: AppSizes.paddingSmall),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text(_selectedDate == null 
                                ? 'Tarih Seç' 
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                              onTap: _selectDate,
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              leading: Icon(Icons.access_time),
                              title: Text(_selectedTime == null 
                                ? 'Saat Seç' 
                                : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
                              onTap: _selectTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // Seans Notu
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seans Notu',
                        style: AppTextStyles.title,
                      ),
                      SizedBox(height: AppSizes.paddingSmall),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Seans notlarınızı buraya yazın...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen seans notu girin';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSizes.paddingMedium),
              
              // AI Özeti
              if (_aiSummary != null) ...[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Özeti',
                          style: AppTextStyles.title,
                        ),
                        SizedBox(height: AppSizes.paddingSmall),
                        Container(
                          padding: EdgeInsets.all(AppSizes.paddingSmall),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(_aiSummary!),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.paddingMedium),
              ],
              
              // Kaydet Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSession,
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Seansı Kaydet'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
