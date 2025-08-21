import 'package:json_annotation/json_annotation.dart';

part 'telehealth_models.g.dart';

// === TELEHEALTH CORE MODELS ===

@JsonSerializable()
class TelehealthSession {
  final String id;
  final String sessionId;
  final String clientId;
  final String therapistId;
  final TelehealthSessionType type;
  final TelehealthSessionStatus status;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationMinutes;
  final String? meetingUrl;
  final String? meetingId;
  final String? meetingPassword;
  final TelehealthPlatform platform;
  final TelehealthQualitySettings qualitySettings;
  final List<TelehealthParticipant> participants;
  final TelehealthRecordingSettings recordingSettings;
  final List<TelehealthNote> notes;
  final TelehealthCompliance compliance;
  final DateTime createdAt;
  final DateTime updatedAt;

  TelehealthSession({
    required this.id,
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
    required this.type,
    required this.status,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.durationMinutes,
    this.meetingUrl,
    this.meetingId,
    this.meetingPassword,
    required this.platform,
    required this.qualitySettings,
    required this.participants,
    required this.recordingSettings,
    required this.notes,
    required this.compliance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TelehealthSession.fromJson(Map<String, dynamic> json) => _$TelehealthSessionFromJson(json);
  Map<String, dynamic> toJson() => _$TelehealthSessionToJson(this);

  TelehealthSession copyWith({
    String? id,
    String? sessionId,
    String? clientId,
    String? therapistId,
    TelehealthSessionType? type,
    TelehealthSessionStatus? status,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    String? meetingUrl,
    String? meetingId,
    String? meetingPassword,
    TelehealthPlatform? platform,
    TelehealthQualitySettings? qualitySettings,
    List<TelehealthParticipant>? participants,
    TelehealthRecordingSettings? recordingSettings,
    List<TelehealthNote>? notes,
    TelehealthCompliance? compliance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TelehealthSession(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      meetingId: meetingId ?? this.meetingId,
      meetingPassword: meetingPassword ?? this.meetingPassword,
      platform: platform ?? this.platform,
      qualitySettings: qualitySettings ?? this.qualitySettings,
      participants: participants ?? this.participants,
      recordingSettings: recordingSettings ?? this.recordingSettings,
      notes: notes ?? this.notes,
      compliance: compliance ?? this.compliance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class TelehealthParticipant {
  final String id;
  final String userId;
  final String name;
  final String email;
  final ParticipantRole role;
  final ParticipantStatus status;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String? deviceInfo;
  final String? ipAddress;
  final String? location;
  final bool isRecording;
  final bool isScreenSharing;
  final List<ParticipantAction> actions;

  TelehealthParticipant({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.leftAt,
    this.deviceInfo,
    this.ipAddress,
    this.location,
    required this.isRecording,
    required this.isScreenSharing,
    required this.actions,
  });

  factory TelehealthParticipant.fromJson(Map<String, dynamic> json) => _$TelehealthParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$TelehealthParticipantToJson(this);
}

@JsonSerializable()
class TelehealthQualitySettings {
  final VideoQuality videoQuality;
  final AudioQuality audioQuality;
  final int maxBitrate;
  final bool enableHD;
  final bool enableNoiseSuppression;
  final bool enableEchoCancellation;
  final bool enableAutoGainControl;
  final int frameRate;
  final String resolution;

  TelehealthQualitySettings({
    required this.videoQuality,
    required this.audioQuality,
    required this.maxBitrate,
    required this.enableHD,
    required this.enableNoiseSuppression,
    required this.enableEchoCancellation,
    required this.enableAutoGainControl,
    required this.frameRate,
    required this.resolution,
  });

  factory TelehealthQualitySettings.fromJson(Map<String, dynamic> json) => _$TelehealthQualitySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$TelehealthQualitySettingsToJson(this);
}

@JsonSerializable()
class TelehealthRecordingSettings {
  final bool isRecordingEnabled;
  final RecordingType recordingType;
  final RecordingQuality recordingQuality;
  final bool enableTranscription;
  final bool enableTranslation;
  final List<String> allowedLanguages;
  final int retentionDays;
  final bool enableWatermark;
  final String watermarkText;

  TelehealthRecordingSettings({
    required this.isRecordingEnabled,
    required this.recordingType,
    required this.recordingQuality,
    required this.enableTranscription,
    required this.enableTranslation,
    required this.allowedLanguages,
    required this.retentionDays,
    required this.enableWatermark,
    required this.watermarkText,
  });

  factory TelehealthRecordingSettings.fromJson(Map<String, dynamic> json) => _$TelehealthRecordingSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$TelehealthRecordingSettingsToJson(this);
}

@JsonSerializable()
class TelehealthNote {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final NoteType type;
  final List<String> tags;
  final bool isPrivate;

  TelehealthNote({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.tags,
    required this.isPrivate,
  });

  factory TelehealthNote.fromJson(Map<String, dynamic> json) => _$TelehealthNoteFromJson(json);
  Map<String, dynamic> toJson() => _$TelehealthNoteToJson(this);
}

@JsonSerializable()
class TelehealthCompliance {
  final bool hipaaCompliant;
  final bool gdprCompliant;
  final bool kvkkCompliant;
  final bool pipedaCompliant;
  final List<String> complianceCertificates;
  final DateTime lastAuditDate;
  final String auditResult;
  final List<ComplianceViolation> violations;
  final DataRetentionPolicy dataRetention;
  final EncryptionSettings encryption;

  TelehealthCompliance({
    required this.hipaaCompliant,
    required this.gdprCompliant,
    required this.kvkkCompliant,
    required this.pipedaCompliant,
    required this.complianceCertificates,
    required this.lastAuditDate,
    required this.auditResult,
    required this.violations,
    required this.dataRetention,
    required this.encryption,
  });

  factory TelehealthCompliance.fromJson(Map<String, dynamic> json) => _$TelehealthComplianceFromJson(json);
  Map<String, dynamic> toJson() => _$TelehealthComplianceToJson(this);
}

// === REMOTE MONITORING MODELS ===

@JsonSerializable()
class RemoteMonitoringDevice {
  final String id;
  final String deviceType;
  final String deviceId;
  final String patientId;
  final DeviceStatus status;
  final DateTime lastSync;
  final Map<String, dynamic> deviceData;
  final List<BiometricReading> readings;
  final DeviceCalibration calibration;
  final List<DeviceAlert> alerts;

  RemoteMonitoringDevice({
    required this.id,
    required this.deviceType,
    required this.deviceId,
    required this.patientId,
    required this.status,
    required this.lastSync,
    required this.deviceData,
    required this.readings,
    required this.calibration,
    required this.alerts,
  });

  factory RemoteMonitoringDevice.fromJson(Map<String, dynamic> json) => _$RemoteMonitoringDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$RemoteMonitoringDeviceToJson(this);

  RemoteMonitoringDevice copyWith({
    String? id,
    String? deviceType,
    String? deviceId,
    String? patientId,
    DeviceStatus? status,
    DateTime? lastSync,
    Map<String, dynamic>? deviceData,
    List<BiometricReading>? readings,
    DeviceCalibration? calibration,
    List<DeviceAlert>? alerts,
  }) {
    return RemoteMonitoringDevice(
      id: id ?? this.id,
      deviceType: deviceType ?? this.deviceType,
      deviceId: deviceId ?? this.deviceId,
      patientId: patientId ?? this.patientId,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      deviceData: deviceData ?? this.deviceData,
      readings: readings ?? this.readings,
      calibration: calibration ?? this.calibration,
      alerts: alerts ?? this.alerts,
    );
  }
}

@JsonSerializable()
class BiometricReading {
  final String id;
  final String deviceId;
  final String patientId;
  final BiometricType type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final ReadingQuality quality;
  final Map<String, dynamic> metadata;
  final List<String> flags;

  BiometricReading({
    required this.id,
    required this.deviceId,
    required this.patientId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.quality,
    required this.metadata,
    required this.flags,
  });

  factory BiometricReading.fromJson(Map<String, dynamic> json) => _$BiometricReadingFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricReadingToJson(this);
}

// === DIGITAL THERAPEUTICS MODELS ===

@JsonSerializable()
class DigitalTherapeutic {
  final String id;
  final String name;
  final String description;
  final TherapeuticType type;
  final List<String> indications;
  final List<String> contraindications;
  final String manufacturer;
  final String? fdaApprovalNumber;
  final String? ceMarkNumber;
  final DateTime? approvalDate;
  final List<String> supportedRegions;
  final TherapeuticProtocol protocol;
  final List<TherapeuticOutcome> outcomes;
  final PricingInfo pricing;

  DigitalTherapeutic({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.indications,
    required this.contraindications,
    required this.manufacturer,
    this.fdaApprovalNumber,
    this.ceMarkNumber,
    this.approvalDate,
    required this.supportedRegions,
    required this.protocol,
    required this.outcomes,
    required this.pricing,
  });

  factory DigitalTherapeutic.fromJson(Map<String, dynamic> json) => _$DigitalTherapeuticFromJson(json);
  Map<String, dynamic> toJson() => _$DigitalTherapeuticToJson(this);
}

@JsonSerializable()
class TherapeuticProtocol {
  final String id;
  final String name;
  final int durationWeeks;
  final int sessionsPerWeek;
  final int sessionDurationMinutes;
  final List<ProtocolStep> steps;
  final List<String> requiredDevices;
  final List<String> optionalDevices;
  final Map<String, dynamic> parameters;

  TherapeuticProtocol({
    required this.id,
    required this.name,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    required this.sessionDurationMinutes,
    required this.steps,
    required this.requiredDevices,
    required this.optionalDevices,
    required this.parameters,
  });

  factory TherapeuticProtocol.fromJson(Map<String, dynamic> json) => _$TherapeuticProtocolFromJson(json);
  Map<String, dynamic> toJson() => _$TherapeuticProtocolToJson(this);
}

// === ENUMS ===

enum TelehealthSessionType {
  @JsonValue('initial_consultation')
  initialConsultation,
  @JsonValue('follow_up')
  followUp,
  @JsonValue('crisis_intervention')
  crisisIntervention,
  @JsonValue('group_therapy')
  groupTherapy,
  @JsonValue('family_therapy')
  familyTherapy,
  @JsonValue('medication_management')
  medicationManagement,
}

enum TelehealthSessionStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
  @JsonValue('rescheduled')
  rescheduled,
}

enum TelehealthPlatform {
  @JsonValue('zoom')
  zoom,
  @JsonValue('teams')
  teams,
  @JsonValue('webex')
  webex,
  @JsonValue('custom')
  custom,
  @JsonValue('integrated')
  integrated,
}

enum ParticipantRole {
  @JsonValue('therapist')
  therapist,
  @JsonValue('client')
  client,
  @JsonValue('supervisor')
  supervisor,
  @JsonValue('family_member')
  familyMember,
  @JsonValue('interpreter')
  interpreter,
  @JsonValue('observer')
  observer,
}

enum ParticipantStatus {
  @JsonValue('invited')
  invited,
  @JsonValue('joined')
  joined,
  @JsonValue('left')
  left,
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('reconnected')
  reconnected,
}

enum VideoQuality {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('ultra_hd')
  ultraHd,
}

enum AudioQuality {
  @JsonValue('standard')
  standard,
  @JsonValue('high')
  high,
  @JsonValue('ultra_high')
  ultraHigh,
}

enum RecordingType {
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('screen')
  screen,
  @JsonValue('combined')
  combined,
}

enum RecordingQuality {
  @JsonValue('standard')
  standard,
  @JsonValue('high')
  high,
  @JsonValue('professional')
  professional,
}

enum NoteType {
  @JsonValue('clinical')
  clinical,
  @JsonValue('technical')
  technical,
  @JsonValue('observation')
  observation,
  @JsonValue('intervention')
  intervention,
}

enum DeviceStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('error')
  error,
}

enum BiometricType {
  @JsonValue('heart_rate')
  heartRate,
  @JsonValue('blood_pressure')
  bloodPressure,
  @JsonValue('temperature')
  temperature,
  @JsonValue('oxygen_saturation')
  oxygenSaturation,
  @JsonValue('sleep_quality')
  sleepQuality,
  @JsonValue('activity_level')
  activityLevel,
  @JsonValue('mood')
  mood,
  @JsonValue('stress_level')
  stressLevel,
}

enum ReadingQuality {
  @JsonValue('excellent')
  excellent,
  @JsonValue('good')
  good,
  @JsonValue('fair')
  fair,
  @JsonValue('poor')
  poor,
  @JsonValue('invalid')
  invalid,
}

enum TherapeuticType {
  @JsonValue('cognitive_behavioral')
  cognitiveBehavioral,
  @JsonValue('mindfulness')
  mindfulness,
  @JsonValue('biofeedback')
  biofeedback,
  @JsonValue('exposure_therapy')
  exposureTherapy,
  @JsonValue('relaxation')
  relaxation,
  @JsonValue('cognitive_training')
  cognitiveTraining,
}

// === SUPPORTING MODELS ===

@JsonSerializable()
class ParticipantAction {
  final String id;
  final String actionType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ParticipantAction({
    required this.id,
    required this.actionType,
    required this.timestamp,
    required this.metadata,
  });

  factory ParticipantAction.fromJson(Map<String, dynamic> json) => _$ParticipantActionFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantActionToJson(this);
}

@JsonSerializable()
class DeviceCalibration {
  final DateTime lastCalibrated;
  final String calibratedBy;
  final Map<String, dynamic> calibrationData;
  final DateTime nextCalibrationDue;

  DeviceCalibration({
    required this.lastCalibrated,
    required this.calibratedBy,
    required this.calibrationData,
    required this.nextCalibrationDue,
  });

  factory DeviceCalibration.fromJson(Map<String, dynamic> json) => _$DeviceCalibrationFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceCalibrationToJson(this);
}

@JsonSerializable()
class DeviceAlert {
  final String id;
  final String alertType;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  DeviceAlert({
    required this.id,
    required this.alertType,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.isAcknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  factory DeviceAlert.fromJson(Map<String, dynamic> json) => _$DeviceAlertFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceAlertToJson(this);
}

@JsonSerializable()
class ProtocolStep {
  final String id;
  final String name;
  final String description;
  final int order;
  final int durationMinutes;
  final List<String> instructions;
  final Map<String, dynamic> parameters;

  ProtocolStep({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.durationMinutes,
    required this.instructions,
    required this.parameters,
  });

  factory ProtocolStep.fromJson(Map<String, dynamic> json) => _$ProtocolStepFromJson(json);
  Map<String, dynamic> toJson() => _$ProtocolStepToJson(this);
}

@JsonSerializable()
class TherapeuticOutcome {
  final String id;
  final String outcomeType;
  final String description;
  final String measurement;
  final double baselineValue;
  final double targetValue;
  final String unit;

  TherapeuticOutcome({
    required this.id,
    required this.outcomeType,
    required this.description,
    required this.measurement,
    required this.baselineValue,
    required this.targetValue,
    required this.unit,
  });

  factory TherapeuticOutcome.fromJson(Map<String, dynamic> json) => _$TherapeuticOutcomeFromJson(json);
  Map<String, dynamic> toJson() => _$TherapeuticOutcomeToJson(this);
}

@JsonSerializable()
class PricingInfo {
  final double price;
  final String currency;
  final BillingFrequency frequency;
  final List<String> includedFeatures;
  final Map<String, double> additionalCosts;

  PricingInfo({
    required this.price,
    required this.currency,
    required this.frequency,
    required this.includedFeatures,
    required this.additionalCosts,
  });

  factory PricingInfo.fromJson(Map<String, dynamic> json) => _$PricingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PricingInfoToJson(this);
}

@JsonSerializable()
class ComplianceViolation {
  final String id;
  final String violationType;
  final String description;
  final DateTime detectedAt;
  final ViolationSeverity severity;
  final String? resolution;
  final DateTime? resolvedAt;

  ComplianceViolation({
    required this.id,
    required this.violationType,
    required this.description,
    required this.detectedAt,
    required this.severity,
    this.resolution,
    this.resolvedAt,
  });

  factory ComplianceViolation.fromJson(Map<String, dynamic> json) => _$ComplianceViolationFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceViolationToJson(this);
}

@JsonSerializable()
class DataRetentionPolicy {
  final int sessionRecordingsDays;
  final int chatLogsDays;
  final int biometricDataDays;
  final int auditLogsDays;
  final bool enableAutoDeletion;
  final List<String> exceptions;

  DataRetentionPolicy({
    required this.sessionRecordingsDays,
    required this.chatLogsDays,
    required this.biometricDataDays,
    required this.auditLogsDays,
    required this.enableAutoDeletion,
    required this.exceptions,
  });

  factory DataRetentionPolicy.fromJson(Map<String, dynamic> json) => _$DataRetentionPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$DataRetentionPolicyToJson(this);
}

@JsonSerializable()
class EncryptionSettings {
  final String algorithm;
  final int keySize;
  final bool enableEndToEndEncryption;
  final bool enableAtRestEncryption;
  final bool enableInTransitEncryption;
  final String keyManagement;

  EncryptionSettings({
    required this.algorithm,
    required this.keySize,
    required this.enableEndToEndEncryption,
    required this.enableAtRestEncryption,
    required this.enableInTransitEncryption,
    required this.keyManagement,
  });

  factory EncryptionSettings.fromJson(Map<String, dynamic> json) => _$EncryptionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$EncryptionSettingsToJson(this);
}

enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum ViolationSeverity {
  @JsonValue('minor')
  minor,
  @JsonValue('moderate')
  moderate,
  @JsonValue('major')
  major,
  @JsonValue('critical')
  critical,
}

enum BillingFrequency {
  @JsonValue('one_time')
  oneTime,
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('annually')
  annually,
}
