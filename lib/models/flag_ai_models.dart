import 'package:json_annotation/json_annotation.dart';

part 'flag_ai_models.g.dart';

// Risk Seviyeleri - Dünya Standartları
enum RiskLevel {
  @JsonValue('none')
  none,        // Risk yok
  @JsonValue('low')
  low,         // Düşük risk
  @JsonValue('moderate')
  moderate,    // Orta risk
  @JsonValue('high')
  high,        // Yüksek risk
  @JsonValue('critical')
  critical,    // Kritik risk
  @JsonValue('emergency')
  emergency    // Acil durum
}

// Flag Türleri - Uluslararası Standartlar
enum FlagType {
  @JsonValue('suicide_risk')
  suicideRisk,           // İntihar riski
  @JsonValue('self_harm')
  selfHarm,              // Kendine zarar verme
  @JsonValue('violence_risk')
  violenceRisk,          // Şiddet riski
  @JsonValue('substance_abuse')
  substanceAbuse,        // Madde bağımlılığı
  @JsonValue('psychosis')
  psychosis,             // Psikoz
  @JsonValue('manic_episode')
  manicEpisode,          // Manik atak
  @JsonValue('severe_depression')
  severeDepression,      // Ağır depresyon
  @JsonValue('anxiety_crisis')
  anxietyCrisis,         // Anksiyete krizi
  @JsonValue('eating_disorder')
  eatingDisorder,        // Yeme bozukluğu
  @JsonValue('personality_disorder')
  personalityDisorder,   // Kişilik bozukluğu
  @JsonValue('trauma_response')
  traumaResponse,        // Travma tepkisi
  @JsonValue('grief_reaction')
  griefReaction,         // Yas tepkisi
  @JsonValue('medication_issue')
  medicationIssue,       // İlaç sorunu
  @JsonValue('medical_emergency')
  medicalEmergency,      // Tıbbi acil
  @JsonValue('social_crisis')
  socialCrisis,          // Sosyal kriz
  @JsonValue('financial_crisis')
  financialCrisis,       // Finansal kriz
  @JsonValue('legal_issue')
  legalIssue,            // Yasal sorun
  @JsonValue('family_crisis')
  familyCrisis,          // Aile krizi
  @JsonValue('work_crisis')
  workCrisis,            // İş krizi
  @JsonValue('academic_crisis')
  academicCrisis,        // Akademik kriz
  @JsonValue('relationship_crisis')
  relationshipCrisis,    // İlişki krizi
  @JsonValue('other')
  other                  // Diğer
}

// Acil Durum Seviyeleri
enum EmergencyLevel {
  @JsonValue('none')
  none,           // Acil değil
  @JsonValue('urgent')
  urgent,         // Acil
  @JsonValue('immediate')
  immediate,      // Anında
  @JsonValue('critical')
  critical,       // Kritik
  @JsonValue('life_threatening')
  lifeThreatening // Yaşam tehdidi
}

// Müdahale Türleri
enum InterventionType {
  @JsonValue('immediate_support')
  immediateSupport,       // Anında destek
  @JsonValue('crisis_intervention')
  crisisIntervention,     // Kriz müdahalesi
  @JsonValue('emergency_services')
  emergencyServices,      // Acil servisler
  @JsonValue('hospitalization')
  hospitalization,        // Hastaneye yatış
  @JsonValue('medication_adjustment')
  medicationAdjustment,  // İlaç ayarlaması
  @JsonValue('therapy_session')
  therapySession,        // Terapi seansı
  @JsonValue('family_intervention')
  familyIntervention,    // Aile müdahalesi
  @JsonValue('social_support')
  socialSupport,         // Sosyal destek
  @JsonValue('legal_assistance')
  legalAssistance,       // Yasal yardım
  @JsonValue('financial_assistance')
  financialAssistance,   // Finansal yardım
  @JsonValue('other')
  other                  // Diğer
}

// AI Güven Skoru
@JsonSerializable()
class AIConfidenceScore {
  final double score;           // 0.0 - 1.0 arası güven skoru
  final String confidence;      // Düşük, Orta, Yüksek, Çok Yüksek
  final List<String> factors;   // Güven skorunu etkileyen faktörler
  final String explanation;     // Güven skoru açıklaması

