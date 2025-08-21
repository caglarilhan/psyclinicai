// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telehealth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelehealthSession _$TelehealthSessionFromJson(Map<String, dynamic> json) =>
    TelehealthSession(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      type: $enumDecode(_$TelehealthSessionTypeEnumMap, json['type']),
      status: $enumDecode(_$TelehealthSessionStatusEnumMap, json['status']),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      meetingUrl: json['meetingUrl'] as String?,
      meetingId: json['meetingId'] as String?,
      meetingPassword: json['meetingPassword'] as String?,
      platform: $enumDecode(_$TelehealthPlatformEnumMap, json['platform']),
      qualitySettings: TelehealthQualitySettings.fromJson(
        json['qualitySettings'] as Map<String, dynamic>,
      ),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => TelehealthParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      recordingSettings: TelehealthRecordingSettings.fromJson(
        json['recordingSettings'] as Map<String, dynamic>,
      ),
      notes: (json['notes'] as List<dynamic>)
          .map((e) => TelehealthNote.fromJson(e as Map<String, dynamic>))
          .toList(),
      compliance: TelehealthCompliance.fromJson(
        json['compliance'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TelehealthSessionToJson(TelehealthSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'type': _$TelehealthSessionTypeEnumMap[instance.type]!,
      'status': _$TelehealthSessionStatusEnumMap[instance.status]!,
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'meetingUrl': instance.meetingUrl,
      'meetingId': instance.meetingId,
      'meetingPassword': instance.meetingPassword,
      'platform': _$TelehealthPlatformEnumMap[instance.platform]!,
      'qualitySettings': instance.qualitySettings,
      'participants': instance.participants,
      'recordingSettings': instance.recordingSettings,
      'notes': instance.notes,
      'compliance': instance.compliance,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TelehealthSessionTypeEnumMap = {
  TelehealthSessionType.initialConsultation: 'initial_consultation',
  TelehealthSessionType.followUp: 'follow_up',
  TelehealthSessionType.crisisIntervention: 'crisis_intervention',
  TelehealthSessionType.groupTherapy: 'group_therapy',
  TelehealthSessionType.familyTherapy: 'family_therapy',
  TelehealthSessionType.medicationManagement: 'medication_management',
};

const _$TelehealthSessionStatusEnumMap = {
  TelehealthSessionStatus.scheduled: 'scheduled',
  TelehealthSessionStatus.inProgress: 'in_progress',
  TelehealthSessionStatus.completed: 'completed',
  TelehealthSessionStatus.cancelled: 'cancelled',
  TelehealthSessionStatus.noShow: 'no_show',
  TelehealthSessionStatus.rescheduled: 'rescheduled',
};

const _$TelehealthPlatformEnumMap = {
  TelehealthPlatform.zoom: 'zoom',
  TelehealthPlatform.teams: 'teams',
  TelehealthPlatform.webex: 'webex',
  TelehealthPlatform.custom: 'custom',
  TelehealthPlatform.integrated: 'integrated',
};

TelehealthParticipant _$TelehealthParticipantFromJson(
  Map<String, dynamic> json,
) => TelehealthParticipant(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$ParticipantRoleEnumMap, json['role']),
  status: $enumDecode(_$ParticipantStatusEnumMap, json['status']),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  leftAt: json['leftAt'] == null
      ? null
      : DateTime.parse(json['leftAt'] as String),
  deviceInfo: json['deviceInfo'] as String?,
  ipAddress: json['ipAddress'] as String?,
  location: json['location'] as String?,
  isRecording: json['isRecording'] as bool,
  isScreenSharing: json['isScreenSharing'] as bool,
  actions: (json['actions'] as List<dynamic>)
      .map((e) => ParticipantAction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TelehealthParticipantToJson(
  TelehealthParticipant instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'email': instance.email,
  'role': _$ParticipantRoleEnumMap[instance.role]!,
  'status': _$ParticipantStatusEnumMap[instance.status]!,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'leftAt': instance.leftAt?.toIso8601String(),
  'deviceInfo': instance.deviceInfo,
  'ipAddress': instance.ipAddress,
  'location': instance.location,
  'isRecording': instance.isRecording,
  'isScreenSharing': instance.isScreenSharing,
  'actions': instance.actions,
};

const _$ParticipantRoleEnumMap = {
  ParticipantRole.therapist: 'therapist',
  ParticipantRole.client: 'client',
  ParticipantRole.supervisor: 'supervisor',
  ParticipantRole.familyMember: 'family_member',
  ParticipantRole.interpreter: 'interpreter',
  ParticipantRole.observer: 'observer',
};

const _$ParticipantStatusEnumMap = {
  ParticipantStatus.invited: 'invited',
  ParticipantStatus.joined: 'joined',
  ParticipantStatus.left: 'left',
  ParticipantStatus.disconnected: 'disconnected',
  ParticipantStatus.reconnected: 'reconnected',
};

TelehealthQualitySettings _$TelehealthQualitySettingsFromJson(
  Map<String, dynamic> json,
) => TelehealthQualitySettings(
  videoQuality: $enumDecode(_$VideoQualityEnumMap, json['videoQuality']),
  audioQuality: $enumDecode(_$AudioQualityEnumMap, json['audioQuality']),
  maxBitrate: (json['maxBitrate'] as num).toInt(),
  enableHD: json['enableHD'] as bool,
  enableNoiseSuppression: json['enableNoiseSuppression'] as bool,
  enableEchoCancellation: json['enableEchoCancellation'] as bool,
  enableAutoGainControl: json['enableAutoGainControl'] as bool,
  frameRate: (json['frameRate'] as num).toInt(),
  resolution: json['resolution'] as String,
);

Map<String, dynamic> _$TelehealthQualitySettingsToJson(
  TelehealthQualitySettings instance,
) => <String, dynamic>{
  'videoQuality': _$VideoQualityEnumMap[instance.videoQuality]!,
  'audioQuality': _$AudioQualityEnumMap[instance.audioQuality]!,
  'maxBitrate': instance.maxBitrate,
  'enableHD': instance.enableHD,
  'enableNoiseSuppression': instance.enableNoiseSuppression,
  'enableEchoCancellation': instance.enableEchoCancellation,
  'enableAutoGainControl': instance.enableAutoGainControl,
  'frameRate': instance.frameRate,
  'resolution': instance.resolution,
};

const _$VideoQualityEnumMap = {
  VideoQuality.low: 'low',
  VideoQuality.medium: 'medium',
  VideoQuality.high: 'high',
  VideoQuality.ultraHd: 'ultra_hd',
};

const _$AudioQualityEnumMap = {
  AudioQuality.standard: 'standard',
  AudioQuality.high: 'high',
  AudioQuality.ultraHigh: 'ultra_high',
};

TelehealthRecordingSettings _$TelehealthRecordingSettingsFromJson(
  Map<String, dynamic> json,
) => TelehealthRecordingSettings(
  isRecordingEnabled: json['isRecordingEnabled'] as bool,
  recordingType: $enumDecode(_$RecordingTypeEnumMap, json['recordingType']),
  recordingQuality: $enumDecode(
    _$RecordingQualityEnumMap,
    json['recordingQuality'],
  ),
  enableTranscription: json['enableTranscription'] as bool,
  enableTranslation: json['enableTranslation'] as bool,
  allowedLanguages: (json['allowedLanguages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  retentionDays: (json['retentionDays'] as num).toInt(),
  enableWatermark: json['enableWatermark'] as bool,
  watermarkText: json['watermarkText'] as String,
);

Map<String, dynamic> _$TelehealthRecordingSettingsToJson(
  TelehealthRecordingSettings instance,
) => <String, dynamic>{
  'isRecordingEnabled': instance.isRecordingEnabled,
  'recordingType': _$RecordingTypeEnumMap[instance.recordingType]!,
  'recordingQuality': _$RecordingQualityEnumMap[instance.recordingQuality]!,
  'enableTranscription': instance.enableTranscription,
  'enableTranslation': instance.enableTranslation,
  'allowedLanguages': instance.allowedLanguages,
  'retentionDays': instance.retentionDays,
  'enableWatermark': instance.enableWatermark,
  'watermarkText': instance.watermarkText,
};

const _$RecordingTypeEnumMap = {
  RecordingType.video: 'video',
  RecordingType.audio: 'audio',
  RecordingType.screen: 'screen',
  RecordingType.combined: 'combined',
};

const _$RecordingQualityEnumMap = {
  RecordingQuality.standard: 'standard',
  RecordingQuality.high: 'high',
  RecordingQuality.professional: 'professional',
};

TelehealthNote _$TelehealthNoteFromJson(Map<String, dynamic> json) =>
    TelehealthNote(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$NoteTypeEnumMap, json['type']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isPrivate: json['isPrivate'] as bool,
    );

Map<String, dynamic> _$TelehealthNoteToJson(TelehealthNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$NoteTypeEnumMap[instance.type]!,
      'tags': instance.tags,
      'isPrivate': instance.isPrivate,
    };

const _$NoteTypeEnumMap = {
  NoteType.clinical: 'clinical',
  NoteType.technical: 'technical',
  NoteType.observation: 'observation',
  NoteType.intervention: 'intervention',
};

TelehealthCompliance _$TelehealthComplianceFromJson(
  Map<String, dynamic> json,
) => TelehealthCompliance(
  hipaaCompliant: json['hipaaCompliant'] as bool,
  gdprCompliant: json['gdprCompliant'] as bool,
  kvkkCompliant: json['kvkkCompliant'] as bool,
  pipedaCompliant: json['pipedaCompliant'] as bool,
  complianceCertificates: (json['complianceCertificates'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastAuditDate: DateTime.parse(json['lastAuditDate'] as String),
  auditResult: json['auditResult'] as String,
  violations: (json['violations'] as List<dynamic>)
      .map((e) => ComplianceViolation.fromJson(e as Map<String, dynamic>))
      .toList(),
  dataRetention: DataRetentionPolicy.fromJson(
    json['dataRetention'] as Map<String, dynamic>,
  ),
  encryption: EncryptionSettings.fromJson(
    json['encryption'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$TelehealthComplianceToJson(
  TelehealthCompliance instance,
) => <String, dynamic>{
  'hipaaCompliant': instance.hipaaCompliant,
  'gdprCompliant': instance.gdprCompliant,
  'kvkkCompliant': instance.kvkkCompliant,
  'pipedaCompliant': instance.pipedaCompliant,
  'complianceCertificates': instance.complianceCertificates,
  'lastAuditDate': instance.lastAuditDate.toIso8601String(),
  'auditResult': instance.auditResult,
  'violations': instance.violations,
  'dataRetention': instance.dataRetention,
  'encryption': instance.encryption,
};

RemoteMonitoringDevice _$RemoteMonitoringDeviceFromJson(
  Map<String, dynamic> json,
) => RemoteMonitoringDevice(
  id: json['id'] as String,
  deviceType: json['deviceType'] as String,
  deviceId: json['deviceId'] as String,
  patientId: json['patientId'] as String,
  status: $enumDecode(_$DeviceStatusEnumMap, json['status']),
  lastSync: DateTime.parse(json['lastSync'] as String),
  deviceData: json['deviceData'] as Map<String, dynamic>,
  readings: (json['readings'] as List<dynamic>)
      .map((e) => BiometricReading.fromJson(e as Map<String, dynamic>))
      .toList(),
  calibration: DeviceCalibration.fromJson(
    json['calibration'] as Map<String, dynamic>,
  ),
  alerts: (json['alerts'] as List<dynamic>)
      .map((e) => DeviceAlert.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RemoteMonitoringDeviceToJson(
  RemoteMonitoringDevice instance,
) => <String, dynamic>{
  'id': instance.id,
  'deviceType': instance.deviceType,
  'deviceId': instance.deviceId,
  'patientId': instance.patientId,
  'status': _$DeviceStatusEnumMap[instance.status]!,
  'lastSync': instance.lastSync.toIso8601String(),
  'deviceData': instance.deviceData,
  'readings': instance.readings,
  'calibration': instance.calibration,
  'alerts': instance.alerts,
};

const _$DeviceStatusEnumMap = {
  DeviceStatus.active: 'active',
  DeviceStatus.inactive: 'inactive',
  DeviceStatus.maintenance: 'maintenance',
  DeviceStatus.error: 'error',
};

BiometricReading _$BiometricReadingFromJson(Map<String, dynamic> json) =>
    BiometricReading(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      patientId: json['patientId'] as String,
      type: $enumDecode(_$BiometricTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      quality: $enumDecode(_$ReadingQualityEnumMap, json['quality']),
      metadata: json['metadata'] as Map<String, dynamic>,
      flags: (json['flags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BiometricReadingToJson(BiometricReading instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'patientId': instance.patientId,
      'type': _$BiometricTypeEnumMap[instance.type]!,
      'value': instance.value,
      'unit': instance.unit,
      'timestamp': instance.timestamp.toIso8601String(),
      'quality': _$ReadingQualityEnumMap[instance.quality]!,
      'metadata': instance.metadata,
      'flags': instance.flags,
    };

const _$BiometricTypeEnumMap = {
  BiometricType.heartRate: 'heart_rate',
  BiometricType.bloodPressure: 'blood_pressure',
  BiometricType.temperature: 'temperature',
  BiometricType.oxygenSaturation: 'oxygen_saturation',
  BiometricType.sleepQuality: 'sleep_quality',
  BiometricType.activityLevel: 'activity_level',
  BiometricType.mood: 'mood',
  BiometricType.stressLevel: 'stress_level',
};

const _$ReadingQualityEnumMap = {
  ReadingQuality.excellent: 'excellent',
  ReadingQuality.good: 'good',
  ReadingQuality.fair: 'fair',
  ReadingQuality.poor: 'poor',
  ReadingQuality.invalid: 'invalid',
};

DigitalTherapeutic _$DigitalTherapeuticFromJson(Map<String, dynamic> json) =>
    DigitalTherapeutic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TherapeuticTypeEnumMap, json['type']),
      indications: (json['indications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      manufacturer: json['manufacturer'] as String,
      fdaApprovalNumber: json['fdaApprovalNumber'] as String?,
      ceMarkNumber: json['ceMarkNumber'] as String?,
      approvalDate: json['approvalDate'] == null
          ? null
          : DateTime.parse(json['approvalDate'] as String),
      supportedRegions: (json['supportedRegions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      protocol: TherapeuticProtocol.fromJson(
        json['protocol'] as Map<String, dynamic>,
      ),
      outcomes: (json['outcomes'] as List<dynamic>)
          .map((e) => TherapeuticOutcome.fromJson(e as Map<String, dynamic>))
          .toList(),
      pricing: PricingInfo.fromJson(json['pricing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DigitalTherapeuticToJson(DigitalTherapeutic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$TherapeuticTypeEnumMap[instance.type]!,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'manufacturer': instance.manufacturer,
      'fdaApprovalNumber': instance.fdaApprovalNumber,
      'ceMarkNumber': instance.ceMarkNumber,
      'approvalDate': instance.approvalDate?.toIso8601String(),
      'supportedRegions': instance.supportedRegions,
      'protocol': instance.protocol,
      'outcomes': instance.outcomes,
      'pricing': instance.pricing,
    };

const _$TherapeuticTypeEnumMap = {
  TherapeuticType.cognitiveBehavioral: 'cognitive_behavioral',
  TherapeuticType.mindfulness: 'mindfulness',
  TherapeuticType.biofeedback: 'biofeedback',
  TherapeuticType.exposureTherapy: 'exposure_therapy',
  TherapeuticType.relaxation: 'relaxation',
  TherapeuticType.cognitiveTraining: 'cognitive_training',
};

TherapeuticProtocol _$TherapeuticProtocolFromJson(Map<String, dynamic> json) =>
    TherapeuticProtocol(
      id: json['id'] as String,
      name: json['name'] as String,
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      sessionsPerWeek: (json['sessionsPerWeek'] as num).toInt(),
      sessionDurationMinutes: (json['sessionDurationMinutes'] as num).toInt(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => ProtocolStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredDevices: (json['requiredDevices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      optionalDevices: (json['optionalDevices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TherapeuticProtocolToJson(
  TherapeuticProtocol instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'durationWeeks': instance.durationWeeks,
  'sessionsPerWeek': instance.sessionsPerWeek,
  'sessionDurationMinutes': instance.sessionDurationMinutes,
  'steps': instance.steps,
  'requiredDevices': instance.requiredDevices,
  'optionalDevices': instance.optionalDevices,
  'parameters': instance.parameters,
};

ParticipantAction _$ParticipantActionFromJson(Map<String, dynamic> json) =>
    ParticipantAction(
      id: json['id'] as String,
      actionType: json['actionType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ParticipantActionToJson(ParticipantAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actionType': instance.actionType,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };

DeviceCalibration _$DeviceCalibrationFromJson(Map<String, dynamic> json) =>
    DeviceCalibration(
      lastCalibrated: DateTime.parse(json['lastCalibrated'] as String),
      calibratedBy: json['calibratedBy'] as String,
      calibrationData: json['calibrationData'] as Map<String, dynamic>,
      nextCalibrationDue: DateTime.parse(json['nextCalibrationDue'] as String),
    );

Map<String, dynamic> _$DeviceCalibrationToJson(DeviceCalibration instance) =>
    <String, dynamic>{
      'lastCalibrated': instance.lastCalibrated.toIso8601String(),
      'calibratedBy': instance.calibratedBy,
      'calibrationData': instance.calibrationData,
      'nextCalibrationDue': instance.nextCalibrationDue.toIso8601String(),
    };

DeviceAlert _$DeviceAlertFromJson(Map<String, dynamic> json) => DeviceAlert(
  id: json['id'] as String,
  alertType: json['alertType'] as String,
  message: json['message'] as String,
  severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  isAcknowledged: json['isAcknowledged'] as bool,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String?,
);

Map<String, dynamic> _$DeviceAlertToJson(DeviceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertType': instance.alertType,
      'message': instance.message,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': instance.acknowledgedBy,
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

ProtocolStep _$ProtocolStepFromJson(Map<String, dynamic> json) => ProtocolStep(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  order: (json['order'] as num).toInt(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  instructions: (json['instructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  parameters: json['parameters'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ProtocolStepToJson(ProtocolStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'order': instance.order,
      'durationMinutes': instance.durationMinutes,
      'instructions': instance.instructions,
      'parameters': instance.parameters,
    };

TherapeuticOutcome _$TherapeuticOutcomeFromJson(Map<String, dynamic> json) =>
    TherapeuticOutcome(
      id: json['id'] as String,
      outcomeType: json['outcomeType'] as String,
      description: json['description'] as String,
      measurement: json['measurement'] as String,
      baselineValue: (json['baselineValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$TherapeuticOutcomeToJson(TherapeuticOutcome instance) =>
    <String, dynamic>{
      'id': instance.id,
      'outcomeType': instance.outcomeType,
      'description': instance.description,
      'measurement': instance.measurement,
      'baselineValue': instance.baselineValue,
      'targetValue': instance.targetValue,
      'unit': instance.unit,
    };

PricingInfo _$PricingInfoFromJson(Map<String, dynamic> json) => PricingInfo(
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  frequency: $enumDecode(_$BillingFrequencyEnumMap, json['frequency']),
  includedFeatures: (json['includedFeatures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  additionalCosts: (json['additionalCosts'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$PricingInfoToJson(PricingInfo instance) =>
    <String, dynamic>{
      'price': instance.price,
      'currency': instance.currency,
      'frequency': _$BillingFrequencyEnumMap[instance.frequency]!,
      'includedFeatures': instance.includedFeatures,
      'additionalCosts': instance.additionalCosts,
    };

const _$BillingFrequencyEnumMap = {
  BillingFrequency.oneTime: 'one_time',
  BillingFrequency.monthly: 'monthly',
  BillingFrequency.quarterly: 'quarterly',
  BillingFrequency.annually: 'annually',
};

ComplianceViolation _$ComplianceViolationFromJson(Map<String, dynamic> json) =>
    ComplianceViolation(
      id: json['id'] as String,
      violationType: json['violationType'] as String,
      description: json['description'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      severity: $enumDecode(_$ViolationSeverityEnumMap, json['severity']),
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$ComplianceViolationToJson(
  ComplianceViolation instance,
) => <String, dynamic>{
  'id': instance.id,
  'violationType': instance.violationType,
  'description': instance.description,
  'detectedAt': instance.detectedAt.toIso8601String(),
  'severity': _$ViolationSeverityEnumMap[instance.severity]!,
  'resolution': instance.resolution,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
};

const _$ViolationSeverityEnumMap = {
  ViolationSeverity.minor: 'minor',
  ViolationSeverity.moderate: 'moderate',
  ViolationSeverity.major: 'major',
  ViolationSeverity.critical: 'critical',
};

DataRetentionPolicy _$DataRetentionPolicyFromJson(Map<String, dynamic> json) =>
    DataRetentionPolicy(
      sessionRecordingsDays: (json['sessionRecordingsDays'] as num).toInt(),
      chatLogsDays: (json['chatLogsDays'] as num).toInt(),
      biometricDataDays: (json['biometricDataDays'] as num).toInt(),
      auditLogsDays: (json['auditLogsDays'] as num).toInt(),
      enableAutoDeletion: json['enableAutoDeletion'] as bool,
      exceptions: (json['exceptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DataRetentionPolicyToJson(
  DataRetentionPolicy instance,
) => <String, dynamic>{
  'sessionRecordingsDays': instance.sessionRecordingsDays,
  'chatLogsDays': instance.chatLogsDays,
  'biometricDataDays': instance.biometricDataDays,
  'auditLogsDays': instance.auditLogsDays,
  'enableAutoDeletion': instance.enableAutoDeletion,
  'exceptions': instance.exceptions,
};

EncryptionSettings _$EncryptionSettingsFromJson(Map<String, dynamic> json) =>
    EncryptionSettings(
      algorithm: json['algorithm'] as String,
      keySize: (json['keySize'] as num).toInt(),
      enableEndToEndEncryption: json['enableEndToEndEncryption'] as bool,
      enableAtRestEncryption: json['enableAtRestEncryption'] as bool,
      enableInTransitEncryption: json['enableInTransitEncryption'] as bool,
      keyManagement: json['keyManagement'] as String,
    );

Map<String, dynamic> _$EncryptionSettingsToJson(EncryptionSettings instance) =>
    <String, dynamic>{
      'algorithm': instance.algorithm,
      'keySize': instance.keySize,
      'enableEndToEndEncryption': instance.enableEndToEndEncryption,
      'enableAtRestEncryption': instance.enableAtRestEncryption,
      'enableInTransitEncryption': instance.enableInTransitEncryption,
      'keyManagement': instance.keyManagement,
    };
