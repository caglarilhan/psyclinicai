import 'package:json_annotation/json_annotation.dart';

part 'multi_country_medication.g.dart';

// Multi-Country İlaç Yönetimi
@JsonSerializable()
class MultiCountryMedication {
  final String id;
  final String medicationName;
  final String genericName;
  final String brandName;
  final String activeIngredient;
  final String classification;
  final String mechanism;
  final String dosageForm;
  final String strength;
  final String route;
  final String frequency;
  final int durationDays;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;
  final List<String> precautions;
  final Map<String, dynamic> countrySpecificInfo;
  final List<String> availableCountries;
  final Map<String, dynamic> metadata;

  MultiCountryMedication({
    required this.id,
    required this.medicationName,
    required this.genericName,
    required this.brandName,
    required this.activeIngredient,
    required this.classification,
    required this.mechanism,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.frequency,
    required this.durationDays,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.warnings,
    required this.precautions,
    required this.countrySpecificInfo,
    required this.availableCountries,
    required this.metadata,
  });

  factory MultiCountryMedication.fromJson(Map<String, dynamic> json) =>
      _$MultiCountryMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$MultiCountryMedicationToJson(this);
}

// WHO Drug Dictionary
@JsonSerializable()
class WHODrugDictionary {
  final String id;
  final String drugCode;
  final String drugName;
  final String genericName;
  final String chemicalName;
  final String molecularFormula;
  final String molecularWeight;
  final String classification;
  final String mechanism;
  final List<String> therapeuticIndications;
  final List<String> contraindications;
  final List<String> adverseEffects;
  final List<String> drugInteractions;
  final Map<String, dynamic> pharmacokinetics;
  final List<String> references;
  final Map<String, dynamic> metadata;

  WHODrugDictionary({
    required this.id,
    required this.drugCode,
    required this.drugName,
    required this.genericName,
    required this.chemicalName,
    required this.molecularFormula,
    required this.molecularWeight,
    required this.classification,
    required this.mechanism,
    required this.therapeuticIndications,
    required this.contraindications,
    required this.adverseEffects,
    required this.drugInteractions,
    required this.pharmacokinetics,
    required this.references,
    required this.metadata,
  });

  factory WHODrugDictionary.fromJson(Map<String, dynamic> json) =>
      _$WHODrugDictionaryFromJson(json);

  Map<String, dynamic> toJson() => _$WHODrugDictionaryToJson(this);
}

// FDA Orange Book (US)
@JsonSerializable()
class FDAOrangeBook {
  final String id;
  final String drugName;
  final String genericName;
  final String brandName;
  final String applicationNumber;
  final String productNumber;
  final String strength;
  final String dosageForm;
  final String route;
  final String activeIngredient;
  final String approvalDate;
  final String patentExpiration;
  final String exclusivityExpiration;
  final String therapeuticEquivalence;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  FDAOrangeBook({
    required this.id,
    required this.drugName,
    required this.genericName,
    required this.brandName,
    required this.applicationNumber,
    required this.productNumber,
    required this.strength,
    required this.dosageForm,
    required this.route,
    required this.activeIngredient,
    required this.approvalDate,
    required this.patentExpiration,
    required this.exclusivityExpiration,
    required this.therapeuticEquivalence,
    required this.indications,
    required this.contraindications,
    required this.warnings,
    required this.metadata,
  });

  factory FDAOrangeBook.fromJson(Map<String, dynamic> json) =>
      _$FDAOrangeBookFromJson(json);

  Map<String, dynamic> toJson() => _$FDAOrangeBookToJson(this);
}

// EMA Database (European Union)
@JsonSerializable()
class EMADatabase {
  final String id;
  final String drugName;
  final String genericName;
  final String brandName;
  final String authorizationNumber;
  final String marketingAuthorizationHolder;
  final String authorizationDate;
  final String expirationDate;
  final String status;
  final List<String> therapeuticIndications;
  final List<String> contraindications;
  final List<String> specialWarnings;
  final List<String> adverseReactions;
  final Map<String, dynamic> posology;
  final Map<String, dynamic> metadata;

  EMADatabase({
    required this.id,
    required this.drugName,
    required this.genericName,
    required this.brandName,
    required this.authorizationNumber,
    required this.marketingAuthorizationHolder,
    required this.authorizationDate,
    required this.expirationDate,
    required this.status,
    required this.therapeuticIndications,
    required this.contraindications,
    required this.specialWarnings,
    required this.adverseReactions,
    required this.posology,
    required this.metadata,
  });

