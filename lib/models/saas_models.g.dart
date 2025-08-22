// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saas_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tenant _$TenantFromJson(Map<String, dynamic> json) => Tenant(
  id: json['id'] as String,
  name: json['name'] as String,
  domain: json['domain'] as String,
  region: json['region'] as String,
  plan: $enumDecode(_$TenantPlanEnumMap, json['plan']),
  status: $enumDecode(_$TenantStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  trialEndsAt: json['trialEndsAt'] == null
      ? null
      : DateTime.parse(json['trialEndsAt'] as String),
  subscriptionEndsAt: json['subscriptionEndsAt'] == null
      ? null
      : DateTime.parse(json['subscriptionEndsAt'] as String),
  settings: json['settings'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$TenantToJson(Tenant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'domain': instance.domain,
  'region': instance.region,
  'plan': _$TenantPlanEnumMap[instance.plan]!,
  'status': _$TenantStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'trialEndsAt': instance.trialEndsAt?.toIso8601String(),
  'subscriptionEndsAt': instance.subscriptionEndsAt?.toIso8601String(),
  'settings': instance.settings,
  'metadata': instance.metadata,
};

const _$TenantPlanEnumMap = {
  TenantPlan.free: 'free',
  TenantPlan.basic: 'basic',
  TenantPlan.professional: 'professional',
  TenantPlan.enterprise: 'enterprise',
  TenantPlan.custom: 'custom',
};

const _$TenantStatusEnumMap = {
  TenantStatus.active: 'active',
  TenantStatus.suspended: 'suspended',
  TenantStatus.cancelled: 'cancelled',
  TenantStatus.trial: 'trial',
  TenantStatus.expired: 'expired',
};

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  planId: json['planId'] as String,
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  trialEndsAt: json['trialEndsAt'] == null
      ? null
      : DateTime.parse(json['trialEndsAt'] as String),
  maxUsers: (json['maxUsers'] as num).toInt(),
  maxStorageGB: (json['maxStorageGB'] as num).toInt(),
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  limits: json['limits'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'planId': instance.planId,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'trialEndsAt': instance.trialEndsAt?.toIso8601String(),
      'maxUsers': instance.maxUsers,
      'maxStorageGB': instance.maxStorageGB,
      'features': instance.features,
      'limits': instance.limits,
      'metadata': instance.metadata,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.pastDue: 'pastDue',
  SubscriptionStatus.trialing: 'trialing',
  SubscriptionStatus.expired: 'expired',
};

UsageMetrics _$UsageMetricsFromJson(Map<String, dynamic> json) => UsageMetrics(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  date: DateTime.parse(json['date'] as String),
  activeUsers: (json['activeUsers'] as num).toInt(),
  totalSessions: (json['totalSessions'] as num).toInt(),
  aiRequests: (json['aiRequests'] as num).toInt(),
  storageUsedMB: (json['storageUsedMB'] as num).toInt(),
  apiCalls: (json['apiCalls'] as num).toInt(),
  featureUsage: json['featureUsage'] as Map<String, dynamic>? ?? const {},
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$UsageMetricsToJson(UsageMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'date': instance.date.toIso8601String(),
      'activeUsers': instance.activeUsers,
      'totalSessions': instance.totalSessions,
      'aiRequests': instance.aiRequests,
      'storageUsedMB': instance.storageUsedMB,
      'apiCalls': instance.apiCalls,
      'featureUsage': instance.featureUsage,
      'metadata': instance.metadata,
    };

BillingRecord _$BillingRecordFromJson(Map<String, dynamic> json) =>
    BillingRecord(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      subscriptionId: json['subscriptionId'] as String,
      type: $enumDecode(_$BillingTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$BillingStatusEnumMap, json['status']),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      invoiceUrl: json['invoiceUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$BillingRecordToJson(BillingRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'subscriptionId': instance.subscriptionId,
      'type': _$BillingTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$BillingStatusEnumMap[instance.status]!,
      'dueDate': instance.dueDate.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'invoiceUrl': instance.invoiceUrl,
      'metadata': instance.metadata,
    };

const _$BillingTypeEnumMap = {
  BillingType.subscription: 'subscription',
  BillingType.overage: 'overage',
  BillingType.setup: 'setup',
  BillingType.addon: 'addon',
  BillingType.penalty: 'penalty',
};

const _$BillingStatusEnumMap = {
  BillingStatus.pending: 'pending',
  BillingStatus.paid: 'paid',
  BillingStatus.overdue: 'overdue',
  BillingStatus.cancelled: 'cancelled',
  BillingStatus.refunded: 'refunded',
};

APIRateLimit _$APIRateLimitFromJson(Map<String, dynamic> json) => APIRateLimit(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  endpoint: json['endpoint'] as String,
  maxRequests: (json['maxRequests'] as num).toInt(),
  timeWindowSeconds: (json['timeWindowSeconds'] as num).toInt(),
  currentUsage: (json['currentUsage'] as num).toInt(),
  resetTime: DateTime.parse(json['resetTime'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$APIRateLimitToJson(APIRateLimit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'endpoint': instance.endpoint,
      'maxRequests': instance.maxRequests,
      'timeWindowSeconds': instance.timeWindowSeconds,
      'currentUsage': instance.currentUsage,
      'resetTime': instance.resetTime.toIso8601String(),
      'metadata': instance.metadata,
    };

FeatureFlag _$FeatureFlagFromJson(Map<String, dynamic> json) => FeatureFlag(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  enabled: json['enabled'] as bool,
  tenantIds:
      (json['tenantIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  userIds:
      (json['userIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  rules: json['rules'] as Map<String, dynamic>? ?? const {},
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$FeatureFlagToJson(FeatureFlag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'enabled': instance.enabled,
      'tenantIds': instance.tenantIds,
      'userIds': instance.userIds,
      'rules': instance.rules,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'metadata': instance.metadata,
    };
