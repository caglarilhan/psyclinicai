import 'package:json_annotation/json_annotation.dart';

part 'telemedicine_remote_care.g.dart';

// Telemedicine ve Uzaktan Bakım
@JsonSerializable()
class TelemedicineRemoteCare {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime lastUpdated;
  final String status;
  final Map<String, dynamic> telemedicineFeatures;
  final Map<String, dynamic> remoteCareFeatures;
  final Map<String, dynamic> metadata;

  TelemedicineRemoteCare({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.lastUpdated,
    required this.status,
    required this.telemedicineFeatures,
    required this.remoteCareFeatures,
    required this.metadata,
  });

  factory TelemedicineRemoteCare.fromJson(Map<String, dynamic> json) =>
      _$TelemedicineRemoteCareFromJson(json);

  Map<String, dynamic> toJson() => _$TelemedicineRemoteCareToJson(this);
}

// Global Video Konsültasyonlar
@JsonSerializable()
class GlobalVideoConsultations {
  final String id;
  final String consultationId;
  final String patientId;
  final String providerId;
  final String consultationType;
  final DateTime scheduledDate;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // scheduled, in_progress, completed, cancelled
  final String platform; // zoom, teams, custom
  final String meetingUrl;
  final String meetingId;
  final String meetingPassword;
  final List<String> participants;
  final Map<String, dynamic> consultationNotes;
  final Map<String, dynamic> metadata;

  GlobalVideoConsultations({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.providerId,
    required this.consultationType,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.platform,
    required this.meetingUrl,
    required this.meetingId,
    required this.meetingPassword,
    required this.participants,
    required this.consultationNotes,
    required this.metadata,
  });

  factory GlobalVideoConsultations.fromJson(Map<String, dynamic> json) =>
      _$GlobalVideoConsultationsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalVideoConsultationsToJson(this);
}

// VR/AR Terapi Seansları
@JsonSerializable()
class VRARTherapySessions {
  final String id;
  final String sessionId;
  final String patientId;
  final String providerId;
  final String therapyType;
  final String vrArPlatform;
  final String scenario;
  final DateTime sessionDate;
  final int durationMinutes;
  final String status;
  final Map<String, dynamic> sessionData;
  final List<String> equipment;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> metadata;

  VRARTherapySessions({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.providerId,
    required this.therapyType,
    required this.vrArPlatform,
    required this.scenario,
    required this.sessionDate,
    required this.durationMinutes,
    required this.status,
    required this.sessionData,
    required this.equipment,
    required this.performanceMetrics,
    required this.metadata,
  });

  factory VRARTherapySessions.fromJson(Map<String, dynamic> json) =>
      _$VRARTherapySessionsFromJson(json);

  Map<String, dynamic> toJson() => _$VRARTherapySessionsToJson(this);
}

// Uzaktan İzleme
@JsonSerializable()
class RemoteMonitoring {
  final String id;
  final String monitoringId;
  final String patientId;
  final String monitoringType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<String> monitoredParameters;
  final Map<String, dynamic> baselineData;
  final Map<String, dynamic> currentData;
  final List<String> alerts;
  final List<String> interventions;
  final Map<String, dynamic> metadata;

  RemoteMonitoring({
    required this.id,
    required this.monitoringId,
    required this.patientId,
    required this.monitoringType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.monitoredParameters,
    required this.baselineData,
    required this.currentData,
    required this.alerts,
    required this.interventions,
    required this.metadata,
  });

  factory RemoteMonitoring.fromJson(Map<String, dynamic> json) =>
      _$RemoteMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteMonitoringToJson(this);
}

// Dijital Terapötikler
@JsonSerializable()
class DigitalTherapeutics {
  final String id;
  final String therapeuticName;
  final String description;
  final String category;
  final String platform;
  final String version;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> features;
  final Map<String, dynamic> clinicalEvidence;
  final double efficacyScore;
  final List<String> sideEffects;
  final Map<String, dynamic> metadata;

  DigitalTherapeutics({
    required this.id,
    required this.therapeuticName,
    required this.description,
    required this.category,
    required this.platform,
    required this.version,
    required this.indications,
    required this.contraindications,
    required this.features,
    required this.clinicalEvidence,
    required this.efficacyScore,
    required this.sideEffects,
    required this.metadata,
  });

  factory DigitalTherapeutics.fromJson(Map<String, dynamic> json) =>
      _$DigitalTherapeuticsFromJson(json);

  Map<String, dynamic> toJson() => _$DigitalTherapeuticsToJson(this);
}

