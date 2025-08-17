import 'package:json_annotation/json_annotation.dart';
import '../services/ai_case_management_service.dart';

part 'ai_case_management_models.g.dart';

// ===== AI VAKA ANALİZİ =====

@JsonSerializable()
class AICaseAnalysis {
  final String id;
  final String caseId;
  final String clientId;
  final String therapistId;
  final DateTime analysisDate;
  final CaseAnalysisType type;
  final double confidence;
  final String summary;
  final List<CaseInsight> insights;
  final List<RiskFactor> riskFactors;
  final List<Recommendation> recommendations;
  final Map<String, dynamic> data;
  final String? notes;
  final bool isActive;

  const AICaseAnalysis({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.therapistId,
    required this.analysisDate,
    required this.type,
    required this.confidence,
    required this.summary,
    required this.insights,
    required this.riskFactors,
    required this.recommendations,
    required this.data,
    this.notes,
    required this.isActive,
  });

  factory AICaseAnalysis.fromJson(Map<String, dynamic> json) => _$AICaseAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$AICaseAnalysisToJson(this);
}

enum CaseAnalysisType {
  initial,
  progress,
  risk,
  outcome,
  relapse,
  maintenance,
  crisis
}

@JsonSerializable()
class CaseInsight {
  final String id;
  final InsightCategory category;
  final String title;
  final String description;
  final double importance;
  final List<String> evidence;
  final DateTime createdAt;
  final bool isActioned;

  const CaseInsight({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.importance,
    required this.evidence,
    required this.createdAt,
    required this.isActioned,
  });

  factory CaseInsight.fromJson(Map<String, dynamic> json) => _$CaseInsightFromJson(json);
  Map<String, dynamic> toJson() => _$CaseInsightToJson(this);
}

enum InsightCategory {
  behavioral,
  emotional,
  cognitive,
  social,
  environmental,
  medical,
  therapeutic
}

@JsonSerializable()
class RiskFactor {
  final String id;
  final RiskType type;
  final RiskSeverity severity;
  final String description;
  final double probability;
  final List<String> indicators;
  final List<String> mitigationStrategies;
  final DateTime identifiedAt;
  final bool isMonitored;

  const RiskFactor({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.probability,
    required this.indicators,
    required this.mitigationStrategies,
    required this.identifiedAt,
    required this.isMonitored,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) => _$RiskFactorFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

enum RiskType {
  selfHarm,
  harmToOthers,
  substanceAbuse,
  relapse,
  nonCompliance,
  crisis,
  medical,
  social
}

enum RiskSeverity {
  low,
  moderate,
  high,
  critical
}

@JsonSerializable()
class Recommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final double priority;
  final List<String> actions;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;

  const Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.actions,
    required this.dueDate,
    required this.isCompleted,
    this.completedAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}

enum RecommendationType {
  assessment,
  intervention,
  referral,
  monitoring,
  education,
  support,
  crisis
}

// ===== İLERLEME TAKİBİ =====

@JsonSerializable()
class ProgressTracking {
  final String id;
  final String caseId;
  final String clientId;
  final String therapistId;
  final DateTime assessmentDate;
  final List<ProgressMetric> metrics;
  final List<Goal> goals;
  final List<Milestone> milestones;
  final ProgressStatus status;
  final double overallProgress;
  final Map<String, dynamic> data;

  const ProgressTracking({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.therapistId,
    required this.assessmentDate,
    required this.metrics,
    required this.goals,
    required this.milestones,
    required this.status,
    required this.overallProgress,
    required this.data,
  });

  factory ProgressTracking.fromJson(Map<String, dynamic> json) => _$ProgressTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressTrackingToJson(this);
}

@JsonSerializable()
class ProgressMetric {
  final String id;
  final String name;
  final String category;
  final double baselineValue;
  final double currentValue;
  final double targetValue;
  final String unit;
  final MetricTrend trend;
  final DateTime lastUpdated;

  const ProgressMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.baselineValue,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    required this.trend,
    required this.lastUpdated,
  });

  factory ProgressMetric.fromJson(Map<String, dynamic> json) => _$ProgressMetricFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressMetricToJson(this);
}

enum MetricTrend {
  improving,
  stable,
  declining,
  fluctuating
}

