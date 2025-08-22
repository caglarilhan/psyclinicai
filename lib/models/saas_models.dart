import 'package:json_annotation/json_annotation.dart';

part 'saas_models.g.dart';

@JsonSerializable()
class Tenant {
  final String id;
  final String name;
  final String domain;
  final String region;
  final TenantPlan plan;
  final TenantStatus status;
  final DateTime createdAt;
  final DateTime? trialEndsAt;
  final DateTime? subscriptionEndsAt;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;

  const Tenant({
    required this.id,
    required this.name,
    required this.domain,
    required this.region,
    required this.plan,
    required this.status,
    required this.createdAt,
    this.trialEndsAt,
    this.subscriptionEndsAt,
    this.settings = const {},
    this.metadata = const {},
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
  Map<String, dynamic> toJson() => _$TenantToJson(this);
}

enum TenantPlan {
  free,
  basic,
  professional,
  enterprise,
  custom
}

enum TenantStatus {
  active,
  suspended,
  cancelled,
  trial,
  expired
}

@JsonSerializable()
class Subscription {
  final String id;
  final String tenantId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? trialEndsAt;
  final int maxUsers;
  final int maxStorageGB;
  final List<String> features;
  final Map<String, dynamic> limits;
  final Map<String, dynamic> metadata;

  const Subscription({
    required this.id,
    required this.tenantId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.trialEndsAt,
    required this.maxUsers,
    required this.maxStorageGB,
    required this.features,
    this.limits = const {},
    this.metadata = const {},
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);
}

enum SubscriptionStatus {
  active,
  cancelled,
  pastDue,
  trialing,
  expired
}

@JsonSerializable()
class UsageMetrics {
  final String id;
  final String tenantId;
  final DateTime date;
  final int activeUsers;
  final int totalSessions;
  final int aiRequests;
  final int storageUsedMB;
  final int apiCalls;
  final Map<String, dynamic> featureUsage;
  final Map<String, dynamic> metadata;

  const UsageMetrics({
    required this.id,
    required this.tenantId,
    required this.date,
    required this.activeUsers,
    required this.totalSessions,
    required this.aiRequests,
    required this.storageUsedMB,
    required this.apiCalls,
    this.featureUsage = const {},
    this.metadata = const {},
  });

  factory UsageMetrics.fromJson(Map<String, dynamic> json) => _$UsageMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$UsageMetricsToJson(this);
}

@JsonSerializable()
class BillingRecord {
  final String id;
  final String tenantId;
  final String subscriptionId;
  final BillingType type;
  final double amount;
  final String currency;
  final BillingStatus status;
  final DateTime dueDate;
  final DateTime? paidAt;
  final String? invoiceUrl;
  final Map<String, dynamic> metadata;

  const BillingRecord({
    required this.id,
    required this.tenantId,
    required this.subscriptionId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.invoiceUrl,
    this.metadata = const {},
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) => _$BillingRecordFromJson(json);
  Map<String, dynamic> toJson() => _$BillingRecordToJson(this);
}

enum BillingType {
  subscription,
  overage,
  setup,
  addon,
  penalty
}

enum BillingStatus {
  pending,
  paid,
  overdue,
  cancelled,
  refunded
}

@JsonSerializable()
class APIRateLimit {
  final String id;
  final String tenantId;
  final String endpoint;
  final int maxRequests;
  final int timeWindowSeconds;
  final int currentUsage;
  final DateTime resetTime;
  final Map<String, dynamic> metadata;

  const APIRateLimit({
    required this.id,
    required this.tenantId,
    required this.endpoint,
    required this.maxRequests,
    required this.timeWindowSeconds,
    required this.currentUsage,
    required this.resetTime,
    this.metadata = const {},
  });

  factory APIRateLimit.fromJson(Map<String, dynamic> json) => _$APIRateLimitFromJson(json);
  Map<String, dynamic> toJson() => _$APIRateLimitToJson(this);
}

@JsonSerializable()
class FeatureFlag {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final List<String> tenantIds;
  final List<String> userIds;
  final Map<String, dynamic> rules;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const FeatureFlag({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    this.tenantIds = const [],
    this.userIds = const [],
    this.rules = const {},
    required this.createdAt,
    this.expiresAt,
    this.metadata = const {},
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) => _$FeatureFlagFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureFlagToJson(this);
}
