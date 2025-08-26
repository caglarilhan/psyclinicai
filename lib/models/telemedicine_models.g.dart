// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemedicine_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemedicineSession _$TelemedicineSessionFromJson(
  Map<String, dynamic> json,
) => TelemedicineSession(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  patientName: json['patientName'] as String,
  therapistId: json['therapistId'] as String,
  therapistName: json['therapistName'] as String,
  sessionType: $enumDecode(_$SessionTypeEnumMap, json['sessionType']),
  status: $enumDecode(_$TelemedicineSessionStatusEnumMap, json['status']),
  scheduledTime: DateTime.parse(json['scheduledTime'] as String),
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  duration: (json['duration'] as num).toInt(),
  videoQuality: $enumDecode(_$VideoQualityLevelEnumMap, json['videoQuality']),
  emergencyLevel: $enumDecode(_$EmergencyLevelEnumMap, json['emergencyLevel']),
  meetingUrl: json['meetingUrl'] as String?,
  meetingId: json['meetingId'] as String?,
  meetingPassword: json['meetingPassword'] as String?,
  sessionNotes: json['sessionNotes'] as Map<String, dynamic>,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  technicalSettings: json['technicalSettings'] as Map<String, dynamic>,
  recordingUrl: json['recordingUrl'] as String?,
  isRecorded: json['isRecorded'] as bool,
  isEncrypted: json['isEncrypted'] as bool,
  blockchainHash: json['blockchainHash'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TelemedicineSessionToJson(
  TelemedicineSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'patientName': instance.patientName,
  'therapistId': instance.therapistId,
  'therapistName': instance.therapistName,
  'sessionType': _$SessionTypeEnumMap[instance.sessionType]!,
  'status': _$TelemedicineSessionStatusEnumMap[instance.status]!,
  'scheduledTime': instance.scheduledTime.toIso8601String(),
  'startTime': instance.startTime?.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'duration': instance.duration,
  'videoQuality': _$VideoQualityLevelEnumMap[instance.videoQuality]!,
  'emergencyLevel': _$EmergencyLevelEnumMap[instance.emergencyLevel]!,
  'meetingUrl': instance.meetingUrl,
  'meetingId': instance.meetingId,
  'meetingPassword': instance.meetingPassword,
  'sessionNotes': instance.sessionNotes,
  'participants': instance.participants,
  'technicalSettings': instance.technicalSettings,
  'recordingUrl': instance.recordingUrl,
  'isRecorded': instance.isRecorded,
  'isEncrypted': instance.isEncrypted,
  'blockchainHash': instance.blockchainHash,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$SessionTypeEnumMap = {
  SessionType.initialConsultation: 'initial_consultation',
  SessionType.followUp: 'follow_up',
  SessionType.crisisIntervention: 'crisis_intervention',
  SessionType.groupTherapy: 'group_therapy',
  SessionType.familyTherapy: 'family_therapy',
  SessionType.medicationReview: 'medication_review',
  SessionType.emergencyEvaluation: 'emergency_evaluation',
  SessionType.assessment: 'assessment',
};

const _$TelemedicineSessionStatusEnumMap = {
  TelemedicineSessionStatus.scheduled: 'scheduled',
  TelemedicineSessionStatus.waiting: 'waiting',
  TelemedicineSessionStatus.active: 'active',
  TelemedicineSessionStatus.paused: 'paused',
  TelemedicineSessionStatus.completed: 'completed',
  TelemedicineSessionStatus.cancelled: 'cancelled',
  TelemedicineSessionStatus.noShow: 'no_show',
  TelemedicineSessionStatus.emergency: 'emergency',
};

const _$VideoQualityLevelEnumMap = {
  VideoQualityLevel.low: 'low',
  VideoQualityLevel.medium: 'medium',
  VideoQualityLevel.high: 'high',
  VideoQualityLevel.ultra: 'ultra',
  VideoQualityLevel.adaptive: 'adaptive',
};

const _$EmergencyLevelEnumMap = {
  EmergencyLevel.none: 'none',
  EmergencyLevel.low: 'low',
  EmergencyLevel.medium: 'medium',
  EmergencyLevel.high: 'high',
  EmergencyLevel.critical: 'critical',
};

VirtualWaitingRoom _$VirtualWaitingRoomFromJson(Map<String, dynamic> json) =>
    VirtualWaitingRoom(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      patients: (json['patients'] as List<dynamic>)
          .map((e) => WaitingPatient.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPosition: (json['currentPosition'] as num).toInt(),
      estimatedStartTime: DateTime.parse(json['estimatedStartTime'] as String),
      status: json['status'] as String,
      queueSettings: json['queueSettings'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VirtualWaitingRoomToJson(VirtualWaitingRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'patients': instance.patients,
      'currentPosition': instance.currentPosition,
      'estimatedStartTime': instance.estimatedStartTime.toIso8601String(),
      'status': instance.status,
      'queueSettings': instance.queueSettings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

WaitingPatient _$WaitingPatientFromJson(Map<String, dynamic> json) =>
    WaitingPatient(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      position: (json['position'] as num).toInt(),
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      estimatedWaitTime: DateTime.parse(json['estimatedWaitTime'] as String),
      emergencyLevel: $enumDecode(
        _$EmergencyLevelEnumMap,
        json['emergencyLevel'],
      ),
      notes: json['notes'] as String?,
      isReady: json['isReady'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WaitingPatientToJson(WaitingPatient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'position': instance.position,
      'checkInTime': instance.checkInTime.toIso8601String(),
      'estimatedWaitTime': instance.estimatedWaitTime.toIso8601String(),
      'emergencyLevel': _$EmergencyLevelEnumMap[instance.emergencyLevel]!,
      'notes': instance.notes,
      'isReady': instance.isReady,
      'metadata': instance.metadata,
    };

VideoCallMetrics _$VideoCallMetricsFromJson(Map<String, dynamic> json) =>
    VideoCallMetrics(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      videoBitrate: (json['videoBitrate'] as num).toDouble(),
      audioBitrate: (json['audioBitrate'] as num).toDouble(),
      frameRate: (json['frameRate'] as num).toInt(),
      packetLoss: (json['packetLoss'] as num).toDouble(),
      latency: (json['latency'] as num).toDouble(),
      jitter: (json['jitter'] as num).toDouble(),
      currentQuality: $enumDecode(
        _$VideoQualityLevelEnumMap,
        json['currentQuality'],
      ),
      isStable: json['isStable'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      technicalDetails: json['technicalDetails'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$VideoCallMetricsToJson(VideoCallMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'videoBitrate': instance.videoBitrate,
      'audioBitrate': instance.audioBitrate,
      'frameRate': instance.frameRate,
      'packetLoss': instance.packetLoss,
      'latency': instance.latency,
      'jitter': instance.jitter,
      'currentQuality': _$VideoQualityLevelEnumMap[instance.currentQuality]!,
      'isStable': instance.isStable,
      'timestamp': instance.timestamp.toIso8601String(),
      'technicalDetails': instance.technicalDetails,
    };

EConsultation _$EConsultationFromJson(Map<String, dynamic> json) =>
    EConsultation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      therapistId: json['therapistId'] as String,
      therapistName: json['therapistName'] as String,
      consultationType: json['consultationType'] as String,
      symptoms: json['symptoms'] as String,
      medicalHistory: json['medicalHistory'] as String,
      currentMedications: (json['currentMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assessment: json['assessment'] as String,
      recommendations: json['recommendations'] as String,
      prescribedMedications: (json['prescribedMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      followUpInstructions: json['followUpInstructions'] as String,
      consultationDate: DateTime.parse(json['consultationDate'] as String),
      duration: (json['duration'] as num).toInt(),
      requiresFollowUp: json['requiresFollowUp'] as bool,
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
      blockchainHash: json['blockchainHash'] as String,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EConsultationToJson(EConsultation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'therapistId': instance.therapistId,
      'therapistName': instance.therapistName,
      'consultationType': instance.consultationType,
      'symptoms': instance.symptoms,
      'medicalHistory': instance.medicalHistory,
      'currentMedications': instance.currentMedications,
      'assessment': instance.assessment,
      'recommendations': instance.recommendations,
      'prescribedMedications': instance.prescribedMedications,
      'followUpInstructions': instance.followUpInstructions,
      'consultationDate': instance.consultationDate.toIso8601String(),
      'duration': instance.duration,
      'requiresFollowUp': instance.requiresFollowUp,
      'followUpDate': instance.followUpDate?.toIso8601String(),
      'blockchainHash': instance.blockchainHash,
      'isVerified': instance.isVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

RemotePrescription _$RemotePrescriptionFromJson(Map<String, dynamic> json) =>
    RemotePrescription(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      therapistId: json['therapistId'] as String,
      therapistName: json['therapistName'] as String,
      prescriptionType: json['prescriptionType'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => PrescribedMedication.fromJson(e as Map<String, dynamic>))
          .toList(),
      diagnosis: json['diagnosis'] as String,
      instructions: json['instructions'] as String,
      prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      refills: (json['refills'] as num).toInt(),
      isControlled: json['isControlled'] as bool,
      blockchainHash: json['blockchainHash'] as String,
      isVerified: json['isVerified'] as bool,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RemotePrescriptionToJson(RemotePrescription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'therapistId': instance.therapistId,
      'therapistName': instance.therapistName,
      'prescriptionType': instance.prescriptionType,
      'medications': instance.medications,
      'diagnosis': instance.diagnosis,
      'instructions': instance.instructions,
      'prescriptionDate': instance.prescriptionDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'refills': instance.refills,
      'isControlled': instance.isControlled,
      'blockchainHash': instance.blockchainHash,
      'isVerified': instance.isVerified,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

PrescribedMedication _$PrescribedMedicationFromJson(
  Map<String, dynamic> json,
) => PrescribedMedication(
  id: json['id'] as String,
  medicationName: json['medicationName'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  route: json['route'] as String,
  quantity: (json['quantity'] as num).toInt(),
  instructions: json['instructions'] as String,
  warnings: json['warnings'] as String,
  isControlled: json['isControlled'] as bool,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  refills: (json['refills'] as num).toInt(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PrescribedMedicationToJson(
  PrescribedMedication instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationName': instance.medicationName,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'route': instance.route,
  'quantity': instance.quantity,
  'instructions': instance.instructions,
  'warnings': instance.warnings,
  'isControlled': instance.isControlled,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'refills': instance.refills,
  'metadata': instance.metadata,
};

PatientMonitoringData _$PatientMonitoringDataFromJson(
  Map<String, dynamic> json,
) => PatientMonitoringData(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  sessionId: json['sessionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  heartRate: (json['heartRate'] as num?)?.toDouble(),
  bloodPressure: (json['bloodPressure'] as num?)?.toDouble(),
  temperature: (json['temperature'] as num?)?.toDouble(),
  oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
  mood: json['mood'] as String?,
  anxietyLevel: json['anxietyLevel'] as String?,
  depressionLevel: json['depressionLevel'] as String?,
  sleepQuality: json['sleepQuality'] as String?,
  stressLevel: json['stressLevel'] as String?,
  biometricData: json['biometricData'] as Map<String, dynamic>,
  behavioralData: json['behavioralData'] as Map<String, dynamic>,
  blockchainHash: json['blockchainHash'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PatientMonitoringDataToJson(
  PatientMonitoringData instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'sessionId': instance.sessionId,
  'timestamp': instance.timestamp.toIso8601String(),
  'heartRate': instance.heartRate,
  'bloodPressure': instance.bloodPressure,
  'temperature': instance.temperature,
  'oxygenSaturation': instance.oxygenSaturation,
  'mood': instance.mood,
  'anxietyLevel': instance.anxietyLevel,
  'depressionLevel': instance.depressionLevel,
  'sleepQuality': instance.sleepQuality,
  'stressLevel': instance.stressLevel,
  'biometricData': instance.biometricData,
  'behavioralData': instance.behavioralData,
  'blockchainHash': instance.blockchainHash,
  'createdAt': instance.createdAt.toIso8601String(),
};

EmergencyProtocol _$EmergencyProtocolFromJson(Map<String, dynamic> json) =>
    EmergencyProtocol(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      patientId: json['patientId'] as String,
      emergencyLevel: $enumDecode(
        _$EmergencyLevelEnumMap,
        json['emergencyLevel'],
      ),
      emergencyType: json['emergencyType'] as String,
      description: json['description'] as String,
      immediateActions: (json['immediateActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nearestHospital: json['nearestHospital'] as String,
      hospitalAddress: json['hospitalAddress'] as String,
      hospitalPhone: json['hospitalPhone'] as String,
      emergencyServicesCalled: json['emergencyServicesCalled'] as bool,
      emergencyStartTime: DateTime.parse(json['emergencyStartTime'] as String),
      emergencyEndTime: json['emergencyEndTime'] == null
          ? null
          : DateTime.parse(json['emergencyEndTime'] as String),
      status: json['status'] as String,
      blockchainHash: json['blockchainHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EmergencyProtocolToJson(EmergencyProtocol instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'patientId': instance.patientId,
      'emergencyLevel': _$EmergencyLevelEnumMap[instance.emergencyLevel]!,
      'emergencyType': instance.emergencyType,
      'description': instance.description,
      'immediateActions': instance.immediateActions,
      'emergencyContacts': instance.emergencyContacts,
      'nearestHospital': instance.nearestHospital,
      'hospitalAddress': instance.hospitalAddress,
      'hospitalPhone': instance.hospitalPhone,
      'emergencyServicesCalled': instance.emergencyServicesCalled,
      'emergencyStartTime': instance.emergencyStartTime.toIso8601String(),
      'emergencyEndTime': instance.emergencyEndTime?.toIso8601String(),
      'status': instance.status,
      'blockchainHash': instance.blockchainHash,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

TelemedicineAnalytics _$TelemedicineAnalyticsFromJson(
  Map<String, dynamic> json,
) => TelemedicineAnalytics(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  totalSessions: (json['totalSessions'] as num).toInt(),
  completedSessions: (json['completedSessions'] as num).toInt(),
  cancelledSessions: (json['cancelledSessions'] as num).toInt(),
  noShowSessions: (json['noShowSessions'] as num).toInt(),
  averageSessionDuration: (json['averageSessionDuration'] as num).toDouble(),
  averageWaitTime: (json['averageWaitTime'] as num).toDouble(),
  patientSatisfactionScore: (json['patientSatisfactionScore'] as num)
      .toDouble(),
  technicalIssueRate: (json['technicalIssueRate'] as num).toDouble(),
  sessionTypeDistribution: Map<String, int>.from(
    json['sessionTypeDistribution'] as Map,
  ),
  emergencyLevelDistribution: Map<String, int>.from(
    json['emergencyLevelDistribution'] as Map,
  ),
  qualityMetrics: (json['qualityMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  performanceData: json['performanceData'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TelemedicineAnalyticsToJson(
  TelemedicineAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'totalSessions': instance.totalSessions,
  'completedSessions': instance.completedSessions,
  'cancelledSessions': instance.cancelledSessions,
  'noShowSessions': instance.noShowSessions,
  'averageSessionDuration': instance.averageSessionDuration,
  'averageWaitTime': instance.averageWaitTime,
  'patientSatisfactionScore': instance.patientSatisfactionScore,
  'technicalIssueRate': instance.technicalIssueRate,
  'sessionTypeDistribution': instance.sessionTypeDistribution,
  'emergencyLevelDistribution': instance.emergencyLevelDistribution,
  'qualityMetrics': instance.qualityMetrics,
  'performanceData': instance.performanceData,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

TechnicalSettings _$TechnicalSettingsFromJson(Map<String, dynamic> json) =>
    TechnicalSettings(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      defaultVideoQuality: $enumDecode(
        _$VideoQualityLevelEnumMap,
        json['defaultVideoQuality'],
      ),
      enableAdaptiveQuality: json['enableAdaptiveQuality'] as bool,
      enableNoiseCancellation: json['enableNoiseCancellation'] as bool,
      enableEchoCancellation: json['enableEchoCancellation'] as bool,
      enableBackgroundBlur: json['enableBackgroundBlur'] as bool,
      enableVirtualBackground: json['enableVirtualBackground'] as bool,
      enableScreenSharing: json['enableScreenSharing'] as bool,
      enableRecording: json['enableRecording'] as bool,
      enableChat: json['enableChat'] as bool,
      enableFileSharing: json['enableFileSharing'] as bool,
      advancedSettings: json['advancedSettings'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TechnicalSettingsToJson(TechnicalSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'defaultVideoQuality':
          _$VideoQualityLevelEnumMap[instance.defaultVideoQuality]!,
      'enableAdaptiveQuality': instance.enableAdaptiveQuality,
      'enableNoiseCancellation': instance.enableNoiseCancellation,
      'enableEchoCancellation': instance.enableEchoCancellation,
      'enableBackgroundBlur': instance.enableBackgroundBlur,
      'enableVirtualBackground': instance.enableVirtualBackground,
      'enableScreenSharing': instance.enableScreenSharing,
      'enableRecording': instance.enableRecording,
      'enableChat': instance.enableChat,
      'enableFileSharing': instance.enableFileSharing,
      'advancedSettings': instance.advancedSettings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
