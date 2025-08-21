import 'package:json_annotation/json_annotation.dart';

part 'clinical_decision_support_models.g.dart';

// ===== KLİNİK KARAR DESTEK SİSTEMİ (CDSS) MODELLERİ =====

@JsonSerializable()
class ClinicalDecisionTree {
  final String id;
  final String name;
  final String description;
  final DecisionNode rootNode;
  final List<String> tags;
  final String source; // DSM-5, ICD-11, NICE, APA, CANMAT
  final String version;
  final DateTime lastUpdated;
  final bool isActive;

  ClinicalDecisionTree({
    required this.id,
    required this.name,
    required this.description,
    required this.rootNode,
    required this.tags,
    required this.source,
    required this.version,
    required this.lastUpdated,
    required this.isActive,
  });

  factory ClinicalDecisionTree.fromJson(Map<String, dynamic> json) =>
      _$ClinicalDecisionTreeFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicalDecisionTreeToJson(this);
}

@JsonSerializable()
class DecisionNode {
  final String id;
  final String question;
  final String? description;
  final List<DecisionOption> options;
  final DecisionNodeType type;
  final String? criteria;
  final Map<String, dynamic>? metadata;

  DecisionNode({
    required this.id,
    required this.question,
    this.description,
    required this.options,
    required this.type,
    this.criteria,
    this.metadata,
  });

  factory DecisionNode.fromJson(Map<String, dynamic> json) =>
      _$DecisionNodeFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionNodeToJson(this);
}

@JsonSerializable()
class DecisionOption {
  final String id;
  final String text;
  final String? value;
  final DecisionNode? nextNode;
  final double? confidence;
  final List<String>? recommendations;
  final Map<String, dynamic>? metadata;

  DecisionOption({
    required this.id,
    required this.text,
    this.value,
    this.nextNode,
    this.confidence,
    this.recommendations,
    this.metadata,
  });

  factory DecisionOption.fromJson(Map<String, dynamic> json) =>
      _$DecisionOptionFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionOptionToJson(this);
}

enum DecisionNodeType {
  @JsonValue('symptom')
  symptom,
  @JsonValue('diagnosis')
  diagnosis,
  @JsonValue('treatment')
  treatment,
  @JsonValue('medication')
  medication,
  @JsonValue('risk_assessment')
  riskAssessment,
  @JsonValue('outcome')
  outcome,
}

// ===== İLAÇ ETKİLEŞİM SİMÜLATÖRÜ =====

@JsonSerializable()
class DrugInteractionSimulation {
  final String id;
  final List<String> medicationIds;
  final List<DrugInteraction> interactions;
  final InteractionSeverity overallSeverity;
  final List<String> warnings;
  final List<String> recommendations;
  final DateTime simulationDate;
  final String patientId;
  final String clinicianId;

  DrugInteractionSimulation({
    required this.id,
    required this.medicationIds,
    required this.interactions,
    required this.overallSeverity,
    required this.warnings,
    required this.recommendations,
    required this.simulationDate,
    required this.patientId,
    required this.clinicianId,
  });

  factory DrugInteractionSimulation.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionSimulationFromJson(json);

  Map<String, dynamic> toJson() => _$DrugInteractionSimulationToJson(this);
}

@JsonSerializable()
class DrugInteraction {
  final String id;
  final String drug1Id;
  final String drug2Id;
  final String drug1Name;
  final String drug2Name;
  final InteractionType type;
  final InteractionSeverity severity;
  final String mechanism;
  final String description;
  final List<String> symptoms;
  final List<String> recommendations;
  final double? riskScore;
  final Map<String, dynamic>? pharmacokinetics;

