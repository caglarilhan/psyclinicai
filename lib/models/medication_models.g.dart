// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WHODrug _$WHODrugFromJson(Map<String, dynamic> json) => WHODrug(
  atcCode: json['atcCode'] as String,
  name: json['name'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  manufacturer: json['manufacturer'] as String,
  country: json['country'] as String,
  activeIngredients: (json['activeIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  excipients: (json['excipients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosageForm: json['dosageForm'] as String,
  strength: json['strength'] as String,
  route: json['route'] as String,
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  precautions: (json['precautions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  translations: Map<String, String>.from(json['translations'] as Map),
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$WHODrugToJson(WHODrug instance) => <String, dynamic>{
  'atcCode': instance.atcCode,
  'name': instance.name,
  'genericName': instance.genericName,
  'brandName': instance.brandName,
  'manufacturer': instance.manufacturer,
  'country': instance.country,
  'activeIngredients': instance.activeIngredients,
  'excipients': instance.excipients,
  'dosageForm': instance.dosageForm,
  'strength': instance.strength,
  'route': instance.route,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'warnings': instance.warnings,
  'precautions': instance.precautions,
  'translations': instance.translations,
  'isActive': instance.isActive,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

FDADrug _$FDADrugFromJson(Map<String, dynamic> json) => FDADrug(
  ndcCode: json['ndcCode'] as String,
  name: json['name'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  manufacturer: json['manufacturer'] as String,
  dosageForm: json['dosageForm'] as String,
  strength: json['strength'] as String,
  route: json['route'] as String,
  approvalDate: json['approvalDate'] as String,
  patentExpiry: json['patentExpiry'] as String,
  exclusivityExpiry: json['exclusivityExpiry'] as String,
  activeIngredients: (json['activeIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  precautions: (json['precautions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pregnancyCategory: json['pregnancyCategory'] as String,
  lactationCategory: json['lactationCategory'] as String,
  isGeneric: json['isGeneric'] as bool,
  isBrand: json['isBrand'] as bool,
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$FDADrugToJson(FDADrug instance) => <String, dynamic>{
  'ndcCode': instance.ndcCode,
  'name': instance.name,
  'genericName': instance.genericName,
  'brandName': instance.brandName,
  'manufacturer': instance.manufacturer,
  'dosageForm': instance.dosageForm,
  'strength': instance.strength,
  'route': instance.route,
  'approvalDate': instance.approvalDate,
  'patentExpiry': instance.patentExpiry,
  'exclusivityExpiry': instance.exclusivityExpiry,
  'activeIngredients': instance.activeIngredients,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'warnings': instance.warnings,
  'precautions': instance.precautions,
  'pregnancyCategory': instance.pregnancyCategory,
  'lactationCategory': instance.lactationCategory,
  'isGeneric': instance.isGeneric,
  'isBrand': instance.isBrand,
  'isActive': instance.isActive,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

EMADrug _$EMADrugFromJson(Map<String, dynamic> json) => EMADrug(
  emaCode: json['emaCode'] as String,
  name: json['name'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  manufacturer: json['manufacturer'] as String,
  dosageForm: json['dosageForm'] as String,
  strength: json['strength'] as String,
  route: json['route'] as String,
  approvalDate: json['approvalDate'] as String,
  expiryDate: json['expiryDate'] as String,
  activeIngredients: (json['activeIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  precautions: (json['precautions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pregnancyCategory: json['pregnancyCategory'] as String,
  lactationCategory: json['lactationCategory'] as String,
  authorizedCountries: (json['authorizedCountries'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$EMADrugToJson(EMADrug instance) => <String, dynamic>{
  'emaCode': instance.emaCode,
  'name': instance.name,
  'genericName': instance.genericName,
  'brandName': instance.brandName,
  'manufacturer': instance.manufacturer,
  'dosageForm': instance.dosageForm,
  'strength': instance.strength,
  'route': instance.route,
  'approvalDate': instance.approvalDate,
  'expiryDate': instance.expiryDate,
  'activeIngredients': instance.activeIngredients,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'warnings': instance.warnings,
  'precautions': instance.precautions,
  'pregnancyCategory': instance.pregnancyCategory,
  'lactationCategory': instance.lactationCategory,
  'authorizedCountries': instance.authorizedCountries,
  'isActive': instance.isActive,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

TurkeyDrug _$TurkeyDrugFromJson(Map<String, dynamic> json) => TurkeyDrug(
  ruhsatNo: json['ruhsatNo'] as String,
  name: json['name'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  manufacturer: json['manufacturer'] as String,
  importer: json['importer'] as String,
  dosageForm: json['dosageForm'] as String,
  strength: json['strength'] as String,
  route: json['route'] as String,
  ruhsatDate: json['ruhsatDate'] as String,
  expiryDate: json['expiryDate'] as String,
  activeIngredients: (json['activeIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  precautions: (json['precautions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pregnancyCategory: json['pregnancyCategory'] as String,
  lactationCategory: json['lactationCategory'] as String,
  reimbursementStatus: json['reimbursementStatus'] as String,
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$TurkeyDrugToJson(TurkeyDrug instance) =>
    <String, dynamic>{
      'ruhsatNo': instance.ruhsatNo,
      'name': instance.name,
      'genericName': instance.genericName,
      'brandName': instance.brandName,
      'manufacturer': instance.manufacturer,
      'importer': instance.importer,
      'dosageForm': instance.dosageForm,
      'strength': instance.strength,
      'route': instance.route,
      'ruhsatDate': instance.ruhsatDate,
      'expiryDate': instance.expiryDate,
      'activeIngredients': instance.activeIngredients,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'sideEffects': instance.sideEffects,
      'interactions': instance.interactions,
      'warnings': instance.warnings,
      'precautions': instance.precautions,
      'pregnancyCategory': instance.pregnancyCategory,
      'lactationCategory': instance.lactationCategory,
      'reimbursementStatus': instance.reimbursementStatus,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) =>
    DrugInteraction(
      id: json['id'] as String,
      drug1Id: json['drug1Id'] as String,
      drug1Name: json['drug1Name'] as String,
      drug2Id: json['drug2Id'] as String,
      drug2Name: json['drug2Name'] as String,
      interactionType: json['interactionType'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      mechanism: json['mechanism'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evidence: json['evidence'] as String,
      source: json['source'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$DrugInteractionToJson(DrugInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drug1Id': instance.drug1Id,
      'drug1Name': instance.drug1Name,
      'drug2Id': instance.drug2Id,
      'drug2Name': instance.drug2Name,
      'interactionType': instance.interactionType,
      'severity': instance.severity,
      'description': instance.description,
      'mechanism': instance.mechanism,
      'symptoms': instance.symptoms,
      'recommendations': instance.recommendations,
      'alternatives': instance.alternatives,
      'evidence': instance.evidence,
      'source': instance.source,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

DrugFoodInteraction _$DrugFoodInteractionFromJson(Map<String, dynamic> json) =>
    DrugFoodInteraction(
      id: json['id'] as String,
      drugId: json['drugId'] as String,
      drugName: json['drugName'] as String,
      foodItem: json['foodItem'] as String,
      interactionType: json['interactionType'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      mechanism: json['mechanism'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timing: json['timing'] as String,
      source: json['source'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$DrugFoodInteractionToJson(
  DrugFoodInteraction instance,
) => <String, dynamic>{
  'id': instance.id,
  'drugId': instance.drugId,
  'drugName': instance.drugName,
  'foodItem': instance.foodItem,
  'interactionType': instance.interactionType,
  'severity': instance.severity,
  'description': instance.description,
  'mechanism': instance.mechanism,
  'recommendations': instance.recommendations,
  'timing': instance.timing,
  'source': instance.source,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

DrugDiseaseInteraction _$DrugDiseaseInteractionFromJson(
  Map<String, dynamic> json,
) => DrugDiseaseInteraction(
  id: json['id'] as String,
  drugId: json['drugId'] as String,
  drugName: json['drugName'] as String,
  diseaseId: json['diseaseId'] as String,
  diseaseName: json['diseaseName'] as String,
  interactionType: json['interactionType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  mechanism: json['mechanism'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  source: json['source'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$DrugDiseaseInteractionToJson(
  DrugDiseaseInteraction instance,
) => <String, dynamic>{
  'id': instance.id,
  'drugId': instance.drugId,
  'drugName': instance.drugName,
  'diseaseId': instance.diseaseId,
  'diseaseName': instance.diseaseName,
  'interactionType': instance.interactionType,
  'severity': instance.severity,
  'description': instance.description,
  'mechanism': instance.mechanism,
  'recommendations': instance.recommendations,
  'alternatives': instance.alternatives,
  'source': instance.source,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

SideEffect _$SideEffectFromJson(Map<String, dynamic> json) => SideEffect(
  id: json['id'] as String,
  drugId: json['drugId'] as String,
  drugName: json['drugName'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  frequency: json['frequency'] as String,
  severity: json['severity'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  management: (json['management'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  onset: json['onset'] as String,
  duration: json['duration'] as String,
  isReversible: json['isReversible'] as bool,
  source: json['source'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$SideEffectToJson(SideEffect instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugId': instance.drugId,
      'drugName': instance.drugName,
      'name': instance.name,
      'description': instance.description,
      'frequency': instance.frequency,
      'severity': instance.severity,
      'symptoms': instance.symptoms,
      'riskFactors': instance.riskFactors,
      'management': instance.management,
      'onset': instance.onset,
      'duration': instance.duration,
      'isReversible': instance.isReversible,
      'source': instance.source,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

DosageInfo _$DosageInfoFromJson(Map<String, dynamic> json) => DosageInfo(
  id: json['id'] as String,
  drugId: json['drugId'] as String,
  drugName: json['drugName'] as String,
  indication: json['indication'] as String,
  ageGroup: json['ageGroup'] as String,
  weightRange: json['weightRange'] as String,
  renalFunction: json['renalFunction'] as String,
  hepaticFunction: json['hepaticFunction'] as String,
  loadingDose: json['loadingDose'] as String,
  maintenanceDose: json['maintenanceDose'] as String,
  maxDose: json['maxDose'] as String,
  frequency: json['frequency'] as String,
  duration: json['duration'] as String,
  route: json['route'] as String,
  adjustments: (json['adjustments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  source: json['source'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$DosageInfoToJson(DosageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugId': instance.drugId,
      'drugName': instance.drugName,
      'indication': instance.indication,
      'ageGroup': instance.ageGroup,
      'weightRange': instance.weightRange,
      'renalFunction': instance.renalFunction,
      'hepaticFunction': instance.hepaticFunction,
      'loadingDose': instance.loadingDose,
      'maintenanceDose': instance.maintenanceDose,
      'maxDose': instance.maxDose,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'route': instance.route,
      'adjustments': instance.adjustments,
      'contraindications': instance.contraindications,
      'source': instance.source,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

AIMedicationSuggestion _$AIMedicationSuggestionFromJson(
  Map<String, dynamic> json,
) => AIMedicationSuggestion(
  id: json['id'] as String,
  suggestedMedication: json['suggestedMedication'] as String,
  medicationCode: json['medicationCode'] as String,
  classificationSystem: json['classificationSystem'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  supportingFactors: (json['supportingFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedDosage: json['recommendedDosage'] as String,
  reasoning: json['reasoning'] as String,
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoring: (json['monitoring'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$AIMedicationSuggestionToJson(
  AIMedicationSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'suggestedMedication': instance.suggestedMedication,
  'medicationCode': instance.medicationCode,
  'classificationSystem': instance.classificationSystem,
  'confidence': instance.confidence,
  'supportingFactors': instance.supportingFactors,
  'contraindications': instance.contraindications,
  'interactions': instance.interactions,
  'sideEffects': instance.sideEffects,
  'recommendedDosage': instance.recommendedDosage,
  'reasoning': instance.reasoning,
  'alternatives': instance.alternatives,
  'monitoring': instance.monitoring,
  'metadata': instance.metadata,
  'generatedAt': instance.generatedAt.toIso8601String(),
};

MedicationSearchResult _$MedicationSearchResultFromJson(
  Map<String, dynamic> json,
) => MedicationSearchResult(
  whoResults: (json['whoResults'] as List<dynamic>)
      .map((e) => WHODrug.fromJson(e as Map<String, dynamic>))
      .toList(),
  fdaResults: (json['fdaResults'] as List<dynamic>)
      .map((e) => FDADrug.fromJson(e as Map<String, dynamic>))
      .toList(),
  emaResults: (json['emaResults'] as List<dynamic>)
      .map((e) => EMADrug.fromJson(e as Map<String, dynamic>))
      .toList(),
  turkeyResults: (json['turkeyResults'] as List<dynamic>)
      .map((e) => TurkeyDrug.fromJson(e as Map<String, dynamic>))
      .toList(),
  aiSuggestions: (json['aiSuggestions'] as List<dynamic>)
      .map((e) => AIMedicationSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalResults: (json['totalResults'] as num).toInt(),
  searchQuery: json['searchQuery'] as String,
  filters: (json['filters'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  searchedAt: DateTime.parse(json['searchedAt'] as String),
);

Map<String, dynamic> _$MedicationSearchResultToJson(
  MedicationSearchResult instance,
) => <String, dynamic>{
  'whoResults': instance.whoResults,
  'fdaResults': instance.fdaResults,
  'emaResults': instance.emaResults,
  'turkeyResults': instance.turkeyResults,
  'aiSuggestions': instance.aiSuggestions,
  'totalResults': instance.totalResults,
  'searchQuery': instance.searchQuery,
  'filters': instance.filters,
  'metadata': instance.metadata,
  'searchedAt': instance.searchedAt.toIso8601String(),
};

MedicationSearchFilters _$MedicationSearchFiltersFromJson(
  Map<String, dynamic> json,
) => MedicationSearchFilters(
  classificationSystems: (json['classificationSystems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosageForms: (json['dosageForms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  routes: (json['routes'] as List<dynamic>).map((e) => e as String).toList(),
  manufacturers: (json['manufacturers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  countries: (json['countries'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  includeGeneric: json['includeGeneric'] as bool,
  includeBrand: json['includeBrand'] as bool,
  includeInactive: json['includeInactive'] as bool,
  includeAI: json['includeAI'] as bool,
  maxResults: (json['maxResults'] as num).toInt(),
  sortBy: json['sortBy'] as String,
  sortOrder: json['sortOrder'] as String,
  customFilters: json['customFilters'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationSearchFiltersToJson(
  MedicationSearchFilters instance,
) => <String, dynamic>{
  'classificationSystems': instance.classificationSystems,
  'dosageForms': instance.dosageForms,
  'routes': instance.routes,
  'manufacturers': instance.manufacturers,
  'countries': instance.countries,
  'includeGeneric': instance.includeGeneric,
  'includeBrand': instance.includeBrand,
  'includeInactive': instance.includeInactive,
  'includeAI': instance.includeAI,
  'maxResults': instance.maxResults,
  'sortBy': instance.sortBy,
  'sortOrder': instance.sortOrder,
  'customFilters': instance.customFilters,
};

MedicationSuggestionSettings _$MedicationSuggestionSettingsFromJson(
  Map<String, dynamic> json,
) => MedicationSuggestionSettings(
  minConfidence: (json['minConfidence'] as num).toDouble(),
  maxSuggestions: (json['maxSuggestions'] as num).toInt(),
  preferredSystems: (json['preferredSystems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  excludedCategories: (json['excludedCategories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  includeInteractions: json['includeInteractions'] as bool,
  includeSideEffects: json['includeSideEffects'] as bool,
  includeAlternatives: json['includeAlternatives'] as bool,
  includeMonitoring: json['includeMonitoring'] as bool,
  language: json['language'] as String,
  customSettings: json['customSettings'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationSuggestionSettingsToJson(
  MedicationSuggestionSettings instance,
) => <String, dynamic>{
  'minConfidence': instance.minConfidence,
  'maxSuggestions': instance.maxSuggestions,
  'preferredSystems': instance.preferredSystems,
  'excludedCategories': instance.excludedCategories,
  'includeInteractions': instance.includeInteractions,
  'includeSideEffects': instance.includeSideEffects,
  'includeAlternatives': instance.includeAlternatives,
  'includeMonitoring': instance.includeMonitoring,
  'language': instance.language,
  'customSettings': instance.customSettings,
};

PatientMedicationProfile _$PatientMedicationProfileFromJson(
  Map<String, dynamic> json,
) => PatientMedicationProfile(
  patientId: json['patientId'] as String,
  currentMedications: (json['currentMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pastMedications: (json['pastMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  allergies: (json['allergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  intolerances: (json['intolerances'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicalConditions: (json['medicalConditions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  labResults: json['labResults'] as Map<String, dynamic>,
  vitalSigns: json['vitalSigns'] as Map<String, dynamic>,
  age: json['age'] as String,
  gender: json['gender'] as String,
  weight: json['weight'] as String,
  height: json['height'] as String,
  renalFunction: json['renalFunction'] as String,
  hepaticFunction: json['hepaticFunction'] as String,
  pregnancyStatus: json['pregnancyStatus'] as String,
  lactationStatus: json['lactationStatus'] as String,
  geneticFactors: (json['geneticFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$PatientMedicationProfileToJson(
  PatientMedicationProfile instance,
) => <String, dynamic>{
  'patientId': instance.patientId,
  'currentMedications': instance.currentMedications,
  'pastMedications': instance.pastMedications,
  'allergies': instance.allergies,
  'intolerances': instance.intolerances,
  'medicalConditions': instance.medicalConditions,
  'labResults': instance.labResults,
  'vitalSigns': instance.vitalSigns,
  'age': instance.age,
  'gender': instance.gender,
  'weight': instance.weight,
  'height': instance.height,
  'renalFunction': instance.renalFunction,
  'hepaticFunction': instance.hepaticFunction,
  'pregnancyStatus': instance.pregnancyStatus,
  'lactationStatus': instance.lactationStatus,
  'geneticFactors': instance.geneticFactors,
  'metadata': instance.metadata,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

MedicationSafetyAlert _$MedicationSafetyAlertFromJson(
  Map<String, dynamic> json,
) => MedicationSafetyAlert(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  alertType: json['alertType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  recommendation: json['recommendation'] as String,
  affectedMedications: (json['affectedMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  affectedConditions: (json['affectedConditions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiresAction: json['requiresAction'] as bool,
  isAcknowledged: json['isAcknowledged'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationSafetyAlertToJson(
  MedicationSafetyAlert instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'alertType': instance.alertType,
  'severity': instance.severity,
  'description': instance.description,
  'recommendation': instance.recommendation,
  'affectedMedications': instance.affectedMedications,
  'affectedConditions': instance.affectedConditions,
  'requiresAction': instance.requiresAction,
  'isAcknowledged': instance.isAcknowledged,
  'createdAt': instance.createdAt.toIso8601String(),
  'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
  'acknowledgedBy': instance.acknowledgedBy,
  'metadata': instance.metadata,
};
