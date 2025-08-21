import 'package:json_annotation/json_annotation.dart';
import 'medication_models.dart';

part 'advanced_patient_tracking_models.g.dart';

// ===== GELİŞMİŞ HASTA TAKİP SİSTEMİ MODELLERİ =====

@JsonSerializable()
class PatientTrackingProfile {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime startDate;
  final DateTime lastUpdated;
  final String status;
  final List<String> activeModules;
  final List<String> alerts;
  final Map<String, dynamic>? metadata;

  PatientTrackingProfile({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.startDate,
    required this.lastUpdated,
    required this.status,
    required this.activeModules,
    required this.alerts,
    this.metadata,
  });

  factory PatientTrackingProfile.fromJson(Map<String, dynamic> json) =>
      _$PatientTrackingProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PatientTrackingProfileToJson(this);
}

enum TrackingStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('discontinued')
  discontinued,
}

enum TrackingModule {
  @JsonValue('mood_timeline')
  moodTimeline,
  @JsonValue('quality_of_life')
  qualityOfLife,
  @JsonValue('polypharmacy')
  polypharmacy,
  @JsonValue('family_observation')
  familyObservation,
  @JsonValue('symptom_tracking')
  symptomTracking,
  @JsonValue('medication_adherence')
  medicationAdherence,
  @JsonValue('sleep_tracking')
  sleepTracking,
  @JsonValue('activity_tracking')
  activityTracking,
}

// ===== AKILLI MOOD TİMELİNE =====

@JsonSerializable()
class MoodTimeline {
  final String id;
  final String patientId;
  final List<MoodEntry> entries;
  final List<MoodTrend> trends;
  final List<MoodAlert> alerts;
  final MoodAnalysis analysis;

  MoodTimeline({
    required this.id,
    required this.patientId,
    required this.entries,
    required this.trends,
    required this.alerts,
    required this.analysis,
  });

  factory MoodTimeline.fromJson(Map<String, dynamic> json) =>
      _$MoodTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$MoodTimelineToJson(this);
}

@JsonSerializable()
class MoodEntry {
  final String id;
  final DateTime timestamp;
  final double moodScore; // 1-10 scale
  final String moodType;
  final List<String> symptoms;
  final String? notes;
  final String? location;
  final Map<String, dynamic>? context;

