// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemedicine_remote_care.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemedicineRemoteCare _$TelemedicineRemoteCareFromJson(
  Map<String, dynamic> json,
) => TelemedicineRemoteCare(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  version: json['version'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  telemedicineFeatures: json['telemedicineFeatures'] as Map<String, dynamic>,
  remoteCareFeatures: json['remoteCareFeatures'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TelemedicineRemoteCareToJson(
  TelemedicineRemoteCare instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'version': instance.version,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'telemedicineFeatures': instance.telemedicineFeatures,
  'remoteCareFeatures': instance.remoteCareFeatures,
  'metadata': instance.metadata,
};

GlobalVideoConsultations _$GlobalVideoConsultationsFromJson(
  Map<String, dynamic> json,
) => GlobalVideoConsultations(
  id: json['id'] as String,
  consultationId: json['consultationId'] as String,
  patientId: json['patientId'] as String,
  providerId: json['providerId'] as String,
  consultationType: json['consultationType'] as String,
  scheduledDate: DateTime.parse(json['scheduledDate'] as String),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  status: json['status'] as String,
  platform: json['platform'] as String,
  meetingUrl: json['meetingUrl'] as String,
  meetingId: json['meetingId'] as String,
  meetingPassword: json['meetingPassword'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  consultationNotes: json['consultationNotes'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$GlobalVideoConsultationsToJson(
  GlobalVideoConsultations instance,
) => <String, dynamic>{
  'id': instance.id,
  'consultationId': instance.consultationId,
  'patientId': instance.patientId,
  'providerId': instance.providerId,
  'consultationType': instance.consultationType,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'status': instance.status,
  'platform': instance.platform,
  'meetingUrl': instance.meetingUrl,
  'meetingId': instance.meetingId,
  'meetingPassword': instance.meetingPassword,
  'participants': instance.participants,
  'consultationNotes': instance.consultationNotes,
  'metadata': instance.metadata,
};

VRARTherapySessions _$VRARTherapySessionsFromJson(Map<String, dynamic> json) =>
    VRARTherapySessions(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      patientId: json['patientId'] as String,
      providerId: json['providerId'] as String,
      therapyType: json['therapyType'] as String,
      vrArPlatform: json['vrArPlatform'] as String,
      scenario: json['scenario'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      status: json['status'] as String,
      sessionData: json['sessionData'] as Map<String, dynamic>,
      equipment: (json['equipment'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$VRARTherapySessionsToJson(
  VRARTherapySessions instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'patientId': instance.patientId,
  'providerId': instance.providerId,
  'therapyType': instance.therapyType,
  'vrArPlatform': instance.vrArPlatform,
  'scenario': instance.scenario,
  'sessionDate': instance.sessionDate.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'status': instance.status,
  'sessionData': instance.sessionData,
  'equipment': instance.equipment,
  'performanceMetrics': instance.performanceMetrics,
  'metadata': instance.metadata,
};

RemoteMonitoring _$RemoteMonitoringFromJson(Map<String, dynamic> json) =>
    RemoteMonitoring(
      id: json['id'] as String,
      monitoringId: json['monitoringId'] as String,
      patientId: json['patientId'] as String,
      monitoringType: json['monitoringType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      monitoredParameters: (json['monitoredParameters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      baselineData: json['baselineData'] as Map<String, dynamic>,
      currentData: json['currentData'] as Map<String, dynamic>,
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RemoteMonitoringToJson(RemoteMonitoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'monitoringId': instance.monitoringId,
      'patientId': instance.patientId,
      'monitoringType': instance.monitoringType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'monitoredParameters': instance.monitoredParameters,
      'baselineData': instance.baselineData,
      'currentData': instance.currentData,
      'alerts': instance.alerts,
      'interventions': instance.interventions,
      'metadata': instance.metadata,
    };

DigitalTherapeutics _$DigitalTherapeuticsFromJson(Map<String, dynamic> json) =>
    DigitalTherapeutics(
      id: json['id'] as String,
      therapeuticName: json['therapeuticName'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      platform: json['platform'] as String,
      version: json['version'] as String,
      indications: (json['indications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalEvidence: json['clinicalEvidence'] as Map<String, dynamic>,
      efficacyScore: (json['efficacyScore'] as num).toDouble(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DigitalTherapeuticsToJson(
  DigitalTherapeutics instance,
) => <String, dynamic>{
  'id': instance.id,
  'therapeuticName': instance.therapeuticName,
  'description': instance.description,
  'category': instance.category,
  'platform': instance.platform,
  'version': instance.version,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'features': instance.features,
  'clinicalEvidence': instance.clinicalEvidence,
  'efficacyScore': instance.efficacyScore,
  'sideEffects': instance.sideEffects,
  'metadata': instance.metadata,
};

RemotePatientEducation _$RemotePatientEducationFromJson(
  Map<String, dynamic> json,
) => RemotePatientEducation(
  id: json['id'] as String,
  educationId: json['educationId'] as String,
  patientId: json['patientId'] as String,
  topic: json['topic'] as String,
  format: json['format'] as String,
  language: json['language'] as String,
  deliveryDate: DateTime.parse(json['deliveryDate'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  status: json['status'] as String,
  learningObjectives: (json['learningObjectives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessmentResults: json['assessmentResults'] as Map<String, dynamic>,
  comprehensionScore: (json['comprehensionScore'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemotePatientEducationToJson(
  RemotePatientEducation instance,
) => <String, dynamic>{
  'id': instance.id,
  'educationId': instance.educationId,
  'patientId': instance.patientId,
  'topic': instance.topic,
  'format': instance.format,
  'language': instance.language,
  'deliveryDate': instance.deliveryDate.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'status': instance.status,
  'learningObjectives': instance.learningObjectives,
  'assessmentResults': instance.assessmentResults,
  'comprehensionScore': instance.comprehensionScore,
  'metadata': instance.metadata,
};

RemoteRehabilitation _$RemoteRehabilitationFromJson(
  Map<String, dynamic> json,
) => RemoteRehabilitation(
  id: json['id'] as String,
  rehabilitationId: json['rehabilitationId'] as String,
  patientId: json['patientId'] as String,
  rehabilitationType: json['rehabilitationType'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  status: json['status'] as String,
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  progressData: json['progressData'] as Map<String, dynamic>,
  goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
  assessmentResults: json['assessmentResults'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteRehabilitationToJson(
  RemoteRehabilitation instance,
) => <String, dynamic>{
  'id': instance.id,
  'rehabilitationId': instance.rehabilitationId,
  'patientId': instance.patientId,
  'rehabilitationType': instance.rehabilitationType,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'status': instance.status,
  'exercises': instance.exercises,
  'progressData': instance.progressData,
  'goals': instance.goals,
  'assessmentResults': instance.assessmentResults,
  'metadata': instance.metadata,
};

RemoteMedicationManagement _$RemoteMedicationManagementFromJson(
  Map<String, dynamic> json,
) => RemoteMedicationManagement(
  id: json['id'] as String,
  managementId: json['managementId'] as String,
  patientId: json['patientId'] as String,
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosingSchedule: json['dosingSchedule'] as Map<String, dynamic>,
  reminders: (json['reminders'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  adherenceData: json['adherenceData'] as Map<String, dynamic>,
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteMedicationManagementToJson(
  RemoteMedicationManagement instance,
) => <String, dynamic>{
  'id': instance.id,
  'managementId': instance.managementId,
  'patientId': instance.patientId,
  'medications': instance.medications,
  'dosingSchedule': instance.dosingSchedule,
  'reminders': instance.reminders,
  'adherenceData': instance.adherenceData,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'metadata': instance.metadata,
};

RemoteSupportGroups _$RemoteSupportGroupsFromJson(
  Map<String, dynamic> json,
) => RemoteSupportGroups(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  groupName: json['groupName'] as String,
  groupType: json['groupType'] as String,
  facilitator: json['facilitator'] as String,
  members: (json['members'] as List<dynamic>).map((e) => e as String).toList(),
  meetingTime: DateTime.parse(json['meetingTime'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  platform: json['platform'] as String,
  meetingUrl: json['meetingUrl'] as String,
  status: json['status'] as String,
  topics: (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteSupportGroupsToJson(
  RemoteSupportGroups instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'groupType': instance.groupType,
  'facilitator': instance.facilitator,
  'members': instance.members,
  'meetingTime': instance.meetingTime.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'platform': instance.platform,
  'meetingUrl': instance.meetingUrl,
  'status': instance.status,
  'topics': instance.topics,
  'metadata': instance.metadata,
};

RemoteEmergencyIntervention _$RemoteEmergencyInterventionFromJson(
  Map<String, dynamic> json,
) => RemoteEmergencyIntervention(
  id: json['id'] as String,
  interventionId: json['interventionId'] as String,
  patientId: json['patientId'] as String,
  emergencyType: json['emergencyType'] as String,
  incidentTime: DateTime.parse(json['incidentTime'] as String),
  severity: json['severity'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  outcome: json['outcome'] as String,
  followUpActions: (json['followUpActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteEmergencyInterventionToJson(
  RemoteEmergencyIntervention instance,
) => <String, dynamic>{
  'id': instance.id,
  'interventionId': instance.interventionId,
  'patientId': instance.patientId,
  'emergencyType': instance.emergencyType,
  'incidentTime': instance.incidentTime.toIso8601String(),
  'severity': instance.severity,
  'symptoms': instance.symptoms,
  'actions': instance.actions,
  'outcome': instance.outcome,
  'followUpActions': instance.followUpActions,
  'metadata': instance.metadata,
};

RemoteHealthScreening _$RemoteHealthScreeningFromJson(
  Map<String, dynamic> json,
) => RemoteHealthScreening(
  id: json['id'] as String,
  screeningId: json['screeningId'] as String,
  patientId: json['patientId'] as String,
  screeningType: json['screeningType'] as String,
  screeningDate: DateTime.parse(json['screeningDate'] as String),
  screeningQuestions: (json['screeningQuestions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responses: json['responses'] as Map<String, dynamic>,
  riskLevel: json['riskLevel'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteHealthScreeningToJson(
  RemoteHealthScreening instance,
) => <String, dynamic>{
  'id': instance.id,
  'screeningId': instance.screeningId,
  'patientId': instance.patientId,
  'screeningType': instance.screeningType,
  'screeningDate': instance.screeningDate.toIso8601String(),
  'screeningQuestions': instance.screeningQuestions,
  'responses': instance.responses,
  'riskLevel': instance.riskLevel,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

RemoteFollowUp _$RemoteFollowUpFromJson(Map<String, dynamic> json) =>
    RemoteFollowUp(
      id: json['id'] as String,
      followUpId: json['followUpId'] as String,
      patientId: json['patientId'] as String,
      followUpType: json['followUpType'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      actualDate: DateTime.parse(json['actualDate'] as String),
      status: json['status'] as String,
      assessmentAreas: (json['assessmentAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      assessmentResults: json['assessmentResults'] as Map<String, dynamic>,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextFollowUpDate: DateTime.parse(json['nextFollowUpDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RemoteFollowUpToJson(RemoteFollowUp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'followUpId': instance.followUpId,
      'patientId': instance.patientId,
      'followUpType': instance.followUpType,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'actualDate': instance.actualDate.toIso8601String(),
      'status': instance.status,
      'assessmentAreas': instance.assessmentAreas,
      'assessmentResults': instance.assessmentResults,
      'recommendations': instance.recommendations,
      'nextFollowUpDate': instance.nextFollowUpDate.toIso8601String(),
      'metadata': instance.metadata,
    };

RemoteConsultationNotes _$RemoteConsultationNotesFromJson(
  Map<String, dynamic> json,
) => RemoteConsultationNotes(
  id: json['id'] as String,
  consultationId: json['consultationId'] as String,
  patientId: json['patientId'] as String,
  providerId: json['providerId'] as String,
  consultationDate: DateTime.parse(json['consultationDate'] as String),
  chiefComplaint: json['chiefComplaint'] as String,
  history: json['history'] as String,
  examination: json['examination'] as String,
  assessment: json['assessment'] as String,
  plan: json['plan'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteConsultationNotesToJson(
  RemoteConsultationNotes instance,
) => <String, dynamic>{
  'id': instance.id,
  'consultationId': instance.consultationId,
  'patientId': instance.patientId,
  'providerId': instance.providerId,
  'consultationDate': instance.consultationDate.toIso8601String(),
  'chiefComplaint': instance.chiefComplaint,
  'history': instance.history,
  'examination': instance.examination,
  'assessment': instance.assessment,
  'plan': instance.plan,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

RemotePrescriptionManagement _$RemotePrescriptionManagementFromJson(
  Map<String, dynamic> json,
) => RemotePrescriptionManagement(
  id: json['id'] as String,
  prescriptionId: json['prescriptionId'] as String,
  patientId: json['patientId'] as String,
  providerId: json['providerId'] as String,
  prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosingInstructions: json['dosingInstructions'] as Map<String, dynamic>,
  durationDays: (json['durationDays'] as num).toInt(),
  specialInstructions: (json['specialInstructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemotePrescriptionManagementToJson(
  RemotePrescriptionManagement instance,
) => <String, dynamic>{
  'id': instance.id,
  'prescriptionId': instance.prescriptionId,
  'patientId': instance.patientId,
  'providerId': instance.providerId,
  'prescriptionDate': instance.prescriptionDate.toIso8601String(),
  'medications': instance.medications,
  'dosingInstructions': instance.dosingInstructions,
  'durationDays': instance.durationDays,
  'specialInstructions': instance.specialInstructions,
  'status': instance.status,
  'metadata': instance.metadata,
};

RemoteLabResults _$RemoteLabResultsFromJson(Map<String, dynamic> json) =>
    RemoteLabResults(
      id: json['id'] as String,
      resultId: json['resultId'] as String,
      patientId: json['patientId'] as String,
      testName: json['testName'] as String,
      testDate: DateTime.parse(json['testDate'] as String),
      resultDate: DateTime.parse(json['resultDate'] as String),
      testResults: json['testResults'] as Map<String, dynamic>,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RemoteLabResultsToJson(RemoteLabResults instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resultId': instance.resultId,
      'patientId': instance.patientId,
      'testName': instance.testName,
      'testDate': instance.testDate.toIso8601String(),
      'resultDate': instance.resultDate.toIso8601String(),
      'testResults': instance.testResults,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
    };

RemoteImagingResults _$RemoteImagingResultsFromJson(
  Map<String, dynamic> json,
) => RemoteImagingResults(
  id: json['id'] as String,
  imagingId: json['imagingId'] as String,
  patientId: json['patientId'] as String,
  imagingType: json['imagingType'] as String,
  imagingDate: DateTime.parse(json['imagingDate'] as String),
  resultDate: DateTime.parse(json['resultDate'] as String),
  findings: json['findings'] as String,
  impression: json['impression'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RemoteImagingResultsToJson(
  RemoteImagingResults instance,
) => <String, dynamic>{
  'id': instance.id,
  'imagingId': instance.imagingId,
  'patientId': instance.patientId,
  'imagingType': instance.imagingType,
  'imagingDate': instance.imagingDate.toIso8601String(),
  'resultDate': instance.resultDate.toIso8601String(),
  'findings': instance.findings,
  'impression': instance.impression,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};
