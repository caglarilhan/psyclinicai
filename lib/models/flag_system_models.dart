import 'package:json_annotation/json_annotation.dart';

part 'flag_system_models.g.dart';

// ===== FLAG SİSTEMİ MODELLERİ =====
// Kriz, suicid ve ajitasyon durumlarını tespit eden sistem

/// Kriz Durumu - Acil müdahale gerektiren psikiyatrik durumlar
/// Hasta güvenliği için anında dikkat gerektiren durumları tanımlar
@JsonSerializable()
class CrisisFlag {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final CrisisType type; // Kriz türü
  final CrisisSeverity severity; // Kriz şiddeti
  final DateTime detectedAt; // Tespit edilme zamanı
  final DateTime? resolvedAt; // Çözüldüğü zaman
  final String description; // Kriz açıklaması
  final List<String> symptoms; // Belirtiler
  final List<String> riskFactors; // Risk faktörleri
  final List<String> immediateActions; // Acil eylemler
  final String? resolutionNotes; // Çözüm notları
  final FlagStatus status; // Flag durumu
  final Map<String, dynamic> metadata; // Ek meta veriler

  const CrisisFlag({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.type,
    required this.severity,
    required this.detectedAt,
    this.resolvedAt,
    required this.description,
    required this.symptoms,
    required this.riskFactors,
    required this.immediateActions,
    this.resolutionNotes,
    required this.status,
    required this.metadata,
  });

  factory CrisisFlag.fromJson(Map<String, dynamic> json) =>
      _$CrisisFlagFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisFlagToJson(this);
}

/// Kriz Türü - Farklı kriz durumlarının kategorileri
/// Her kriz türü için farklı müdahale protokolleri gerekir
enum CrisisType {
  @JsonValue('suicidal_ideation') suicidalIdeation, // İntihar düşüncesi
  @JsonValue('suicidal_attempt') suicidalAttempt, // İntihar girişimi
  @JsonValue('homicidal_ideation') homicidalIdeation, // Cinayet düşüncesi
  @JsonValue('severe_agitation') severeAgitation, // Şiddetli ajitasyon
  @JsonValue('psychotic_break') psychoticBreak, // Psikotik kırılma
  @JsonValue('severe_depression') severeDepression, // Şiddetli depresyon
  @JsonValue('manic_episode') manicEpisode, // Manik atak
  @JsonValue('substance_abuse') substanceAbuse, // Madde kullanımı
  @JsonValue('self_harm') selfHarm, // Kendine zarar verme
  @JsonValue('violent_behavior') violentBehavior, // Şiddetli davranış
}

/// Kriz Şiddeti - Kriz durumunun aciliyet seviyesi
/// Müdahale önceliğini belirler
enum CrisisSeverity {
  @JsonValue('low') low, // Düşük - Rutin takip
  @JsonValue('moderate') moderate, // Orta - Yakın takip
  @JsonValue('high') high, // Yüksek - Acil müdahale
  @JsonValue('critical') critical, // Kritik - Anında müdahale
  @JsonValue('emergency') emergency, // Acil - 911 çağrısı
}

/// İntihar Risk Değerlendirmesi - Detaylı intihar risk analizi
/// Columbia Suicide Severity Rating Scale (C-SSRS) benzeri değerlendirme
@JsonSerializable()
class SuicideRiskAssessment {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final DateTime assessmentDate; // Değerlendirme tarihi
  final int suicidalIdeationScore; // İntihar düşüncesi skoru (0-5)
  final int suicidalBehaviorScore; // İntihar davranışı skoru (0-5)
  final int lethalityScore; // Ölümcüllük skoru (0-5)
  final List<String> riskFactors; // Risk faktörleri
  final List<String> protectiveFactors; // Koruyucu faktörler
  final String riskLevel; // Risk seviyesi
  final String clinicalImpression; // Klinik izlenim
  final List<String> safetyPlan; // Güvenlik planı
  final List<String> followUpActions; // Takip eylemleri
  final Map<String, dynamic> metadata; // Ek meta veriler