  DrugInteraction({
    required this.id,
    required this.drug1Id,
    required this.drug2Id,
    required this.drug1Name,
    required this.drug2Name,
    required this.type,
    required this.severity,
    required this.mechanism,
    required this.description,
    required this.symptoms,
    required this.recommendations,
    this.riskScore,
    this.pharmacokinetics,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$DrugInteractionToJson(this);
}

enum InteractionType {
  @JsonValue('pharmacokinetic')
  pharmacokinetic,
  @JsonValue('pharmacodynamic')
  pharmacodynamic,
  @JsonValue('absorption')
  absorption,
  @JsonValue('distribution')
  distribution,
  @JsonValue('metabolism')
  metabolism,
  @JsonValue('excretion')
  excretion,
}

enum InteractionSeverity {
  @JsonValue('none')
  none,
  @JsonValue('minor')
  minor,
  @JsonValue('moderate')
  moderate,
  @JsonValue('major')
  major,
  @JsonValue('contraindicated')
  contraindicated,
}

// ===== FARMAKOGENETİK API =====

@JsonSerializable()
class PharmacogeneticProfile {
  final String id;
  final String patientId;
  final DateTime testDate;
  final List<GeneticVariant> variants;
  final List<DrugMetabolism> drugMetabolisms;
  final List<String> recommendations;
  final String? labReportUrl;
  final String? clinicianNotes;

  PharmacogeneticProfile({
    required this.id,
    required this.patientId,
    required this.testDate,
    required this.variants,
    required this.drugMetabolisms,
    required this.recommendations,
    this.labReportUrl,
    this.clinicianNotes,
  });

  factory PharmacogeneticProfile.fromJson(Map<String, dynamic> json) =>
      _$PharmacogeneticProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PharmacogeneticProfileToJson(this);
}

@JsonSerializable()
class GeneticVariant {
  final String id;
  final String gene;
  final String variant;
  final String rsId;
  final String chromosome;
  final int position;
  final String reference;
  final String alternate;
  final String genotype;
  final String phenotype;
  final double? frequency;
  final String? clinicalSignificance;

  GeneticVariant({
    required this.id,
    required this.gene,
    required this.variant,
    required this.rsId,
    required this.chromosome,
    required this.position,
    required this.reference,
    required this.alternate,
    required this.genotype,
    required this.phenotype,
    this.frequency,
    this.clinicalSignificance,
  });

  factory GeneticVariant.fromJson(Map<String, dynamic> json) =>
      _$GeneticVariantFromJson(json);

  Map<String, dynamic> toJson() => _$GeneticVariantToJson(this);
}

@JsonSerializable()
class DrugMetabolism {
  final String id;
  final String drugId;
  final String drugName;
  final String gene;
  final MetabolismStatus status;
  final String phenotype;
  final String recommendation;
  final double? doseAdjustment;
  final List<String> alternatives;
  final Map<String, dynamic>? evidence;

  DrugMetabolism({
    required this.id,
    required this.drugId,
    required this.drugName,
    required this.gene,
    required this.status,
    required this.phenotype,
    required this.recommendation,
    this.doseAdjustment,
    required this.alternatives,
    this.evidence,
  });

  factory DrugMetabolism.fromJson(Map<String, dynamic> json) =>
      _$DrugMetabolismFromJson(json);

  Map<String, dynamic> toJson() => _$DrugMetabolismToJson(this);
}

enum MetabolismStatus {
  @JsonValue('normal')
  normal,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('poor')
  poor,
  @JsonValue('ultrarapid')
  ultrarapid,
  @JsonValue('unknown')
  unknown,
}

// ===== TEDAVİ DİRENCİ ALGORİTMASI =====

@JsonSerializable()
class TreatmentResistanceAlgorithm {
  final String id;
  final String name;
  final String description;
  final List<TreatmentStep> steps;
  final List<String> criteria;
  final String source;
  final String version;
  final bool isActive;

  TreatmentResistanceAlgorithm({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.criteria,
    required this.source,
    required this.version,
    required this.isActive,
  });

  factory TreatmentResistanceAlgorithm.fromJson(Map<String, dynamic> json) =>
      _$TreatmentResistanceAlgorithmFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentResistanceAlgorithmToJson(this);
}

@JsonSerializable()
class TreatmentStep {
  final String id;
  final int stepNumber;
  final String name;
  final String description;
  final List<String> medications;
  final List<String> therapies;
  final DurationPeriod duration;
  final List<String> successCriteria;
  final List<String> failureCriteria;
  final TreatmentStep? nextStep;
  final Map<String, dynamic>? metadata;

  TreatmentStep({
    required this.id,
    required this.stepNumber,
    required this.name,
    required this.description,
    required this.medications,
    required this.therapies,
    required this.duration,
    required this.successCriteria,
    required this.failureCriteria,
    this.nextStep,
    this.metadata,
  });

  factory TreatmentStep.fromJson(Map<String, dynamic> json) =>
      _$TreatmentStepFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentStepToJson(this);
}

@JsonSerializable()
class DurationPeriod {
  final int value;
  final DurationUnit unit;

  DurationPeriod({
    required this.value,
    required this.unit,
  });

  factory DurationPeriod.fromJson(Map<String, dynamic> json) =>
      _$DurationPeriodFromJson(json);

  Map<String, dynamic> toJson() => _$DurationPeriodToJson(this);
}

enum DurationUnit {
  @JsonValue('days')
  days,
  @JsonValue('weeks')
  weeks,
  @JsonValue('months')
  months,
}

// ===== TEDAVİ ÖNERİSİ =====

@JsonSerializable()
class TreatmentRecommendation {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime recommendationDate;
  final String diagnosis;
  final List<String> symptoms;
  final List<TreatmentOption> options;
  final TreatmentOption? recommendedOption;
  final double confidence;
  final List<String> reasoning;
  final List<String> contraindications;
  final List<String> warnings;
  final Map<String, dynamic>? metadata;

  TreatmentRecommendation({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.recommendationDate,
    required this.diagnosis,
    required this.symptoms,
    required this.options,
    this.recommendedOption,
    required this.confidence,
    required this.reasoning,
    required this.contraindications,
    required this.warnings,
    this.metadata,
  });

  factory TreatmentRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TreatmentRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentRecommendationToJson(this);
}

@JsonSerializable()
class TreatmentOption {
  final String id;
  final String name;
  final String type; // medication, therapy, combination
  final String description;
  final List<String> medications;
  final List<String> therapies;
  final DurationPeriod duration;
  final double efficacy;
  final List<String> sideEffects;
  final List<String> contraindications;
  final double cost;
  final String evidenceLevel;
  final Map<String, dynamic>? metadata;

  TreatmentOption({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.medications,
    required this.therapies,
    required this.duration,
    required this.efficacy,
    required this.sideEffects,
    required this.contraindications,
    required this.cost,
    required this.evidenceLevel,
    this.metadata,
  });

  factory TreatmentOption.fromJson(Map<String, dynamic> json) =>
      _$TreatmentOptionFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentOptionToJson(this);
}

// ===== CDSS SONUÇ =====

@JsonSerializable()
class CDSSResult {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime analysisDate;
  final String analysisType;
  final List<String> symptoms;
  final String? diagnosis;
  final List<TreatmentRecommendation> recommendations;
  final List<DrugInteraction> drugInteractions;
  final PharmacogeneticProfile? pharmacogeneticProfile;
  final double confidence;
  final List<String> reasoning;
  final List<String> warnings;
  final Map<String, dynamic>? metadata;

  CDSSResult({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.analysisDate,
    required this.analysisType,
    required this.symptoms,
    this.diagnosis,
    required this.recommendations,
    required this.drugInteractions,
    this.pharmacogeneticProfile,
    required this.confidence,
    required this.reasoning,
    required this.warnings,
    this.metadata,
  });

  factory CDSSResult.fromJson(Map<String, dynamic> json) =>
      _$CDSSResultFromJson(json);

  Map<String, dynamic> toJson() => _$CDSSResultToJson(this);
}