// Uzaktan Hasta Eğitimi
@JsonSerializable()
class RemotePatientEducation {
  final String id;
  final String educationId;
  final String patientId;
  final String topic;
  final String format; // video, interactive, text, audio
  final String language;
  final DateTime deliveryDate;
  final int durationMinutes;
  final String status;
  final List<String> learningObjectives;
  final Map<String, dynamic> assessmentResults;
  final double comprehensionScore;
  final Map<String, dynamic> metadata;

  RemotePatientEducation({
    required this.id,
    required this.educationId,
    required this.patientId,
    required this.topic,
    required this.format,
    required this.language,
    required this.deliveryDate,
    required this.durationMinutes,
    required this.status,
    required this.learningObjectives,
    required this.assessmentResults,
    required this.comprehensionScore,
    required this.metadata,
  });

  factory RemotePatientEducation.fromJson(Map<String, dynamic> json) =>
      _$RemotePatientEducationFromJson(json);

  Map<String, dynamic> toJson() => _$RemotePatientEducationToJson(this);
}

// Uzaktan Rehabilitasyon
@JsonSerializable()
class RemoteRehabilitation {
  final String id;
  final String rehabilitationId;
  final String patientId;
  final String rehabilitationType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<String> exercises;
  final Map<String, dynamic> progressData;
  final List<String> goals;
  final Map<String, dynamic> assessmentResults;
  final Map<String, dynamic> metadata;

  RemoteRehabilitation({
    required this.id,
    required this.rehabilitationId,
    required this.patientId,
    required this.rehabilitationType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.exercises,
    required this.progressData,
    required this.goals,
    required this.assessmentResults,
    required this.metadata,
  });

  factory RemoteRehabilitation.fromJson(Map<String, dynamic> json) =>
      _$RemoteRehabilitationFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteRehabilitationToJson(this);
}

// Uzaktan İlaç Yönetimi
@JsonSerializable()
class RemoteMedicationManagement {
  final String id;
  final String managementId;
  final String patientId;
  final List<String> medications;
  final Map<String, dynamic> dosingSchedule;
  final List<String> reminders;
  final Map<String, dynamic> adherenceData;
  final List<String> sideEffects;
  final List<String> interactions;
  final Map<String, dynamic> metadata;

  RemoteMedicationManagement({
    required this.id,
    required this.managementId,
    required this.patientId,
    required this.medications,
    required this.dosingSchedule,
    required this.reminders,
    required this.adherenceData,
    required this.sideEffects,
    required this.interactions,
    required this.metadata,
  });

  factory RemoteMedicationManagement.fromJson(Map<String, dynamic> json) =>
      _$RemoteMedicationManagementFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteMedicationManagementToJson(this);
}

// Uzaktan Destek Grupları
@JsonSerializable()
class RemoteSupportGroups {
  final String id;
  final String groupId;
  final String groupName;
  final String groupType;
  final String facilitator;
  final List<String> members;
  final DateTime meetingTime;
  final int durationMinutes;
  final String platform;
  final String meetingUrl;
  final String status;
  final List<String> topics;
  final Map<String, dynamic> metadata;

  RemoteSupportGroups({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.groupType,
    required this.facilitator,
    required this.members,
    required this.meetingTime,
    required this.durationMinutes,
    required this.platform,
    required this.meetingUrl,
    required this.status,
    required this.topics,
    required this.metadata,
  });

  factory RemoteSupportGroups.fromJson(Map<String, dynamic> json) =>
      _$RemoteSupportGroupsFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteSupportGroupsToJson(this);
}

// Uzaktan Acil Müdahale
@JsonSerializable()
class RemoteEmergencyIntervention {
  final String id;
  final String interventionId;
  final String patientId;
  final String emergencyType;
  final DateTime incidentTime;
  final String severity; // low, medium, high, critical
  final List<String> symptoms;
  final List<String> actions;
  final String outcome;
  final List<String> followUpActions;
  final Map<String, dynamic> metadata;

  RemoteEmergencyIntervention({
    required this.id,
    required this.interventionId,
    required this.patientId,
    required this.emergencyType,
    required this.incidentTime,
    required this.severity,
    required this.symptoms,
    required this.actions,
    required this.outcome,
    required this.followUpActions,
    required this.metadata,
  });

  factory RemoteEmergencyIntervention.fromJson(Map<String, dynamic> json) =>
      _$RemoteEmergencyInterventionFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteEmergencyInterventionToJson(this);
}

