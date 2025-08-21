import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/telehealth_models.dart';
import '../utils/ai_logger.dart';

class TelehealthService extends ChangeNotifier {
  static final TelehealthService _instance = TelehealthService._internal();
  factory TelehealthService() => _instance;
  TelehealthService._internal();

  final AILogger _logger = AILogger();
  
  // Telehealth state
  bool _isInitialized = false;
  List<TelehealthSession> _sessions = [];
  List<RemoteMonitoringDevice> _devices = [];
  List<DigitalTherapeutic> _therapeutics = [];
  
  // Stream controllers
  final StreamController<TelehealthSession> _sessionController = StreamController<TelehealthSession>.broadcast();
  final StreamController<RemoteMonitoringDevice> _deviceController = StreamController<RemoteMonitoringDevice>.broadcast();
  final StreamController<BiometricReading> _readingController = StreamController<BiometricReading>.broadcast();
  final StreamController<DeviceAlert> _alertController = StreamController<DeviceAlert>.broadcast();

  // Streams
  Stream<TelehealthSession> get sessionStream => _sessionController.stream;
  Stream<RemoteMonitoringDevice> get deviceStream => _deviceController.stream;
  Stream<BiometricReading> get readingStream => _readingController.stream;
  Stream<DeviceAlert> get alertStream => _alertController.stream;

  // Getters
  bool get isInitialized => _isInitialized;
  List<TelehealthSession> get sessions => _sessions;
  List<RemoteMonitoringDevice> get devices => _devices;
  List<DigitalTherapeutic> get therapeutics => _therapeutics;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _logger.info('TelehealthService initializing...', context: 'TelehealthService');
    