  factory EMADatabase.fromJson(Map<String, dynamic> json) =>
      _$EMADatabaseFromJson(json);

  Map<String, dynamic> toJson() => _$EMADatabaseToJson(this);
}

// Türkiye İlaç ve Tıbbi Cihaz Kurumu
@JsonSerializable()
class TurkeyDrugAuthority {
  final String id;
  final String drugName;
  final String genericName;
  final String brandName;
  final String registrationNumber;
  final String marketingAuthorizationHolder;
  final String registrationDate;
  final String expirationDate;
  final String status;
  final List<String> therapeuticIndications;
  final List<String> contraindications;
  final List<String> specialWarnings;
  final List<String> adverseReactions;
  final Map<String, dynamic> posology;
  final Map<String, dynamic> metadata;

  TurkeyDrugAuthority({
    required this.id,
    required this.drugName,
    required this.genericName,
    required this.brandName,
    required this.registrationNumber,
    required this.marketingAuthorizationHolder,
    required this.registrationDate,
    required this.expirationDate,
    required this.status,
    required this.therapeuticIndications,
    required this.contraindications,
    required this.specialWarnings,
    required this.adverseReactions,
    required this.posology,
    required this.metadata,
  });

  factory TurkeyDrugAuthority.fromJson(Map<String, dynamic> json) =>
      _$TurkeyDrugAuthorityFromJson(json);

  Map<String, dynamic> toJson() => _$TurkeyDrugAuthorityToJson(this);
}

// İlaç Etkileşim Kontrolü
@JsonSerializable()
class DrugInteractionChecker {
  final String id;
  final String drug1Id;
  final String drug1Name;
  final String drug2Id;
  final String drug2Name;
  final String interactionType; // major, moderate, minor, none
  final String severity; // high, medium, low
  final String description;
  final String mechanism;
  final List<String> clinicalEffects;
  final List<String> recommendations;
  final List<String> alternatives;
  final double evidenceLevel; // 0.0 - 1.0
  final Map<String, dynamic> metadata;

  DrugInteractionChecker({
    required this.id,
    required this.drug1Id,
    required this.drug1Name,
    required this.drug2Id,
    required this.drug2Name,
    required this.interactionType,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.clinicalEffects,
    required this.recommendations,
    required this.alternatives,
    required this.evidenceLevel,
    required this.metadata,
  });

  factory DrugInteractionChecker.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionCheckerFromJson(json);

  Map<String, dynamic> toJson() => _$DrugInteractionCheckerToJson(this);
}

// Kültürel İlaç Tercihleri
@JsonSerializable()
class CulturalMedicationPreferences {
  final String id;
  final String countryCode;
  final String countryName;
  final String culture;
  final List<String> preferredMedicationTypes;
  final List<String> avoidedMedicationTypes;
  final Map<String, String> traditionalMedicine;
  final List<String> culturalBeliefs;
  final List<String> taboos;
  final Map<String, dynamic> communicationPreferences;
  final List<String> familyInvolvement;
  final Map<String, dynamic> metadata;

  CulturalMedicationPreferences({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.culture,
    required this.preferredMedicationTypes,
    required this.avoidedMedicationTypes,
    required this.traditionalMedicine,
    required this.culturalBeliefs,
    required this.taboos,
    required this.communicationPreferences,
    required this.familyInvolvement,
    required this.metadata,
  });

  factory CulturalMedicationPreferences.fromJson(Map<String, dynamic> json) =>
      _$CulturalMedicationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalMedicationPreferencesToJson(this);
}

// Yerel Eczane Entegrasyonu
@JsonSerializable()
class LocalPharmacyIntegration {
  final String id;
  final String pharmacyId;
  final String pharmacyName;
  final String countryCode;
  final String region;
  final String city;
  final String address;
  final String phone;
  final String email;
  final List<String> availableMedications;
  final List<String> services;
  final Map<String, dynamic> operatingHours;
  final Map<String, dynamic> insuranceAccepted;
  final Map<String, dynamic> metadata;

  LocalPharmacyIntegration({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.countryCode,
    required this.region,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    required this.availableMedications,
    required this.services,
    required this.operatingHours,
    required this.insuranceAccepted,
    required this.metadata,
  });

  factory LocalPharmacyIntegration.fromJson(Map<String, dynamic> json) =>
      _$LocalPharmacyIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$LocalPharmacyIntegrationToJson(this);
}

