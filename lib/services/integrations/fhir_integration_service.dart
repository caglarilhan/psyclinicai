import 'package:flutter/foundation.dart';

class FHIRIntegrationService extends ChangeNotifier {
  static final FHIRIntegrationService _instance = FHIRIntegrationService._internal();
  factory FHIRIntegrationService() => _instance;
  FHIRIntegrationService._internal();

  Future<void> initialize() async {
    // TODO: Configure SMART on FHIR / OAuth2
  }

  // Mock calls
  Future<Map<String, dynamic>> fetchPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'resourceType': 'Patient', 'id': patientId, 'name': 'John Doe'};
  }

  Future<List<Map<String, dynamic>>> fetchObservations(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      {'resourceType': 'Observation', 'code': 'PHQ9', 'value': 14},
      {'resourceType': 'Observation', 'code': 'GAD7', 'value': 12},
    ];
  }
}


