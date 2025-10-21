import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vital_signs_models.dart';
import '../models/patient_models.dart';

class VitalSignsService {
  static final VitalSignsService _instance = VitalSignsService._internal();
  factory VitalSignsService() => _instance;
  VitalSignsService._internal();

  final List<VitalSigns> _vitalSignsRecords = [];
  final List<VitalSignsAlert> _alerts = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadVitalSignsRecords();
    await _loadAlerts();
  }

  // Load vital signs records from storage
  Future<void> _loadVitalSignsRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('vital_signs_records') ?? [];
      _vitalSignsRecords.clear();
      
      for (final recordJson in recordsJson) {
        final record = VitalSigns.fromJson(jsonDecode(recordJson));
        _vitalSignsRecords.add(record);
      }
    } catch (e) {
      print('Error loading vital signs records: $e');
      _vitalSignsRecords.clear();
    }
  }

  // Save vital signs records to storage
  Future<void> _saveVitalSignsRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = _vitalSignsRecords
          .map((record) => jsonEncode(record.toJson()))
          .toList();
      await prefs.setStringList('vital_signs_records', recordsJson);
    } catch (e) {
      print('Error saving vital signs records: $e');
    }
  }

  // Load alerts from storage
  Future<void> _loadAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('vital_signs_alerts') ?? [];
      _alerts.clear();
      
      for (final alertJson in alertsJson) {
        final alert = VitalSignsAlert.fromJson(jsonDecode(alertJson));
        _alerts.add(alert);
      }
    } catch (e) {
      print('Error loading alerts: $e');
      _alerts.clear();
    }
  }

  // Save alerts to storage
  Future<void> _saveAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = _alerts
          .map((alert) => jsonEncode(alert.toJson()))
          .toList();
      await prefs.setStringList('vital_signs_alerts', alertsJson);
    } catch (e) {
      print('Error saving alerts: $e');
    }
  }

  // Add new vital signs record
  Future<VitalSigns> addVitalSignsRecord({
    required String patientId,
    required String recordedBy,
    required VitalSignsData data,
    String? notes,
  }) async {
    final record = VitalSigns(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      recordedAt: DateTime.now(),
      recordedBy: recordedBy,
      data: data,
      notes: notes,
      status: _determineVitalSignsStatus(data),
    );

    _vitalSignsRecords.add(record);
    await _saveVitalSignsRecords();

    // Check for alerts
    await _checkForAlerts(record);

    return record;
  }

  // Determine vital signs status
  VitalSignsStatus _determineVitalSignsStatus(VitalSignsData data) {
    // Check for critical values
    if (data.systolicBP != null && data.systolicBP! > 180) {
      return VitalSignsStatus.critical;
    }
    if (data.diastolicBP != null && data.diastolicBP! > 120) {
      return VitalSignsStatus.critical;
    }
    if (data.heartRate != null && (data.heartRate! < 40 || data.heartRate! > 150)) {
      return VitalSignsStatus.critical;
    }
    if (data.temperature != null && data.temperature! > 39.0) {
      return VitalSignsStatus.critical;
    }
    if (data.oxygenSaturation != null && data.oxygenSaturation! < 90) {
      return VitalSignsStatus.critical;
    }

    // Check for abnormal values
    if (data.bloodPressureCategory != BloodPressureCategory.normal ||
        data.heartRateCategory != HeartRateCategory.normal ||
        data.temperatureCategory != TemperatureCategory.normal) {
      return VitalSignsStatus.abnormal;
    }

    return VitalSignsStatus.normal;
  }

  // Check for alerts and create them if needed
  Future<void> _checkForAlerts(VitalSigns record) async {
    final alerts = <VitalSignsAlert>[];

    // Blood pressure alerts
    if (record.data.bloodPressureCategory == BloodPressureCategory.hypertensiveCrisis) {
      alerts.add(VitalSignsAlert(
        id: '${record.id}_bp_crisis',
        patientId: record.patientId,
        vitalSignsId: record.id,
        type: AlertType.bloodPressureHigh,
        severity: AlertSeverity.critical,
        message: 'Hipertansif kriz: ${record.data.systolicBP}/${record.data.diastolicBP} mmHg',
        createdAt: DateTime.now(),
      ));
    }

    // Heart rate alerts
    if (record.data.heartRateCategory == HeartRateCategory.bradycardia ||
        record.data.heartRateCategory == HeartRateCategory.tachycardia) {
      alerts.add(VitalSignsAlert(
        id: '${record.id}_hr_abnormal',
        patientId: record.patientId,
        vitalSignsId: record.id,
        type: AlertType.heartRateAbnormal,
        severity: AlertSeverity.high,
        message: 'Anormal nabız: ${record.data.heartRate} bpm',
        createdAt: DateTime.now(),
      ));
    }

    // Temperature alerts
    if (record.data.temperatureCategory == TemperatureCategory.highFever) {
      alerts.add(VitalSignsAlert(
        id: '${record.id}_temp_high',
        patientId: record.patientId,
        vitalSignsId: record.id,
        type: AlertType.temperatureHigh,
        severity: AlertSeverity.high,
        message: 'Yüksek ateş: ${record.data.temperature}°C',
        createdAt: DateTime.now(),
      ));
    }

    // Oxygen saturation alerts
    if (record.data.oxygenSaturation != null && record.data.oxygenSaturation! < 95) {
      alerts.add(VitalSignsAlert(
        id: '${record.id}_spo2_low',
        patientId: record.patientId,
        vitalSignsId: record.id,
        type: AlertType.oxygenSaturationLow,
        severity: AlertSeverity.critical,
        message: 'Düşük oksijen saturasyonu: ${record.data.oxygenSaturation}%',
        createdAt: DateTime.now(),
      ));
    }

    // Pain level alerts
    if (record.data.painLevel != null && record.data.painLevel! >= 8) {
      alerts.add(VitalSignsAlert(
        id: '${record.id}_pain_high',
        patientId: record.patientId,
        vitalSignsId: record.id,
        type: AlertType.painLevelHigh,
        severity: AlertSeverity.high,
        message: 'Yüksek ağrı seviyesi: ${record.data.painLevel}/10',
        createdAt: DateTime.now(),
      ));
    }

    // Add alerts
    for (final alert in alerts) {
      _alerts.add(alert);
    }

    if (alerts.isNotEmpty) {
      await _saveAlerts();
    }
  }

  // Get vital signs records for a patient
  List<VitalSigns> getVitalSignsForPatient(String patientId) {
    return _vitalSignsRecords
        .where((record) => record.patientId == patientId)
        .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // Get latest vital signs for a patient
  VitalSigns? getLatestVitalSignsForPatient(String patientId) {
    final records = getVitalSignsForPatient(patientId);
    return records.isNotEmpty ? records.first : null;
  }

  // Get all alerts
  List<VitalSignsAlert> getAllAlerts() {
    return _alerts
        .where((alert) => !alert.isResolved)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get alerts for a patient
  List<VitalSignsAlert> getAlertsForPatient(String patientId) {
    return _alerts
        .where((alert) => alert.patientId == patientId && !alert.isResolved)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Resolve alert
  Future<bool> resolveAlert(String alertId, String resolvedBy) async {
    try {
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index == -1) return false;

      final alert = _alerts[index];
      final resolvedAlert = VitalSignsAlert(
        id: alert.id,
        patientId: alert.patientId,
        vitalSignsId: alert.vitalSignsId,
        type: alert.type,
        severity: alert.severity,
        message: alert.message,
        createdAt: alert.createdAt,
        isResolved: true,
        resolvedAt: DateTime.now(),
        resolvedBy: resolvedBy,
      );

      _alerts[index] = resolvedAlert;
      await _saveAlerts();
      return true;
    } catch (e) {
      print('Error resolving alert: $e');
      return false;
    }
  }

  // Get vital signs trends for a patient
  Map<String, List<double>> getVitalSignsTrends(String patientId, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final records = _vitalSignsRecords
        .where((record) => 
            record.patientId == patientId && 
            record.recordedAt.isAfter(cutoffDate))
        .toList()
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final trends = <String, List<double>>{
      'systolicBP': [],
      'diastolicBP': [],
      'heartRate': [],
      'temperature': [],
      'oxygenSaturation': [],
      'painLevel': [],
    };

    for (final record in records) {
      if (record.data.systolicBP != null) {
        trends['systolicBP']!.add(record.data.systolicBP!);
      }
      if (record.data.diastolicBP != null) {
        trends['diastolicBP']!.add(record.data.diastolicBP!);
      }
      if (record.data.heartRate != null) {
        trends['heartRate']!.add(record.data.heartRate!.toDouble());
      }
      if (record.data.temperature != null) {
        trends['temperature']!.add(record.data.temperature!);
      }
      if (record.data.oxygenSaturation != null) {
        trends['oxygenSaturation']!.add(record.data.oxygenSaturation!.toDouble());
      }
      if (record.data.painLevel != null) {
        trends['painLevel']!.add(record.data.painLevel!);
      }
    }

    return trends;
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_vitalSignsRecords.isNotEmpty) return;

    final demoRecords = [
      VitalSigns(
        id: 'vs_001',
        patientId: '1',
        recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
        recordedBy: 'nurse_001',
        data: const VitalSignsData(
          systolicBP: 120.0,
          diastolicBP: 80.0,
          heartRate: 72,
          temperature: 36.5,
          respiratoryRate: 16,
          oxygenSaturation: 98,
          weight: 70.0,
          height: 170.0,
          painLevel: 2.0,
        ),
        notes: 'Normal vital bulgular',
      ),
      VitalSigns(
        id: 'vs_002',
        patientId: '2',
        recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
        recordedBy: 'nurse_001',
        data: const VitalSignsData(
          systolicBP: 140.0,
          diastolicBP: 90.0,
          heartRate: 85,
          temperature: 37.8,
          respiratoryRate: 18,
          oxygenSaturation: 95,
          weight: 65.0,
          height: 165.0,
          painLevel: 6.0,
        ),
        notes: 'Hafif hipertansiyon ve ateş',
      ),
      VitalSigns(
        id: 'vs_003',
        patientId: '3',
        recordedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        recordedBy: 'nurse_002',
        data: const VitalSignsData(
          systolicBP: 160.0,
          diastolicBP: 100.0,
          heartRate: 95,
          temperature: 38.5,
          respiratoryRate: 20,
          oxygenSaturation: 92,
          weight: 80.0,
          height: 175.0,
          painLevel: 8.0,
        ),
        notes: 'Kritik vital bulgular - acil müdahale gerekli',
      ),
    ];

    for (final record in demoRecords) {
      _vitalSignsRecords.add(record);
      await _checkForAlerts(record);
    }

    await _saveVitalSignsRecords();
    print('✅ Demo vital signs records created: ${demoRecords.length}');
  }

  // Get vital signs statistics
  Map<String, dynamic> getVitalSignsStatistics() {
    final totalRecords = _vitalSignsRecords.length;
    final criticalRecords = _vitalSignsRecords
        .where((record) => record.status == VitalSignsStatus.critical)
        .length;
    final abnormalRecords = _vitalSignsRecords
        .where((record) => record.status == VitalSignsStatus.abnormal)
        .length;
    final normalRecords = _vitalSignsRecords
        .where((record) => record.status == VitalSignsStatus.normal)
        .length;

    final activeAlerts = _alerts.where((alert) => !alert.isResolved).length;
    final criticalAlerts = _alerts
        .where((alert) => !alert.isResolved && alert.severity == AlertSeverity.critical)
        .length;

    return {
      'totalRecords': totalRecords,
      'criticalRecords': criticalRecords,
      'abnormalRecords': abnormalRecords,
      'normalRecords': normalRecords,
      'activeAlerts': activeAlerts,
      'criticalAlerts': criticalAlerts,
    };
  }
}
