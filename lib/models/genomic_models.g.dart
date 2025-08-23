// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genomic_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenomicProfile _$GenomicProfileFromJson(Map<String, dynamic> json) =>
    GenomicProfile(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      profileType: json['profileType'] as String,
      sequencedAt: DateTime.parse(json['sequencedAt'] as String),
      sequencingMethod: json['sequencingMethod'] as String,
      sequencingPlatform: json['sequencingPlatform'] as String,
      rawData: json['rawData'] as Map<String, dynamic>,
      variants: (json['variants'] as List<dynamic>)
          .map((e) => GeneVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      expressions: (json['expressions'] as List<dynamic>)
          .map((e) => GeneExpression.fromJson(e as Map<String, dynamic>))
          .toList(),
      epigeneticMarks: (json['epigeneticMarks'] as List<dynamic>)
          .map((e) => EpigeneticMark.fromJson(e as Map<String, dynamic>))
          .toList(),
      qualityMetrics: (json['qualityMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      status: $enumDecode(_$GenomicProfileStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GenomicProfileToJson(GenomicProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'profileType': instance.profileType,
      'sequencedAt': instance.sequencedAt.toIso8601String(),
      'sequencingMethod': instance.sequencingMethod,
      'sequencingPlatform': instance.sequencingPlatform,
      'rawData': instance.rawData,
      'variants': instance.variants,
      'expressions': instance.expressions,
      'epigeneticMarks': instance.epigeneticMarks,
      'qualityMetrics': instance.qualityMetrics,
      'status': _$GenomicProfileStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'metadata': instance.metadata,
    };

const _$GenomicProfileStatusEnumMap = {
  GenomicProfileStatus.processing: 'processing',
  GenomicProfileStatus.complete: 'complete',
  GenomicProfileStatus.failed: 'failed',
  GenomicProfileStatus.needsReview: 'needsReview',
  GenomicProfileStatus.deprecated: 'deprecated',
};

GeneVariant _$GeneVariantFromJson(Map<String, dynamic> json) => GeneVariant(
  id: json['id'] as String,
  chromosome: json['chromosome'] as String,
  position: (json['position'] as num).toInt(),
  referenceAllele: json['referenceAllele'] as String,
  alternateAllele: json['alternateAllele'] as String,
  geneSymbol: json['geneSymbol'] as String,
  geneName: json['geneName'] as String,
  type: $enumDecode(_$VariantTypeEnumMap, json['type']),
  significance: $enumDecode(_$VariantSignificanceEnumMap, json['significance']),
  frequency: (json['frequency'] as num).toDouble(),
  clinicalSignificance: (json['clinicalSignificance'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  phenotypes: (json['phenotypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  annotations: json['annotations'] as Map<String, dynamic>,
  scores: (json['scores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  discoveredAt: DateTime.parse(json['discoveredAt'] as String),
  discoveredBy: json['discoveredBy'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$GeneVariantToJson(GeneVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chromosome': instance.chromosome,
      'position': instance.position,
      'referenceAllele': instance.referenceAllele,
      'alternateAllele': instance.alternateAllele,
      'geneSymbol': instance.geneSymbol,
      'geneName': instance.geneName,
      'type': _$VariantTypeEnumMap[instance.type]!,
      'significance': _$VariantSignificanceEnumMap[instance.significance]!,
      'frequency': instance.frequency,
      'clinicalSignificance': instance.clinicalSignificance,
      'phenotypes': instance.phenotypes,
      'annotations': instance.annotations,
      'scores': instance.scores,
      'discoveredAt': instance.discoveredAt.toIso8601String(),
      'discoveredBy': instance.discoveredBy,
      'metadata': instance.metadata,
    };

const _$VariantTypeEnumMap = {
  VariantType.snp: 'snp',
  VariantType.insertion: 'insertion',
  VariantType.deletion: 'deletion',
  VariantType.duplication: 'duplication',
  VariantType.inversion: 'inversion',
  VariantType.translocation: 'translocation',
  VariantType.frameshift: 'frameshift',
  VariantType.nonsense: 'nonsense',
  VariantType.missense: 'missense',
  VariantType.silent: 'silent',
};

const _$VariantSignificanceEnumMap = {
  VariantSignificance.low: 'low',
  VariantSignificance.moderate: 'moderate',
  VariantSignificance.high: 'high',
  VariantSignificance.unknown: 'unknown',
};

GeneExpression _$GeneExpressionFromJson(Map<String, dynamic> json) =>
    GeneExpression(
      id: json['id'] as String,
      geneSymbol: json['geneSymbol'] as String,
      geneName: json['geneName'] as String,
      tissue: json['tissue'] as String,
      cellType: json['cellType'] as String,
      expressionLevel: (json['expressionLevel'] as num).toDouble(),
      expressionUnit: json['expressionUnit'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      measurementMethod: json['measurementMethod'] as String,
      conditions: (json['conditions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GeneExpressionToJson(GeneExpression instance) =>
    <String, dynamic>{
      'id': instance.id,
      'geneSymbol': instance.geneSymbol,
      'geneName': instance.geneName,
      'tissue': instance.tissue,
      'cellType': instance.cellType,
      'expressionLevel': instance.expressionLevel,
      'expressionUnit': instance.expressionUnit,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'measurementMethod': instance.measurementMethod,
      'conditions': instance.conditions,
      'metadata': instance.metadata,
    };

EpigeneticMark _$EpigeneticMarkFromJson(Map<String, dynamic> json) =>
    EpigeneticMark(
      id: json['id'] as String,
      markType: json['markType'] as String,
      chromosome: json['chromosome'] as String,
      position: (json['position'] as num).toInt(),
      geneSymbol: json['geneSymbol'] as String,
      geneName: json['geneName'] as String,
      methylationLevel: (json['methylationLevel'] as num).toDouble(),
      tissue: json['tissue'] as String,
      cellType: json['cellType'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      measurementMethod: json['measurementMethod'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EpigeneticMarkToJson(EpigeneticMark instance) =>
    <String, dynamic>{
      'id': instance.id,
      'markType': instance.markType,
      'chromosome': instance.chromosome,
      'position': instance.position,
      'geneSymbol': instance.geneSymbol,
      'geneName': instance.geneName,
      'methylationLevel': instance.methylationLevel,
      'tissue': instance.tissue,
      'cellType': instance.cellType,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'measurementMethod': instance.measurementMethod,
      'metadata': instance.metadata,
    };

PharmacogenomicProfile _$PharmacogenomicProfileFromJson(
  Map<String, dynamic> json,
) => PharmacogenomicProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  profileType: json['profileType'] as String,
  drugMetabolisms: (json['drugMetabolisms'] as List<dynamic>)
      .map((e) => DrugMetabolism.fromJson(e as Map<String, dynamic>))
      .toList(),
  drugResponses: (json['drugResponses'] as List<dynamic>)
      .map((e) => DrugResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  drugInteractions: (json['drugInteractions'] as List<dynamic>)
      .map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
      .toList(),
  riskScores: (json['riskScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  generatedBy: json['generatedBy'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$PharmacogenomicProfileToJson(
  PharmacogenomicProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'profileType': instance.profileType,
  'drugMetabolisms': instance.drugMetabolisms,
  'drugResponses': instance.drugResponses,
  'drugInteractions': instance.drugInteractions,
  'riskScores': instance.riskScores,
  'recommendations': instance.recommendations,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'generatedBy': instance.generatedBy,
  'metadata': instance.metadata,
};

DrugMetabolism _$DrugMetabolismFromJson(Map<String, dynamic> json) =>
    DrugMetabolism(
      id: json['id'] as String,
      drugName: json['drugName'] as String,
      drugClass: json['drugClass'] as String,
      metabolizingEnzyme: json['metabolizingEnzyme'] as String,
      type: $enumDecode(_$MetabolismTypeEnumMap, json['type']),
      efficiency: (json['efficiency'] as num).toDouble(),
      affectedGenes: (json['affectedGenes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DrugMetabolismToJson(DrugMetabolism instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugName': instance.drugName,
      'drugClass': instance.drugClass,
      'metabolizingEnzyme': instance.metabolizingEnzyme,
      'type': _$MetabolismTypeEnumMap[instance.type]!,
      'efficiency': instance.efficiency,
      'affectedGenes': instance.affectedGenes,
      'metadata': instance.metadata,
    };

const _$MetabolismTypeEnumMap = {
  MetabolismType.poor: 'poor',
  MetabolismType.intermediate: 'intermediate',
  MetabolismType.normal: 'normal',
  MetabolismType.rapid: 'rapid',
  MetabolismType.ultrarapid: 'ultrarapid',
};

DrugResponse _$DrugResponseFromJson(Map<String, dynamic> json) => DrugResponse(
  id: json['id'] as String,
  drugName: json['drugName'] as String,
  drugClass: json['drugClass'] as String,
  type: $enumDecode(_$ResponseTypeEnumMap, json['type']),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  efficacy: (json['efficacy'] as num).toDouble(),
  toxicity: (json['toxicity'] as num).toDouble(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DrugResponseToJson(DrugResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugName': instance.drugName,
      'drugClass': instance.drugClass,
      'type': _$ResponseTypeEnumMap[instance.type]!,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'efficacy': instance.efficacy,
      'toxicity': instance.toxicity,
      'sideEffects': instance.sideEffects,
      'metadata': instance.metadata,
    };

const _$ResponseTypeEnumMap = {
  ResponseType.poor: 'poor',
  ResponseType.reduced: 'reduced',
  ResponseType.normal: 'normal',
  ResponseType.enhanced: 'enhanced',
  ResponseType.adverse: 'adverse',
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.severe: 'severe',
};

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) =>
    DrugInteraction(
      id: json['id'] as String,
      drug1Name: json['drug1Name'] as String,
      drug2Name: json['drug2Name'] as String,
      type: $enumDecode(_$InteractionTypeEnumMap, json['type']),
      severity: (json['severity'] as num).toDouble(),
      mechanism: json['mechanism'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DrugInteractionToJson(DrugInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drug1Name': instance.drug1Name,
      'drug2Name': instance.drug2Name,
      'type': _$InteractionTypeEnumMap[instance.type]!,
      'severity': instance.severity,
      'mechanism': instance.mechanism,
      'symptoms': instance.symptoms,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
    };

const _$InteractionTypeEnumMap = {
  InteractionType.pharmacokinetic: 'pharmacokinetic',
  InteractionType.pharmacodynamic: 'pharmacodynamic',
  InteractionType.additive: 'additive',
  InteractionType.synergistic: 'synergistic',
  InteractionType.antagonistic: 'antagonistic',
};

GenomicRiskAssessment _$GenomicRiskAssessmentFromJson(
  Map<String, dynamic> json,
) => GenomicRiskAssessment(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  assessmentType: json['assessmentType'] as String,
  diseaseRisks: (json['diseaseRisks'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  traitProbabilities: (json['traitProbabilities'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  highRiskConditions: (json['highRiskConditions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  assessedAt: DateTime.parse(json['assessedAt'] as String),
  assessedBy: json['assessedBy'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$GenomicRiskAssessmentToJson(
  GenomicRiskAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'assessmentType': instance.assessmentType,
  'diseaseRisks': instance.diseaseRisks,
  'traitProbabilities': instance.traitProbabilities,
  'highRiskConditions': instance.highRiskConditions,
  'recommendations': instance.recommendations,
  'assessedAt': instance.assessedAt.toIso8601String(),
  'assessedBy': instance.assessedBy,
  'metadata': instance.metadata,
};

GenomicReport _$GenomicReportFromJson(Map<String, dynamic> json) =>
    GenomicReport(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      reportType: json['reportType'] as String,
      genomicProfile: GenomicProfile.fromJson(
        json['genomicProfile'] as Map<String, dynamic>,
      ),
      pharmacogenomicProfile: json['pharmacogenomicProfile'] == null
          ? null
          : PharmacogenomicProfile.fromJson(
              json['pharmacogenomicProfile'] as Map<String, dynamic>,
            ),
      riskAssessment: json['riskAssessment'] == null
          ? null
          : GenomicRiskAssessment.fromJson(
              json['riskAssessment'] as Map<String, dynamic>,
            ),
      keyFindings: (json['keyFindings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalImplications: (json['clinicalImplications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GenomicReportToJson(GenomicReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'reportType': instance.reportType,
      'genomicProfile': instance.genomicProfile,
      'pharmacogenomicProfile': instance.pharmacogenomicProfile,
      'riskAssessment': instance.riskAssessment,
      'keyFindings': instance.keyFindings,
      'clinicalImplications': instance.clinicalImplications,
      'recommendations': instance.recommendations,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'metadata': instance.metadata,
    };

GenomicAnalysisJob _$GenomicAnalysisJobFromJson(Map<String, dynamic> json) =>
    GenomicAnalysisJob(
      id: json['id'] as String,
      jobType: json['jobType'] as String,
      patientId: json['patientId'] as String,
      inputDataId: json['inputDataId'] as String,
      status: $enumDecode(_$AnalysisJobStatusEnumMap, json['status']),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      failedAt: json['failedAt'] == null
          ? null
          : DateTime.parse(json['failedAt'] as String),
      progress: (json['progress'] as num).toDouble(),
      parameters: json['parameters'] as Map<String, dynamic>,
      results: json['results'] as Map<String, dynamic>,
      logs: (json['logs'] as List<dynamic>).map((e) => e as String).toList(),
      submittedBy: json['submittedBy'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GenomicAnalysisJobToJson(GenomicAnalysisJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobType': instance.jobType,
      'patientId': instance.patientId,
      'inputDataId': instance.inputDataId,
      'status': _$AnalysisJobStatusEnumMap[instance.status]!,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'failedAt': instance.failedAt?.toIso8601String(),
      'progress': instance.progress,
      'parameters': instance.parameters,
      'results': instance.results,
      'logs': instance.logs,
      'submittedBy': instance.submittedBy,
      'metadata': instance.metadata,
    };

const _$AnalysisJobStatusEnumMap = {
  AnalysisJobStatus.queued: 'queued',
  AnalysisJobStatus.running: 'running',
  AnalysisJobStatus.completed: 'completed',
  AnalysisJobStatus.failed: 'failed',
  AnalysisJobStatus.cancelled: 'cancelled',
  AnalysisJobStatus.paused: 'paused',
};

GenomicDataQuality _$GenomicDataQualityFromJson(Map<String, dynamic> json) =>
    GenomicDataQuality(
      id: json['id'] as String,
      dataSourceId: json['dataSourceId'] as String,
      dataType: json['dataType'] as String,
      qualityMetrics: (json['qualityMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      qualityIssues: (json['qualityIssues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      overallScore: $enumDecode(_$QualityScoreEnumMap, json['overallScore']),
      assessedAt: DateTime.parse(json['assessedAt'] as String),
      assessedBy: json['assessedBy'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GenomicDataQualityToJson(GenomicDataQuality instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dataSourceId': instance.dataSourceId,
      'dataType': instance.dataType,
      'qualityMetrics': instance.qualityMetrics,
      'qualityIssues': instance.qualityIssues,
      'overallScore': _$QualityScoreEnumMap[instance.overallScore]!,
      'assessedAt': instance.assessedAt.toIso8601String(),
      'assessedBy': instance.assessedBy,
      'metadata': instance.metadata,
    };

const _$QualityScoreEnumMap = {
  QualityScore.excellent: 'excellent',
  QualityScore.good: 'good',
  QualityScore.fair: 'fair',
  QualityScore.poor: 'poor',
  QualityScore.unacceptable: 'unacceptable',
};
