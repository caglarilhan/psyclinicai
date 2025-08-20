// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'psychiatric_scales_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PsychiatricScale _$PsychiatricScaleFromJson(Map<String, dynamic> json) =>
    PsychiatricScale(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      type: $enumDecode(_$ScaleTypeEnumMap, json['type']),
      items: (json['items'] as List<dynamic>)
          .map((e) => ScaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      scoringMethod: $enumDecode(_$ScoringMethodEnumMap, json['scoringMethod']),
      scoreRanges: (json['scoreRanges'] as List<dynamic>)
          .map((e) => ScoreRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      administrationTime: json['administrationTime'] as String,
      targetPopulation: json['targetPopulation'] as String,
      indications: (json['indications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reliability: json['reliability'] as String,
      validity: json['validity'] as String,
      sensitivity: json['sensitivity'] as String,
      specificity: json['specificity'] as String,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$PsychiatricScaleToJson(PsychiatricScale instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'version': instance.version,
      'type': _$ScaleTypeEnumMap[instance.type]!,
      'items': instance.items,
      'scoringMethod': _$ScoringMethodEnumMap[instance.scoringMethod]!,
      'scoreRanges': instance.scoreRanges,
      'administrationTime': instance.administrationTime,
      'targetPopulation': instance.targetPopulation,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'reliability': instance.reliability,
      'validity': instance.validity,
      'sensitivity': instance.sensitivity,
      'specificity': instance.specificity,
      'languages': instance.languages,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$ScaleTypeEnumMap = {
  ScaleType.depression: 'depression',
  ScaleType.anxiety: 'anxiety',
  ScaleType.mania: 'mania',
  ScaleType.psychosis: 'psychosis',
  ScaleType.personality: 'personality',
  ScaleType.cognitive: 'cognitive',
  ScaleType.substance: 'substance',
  ScaleType.eating: 'eating',
  ScaleType.sleep: 'sleep',
  ScaleType.other: 'other',
};

const _$ScoringMethodEnumMap = {
  ScoringMethod.sum: 'sum',
  ScoringMethod.average: 'average',
  ScoringMethod.weighted: 'weighted',
  ScoringMethod.algorithm: 'algorithm',
  ScoringMethod.other: 'other',
};

ScaleItem _$ScaleItemFromJson(Map<String, dynamic> json) => ScaleItem(
  id: json['id'] as String,
  itemNumber: json['itemNumber'] as String,
  question: json['question'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ItemTypeEnumMap, json['type']),
  responses: (json['responses'] as List<dynamic>)
      .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  category: json['category'] as String,
  subcategory: json['subcategory'] as String,
  weight: (json['weight'] as num).toDouble(),
  isRequired: json['isRequired'] as bool,
  instructions: json['instructions'] as String,
  examples: (json['examples'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ScaleItemToJson(ScaleItem instance) => <String, dynamic>{
  'id': instance.id,
  'itemNumber': instance.itemNumber,
  'question': instance.question,
  'description': instance.description,
  'type': _$ItemTypeEnumMap[instance.type]!,
  'responses': instance.responses,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'weight': instance.weight,
  'isRequired': instance.isRequired,
  'instructions': instance.instructions,
  'examples': instance.examples,
  'metadata': instance.metadata,
};

const _$ItemTypeEnumMap = {
  ItemType.likert: 'likert',
  ItemType.binary: 'binary',
  ItemType.multipleChoice: 'multipleChoice',
  ItemType.openEnded: 'openEnded',
  ItemType.visual: 'visual',
  ItemType.other: 'other',
};

ItemResponse _$ItemResponseFromJson(Map<String, dynamic> json) => ItemResponse(
  id: json['id'] as String,
  responseText: json['responseText'] as String,
  score: (json['score'] as num).toInt(),
  description: json['description'] as String,
  interpretation: json['interpretation'] as String,
  examples: (json['examples'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ItemResponseToJson(ItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'responseText': instance.responseText,
      'score': instance.score,
      'description': instance.description,
      'interpretation': instance.interpretation,
      'examples': instance.examples,
      'metadata': instance.metadata,
    };

ScoreRange _$ScoreRangeFromJson(Map<String, dynamic> json) => ScoreRange(
  id: json['id'] as String,
  minScore: (json['minScore'] as num).toInt(),
  maxScore: (json['maxScore'] as num).toInt(),
  severity: json['severity'] as String,
  interpretation: json['interpretation'] as String,
  recommendation: json['recommendation'] as String,
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ScoreRangeToJson(ScoreRange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'minScore': instance.minScore,
      'maxScore': instance.maxScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendation': instance.recommendation,
      'actions': instance.actions,
      'metadata': instance.metadata,
    };

ScaleAssessment _$ScaleAssessmentFromJson(Map<String, dynamic> json) =>
    ScaleAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      scaleId: json['scaleId'] as String,
      scaleName: json['scaleName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      severity: json['severity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalNotes: json['clinicalNotes'] as String,
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ScaleAssessmentToJson(ScaleAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'responses': instance.responses,
      'totalScore': instance.totalScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'clinicalNotes': instance.clinicalNotes,
      'status': instance.status,
      'metadata': instance.metadata,
    };

ScaleTrend _$ScaleTrendFromJson(Map<String, dynamic> json) => ScaleTrend(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  scaleId: json['scaleId'] as String,
  scaleName: json['scaleName'] as String,
  assessments: (json['assessments'] as List<dynamic>)
      .map((e) => ScaleAssessment.fromJson(e as Map<String, dynamic>))
      .toList(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  trend: json['trend'] as String,
  interpretation: json['interpretation'] as String,
  significantChanges: (json['significantChanges'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  improvementRate: (json['improvementRate'] as num).toDouble(),
  responseRate: (json['responseRate'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ScaleTrendToJson(ScaleTrend instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessments': instance.assessments,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'trend': instance.trend,
      'interpretation': instance.interpretation,
      'significantChanges': instance.significantChanges,
      'recommendations': instance.recommendations,
      'improvementRate': instance.improvementRate,
      'responseRate': instance.responseRate,
      'metadata': instance.metadata,
    };

ScaleReport _$ScaleReportFromJson(Map<String, dynamic> json) => ScaleReport(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  reportDate: DateTime.parse(json['reportDate'] as String),
  assessments: (json['assessments'] as List<dynamic>)
      .map((e) => ScaleAssessment.fromJson(e as Map<String, dynamic>))
      .toList(),
  trends: (json['trends'] as List<dynamic>)
      .map((e) => ScaleTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: json['summary'] as String,
  interpretation: json['interpretation'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  followUpAssessments: (json['followUpAssessments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  notes: json['notes'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$ScaleReportToJson(ScaleReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'reportDate': instance.reportDate.toIso8601String(),
      'assessments': instance.assessments,
      'trends': instance.trends,
      'summary': instance.summary,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'followUpAssessments': instance.followUpAssessments,
      'status': instance.status,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

PANSSAssessment _$PANSSAssessmentFromJson(Map<String, dynamic> json) =>
    PANSSAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      scaleId: json['scaleId'] as String,
      scaleName: json['scaleName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      severity: json['severity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalNotes: json['clinicalNotes'] as String,
      status: json['status'] as String,
      positiveScore: (json['positiveScore'] as num).toInt(),
      negativeScore: (json['negativeScore'] as num).toInt(),
      generalScore: (json['generalScore'] as num).toInt(),
      positiveSeverity: json['positiveSeverity'] as String,
      negativeSeverity: json['negativeSeverity'] as String,
      generalSeverity: json['generalSeverity'] as String,
      positiveSymptoms: (json['positiveSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      negativeSymptoms: (json['negativeSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      generalSymptoms: (json['generalSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PANSSAssessmentToJson(PANSSAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'responses': instance.responses,
      'totalScore': instance.totalScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'clinicalNotes': instance.clinicalNotes,
      'status': instance.status,
      'metadata': instance.metadata,
      'positiveScore': instance.positiveScore,
      'negativeScore': instance.negativeScore,
      'generalScore': instance.generalScore,
      'positiveSeverity': instance.positiveSeverity,
      'negativeSeverity': instance.negativeSeverity,
      'generalSeverity': instance.generalSeverity,
      'positiveSymptoms': instance.positiveSymptoms,
      'negativeSymptoms': instance.negativeSymptoms,
      'generalSymptoms': instance.generalSymptoms,
    };

YMRSAssessment _$YMRSAssessmentFromJson(Map<String, dynamic> json) =>
    YMRSAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      scaleId: json['scaleId'] as String,
      scaleName: json['scaleName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      severity: json['severity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalNotes: json['clinicalNotes'] as String,
      status: json['status'] as String,
      manicScore: (json['manicScore'] as num).toInt(),
      manicSeverity: json['manicSeverity'] as String,
      manicSymptoms: (json['manicSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      safetyMeasures: (json['safetyMeasures'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$YMRSAssessmentToJson(YMRSAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'responses': instance.responses,
      'totalScore': instance.totalScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'clinicalNotes': instance.clinicalNotes,
      'status': instance.status,
      'metadata': instance.metadata,
      'manicScore': instance.manicScore,
      'manicSeverity': instance.manicSeverity,
      'manicSymptoms': instance.manicSymptoms,
      'riskFactors': instance.riskFactors,
      'safetyMeasures': instance.safetyMeasures,
    };

HAMDAssessment _$HAMDAssessmentFromJson(Map<String, dynamic> json) =>
    HAMDAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      scaleId: json['scaleId'] as String,
      scaleName: json['scaleName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      severity: json['severity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalNotes: json['clinicalNotes'] as String,
      status: json['status'] as String,
      depressionScore: (json['depressionScore'] as num).toInt(),
      depressionSeverity: json['depressionSeverity'] as String,
      coreSymptoms: (json['coreSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      somaticSymptoms: (json['somaticSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      cognitiveSymptoms: (json['cognitiveSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suicideRisk: (json['suicideRisk'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$HAMDAssessmentToJson(HAMDAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'responses': instance.responses,
      'totalScore': instance.totalScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'clinicalNotes': instance.clinicalNotes,
      'status': instance.status,
      'metadata': instance.metadata,
      'depressionScore': instance.depressionScore,
      'depressionSeverity': instance.depressionSeverity,
      'coreSymptoms': instance.coreSymptoms,
      'somaticSymptoms': instance.somaticSymptoms,
      'cognitiveSymptoms': instance.cognitiveSymptoms,
      'suicideRisk': instance.suicideRisk,
    };

HAMAAssessment _$HAMAAssessmentFromJson(Map<String, dynamic> json) =>
    HAMAAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      scaleId: json['scaleId'] as String,
      scaleName: json['scaleName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      severity: json['severity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalNotes: json['clinicalNotes'] as String,
      status: json['status'] as String,
      anxietyScore: (json['anxietyScore'] as num).toInt(),
      anxietySeverity: json['anxietySeverity'] as String,
      psychicSymptoms: (json['psychicSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      somaticSymptoms: (json['somaticSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      avoidanceBehaviors: (json['avoidanceBehaviors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      triggers: (json['triggers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$HAMAAssessmentToJson(HAMAAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'responses': instance.responses,
      'totalScore': instance.totalScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'clinicalNotes': instance.clinicalNotes,
      'status': instance.status,
      'metadata': instance.metadata,
      'anxietyScore': instance.anxietyScore,
      'anxietySeverity': instance.anxietySeverity,
      'psychicSymptoms': instance.psychicSymptoms,
      'somaticSymptoms': instance.somaticSymptoms,
      'avoidanceBehaviors': instance.avoidanceBehaviors,
      'triggers': instance.triggers,
    };

MADRSAssessment _$MADRSAssessmentFromJson(Map<String, dynamic> json) =>
    MADRSAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      scaleId: json['scaleId'] as String,
      scaleName: json['scaleName'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalScore: (json['totalScore'] as num).toInt(),
      severity: json['severity'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalNotes: json['clinicalNotes'] as String,
      status: json['status'] as String,
      depressionScore: (json['depressionScore'] as num).toInt(),
      depressionSeverity: json['depressionSeverity'] as String,
      moodSymptoms: (json['moodSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      cognitiveSymptoms: (json['cognitiveSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      physicalSymptoms: (json['physicalSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suicideRisk: (json['suicideRisk'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MADRSAssessmentToJson(MADRSAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'scaleId': instance.scaleId,
      'scaleName': instance.scaleName,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'responses': instance.responses,
      'totalScore': instance.totalScore,
      'severity': instance.severity,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'clinicalNotes': instance.clinicalNotes,
      'status': instance.status,
      'metadata': instance.metadata,
      'depressionScore': instance.depressionScore,
      'depressionSeverity': instance.depressionSeverity,
      'moodSymptoms': instance.moodSymptoms,
      'cognitiveSymptoms': instance.cognitiveSymptoms,
      'physicalSymptoms': instance.physicalSymptoms,
      'suicideRisk': instance.suicideRisk,
    };
