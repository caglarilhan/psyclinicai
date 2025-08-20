import 'package:flutter/foundation.dart';

class MHRSSGKIntegrationService extends ChangeNotifier {
  static final MHRSSGKIntegrationService _instance = MHRSSGKIntegrationService._internal();
  factory MHRSSGKIntegrationService() => _instance;
  MHRSSGKIntegrationService._internal();

  Future<void> initialize() async {
    // TODO: gerçek API endpoint ve auth yapılandırması
  }

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      {'id': '1', 'patient': 'Ali Veli', 'date': '2025-08-20', 'status': 'confirmed'},
      {'id': '2', 'patient': 'Ayşe Yılmaz', 'date': '2025-08-21', 'status': 'scheduled'},
    ];
  }

  Future<Map<String, dynamic>> fetchInsuranceStatus(String tcKimlikNo) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'tc': tcKimlikNo, 'coverage': 'active', 'rate': 0.9};
  }
}


