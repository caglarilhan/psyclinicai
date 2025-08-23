import 'package:json_annotation/json_annotation.dart';

part 'genomic_models.g.dart';

/// Genomic Data Models for PsyClinicAI
/// Provides comprehensive genomic data integration for personalized healthcare

@JsonSerializable()
class GenomicProfile {
  final String id;
  final String patientId;
  final String profileType;
  final DateTime sequencedAt;
  final String sequencingMethod;
  final String sequencingPlatform;
  final Map<String, dynamic> rawData;
  final List<GeneVariant> variants;
  final List<GeneExpression> expressions;
  final List<EpigeneticMark> epigeneticMarks;
  final Map<String, double> qualityMetrics;
  final GenomicProfileStatus status;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  const GenomicProfile({
    required this.id,
    required this.patientId,
    required this.profileType,
    required this.sequencedAt,
    required this.sequencingMethod,
    required this.sequencingPlatform,
    required this.rawData,
    required this.variants,
    required this.expressions,
    required this.epigeneticMarks,
    required this.qualityMetrics,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.metadata,
  });

  factory GenomicProfile.fromJson(Map<String, dynamic> json) => _$GenomicProfileFromJson(json);
  Map<String, dynamic> toJson() => _$GenomicProfileToJson(this);

  bool get isHighQuality => qualityMetrics['coverage'] != null && qualityMetrics['coverage']! > 30.0;
  bool get isComplete => status == GenomicProfileStatus.complete;
  int get totalVariants => variants.length;
  int get significantVariants => variants.where((v) => v.significance == VariantSignificance.high).length;
}

enum GenomicProfileStatus { 
  processing, 
  complete, 
  failed, 
  needsReview, 
  deprecated 
}

@JsonSerializable()
class GeneVariant {
  final String id;
  final String chromosome;
  final int position;
  final String referenceAllele;
  final String alternateAllele;
  final String geneSymbol;
  final String geneName;
  final VariantType type;
  final VariantSignificance significance;
  final double frequency;
  final List<String> clinicalSignificance;
  final List<String> phenotypes;
  final Map<String, dynamic> annotations;
  final Map<String, double> scores;
  final DateTime discoveredAt;
  final String discoveredBy;
  final Map<String, dynamic> metadata;

  const GeneVariant({
    required this.id,
    required this.chromosome,
    required this.position,
    required this.referenceAllele,
    required this.alternateAllele,
    required this.geneSymbol,
    required this.geneName,
    required this.type,
    required this.significance,
    required this.frequency,
    required this.clinicalSignificance,
    required this.phenotypes,
    required this.annotations,
    required this.scores,
    required this.discoveredAt,
    required this.discoveredBy,
    required this.metadata,
  });

  factory GeneVariant.fromJson(Map<String, dynamic> json) => _$GeneVariantFromJson(json);
  Map<String, dynamic> toJson() => _$GeneVariantToJson(this);

  bool get isRare => frequency < 0.01;
  bool get isPathogenic => clinicalSignificance.contains('pathogenic');
  bool get isHighImpact => type == VariantType.deletion || type == VariantType.insertion || type == VariantType.frameshift;
  double get pathogenicityScore => scores['pathogenicity'] ?? 0.0;
  bool get isSignificant => significance == VariantSignificance.high;
}

enum VariantType { 
  snp, 
  insertion, 
  deletion, 
  duplication, 
  inversion, 
  translocation, 
  frameshift, 
  nonsense, 
  missense, 
  silent 
}

enum VariantSignificance { 
  low, 
  moderate, 
  high, 
  unknown 
}

@JsonSerializable()
class GeneExpression {
  final String id;
  final String geneSymbol;
  final String geneName;
  final String tissue;
  final String cellType;
  final double expressionLevel;
  final String expressionUnit;
  final DateTime measuredAt;
  final String measurementMethod;
  final Map<String, double> conditions;
  final Map<String, dynamic> metadata;

  const GeneExpression({
    required this.id,
    required this.geneSymbol,
    required this.geneName,
    required this.tissue,
    required this.cellType,
    required this.expressionLevel,
    required this.expressionUnit,
    required this.measuredAt,
    required this.measurementMethod,
    required this.conditions,
    required this.metadata,
  });

  factory GeneExpression.fromJson(Map<String, dynamic> json) => _$GeneExpressionFromJson(json);
  Map<String, dynamic> toJson() => _$GeneExpressionToJson(this);

  bool get isHighExpression => expressionLevel > 1000.0;
  bool get isLowExpression => expressionLevel < 10.0;
  bool get isModerateExpression => expressionLevel >= 10.0 && expressionLevel <= 1000.0;
}

@JsonSerializable()
class EpigeneticMark {
  final String id;
  final String markType;
  final String chromosome;
  final int position;
  final String geneSymbol;
  final String geneName;
  final double methylationLevel;
  final String tissue;
  final String cellType;
  final DateTime measuredAt;
  final String measurementMethod;
  final Map<String, dynamic> metadata;

