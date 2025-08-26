import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/telemedicine_models.dart';
import '../models/blockchain_security_models.dart';

/// Advanced Telemedicine Service for comprehensive telemedicine management
class AdvancedTelemedicineService {
  static const String _baseUrl = 'https://api.telemedicine.psyclinicai.com/v1';
  static const String _apiKey = 'demo_key_12345';

  // Cache for telemedicine data
  final Map<String, TelemedicineSession> _sessionsCache = {};
  final Map<String, VirtualWaitingRoom> _waitingRoomsCache = {};
  final Map<String, EConsultation> _consultationsCache = {};
  final Map<String, RemotePrescription> _prescriptionsCache = {};
  final Map<String, PatientMonitoringData> _monitoringCache = {};
  final Map<String, EmergencyProtocol> _emergencyCache = {};

  // Stream controllers for real-time updates
  final StreamController<TelemedicineSession> _sessionController =
      StreamController<TelemedicineSession>.broadcast();
  final StreamController<VideoCallMetrics> _qualityController =
      StreamController<VideoCallMetrics>.broadcast();
  final StreamController<PatientMonitoringData> _monitoringController =
      StreamController<PatientMonitoringData>.broadcast();
  final StreamController<EmergencyProtocol> _emergencyController =
      StreamController<EmergencyProtocol>.broadcast();

  // Active sessions and monitoring
  final Map<String, TelemedicineSession> _activeSessions = {};
  final Map<String, Timer> _monitoringTimers = {};

  /// Get stream for session updates
  Stream<TelemedicineSession> get sessionStream => _sessionController.stream;

  /// Get stream for video quality updates
  Stream<VideoCallMetrics> get qualityStream => _qualityController.stream;

  /// Get stream for patient monitoring updates
  Stream<PatientMonitoringData> get monitoringStream => _monitoringController.stream;

  /// Get stream for emergency protocol updates
  Stream<EmergencyProtocol> get emergencyStream => _emergencyController.stream;

  /// Initialize telemedicine service
  Future<void> initialize() async {
    await _loadActiveSessions();
    await _startMonitoringServices();
  }

  /// Create new telemedicine session
  Future<TelemedicineSession> createSession({
    required String patientId,
    required String patientName,
    required String therapistId,
    required String therapistName,
    required SessionType sessionType,
    required DateTime scheduledTime,
    required int duration,
    VideoQualityLevel videoQuality = VideoQualityLevel.high,
    EmergencyLevel emergencyLevel = EmergencyLevel.none,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patient_id': patientId,
          'patient_name': patientName,
          'therapist_id': therapistId,
          'therapist_name': therapistName,
          'session_type': sessionType.name,
          'scheduled_time': scheduledTime.toIso8601String(),
          'duration': duration,
          'video_quality': videoQuality.name,
          'emergency_level': emergencyLevel.name,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final session = TelemedicineSession.fromJson(data);
        _sessionsCache[session.id] = session;

        // Notify listeners
        _sessionController.add(session);

        return session;
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock session for demo purposes
      final session = TelemedicineSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        therapistId: therapistId,
        therapistName: therapistName,
        sessionType: sessionType,
        status: TelemedicineSessionStatus.scheduled,
        scheduledTime: scheduledTime,
        duration: duration,
        videoQuality: videoQuality,
        emergencyLevel: emergencyLevel,
        sessionNotes: {},
        participants: [patientId, therapistId],
        technicalSettings: _getDefaultTechnicalSettings(),
        isRecorded: false,
        isEncrypted: true,
        blockchainHash: '0x${_generateRandomHash()}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      _sessionsCache[session.id] = session;
      _sessionController.add(session);

      return session;
    }
  }

