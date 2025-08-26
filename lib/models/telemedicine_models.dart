import 'package:json_annotation/json_annotation.dart';

part 'telemedicine_models.g.dart';

/// Telemedicine Session Status
enum TelemedicineSessionStatus {
  @JsonValue('scheduled') scheduled,
  @JsonValue('waiting') waiting,
  @JsonValue('active') active,
  @JsonValue('paused') paused,
  @JsonValue('completed') completed,
  @JsonValue('cancelled') cancelled,
  @JsonValue('no_show') noShow,
  @JsonValue('emergency') emergency,
}

/// Video Quality Level
enum VideoQualityLevel {
  @JsonValue('low') low,        // 480p
  @JsonValue('medium') medium,  // 720p
  @JsonValue('high') high,      // 1080p
  @JsonValue('ultra') ultra,    // 4K
  @JsonValue('adaptive') adaptive, // AI-powered adaptive
}

/// Session Type
enum SessionType {
  @JsonValue('initial_consultation') initialConsultation,
  @JsonValue('follow_up') followUp,
  @JsonValue('crisis_intervention') crisisIntervention,
  @JsonValue('group_therapy') groupTherapy,
  @JsonValue('family_therapy') familyTherapy,
  @JsonValue('medication_review') medicationReview,
  @JsonValue('emergency_evaluation') emergencyEvaluation,
  @JsonValue('assessment') assessment,
}

/// Emergency Level
enum EmergencyLevel {
  @JsonValue('none') none,
  @JsonValue('low') low,
  @JsonValue('medium') medium,
  @JsonValue('high') high,
  @JsonValue('critical') critical,
}

