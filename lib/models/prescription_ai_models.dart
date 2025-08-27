import 'package:json_annotation/json_annotation.dart';

part 'prescription_ai_models.g.dart';

// ===== AI DESTEKLİ REÇETE SİSTEMİ MODELLERİ =====

/// AI İlaç Önerisi - AI medication recommendation
@JsonSerializable()
class AIMedicationRecommendation {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime recommendationDate;
  final String aiModel;
  final String aiVersion;
  final double confidenceScore; // 0-1
  final List<RecommendedMedication> recommendedMedications;
  final List<MedicationAlternative> alternatives;
  final List<String> contraindications;
  final List<String> warnings;
  final List<String> monitoringRequirements;
  final String clinicalRationale;
  final Map<String, dynamic> aiAnalysis;
  final bool isReviewed;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final Map<String, dynamic> metadata;

  const AIMedicationRecommendation({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.recommendationDate,
    required this.aiModel,
    required this.aiVersion,
    required this.confidenceScore,
    required this.recommendedMedications,
    required this.alternatives,
    required this.contraindications,
    required this.warnings,
    required this.monitoringRequirements,
    required this.clinicalRationale,
    required this.aiAnalysis,
    required this.isReviewed,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    required this.metadata,
  });

  factory AIMedicationRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AIMedicationRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$AIMedicationRecommendationToJson(this);
}

/// Önerilen İlaç - Recommended medication
@JsonSerializable()
class RecommendedMedication {
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String titrationSchedule;
  final double efficacyScore; // 0-1
  final double safetyScore; // 0-1
  final double costEffectivenessScore; // 0-1
  final List<String> expectedBenefits;
  final List<String> potentialRisks;
  final List<String> monitoringParameters;
  final Map<String, dynamic> metadata;

  const RecommendedMedication({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.titrationSchedule,
    required this.efficacyScore,
    required this.safetyScore,
    required this.costEffectivenessScore,
    required this.expectedBenefits,
    required this.potentialRisks,
    required this.monitoringParameters,
    required this.metadata,
  });

  factory RecommendedMedication.fromJson(Map<String, dynamic> json) =>
      _$RecommendedMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedMedicationToJson(this);
}

/// İlaç Alternatifi - Medication alternative
@JsonSerializable()
class MedicationAlternative {
  final String medicationId;
  final String medicationName;
  final String reason;
  final double similarityScore; // 0-1
  final double costDifference;
  final List<String> advantages;
  final List<String> disadvantages;
  final Map<String, dynamic> metadata;

  const MedicationAlternative({
    required this.medicationId,
    required this.medicationName,
    required this.reason,
    required this.similarityScore,
    required this.costDifference,
    required this.advantages,
    required this.disadvantages,
    required this.metadata,
  });

  factory MedicationAlternative.fromJson(Map<String, dynamic> json) =>
      _$MedicationAlternativeFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationAlternativeToJson(this);
}

/// Hasta Profili - Patient profile for medication recommendations
@JsonSerializable()
class PatientMedicationProfile {
  final String id;
  final String patientId;
  final DateTime profileDate;
  final List<String> currentDiagnoses;
  final List<String> currentMedications;
  final List<String> allergies;
  final List<String> intolerances;
  final List<String> previousMedications;
  final List<String> adverseReactions;
  final List<String> familyHistory;
  final List<String> comorbidities;
  final List<String> lifestyleFactors;
  final Map<String, dynamic> labResults;
  final Map<String, dynamic> vitalSigns;
  final Map<String, dynamic> geneticFactors;
  final Map<String, dynamic> metadata;

  const PatientMedicationProfile({
    required this.id,
    required this.patientId,
    required this.profileDate,
    required this.currentDiagnoses,
    required this.currentMedications,
    required this.allergies,
    required this.intolerances,
    required this.previousMedications,
    required this.adverseReactions,
    required this.familyHistory,
    required this.comorbidities,
    required this.lifestyleFactors,
    required this.labResults,
    required this.vitalSigns,
    required this.geneticFactors,
    required this.metadata,
  });