// Uzaktan Sağlık Taraması
@JsonSerializable()
class RemoteHealthScreening {
  final String id;
  final String screeningId;
  final String patientId;
  final String screeningType;
  final DateTime screeningDate;
  final List<String> screeningQuestions;
  final Map<String, dynamic> responses;
  final String riskLevel;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  RemoteHealthScreening({
    required this.id,
    required this.screeningId,
    required this.patientId,
    required this.screeningType,
    required this.screeningDate,
    required this.screeningQuestions,
    required this.responses,
    required this.riskLevel,
    required this.recommendations,
    required this.metadata,
  });

  factory RemoteHealthScreening.fromJson(Map<String, dynamic> json) =>
      _$RemoteHealthScreeningFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteHealthScreeningToJson(this);
}

// Uzaktan Takip
@JsonSerializable()
class RemoteFollowUp {
  final String id;
  final String followUpId;
  final String patientId;
  final String followUpType;
  final DateTime scheduledDate;
  final DateTime actualDate;
  final String status;
  final List<String> assessmentAreas;
  final Map<String, dynamic> assessmentResults;
  final List<String> recommendations;
  final DateTime nextFollowUpDate;
  final Map<String, dynamic> metadata;

  RemoteFollowUp({
    required this.id,
    required this.followUpId,
    required this.patientId,
    required this.followUpType,
    required this.scheduledDate,
    required this.actualDate,
    required this.status,
    required this.assessmentAreas,
    required this.assessmentResults,
    required this.recommendations,
    required this.nextFollowUpDate,
    required this.metadata,
  });

  factory RemoteFollowUp.fromJson(Map<String, dynamic> json) =>
      _$RemoteFollowUpFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteFollowUpToJson(this);
}

// Uzaktan Konsültasyon Notları
@JsonSerializable()
class RemoteConsultationNotes {
  final String id;
  final String consultationId;
  final String patientId;
  final String providerId;
  final DateTime consultationDate;
  final String chiefComplaint;
  final String history;
  final String examination;
  final String assessment;
  final String plan;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  RemoteConsultationNotes({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.providerId,
    required this.consultationDate,
    required this.chiefComplaint,
    required this.history,
    required this.examination,
    required this.assessment,
    required this.plan,
    required this.recommendations,
    required this.metadata,
  });

  factory RemoteConsultationNotes.fromJson(Map<String, dynamic> json) =>
      _$RemoteConsultationNotesFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteConsultationNotesToJson(this);
}

// Uzaktan Reçete Yönetimi
@JsonSerializable()
class RemotePrescriptionManagement {
  final String id;
  final String prescriptionId;
  final String patientId;
  final String providerId;
  final DateTime prescriptionDate;
  final List<String> medications;
  final Map<String, dynamic> dosingInstructions;
  final int durationDays;
  final List<String> specialInstructions;
  final String status;
  final Map<String, dynamic> metadata;

  RemotePrescriptionManagement({
    required this.id,
    required this.prescriptionId,
    required this.patientId,
    required this.providerId,
    required this.prescriptionDate,
    required this.medications,
    required this.dosingInstructions,
    required this.durationDays,
    required this.specialInstructions,
    required this.status,
    required this.metadata,
  });

  factory RemotePrescriptionManagement.fromJson(Map<String, dynamic> json) =>
      _$RemotePrescriptionManagementFromJson(json);

  Map<String, dynamic> toJson() => _$RemotePrescriptionManagementToJson(this);
}

// Uzaktan Laboratuvar Sonuçları
@JsonSerializable()
class RemoteLabResults {
  final String id;
  final String resultId;
  final String patientId;
  final String testName;
  final DateTime testDate;
  final DateTime resultDate;
  final Map<String, dynamic> testResults;
  final String interpretation;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  RemoteLabResults({
    required this.id,
    required this.resultId,
    required this.patientId,
    required this.testName,
    required this.testDate,
    required this.resultDate,
    required this.testResults,
    required this.interpretation,
    required this.recommendations,
    required this.metadata,
  });

  factory RemoteLabResults.fromJson(Map<String, dynamic> json) =>
      _$RemoteLabResultsFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteLabResultsToJson(this);
}

// Uzaktan Görüntüleme Sonuçları
@JsonSerializable()
class RemoteImagingResults {
  final String id;
  final String imagingId;
  final String patientId;
  final String imagingType;
  final DateTime imagingDate;
  final DateTime resultDate;
  final String findings;
  final String impression;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  RemoteImagingResults({
    required this.id,
    required this.imagingId,
    required this.patientId,
    required this.imagingType,
    required this.imagingDate,
    required this.resultDate,
    required this.findings,
    required this.impression,
    required this.recommendations,
    required this.metadata,
  });

  factory RemoteImagingResults.fromJson(Map<String, dynamic> json) =>
      _$RemoteImagingResultsFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteImagingResultsToJson(this);
}