/// Telemedicine Session
@JsonSerializable()
class TelemedicineSession {
  final String id;
  final String patientId;
  final String patientName;
  final String therapistId;
  final String therapistName;
  final SessionType sessionType;
  final TelemedicineSessionStatus status;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final int duration; // in minutes
  final VideoQualityLevel videoQuality;
  final EmergencyLevel emergencyLevel;
  final String? meetingUrl;
  final String? meetingId;
  final String? meetingPassword;
  final Map<String, dynamic> sessionNotes;
  final List<String> participants;
  final Map<String, dynamic> technicalSettings;
  final String? recordingUrl;
  final bool isRecorded;
  final bool isEncrypted;
  final String blockchainHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const TelemedicineSession({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.therapistId,
    required this.therapistName,
    required this.sessionType,
    required this.status,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    required this.duration,
    required this.videoQuality,
    required this.emergencyLevel,
    this.meetingUrl,
    this.meetingId,
    this.meetingPassword,
    required this.sessionNotes,
    required this.participants,
    required this.technicalSettings,
    this.recordingUrl,
    required this.isRecorded,
    required this.isEncrypted,
    required this.blockchainHash,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory TelemedicineSession.fromJson(Map<String, dynamic> json) =>
      _$TelemedicineSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TelemedicineSessionToJson(this);
}

/// Virtual Waiting Room
@JsonSerializable()
class VirtualWaitingRoom {
  final String id;
  final String sessionId;
  final List<WaitingPatient> patients;
  final int currentPosition;
  final DateTime estimatedStartTime;
  final String status; // 'active', 'paused', 'closed'
  final Map<String, dynamic> queueSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VirtualWaitingRoom({
    required this.id,
    required this.sessionId,
    required this.patients,
    required this.currentPosition,
    required this.estimatedStartTime,
    required this.status,
    required this.queueSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VirtualWaitingRoom.fromJson(Map<String, dynamic> json) =>
      _$VirtualWaitingRoomFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualWaitingRoomToJson(this);
}

/// Waiting Patient
@JsonSerializable()
class WaitingPatient {
  final String id;
  final String patientId;
  final String patientName;
  final int position;
  final DateTime checkInTime;
  final DateTime estimatedWaitTime;
  final EmergencyLevel emergencyLevel;
  final String? notes;
  final bool isReady;
  final Map<String, dynamic> metadata;

  const WaitingPatient({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.position,
    required this.checkInTime,
    required this.estimatedWaitTime,
    required this.emergencyLevel,
    this.notes,
    required this.isReady,
    required this.metadata,
  });

  factory WaitingPatient.fromJson(Map<String, dynamic> json) =>
      _$WaitingPatientFromJson(json);

  Map<String, dynamic> toJson() => _$WaitingPatientToJson(this);
}

/// Video Call Quality Metrics
@JsonSerializable()
class VideoCallMetrics {
  final String id;
  final String sessionId;
  final double videoBitrate;
  final double audioBitrate;
  final int frameRate;
  final double packetLoss;
  final double latency;
  final double jitter;
  final VideoQualityLevel currentQuality;
  final bool isStable;
  final DateTime timestamp;
  final Map<String, dynamic> technicalDetails;

  const VideoCallMetrics({
    required this.id,
    required this.sessionId,
    required this.videoBitrate,
    required this.audioBitrate,
    required this.frameRate,
    required this.packetLoss,
    required this.latency,
    required this.jitter,
    required this.currentQuality,
    required this.isStable,
    required this.timestamp,
    required this.technicalDetails,
  });

  factory VideoCallMetrics.fromJson(Map<String, dynamic> json) =>
      _$VideoCallMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCallMetricsToJson(this);
}

/// E-Consultation
@JsonSerializable()
class EConsultation {
  final String id;
  final String patientId;
  final String patientName;
  final String therapistId;
  final String therapistName;
  final String consultationType;
  final String symptoms;
  final String medicalHistory;
  final List<String> currentMedications;
  final String assessment;
  final String recommendations;
  final List<String> prescribedMedications;
  final String followUpInstructions;
  final DateTime consultationDate;
  final int duration; // in minutes
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final String blockchainHash;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const EConsultation({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.therapistId,
    required this.therapistName,
    required this.consultationType,
    required this.symptoms,
    required this.medicalHistory,
    required this.currentMedications,
    required this.assessment,
    required this.recommendations,
    required this.prescribedMedications,
    required this.followUpInstructions,
    required this.consultationDate,
    required this.duration,
    required this.requiresFollowUp,
    this.followUpDate,
    required this.blockchainHash,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory EConsultation.fromJson(Map<String, dynamic> json) =>
      _$EConsultationFromJson(json);

  Map<String, dynamic> toJson() => _$EConsultationToJson(this);
}

/// Remote Prescription
@JsonSerializable()
class RemotePrescription {
  final String id;
  final String patientId;
  final String patientName;
  final String therapistId;
  final String therapistName;
  final String prescriptionType;
  final List<PrescribedMedication> medications;
  final String diagnosis;
  final String instructions;
  final DateTime prescriptionDate;
  final DateTime expiryDate;
  final int refills;
  final bool isControlled;
  final String blockchainHash;
  final bool isVerified;
  final String status; // 'active', 'expired', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const RemotePrescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.therapistId,
    required this.therapistName,
    required this.prescriptionType,
    required this.medications,
    required this.diagnosis,
    required this.instructions,
    required this.prescriptionDate,
    required this.expiryDate,
    required this.refills,
    required this.isControlled,
    required this.blockchainHash,
    required this.isVerified,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory RemotePrescription.fromJson(Map<String, dynamic> json) =>
      _$RemotePrescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$RemotePrescriptionToJson(this);
}

/// Prescribed Medication
@JsonSerializable()
class PrescribedMedication {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String route;
  final int quantity;
  final String instructions;
  final String warnings;
  final bool isControlled;
  final DateTime startDate;
  final DateTime? endDate;
  final int refills;
  final Map<String, dynamic> metadata;

  const PrescribedMedication({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.quantity,
    required this.instructions,
    required this.warnings,
    required this.isControlled,
    required this.startDate,
    this.endDate,
    required this.refills,
    required this.metadata,
  });

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) =>
      _$PrescribedMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$PrescribedMedicationToJson(this);
}

/// Patient Monitoring Data
@JsonSerializable()
class PatientMonitoringData {
  final String id;
  final String patientId;
  final String sessionId;
  final DateTime timestamp;
  final double? heartRate;
  final double? bloodPressure;
  final double? temperature;
  final double? oxygenSaturation;
  final String? mood;
  final String? anxietyLevel;
  final String? depressionLevel;
  final String? sleepQuality;
  final String? stressLevel;
  final Map<String, dynamic> biometricData;
  final Map<String, dynamic> behavioralData;
  final String blockchainHash;
  final DateTime createdAt;

  const PatientMonitoringData({
    required this.id,
    required this.patientId,
    required this.sessionId,
    required this.timestamp,
    this.heartRate,
    this.bloodPressure,
    this.temperature,
    this.oxygenSaturation,
    this.mood,
    this.anxietyLevel,
    this.depressionLevel,
    this.sleepQuality,
    this.stressLevel,
    required this.biometricData,
    required this.behavioralData,
    required this.blockchainHash,
    required this.createdAt,
  });

  factory PatientMonitoringData.fromJson(Map<String, dynamic> json) =>
      _$PatientMonitoringDataFromJson(json);

  Map<String, dynamic> toJson() => _$PatientMonitoringDataToJson(this);
}

/// Emergency Protocol
@JsonSerializable()
class EmergencyProtocol {
  final String id;
  final String sessionId;
  final String patientId;
  final EmergencyLevel emergencyLevel;
  final String emergencyType;
  final String description;
  final List<String> immediateActions;
  final List<String> emergencyContacts;
  final String nearestHospital;
  final String hospitalAddress;
  final String hospitalPhone;
  final bool emergencyServicesCalled;
  final DateTime emergencyStartTime;
  final DateTime? emergencyEndTime;
  final String status; // 'active', 'resolved', 'escalated'
  final String blockchainHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const EmergencyProtocol({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.emergencyLevel,
    required this.emergencyType,
    required this.description,
    required this.immediateActions,
    required this.emergencyContacts,
    required this.nearestHospital,
    required this.hospitalAddress,
    required this.hospitalPhone,
    required this.emergencyServicesCalled,
    required this.emergencyStartTime,
    this.emergencyEndTime,
    required this.status,
    required this.blockchainHash,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory EmergencyProtocol.fromJson(Map<String, dynamic> json) =>
      _$EmergencyProtocolFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyProtocolToJson(this);
}

/// Telemedicine Analytics
@JsonSerializable()
class TelemedicineAnalytics {
  final String id;
  final DateTime date;
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final int noShowSessions;
  final double averageSessionDuration;
  final double averageWaitTime;
  final double patientSatisfactionScore;
  final double technicalIssueRate;
  final Map<String, int> sessionTypeDistribution;
  final Map<String, int> emergencyLevelDistribution;
  final Map<String, double> qualityMetrics;
  final Map<String, dynamic> performanceData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TelemedicineAnalytics({
    required this.id,
    required this.date,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.noShowSessions,
    required this.averageSessionDuration,
    required this.averageWaitTime,
    required this.patientSatisfactionScore,
    required this.technicalIssueRate,
    required this.sessionTypeDistribution,
    required this.emergencyLevelDistribution,
    required this.qualityMetrics,
    required this.performanceData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TelemedicineAnalytics.fromJson(Map<String, dynamic> json) =>
      _$TelemedicineAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$TelemedicineAnalyticsToJson(this);
}

/// Technical Settings
@JsonSerializable()
class TechnicalSettings {
  final String id;
  final String sessionId;
  final VideoQualityLevel defaultVideoQuality;
  final bool enableAdaptiveQuality;
  final bool enableNoiseCancellation;
  final bool enableEchoCancellation;
  final bool enableBackgroundBlur;
  final bool enableVirtualBackground;
  final bool enableScreenSharing;
  final bool enableRecording;
  final bool enableChat;
  final bool enableFileSharing;
  final Map<String, dynamic> advancedSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TechnicalSettings({
    required this.id,
    required this.sessionId,
    required this.defaultVideoQuality,
    required this.enableAdaptiveQuality,
    required this.enableNoiseCancellation,
    required this.enableEchoCancellation,
    required this.enableBackgroundBlur,
    required this.enableVirtualBackground,
    required this.enableScreenSharing,
    required this.enableRecording,
    required this.enableChat,
    required this.enableFileSharing,
    required this.advancedSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TechnicalSettings.fromJson(Map<String, dynamic> json) =>
      _$TechnicalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TechnicalSettingsToJson(this);
}
