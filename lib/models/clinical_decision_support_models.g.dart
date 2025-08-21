// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_decision_support_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicalDecisionTree _$ClinicalDecisionTreeFromJson(
  Map<String, dynamic> json,
) => ClinicalDecisionTree(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  rootNode: DecisionNode.fromJson(json['rootNode'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  source: json['source'] as String,
  version: json['version'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$ClinicalDecisionTreeToJson(
  ClinicalDecisionTree instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'rootNode': instance.rootNode,
  'tags': instance.tags,
  'source': instance.source,
  'version': instance.version,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'isActive': instance.isActive,
};

DecisionNode _$DecisionNodeFromJson(Map<String, dynamic> json) => DecisionNode(
  id: json['id'] as String,
  question: json['question'] as String,
  description: json['description'] as String?,
  options: (json['options'] as List<dynamic>)
      .map((e) => DecisionOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: $enumDecode(_$DecisionNodeTypeEnumMap, json['type']),
  criteria: json['criteria'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DecisionNodeToJson(DecisionNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'description': instance.description,
      'options': instance.options,
      'type': _$DecisionNodeTypeEnumMap[instance.type]!,
      'criteria': instance.criteria,
      'metadata': instance.metadata,
    };

const _$DecisionNodeTypeEnumMap = {
  DecisionNodeType.symptom: 'symptom',
  DecisionNodeType.diagnosis: 'diagnosis',
  DecisionNodeType.treatment: 'treatment',
  DecisionNodeType.medication: 'medication',
  DecisionNodeType.riskAssessment: 'risk_assessment',
  DecisionNodeType.outcome: 'outcome',
};

DecisionOption _$DecisionOptionFromJson(Map<String, dynamic> json) =>
    DecisionOption(
      id: json['id'] as String,
      text: json['text'] as String,
      value: json['value'] as String?,
      nextNode: json['nextNode'] == null
          ? null
          : DecisionNode.fromJson(json['nextNode'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num?)?.toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DecisionOptionToJson(DecisionOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'value': instance.value,
      'nextNode': instance.nextNode,
      'confidence': instance.confidence,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
    };

DrugInteractionSimulation _$DrugInteractionSimulationFromJson(
  Map<String, dynamic> json,
) => DrugInteractionSimulation(
  id: json['id'] as String,
  medicationIds: (json['medicationIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallSeverity: $enumDecode(
    _$InteractionSeverityEnumMap,
    json['overallSeverity'],
  ),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  simulationDate: DateTime.parse(json['simulationDate'] as String),
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
);

Map<String, dynamic> _$DrugInteractionSimulationToJson(
  DrugInteractionSimulation instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationIds': instance.medicationIds,
  'interactions': instance.interactions,
  'overallSeverity': _$InteractionSeverityEnumMap[instance.overallSeverity]!,
  'warnings': instance.warnings,
  'recommendations': instance.recommendations,
  'simulationDate': instance.simulationDate.toIso8601String(),
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
};

const _$InteractionSeverityEnumMap = {
  InteractionSeverity.none: 'none',
  InteractionSeverity.minor: 'minor',
  InteractionSeverity.moderate: 'moderate',
  InteractionSeverity.major: 'major',
  InteractionSeverity.contraindicated: 'contraindicated',
};

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) =>
    DrugInteraction(
      id: json['id'] as String,
      drug1Id: json['drug1Id'] as String,
      drug2Id: json['drug2Id'] as String,
      drug1Name: json['drug1Name'] as String,
      drug2Name: json['drug2Name'] as String,
      type: $enumDecode(_$InteractionTypeEnumMap, json['type']),
      severity: $enumDecode(_$InteractionSeverityEnumMap, json['severity']),
      mechanism: json['mechanism'] as String,
      description: json['description'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskScore: (json['riskScore'] as num?)?.toDouble(),
      pharmacokinetics: json['pharmacokinetics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DrugInteractionToJson(DrugInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drug1Id': instance.drug1Id,
      'drug2Id': instance.drug2Id,
      'drug1Name': instance.drug1Name,
      'drug2Name': instance.drug2Name,
      'type': _$InteractionTypeEnumMap[instance.type]!,
      'severity': _$InteractionSeverityEnumMap[instance.severity]!,
      'mechanism': instance.mechanism,
      'description': instance.description,
      'symptoms': instance.symptoms,
      'recommendations': instance.recommendations,
      'riskScore': instance.riskScore,
      'pharmacokinetics': instance.pharmacokinetics,
    };

const _$InteractionTypeEnumMap = {
  InteractionType.pharmacokinetic: 'pharmacokinetic',
  InteractionType.pharmacodynamic: 'pharmacodynamic',
  InteractionType.absorption: 'absorption',
  InteractionType.distribution: 'distribution',
  InteractionType.metabolism: 'metabolism',
  InteractionType.excretion: 'excretion',
};

PharmacogeneticProfile _$PharmacogeneticProfileFromJson(
  Map<String, dynamic> json,
) => PharmacogeneticProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  testDate: DateTime.parse(json['testDate'] as String),
  variants: (json['variants'] as List<dynamic>)
      .map((e) => GeneticVariant.fromJson(e as Map<String, dynamic>))
      .toList(),
  drugMetabolisms: (json['drugMetabolisms'] as List<dynamic>)
      .map((e) => DrugMetabolism.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  labReportUrl: json['labReportUrl'] as String?,
  clinicianNotes: json['clinicianNotes'] as String?,
);

Map<String, dynamic> _$PharmacogeneticProfileToJson(
  PharmacogeneticProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'testDate': instance.testDate.toIso8601String(),
  'variants': instance.variants,
  'drugMetabolisms': instance.drugMetabolisms,
  'recommendations': instance.recommendations,
  'labReportUrl': instance.labReportUrl,
  'clinicianNotes': instance.clinicianNotes,
};

GeneticVariant _$GeneticVariantFromJson(Map<String, dynamic> json) =>
    GeneticVariant(
      id: json['id'] as String,
      gene: json['gene'] as String,
      variant: json['variant'] as String,
      rsId: json['rsId'] as String,
      chromosome: json['chromosome'] as String,
      position: (json['position'] as num).toInt(),
      reference: json['reference'] as String,
      alternate: json['alternate'] as String,
      genotype: json['genotype'] as String,
      phenotype: json['phenotype'] as String,
      frequency: (json['frequency'] as num?)?.toDouble(),
      clinicalSignificance: json['clinicalSignificance'] as String?,
    );

Map<String, dynamic> _$GeneticVariantToJson(GeneticVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gene': instance.gene,
      'variant': instance.variant,
      'rsId': instance.rsId,
      'chromosome': instance.chromosome,
      'position': instance.position,
      'reference': instance.reference,
      'alternate': instance.alternate,
      'genotype': instance.genotype,
      'phenotype': instance.phenotype,
      'frequency': instance.frequency,
      'clinicalSignificance': instance.clinicalSignificance,
    };

DrugMetabolism _$DrugMetabolismFromJson(Map<String, dynamic> json) =>
    DrugMetabolism(
      id: json['id'] as String,
      drugId: json['drugId'] as String,
      drugName: json['drugName'] as String,
      gene: json['gene'] as String,
      status: $enumDecode(_$MetabolismStatusEnumMap, json['status']),
      phenotype: json['phenotype'] as String,
      recommendation: json['recommendation'] as String,
      doseAdjustment: (json['doseAdjustment'] as num?)?.toDouble(),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evidence: json['evidence'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DrugMetabolismToJson(DrugMetabolism instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugId': instance.drugId,
      'drugName': instance.drugName,
      'gene': instance.gene,
      'status': _$MetabolismStatusEnumMap[instance.status]!,
      'phenotype': instance.phenotype,
      'recommendation': instance.recommendation,
      'doseAdjustment': instance.doseAdjustment,
      'alternatives': instance.alternatives,
      'evidence': instance.evidence,
    };

const _$MetabolismStatusEnumMap = {
  MetabolismStatus.normal: 'normal',
  MetabolismStatus.intermediate: 'intermediate',
  MetabolismStatus.poor: 'poor',
  MetabolismStatus.ultrarapid: 'ultrarapid',
  MetabolismStatus.unknown: 'unknown',
};

TreatmentResistanceAlgorithm _$TreatmentResistanceAlgorithmFromJson(
  Map<String, dynamic> json,
) => TreatmentResistanceAlgorithm(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  steps: (json['steps'] as List<dynamic>)
      .map((e) => TreatmentStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  criteria: (json['criteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  source: json['source'] as String,
  version: json['version'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$TreatmentResistanceAlgorithmToJson(
  TreatmentResistanceAlgorithm instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'steps': instance.steps,
  'criteria': instance.criteria,
  'source': instance.source,
  'version': instance.version,
  'isActive': instance.isActive,
};

TreatmentStep _$TreatmentStepFromJson(Map<String, dynamic> json) =>
    TreatmentStep(
      id: json['id'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapies: (json['therapies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: DurationPeriod.fromJson(
        json['duration'] as Map<String, dynamic>,
      ),
      successCriteria: (json['successCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      failureCriteria: (json['failureCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextStep: json['nextStep'] == null
          ? null
          : TreatmentStep.fromJson(json['nextStep'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TreatmentStepToJson(TreatmentStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'name': instance.name,
      'description': instance.description,
      'medications': instance.medications,
      'therapies': instance.therapies,
      'duration': instance.duration,
      'successCriteria': instance.successCriteria,
      'failureCriteria': instance.failureCriteria,
      'nextStep': instance.nextStep,
      'metadata': instance.metadata,
    };

DurationPeriod _$DurationPeriodFromJson(Map<String, dynamic> json) =>
    DurationPeriod(
      value: (json['value'] as num).toInt(),
      unit: $enumDecode(_$DurationUnitEnumMap, json['unit']),
    );

Map<String, dynamic> _$DurationPeriodToJson(DurationPeriod instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': _$DurationUnitEnumMap[instance.unit]!,
    };

const _$DurationUnitEnumMap = {
  DurationUnit.days: 'days',
  DurationUnit.weeks: 'weeks',
  DurationUnit.months: 'months',
};

TreatmentRecommendation _$TreatmentRecommendationFromJson(
  Map<String, dynamic> json,
) => TreatmentRecommendation(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  recommendationDate: DateTime.parse(json['recommendationDate'] as String),
  diagnosis: json['diagnosis'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  options: (json['options'] as List<dynamic>)
      .map((e) => TreatmentOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendedOption: json['recommendedOption'] == null
      ? null
      : TreatmentOption.fromJson(
          json['recommendedOption'] as Map<String, dynamic>,
        ),
  confidence: (json['confidence'] as num).toDouble(),
  reasoning: (json['reasoning'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$TreatmentRecommendationToJson(
  TreatmentRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'recommendationDate': instance.recommendationDate.toIso8601String(),
  'diagnosis': instance.diagnosis,
  'symptoms': instance.symptoms,
  'options': instance.options,
  'recommendedOption': instance.recommendedOption,
  'confidence': instance.confidence,
  'reasoning': instance.reasoning,
  'contraindications': instance.contraindications,
  'warnings': instance.warnings,
  'metadata': instance.metadata,
};

TreatmentOption _$TreatmentOptionFromJson(Map<String, dynamic> json) =>
    TreatmentOption(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapies: (json['therapies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: DurationPeriod.fromJson(
        json['duration'] as Map<String, dynamic>,
      ),
      efficacy: (json['efficacy'] as num).toDouble(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      cost: (json['cost'] as num).toDouble(),
      evidenceLevel: json['evidenceLevel'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TreatmentOptionToJson(TreatmentOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'medications': instance.medications,
      'therapies': instance.therapies,
      'duration': instance.duration,
      'efficacy': instance.efficacy,
      'sideEffects': instance.sideEffects,
      'contraindications': instance.contraindications,
      'cost': instance.cost,
      'evidenceLevel': instance.evidenceLevel,
      'metadata': instance.metadata,
    };

CDSSResult _$CDSSResultFromJson(Map<String, dynamic> json) => CDSSResult(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  analysisType: json['analysisType'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  diagnosis: json['diagnosis'] as String?,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => TreatmentRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  drugInteractions: (json['drugInteractions'] as List<dynamic>)
      .map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
      .toList(),
  pharmacogeneticProfile: json['pharmacogeneticProfile'] == null
      ? null
      : PharmacogeneticProfile.fromJson(
          json['pharmacogeneticProfile'] as Map<String, dynamic>,
        ),
  confidence: (json['confidence'] as num).toDouble(),
  reasoning: (json['reasoning'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CDSSResultToJson(CDSSResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'analysisType': instance.analysisType,
      'symptoms': instance.symptoms,
      'diagnosis': instance.diagnosis,
      'recommendations': instance.recommendations,
      'drugInteractions': instance.drugInteractions,
      'pharmacogeneticProfile': instance.pharmacogeneticProfile,
      'confidence': instance.confidence,
      'reasoning': instance.reasoning,
      'warnings': instance.warnings,
      'metadata': instance.metadata,
    };