// İlaç Güvenlik İzleme
@JsonSerializable()
class MedicationSafetyMonitoring {
  final String id;
  final String medicationId;
  final String medicationName;
  final String countryCode;
  final DateTime monitoringStartDate;
  final String monitoringType; // post_marketing, clinical_trial, real_world
  final List<String> safetySignals;
  final List<String> adverseEvents;
  final List<String> riskFactors;
  final Map<String, dynamic> safetyMetrics;
  final String riskLevel; // low, medium, high, critical
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  MedicationSafetyMonitoring({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.countryCode,
    required this.monitoringStartDate,
    required this.monitoringType,
    required this.safetySignals,
    required this.adverseEvents,
    required this.riskFactors,
    required this.safetyMetrics,
    required this.riskLevel,
    required this.recommendations,
    required this.metadata,
  });

  factory MedicationSafetyMonitoring.fromJson(Map<String, dynamic> json) =>
      _$MedicationSafetyMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationSafetyMonitoringToJson(this);
}

// İlaç Maliyet Analizi
@JsonSerializable()
class MedicationCostAnalysis {
  final String id;
  final String medicationId;
  final String medicationName;
  final String countryCode;
  final double unitCost;
  final String currency;
  final String costType; // retail, wholesale, insurance
  final double insuranceCoverage;
  final double patientCost;
  final List<String> costFactors;
  final Map<String, dynamic> pricingHistory;
  final List<String> alternatives;
  final Map<String, dynamic> metadata;

  MedicationCostAnalysis({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.countryCode,
    required this.unitCost,
    required this.currency,
    required this.costType,
    required this.insuranceCoverage,
    required this.patientCost,
    required this.costFactors,
    required this.pricingHistory,
    required this.alternatives,
    required this.metadata,
  });

  factory MedicationCostAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MedicationCostAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationCostAnalysisToJson(this);
}

// İlaç Erişilebilirlik
@JsonSerializable()
class MedicationAccessibility {
  final String id;
  final String medicationId;
  final String medicationName;
  final String countryCode;
  final String region;
  final String availabilityStatus; // available, limited, unavailable
  final List<String> distributionChannels;
  final List<String> barriers;
  final Map<String, dynamic> accessibilityMetrics;
  final List<String> improvementStrategies;
  final Map<String, dynamic> metadata;

  MedicationAccessibility({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.countryCode,
    required this.region,
    required this.availabilityStatus,
    required this.distributionChannels,
    required this.barriers,
    required this.accessibilityMetrics,
    required this.improvementStrategies,
    required this.metadata,
  });

  factory MedicationAccessibility.fromJson(Map<String, dynamic> json) =>
      _$MedicationAccessibilityFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationAccessibilityFromJson(this);
}

// İlaç Kalite Kontrolü
@JsonSerializable()
class MedicationQualityControl {
  final String id;
  final String medicationId;
  final String medicationName;
  final String manufacturer;
  final String batchNumber;
  final DateTime manufacturingDate;
  final DateTime expirationDate;
  final String qualityStatus; // approved, pending, rejected
  final List<String> qualityTests;
  final Map<String, dynamic> testResults;
  final List<String> qualityIssues;
  final List<String> correctiveActions;
  final Map<String, dynamic> metadata;

  MedicationQualityControl({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.manufacturer,
    required this.batchNumber,
    required this.manufacturingDate,
    required this.expirationDate,
    required this.qualityStatus,
    required this.qualityTests,
    required this.testResults,
    required this.qualityIssues,
    required this.correctiveActions,
    required this.metadata,
  });

  factory MedicationQualityControl.fromJson(Map<String, dynamic> json) =>
      _$MedicationQualityControlFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationQualityControlToJson(this);
}

// İlaç Tedarik Zinciri
@JsonSerializable()
class MedicationSupplyChain {
  final String id;
  final String medicationId;
  final String medicationName;
  final String manufacturer;
  final String distributor;
  final String wholesaler;
  final String pharmacy;
  final DateTime manufacturingDate;
  final DateTime distributionDate;
  final DateTime deliveryDate;
  final String trackingNumber;
  final String status;
  final List<String> checkpoints;
  final Map<String, dynamic> metadata;

  MedicationSupplyChain({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.manufacturer,
    required this.distributor,
    required this.wholesaler,
    required this.pharmacy,
    required this.manufacturingDate,
    required this.distributionDate,
    required this.deliveryDate,
    required this.trackingNumber,
    required this.status,
    required this.checkpoints,
    required this.metadata,
  });

  factory MedicationSupplyChain.fromJson(Map<String, dynamic> json) =>
      _$MedicationSupplyChainFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationSupplyChainToJson(this);
}