  /// Start telemedicine session
  Future<TelemedicineSession> startSession({
    required String sessionId,
    required String meetingUrl,
    required String meetingId,
    String? meetingPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/start'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'meeting_url': meetingUrl,
          'meeting_id': meetingId,
          'meeting_password': meetingPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final session = TelemedicineSession.fromJson(data);
        _sessionsCache[sessionId] = session;
        _activeSessions[sessionId] = session;

        // Start monitoring
        _startSessionMonitoring(sessionId);

        // Notify listeners
        _sessionController.add(session);

        return session;
      } else {
        throw Exception('Failed to start session: ${response.statusCode}');
      }
    } catch (e) {
      // Update mock session for demo purposes
      final session = _sessionsCache[sessionId];
      if (session != null) {
        final updatedSession = TelemedicineSession(
          id: session.id,
          patientId: session.patientId,
          patientName: session.patientName,
          therapistId: session.therapistId,
          therapistName: session.therapistName,
          sessionType: session.sessionType,
          status: TelemedicineSessionStatus.active,
          scheduledTime: session.scheduledTime,
          startTime: DateTime.now(),
          duration: session.duration,
          videoQuality: session.videoQuality,
          emergencyLevel: session.emergencyLevel,
          meetingUrl: meetingUrl,
          meetingId: meetingId,
          meetingPassword: meetingPassword,
          sessionNotes: session.sessionNotes,
          participants: session.participants,
          technicalSettings: session.technicalSettings,
          recordingUrl: session.recordingUrl,
          isRecorded: session.isRecorded,
          isEncrypted: session.isEncrypted,
          blockchainHash: session.blockchainHash,
          createdAt: session.createdAt,
          updatedAt: DateTime.now(),
          metadata: session.metadata,
        );

        _sessionsCache[sessionId] = updatedSession;
        _activeSessions[sessionId] = updatedSession;
        _startSessionMonitoring(sessionId);
        _sessionController.add(updatedSession);

        return updatedSession;
      }
      throw Exception('Session not found');
    }
  }

  /// End telemedicine session
  Future<TelemedicineSession> endSession({
    required String sessionId,
    Map<String, dynamic>? sessionNotes,
    String? recordingUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/end'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session_notes': sessionNotes ?? {},
          'recording_url': recordingUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final session = TelemedicineSession.fromJson(data);
        _sessionsCache[sessionId] = session;
        _activeSessions.remove(sessionId);

        // Stop monitoring
        _stopSessionMonitoring(sessionId);

        // Notify listeners
        _sessionController.add(session);

        return session;
      } else {
        throw Exception('Failed to end session: ${response.statusCode}');
      }
    } catch (e) {
      // Update mock session for demo purposes
      final session = _sessionsCache[sessionId];
      if (session != null) {
        final updatedSession = TelemedicineSession(
          id: session.id,
          patientId: session.patientId,
          patientName: session.patientName,
          therapistId: session.therapistId,
          therapistName: session.therapistName,
          sessionType: session.sessionType,
          status: TelemedicineSessionStatus.completed,
          scheduledTime: session.scheduledTime,
          startTime: session.startTime,
          endTime: DateTime.now(),
          duration: session.duration,
          videoQuality: session.videoQuality,
          emergencyLevel: session.emergencyLevel,
          meetingUrl: session.meetingUrl,
          meetingId: session.meetingId,
          meetingPassword: session.meetingPassword,
          sessionNotes: sessionNotes ?? session.sessionNotes,
          participants: session.participants,
          technicalSettings: session.technicalSettings,
          recordingUrl: recordingUrl ?? session.recordingUrl,
          isRecorded: recordingUrl != null,
          isEncrypted: session.isEncrypted,
          blockchainHash: session.blockchainHash,
          createdAt: session.createdAt,
          updatedAt: DateTime.now(),
          metadata: session.metadata,
        );

        _sessionsCache[sessionId] = updatedSession;
        _activeSessions.remove(sessionId);
        _stopSessionMonitoring(sessionId);
        _sessionController.add(updatedSession);

        return updatedSession;
      }
      throw Exception('Session not found');
    }
  }

  /// Create virtual waiting room
  Future<VirtualWaitingRoom> createWaitingRoom({
    required String sessionId,
    Map<String, dynamic>? queueSettings,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/waiting-rooms'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session_id': sessionId,
          'queue_settings': queueSettings ?? _getDefaultQueueSettings(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final waitingRoom = VirtualWaitingRoom.fromJson(data);
        _waitingRoomsCache[waitingRoom.id] = waitingRoom;

        return waitingRoom;
      } else {
        throw Exception('Failed to create waiting room: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock waiting room for demo purposes
      final waitingRoom = VirtualWaitingRoom(
        id: 'waiting_room_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        patients: [],
        currentPosition: 0,
        estimatedStartTime: DateTime.now().add(const Duration(minutes: 15)),
        status: 'active',
        queueSettings: queueSettings ?? _getDefaultQueueSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _waitingRoomsCache[waitingRoom.id] = waitingRoom;
      return waitingRoom;
    }
  }

  /// Add patient to waiting room
  Future<VirtualWaitingRoom> addPatientToWaitingRoom({
    required String waitingRoomId,
    required String patientId,
    required String patientName,
    EmergencyLevel emergencyLevel = EmergencyLevel.none,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/waiting-rooms/$waitingRoomId/patients'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patient_id': patientId,
          'patient_name': patientName,
          'emergency_level': emergencyLevel.name,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final waitingRoom = VirtualWaitingRoom.fromJson(data);
        _waitingRoomsCache[waitingRoomId] = waitingRoom;

        return waitingRoom;
      } else {
        throw Exception('Failed to add patient: ${response.statusCode}');
      }
    } catch (e) {
      // Update mock waiting room for demo purposes
      final waitingRoom = _waitingRoomsCache[waitingRoomId];
      if (waitingRoom != null) {
        final newPatient = WaitingPatient(
          id: 'patient_${DateTime.now().millisecondsSinceEpoch}',
          patientId: patientId,
          patientName: patientName,
          position: waitingRoom.patients.length + 1,
          checkInTime: DateTime.now(),
          estimatedWaitTime: DateTime.now().add(const Duration(minutes: 15)),
          emergencyLevel: emergencyLevel,
          notes: notes,
          isReady: true,
          metadata: {},
        );

        final updatedPatients = List<WaitingPatient>.from(waitingRoom.patients)
          ..add(newPatient);

        final updatedWaitingRoom = VirtualWaitingRoom(
          id: waitingRoom.id,
          sessionId: waitingRoom.sessionId,
          patients: updatedPatients,
          currentPosition: waitingRoom.currentPosition,
          estimatedStartTime: waitingRoom.estimatedStartTime,
          status: waitingRoom.status,
          queueSettings: waitingRoom.queueSettings,
          createdAt: waitingRoom.createdAt,
          updatedAt: DateTime.now(),
        );

        _waitingRoomsCache[waitingRoomId] = updatedWaitingRoom;
        return updatedWaitingRoom;
      }
      throw Exception('Waiting room not found');
    }
  }

  /// Create e-consultation
  Future<EConsultation> createEConsultation({
    required String patientId,
    required String patientName,
    required String therapistId,
    required String therapistName,
    required String consultationType,
    required String symptoms,
    required String medicalHistory,
    required List<String> currentMedications,
    required String assessment,
    required String recommendations,
    required List<String> prescribedMedications,
    required String followUpInstructions,
    required int duration,
    bool requiresFollowUp = false,
    DateTime? followUpDate,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/e-consultations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patient_id': patientId,
          'patient_name': patientName,
          'therapist_id': therapistId,
          'therapist_name': therapistName,
          'consultation_type': consultationType,
          'symptoms': symptoms,
          'medical_history': medicalHistory,
          'current_medications': currentMedications,
          'assessment': assessment,
          'recommendations': recommendations,
          'prescribed_medications': prescribedMedications,
          'follow_up_instructions': followUpInstructions,
          'duration': duration,
          'requires_follow_up': requiresFollowUp,
          'follow_up_date': followUpDate?.toIso8601String(),
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final consultation = EConsultation.fromJson(data);
        _consultationsCache[consultation.id] = consultation;

        return consultation;
      } else {
        throw Exception('Failed to create e-consultation: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock e-consultation for demo purposes
      final consultation = EConsultation(
        id: 'consultation_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        therapistId: therapistId,
        therapistName: therapistName,
        consultationType: consultationType,
        symptoms: symptoms,
        medicalHistory: medicalHistory,
        currentMedications: currentMedications,
        assessment: assessment,
        recommendations: recommendations,
        prescribedMedications: prescribedMedications,
        followUpInstructions: followUpInstructions,
        consultationDate: DateTime.now(),
        duration: duration,
        requiresFollowUp: requiresFollowUp,
        followUpDate: followUpDate,
        blockchainHash: '0x${_generateRandomHash()}',
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      _consultationsCache[consultation.id] = consultation;
      return consultation;
    }
  }

  /// Create remote prescription
  Future<RemotePrescription> createRemotePrescription({
    required String patientId,
    required String patientName,
    required String therapistId,
    required String therapistName,
    required String prescriptionType,
    required List<PrescribedMedication> medications,
    required String diagnosis,
    required String instructions,
    required DateTime expiryDate,
    required int refills,
    bool isControlled = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/remote-prescriptions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patient_id': patientId,
          'patient_name': patientName,
          'therapist_id': therapistId,
          'therapist_name': therapistName,
          'prescription_type': prescriptionType,
          'medications': medications.map((m) => m.toJson()).toList(),
          'diagnosis': diagnosis,
          'instructions': instructions,
          'expiry_date': expiryDate.toIso8601String(),
          'refills': refills,
          'is_controlled': isControlled,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prescription = RemotePrescription.fromJson(data);
        _prescriptionsCache[prescription.id] = prescription;

        return prescription;
      } else {
        throw Exception('Failed to create prescription: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock prescription for demo purposes
      final prescription = RemotePrescription(
        id: 'prescription_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        therapistId: therapistId,
        therapistName: therapistName,
        prescriptionType: prescriptionType,
        medications: medications,
        diagnosis: diagnosis,
        instructions: instructions,
        prescriptionDate: DateTime.now(),
        expiryDate: expiryDate,
        refills: refills,
        isControlled: isControlled,
        blockchainHash: '0x${_generateRandomHash()}',
        isVerified: true,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      _prescriptionsCache[prescription.id] = prescription;
      return prescription;
    }
  }

  /// Start patient monitoring
  Future<void> startPatientMonitoring({
    required String patientId,
    required String sessionId,
    int monitoringInterval = 30, // seconds
  }) async {
    if (_monitoringTimers.containsKey(patientId)) {
      _stopPatientMonitoring(patientId);
    }

    final timer = Timer.periodic(Duration(seconds: monitoringInterval), (timer) {
      _collectMonitoringData(patientId, sessionId);
    });

    _monitoringTimers[patientId] = timer;
  }

  /// Stop patient monitoring
  Future<void> stopPatientMonitoring(String patientId) async {
    final timer = _monitoringTimers[patientId];
    if (timer != null) {
      timer.cancel();
      _monitoringTimers.remove(patientId);
    }
  }

  /// Create emergency protocol
  Future<EmergencyProtocol> createEmergencyProtocol({
    required String sessionId,
    required String patientId,
    required EmergencyLevel emergencyLevel,
    required String emergencyType,
    required String description,
    required List<String> immediateActions,
    required List<String> emergencyContacts,
    required String nearestHospital,
    required String hospitalAddress,
    required String hospitalPhone,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/emergency-protocols'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session_id': sessionId,
          'patient_id': patientId,
          'emergency_level': emergencyLevel.name,
          'emergency_type': emergencyType,
          'description': description,
          'immediate_actions': immediateActions,
          'emergency_contacts': emergencyContacts,
          'nearest_hospital': nearestHospital,
          'hospital_address': hospitalAddress,
          'hospital_phone': hospitalPhone,
          'metadata': metadata ?? {},
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final protocol = EmergencyProtocol.fromJson(data);
        _emergencyCache[protocol.id] = protocol;

        // Notify listeners
        _emergencyController.add(protocol);

        return protocol;
      } else {
        throw Exception('Failed to create emergency protocol: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock emergency protocol for demo purposes
      final protocol = EmergencyProtocol(
        id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        patientId: patientId,
        emergencyLevel: emergencyLevel,
        emergencyType: emergencyType,
        description: description,
        immediateActions: immediateActions,
        emergencyContacts: emergencyContacts,
        nearestHospital: nearestHospital,
        hospitalAddress: hospitalAddress,
        hospitalPhone: hospitalPhone,
        emergencyServicesCalled: false,
        emergencyStartTime: DateTime.now(),
        status: 'active',
        blockchainHash: '0x${_generateRandomHash()}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      _emergencyCache[protocol.id] = protocol;
      _emergencyController.add(protocol);

      return protocol;
    }
  }

  /// Get telemedicine analytics
  Future<TelemedicineAnalytics> getAnalytics({
    required DateTime date,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics').replace(queryParameters: {
          'date': date.toIso8601String(),
        }),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TelemedicineAnalytics.fromJson(data);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock analytics for demo purposes
      return TelemedicineAnalytics(
        id: 'analytics_${date.millisecondsSinceEpoch}',
        date: date,
        totalSessions: _sessionsCache.length,
        completedSessions: _sessionsCache.values
            .where((s) => s.status == TelemedicineSessionStatus.completed)
            .length,
        cancelledSessions: _sessionsCache.values
            .where((s) => s.status == TelemedicineSessionStatus.cancelled)
            .length,
        noShowSessions: _sessionsCache.values
            .where((s) => s.status == TelemedicineSessionStatus.noShow)
            .length,
        averageSessionDuration: 45.0,
        averageWaitTime: 12.5,
        patientSatisfactionScore: 4.7,
        technicalIssueRate: 0.05,
        sessionTypeDistribution: {
          'initial_consultation': 25,
          'follow_up': 40,
          'crisis_intervention': 10,
          'group_therapy': 15,
          'family_therapy': 10,
        },
        emergencyLevelDistribution: {
          'none': 70,
          'low': 15,
          'medium': 10,
          'high': 3,
          'critical': 2,
        },
        qualityMetrics: {
          'video_quality': 4.8,
          'audio_quality': 4.9,
          'connection_stability': 4.7,
        },
        performanceData: {
          'uptime': 99.9,
          'response_time': 0.8,
          'error_rate': 0.01,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Dispose resources
  void dispose() {
    // Stop all monitoring timers
    for (final timer in _monitoringTimers.values) {
      timer.cancel();
    }
    _monitoringTimers.clear();

    // Close stream controllers
    if (!_sessionController.isClosed) {
      _sessionController.close();
    }
    if (!_qualityController.isClosed) {
      _qualityController.close();
    }
    if (!_monitoringController.isClosed) {
      _monitoringController.close();
    }
    if (!_emergencyController.isClosed) {
      _emergencyController.close();
    }
  }

  // Private helper methods
  Future<void> _loadActiveSessions() async {
    // Load active sessions from cache or API
    final activeSessions = _sessionsCache.values
        .where((s) => s.status == TelemedicineSessionStatus.active)
        .toList();
    
    for (final session in activeSessions) {
      _activeSessions[session.id] = session;
    }
  }

  Future<void> _startMonitoringServices() async {
    // Start monitoring for active sessions
    for (final session in _activeSessions.values) {
      _startSessionMonitoring(session.id);
    }
  }

  void _startSessionMonitoring(String sessionId) {
    // Start video quality monitoring
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_activeSessions.containsKey(sessionId)) {
        timer.cancel();
        return;
      }
      _collectVideoQualityMetrics(sessionId);
    });
  }

  void _stopSessionMonitoring(String sessionId) {
    // Stop monitoring for session
    // This is handled by the timer cancellation in _startSessionMonitoring
  }

  void _stopPatientMonitoring(String patientId) {
    // Stop monitoring for specific patient
    final timer = _monitoringTimers[patientId];
    if (timer != null) {
      timer.cancel();
      _monitoringTimers.remove(patientId);
    }
  }

  void _collectVideoQualityMetrics(String sessionId) {
    // Simulate video quality metrics collection
    final metrics = VideoCallMetrics(
      id: 'metrics_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      videoBitrate: 2000.0 + Random().nextDouble() * 1000,
      audioBitrate: 128.0 + Random().nextDouble() * 64,
      frameRate: 25 + Random().nextInt(5),
      packetLoss: Random().nextDouble() * 2,
      latency: 50.0 + Random().nextDouble() * 100,
      jitter: Random().nextDouble() * 10,
      currentQuality: VideoQualityLevel.high,
      isStable: Random().nextBool(),
      timestamp: DateTime.now(),
      technicalDetails: {
        'codec': 'H.264',
        'resolution': '1920x1080',
        'bandwidth': '5 Mbps',
      },
    );

    _qualityController.add(metrics);
  }

  void _collectMonitoringData(String patientId, String sessionId) {
    // Simulate patient monitoring data collection
    final monitoringData = PatientMonitoringData(
      id: 'monitoring_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      sessionId: sessionId,
      timestamp: DateTime.now(),
      heartRate: 70.0 + Random().nextDouble() * 20,
      bloodPressure: 120.0 + Random().nextDouble() * 20,
      temperature: 36.5 + Random().nextDouble() * 2,
      oxygenSaturation: 95.0 + Random().nextDouble() * 5,
      mood: _getRandomMood(),
      anxietyLevel: _getRandomAnxietyLevel(),
      depressionLevel: _getRandomDepressionLevel(),
      sleepQuality: _getRandomSleepQuality(),
      stressLevel: _getRandomStressLevel(),
      biometricData: {
        'heart_rate_variability': 45.2,
        'respiratory_rate': 16.0,
        'blood_glucose': 95.0,
      },
      behavioralData: {
        'eye_contact': Random().nextBool(),
        'speech_rate': 'normal',
        'body_language': 'open',
      },
      blockchainHash: '0x${_generateRandomHash()}',
      createdAt: DateTime.now(),
    );

    _monitoringCache[monitoringData.id] = monitoringData;
    _monitoringController.add(monitoringData);
  }

  Map<String, dynamic> _getDefaultTechnicalSettings() {
    return {
      'default_video_quality': VideoQualityLevel.high.name,
      'enable_adaptive_quality': true,
      'enable_noise_cancellation': true,
      'enable_echo_cancellation': true,
      'enable_background_blur': true,
      'enable_virtual_background': false,
      'enable_screen_sharing': true,
      'enable_recording': false,
      'enable_chat': true,
      'enable_file_sharing': true,
      'advanced_settings': {
        'max_bandwidth': '10 Mbps',
        'audio_codec': 'Opus',
        'video_codec': 'H.264',
        'encryption': 'AES-256',
      },
    };
  }

  Map<String, dynamic> _getDefaultQueueSettings() {
    return {
      'max_wait_time': 30, // minutes
      'priority_emergency': true,
      'auto_reorder': true,
      'notifications': true,
      'estimated_wait_display': true,
    };
  }

  String _getRandomMood() {
    final moods = ['calm', 'anxious', 'depressed', 'manic', 'stable', 'irritable'];
    return moods[Random().nextInt(moods.length)];
  }

  String _getRandomAnxietyLevel() {
    final levels = ['none', 'mild', 'moderate', 'severe', 'panic'];
    return levels[Random().nextInt(levels.length)];
  }

  String _getRandomDepressionLevel() {
    final levels = ['none', 'mild', 'moderate', 'severe', 'extreme'];
    return levels[Random().nextInt(levels.length)];
  }

  String _getRandomSleepQuality() {
    final qualities = ['excellent', 'good', 'fair', 'poor', 'very_poor'];
    return qualities[Random().nextInt(qualities.length)];
  }

  String _getRandomStressLevel() {
    final levels = ['none', 'low', 'moderate', 'high', 'extreme'];
    return levels[Random().nextInt(levels.length)];
  }

  String _generateRandomHash() {
    final random = Random();
    final chars = '0123456789abcdef';
    return List.generate(64, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
