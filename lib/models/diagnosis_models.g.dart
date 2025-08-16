// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ICD11Category _$ICD11CategoryFromJson(Map<String, dynamic> json) =>
    ICD11Category(
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      translations: Map<String, String>.from(json['translations'] as Map),
      subcategories: (json['subcategories'] as List<dynamic>)
          .map((e) => ICD11Subcategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      synonyms: (json['synonyms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parentCode: json['parentCode'] as String,
      level: (json['level'] as num).toInt(),
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ICD11CategoryToJson(ICD11Category instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'languages': instance.languages,
      'translations': instance.translations,
      'subcategories': instance.subcategories,
      'keywords': instance.keywords,
      'synonyms': instance.synonyms,
      'parentCode': instance.parentCode,
      'level': instance.level,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

ICD11Subcategory _$ICD11SubcategoryFromJson(Map<String, dynamic> json) =>
    ICD11Subcategory(
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      synonyms: (json['synonyms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      inclusionCriteria: (json['inclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionCriteria: (json['exclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relatedConditions: (json['relatedConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      parentCode: json['parentCode'] as String,
      level: (json['level'] as num).toInt(),
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ICD11SubcategoryToJson(ICD11Subcategory instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'translations': instance.translations,
      'keywords': instance.keywords,
      'synonyms': instance.synonyms,
      'inclusionCriteria': instance.inclusionCriteria,
      'exclusionCriteria': instance.exclusionCriteria,
      'relatedConditions': instance.relatedConditions,
      'parentCode': instance.parentCode,
      'level': instance.level,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

ICD11Diagnosis _$ICD11DiagnosisFromJson(Map<String, dynamic> json) =>
    ICD11Diagnosis(
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      synonyms: (json['synonyms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      inclusionCriteria: (json['inclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exclusionCriteria: (json['exclusionCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relatedConditions: (json['relatedConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      complications: (json['complications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      severity: json['severity'] as String,
      chronicity: json['chronicity'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      treatmentOptions: (json['treatmentOptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapies: (json['therapies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ICD11DiagnosisToJson(ICD11Diagnosis instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'translations': instance.translations,
      'keywords': instance.keywords,
      'synonyms': instance.synonyms,
      'inclusionCriteria': instance.inclusionCriteria,
      'exclusionCriteria': instance.exclusionCriteria,
      'relatedConditions': instance.relatedConditions,
      'symptoms': instance.symptoms,
      'riskFactors': instance.riskFactors,
      'complications': instance.complications,
      'severity': instance.severity,
      'chronicity': instance.chronicity,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'treatmentOptions': instance.treatmentOptions,
      'medications': instance.medications,
      'therapies': instance.therapies,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

DSM5Diagnosis _$DSM5DiagnosisFromJson(Map<String, dynamic> json) =>
    DSM5Diagnosis(
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      criteria: (json['criteria'] as List<dynamic>)
          .map((e) => DSM5Criterion.fromJson(e as Map<String, dynamic>))
          .toList(),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      complications: (json['complications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      severity: json['severity'] as String,
      chronicity: json['chronicity'] as String,
      differentialDiagnosis: (json['differentialDiagnosis'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comorbidities: (json['comorbidities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatmentOptions: (json['treatmentOptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapies: (json['therapies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$DSM5DiagnosisToJson(DSM5Diagnosis instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'translations': instance.translations,
      'criteria': instance.criteria,
      'symptoms': instance.symptoms,
      'riskFactors': instance.riskFactors,
      'complications': instance.complications,
      'severity': instance.severity,
      'chronicity': instance.chronicity,
      'differentialDiagnosis': instance.differentialDiagnosis,
      'comorbidities': instance.comorbidities,
      'treatmentOptions': instance.treatmentOptions,
      'medications': instance.medications,
      'therapies': instance.therapies,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

DSM5Criterion _$DSM5CriterionFromJson(Map<String, dynamic> json) =>
    DSM5Criterion(
      code: json['code'] as String,
      description: json['description'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      examples: (json['examples'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: json['type'] as String,
      minRequired: (json['minRequired'] as num).toInt(),
      maxAllowed: (json['maxAllowed'] as num).toInt(),
      subCriteria: (json['subCriteria'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DSM5CriterionToJson(DSM5Criterion instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'translations': instance.translations,
      'examples': instance.examples,
      'type': instance.type,
      'minRequired': instance.minRequired,
      'maxAllowed': instance.maxAllowed,
      'subCriteria': instance.subCriteria,
      'metadata': instance.metadata,
    };

AIDiagnosisSuggestion _$AIDiagnosisSuggestionFromJson(
  Map<String, dynamic> json,
) => AIDiagnosisSuggestion(
  suggestedDiagnosis: json['suggestedDiagnosis'] as String,
  diagnosisCode: json['diagnosisCode'] as String,
  classificationSystem: json['classificationSystem'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  supportingSymptoms: (json['supportingSymptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  supportingCriteria: (json['supportingCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  conflictingSymptoms: (json['conflictingSymptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  conflictingCriteria: (json['conflictingCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedAssessments: (json['recommendedAssessments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedTests: (json['recommendedTests'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  reasoning: json['reasoning'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$AIDiagnosisSuggestionToJson(
  AIDiagnosisSuggestion instance,
) => <String, dynamic>{
  'suggestedDiagnosis': instance.suggestedDiagnosis,
  'diagnosisCode': instance.diagnosisCode,
  'classificationSystem': instance.classificationSystem,
  'confidence': instance.confidence,
  'supportingSymptoms': instance.supportingSymptoms,
  'supportingCriteria': instance.supportingCriteria,
  'conflictingSymptoms': instance.conflictingSymptoms,
  'conflictingCriteria': instance.conflictingCriteria,
  'differentialDiagnoses': instance.differentialDiagnoses,
  'recommendedAssessments': instance.recommendedAssessments,
  'recommendedTests': instance.recommendedTests,
  'reasoning': instance.reasoning,
  'metadata': instance.metadata,
  'generatedAt': instance.generatedAt.toIso8601String(),
};

DiagnosisSearchResult _$DiagnosisSearchResultFromJson(
  Map<String, dynamic> json,
) => DiagnosisSearchResult(
  icd11Results: (json['icd11Results'] as List<dynamic>)
      .map((e) => ICD11Diagnosis.fromJson(e as Map<String, dynamic>))
      .toList(),
  dsm5Results: (json['dsm5Results'] as List<dynamic>)
      .map((e) => DSM5Diagnosis.fromJson(e as Map<String, dynamic>))
      .toList(),
  aiSuggestions: (json['aiSuggestions'] as List<dynamic>)
      .map((e) => AIDiagnosisSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalResults: (json['totalResults'] as num).toInt(),
  searchQuery: json['searchQuery'] as String,
  filters: (json['filters'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  searchedAt: DateTime.parse(json['searchedAt'] as String),
);

Map<String, dynamic> _$DiagnosisSearchResultToJson(
  DiagnosisSearchResult instance,
) => <String, dynamic>{
  'icd11Results': instance.icd11Results,
  'dsm5Results': instance.dsm5Results,
  'aiSuggestions': instance.aiSuggestions,
  'totalResults': instance.totalResults,
  'searchQuery': instance.searchQuery,
  'filters': instance.filters,
  'metadata': instance.metadata,
  'searchedAt': instance.searchedAt.toIso8601String(),
};

DiagnosisHistory _$DiagnosisHistoryFromJson(Map<String, dynamic> json) =>
    DiagnosisHistory(
      patientId: json['patientId'] as String,
      diagnosisCode: json['diagnosisCode'] as String,
      diagnosisTitle: json['diagnosisTitle'] as String,
      classificationSystem: json['classificationSystem'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      diagnosedAt: DateTime.parse(json['diagnosedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      diagnosedBy: json['diagnosedBy'] as String,
      notes: json['notes'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      treatments: (json['treatments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      source: json['source'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DiagnosisHistoryToJson(DiagnosisHistory instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'diagnosisCode': instance.diagnosisCode,
      'diagnosisTitle': instance.diagnosisTitle,
      'classificationSystem': instance.classificationSystem,
      'severity': instance.severity,
      'status': instance.status,
      'diagnosedAt': instance.diagnosedAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'diagnosedBy': instance.diagnosedBy,
      'notes': instance.notes,
      'symptoms': instance.symptoms,
      'treatments': instance.treatments,
      'medications': instance.medications,
      'confidence': instance.confidence,
      'source': instance.source,
      'metadata': instance.metadata,
    };

DiagnosisTrend _$DiagnosisTrendFromJson(Map<String, dynamic> json) =>
    DiagnosisTrend(
      diagnosisCode: json['diagnosisCode'] as String,
      diagnosisTitle: json['diagnosisTitle'] as String,
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalCases: (json['totalCases'] as num).toInt(),
      newCases: (json['newCases'] as num).toInt(),
      resolvedCases: (json['resolvedCases'] as num).toInt(),
      prevalence: (json['prevalence'] as num).toDouble(),
      incidence: (json['incidence'] as num).toDouble(),
      timeSeriesData: (json['timeSeriesData'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      demographics: json['demographics'] as Map<String, dynamic>,
      riskFactors: json['riskFactors'] as Map<String, dynamic>,
      outcomes: json['outcomes'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$DiagnosisTrendToJson(DiagnosisTrend instance) =>
    <String, dynamic>{
      'diagnosisCode': instance.diagnosisCode,
      'diagnosisTitle': instance.diagnosisTitle,
      'period': instance.period,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalCases': instance.totalCases,
      'newCases': instance.newCases,
      'resolvedCases': instance.resolvedCases,
      'prevalence': instance.prevalence,
      'incidence': instance.incidence,
      'timeSeriesData': instance.timeSeriesData,
      'demographics': instance.demographics,
      'riskFactors': instance.riskFactors,
      'outcomes': instance.outcomes,
      'metadata': instance.metadata,
    };

DiagnosisStatistics _$DiagnosisStatisticsFromJson(
  Map<String, dynamic> json,
) => DiagnosisStatistics(
  totalDiagnoses: (json['totalDiagnoses'] as num).toInt(),
  activeDiagnoses: (json['activeDiagnoses'] as num).toInt(),
  resolvedDiagnoses: (json['resolvedDiagnoses'] as num).toInt(),
  chronicDiagnoses: (json['chronicDiagnoses'] as num).toInt(),
  diagnosesByCategory: Map<String, int>.from(
    json['diagnosesByCategory'] as Map,
  ),
  diagnosesBySeverity: Map<String, int>.from(
    json['diagnosesBySeverity'] as Map,
  ),
  diagnosesBySystem: Map<String, int>.from(json['diagnosesBySystem'] as Map),
  topTrendingDiagnoses: (json['topTrendingDiagnoses'] as List<dynamic>)
      .map((e) => DiagnosisTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  averageResolutionTime: (json['averageResolutionTime'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  treatmentSuccessRate: (json['treatmentSuccessRate'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  metadata: json['metadata'] as Map<String, dynamic>,
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$DiagnosisStatisticsToJson(
  DiagnosisStatistics instance,
) => <String, dynamic>{
  'totalDiagnoses': instance.totalDiagnoses,
  'activeDiagnoses': instance.activeDiagnoses,
  'resolvedDiagnoses': instance.resolvedDiagnoses,
  'chronicDiagnoses': instance.chronicDiagnoses,
  'diagnosesByCategory': instance.diagnosesByCategory,
  'diagnosesBySeverity': instance.diagnosesBySeverity,
  'diagnosesBySystem': instance.diagnosesBySystem,
  'topTrendingDiagnoses': instance.topTrendingDiagnoses,
  'averageResolutionTime': instance.averageResolutionTime,
  'treatmentSuccessRate': instance.treatmentSuccessRate,
  'metadata': instance.metadata,
  'calculatedAt': instance.calculatedAt.toIso8601String(),
};

DiagnosisSearchFilters _$DiagnosisSearchFiltersFromJson(
  Map<String, dynamic> json,
) => DiagnosisSearchFilters(
  classificationSystems: (json['classificationSystems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  subcategories: (json['subcategories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  severityLevels: (json['severityLevels'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  chronicityTypes: (json['chronicityTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  languages: (json['languages'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  includeInactive: json['includeInactive'] as bool,
  includeAI: json['includeAI'] as bool,
  includeSynonyms: json['includeSynonyms'] as bool,
  includeRelated: json['includeRelated'] as bool,
  maxResults: (json['maxResults'] as num).toInt(),
  sortBy: json['sortBy'] as String,
  sortOrder: json['sortOrder'] as String,
  customFilters: json['customFilters'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DiagnosisSearchFiltersToJson(
  DiagnosisSearchFilters instance,
) => <String, dynamic>{
  'classificationSystems': instance.classificationSystems,
  'categories': instance.categories,
  'subcategories': instance.subcategories,
  'severityLevels': instance.severityLevels,
  'chronicityTypes': instance.chronicityTypes,
  'languages': instance.languages,
  'includeInactive': instance.includeInactive,
  'includeAI': instance.includeAI,
  'includeSynonyms': instance.includeSynonyms,
  'includeRelated': instance.includeRelated,
  'maxResults': instance.maxResults,
  'sortBy': instance.sortBy,
  'sortOrder': instance.sortOrder,
  'customFilters': instance.customFilters,
};

DiagnosisSuggestionSettings _$DiagnosisSuggestionSettingsFromJson(
  Map<String, dynamic> json,
) => DiagnosisSuggestionSettings(
  minConfidence: (json['minConfidence'] as num).toDouble(),
  maxSuggestions: (json['maxSuggestions'] as num).toInt(),
  preferredSystems: (json['preferredSystems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  excludedCategories: (json['excludedCategories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  includeDifferentialDiagnosis: json['includeDifferentialDiagnosis'] as bool,
  includeTreatmentOptions: json['includeTreatmentOptions'] as bool,
  includeRiskFactors: json['includeRiskFactors'] as bool,
  includeComorbidities: json['includeComorbidities'] as bool,
  language: json['language'] as String,
  customSettings: json['customSettings'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DiagnosisSuggestionSettingsToJson(
  DiagnosisSuggestionSettings instance,
) => <String, dynamic>{
  'minConfidence': instance.minConfidence,
  'maxSuggestions': instance.maxSuggestions,
  'preferredSystems': instance.preferredSystems,
  'excludedCategories': instance.excludedCategories,
  'includeDifferentialDiagnosis': instance.includeDifferentialDiagnosis,
  'includeTreatmentOptions': instance.includeTreatmentOptions,
  'includeRiskFactors': instance.includeRiskFactors,
  'includeComorbidities': instance.includeComorbidities,
  'language': instance.language,
  'customSettings': instance.customSettings,
};