  AIConfidenceScore({
    required this.score,
    required this.confidence,
    required this.factors,
    required this.explanation,
  });

  factory AIConfidenceScore.fromJson(Map<String, dynamic> json) =>
      _$AIConfidenceScoreFromJson(json);

  Map<String, dynamic> toJson() => _$AIConfidenceScoreToJson(this);
}

// Risk Faktörleri
@JsonSerializable()
class RiskFactor {
  final String id;
  final String name;
  final String description;
  final RiskLevel level;
  final double weight;          // 0.0 - 1.0 arası ağırlık
  final List<String> indicators; // Risk göstergeleri
  final List<String> triggers;   // Tetikleyiciler
  final Map<String, dynamic> metadata;

  RiskFactor({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.weight,
    required this.indicators,
    required this.triggers,
    required this.metadata,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);

  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

// AI Flag Tespiti
@JsonSerializable()
class AIFlagDetection {
  final String id;
  final FlagType type;
  final RiskLevel riskLevel;
  final EmergencyLevel emergencyLevel;
  final AIConfidenceScore confidence;
  final List<RiskFactor> riskFactors;
  final String summary;
  final String detailedAnalysis;
  final List<String> warningSigns;
  final List<String> protectiveFactors;
  final List<InterventionType> recommendedInterventions;
  final Map<String, dynamic> aiMetadata;
  final DateTime detectedAt;
  final DateTime expiresAt;
  final bool isActive;
  final String status; // active, resolved, escalated, false_positive

  AIFlagDetection({
    required this.id,
    required this.type,
    required this.riskLevel,
    required this.emergencyLevel,
    required this.confidence,
    required this.riskFactors,
    required this.summary,
    required this.detailedAnalysis,
    required this.warningSigns,
    required this.protectiveFactors,
    required this.recommendedInterventions,
    required this.aiMetadata,
    required this.detectedAt,
    required this.expiresAt,
    required this.isActive,
    required this.status,
  });

  factory AIFlagDetection.fromJson(Map<String, dynamic> json) =>
      _$AIFlagDetectionFromJson(json);

  Map<String, dynamic> toJson() => _$AIFlagDetectionToJson(this);
}

// Kriz Müdahale Planı
@JsonSerializable()
class CrisisInterventionPlan {
  final String id;
  final String flagId;
  final EmergencyLevel level;
  final List<InterventionType> interventions;
  final Map<String, dynamic> actionSteps;
  final List<String> requiredResources;
  final List<String> contactPersons;
  final List<String> emergencyContacts;
  final String protocol;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final DateTime? resolvedAt;
  final String status; // planned, active, completed, cancelled
  final Map<String, dynamic> outcomes;
  final List<String> notes;

  CrisisInterventionPlan({
    required this.id,
    required this.flagId,
    required this.level,
    required this.interventions,
    required this.actionSteps,
    required this.requiredResources,
    required this.contactPersons,
    required this.emergencyContacts,
    required this.protocol,
    required this.createdAt,
    this.activatedAt,
    this.resolvedAt,
    required this.status,
    required this.outcomes,
    required this.notes,
  });

  factory CrisisInterventionPlan.fromJson(Map<String, dynamic> json) =>
      _$CrisisInterventionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisInterventionPlanToJson(this);
}

// Acil Durum Protokolü
@JsonSerializable()
class EmergencyProtocol {
  final String id;
  final String name;
  final String description;
  final EmergencyLevel level;
  final List<String> steps;
  final List<String> requiredActions;
  final List<String> contactPersons;
  final List<String> emergencyNumbers;
  final Map<String, dynamic> escalationRules;
  final String countryCode;
  final String region;
  final DateTime lastUpdated;
  final bool isActive;

  EmergencyProtocol({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.steps,
    required this.requiredActions,
    required this.contactPersons,
    required this.emergencyNumbers,
    required this.escalationRules,
    required this.countryCode,
    required this.region,
    required this.lastUpdated,
    required this.isActive,
  });

  factory EmergencyProtocol.fromJson(Map<String, dynamic> json) =>
      _$EmergencyProtocolFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyProtocolToJson(this);
}

// AI Model Performans Metrikleri
@JsonSerializable()
class AIModelPerformance {
  final String modelId;
  final String version;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double falsePositiveRate;
  final double falseNegativeRate;
  final int totalPredictions;
  final int correctPredictions;
  final int falsePositives;
  final int falseNegatives;
  final Map<String, double> classAccuracy;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  AIModelPerformance({
    required this.modelId,
    required this.version,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.falsePositiveRate,
    required this.falseNegativeRate,
    required this.totalPredictions,
    required this.correctPredictions,
    required this.falsePositives,
    required this.falseNegatives,
    required this.classAccuracy,
    required this.lastUpdated,
    required this.metadata,
  });

  factory AIModelPerformance.fromJson(Map<String, dynamic> json) =>
      _$AIModelPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$AIModelPerformanceToJson(this);
}

// Flag Geçmişi
@JsonSerializable()
class FlagHistory {
  final String id;
  final String clientId;
  final List<AIFlagDetection> detections;
  final List<CrisisInterventionPlan> interventions;
  final Map<String, dynamic> statistics;
  final List<String> patterns;
  final List<String> trends;
  final DateTime firstDetection;
  final DateTime lastDetection;
  final int totalFlags;
  final int resolvedFlags;
  final int escalatedFlags;
  final Map<String, dynamic> metadata;

  FlagHistory({
    required this.id,
    required this.clientId,
    required this.detections,
    required this.interventions,
    required this.statistics,
    required this.patterns,
    required this.trends,
    required this.firstDetection,
    required this.lastDetection,
    required this.totalFlags,
    required this.resolvedFlags,
    required this.escalatedFlags,
    required this.metadata,
  });

  factory FlagHistory.fromJson(Map<String, dynamic> json) =>
      _$FlagHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$FlagHistoryToJson(this);
}

// AI Öngörü Modeli
@JsonSerializable()
class AIPredictionModel {
  final String id;
  final String name;
  final String description;
  final String algorithm;
  final Map<String, dynamic> parameters;
  final List<String> features;
  final double predictionAccuracy;
  final DateTime lastTrained;
  final DateTime nextTraining;
  final bool isActive;
  final Map<String, dynamic> performanceMetrics;
  final List<String> supportedFlagTypes;

  AIPredictionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.algorithm,
    required this.parameters,
    required this.features,
    required this.predictionAccuracy,
    required this.lastTrained,
    required this.nextTraining,
    required this.isActive,
    required this.performanceMetrics,
    required this.supportedFlagTypes,
  });

