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
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  duration: json['duration'] as String,
  route: json['route'] as String,
  specialInstructions: (json['specialInstructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  priorityScore: (json['priorityScore'] as num).toDouble(),
  reasoning: json['reasoning'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RecommendedMedicationToJson(
  RecommendedMedication instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'duration': instance.duration,
  'route': instance.route,
  'specialInstructions': instance.specialInstructions,
  'priorityScore': instance.priorityScore,
  'reasoning': instance.reasoning,
  'metadata': instance.metadata,
};

MedicationAlternative _$MedicationAlternativeFromJson(
  Map<String, dynamic> json,
) => MedicationAlternative(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  alternativeType: json['alternativeType'] as String,
  reasoning: json['reasoning'] as String,
  similarityScore: (json['similarityScore'] as num).toDouble(),
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
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'alternativeType': instance.alternativeType,
  'reasoning': instance.reasoning,
  'similarityScore': instance.similarityScore,
  'advantages': instance.advantages,
  'disadvantages': instance.disadvantages,
  'metadata': instance.metadata,
};

PatientMedicationProfile _$PatientMedicationProfileFromJson(
  Map<String, dynamic> json,
) => PatientMedicationProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  currentMedications: (json['currentMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicationAllergies: (json['medicationAllergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicationIntolerances: (json['medicationIntolerances'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicationHistory: Map<String, String>.from(json['medicationHistory'] as Map),
  geneticFactors: (json['geneticFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  organFunction: json['organFunction'] as Map<String, dynamic>,
  comorbidities: (json['comorbidities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responsePatterns: json['responsePatterns'] as Map<String, dynamic>,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PatientMedicationProfileToJson(
  PatientMedicationProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'currentMedications': instance.currentMedications,
  'medicationAllergies': instance.medicationAllergies,
  'medicationIntolerances': instance.medicationIntolerances,
  'medicationHistory': instance.medicationHistory,
  'geneticFactors': instance.geneticFactors,
  'organFunction': instance.organFunction,
  'comorbidities': instance.comorbidities,
  'responsePatterns': instance.responsePatterns,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
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
  optimizationFactors: (json['optimizationFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  optimizationReasoning: json['optimizationReasoning'] as String,
  monitoringParameters: (json['monitoringParameters'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  titrationPlan: json['titrationPlan'] as String,
  optimizationDate: DateTime.parse(json['optimizationDate'] as String),
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
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
  'optimizationFactors': instance.optimizationFactors,
  'optimizationReasoning': instance.optimizationReasoning,
  'monitoringParameters': instance.monitoringParameters,
  'titrationPlan': instance.titrationPlan,
  'optimizationDate': instance.optimizationDate.toIso8601String(),
  'confidenceScore': instance.confidenceScore,
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
  interactionType: json['interactionType'] as String,
  mechanism: json['mechanism'] as String,
  clinicalSignificance: json['clinicalSignificance'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoring: (json['monitoring'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskScore: (json['riskScore'] as num).toDouble(),
  evidence: json['evidence'] as String,
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AdvancedDrugInteractionToJson(
  AdvancedDrugInteraction instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationIds': instance.medicationIds,
  'medicationNames': instance.medicationNames,
  'severity': _$InteractionSeverityEnumMap[instance.severity]!,
  'interactionType': instance.interactionType,
  'mechanism': instance.mechanism,
  'clinicalSignificance': instance.clinicalSignificance,
  'symptoms': instance.symptoms,
  'riskFactors': instance.riskFactors,
  'recommendations': instance.recommendations,
  'monitoring': instance.monitoring,
  'riskScore': instance.riskScore,
  'evidence': instance.evidence,
  'analysisDate': instance.analysisDate.toIso8601String(),
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
  recommendationId: json['recommendationId'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  status: $enumDecode(_$AIPrescriptionStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  reviewNotes: json['reviewNotes'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  modifications: (json['modifications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AIPrescriptionHistoryToJson(
  AIPrescriptionHistory instance,
) => <String, dynamic>{
  'id': instance.id,
  'recommendationId': instance.recommendationId,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'status': _$AIPrescriptionStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'reviewNotes': instance.reviewNotes,
  'rejectionReason': instance.rejectionReason,
  'modifications': instance.modifications,
  'metadata': instance.metadata,
};

const _$AIPrescriptionStatusEnumMap = {
  AIPrescriptionStatus.pending: 'pending',
  AIPrescriptionStatus.approved: 'approved',
  AIPrescriptionStatus.rejected: 'rejected',
  AIPrescriptionStatus.modified: 'modified',
  AIPrescriptionStatus.underReview: 'under_review',
};
