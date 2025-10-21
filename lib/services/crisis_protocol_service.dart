import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crisis_protocol_models.dart';

class CrisisProtocolService {
  static final CrisisProtocolService _instance = CrisisProtocolService._internal();
  factory CrisisProtocolService() => _instance;
  CrisisProtocolService._internal();

  final List<CrisisProtocol> _protocols = [];
  final List<CrisisIncident> _incidents = [];
  final List<CrisisAlert> _alerts = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadProtocols();
    await _loadIncidents();
    await _loadAlerts();
  }

  // Load protocols from storage
  Future<void> _loadProtocols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final protocolsJson = prefs.getStringList('crisis_protocols') ?? [];
      _protocols.clear();
      
      for (final protocolJson in protocolsJson) {
        final protocol = CrisisProtocol.fromJson(jsonDecode(protocolJson));
        _protocols.add(protocol);
      }
    } catch (e) {
      print('Error loading crisis protocols: $e');
      _protocols.clear();
    }
  }

  // Save protocols to storage
  Future<void> _saveProtocols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final protocolsJson = _protocols
          .map((protocol) => jsonEncode(protocol.toJson()))
          .toList();
      await prefs.setStringList('crisis_protocols', protocolsJson);
    } catch (e) {
      print('Error saving crisis protocols: $e');
    }
  }

  // Load incidents from storage
  Future<void> _loadIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentsJson = prefs.getStringList('crisis_incidents') ?? [];
      _incidents.clear();
      
      for (final incidentJson in incidentsJson) {
        final incident = CrisisIncident.fromJson(jsonDecode(incidentJson));
        _incidents.add(incident);
      }
    } catch (e) {
      print('Error loading crisis incidents: $e');
      _incidents.clear();
    }
  }

  // Save incidents to storage
  Future<void> _saveIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentsJson = _incidents
          .map((incident) => jsonEncode(incident.toJson()))
          .toList();
      await prefs.setStringList('crisis_incidents', incidentsJson);
    } catch (e) {
      print('Error saving crisis incidents: $e');
    }
  }

  // Load alerts from storage
  Future<void> _loadAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('crisis_alerts') ?? [];
      _alerts.clear();
      
      for (final alertJson in alertsJson) {
        final alert = CrisisAlert.fromJson(jsonDecode(alertJson));
        _alerts.add(alert);
      }
    } catch (e) {
      print('Error loading crisis alerts: $e');
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
      await prefs.setStringList('crisis_alerts', alertsJson);
    } catch (e) {
      print('Error saving crisis alerts: $e');
    }
  }

  // Get all protocols
  List<CrisisProtocol> getAllProtocols() {
    return _protocols.where((protocol) => protocol.isActive).toList();
  }

  // Get protocols by type
  List<CrisisProtocol> getProtocolsByType(CrisisType type) {
    return _protocols
        .where((protocol) => protocol.isActive && protocol.type == type)
        .toList();
  }

  // Get protocols by severity
  List<CrisisProtocol> getProtocolsBySeverity(CrisisSeverity severity) {
    return _protocols
        .where((protocol) => protocol.isActive && protocol.severity == severity)
        .toList();
  }

  // Start crisis incident
  Future<CrisisIncident> startCrisisIncident({
    required String patientId,
    required String protocolId,
    required CrisisType type,
    required CrisisSeverity severity,
    required String initiatedBy,
    List<String>? involvedStaff,
    String? notes,
  }) async {
    final incident = CrisisIncident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      protocolId: protocolId,
      type: type,
      severity: severity,
      startedAt: DateTime.now(),
      initiatedBy: initiatedBy,
      involvedStaff: involvedStaff ?? [],
      notes: notes,
    );

    _incidents.add(incident);
    await _saveIncidents();

    // Create initial alert
    await _createCrisisAlert(
      patientId: patientId,
      incidentId: incident.id,
      type: AlertType.crisisInitiated,
      severity: _getAlertSeverity(severity),
      message: 'Kriz müdahalesi başlatıldı: ${_getCrisisTypeName(type)}',
    );

    return incident;
  }

  // Execute crisis step
  Future<bool> executeCrisisStep({
    required String incidentId,
    required String stepId,
    required String executedBy,
    String? notes,
    List<String>? issues,
    Map<String, dynamic>? measurements,
  }) async {
    try {
      final incidentIndex = _incidents.indexWhere((incident) => incident.id == incidentId);
      if (incidentIndex == -1) return false;

      final incident = _incidents[incidentIndex];
      
      // Check if step is already executed
      final existingExecution = incident.stepExecutions
          .where((execution) => execution.stepId == stepId)
          .firstOrNull;

      if (existingExecution != null) {
        // Update existing execution
        final updatedExecution = CrisisStepExecution(
          id: existingExecution.id,
          stepId: existingExecution.stepId,
          startedAt: existingExecution.startedAt,
          completedAt: DateTime.now(),
          executedBy: executedBy,
          isCompleted: true,
          notes: notes ?? existingExecution.notes,
          issues: issues ?? existingExecution.issues,
          measurements: measurements ?? existingExecution.measurements,
        );

        final updatedExecutions = List<CrisisStepExecution>.from(incident.stepExecutions);
        final executionIndex = updatedExecutions.indexWhere((e) => e.id == existingExecution.id);
        if (executionIndex != -1) {
          updatedExecutions[executionIndex] = updatedExecution;
        }

        final updatedIncident = CrisisIncident(
          id: incident.id,
          patientId: incident.patientId,
          protocolId: incident.protocolId,
          type: incident.type,
          severity: incident.severity,
          startedAt: incident.startedAt,
          endedAt: incident.endedAt,
          initiatedBy: incident.initiatedBy,
          involvedStaff: incident.involvedStaff,
          stepExecutions: updatedExecutions,
          notes: incident.notes,
          status: incident.status,
          metadata: incident.metadata,
        );

        _incidents[incidentIndex] = updatedIncident;
      } else {
        // Create new execution
        final execution = CrisisStepExecution(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          stepId: stepId,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          executedBy: executedBy,
          isCompleted: true,
          notes: notes,
          issues: issues,
          measurements: measurements,
        );

        final updatedExecutions = [...incident.stepExecutions, execution];
        final updatedIncident = CrisisIncident(
          id: incident.id,
          patientId: incident.patientId,
          protocolId: incident.protocolId,
          type: incident.type,
          severity: incident.severity,
          startedAt: incident.startedAt,
          endedAt: incident.endedAt,
          initiatedBy: incident.initiatedBy,
          involvedStaff: incident.involvedStaff,
          stepExecutions: updatedExecutions,
          notes: incident.notes,
          status: incident.status,
          metadata: incident.metadata,
        );

        _incidents[incidentIndex] = updatedIncident;
      }

      await _saveIncidents();

      // Create step completed alert
      await _createCrisisAlert(
        patientId: incident.patientId,
        incidentId: incidentId,
        type: AlertType.stepCompleted,
        severity: AlertSeverity.medium,
        message: 'Kriz adımı tamamlandı',
      );

      return true;
    } catch (e) {
      print('Error executing crisis step: $e');
      return false;
    }
  }

  // End crisis incident
  Future<bool> endCrisisIncident({
    required String incidentId,
    required String endedBy,
    String? notes,
  }) async {
    try {
      final index = _incidents.indexWhere((incident) => incident.id == incidentId);
      if (index == -1) return false;

      final incident = _incidents[index];
      final updatedIncident = CrisisIncident(
        id: incident.id,
        patientId: incident.patientId,
        protocolId: incident.protocolId,
        type: incident.type,
        severity: incident.severity,
        startedAt: incident.startedAt,
        endedAt: DateTime.now(),
        initiatedBy: incident.initiatedBy,
        involvedStaff: incident.involvedStaff,
        stepExecutions: incident.stepExecutions,
        notes: notes ?? incident.notes,
        status: CrisisStatus.resolved,
        metadata: incident.metadata,
      );

      _incidents[index] = updatedIncident;
      await _saveIncidents();

      // Create resolution alert
      await _createCrisisAlert(
        patientId: incident.patientId,
        incidentId: incidentId,
        type: AlertType.crisisInitiated, // Reuse type for resolution
        severity: AlertSeverity.low,
        message: 'Kriz müdahalesi tamamlandı',
      );

      return true;
    } catch (e) {
      print('Error ending crisis incident: $e');
      return false;
    }
  }

  // Create crisis alert
  Future<void> _createCrisisAlert({
    required String patientId,
    required String incidentId,
    required AlertType type,
    required AlertSeverity severity,
    required String message,
  }) async {
    final alert = CrisisAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      incidentId: incidentId,
      type: type,
      severity: severity,
      message: message,
      createdAt: DateTime.now(),
    );

    _alerts.add(alert);
    await _saveAlerts();
  }

  // Get active incidents
  List<CrisisIncident> getActiveIncidents() {
    return _incidents
        .where((incident) => incident.status == CrisisStatus.active)
        .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Get incidents for patient
  List<CrisisIncident> getIncidentsForPatient(String patientId) {
    return _incidents
        .where((incident) => incident.patientId == patientId)
        .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Get all alerts
  List<CrisisAlert> getAllAlerts() {
    return _alerts
        .where((alert) => !alert.isAcknowledged)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get alerts for patient
  List<CrisisAlert> getAlertsForPatient(String patientId) {
    return _alerts
        .where((alert) => alert.patientId == patientId && !alert.isAcknowledged)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Acknowledge alert
  Future<bool> acknowledgeAlert(String alertId, String acknowledgedBy) async {
    try {
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index == -1) return false;

      final alert = _alerts[index];
      final acknowledgedAlert = CrisisAlert(
        id: alert.id,
        patientId: alert.patientId,
        incidentId: alert.incidentId,
        type: alert.type,
        severity: alert.severity,
        message: alert.message,
        createdAt: alert.createdAt,
        isAcknowledged: true,
        acknowledgedAt: DateTime.now(),
        acknowledgedBy: acknowledgedBy,
        notifiedStaff: alert.notifiedStaff,
      );

      _alerts[index] = acknowledgedAlert;
      await _saveAlerts();
      return true;
    } catch (e) {
      print('Error acknowledging alert: $e');
      return false;
    }
  }

  // Get crisis statistics
  Map<String, dynamic> getCrisisStatistics() {
    final totalIncidents = _incidents.length;
    final activeIncidents = _incidents
        .where((incident) => incident.status == CrisisStatus.active)
        .length;
    final resolvedIncidents = _incidents
        .where((incident) => incident.status == CrisisStatus.resolved)
        .length;
    final escalatedIncidents = _incidents
        .where((incident) => incident.status == CrisisStatus.escalated)
        .length;

    final totalAlerts = _alerts.length;
    final unacknowledgedAlerts = _alerts
        .where((alert) => !alert.isAcknowledged)
        .length;

    // Calculate average resolution time
    final resolvedIncidentsWithDuration = _incidents
        .where((incident) => 
            incident.status == CrisisStatus.resolved && 
            incident.duration != null)
        .toList();

    final averageResolutionTime = resolvedIncidentsWithDuration.isNotEmpty
        ? resolvedIncidentsWithDuration
            .map((incident) => incident.duration!.inMinutes)
            .reduce((a, b) => a + b) / resolvedIncidentsWithDuration.length
        : 0.0;

    return {
      'totalIncidents': totalIncidents,
      'activeIncidents': activeIncidents,
      'resolvedIncidents': resolvedIncidents,
      'escalatedIncidents': escalatedIncidents,
      'totalAlerts': totalAlerts,
      'unacknowledgedAlerts': unacknowledgedAlerts,
      'averageResolutionTime': averageResolutionTime,
    };
  }

  // Helper methods
  AlertSeverity _getAlertSeverity(CrisisSeverity severity) {
    switch (severity) {
      case CrisisSeverity.low:
        return AlertSeverity.low;
      case CrisisSeverity.moderate:
        return AlertSeverity.medium;
      case CrisisSeverity.high:
        return AlertSeverity.high;
      case CrisisSeverity.critical:
        return AlertSeverity.critical;
      case CrisisSeverity.emergency:
        return AlertSeverity.critical;
    }
  }

  String _getCrisisTypeName(CrisisType type) {
    switch (type) {
      case CrisisType.medical:
        return 'Tıbbi Kriz';
      case CrisisType.psychiatric:
        return 'Psikiyatrik Kriz';
      case CrisisType.cardiac:
        return 'Kardiyak Kriz';
      case CrisisType.respiratory:
        return 'Solunum Kriz';
      case CrisisType.neurological:
        return 'Nörolojik Kriz';
      case CrisisType.trauma:
        return 'Travma';
      case CrisisType.overdose:
        return 'Aşırı Doz';
      case CrisisType.suicide:
        return 'İntihar Riski';
      case CrisisType.violence:
        return 'Şiddet';
      case CrisisType.fire:
        return 'Yangın';
      case CrisisType.security:
        return 'Güvenlik';
    }
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_protocols.isNotEmpty) return;

    final demoProtocols = [
      CrisisProtocol(
        id: 'protocol_001',
        title: 'Kardiyak Arrest Protokolü',
        description: 'Kalp durması durumunda uygulanacak acil müdahale protokolü',
        type: CrisisType.cardiac,
        severity: CrisisSeverity.emergency,
        steps: [
          CrisisStep(
            id: 'step_001',
            order: 1,
            title: 'Durumu Değerlendir',
            description: 'Hastanın bilinç durumunu ve nabzını kontrol et',
            actions: [
              'Hastaya seslen',
              'Omuzlarından sars',
              'Karotis nabzını kontrol et',
              'Solunumu kontrol et',
            ],
            estimatedTime: const Duration(minutes: 1),
            isCritical: true,
            responsibleRole: 'Hemşire',
          ),
          CrisisStep(
            id: 'step_002',
            order: 2,
            title: 'Yardım Çağır',
            description: 'Acil durum ekibini ve doktoru çağır',
            actions: [
              'Kod mavi çağrısı yap',
              'Defibrilatörü getir',
              'İlaçları hazırla',
            ],
            estimatedTime: const Duration(minutes: 1),
            isCritical: true,
            responsibleRole: 'Hemşire',
          ),
          CrisisStep(
            id: 'step_003',
            order: 3,
            title: 'CPR Başlat',
            description: 'Kalp masajı ve suni solunum başlat',
            actions: [
              '30 kalp masajı',
              '2 suni solunum',
              '5 siklus tekrarla',
            ],
            estimatedTime: const Duration(minutes: 2),
            isCritical: true,
            responsibleRole: 'Hemşire',
          ),
        ],
        requiredResources: [
          'Defibrilatör',
          'Ambu balonu',
          'Oksijen',
          'İlaçlar',
        ],
        contactNumbers: [
          '112',
          'Dahili: 4444',
          'Kardiyoloji: 4445',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CrisisProtocol(
        id: 'protocol_002',
        title: 'Psikiyatrik Kriz Protokolü',
        description: 'Akut psikiyatrik kriz durumunda uygulanacak protokol',
        type: CrisisType.psychiatric,
        severity: CrisisSeverity.high,
        steps: [
          CrisisStep(
            id: 'step_004',
            order: 1,
            title: 'Güvenliği Sağla',
            description: 'Hasta ve çevresindekilerin güvenliğini sağla',
            actions: [
              'Tehlikeli objeleri uzaklaştır',
              'Güvenli mesafe koru',
              'Güvenlik ekibini çağır',
            ],
            estimatedTime: const Duration(minutes: 2),
            isCritical: true,
            responsibleRole: 'Hemşire',
          ),
          CrisisStep(
            id: 'step_005',
            order: 2,
            title: 'Hastayı Sakinleştir',
            description: 'Sözlü müdahale ile hastayı sakinleştirmeye çalış',
            actions: [
              'Sakin ve net konuş',
              'Empati göster',
              'Seçenekler sun',
            ],
            estimatedTime: const Duration(minutes: 5),
            isCritical: false,
            responsibleRole: 'Psikolog',
          ),
        ],
        requiredResources: [
          'Güvenlik ekibi',
          'Sedatif ilaçlar',
          'Kısıtlama araçları',
        ],
        contactNumbers: [
          'Psikiyatri: 4446',
          'Güvenlik: 4447',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    for (final protocol in demoProtocols) {
      _protocols.add(protocol);
    }

    await _saveProtocols();
    print('✅ Demo crisis protocols created: ${demoProtocols.length}');
  }
}
