// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_decision_support_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentalDisorder _$MentalDisorderFromJson(Map<String, dynamic> json) =>
    MentalDisorder(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatments: (json['treatments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$MentalDisorderToJson(MentalDisorder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'symptoms': instance.symptoms,
      'criteria': instance.criteria,
      'treatments': instance.treatments,
      'metadata': instance.metadata,
    };

DiagnosticCriteria _$DiagnosticCriteriaFromJson(Map<String, dynamic> json) =>
    DiagnosticCriteria(
      id: json['id'] as String,
      disorderId: json['disorderId'] as String,
      criteria: json['criteria'] as String,
      requiredCount: (json['requiredCount'] as num).toInt(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DiagnosticCriteriaToJson(DiagnosticCriteria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'disorderId': instance.disorderId,
      'criteria': instance.criteria,
      'requiredCount': instance.requiredCount,
      'symptoms': instance.symptoms,
      'metadata': instance.metadata,
    };

TreatmentGuideline _$TreatmentGuidelineFromJson(Map<String, dynamic> json) =>
    TreatmentGuideline(
      id: json['id'] as String,
      disorderId: json['disorderId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapies: (json['therapies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TreatmentGuidelineToJson(TreatmentGuideline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'disorderId': instance.disorderId,
      'title': instance.title,
      'description': instance.description,
      'recommendations': instance.recommendations,
      'medications': instance.medications,
      'therapies': instance.therapies,
      'metadata': instance.metadata,
    };

Symptom _$SymptomFromJson(Map<String, dynamic> json) => Symptom(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$SymptomTypeEnumMap, json['type']),
  severity: $enumDecode(_$SymptomSeverityEnumMap, json['severity']),
  description: json['description'] as String,
  relatedSymptoms: (json['relatedSymptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SymptomToJson(Symptom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$SymptomTypeEnumMap[instance.type]!,
  'severity': _$SymptomSeverityEnumMap[instance.severity]!,
  'description': instance.description,
  'relatedSymptoms': instance.relatedSymptoms,
  'metadata': instance.metadata,
};

const _$SymptomTypeEnumMap = {
  SymptomType.mood: 'mood',
  SymptomType.anxiety: 'anxiety',
  SymptomType.psychotic: 'psychotic',
  SymptomType.cognitive: 'cognitive',
  SymptomType.behavioral: 'behavioral',
  SymptomType.physical: 'physical',
  SymptomType.sleep: 'sleep',
  SymptomType.appetite: 'appetite',
};

const _$SymptomSeverityEnumMap = {
  SymptomSeverity.none: 'none',
  SymptomSeverity.mild: 'mild',
  SymptomSeverity.moderate: 'moderate',
  SymptomSeverity.severe: 'severe',
  SymptomSeverity.extreme: 'extreme',
};