  const EpigeneticMark({
    required this.id,
    required this.markType,
    required this.chromosome,
    required this.position,
    required this.geneSymbol,
    required this.geneName,
    required this.methylationLevel,
    required this.tissue,
    required this.cellType,
    required this.measuredAt,
    required this.measurementMethod,
    required this.metadata,
  });

  factory EpigeneticMark.fromJson(Map<String, dynamic> json) => _$EpigeneticMarkFromJson(json);
  Map<String, dynamic> toJson() => _$EpigeneticMarkToJson(this);

  bool get isHighMethylation => methylationLevel > 0.7;
  bool get isLowMethylation => methylationLevel < 0.3;
  bool get isModerateMethylation => methylationLevel >= 0.3 && methylationLevel <= 0.7;
}

@JsonSerializable()
class PharmacogenomicProfile {
  final String id;
  final String patientId;
  final String profileType;
  final List<DrugMetabolism> drugMetabolisms;
  final List<DrugResponse> drugResponses;
  final List<DrugInteraction> drugInteractions;
  final Map<String, double> riskScores;
  final List<String> recommendations;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, dynamic> metadata;

  const PharmacogenomicProfile({
    required this.id,
    required this.patientId,
    required this.profileType,
    required this.drugMetabolisms,
    required this.drugResponses,
    required this.drugInteractions,
    required this.riskScores,
    required this.recommendations,
    required this.generatedAt,
    required this.generatedBy,
    required this.metadata,
  });

  factory PharmacogenomicProfile.fromJson(Map<String, dynamic> json) => _$PharmacogenomicProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PharmacogenomicProfileToJson(this);

  int get totalDrugs => drugMetabolisms.length;
  int get highRiskDrugs => drugResponses.where((dr) => dr.riskLevel == RiskLevel.high).length;
  bool get hasHighRisk => riskScores.values.any((score) => score > 0.7);
}

@JsonSerializable()
class DrugMetabolism {
  final String id;
  final String drugName;
  final String drugClass;
  final String metabolizingEnzyme;
  final MetabolismType type;
  final double efficiency;
  final List<String> affectedGenes;
  final Map<String, dynamic> metadata;

  const DrugMetabolism({
    required this.id,
    required this.drugName,
    required this.drugClass,
    required this.metabolizingEnzyme,
    required this.type,
    required this.efficiency,
    required this.affectedGenes,
    required this.metadata,
  });

  factory DrugMetabolism.fromJson(Map<String, dynamic> json) => _$DrugMetabolismFromJson(json);
  Map<String, dynamic> toJson() => _$DrugMetabolismToJson(this);

  bool get isPoorMetabolizer => efficiency < 0.3;
  bool get isNormalMetabolizer => efficiency >= 0.3 && efficiency <= 0.7;
  bool get isRapidMetabolizer => efficiency > 0.7;
}

enum MetabolismType { 
  poor, 
  intermediate, 
  normal, 
  rapid, 
  ultrarapid 
}

@JsonSerializable()
class DrugResponse {
  final String id;
  final String drugName;
  final String drugClass;
  final ResponseType type;
  final RiskLevel riskLevel;
  final double efficacy;
  final double toxicity;
  final List<String> sideEffects;
  final Map<String, dynamic> metadata;

  const DrugResponse({
    required this.id,
    required this.drugName,
    required this.drugClass,
    required this.type,
    required this.riskLevel,
    required this.efficacy,
    required this.toxicity,
    required this.sideEffects,
    required this.metadata,
  });

  factory DrugResponse.fromJson(Map<String, dynamic> json) => _$DrugResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DrugResponseToJson(this);

  bool get isHighEfficacy => efficacy > 0.8;
  bool get isHighToxicity => toxicity > 0.7;
  bool get isSafe => toxicity < 0.3;
}

enum ResponseType { 
  poor, 
  reduced, 
  normal, 
  enhanced, 
  adverse 
}

enum RiskLevel { 
  low, 
  moderate, 
  high, 
  severe 
}

