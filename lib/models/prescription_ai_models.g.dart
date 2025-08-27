// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIMedicationRecommendation _$AIMedicationRecommendationFromJson(
  Map<String, dynamic> json,
) => AIMedicationRecommendation(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  recommendationDate: DateTime.parse(json['recommendationDate'] as String),
  aiModel: json['aiModel'] as String,
  aiVersion: json['aiVersion'] as String,
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  recommendedMedications: (json['recommendedMedications'] as List<dynamic>)
      .map((e) => RecommendedMedication.fromJson(e as Map<String, dynamic>))
      .toList(),
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => MedicationAlternative.fromJson(e as Map<String, dynamic>))
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringRequirements: (json['monitoringRequirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  clinicalRationale: json['clinicalRationale'] as String,
  aiAnalysis: json['aiAnalysis'] as Map<String, dynamic>,
  isReviewed: json['isReviewed'] as bool,
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  reviewNotes: json['reviewNotes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AIMedicationRecommendationToJson(
  AIMedicationRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'recommendationDate': instance.recommendationDate.toIso8601String(),
  'aiModel': instance.aiModel,
  'aiVersion': instance.aiVersion,
  'confidenceScore': instance.confidenceScore,
  'recommendedMedications': instance.recommendedMedications,
  'alternatives': instance.alternatives,
  'contraindications': instance.contraindications,
  'warnings': instance.warnings,
  'monitoringRequirements': instance.monitoringRequirements,
  'clinicalRationale': instance.clinicalRationale,
  'aiAnalysis': instance.aiAnalysis,
  'isReviewed': instance.isReviewed,
  'reviewedBy': instance.reviewedBy,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'reviewNotes': instance.reviewNotes,
  'metadata': instance.metadata,
};

RecommendedMedication _$RecommendedMedicationFromJson(
  Map<String, dynamic> json,
) => RecommendedMedication(
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
  titrationSchedule: json['titrationSchedule'] as String,
  efficacyScore: (json['efficacyScore'] as num).toDouble(),
  safetyScore: (json['safetyScore'] as num).toDouble(),
  costEffectivenessScore: (json['costEffectivenessScore'] as num).toDouble(),
  expectedBenefits: (json['expectedBenefits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  potentialRisks: (json['potentialRisks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringParameters: (json['monitoringParameters'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RecommendedMedicationToJson(
  RecommendedMedication instance,
) => <String, dynamic>{
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'durationDays': instance.durationDays,
  'titrationSchedule': instance.titrationSchedule,
  'efficacyScore': instance.efficacyScore,
  'safetyScore': instance.safetyScore,
  'costEffectivenessScore': instance.costEffectivenessScore,
  'expectedBenefits': instance.expectedBenefits,
  'potentialRisks': instance.potentialRisks,
  'monitoringParameters': instance.monitoringParameters,
  'metadata': instance.metadata,
};

MedicationAlternative _$MedicationAlternativeFromJson(
  Map<String, dynamic> json,
) => MedicationAlternative(
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  reason: json['reason'] as String,
  similarityScore: (json['similarityScore'] as num).toDouble(),
  costDifference: (json['costDifference'] as num).toDouble(),
  advantages: (json['advantages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  disadvantages: (json['disadvantages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationAlternativeToJson(
  MedicationAlternative instance,
) => <String, dynamic>{
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'reason': instance.reason,
  'similarityScore': instance.similarityScore,
  'costDifference': instance.costDifference,
  'advantages': instance.advantages,
  'disadvantages': instance.disadvantages,
  'metadata': instance.metadata,
};

PatientMedicationProfile _$PatientMedicationProfileFromJson(
  Map<String, dynamic> json,
) => PatientMedicationProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  profileDate: DateTime.parse(json['profileDate'] as String),
  currentDiagnoses: (json['currentDiagnoses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  currentMedications: (json['currentMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  allergies: (json['allergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  intolerances: (json['intolerances'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  previousMedications: (json['previousMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  adverseReactions: (json['adverseReactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  familyHistory: (json['familyHistory'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  comorbidities: (json['comorbidities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lifestyleFactors: (json['lifestyleFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  labResults: json['labResults'] as Map<String, dynamic>,
  vitalSigns: json['vitalSigns'] as Map<String, dynamic>,
  geneticFactors: json['geneticFactors'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PatientMedicationProfileToJson(
  PatientMedicationProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'profileDate': instance.profileDate.toIso8601String(),
  'currentDiagnoses': instance.currentDiagnoses,
  'currentMedications': instance.currentMedications,
  'allergies': instance.allergies,
  'intolerances': instance.intolerances,
  'previousMedications': instance.previousMedications,
  'adverseReactions': instance.adverseReactions,
  'familyHistory': instance.familyHistory,
  'comorbidities': instance.comorbidities,
  'lifestyleFactors': instance.lifestyleFactors,
  'labResults': instance.labResults,
  'vitalSigns': instance.vitalSigns,
  'geneticFactors': instance.geneticFactors,
  'metadata': instance.metadata,
};

SmartDosageOptimization _$SmartDosageOptimizationFromJson(
  Map<String, dynamic> json,
) => SmartDosageOptimization(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  medicationId: json['medicationId'] as String,
  currentDosage: json['currentDosage'] as String,
  optimizedDosage: json['optimizedDosage'] as String,
  titrationSchedule: json['titrationSchedule'] as String,
  optimizationFactors: (json['optimizationFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  expectedEfficacy: (json['expectedEfficacy'] as num).toDouble(),
  expectedSafety: (json['expectedSafety'] as num).toDouble(),
  monitoringPoints: (json['monitoringPoints'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  optimizationDate: DateTime.parse(json['optimizationDate'] as String),
  aiModel: json['aiModel'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SmartDosageOptimizationToJson(
  SmartDosageOptimization instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'medicationId': instance.medicationId,
  'currentDosage': instance.currentDosage,
  'optimizedDosage': instance.optimizedDosage,
  'titrationSchedule': instance.titrationSchedule,
  'optimizationFactors': instance.optimizationFactors,
  'expectedEfficacy': instance.expectedEfficacy,
  'expectedSafety': instance.expectedSafety,
  'monitoringPoints': instance.monitoringPoints,
  'optimizationDate': instance.optimizationDate.toIso8601String(),
  'aiModel': instance.aiModel,
  'metadata': instance.metadata,
};

AdvancedDrugInteraction _$AdvancedDrugInteractionFromJson(
  Map<String, dynamic> json,
) => AdvancedDrugInteraction(
  id: json['id'] as String,
  medicationIds: (json['medicationIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicationNames: (json['medicationNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  severity: $enumDecode(_$InteractionSeverityEnumMap, json['severity']),
  mechanism: json['mechanism'] as String,
  clinicalSignificance: json['clinicalSignificance'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringRequirements: (json['monitoringRequirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskScore: (json['riskScore'] as num).toDouble(),
  evidenceLevel: json['evidenceLevel'] as String,
  references: (json['references'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AdvancedDrugInteractionToJson(
  AdvancedDrugInteraction instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationIds': instance.medicationIds,
  'medicationNames': instance.medicationNames,
  'severity': _$InteractionSeverityEnumMap[instance.severity]!,
  'mechanism': instance.mechanism,
  'clinicalSignificance': instance.clinicalSignificance,
  'symptoms': instance.symptoms,
  'recommendations': instance.recommendations,
  'monitoringRequirements': instance.monitoringRequirements,
  'riskScore': instance.riskScore,
  'evidenceLevel': instance.evidenceLevel,
  'references': instance.references,
  'metadata': instance.metadata,
};

const _$InteractionSeverityEnumMap = {
  InteractionSeverity.none: 'none',
  InteractionSeverity.mild: 'mild',
  InteractionSeverity.moderate: 'moderate',
  InteractionSeverity.major: 'major',
  InteractionSeverity.contraindicated: 'contraindicated',
};

AIPrescriptionHistory _$AIPrescriptionHistoryFromJson(
  Map<String, dynamic> json,
) => AIPrescriptionHistory(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
  status: $enumDecode(_$AIPrescriptionStatusEnumMap, json['status']),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  diagnosis: json['diagnosis'] as String,
  aiRecommendation: json['aiRecommendation'] as String,
  aiConfidence: (json['aiConfidence'] as num).toDouble(),
  rejectionReason: json['rejectionReason'] as String?,
  modificationNotes: json['modificationNotes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AIPrescriptionHistoryToJson(
  AIPrescriptionHistory instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'prescriptionDate': instance.prescriptionDate.toIso8601String(),
  'status': _$AIPrescriptionStatusEnumMap[instance.status]!,
  'medications': instance.medications,
  'diagnosis': instance.diagnosis,
  'aiRecommendation': instance.aiRecommendation,
  'aiConfidence': instance.aiConfidence,
  'rejectionReason': instance.rejectionReason,
  'modificationNotes': instance.modificationNotes,
  'metadata': instance.metadata,
};

const _$AIPrescriptionStatusEnumMap = {
  AIPrescriptionStatus.pending: 'pending',
  AIPrescriptionStatus.approved: 'approved',
  AIPrescriptionStatus.rejected: 'rejected',
  AIPrescriptionStatus.modified: 'modified',
  AIPrescriptionStatus.expired: 'expired',
};