  const SuicideRiskAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.assessmentDate,
    required this.suicidalIdeationScore,
    required this.suicidalBehaviorScore,
    required this.lethalityScore,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.riskLevel,
    required this.clinicalImpression,
    required this.safetyPlan,
    required this.followUpActions,
    required this.metadata,
  });

  factory SuicideRiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$SuicideRiskAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$SuicideRiskAssessmentToJson(this);
}

/// Ajitasyon Değerlendirmesi - Hasta ajitasyon seviyesinin ölçülmesi
/// Agitated Behavior Scale (ABS) benzeri değerlendirme
@JsonSerializable()
class AgitationAssessment {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final DateTime assessmentDate; // Değerlendirme tarihi
  final int motorAgitationScore; // Motor ajitasyon skoru (0-5)
  final int verbalAgitationScore; // Sözel ajitasyon skoru (0-5)
  final int aggressiveBehaviorScore; // Agresif davranış skoru (0-5)
  final int impulsivityScore; // Dürtüsellik skoru (0-5)
  final String agitationLevel; // Ajitasyon seviyesi
  final List<String> triggers; // Tetikleyiciler
  final List<String> calmingTechniques; // Sakinleştirme teknikleri
  final String interventionPlan; // Müdahale planı
  final Map<String, dynamic> metadata; // Ek meta veriler

  const AgitationAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.assessmentDate,
    required this.motorAgitationScore,
    required this.verbalAgitationScore,
    required this.aggressiveBehaviorScore,
    required this.impulsivityScore,
    required this.agitationLevel,
    required this.triggers,
    required this.calmingTechniques,
    required this.interventionPlan,
    required this.metadata,
  });

  factory AgitationAssessment.fromJson(Map<String, dynamic> json) =>
      _$AgitationAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$AgitationAssessmentToJson(this);
}

/// Güvenlik Planı - Kriz durumlarında uygulanacak protokoller
/// Hasta ve klinisyen için adım adım güvenlik önlemleri
@JsonSerializable()
class SafetyPlan {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final DateTime createdAt; // Oluşturulma tarihi
  final DateTime? lastUpdated; // Son güncelleme tarihi
  final List<String> warningSigns; // Uyarı işaretleri
  final List<String> internalCopingStrategies; // İçsel başa çıkma stratejileri
  final List<String> socialSupport; // Sosyal destek kişileri
  final List<String> professionalHelp; // Profesyonel yardım kaynakları
  final List<String> environmentalSafety; // Çevresel güvenlik önlemleri
  final List<String> crisisIntervention; // Kriz müdahale adımları
  final String emergencyContact; // Acil durum iletişim bilgisi
  final bool isActive; // Aktif durum
  final Map<String, dynamic> metadata; // Ek meta veriler

  const SafetyPlan({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.createdAt,
    this.lastUpdated,
    required this.warningSigns,
    required this.internalCopingStrategies,
    required this.socialSupport,
    required this.professionalHelp,
    required this.environmentalSafety,
    required this.crisisIntervention,
    required this.emergencyContact,
    required this.isActive,
    required this.metadata,
  });

  factory SafetyPlan.fromJson(Map<String, dynamic> json) =>
      _$SafetyPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SafetyPlanToJson(this);
}

/// Flag Durumu - Flag'ların mevcut durumunu takip eder
/// Flag'ın yaşam döngüsünü yönetir
enum FlagStatus {
  @JsonValue('active') active, // Aktif - Dikkat gerektiriyor
  @JsonValue('monitoring') monitoring, // İzlemede - Yakın takip
  @JsonValue('resolved') resolved, // Çözüldü - Risk geçti
  @JsonValue('escalated') escalated, // Yükseltildi - Daha yüksek seviyede
  @JsonValue('dismissed') dismissed, // Reddedildi - Yanlış alarm
  @JsonValue('archived') archived, // Arşivlendi - Geçmiş kayıt
}

