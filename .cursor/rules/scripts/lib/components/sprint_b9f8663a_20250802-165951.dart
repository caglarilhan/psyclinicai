import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SessionScreen extends StatefulWidget {
  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _patientController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double _noShowProbability = 0.3; // placeholder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PsyClinic AI - Seans Ekranı'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Selection
            Text(
              'Danışan Seçimi',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _patientController,
              decoration: InputDecoration(
                labelText: 'Danışan Adı',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            SizedBox(height: 24),
            
            // Date and Time Selection
            Text(
              'Randevu Tarihi ve Saati',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null 
                      ? 'Tarih Seç' 
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _selectedTime = time);
                      }
                    },
                    icon: Icon(Icons.access_time),
                    label: Text(_selectedTime == null 
                      ? 'Saat Seç' 
                      : _selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // No-Show Prediction
            Text(
              'No-Show Tahmini: ${(_noShowProbability * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: _noShowProbability,
              onChanged: (value) => setState(() => _noShowProbability = value),
              min: 0.0,
              max: 1.0,
              divisions: 10,
            ),
            SizedBox(height: 24),
            
            // Session Notes
            Text(
              'Seans Notları',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Seans notlarını buraya yazın...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSession,
                    child: Text('Seansı Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateSummary,
                    child: Text('AI Özet Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSession() async {
    if (_patientController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    try {
      final sessionData = {
        'patientName': _patientController.text,
        'date': _selectedDate!.toIso8601String(),
        'time': '${_selectedTime!.hour}:${_selectedTime!.minute}',
        'notes': _noteController.text,
        'noShowProbability': _noShowProbability,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('sessions').add(sessionData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seans başarıyla kaydedildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> _generateSummary() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Önce seans notları girin')),
      );
      return;
    }

    // TODO: AI summary generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI özet oluşturuluyor...')),
    );
  }
}

class AppointmentCalendar extends StatefulWidget {
  @override
  _AppointmentCalendarState createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends State<AppointmentCalendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Randevu Takvimi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sessions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(session['patientName'] ?? 'Bilinmeyen'),
                  subtitle: Text('${session['date']} - ${session['time']}'),
                  trailing: Text('${(session['noShowProbability'] * 100).toStringAsFixed(1)}%'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
