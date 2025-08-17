import 'package:flutter/material.dart';
import '../../models/ai_appointment_models.dart';
import '../../services/ai_appointment_service.dart';
import '../../widgets/ai_appointment/ai_appointment_dashboard_widget.dart';
import '../../utils/theme.dart';

class AIAppointmentScreen extends StatefulWidget {
  const AIAppointmentScreen({super.key});

  @override
  State<AIAppointmentScreen> createState() => _AIAppointmentScreenState();
}

class _AIAppointmentScreenState extends State<AIAppointmentScreen> {
  final AIAppointmentService _aiService = AIAppointmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Randevu Sistemi'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: const AIAppointmentDashboardWidget(
        therapistId: 'therapist1', // TODO: Gerçek therapist ID
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActionsDialog(context);
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Hızlı İşlemler'),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Randevu Ayarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Tahmin Hassasiyeti'),
            Slider(
              value: 0.8,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '80%',
              onChanged: null,
            ),
            SizedBox(height: 16),
            Text('Otomatik Hatırlatıcılar'),
            SwitchListTile(
              title: Text('SMS Hatırlatıcıları'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('E-posta Hatırlatıcıları'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Push Bildirimleri'),
              value: false,
              onChanged: null,
            ),
            SizedBox(height: 16),
            Text('AI Öğrenme'),
            SwitchListTile(
              title: Text('Otomatik Model Güncelleme'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Kullanıcı Davranış Analizi'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar kaydedildi')),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hızlı İşlemler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.psychology, color: Colors.blue),
              title: const Text('AI Tahmin Oluştur'),
              subtitle: const Text('Yeni randevu için AI tahmini'),
              onTap: () {
                Navigator.of(context).pop();
                _createAIPrediction();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Hatırlatıcı Ekle'),
              subtitle: const Text('AI optimize edilmiş hatırlatıcı'),
              onTap: () {
                Navigator.of(context).pop();
                _createAIReminder();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb, color: Colors.green),
              title: const Text('Akıllı Öneri'),
              subtitle: const Text('Optimal randevu zamanı önerisi'),
              onTap: () {
                Navigator.of(context).pop();
                _createSmartSuggestion();
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.purple),
              title: const Text('Kurum Mesajı'),
              subtitle: const Text('AI destekli mesaj gönder'),
              onTap: () {
                Navigator.of(context).pop();
                _sendInstitutionalMessage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.red),
              title: const Text('Analitik Rapor'),
              subtitle: const Text('AI destekli performans analizi'),
              onTap: () {
                Navigator.of(context).pop();
                _generateAnalyticsReport();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAIPrediction() async {
    try {
      final prediction = await _aiService.predictAppointmentOutcome(
        appointmentId: 'apt_${DateTime.now().millisecondsSinceEpoch}',
        clientId: 'client1',
        therapistId: 'therapist1',
        clientHistory: {
          'noShowRate': 0.25,
          'previousNoShows': 2,
          'lastMinuteCancellations': 1,
          'averageDelay': 15,
        },
        appointmentData: {
          'type': 'therapy',
          'duration': 60,
          'time': '10:00',
          'day': 'monday',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI tahmin oluşturuldu: ${prediction.prediction}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tahmin oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAIReminder() async {
    try {
      final reminder = await _aiService.createAIOptimizedReminder(
        appointmentId: 'apt_${DateTime.now().millisecondsSinceEpoch}',
        clientId: 'client1',
        therapistId: 'therapist1',
        type: ReminderType.appointmentReminder,
        appointmentTime: DateTime.now().add(const Duration(days: 1)),
        clientPreferences: {
          'name': 'Ahmet Yılmaz',
          'preferredAdvanceNotice': 24,
          'timezone': 'Europe/Istanbul',
          'workingHours': {'start': 9, 'end': 18},
          'preferredChannels': ['sms', 'email'],
          'responseRates': {'sms': 0.9, 'email': 0.7},
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI hatırlatıcı oluşturuldu: ${reminder.message}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hatırlatıcı oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSmartSuggestion() async {
    try {
      final suggestion = await _aiService.generateSmartSuggestion(
        clientId: 'client1',
        therapistId: 'therapist1',
        clientPreferences: {
          'name': 'Fatma Demir',
          'preferredTime': '14:00',
          'preferredDay': 'wednesday',
          'timezone': 'Europe/Istanbul',
          'hasPreference': true,
          'priority': 'normal',
        },
        therapistAvailability: {
          'availableSlots': [
            DateTime.now().add(const Duration(days: 1)),
            DateTime.now().add(const Duration(days: 2)),
            DateTime.now().add(const Duration(days: 3)),
          ],
        },
        constraints: {
          'urgency': 'normal',
          'isFollowUp': false,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akıllı öneri oluşturuldu: ${_formatDateTime(suggestion.suggestedTime)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öneri oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendInstitutionalMessage() async {
    try {
      final message = await _aiService.sendMessage(
        senderId: 'therapist1',
        senderName: 'Dr. Ayşe Demir',
        senderRole: 'therapist',
        recipientIds: ['therapist2', 'therapist3'],
        recipientNames: ['Dr. Mehmet Kaya', 'Dr. Fatma Öz'],
        type: MessageType.announcement,
        subject: 'AI Randevu Sistemi Test Sonuçları',
        content: 'Yeni AI özellikleri başarıyla test edildi. No-show tahminleri %85 doğruluk oranına ulaştı. Hatırlatıcı sistemi %30 daha etkili hale geldi.',
        priority: MessagePriority.high,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kurum mesajı gönderildi: ${message.subject}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesaj gönderilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateAnalyticsReport() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 1, 1);
      final endDate = DateTime(now.year, now.month, 0);

      final analytics = await _aiService.generateAnalytics(
        therapistId: 'therapist1',
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI Analitik Raporu'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dönem: ${_formatDate(startDate)} - ${_formatDate(endDate)}'),
                  const SizedBox(height: 16),
                  Text('Toplam Randevu: ${analytics.totalAppointments}'),
                  Text('Tamamlanan: ${analytics.completedAppointments}'),
                  Text('İptal Edilen: ${analytics.cancelledAppointments}'),
                  Text('No-Show: ${analytics.noShowAppointments}'),
                  Text('Tamamlanma Oranı: %${analytics.completionRate.toStringAsFixed(1)}'),
                  const SizedBox(height: 16),
                  const Text('AI Öngörüler:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...analytics.insights.take(3).map((insight) => 
                    Text('• ${insight.title}')
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rapor kaydedildi')),
                  );
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapor oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