  factory PatientMedicationProfile.fromJson(Map<String, dynamic> json) =>
      _$PatientMedicationProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PatientMedicationProfileToJson(this);
}

/// Akıllı Dozaj Optimizasyonu - Smart dosage optimization
@JsonSerializable()
class SmartDosageOptimization {
  final String id;
  final String patientId;
  final String medicationId;
  final String currentDosage;
  final String optimizedDosage;
  final String titrationSchedule;
  final List<String> optimizationFactors;
  final double expectedEfficacy;
  final double expectedSafety;
  final List<String> monitoringPoints;
  final DateTime optimizationDate;
  final String aiModel;
  final Map<String, dynamic> metadata;

  const SmartDosageOptimization({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.currentDosage,
    required this.optimizedDosage,
    required this.titrationSchedule,
    required this.optimizationFactors,
    required this.expectedEfficacy,
    required this.expectedSafety,
    required this.monitoringPoints,
    required this.optimizationDate,
    required this.aiModel,
    required this.metadata,
  });

  factory SmartDosageOptimization.fromJson(Map<String, dynamic> json) =>
      _$SmartDosageOptimizationFromJson(json);

  Map<String, dynamic> toJson() => _$SmartDosageOptimizationToJson(this);
}

/// Gelişmiş Etkileşim Analizi - Advanced interaction analysis
@JsonSerializable()
class AdvancedDrugInteraction {
  final String id;
  final List<String> medicationIds;
  final List<String> medicationNames;
  final InteractionSeverity severity;
  final String mechanism;
  final String clinicalSignificance;
  final List<String> symptoms;
  final List<String> recommendations;
  final List<String> monitoringRequirements;
  final double riskScore; // 0-1
  final String evidenceLevel;
  final List<String> references;
  final Map<String, dynamic> metadata;

  const AdvancedDrugInteraction({
    required this.id,
    required this.medicationIds,
    required this.medicationNames,
    required this.severity,
    required this.mechanism,
    required this.clinicalSignificance,
    required this.symptoms,
    required this.recommendations,
    required this.monitoringRequirements,
    required this.riskScore,
    required this.evidenceLevel,
    required this.references,
    required this.metadata,
  });

  factory AdvancedDrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$AdvancedDrugInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedDrugInteractionToJson(this);
}

/// Etkileşim Şiddeti - Interaction severity
enum InteractionSeverity {
  @JsonValue('none') none,
  @JsonValue('mild') mild,
  @JsonValue('moderate') moderate,
  @JsonValue('major') major,
  @JsonValue('contraindicated') contraindicated,
}

/// AI Reçete Durumu - AI prescription status
enum AIPrescriptionStatus {
  @JsonValue('pending') pending,
  @JsonValue('approved') approved,
  @JsonValue('rejected') rejected,
  @JsonValue('modified') modified,
  @JsonValue('expired') expired,
}

/// AI Reçete Geçmişi - AI prescription history
@JsonSerializable()
class AIPrescriptionHistory {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime prescriptionDate;
  final AIPrescriptionStatus status;
  final List<String> medications;
  final String diagnosis;
  final String aiRecommendation;
  final double aiConfidence;
  final String? rejectionReason;
  final String? modificationNotes;
  final Map<String, dynamic> metadata;

  const AIPrescriptionHistory({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.prescriptionDate,
    required this.status,
    required this.medications,
    required this.diagnosis,
    required this.aiRecommendation,
    required this.aiConfidence,
    this.rejectionReason,
    this.modificationNotes,
    required this.metadata,
  });

  factory AIPrescriptionHistory.fromJson(Map<String, dynamic> json) =>
      _$AIPrescriptionHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$AIPrescriptionHistoryToJson(this);
}
