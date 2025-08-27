import 'package:json_annotation/json_annotation.dart';

part 'legal_policy_models.g.dart';

/// Eyalet kodları (örnek, genişletilebilir)
enum UsStateCode {
  @JsonValue('CA') ca,
  @JsonValue('NY') ny,
  @JsonValue('TX') tx,
  @JsonValue('FL') fl,
  @JsonValue('IL') il,
}

/// Hukuki yükümlülük türleri
enum LegalObligationType {
  @JsonValue('duty_to_warn') dutyToWarn, // Uyarma yükümlülüğü
  @JsonValue('mandatory_reporting') mandatoryReporting, // Zorunlu bildirim
  @JsonValue('involuntary_hold') involuntaryHold, // Zorla yatırma/hold
  @JsonValue('safety_plan_required') safetyPlanRequired, // Güvenlik planı zorunluluğu
}

/// Aksiyon önemi/seviyesi
enum LegalActionSeverity {
  @JsonValue('info') info,
  @JsonValue('low') low,
  @JsonValue('medium') medium,
  @JsonValue('high') high,
  @JsonValue('critical') critical,
}

/// Politika koşulu - basit kural yapısı
@JsonSerializable()
class PolicyCondition {
  final String key; // ör: risk_level, threat_to_others, age, guardianship
  final String operator; // eq, ne, in, not_in, gte, lte, exists
  final dynamic value; // hedef değer (string/num/bool/list)

  const PolicyCondition({
    required this.key,
    required this.operator,
    required this.value,
  });

  factory PolicyCondition.fromJson(Map<String, dynamic> json) => _$PolicyConditionFromJson(json);
  Map<String, dynamic> toJson() => _$PolicyConditionToJson(this);
}

/// Politika aksiyonu - yapılması beklenen işlem/obligasyon
@JsonSerializable()
class PolicyAction {
  final String id;
  final LegalObligationType obligation;
  final LegalActionSeverity severity;
  final String title; // kısa başlık
  final String description; // detay açıklama
  final String templateKey; // bildirim/şablon anahtarı
  final Map<String, dynamic> metadata; // ek veriler

  const PolicyAction({
    required this.id,
    required this.obligation,
    required this.severity,
    required this.title,
    required this.description,
    required this.templateKey,
    this.metadata = const {},
  });

  factory PolicyAction.fromJson(Map<String, dynamic> json) => _$PolicyActionFromJson(json);
  Map<String, dynamic> toJson() => _$PolicyActionToJson(this);
}

/// Tekil kural: koşullar sağlanırsa aksiyonlar uygulanır
@JsonSerializable()
class LegalRule {
  final String id;
  final String name;
  final List<PolicyCondition> allOf; // tüm koşullar sağlanmalı
  final List<PolicyAction> actions; // gerçekleştirilmesi gereken aksiyonlar
  final int priority; // yüksek öncelik önce değerlendirilir

  const LegalRule({
    required this.id,
    required this.name,
    required this.allOf,
    required this.actions,
    this.priority = 0,
  });

  factory LegalRule.fromJson(Map<String, dynamic> json) => _$LegalRuleFromJson(json);
  Map<String, dynamic> toJson() => _$LegalRuleToJson(this);
}

/// Eyalet politikası: bir eyalet için kural grupları
@JsonSerializable()
class StateLegalPolicy {
  final String id;
  final UsStateCode state;
  final String version;
  final DateTime updatedAt;
  final List<LegalRule> rules;
  final Map<String, String> notificationTemplates; // templateKey -> şablon
  final Map<String, dynamic> metadata;

  const StateLegalPolicy({
    required this.id,
    required this.state,
    required this.version,
    required this.updatedAt,
    required this.rules,
    required this.notificationTemplates,
    this.metadata = const {},
  });

  factory StateLegalPolicy.fromJson(Map<String, dynamic> json) => _$StateLegalPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$StateLegalPolicyToJson(this);
}

/// Değerlendirme isteği (context)
@JsonSerializable()
class LegalEvaluationContext {
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final String crisisType; // Kriz türü (suicide_risk, threat_to_others, vb.)
  final String severity; // Şiddet seviyesi (low, medium, high, critical)
  final String description; // Kriz açıklaması
  final List<String> symptoms; // Belirtiler
  final List<String> riskFactors; // Risk faktörleri
  final List<String> immediateActions; // Acil eylemler
  final DateTime timestamp; // Zaman damgası
  final UsStateCode state; // Eyalet kodu
  final Map<String, dynamic> facts; // Ek gerçekler
  final Map<String, dynamic> metadata; // Meta veriler

  const LegalEvaluationContext({
    required this.patientId,
    required this.clinicianId,
    required this.crisisType,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.riskFactors,
    required this.immediateActions,
    required this.timestamp,
    required this.state,
    required this.facts,
    this.metadata = const {},
  });

  factory LegalEvaluationContext.fromJson(Map<String, dynamic> json) => _$LegalEvaluationContextFromJson(json);
  Map<String, dynamic> toJson() => _$LegalEvaluationContextToJson(this);
}

/// Değerlendirme sonucu
@JsonSerializable()
class LegalDecision {
  final UsStateCode state;
  final List<PolicyAction> requiredActions;
  final List<String> notifications; // oluşturulan metin şablonları
  final Map<String, dynamic> reasoning; // hangi kurallar tetiklendi vb.

  const LegalDecision({
    required this.state,
    required this.requiredActions,
    required this.notifications,
    required this.reasoning,
  });

  factory LegalDecision.fromJson(Map<String, dynamic> json) => _$LegalDecisionFromJson(json);
  Map<String, dynamic> toJson() => _$LegalDecisionToJson(this);
}
