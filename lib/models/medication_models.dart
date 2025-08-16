import 'package:json_annotation/json_annotation.dart';

part 'medication_models.g.dart';

// WHO Drug Dictionary - Uluslararası standart
@JsonSerializable()
class WHODrug {
  final String atcCode;
  final String name;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String country;
  final List<String> activeIngredients;
  final List<String> excipients;
  final String dosageForm;
  final String strength;
  final String route;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;
  final List<String> precautions;
  final Map<String, String> translations;
  final bool isActive;
  final DateTime lastUpdated;

  WHODrug({
    required this.atcCode,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.country,
    required this.activeIngredients,
    required this.excipients,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.warnings,
    required this.precautions,
    required this.translations,
    required this.isActive,
    required this.lastUpdated,
  });

  factory WHODrug.fromJson(Map<String, dynamic> json) => _$WHODrugFromJson(json);
  Map<String, dynamic> toJson() => _$WHODrugToJson(this);
}

// FDA Orange Book - ABD onaylı ilaçlar
@JsonSerializable()
class FDADrug {
  final String ndcCode;
  final String name;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String dosageForm;
  final String strength;
  final String route;
  final String approvalDate;
  final String patentExpiry;
  final String exclusivityExpiry;
  final List<String> activeIngredients;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;
  final List<String> precautions;
  final String pregnancyCategory;
  final String lactationCategory;
  final bool isGeneric;
  final bool isBrand;
  final bool isActive;
  final DateTime lastUpdated;

  FDADrug({
    required this.ndcCode,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.approvalDate,
    required this.patentExpiry,
    required this.exclusivityExpiry,
    required this.activeIngredients,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.warnings,
    required this.precautions,
    required this.pregnancyCategory,
    required this.lactationCategory,
    required this.isGeneric,
    required this.isBrand,
    required this.isActive,
    required this.lastUpdated,
  });

  factory FDADrug.fromJson(Map<String, dynamic> json) => _$FDADrugFromJson(json);
  Map<String, dynamic> toJson() => _$FDADrugToJson(this);
}

// EMA Database - Avrupa ilaç ajansı
@JsonSerializable()
class EMADrug {
  final String emaCode;
  final String name;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String dosageForm;
  final String strength;
  final String route;
  final String approvalDate;
  final String expiryDate;
  final List<String> activeIngredients;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;
  final List<String> precautions;
  final String pregnancyCategory;
  final String lactationCategory;
  final List<String> authorizedCountries;
  final bool isActive;
  final DateTime lastUpdated;

  EMADrug({
    required this.emaCode,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.approvalDate,
    required this.expiryDate,
    required this.activeIngredients,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.warnings,
    required this.precautions,
    required this.pregnancyCategory,
    required this.lactationCategory,
    required this.authorizedCountries,
    required this.isActive,
    required this.lastUpdated,
  });

  factory EMADrug.fromJson(Map<String, dynamic> json) => _$EMADrugFromJson(json);
  Map<String, dynamic> toJson() => _$EMADrugToJson(this);
}

// Türkiye İlaç Kurumu - Yerel veritabanı
@JsonSerializable()
class TurkeyDrug {
  final String ruhsatNo;
  final String name;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String importer;
  final String dosageForm;
  final String strength;
  final String route;
  final String ruhsatDate;
  final String expiryDate;
  final List<String> activeIngredients;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;
  final List<String> precautions;
  final String pregnancyCategory;
  final String lactationCategory;
  final String reimbursementStatus;
  final bool isActive;
  final DateTime lastUpdated;

  TurkeyDrug({
    required this.ruhsatNo,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.importer,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.ruhsatDate,
    required this.expiryDate,
    required this.activeIngredients,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.warnings,
    required this.precautions,
    required this.pregnancyCategory,
    required this.lactationCategory,
    required this.reimbursementStatus,
    required this.isActive,
    required this.lastUpdated,
  });

  factory TurkeyDrug.fromJson(Map<String, dynamic> json) => _$TurkeyDrugFromJson(json);
  Map<String, dynamic> toJson() => _$TurkeyDrugToJson(this);
}

// İlaç Etkileşimi
@JsonSerializable()
class DrugInteraction {
  final String id;
  final String drug1Id;
  final String drug1Name;
  final String drug2Id;
  final String drug2Name;
  final String interactionType; // major, moderate, minor
  final String severity; // high, medium, low
  final String description;
  final String mechanism;
  final List<String> symptoms;
  final List<String> recommendations;
  final List<String> alternatives;
  final String evidence;
  final String source;
  final DateTime lastUpdated;