@JsonSerializable()
class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final GoalPriority priority;
  final DateTime targetDate;
  final GoalStatus status;
  final double completionPercentage;
  final List<String> subGoals;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.targetDate,
    required this.status,
    required this.completionPercentage,
    required this.subGoals,
    required this.createdAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}

enum GoalType {
  symptom,
  functional,
  behavioral,
  cognitive,
  social,
  occupational,
  qualityOfLife
}

enum GoalPriority {
  low,
  medium,
  high,
  critical
}

enum GoalStatus {
  notStarted,
  inProgress,
  completed,
  onHold,
  cancelled
}

@JsonSerializable()
class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final DateTime? achievedDate;
  final MilestoneStatus status;
  final List<String> criteria;
  final double importance;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    this.achievedDate,
    required this.status,
    required this.criteria,
    required this.importance,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);
  Map<String, dynamic> toJson() => _$MilestoneToJson(this);
}

enum MilestoneStatus {
  pending,
  inProgress,
  achieved,
  overdue,
  cancelled
}

enum ProgressStatus {
  improving,
  stable,
  declining,
  crisis,
  maintenance
}

// ===== GELİŞİM RAPORLARI =====

@JsonSerializable()
class DevelopmentReport {
  final String id;
  final String caseId;
  final String clientId;
  final String therapistId;
  final DateTime reportDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String executiveSummary;
  final List<ProgressMetric> keyMetrics;
  final List<CaseInsight> keyInsights;
  final List<RiskFactor> activeRisks;
  final List<Recommendation> nextSteps;
  final double overallProgress;
  final String? notes;

  const DevelopmentReport({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.therapistId,
    required this.reportDate,
    required this.periodStart,
    required this.periodEnd,
    required this.executiveSummary,
    required this.keyMetrics,
    required this.keyInsights,
    required this.activeRisks,
    required this.nextSteps,
    required this.overallProgress,
    this.notes,
  });

  factory DevelopmentReport.fromJson(Map<String, dynamic> json) => _$DevelopmentReportFromJson(json);
  Map<String, dynamic> toJson() => _$DevelopmentReportToJson(this);
}

// ===== GELİŞMİŞ GÜVENLİK MODELLERİ =====

@JsonSerializable()
class SecurityAudit {
  final String id;
  final String userId;
  final String action;
  final String resource;
  final String ipAddress;
  final String userAgent;
  final DateTime timestamp;
  final AuditSeverity severity;
  final bool isSuccessful;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const SecurityAudit({
    required this.id,
    required this.userId,
    required this.action,
    required this.resource,
    required this.ipAddress,
    required this.userAgent,
    required this.timestamp,
    required this.severity,
    required this.isSuccessful,
    this.failureReason,
    required this.metadata,
  });

  factory SecurityAudit.fromJson(Map<String, dynamic> json) => _$SecurityAuditFromJson(json);
  Map<String, dynamic> toJson() => _$SecurityAuditToJson(this);
}

enum AuditSeverity {
  info,
  warning,
  error,
  critical
}

@JsonSerializable()
class EncryptionKey {
  final String id;
  final String keyId;
  final String algorithm;
  final int keySize;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? description;
  final Map<String, dynamic> metadata;

  const EncryptionKey({
    required this.id,
    required this.keyId,
    required this.algorithm,
    required this.keySize,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
    this.description,
    required this.metadata,
  });

  factory EncryptionKey.fromJson(Map<String, dynamic> json) => _$EncryptionKeyFromJson(json);
  Map<String, dynamic> toJson() => _$EncryptionKeyToJson(this);
}

@JsonSerializable()
class BiometricAuth {
  final String id;
  final String userId;
  final BiometricType type;
  final String identifier;
  final DateTime registeredAt;
  final DateTime? lastUsed;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const BiometricAuth({
    required this.id,
    required this.userId,
    required this.type,
    required this.identifier,
    required this.registeredAt,
    this.lastUsed,
    required this.isActive,
    required this.metadata,
  });

  factory BiometricAuth.fromJson(Map<String, dynamic> json) => _$BiometricAuthFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricAuthToJson(this);
}

enum BiometricType {
  fingerprint,
  face,
  iris,
  voice,
  gait,
  heartbeat
}