/// Kriz Müdahale Protokolü - Standart kriz müdahale adımları
/// Her kriz türü için önceden tanımlanmış müdahale sırası
@JsonSerializable()
class CrisisInterventionProtocol {
  final String id; // Benzersiz tanımlayıcı
  final CrisisType crisisType; // Kriz türü
  final CrisisSeverity severity; // Kriz şiddeti
  final List<InterventionStep> steps; // Müdahale adımları
  final List<String> requiredResources; // Gerekli kaynaklar
  final List<String> teamMembers; // Ekip üyeleri
  final int estimatedDuration; // Tahmini süre (dakika)
  final String successCriteria; // Başarı kriterleri
  final List<String> escalationTriggers; // Yükseltme tetikleyicileri
  final Map<String, dynamic> metadata; // Ek meta veriler

  const CrisisInterventionProtocol({
    required this.id,
    required this.crisisType,
    required this.severity,
    required this.steps,
    required this.requiredResources,
    required this.teamMembers,
    required this.estimatedDuration,
    required this.successCriteria,
    required this.escalationTriggers,
    required this.metadata,
  });

  factory CrisisInterventionProtocol.fromJson(Map<String, dynamic> json) =>
      _$CrisisInterventionProtocolFromJson(json);

  Map<String, dynamic> toJson() => _$CrisisInterventionProtocolToJson(this);
}

/// Müdahale Adımı - Kriz müdahalesinde tek bir adım
/// Sıralı ve ölçülebilir müdahale adımları
@JsonSerializable()
class InterventionStep {
  final String id; // Benzersiz tanımlayıcı
  final int stepNumber; // Adım numarası
  final String description; // Adım açıklaması
  final String action; // Yapılacak eylem
  final String responsiblePerson; // Sorumlu kişi
  final int estimatedTime; // Tahmini süre (dakika)
  final List<String> prerequisites; // Ön koşullar
  final List<String> successIndicators; // Başarı göstergeleri
  final List<String> failureIndicators; // Başarısızlık göstergeleri
  final Map<String, dynamic> metadata; // Ek meta veriler

  const InterventionStep({
    required this.id,
    required this.stepNumber,
    required this.description,
    required this.action,
    required this.responsiblePerson,
    required this.estimatedTime,
    required this.prerequisites,
    required this.successIndicators,
    required this.failureIndicators,
    required this.metadata,
  });

  factory InterventionStep.fromJson(Map<String, dynamic> json) =>
      _$InterventionStepFromJson(json);

  Map<String, dynamic> toJson() => _$InterventionStepToJson(this);
}

/// Flag Geçmişi - Tüm flag'ların zaman içindeki değişimini takip eder
/// Flag'ların yaşam döngüsü ve müdahale sonuçlarını kaydeder
@JsonSerializable()
class FlagHistory {
  final String id; // Benzersiz tanımlayıcı
  final String flagId; // Flag kimliği
  final String patientId; // Hasta kimliği
  final DateTime timestamp; // Zaman damgası
  final FlagStatus previousStatus; // Önceki durum
  final FlagStatus newStatus; // Yeni durum
  final String changeReason; // Değişim nedeni
  final String? notes; // Notlar
  final String changedBy; // Değiştiren kişi
  final Map<String, dynamic> metadata; // Ek meta veriler

  const FlagHistory({
    required this.id,
    required this.flagId,
    required this.patientId,
    required this.timestamp,
    required this.previousStatus,
    required this.newStatus,
    required this.changeReason,
    this.notes,
    required this.changedBy,
    required this.metadata,
  });

  factory FlagHistory.fromJson(Map<String, dynamic> json) =>
      _$FlagHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$FlagHistoryToJson(this);
}