  factory AIPredictionModel.fromJson(Map<String, dynamic> json) =>
      _$AIPredictionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIPredictionModelToJson(this);
}

// Gerçek Zamanlı İzleme
@JsonSerializable()
class RealTimeMonitoring {
  final String id;
  final String clientId;
  final List<String> activeFlags;
  final Map<String, dynamic> vitalSigns;
  final List<String> behavioralIndicators;
  final Map<String, dynamic> environmentalFactors;
  final List<String> riskAlerts;
  final DateTime lastUpdate;
  final bool isOnline;
  final Map<String, dynamic> metadata;

  RealTimeMonitoring({
    required this.id,
    required this.clientId,
    required this.activeFlags,
    required this.vitalSigns,
    required this.behavioralIndicators,
    required this.environmentalFactors,
    required this.riskAlerts,
    required this.lastUpdate,
    required this.isOnline,
    required this.metadata,
  });

  factory RealTimeMonitoring.fromJson(Map<String, dynamic> json) =>
      _$RealTimeMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$RealTimeMonitoringToJson(this);
}

// Uluslararası Standartlar
@JsonSerializable()
class InternationalStandards {
  final String id;
  final String name;
  final String description;
  final String organization; // WHO, APA, WPA, vb.
  final String country;
  final String version;
  final DateTime publishedDate;
  final List<String> applicableRegions;
  final Map<String, dynamic> guidelines;
  final List<String> references;
  final bool isActive;