  DrugInteraction({
    required this.id,
    required this.drug1Id,
    required this.drug1Name,
    required this.drug2Id,
    required this.drug2Name,
    required this.interactionType,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.symptoms,
    required this.recommendations,
    required this.alternatives,
    required this.evidence,
    required this.source,
    required this.lastUpdated,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => _$DrugInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$DrugInteractionToJson(this);
}

// İlaç-Besin Etkileşimi
@JsonSerializable()
class DrugFoodInteraction {
  final String id;
  final String drugId;
  final String drugName;
  final String foodItem;
  final String interactionType;
  final String severity;
  final String description;
  final String mechanism;
  final List<String> recommendations;
  final String timing;
  final String source;
  final DateTime lastUpdated;

  DrugFoodInteraction({
    required this.id,
    required this.drugId,
    required this.drugName,
    required this.foodItem,
    required this.interactionType,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.recommendations,
    required this.timing,
    required this.source,
    required this.lastUpdated,
  });

  factory DrugFoodInteraction.fromJson(Map<String, dynamic> json) => _$DrugFoodInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$DrugFoodInteractionToJson(this);
}

// İlaç-Hastalık Etkileşimi
@JsonSerializable()
class DrugDiseaseInteraction {
  final String id;
  final String drugId;
  final String drugName;
  final String diseaseId;
  final String diseaseName;
  final String interactionType;
  final String severity;
  final String description;
  final String mechanism;
  final List<String> recommendations;
  final List<String> alternatives;
  final String source;
  final DateTime lastUpdated;

  DrugDiseaseInteraction({
    required this.id,
    required this.drugId,
    required this.drugName,
    required this.diseaseId,
    required this.diseaseName,
    required this.interactionType,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.recommendations,
    required this.alternatives,
    required this.source,
    required this.lastUpdated,
  });

  factory DrugDiseaseInteraction.fromJson(Map<String, dynamic> json) => _$DrugDiseaseInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$DrugDiseaseInteractionToJson(this);
}

// Yan Etki
@JsonSerializable()
class SideEffect {
  final String id;
  final String drugId;
  final String drugName;
  final String name;
  final String description;
  final String frequency; // very common, common, uncommon, rare, very rare
  final String severity; // mild, moderate, severe, life-threatening
  final List<String> symptoms;
  final List<String> riskFactors;
  final List<String> management;
  final String onset;
  final String duration;
  final bool isReversible;
  final String source;
  final DateTime lastUpdated;

  SideEffect({
    required this.id,
    required this.drugId,
    required this.drugName,
    required this.name,
    required this.description,
    required this.frequency,
    required this.severity,
    required this.symptoms,
    required this.riskFactors,
    required this.management,
    required this.onset,
    required this.duration,
    required this.isReversible,
    required this.source,
    required this.lastUpdated,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) => _$SideEffectFromJson(json);
  Map<String, dynamic> toJson() => _$SideEffectToJson(this);
}

// Doz Bilgisi
@JsonSerializable()
class DosageInfo {
  final String id;
  final String drugId;
  final String drugName;
  final String indication;
  final String ageGroup;
  final String weightRange;
  final String renalFunction;
  final String hepaticFunction;
  final String loadingDose;
  final String maintenanceDose;
  final String maxDose;
  final String frequency;
  final String duration;
  final String route;
  final List<String> adjustments;
  final List<String> contraindications;
  final String source;
  final DateTime lastUpdated;

  DosageInfo({
    required this.id,
    required this.drugId,
    required this.drugName,
    required this.indication,
    required this.ageGroup,
    required this.weightRange,
    required this.renalFunction,
    required this.hepaticFunction,
    required this.loadingDose,
    required this.maintenanceDose,
    required this.maxDose,
    required this.frequency,
    required this.duration,
    required this.route,
    required this.adjustments,
    required this.contraindications,
    required this.source,
    required this.lastUpdated,
  });

  factory DosageInfo.fromJson(Map<String, dynamic> json) => _$DosageInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DosageInfoToJson(this);
}

// AI Destekli İlaç Önerisi
@JsonSerializable()
class AIMedicationSuggestion {
  final String id;
  final String suggestedMedication;
  final String medicationCode;
  final String classificationSystem; // WHO, FDA, EMA, Turkey
  final double confidence;
  final List<String> supportingFactors;
  final List<String> contraindications;
  final List<String> interactions;
  final List<String> sideEffects;
  final String recommendedDosage;
  final String reasoning;
  final List<String> alternatives;
  final List<String> monitoring;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;

  AIMedicationSuggestion({
    required this.id,
    required this.suggestedMedication,
    required this.medicationCode,
    required this.classificationSystem,
    required this.confidence,
    required this.supportingFactors,
    required this.contraindications,
    required this.interactions,
    required this.sideEffects,
    required this.recommendedDosage,
    required this.reasoning,
    required this.alternatives,
    required this.monitoring,
    required this.metadata,
    required this.generatedAt,
  });

  factory AIMedicationSuggestion.fromJson(Map<String, dynamic> json) => _$AIMedicationSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$AIMedicationSuggestionToJson(this);
}

// İlaç Arama Sonucu
@JsonSerializable()
class MedicationSearchResult {
  final List<WHODrug> whoResults;
  final List<FDADrug> fdaResults;
  final List<EMADrug> emaResults;
  final List<TurkeyDrug> turkeyResults;
  final List<AIMedicationSuggestion> aiSuggestions;
  final int totalResults;
  final String searchQuery;
  final List<String> filters;
  final Map<String, dynamic> metadata;
  final DateTime searchedAt;

  MedicationSearchResult({
    required this.whoResults,
    required this.fdaResults,
    required this.emaResults,
    required this.turkeyResults,
    required this.aiSuggestions,
    required this.totalResults,
    required this.searchQuery,
    required this.filters,
    required this.metadata,
    required this.searchedAt,
  });

  factory MedicationSearchResult.fromJson(Map<String, dynamic> json) => _$MedicationSearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationSearchResultToJson(this);
}

// İlaç Arama Filtreleri
@JsonSerializable()
class MedicationSearchFilters {
  final List<String> classificationSystems;
  final List<String> dosageForms;
  final List<String> routes;
  final List<String> manufacturers;
  final List<String> countries;
  final bool includeGeneric;
  final bool includeBrand;
  final bool includeInactive;
  final bool includeAI;
  final int maxResults;
  final String sortBy;
  final String sortOrder;
  final Map<String, dynamic> customFilters;

  MedicationSearchFilters({
    required this.classificationSystems,
    required this.dosageForms,
    required this.routes,
    required this.manufacturers,
    required this.countries,
    required this.includeGeneric,
    required this.includeBrand,
    required this.includeInactive,
    required this.includeAI,
    required this.maxResults,
    required this.sortBy,
    required this.sortOrder,
    required this.customFilters,
  });

  factory MedicationSearchFilters.fromJson(Map<String, dynamic> json) => _$MedicationSearchFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationSearchFiltersToJson(this);
}

// İlaç Öneri Ayarları
@JsonSerializable()
class MedicationSuggestionSettings {
  final double minConfidence;
  final int maxSuggestions;
  final List<String> preferredSystems;
  final List<String> excludedCategories;
  final bool includeInteractions;
  final bool includeSideEffects;
  final bool includeAlternatives;
  final bool includeMonitoring;
  final String language;
  final Map<String, dynamic> customSettings;

  MedicationSuggestionSettings({
    required this.minConfidence,
    required this.maxSuggestions,
    required this.preferredSystems,
    required this.excludedCategories,
    required this.includeInteractions,
    required this.includeSideEffects,
    required this.includeAlternatives,
    required this.includeMonitoring,
    required this.language,
    required this.customSettings,
  });

  factory MedicationSuggestionSettings.fromJson(Map<String, dynamic> json) => _$MedicationSuggestionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationSuggestionSettingsToJson(this);
}

// Hasta İlaç Profili
@JsonSerializable()
class PatientMedicationProfile {
  final String patientId;
  final List<String> currentMedications;
  final List<String> pastMedications;
  final List<String> allergies;
  final List<String> intolerances;
  final List<String> medicalConditions;
  final Map<String, dynamic> labResults;
  final Map<String, dynamic> vitalSigns;
  final String age;
  final String gender;
  final String weight;
  final String height;
  final String renalFunction;
  final String hepaticFunction;
  final String pregnancyStatus;
  final String lactationStatus;
  final List<String> geneticFactors;
  final Map<String, dynamic> metadata;
  final DateTime lastUpdated;

  PatientMedicationProfile({
    required this.patientId,
    required this.currentMedications,
    required this.pastMedications,
    required this.allergies,
    required this.intolerances,
    required this.medicalConditions,
    required this.labResults,
    required this.vitalSigns,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.renalFunction,
    required this.hepaticFunction,
    required this.pregnancyStatus,
    required this.lactationStatus,
    required this.geneticFactors,
    required this.metadata,
    required this.lastUpdated,
  });

  factory PatientMedicationProfile.fromJson(Map<String, dynamic> json) => _$PatientMedicationProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PatientMedicationProfileToJson(this);
}

// İlaç Güvenlik Uyarısı
@JsonSerializable()
class MedicationSafetyAlert {
  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final String alertType; // interaction, allergy, contraindication, dosage, pregnancy, lactation
  final String severity; // critical, high, medium, low
  final String description;
  final String recommendation;
  final List<String> affectedMedications;
  final List<String> affectedConditions;
  final bool requiresAction;
  final bool isAcknowledged;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final String acknowledgedBy;
  final Map<String, dynamic> metadata;

  MedicationSafetyAlert({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.alertType,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.affectedMedications,
    required this.affectedConditions,
    required this.requiresAction,
    required this.isAcknowledged,
    required this.createdAt,
    this.acknowledgedAt,
    required this.acknowledgedBy,
    required this.metadata,
  });

  factory MedicationSafetyAlert.fromJson(Map<String, dynamic> json) => _$MedicationSafetyAlertFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationSafetyAlertToJson(this);
}