    try {
      await _loadTelehealthData();
      await _initializeDefaultTherapeutics();
      await _setupComplianceDefaults();
      
      _isInitialized = true;
      _logger.info('TelehealthService initialized successfully', context: 'TelehealthService');
      notifyListeners();
    } catch (e) {
      _logger.error('TelehealthService initialization failed: $e', context: 'TelehealthService');
      rethrow;
    }
  }

  // === TELEHEALTH SESSION MANAGEMENT ===

  Future<TelehealthSession> createSession({
    required String sessionId,
    required String clientId,
    required String therapistId,
    required TelehealthSessionType type,
    required DateTime scheduledAt,
    required int durationMinutes,
    TelehealthPlatform platform = TelehealthPlatform.integrated,
  }) async {
    final session = TelehealthSession(
      id: _generateId(),
      sessionId: sessionId,
      clientId: clientId,
      therapistId: therapistId,
      type: type,
      status: TelehealthSessionStatus.scheduled,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      platform: platform,
      qualitySettings: _getDefaultQualitySettings(),
      participants: [
        TelehealthParticipant(
          id: _generateId(),
          userId: therapistId,
          name: 'Therapist',
          email: 'therapist@example.com',
          role: ParticipantRole.therapist,
          status: ParticipantStatus.invited,
          joinedAt: DateTime.now(),
          isRecording: false,
          isScreenSharing: false,
          actions: [],
        ),
        TelehealthParticipant(
          id: _generateId(),
          userId: clientId,
          name: 'Client',
          email: 'client@example.com',
          role: ParticipantRole.client,
          status: ParticipantStatus.invited,
          joinedAt: DateTime.now(),
          isRecording: false,
          isScreenSharing: false,
          actions: [],
        ),
      ],
      recordingSettings: _getDefaultRecordingSettings(),
      notes: [],
      compliance: _getDefaultCompliance(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sessions.add(session);
    await _saveTelehealthData();
    _sessionController.add(session);
    notifyListeners();

    _logger.info('Created telehealth session: ${session.id}', context: 'TelehealthService');
    return session;
  }

  Future<void> startSession(String sessionId) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final updatedSession = session.copyWith(
      status: TelehealthSessionStatus.inProgress,
      startedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    _sessions[index] = updatedSession;
    await _saveTelehealthData();
    _sessionController.add(updatedSession);
    notifyListeners();

    _logger.info('Started telehealth session: $sessionId', context: 'TelehealthService');
  }

  Future<void> endSession(String sessionId) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final updatedSession = session.copyWith(
      status: TelehealthSessionStatus.completed,
      endedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    _sessions[index] = updatedSession;
    await _saveTelehealthData();
    _sessionController.add(updatedSession);
    notifyListeners();

    _logger.info('Ended telehealth session: $sessionId', context: 'TelehealthService');
  }

  Future<void> addSessionNote({
    required String sessionId,
    required String authorId,
    required String authorName,
    required String content,
    NoteType type = NoteType.clinical,
    List<String> tags = const [],
    bool isPrivate = false,
  }) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final note = TelehealthNote(
      id: _generateId(),
      authorId: authorId,
      authorName: authorName,
      content: content,
      timestamp: DateTime.now(),
      type: type,
      tags: tags,
      isPrivate: isPrivate,
    );

    final updatedNotes = [...session.notes, note];
    final updatedSession = session.copyWith(
      notes: updatedNotes,
      updatedAt: DateTime.now(),
    );

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    _sessions[index] = updatedSession;
    await _saveTelehealthData();
    _sessionController.add(updatedSession);
    notifyListeners();

    _logger.info('Added note to session: $sessionId', context: 'TelehealthService');
  }

  // === REMOTE MONITORING DEVICE MANAGEMENT ===

  Future<RemoteMonitoringDevice> registerDevice({
    required String deviceType,
    required String deviceId,
    required String patientId,
  }) async {
    final device = RemoteMonitoringDevice(
      id: _generateId(),
      deviceType: deviceType,
      deviceId: deviceId,
      patientId: patientId,
      status: DeviceStatus.active,
      lastSync: DateTime.now(),
      deviceData: {},
      readings: [],
      calibration: DeviceCalibration(
        lastCalibrated: DateTime.now(),
        calibratedBy: 'system',
        calibrationData: {},
        nextCalibrationDue: DateTime.now().add(const Duration(days: 30)),
      ),
      alerts: [],
    );

    _devices.add(device);
    await _saveTelehealthData();
    _deviceController.add(device);
    notifyListeners();

    _logger.info('Registered device: ${device.id}', context: 'TelehealthService');
    return device;
  }

  Future<void> addBiometricReading({
    required String deviceId,
    required String patientId,
    required BiometricType type,
    required double value,
    required String unit,
    ReadingQuality quality = ReadingQuality.good,
    Map<String, dynamic> metadata = const {},
    List<String> flags = const [],
  }) async {
    final reading = BiometricReading(
      id: _generateId(),
      deviceId: deviceId,
      patientId: patientId,
      type: type,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      quality: quality,
      metadata: metadata,
      flags: flags,
    );

    final device = _devices.firstWhere((d) => d.deviceId == deviceId);
    final updatedReadings = [...device.readings, reading];
    final updatedDevice = device.copyWith(
      readings: updatedReadings,
      lastSync: DateTime.now(),
    );

    final index = _devices.indexWhere((d) => d.deviceId == deviceId);
    _devices[index] = updatedDevice;
    await _saveTelehealthData();
    _readingController.add(reading);
    _deviceController.add(updatedDevice);
    notifyListeners();

    // Check for alerts
    await _checkBiometricAlerts(reading);

    _logger.info('Added biometric reading: ${reading.id}', context: 'TelehealthService');
  }

  Future<void> _checkBiometricAlerts(BiometricReading reading) async {
    // Example alert logic for heart rate
    if (reading.type == BiometricType.heartRate) {
      if (reading.value > 100) {
        final alert = DeviceAlert(
          id: _generateId(),
          alertType: 'high_heart_rate',
          message: 'Heart rate is elevated: ${reading.value} ${reading.unit}',
          severity: AlertSeverity.medium,
          timestamp: DateTime.now(),
          isAcknowledged: false,

        );

        final device = _devices.firstWhere((d) => d.deviceId == reading.deviceId);
        final updatedAlerts = [...device.alerts, alert];
        final updatedDevice = device.copyWith(alerts: updatedAlerts);

        final index = _devices.indexWhere((d) => d.deviceId == reading.deviceId);
        _devices[index] = updatedDevice;
        await _saveTelehealthData();
        _alertController.add(alert);
        _deviceController.add(updatedDevice);
        notifyListeners();

        _logger.warning('Biometric alert triggered: ${alert.message}', context: 'TelehealthService');
      }
    }
  }

  // === DIGITAL THERAPEUTICS MANAGEMENT ===

  Future<DigitalTherapeutic> createDigitalTherapeutic({
    required String name,
    required String description,
    required TherapeuticType type,
    required List<String> indications,
    required List<String> contraindications,
    required String manufacturer,
    String? fdaApprovalNumber,
    String? ceMarkNumber,
    required List<String> supportedRegions,
    required TherapeuticProtocol protocol,
    required List<TherapeuticOutcome> outcomes,
    required PricingInfo pricing,
  }) async {
    final therapeutic = DigitalTherapeutic(
      id: _generateId(),
      name: name,
      description: description,
      type: type,
      indications: indications,
      contraindications: contraindications,
      manufacturer: manufacturer,
      fdaApprovalNumber: fdaApprovalNumber,
      ceMarkNumber: ceMarkNumber,
      approvalDate: DateTime.now(),
      supportedRegions: supportedRegions,
      protocol: protocol,
      outcomes: outcomes,
      pricing: pricing,
    );

    _therapeutics.add(therapeutic);
    await _saveTelehealthData();
    notifyListeners();

    _logger.info('Created digital therapeutic: ${therapeutic.id}', context: 'TelehealthService');
    return therapeutic;
  }

  // === COMPLIANCE & SECURITY ===

  Future<void> updateCompliance(String sessionId, TelehealthCompliance compliance) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final updatedSession = session.copyWith(
      compliance: compliance,
      updatedAt: DateTime.now(),
    );

    final index = _sessions.indexWhere((s) => s.id == sessionId);
    _sessions[index] = updatedSession;
    await _saveTelehealthData();
    _sessionController.add(updatedSession);
    notifyListeners();

    _logger.info('Updated compliance for session: $sessionId', context: 'TelehealthService');
  }

  Future<bool> checkComplianceViolation(String sessionId) async {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    return session.compliance.violations.isNotEmpty;
  }

  // === UTILITY METHODS ===

  TelehealthQualitySettings _getDefaultQualitySettings() {
    return TelehealthQualitySettings(
      videoQuality: VideoQuality.high,
      audioQuality: AudioQuality.high,
      maxBitrate: 2000000, // 2 Mbps
      enableHD: true,
      enableNoiseSuppression: true,
      enableEchoCancellation: true,
      enableAutoGainControl: true,
      frameRate: 30,
      resolution: '1920x1080',
    );
  }

  TelehealthRecordingSettings _getDefaultRecordingSettings() {
    return TelehealthRecordingSettings(
      isRecordingEnabled: true,
      recordingType: RecordingType.combined,
      recordingQuality: RecordingQuality.high,
      enableTranscription: true,
      enableTranslation: false,
      allowedLanguages: ['en', 'tr'],
      retentionDays: 30,
      enableWatermark: true,
      watermarkText: 'PsyClinic AI - Confidential',
    );
  }

  TelehealthCompliance _getDefaultCompliance() {
    return TelehealthCompliance(
      hipaaCompliant: true,
      gdprCompliant: true,
      kvkkCompliant: true,
      pipedaCompliant: true,
      complianceCertificates: ['ISO 27001', 'SOC 2 Type II'],
      lastAuditDate: DateTime.now(),
      auditResult: 'Passed',
      violations: [],
      dataRetention: DataRetentionPolicy(
        sessionRecordingsDays: 30,
        chatLogsDays: 90,
        biometricDataDays: 365,
        auditLogsDays: 2555, // 7 years
        enableAutoDeletion: true,
        exceptions: ['legal_hold', 'research'],
      ),
      encryption: EncryptionSettings(
        algorithm: 'AES-256',
        keySize: 256,
        enableEndToEndEncryption: true,
        enableAtRestEncryption: true,
        enableInTransitEncryption: true,
        keyManagement: 'AWS KMS',
      ),
    );
  }

  Future<void> _initializeDefaultTherapeutics() async {
    if (_therapeutics.isNotEmpty) return;

    // Example: Mindfulness App
    final mindfulnessProtocol = TherapeuticProtocol(
      id: _generateId(),
      name: 'Mindfulness Training Protocol',
      durationWeeks: 8,
      sessionsPerWeek: 3,
      sessionDurationMinutes: 20,
      steps: [
        ProtocolStep(
          id: _generateId(),
          name: 'Breathing Exercise',
          description: 'Basic breathing awareness',
          order: 1,
          durationMinutes: 5,
          instructions: ['Sit comfortably', 'Focus on breath', 'Count breaths'],
          parameters: {'breathCount': 10},
        ),
        ProtocolStep(
          id: _generateId(),
          name: 'Body Scan',
          description: 'Progressive body relaxation',
          order: 2,
          durationMinutes: 10,
          instructions: ['Start from toes', 'Move upward', 'Release tension'],
          parameters: {'bodyParts': ['toes', 'feet', 'legs', 'torso', 'arms', 'head']},
        ),
      ],
      requiredDevices: ['smartphone'],
      optionalDevices: ['heart_rate_monitor'],
      parameters: {'difficulty': 'beginner'},
    );

    final mindfulnessOutcomes = [
      TherapeuticOutcome(
        id: _generateId(),
        outcomeType: 'stress_reduction',
        description: 'Reduction in perceived stress levels',
        measurement: 'PSS-10 Score',
        baselineValue: 25.0,
        targetValue: 15.0,
        unit: 'points',
      ),
      TherapeuticOutcome(
        id: _generateId(),
        outcomeType: 'anxiety_reduction',
        description: 'Reduction in anxiety symptoms',
        measurement: 'GAD-7 Score',
        baselineValue: 12.0,
        targetValue: 7.0,
        unit: 'points',
      ),
    ];

    final mindfulnessPricing = PricingInfo(
      price: 29.99,
      currency: 'USD',
      frequency: BillingFrequency.monthly,
      includedFeatures: ['8-week program', 'Daily exercises', 'Progress tracking'],
      additionalCosts: {'personal_coaching': 99.99},
    );

    await createDigitalTherapeutic(
      name: 'MindfulMind',
      description: 'AI-powered mindfulness training app for stress and anxiety',
      type: TherapeuticType.mindfulness,
      indications: ['Stress', 'Anxiety', 'Insomnia', 'Depression'],
      contraindications: ['Acute psychosis', 'Severe depression'],
      manufacturer: 'PsyClinic AI',
      fdaApprovalNumber: 'FDA-2024-001',
      supportedRegions: ['US', 'EU', 'TR'],
      protocol: mindfulnessProtocol,
      outcomes: mindfulnessOutcomes,
      pricing: mindfulnessPricing,
    );
  }

  Future<void> _setupComplianceDefaults() async {
    // Platform-specific compliance settings
    final prefs = await SharedPreferences.getInstance();
    final region = prefs.getString('selected_region') ?? 'TR';

    switch (region) {
      case 'US':
        await _setupUSCompliance();
        break;
      case 'EU':
        await _setupEUCompliance();
        break;
      case 'TR':
        await _setupTRCompliance();
        break;
      default:
        await _setupTRCompliance();
    }
  }

  Future<void> _setupUSCompliance() async {
    _logger.info('Setting up US compliance (HIPAA)', context: 'TelehealthService');
    // HIPAA specific settings
  }

  Future<void> _setupEUCompliance() async {
    _logger.info('Setting up EU compliance (GDPR)', context: 'TelehealthService');
    // GDPR specific settings
  }

  Future<void> _setupTRCompliance() async {
    _logger.info('Setting up TR compliance (KVKK)', context: 'TelehealthService');
    // KVKK specific settings
  }

  // === DATA PERSISTENCE ===

  Future<void> _loadTelehealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load sessions
      final sessionsJson = prefs.getString('telehealth_sessions');
      if (sessionsJson != null) {
        final sessionsList = json.decode(sessionsJson) as List;
        _sessions = sessionsList
            .map((json) => TelehealthSession.fromJson(json))
            .toList();
      }

      // Load devices
      final devicesJson = prefs.getString('telehealth_devices');
      if (devicesJson != null) {
        final devicesList = json.decode(devicesJson) as List;
        _devices = devicesList
            .map((json) => RemoteMonitoringDevice.fromJson(json))
            .toList();
      }

      // Load therapeutics
      final therapeuticsJson = prefs.getString('telehealth_therapeutics');
      if (therapeuticsJson != null) {
        final therapeuticsList = json.decode(therapeuticsJson) as List;
        _therapeutics = therapeuticsList
            .map((json) => DigitalTherapeutic.fromJson(json))
            .toList();
      }
    } catch (e) {
      _logger.error('Failed to load telehealth data: $e', context: 'TelehealthService');
    }
  }

  Future<void> _saveTelehealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save sessions
      final sessionsJson = json.encode(_sessions.map((s) => s.toJson()).toList());
      await prefs.setString('telehealth_sessions', sessionsJson);

      // Save devices
      final devicesJson = json.encode(_devices.map((d) => d.toJson()).toList());
      await prefs.setString('telehealth_devices', devicesJson);

      // Save therapeutics
      final therapeuticsJson = json.encode(_therapeutics.map((t) => t.toJson()).toList());
      await prefs.setString('telehealth_therapeutics', therapeuticsJson);
    } catch (e) {
      _logger.error('Failed to save telehealth data: $e', context: 'TelehealthService');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + DateTime.now().microsecond % 1000).toString();
  }

  // === QUERY METHODS ===

  List<TelehealthSession> getSessionsByStatus(TelehealthSessionStatus status) {
    return _sessions.where((s) => s.status == status).toList();
  }

  List<TelehealthSession> getSessionsByClient(String clientId) {
    return _sessions.where((s) => s.clientId == clientId).toList();
  }

  List<TelehealthSession> getSessionsByTherapist(String therapistId) {
    return _sessions.where((s) => s.therapistId == therapistId).toList();
  }

  List<RemoteMonitoringDevice> getDevicesByPatient(String patientId) {
    return _devices.where((d) => d.patientId == patientId).toList();
  }

  List<BiometricReading> getReadingsByPatient(String patientId, {BiometricType? type}) {
    final patientDevices = getDevicesByPatient(patientId);
    final allReadings = <BiometricReading>[];
    
    for (final device in patientDevices) {
      if (type != null) {
        allReadings.addAll(device.readings.where((r) => r.type == type));
      } else {
        allReadings.addAll(device.readings);
      }
    }
    
    allReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allReadings;
  }

  List<DigitalTherapeutic> getTherapeuticsByType(TherapeuticType type) {
    return _therapeutics.where((t) => t.type == type).toList();
  }

  List<DigitalTherapeutic> getTherapeuticsByRegion(String region) {
    return _therapeutics.where((t) => t.supportedRegions.contains(region)).toList();
  }

  // === CLEANUP ===

  @override
  void dispose() {
    _sessionController.close();
    _deviceController.close();
    _readingController.close();
    _alertController.close();
    super.dispose();
  }
}