  InternationalStandards({
    required this.id,
    required this.name,
    required this.description,
    required this.organization,
    required this.country,
    required this.version,
    required this.publishedDate,
    required this.applicableRegions,
    required this.guidelines,
    required this.references,
    required this.isActive,
  });

  factory InternationalStandards.fromJson(Map<String, dynamic> json) =>
      _$InternationalStandardsFromJson(json);

  Map<String, dynamic> toJson() => _$InternationalStandardsToJson(this);
}

// Çok Dilli Destek
@JsonSerializable()
class MultilingualSupport {
  final String id;
  final String languageCode;
  final String languageName;
  final String nativeName;
  final Map<String, String> translations;
  final Map<String, String> culturalAdaptations;
  final List<String> regionalVariations;
  final bool isRTL; // Right-to-left text
  final DateTime lastUpdated;
  final bool isActive;

  MultilingualSupport({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.translations,
    required this.culturalAdaptations,
    required this.regionalVariations,
    required this.isRTL,
    required this.lastUpdated,
    required this.isActive,
  });

  factory MultilingualSupport.fromJson(Map<String, dynamic> json) =>
      _$MultilingualSupportFromJson(json);

  Map<String, dynamic> toJson() => _$MultilingualSupportToJson(this);
}

// Kültürel Duyarlılık
@JsonSerializable()
class CulturalSensitivity {
  final String id;
  final String culture;
  final String region;
  final Map<String, dynamic> culturalNorms;
  final List<String> taboos;
  final List<String> preferredPractices;
  final Map<String, String> communicationStyles;
  final List<String> familyStructures;
  final Map<String, dynamic> religiousConsiderations;
  final List<String> traditionalHealing;
  final Map<String, dynamic> stigmaFactors;
  final DateTime lastUpdated;

  CulturalSensitivity({
    required this.id,
    required this.culture,
    required this.region,
    required this.culturalNorms,
    required this.taboos,
    required this.preferredPractices,
    required this.communicationStyles,
    required this.familyStructures,
    required this.religiousConsiderations,
    required this.traditionalHealing,
    required this.stigmaFactors,
    required this.lastUpdated,
  });

  factory CulturalSensitivity.fromJson(Map<String, dynamic> json) =>
      _$CulturalSensitivityFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalSensitivityToJson(this);
}

// Gizlilik ve Güvenlik
@JsonSerializable()
class PrivacySecurity {
  final String id;
  final String standard; // HIPAA, GDPR, KVKK, vb.
  final String country;
  final Map<String, dynamic> requirements;
  final List<String> dataProtectionMeasures;
  final List<String> encryptionStandards;
  final List<String> accessControls;
  final Map<String, dynamic> auditTrail;
  final List<String> complianceChecks;
  final DateTime lastAudit;
  final bool isCompliant;

  PrivacySecurity({
    required this.id,
    required this.standard,
    required this.country,
    required this.requirements,
    required this.dataProtectionMeasures,
    required this.encryptionStandards,
    required this.accessControls,
    required this.auditTrail,
    required this.complianceChecks,
    required this.lastAudit,
    required this.isCompliant,
  });

  factory PrivacySecurity.fromJson(Map<String, dynamic> json) =>
      _$PrivacySecurityFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySecurityToJson(this);
}

// Performans İzleme
@JsonSerializable()
class PerformanceMonitoring {
  final String id;
  final DateTime timestamp;
  final Map<String, dynamic> systemMetrics;
  final Map<String, dynamic> aiMetrics;
  final Map<String, dynamic> userMetrics;
  final List<String> alerts;
  final Map<String, dynamic> recommendations;
  final bool isHealthy;

  PerformanceMonitoring({
    required this.id,
    required this.timestamp,
    required this.systemMetrics,
    required this.aiMetrics,
    required this.userMetrics,
    required this.alerts,
    required this.recommendations,
    required this.isHealthy,
  });

  factory PerformanceMonitoring.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceMonitoringToJson(this);
}