  MoodEntry({
    required this.id,
    required this.timestamp,
    required this.moodScore,
    required this.moodType,
    required this.symptoms,
    this.notes,
    this.location,
    this.context,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MoodEntryToJson(this);
}

enum MoodType {
  @JsonValue('very_low')
  veryLow,
  @JsonValue('low')
  low,
  @JsonValue('neutral')
  neutral,
  @JsonValue('elevated')
  elevated,
  @JsonValue('very_elevated')
  veryElevated,
  @JsonValue('mixed')
  mixed,
  @JsonValue('irritable')
  irritable,
}

@JsonSerializable()
class MoodTrend {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String direction;
  final double changeRate;
  final List<String> contributingFactors;
  final double confidence;
  final List<String> recommendations;

  MoodTrend({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.direction,
    required this.changeRate,
    required this.contributingFactors,
    required this.confidence,
    required this.recommendations,
  });

  factory MoodTrend.fromJson(Map<String, dynamic> json) =>
      _$MoodTrendFromJson(json);

  Map<String, dynamic> toJson() => _$MoodTrendToJson(this);
}

enum TrendDirection {
  @JsonValue('improving')
  improving,
  @JsonValue('stable')
  stable,
  @JsonValue('declining')
  declining,
  @JsonValue('fluctuating')
  fluctuating,
}

@JsonSerializable()
class MoodAlert {
  final String id;
  final DateTime timestamp;
  final String type;
  final String message;
  final double severity;
  final List<String> actions;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  MoodAlert({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.message,
    required this.severity,
    required this.actions,
    required this.isAcknowledged,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  factory MoodAlert.fromJson(Map<String, dynamic> json) =>
      _$MoodAlertFromJson(json);

  Map<String, dynamic> toJson() => _$MoodAlertToJson(this);
}

@JsonSerializable()
class MoodAnalysis {
  final String id;
  final DateTime analysisDate;
  final double averageMood;
  final double moodStability;
  final List<String> patterns;
  final List<String> triggers;
  final List<String> recommendations;
  final double confidence;

  MoodAnalysis({
    required this.id,
    required this.analysisDate,
    required this.averageMood,
    required this.moodStability,
    required this.patterns,
    required this.triggers,
    required this.recommendations,
    required this.confidence,
  });

  factory MoodAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MoodAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$MoodAnalysisToJson(this);
}

// ===== YAŞAM KALİTESİ PANELİ =====

@JsonSerializable()
class QualityOfLifePanel {
  final String id;
  final String patientId;
  final List<QualityOfLifeAssessment> assessments;
  final QualityOfLifeTrend trend;
  final List<String> recommendations;

  QualityOfLifePanel({
    required this.id,
    required this.patientId,
    required this.assessments,
    required this.trend,
    required this.recommendations,
  });

  factory QualityOfLifePanel.fromJson(Map<String, dynamic> json) =>
      _$QualityOfLifePanelFromJson(json);

  Map<String, dynamic> toJson() => _$QualityOfLifePanelToJson(this);
}

@JsonSerializable()
class QualityOfLifeAssessment {
  final String id;
  final DateTime assessmentDate;
  final String scale; // WHOQOL, SF-36, etc.
  final Map<String, double> domainScores;
  final double overallScore;
  final List<String> notes;
  final String? clinicianNotes;

  QualityOfLifeAssessment({
    required this.id,
    required this.assessmentDate,
    required this.scale,
    required this.domainScores,
    required this.overallScore,
    required this.notes,
    this.clinicianNotes,
  });

  factory QualityOfLifeAssessment.fromJson(Map<String, dynamic> json) =>
      _$QualityOfLifeAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$QualityOfLifeAssessmentToJson(this);
}

@JsonSerializable()
class QualityOfLifeTrend {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> domainChanges;
  final double overallChange;
  final List<String> significantChanges;
  final List<String> contributingFactors;

  QualityOfLifeTrend({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.domainChanges,
    required this.overallChange,
    required this.significantChanges,
    required this.contributingFactors,
  });

  factory QualityOfLifeTrend.fromJson(Map<String, dynamic> json) =>
      _$QualityOfLifeTrendFromJson(json);

  Map<String, dynamic> toJson() => _$QualityOfLifeTrendToJson(this);
}

// ===== POLYPHARMACY TRACKER =====

@JsonSerializable()
class PolypharmacyTracker {
  final String id;
  final String patientId;
  final List<String> activeMedications;
  final int medicationCount;
  final String riskLevel;
  final List<DrugInteraction> interactions;
  final List<SideEffect> sideEffects;
  final double adherenceScore;
  final List<String> recommendations;
  final List<String> alerts;

  PolypharmacyTracker({
    required this.id,
    required this.patientId,
    required this.activeMedications,
    required this.medicationCount,
    required this.riskLevel,
    required this.interactions,
    required this.sideEffects,
    required this.adherenceScore,
    required this.recommendations,
    required this.alerts,
  });

  factory PolypharmacyTracker.fromJson(Map<String, dynamic> json) =>
      _$PolypharmacyTrackerFromJson(json);

  Map<String, dynamic> toJson() => _$PolypharmacyTrackerToJson(this);
}

enum PolypharmacyRisk {
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@JsonSerializable()
class SideEffect {
  final String id;
  final String medicationId;
  final String medicationName;
  final String symptom;
  final String severity;
  final DateTime onsetDate;
  final DateTime? resolutionDate;
  final String? notes;
  final List<String> actions;

  SideEffect({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.symptom,
    required this.severity,
    required this.onsetDate,
    this.resolutionDate,
    this.notes,
    required this.actions,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) =>
      _$SideEffectFromJson(json);

  Map<String, dynamic> toJson() => _$SideEffectToJson(this);
}

enum SideEffectSeverity {
  @JsonValue('mild')
  mild,
  @JsonValue('moderate')
  moderate,
  @JsonValue('severe')
  severe,
  @JsonValue('life_threatening')
  lifeThreatening,
}

// ===== AİLE GÖZLEM MODÜLÜ =====

@JsonSerializable()
class FamilyObservationModule {
  final String id;
  final String patientId;
  final List<FamilyMember> familyMembers;
  final List<FamilyAssessment> assessments;
  final List<FamilyAlert> alerts;
  final String supportLevel;

  FamilyObservationModule({
    required this.id,
    required this.patientId,
    required this.familyMembers,
    required this.assessments,
    required this.alerts,
    required this.supportLevel,
  });

  factory FamilyObservationModule.fromJson(Map<String, dynamic> json) =>
      _$FamilyObservationModuleFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyObservationModuleToJson(this);
}

@JsonSerializable()
class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final int age;
  final String? contactInfo;
  final bool isPrimaryCaregiver;
  final List<String> observations;
  final DateTime lastContact;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.age,
    this.contactInfo,
    required this.isPrimaryCaregiver,
    required this.observations,
    required this.lastContact,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyMemberToJson(this);
}

@JsonSerializable()
class FamilyAssessment {
  final String id;
  final DateTime assessmentDate;
  final String familyMemberId;
  final String familyMemberName;
  final Map<String, double> scaleScores;
  final List<String> observations;
  final List<String> concerns;
  final List<String> recommendations;

  FamilyAssessment({
    required this.id,
    required this.assessmentDate,
    required this.familyMemberId,
    required this.familyMemberName,
    required this.scaleScores,
    required this.observations,
    required this.concerns,
    required this.recommendations,
  });

  factory FamilyAssessment.fromJson(Map<String, dynamic> json) =>
      _$FamilyAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyAssessmentToJson(this);
}

@JsonSerializable()
class FamilyAlert {
  final String id;
  final DateTime timestamp;
  final String familyMemberId;
  final String familyMemberName;
  final String type;
  final String message;
  final double severity;
  final List<String> actions;
  final bool isAcknowledged;

  FamilyAlert({
    required this.id,
    required this.timestamp,
    required this.familyMemberId,
    required this.familyMemberName,
    required this.type,
    required this.message,
    required this.severity,
    required this.actions,
    required this.isAcknowledged,
  });

  factory FamilyAlert.fromJson(Map<String, dynamic> json) =>
      _$FamilyAlertFromJson(json);

  Map<String, dynamic> toJson() => _$FamilyAlertToJson(this);
}

enum FamilySupportLevel {
  @JsonValue('excellent')
  excellent,
  @JsonValue('good')
  good,
  @JsonValue('moderate')
  moderate,
  @JsonValue('poor')
  poor,
  @JsonValue('absent')
  absent,
}

// ===== HASTA TAKİP ÖZETİ =====

@JsonSerializable()
class PatientTrackingSummary {
  final String id;
  final String patientId;
  final DateTime summaryDate;
  final String overallStatus;
  final MoodAnalysis moodAnalysis;
  final QualityOfLifeTrend qualityOfLifeTrend;
  final String polypharmacyRisk;
  final String familySupport;
  final List<String> criticalAlerts;
  final List<String> recommendations;
  final double overallProgress;
  final Map<String, dynamic>? metadata;

  PatientTrackingSummary({
    required this.id,
    required this.patientId,
    required this.summaryDate,
    required this.overallStatus,
    required this.moodAnalysis,
    required this.qualityOfLifeTrend,
    required this.polypharmacyRisk,
    required this.familySupport,
    required this.criticalAlerts,
    required this.recommendations,
    required this.overallProgress,
    this.metadata,
  });

  factory PatientTrackingSummary.fromJson(Map<String, dynamic> json) =>
      _$PatientTrackingSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PatientTrackingSummaryToJson(this);
}