@JsonSerializable()
class BlockchainRecord {
  final String id;
  final String hash;
  final String previousHash;
  final String data;
  final DateTime timestamp;
  final String userId;
  final String recordType;
  final bool isImmutable;
  final Map<String, dynamic> metadata;

  const BlockchainRecord({
    required this.id,
    required this.hash,
    required this.previousHash,
    required this.data,
    required this.timestamp,
    required this.userId,
    required this.recordType,
    required this.isImmutable,
    required this.metadata,
  });

  factory BlockchainRecord.fromJson(Map<String, dynamic> json) => _$BlockchainRecordFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainRecordToJson(this);
}

// ===== UYUMLULUK MODELLERİ =====

@JsonSerializable()
class ComplianceCheck {
  final String id;
  final String standard;
  final String requirement;
  final ComplianceStatus status;
  final DateTime lastChecked;
  final DateTime? nextCheck;
  final String? notes;
  final List<String> violations;
  final List<String> remediationSteps;

  const ComplianceCheck({
    required this.id,
    required this.standard,
    required this.requirement,
    required this.status,
    required this.lastChecked,
    this.nextCheck,
    this.notes,
    required this.violations,
    required this.remediationSteps,
  });

  factory ComplianceCheck.fromJson(Map<String, dynamic> json) => _$ComplianceCheckFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceCheckToJson(this);
}

enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
  pending
}

@JsonSerializable()
class PrivacyConsent {
  final String id;
  final String userId;
  final String consentType;
  final bool isGranted;
  final DateTime grantedAt;
  final DateTime? revokedAt;
  final String? revocationReason;
  final List<String> purposes;
  final Map<String, dynamic> metadata;

  const PrivacyConsent({
    required this.id,
    required this.userId,
    required this.consentType,
    required this.isGranted,
    required this.grantedAt,
    this.revokedAt,
    this.revocationReason,
    required this.purposes,
    required this.metadata,
  });

  factory PrivacyConsent.fromJson(Map<String, dynamic> json) => _$PrivacyConsentFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacyConsentToJson(this);
}

// ===== ÇOK ÜLKE DESTEĞİ =====

@JsonSerializable()
class RegionConfig {
  final String id;
  final String countryCode;
  final String countryName;
  final String language;
  final String currency;
  final String timezone;
  final List<String> supportedLanguages;
  final Map<String, dynamic> healthcareStandards;
  final Map<String, dynamic> privacyLaws;
  final Map<String, dynamic> drugDatabases;
  final Map<String, dynamic> culturalNorms;
  final bool isActive;

  const RegionConfig({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.language,
    required this.currency,
    required this.timezone,
    required this.supportedLanguages,
    required this.healthcareStandards,
    required this.privacyLaws,
    required this.drugDatabases,
    required this.culturalNorms,
    required this.isActive,
  });

  factory RegionConfig.fromJson(Map<String, dynamic> json) => _$RegionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RegionConfigToJson(this);
}

@JsonSerializable()
class CulturalSensitivity {
  final String id;
  final String regionId;
  final String category;
  final String description;
  final SensitivityLevel level;
  final List<String> guidelines;
  final List<String> taboos;
  final Map<String, dynamic> metadata;

  const CulturalSensitivity({
    required this.id,
    required this.regionId,
    required this.category,
    required this.description,
    required this.level,
    required this.guidelines,
    required this.taboos,
    required this.metadata,
  });

  factory CulturalSensitivity.fromJson(Map<String, dynamic> json) => _$CulturalSensitivityFromJson(json);
  Map<String, dynamic> toJson() => _$CulturalSensitivityToJson(this);
}

enum SensitivityLevel {
  low,
  medium,
  high,
  critical
}

// ===== VAKA ÖZETİ =====

@JsonSerializable()
class CaseSummary {
  final String id;
  final String caseId;
  final String clientId;
  final String therapistId;
  final String title;
  final String description;
  final CaseStatus status;
  final DateTime openedAt;
  final DateTime? closedAt;
  final List<String> diagnoses;
  final List<String> medications;
  final List<String> keyIssues;
  final double progressPercentage;
  final List<CaseInsight> recentInsights;
  final List<RiskFactor> activeRisks;
  final Map<String, dynamic> metadata;

