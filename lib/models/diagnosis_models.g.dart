// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagnosisEntry _$DiagnosisEntryFromJson(Map<String, dynamic> json) =>
    DiagnosisEntry(
      id: json['id'] as String,
      system: $enumDecode(_$DiagnosisSystemEnumMap, json['system']),
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      synonyms: (json['synonyms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specifiers: (json['specifiers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comorbidities: (json['comorbidities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      typicalSeverity: $enumDecode(
        _$DiagnosisSeverityEnumMap,
        json['typicalSeverity'],
      ),
      commonTreatments: (json['commonTreatments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DiagnosisEntryToJson(DiagnosisEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'system': _$DiagnosisSystemEnumMap[instance.system]!,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'synonyms': instance.synonyms,
      'specifiers': instance.specifiers,
      'comorbidities': instance.comorbidities,
      'typicalSeverity': _$DiagnosisSeverityEnumMap[instance.typicalSeverity]!,
      'commonTreatments': instance.commonTreatments,
      'metadata': instance.metadata,
    };

const _$DiagnosisSystemEnumMap = {
  DiagnosisSystem.dsm_5_tr: 'dsm_5_tr',
  DiagnosisSystem.icd_11: 'icd_11',
  DiagnosisSystem.icd_10: 'icd_10',
};

const _$DiagnosisSeverityEnumMap = {
  DiagnosisSeverity.mild: 'mild',
  DiagnosisSeverity.moderate: 'moderate',
  DiagnosisSeverity.severe: 'severe',
  DiagnosisSeverity.verySevere: 'very_severe',
};

DiagnosisSearchFilters _$DiagnosisSearchFiltersFromJson(
  Map<String, dynamic> json,
) => DiagnosisSearchFilters(
  system: $enumDecode(_$DiagnosisSystemEnumMap, json['system']),
  query: json['query'] as String?,
  minSeverity: $enumDecodeNullable(
    _$DiagnosisSeverityEnumMap,
    json['minSeverity'],
  ),
  includeSynonyms: json['includeSynonyms'] as bool? ?? true,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$DiagnosisSearchFiltersToJson(
  DiagnosisSearchFilters instance,
) => <String, dynamic>{
  'system': _$DiagnosisSystemEnumMap[instance.system]!,
  'query': instance.query,
  'minSeverity': _$DiagnosisSeverityEnumMap[instance.minSeverity],
  'includeSynonyms': instance.includeSynonyms,
  'limit': instance.limit,
};

DiagnosisSuggestion _$DiagnosisSuggestionFromJson(Map<String, dynamic> json) =>
    DiagnosisSuggestion(
      id: json['id'] as String,
      diagnosis: json['diagnosis'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      evidence: (json['evidence'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      icd10Code: json['icd10Code'] as String,
      severity: $enumDecode(_$DiagnosisSeverityEnumMap, json['severity']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DiagnosisSuggestionToJson(
  DiagnosisSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'diagnosis': instance.diagnosis,
  'confidence': instance.confidence,
  'evidence': instance.evidence,
  'differentialDiagnoses': instance.differentialDiagnoses,
  'icd10Code': instance.icd10Code,
  'severity': _$DiagnosisSeverityEnumMap[instance.severity]!,
  'notes': instance.notes,
};

RegionalDiagnosisConfig _$RegionalDiagnosisConfigFromJson(
  Map<String, dynamic> json,
) => RegionalDiagnosisConfig(
  region: json['region'] as String,
  defaultSystem: $enumDecode(_$DiagnosisSystemEnumMap, json['defaultSystem']),
  language: json['language'] as String,
  codeMappings: Map<String, String>.from(json['codeMappings'] as Map),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RegionalDiagnosisConfigToJson(
  RegionalDiagnosisConfig instance,
) => <String, dynamic>{
  'region': instance.region,
  'defaultSystem': _$DiagnosisSystemEnumMap[instance.defaultSystem]!,
  'language': instance.language,
  'codeMappings': instance.codeMappings,
  'metadata': instance.metadata,
};

DiagnosisCategory _$DiagnosisCategoryFromJson(Map<String, dynamic> json) =>
    DiagnosisCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      parentCategories: (json['parentCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      childCategories: (json['childCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      disorderIds: (json['disorderIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DiagnosisCategoryToJson(DiagnosisCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'parentCategories': instance.parentCategories,
      'childCategories': instance.childCategories,
      'disorderIds': instance.disorderIds,
      'metadata': instance.metadata,
    };