@JsonSerializable()
class DrugInteraction {
  final String id;
  final String drug1Name;
  final String drug2Name;
  final InteractionType type;
  final double severity;
  final String mechanism;
  final List<String> symptoms;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const DrugInteraction({
    required this.id,
    required this.drug1Name,
    required this.drug2Name,
    required this.type,
    required this.severity,
    required this.mechanism,
    required this.symptoms,
    required this.recommendations,
    required this.metadata,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => _$DrugInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$DrugInteractionToJson(this);

  bool get isSevere => severity > 0.8;
  bool get isModerate => severity >= 0.4 && severity <= 0.8;
  bool get isMild => severity < 0.4;
}

enum InteractionType { 
  pharmacokinetic, 
  pharmacodynamic, 
  additive, 
  synergistic, 
  antagonistic 
}

@JsonSerializable()
class GenomicRiskAssessment {
  final String id;
  final String patientId;
  final String assessmentType;
  final Map<String, double> diseaseRisks;
  final Map<String, double> traitProbabilities;
  final List<String> highRiskConditions;
  final List<String> recommendations;
  final DateTime assessedAt;
  final String assessedBy;
  final Map<String, dynamic> metadata;

  const GenomicRiskAssessment({
    required this.id,
    required this.patientId,
    required this.assessmentType,
    required this.diseaseRisks,
    required this.traitProbabilities,
    required this.highRiskConditions,
    required this.recommendations,
    required this.assessedAt,
    required this.assessedBy,
    required this.metadata,
  });

  factory GenomicRiskAssessment.fromJson(Map<String, dynamic> json) => _$GenomicRiskAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$GenomicRiskAssessmentToJson(this);

  bool get hasHighRisk => diseaseRisks.values.any((risk) => risk > 0.7);
  int get totalHighRiskConditions => highRiskConditions.length;
  double get averageRisk => diseaseRisks.values.isEmpty ? 0.0 : diseaseRisks.values.reduce((a, b) => a + b) / diseaseRisks.length;
}

@JsonSerializable()
class GenomicReport {
  final String id;
  final String patientId;
  final String reportType;
  final GenomicProfile genomicProfile;
  final PharmacogenomicProfile? pharmacogenomicProfile;
  final GenomicRiskAssessment? riskAssessment;
  final List<String> keyFindings;
  final List<String> clinicalImplications;
  final List<String> recommendations;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, dynamic> metadata;

  const GenomicReport({
    required this.id,
    required this.patientId,
    required this.reportType,
    required this.genomicProfile,
    this.pharmacogenomicProfile,
    this.riskAssessment,
    required this.keyFindings,
    required this.clinicalImplications,
    required this.recommendations,
    required this.generatedAt,
    required this.generatedBy,
    required this.metadata,
  });

  factory GenomicReport.fromJson(Map<String, dynamic> json) => _$GenomicReportFromJson(json);
  Map<String, dynamic> toJson() => _$GenomicReportToJson(this);

  bool get isComplete => pharmacogenomicProfile != null && riskAssessment != null;
  int get totalFindings => keyFindings.length;
  int get totalRecommendations => recommendations.length;
  bool get hasClinicalImplications => clinicalImplications.isNotEmpty;
}

@JsonSerializable()
class GenomicAnalysisJob {
  final String id;
  final String jobType;
  final String patientId;
  final String inputDataId;
  final AnalysisJobStatus status;
  final DateTime submittedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final double progress;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> results;
  final List<String> logs;
  final String submittedBy;
  final Map<String, dynamic> metadata;

  const GenomicAnalysisJob({
    required this.id,
    required this.jobType,
    required this.patientId,
    required this.inputDataId,
    required this.status,
    required this.submittedAt,
    this.startedAt,
    this.completedAt,
    this.failedAt,
    required this.progress,
    required this.parameters,
    required this.results,
    required this.logs,
    required this.submittedBy,
    required this.metadata,
  });

  factory GenomicAnalysisJob.fromJson(Map<String, dynamic> json) => _$GenomicAnalysisJobFromJson(json);
  Map<String, dynamic> toJson() => _$GenomicAnalysisJobToJson(this);

  bool get isCompleted => status == AnalysisJobStatus.completed;
  bool get isFailed => status == AnalysisJobStatus.failed;
  bool get isRunning => status == AnalysisJobStatus.running;
  Duration get runtime {
    if (startedAt == null || completedAt == null) return Duration.zero;
    return completedAt!.difference(startedAt!);
  }
}

enum AnalysisJobStatus { 
  queued, 
  running, 
  completed, 
  failed, 
  cancelled, 
  paused 
}

@JsonSerializable()
class GenomicDataQuality {
  final String id;
  final String dataSourceId;
  final String dataType;
  final Map<String, double> qualityMetrics;
  final List<String> qualityIssues;
  final QualityScore overallScore;
  final DateTime assessedAt;
  final String assessedBy;
  final Map<String, dynamic> metadata;

  const GenomicDataQuality({
    required this.id,
    required this.dataSourceId,
    required this.dataType,
    required this.qualityMetrics,
    required this.qualityIssues,
    required this.overallScore,
    required this.assessedAt,
    required this.assessedBy,
    required this.metadata,
  });

  factory GenomicDataQuality.fromJson(Map<String, dynamic> json) => _$GenomicDataQualityFromJson(json);
  Map<String, dynamic> toJson() => _$GenomicDataQualityToJson(this);

  bool get isHighQuality => overallScore == QualityScore.excellent || overallScore == QualityScore.good;
  bool get needsAttention => overallScore == QualityScore.poor || overallScore == QualityScore.unacceptable;
  int get totalIssues => qualityIssues.length;
}

enum QualityScore { 
  excellent, 
  good, 
  fair, 
  poor, 
  unacceptable 
}