  const CaseSummary({
    required this.id,
    required this.caseId,
    required this.clientId,
    required this.therapistId,
    required this.title,
    required this.description,
    required this.status,
    required this.openedAt,
    this.closedAt,
    required this.diagnoses,
    required this.medications,
    required this.keyIssues,
    required this.progressPercentage,
    required this.recentInsights,
    required this.activeRisks,
    required this.metadata,
  });

  factory CaseSummary.fromJson(Map<String, dynamic> json) => _$CaseSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$CaseSummaryToJson(this);
}

enum CaseStatus {
  active,
  onHold,
  closed,
  transferred,
  archived
}

// ===== VAKA ÖNCELİKLENDİRME =====

@JsonSerializable()
class CasePriority {
  final String id;
  final String caseId;
  final String caseTitle;
  final Priority priority;
  final RiskLevel riskLevel;
  final double aiConfidence;
  final DateTime lastUpdated;
  final String? notes;

  const CasePriority({
    required this.id,
    required this.caseId,
    required this.caseTitle,
    required this.priority,
    required this.riskLevel,
    required this.aiConfidence,
    required this.lastUpdated,
    this.notes,
  });

  factory CasePriority.fromJson(Map<String, dynamic> json) => _$CasePriorityFromJson(json);
  Map<String, dynamic> toJson() => _$CasePriorityToJson(this);
}

enum Priority {
  high,
  medium,
  low
}

enum RiskLevel {
  high,
  medium,
  low
}

// ===== AI SERVİS METODLARI =====

extension AICaseManagementServiceExtension on AICaseManagementService {
  Future<double> getRealTimeRiskScore() async {
    // Simüle edilmiş risk skoru (0.0 - 1.0)
    await Future.delayed(const Duration(milliseconds: 500));
    return 0.65; // %65 risk
  }

  Future<List<CasePriority>> getCasePriorities() async {
    // Simüle edilmiş vaka öncelikleri
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      CasePriority(
        id: '1',
        caseId: 'case_001',
        caseTitle: 'Depresyon Vakası - Ahmet Y.',
        priority: Priority.high,
        riskLevel: RiskLevel.high,
        aiConfidence: 0.92,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        notes: 'Yüksek intihar riski, acil müdahale gerekli',
      ),
      CasePriority(
        id: '2',
        caseId: 'case_002',
        caseTitle: 'Anksiyete Bozukluğu - Ayşe D.',
        priority: Priority.medium,
        riskLevel: RiskLevel.medium,
        aiConfidence: 0.78,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        notes: 'Orta seviye anksiyete, düzenli takip gerekli',
      ),
      CasePriority(
        id: '3',
        caseId: 'case_003',
        caseTitle: 'PTSD Vakası - Mehmet K.',
        priority: Priority.high,
        riskLevel: RiskLevel.high,
        aiConfidence: 0.89,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        notes: 'Travma sonrası stres, kriz müdahale protokolü aktif',
      ),
      CasePriority(
        id: '4',
        caseId: 'case_004',
        caseTitle: 'OKB Vakası - Fatma Ö.',
        priority: Priority.medium,
        riskLevel: RiskLevel.medium,
        aiConfidence: 0.81,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
        notes: 'Obsesif kompulsif bozukluk, CBT tedavisi devam ediyor',
      ),
      CasePriority(
        id: '5',
        caseId: 'case_005',
        caseTitle: 'Bipolar Bozukluk - Ali V.',
        priority: Priority.low,
        riskLevel: RiskLevel.low,
        aiConfidence: 0.95,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        notes: 'Stabil durum, rutin takip yeterli',
      ),
    ];
  }

  Future<List<CasePriority>> autoPrioritizeCases() async {
    // Otomatik önceliklendirme simülasyonu
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final priorities = await getCasePriorities();
    
    // AI algoritması ile öncelikleri yeniden hesapla
    for (var priority in priorities) {
      // Risk faktörlerine göre öncelik güncelle
      if (priority.riskLevel == RiskLevel.high) {
        priority = CasePriority(
          id: priority.id,
          caseId: priority.caseId,
          caseTitle: priority.caseTitle,
          priority: Priority.high,
          riskLevel: priority.riskLevel,
          aiConfidence: priority.aiConfidence,
          lastUpdated: DateTime.now(),
          notes: priority.notes,
        );
      }
    }
    
    return priorities;
  }
}
