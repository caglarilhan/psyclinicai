// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_country_medication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MultiCountryMedication _$MultiCountryMedicationFromJson(
  Map<String, dynamic> json,
) => MultiCountryMedication(
  id: json['id'] as String,
  medicationName: json['medicationName'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  activeIngredient: json['activeIngredient'] as String,
  classification: json['classification'] as String,
  mechanism: json['mechanism'] as String,
  dosageForm: json['dosageForm'] as String,
  strength: json['strength'] as String,
  route: json['route'] as String,
  frequency: json['frequency'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
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
  countrySpecificInfo: json['countrySpecificInfo'] as Map<String, dynamic>,
  availableCountries: (json['availableCountries'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MultiCountryMedicationToJson(
  MultiCountryMedication instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationName': instance.medicationName,
  'genericName': instance.genericName,
  'brandName': instance.brandName,
  'activeIngredient': instance.activeIngredient,
  'classification': instance.classification,
  'mechanism': instance.mechanism,
  'dosageForm': instance.dosageForm,
  'strength': instance.strength,
  'route': instance.route,
  'frequency': instance.frequency,
  'durationDays': instance.durationDays,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'warnings': instance.warnings,
  'precautions': instance.precautions,
  'countrySpecificInfo': instance.countrySpecificInfo,
  'availableCountries': instance.availableCountries,
  'metadata': instance.metadata,
};

WHODrugDictionary _$WHODrugDictionaryFromJson(Map<String, dynamic> json) =>
    WHODrugDictionary(
      id: json['id'] as String,
      drugCode: json['drugCode'] as String,
      drugName: json['drugName'] as String,
      genericName: json['genericName'] as String,
      chemicalName: json['chemicalName'] as String,
      molecularFormula: json['molecularFormula'] as String,
      molecularWeight: json['molecularWeight'] as String,
      classification: json['classification'] as String,
      mechanism: json['mechanism'] as String,
      therapeuticIndications: (json['therapeuticIndications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      adverseEffects: (json['adverseEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      drugInteractions: (json['drugInteractions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      pharmacokinetics: json['pharmacokinetics'] as Map<String, dynamic>,
      references: (json['references'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WHODrugDictionaryToJson(WHODrugDictionary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugCode': instance.drugCode,
      'drugName': instance.drugName,
      'genericName': instance.genericName,
      'chemicalName': instance.chemicalName,
      'molecularFormula': instance.molecularFormula,
      'molecularWeight': instance.molecularWeight,
      'classification': instance.classification,
      'mechanism': instance.mechanism,
      'therapeuticIndications': instance.therapeuticIndications,
      'contraindications': instance.contraindications,
      'adverseEffects': instance.adverseEffects,
      'drugInteractions': instance.drugInteractions,
      'pharmacokinetics': instance.pharmacokinetics,
      'references': instance.references,
      'metadata': instance.metadata,
    };

FDAOrangeBook _$FDAOrangeBookFromJson(Map<String, dynamic> json) =>
    FDAOrangeBook(
      id: json['id'] as String,
      drugName: json['drugName'] as String,
      genericName: json['genericName'] as String,
      brandName: json['brandName'] as String,
      applicationNumber: json['applicationNumber'] as String,
      productNumber: json['productNumber'] as String,
      strength: json['strength'] as String,
      dosageForm: json['dosageForm'] as String,
      route: json['route'] as String,
      activeIngredient: json['activeIngredient'] as String,
      approvalDate: json['approvalDate'] as String,
      patentExpiration: json['patentExpiration'] as String,
      exclusivityExpiration: json['exclusivityExpiration'] as String,
      therapeuticEquivalence: json['therapeuticEquivalence'] as String,
      indications: (json['indications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      warnings: (json['warnings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$FDAOrangeBookToJson(FDAOrangeBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugName': instance.drugName,
      'genericName': instance.genericName,
      'brandName': instance.brandName,
      'applicationNumber': instance.applicationNumber,
      'productNumber': instance.productNumber,
      'strength': instance.strength,
      'dosageForm': instance.dosageForm,
      'route': instance.route,
      'activeIngredient': instance.activeIngredient,
      'approvalDate': instance.approvalDate,
      'patentExpiration': instance.patentExpiration,
      'exclusivityExpiration': instance.exclusivityExpiration,
      'therapeuticEquivalence': instance.therapeuticEquivalence,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'warnings': instance.warnings,
      'metadata': instance.metadata,
    };

EMADatabase _$EMADatabaseFromJson(Map<String, dynamic> json) => EMADatabase(
  id: json['id'] as String,
  drugName: json['drugName'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  authorizationNumber: json['authorizationNumber'] as String,
  marketingAuthorizationHolder: json['marketingAuthorizationHolder'] as String,
  authorizationDate: json['authorizationDate'] as String,
  expirationDate: json['expirationDate'] as String,
  status: json['status'] as String,
  therapeuticIndications: (json['therapeuticIndications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  specialWarnings: (json['specialWarnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  adverseReactions: (json['adverseReactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  posology: json['posology'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$EMADatabaseToJson(EMADatabase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drugName': instance.drugName,
      'genericName': instance.genericName,
      'brandName': instance.brandName,
      'authorizationNumber': instance.authorizationNumber,
      'marketingAuthorizationHolder': instance.marketingAuthorizationHolder,
      'authorizationDate': instance.authorizationDate,
      'expirationDate': instance.expirationDate,
      'status': instance.status,
      'therapeuticIndications': instance.therapeuticIndications,
      'contraindications': instance.contraindications,
      'specialWarnings': instance.specialWarnings,
      'adverseReactions': instance.adverseReactions,
      'posology': instance.posology,
      'metadata': instance.metadata,
    };

TurkeyDrugAuthority _$TurkeyDrugAuthorityFromJson(Map<String, dynamic> json) =>
    TurkeyDrugAuthority(
      id: json['id'] as String,
      drugName: json['drugName'] as String,
      genericName: json['genericName'] as String,
      brandName: json['brandName'] as String,
      registrationNumber: json['registrationNumber'] as String,
      marketingAuthorizationHolder:
          json['marketingAuthorizationHolder'] as String,
      registrationDate: json['registrationDate'] as String,
      expirationDate: json['expirationDate'] as String,
      status: json['status'] as String,
      therapeuticIndications: (json['therapeuticIndications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specialWarnings: (json['specialWarnings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      adverseReactions: (json['adverseReactions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      posology: json['posology'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TurkeyDrugAuthorityToJson(
  TurkeyDrugAuthority instance,
) => <String, dynamic>{
  'id': instance.id,
  'drugName': instance.drugName,
  'genericName': instance.genericName,
  'brandName': instance.brandName,
  'registrationNumber': instance.registrationNumber,
  'marketingAuthorizationHolder': instance.marketingAuthorizationHolder,
  'registrationDate': instance.registrationDate,
  'expirationDate': instance.expirationDate,
  'status': instance.status,
  'therapeuticIndications': instance.therapeuticIndications,
  'contraindications': instance.contraindications,
  'specialWarnings': instance.specialWarnings,
  'adverseReactions': instance.adverseReactions,
  'posology': instance.posology,
  'metadata': instance.metadata,
};

DrugInteractionChecker _$DrugInteractionCheckerFromJson(
  Map<String, dynamic> json,
) => DrugInteractionChecker(
  id: json['id'] as String,
  drug1Id: json['drug1Id'] as String,
  drug1Name: json['drug1Name'] as String,
  drug2Id: json['drug2Id'] as String,
  drug2Name: json['drug2Name'] as String,
  interactionType: json['interactionType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  mechanism: json['mechanism'] as String,
  clinicalEffects: (json['clinicalEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  evidenceLevel: (json['evidenceLevel'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$DrugInteractionCheckerToJson(
  DrugInteractionChecker instance,
) => <String, dynamic>{
  'id': instance.id,
  'drug1Id': instance.drug1Id,
  'drug1Name': instance.drug1Name,
  'drug2Id': instance.drug2Id,
  'drug2Name': instance.drug2Name,
  'interactionType': instance.interactionType,
  'severity': instance.severity,
  'description': instance.description,
  'mechanism': instance.mechanism,
  'clinicalEffects': instance.clinicalEffects,
  'recommendations': instance.recommendations,
  'alternatives': instance.alternatives,
  'evidenceLevel': instance.evidenceLevel,
  'metadata': instance.metadata,
};

CulturalMedicationPreferences _$CulturalMedicationPreferencesFromJson(
  Map<String, dynamic> json,
) => CulturalMedicationPreferences(
  id: json['id'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  culture: json['culture'] as String,
  preferredMedicationTypes: (json['preferredMedicationTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  avoidedMedicationTypes: (json['avoidedMedicationTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  traditionalMedicine: Map<String, String>.from(
    json['traditionalMedicine'] as Map,
  ),
  culturalBeliefs: (json['culturalBeliefs'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  taboos: (json['taboos'] as List<dynamic>).map((e) => e as String).toList(),
  communicationPreferences:
      json['communicationPreferences'] as Map<String, dynamic>,
  familyInvolvement: (json['familyInvolvement'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CulturalMedicationPreferencesToJson(
  CulturalMedicationPreferences instance,
) => <String, dynamic>{
  'id': instance.id,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'culture': instance.culture,
  'preferredMedicationTypes': instance.preferredMedicationTypes,
  'avoidedMedicationTypes': instance.avoidedMedicationTypes,
  'traditionalMedicine': instance.traditionalMedicine,
  'culturalBeliefs': instance.culturalBeliefs,
  'taboos': instance.taboos,
  'communicationPreferences': instance.communicationPreferences,
  'familyInvolvement': instance.familyInvolvement,
  'metadata': instance.metadata,
};

LocalPharmacyIntegration _$LocalPharmacyIntegrationFromJson(
  Map<String, dynamic> json,
) => LocalPharmacyIntegration(
  id: json['id'] as String,
  pharmacyId: json['pharmacyId'] as String,
  pharmacyName: json['pharmacyName'] as String,
  countryCode: json['countryCode'] as String,
  region: json['region'] as String,
  city: json['city'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  availableMedications: (json['availableMedications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  services: (json['services'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  operatingHours: json['operatingHours'] as Map<String, dynamic>,
  insuranceAccepted: json['insuranceAccepted'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$LocalPharmacyIntegrationToJson(
  LocalPharmacyIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'pharmacyId': instance.pharmacyId,
  'pharmacyName': instance.pharmacyName,
  'countryCode': instance.countryCode,
  'region': instance.region,
  'city': instance.city,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'availableMedications': instance.availableMedications,
  'services': instance.services,
  'operatingHours': instance.operatingHours,
  'insuranceAccepted': instance.insuranceAccepted,
  'metadata': instance.metadata,
};

MedicationSafetyMonitoring _$MedicationSafetyMonitoringFromJson(
  Map<String, dynamic> json,
) => MedicationSafetyMonitoring(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  countryCode: json['countryCode'] as String,
  monitoringStartDate: DateTime.parse(json['monitoringStartDate'] as String),
  monitoringType: json['monitoringType'] as String,
  safetySignals: (json['safetySignals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  adverseEvents: (json['adverseEvents'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  safetyMetrics: json['safetyMetrics'] as Map<String, dynamic>,
  riskLevel: json['riskLevel'] as String,
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationSafetyMonitoringToJson(
  MedicationSafetyMonitoring instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'countryCode': instance.countryCode,
  'monitoringStartDate': instance.monitoringStartDate.toIso8601String(),
  'monitoringType': instance.monitoringType,
  'safetySignals': instance.safetySignals,
  'adverseEvents': instance.adverseEvents,
  'riskFactors': instance.riskFactors,
  'safetyMetrics': instance.safetyMetrics,
  'riskLevel': instance.riskLevel,
  'recommendations': instance.recommendations,
  'metadata': instance.metadata,
};

MedicationCostAnalysis _$MedicationCostAnalysisFromJson(
  Map<String, dynamic> json,
) => MedicationCostAnalysis(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  countryCode: json['countryCode'] as String,
  unitCost: (json['unitCost'] as num).toDouble(),
  currency: json['currency'] as String,
  costType: json['costType'] as String,
  insuranceCoverage: (json['insuranceCoverage'] as num).toDouble(),
  patientCost: (json['patientCost'] as num).toDouble(),
  costFactors: (json['costFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pricingHistory: json['pricingHistory'] as Map<String, dynamic>,
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationCostAnalysisToJson(
  MedicationCostAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'countryCode': instance.countryCode,
  'unitCost': instance.unitCost,
  'currency': instance.currency,
  'costType': instance.costType,
  'insuranceCoverage': instance.insuranceCoverage,
  'patientCost': instance.patientCost,
  'costFactors': instance.costFactors,
  'pricingHistory': instance.pricingHistory,
  'alternatives': instance.alternatives,
  'metadata': instance.metadata,
};

MedicationAccessibility _$MedicationAccessibilityFromJson(
  Map<String, dynamic> json,
) => MedicationAccessibility(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  countryCode: json['countryCode'] as String,
  region: json['region'] as String,
  availabilityStatus: json['availabilityStatus'] as String,
  distributionChannels: (json['distributionChannels'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  barriers: (json['barriers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  accessibilityMetrics: json['accessibilityMetrics'] as Map<String, dynamic>,
  improvementStrategies: (json['improvementStrategies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationAccessibilityToJson(
  MedicationAccessibility instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'countryCode': instance.countryCode,
  'region': instance.region,
  'availabilityStatus': instance.availabilityStatus,
  'distributionChannels': instance.distributionChannels,
  'barriers': instance.barriers,
  'accessibilityMetrics': instance.accessibilityMetrics,
  'improvementStrategies': instance.improvementStrategies,
  'metadata': instance.metadata,
};

MedicationQualityControl _$MedicationQualityControlFromJson(
  Map<String, dynamic> json,
) => MedicationQualityControl(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  manufacturer: json['manufacturer'] as String,
  batchNumber: json['batchNumber'] as String,
  manufacturingDate: DateTime.parse(json['manufacturingDate'] as String),
  expirationDate: DateTime.parse(json['expirationDate'] as String),
  qualityStatus: json['qualityStatus'] as String,
  qualityTests: (json['qualityTests'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  testResults: json['testResults'] as Map<String, dynamic>,
  qualityIssues: (json['qualityIssues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  correctiveActions: (json['correctiveActions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationQualityControlToJson(
  MedicationQualityControl instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'manufacturer': instance.manufacturer,
  'batchNumber': instance.batchNumber,
  'manufacturingDate': instance.manufacturingDate.toIso8601String(),
  'expirationDate': instance.expirationDate.toIso8601String(),
  'qualityStatus': instance.qualityStatus,
  'qualityTests': instance.qualityTests,
  'testResults': instance.testResults,
  'qualityIssues': instance.qualityIssues,
  'correctiveActions': instance.correctiveActions,
  'metadata': instance.metadata,
};

MedicationSupplyChain _$MedicationSupplyChainFromJson(
  Map<String, dynamic> json,
) => MedicationSupplyChain(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  manufacturer: json['manufacturer'] as String,
  distributor: json['distributor'] as String,
  wholesaler: json['wholesaler'] as String,
  pharmacy: json['pharmacy'] as String,
  manufacturingDate: DateTime.parse(json['manufacturingDate'] as String),
  distributionDate: DateTime.parse(json['distributionDate'] as String),
  deliveryDate: DateTime.parse(json['deliveryDate'] as String),
  trackingNumber: json['trackingNumber'] as String,
  status: json['status'] as String,
  checkpoints: (json['checkpoints'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$MedicationSupplyChainToJson(
  MedicationSupplyChain instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'manufacturer': instance.manufacturer,
  'distributor': instance.distributor,
  'wholesaler': instance.wholesaler,
  'pharmacy': instance.pharmacy,
  'manufacturingDate': instance.manufacturingDate.toIso8601String(),
  'distributionDate': instance.distributionDate.toIso8601String(),
  'deliveryDate': instance.deliveryDate.toIso8601String(),
  'trackingNumber': instance.trackingNumber,
  'status': instance.status,
  'checkpoints': instance.checkpoints,
  'metadata': instance.metadata,
};
