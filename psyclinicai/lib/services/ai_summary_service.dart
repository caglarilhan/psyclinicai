import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AISummaryService {
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';
  static const String _model = 'mistral:latest';

  /// AI özeti oluşturur
  static Future<String> generateSummary(String notes, String patient, String therapist) async {
    try {
      final prompt = '''You are a clinical AI assistant analyzing therapy session notes. Please provide a structured summary with the following fields:

1. **Affect**: Describe the patient's emotional state and mood during the session
2. **Theme**: Identify the main themes, topics, or issues discussed
3. **ICD Suggestion**: Suggest relevant ICD-10 codes based on the session content

Format your response as:
- Affect: [description]
- Theme: [description] 
- ICD Suggestion: [code] - [description]

Session notes:
"""$notes"""''';

      final response = await http.post(
        Uri.parse(_ollamaUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Özet oluşturulamadı';
      } else {
        throw Exception('AI özeti alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('AI özeti oluşturma hatası: $e');
      return 'AI özeti oluşturulamadı: $e';
    }
  }

  /// Seans verilerini Firestore'a kaydeder
  static Future<void> saveSession({
    required String patientId,
    required String therapistId,
    required String notes,
    required DateTime date,
    required TimeOfDay time,
    String? aiSummary,
  }) async {
    try {
      final sessionData = {
        'patient_id': patientId,
        'therapist_id': therapistId,
        'date': date.toIso8601String(),
        'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        'notes': notes,
        'ai_summary': aiSummary,
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('sessions')
          .add(sessionData);
    } catch (e) {
      print('Seans kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Randevu verilerini Firestore'a kaydeder
  static Future<void> saveAppointment({
    required String patientId,
    required String therapistId,
    required DateTime start,
    required DateTime end,
    double noShowProbability = 0.15,
  }) async {
    try {
      final appointmentData = {
        'patient_id': patientId,
        'therapist_id': therapistId,
        'start': Timestamp.fromDate(start),
        'end': Timestamp.fromDate(end),
        'no_show_prediction': noShowProbability,
        'status': 'scheduled',
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);
    } catch (e) {
      print('Randevu kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Hasta listesini getirir
  static Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .limit(10)
          .get();
      
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] ?? 'İsimsiz',
                'age': doc.data()['age'] ?? '',
              })
          .toList();
    } catch (e) {
      print('Hasta listesi getirme hatası: $e');
      return [];
    }
  }

  /// Randevu listesini getirir
  static Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(Duration(days: 30))))
          .get();
      
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
                'start': (doc.data()['start'] as Timestamp).toDate(),
                'end': (doc.data()['end'] as Timestamp).toDate(),
              })
          .toList();
    } catch (e) {
      print('Randevu listesi getirme hatası: $e');
      return [];
    }
  }
}
