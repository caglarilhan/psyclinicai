// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saas_billing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      tier: $enumDecode(_$PlanTierEnumMap, json['tier']),
      features: (json['features'] as List<dynamic>)
          .map((e) => PlanFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxUsers: (json['maxUsers'] as num).toInt(),
      maxPatients: (json['maxPatients'] as num).toInt(),
      maxStorageGB: (json['maxStorageGB'] as num).toInt(),
      integrations: (json['integrations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionPlanToJson(SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'monthlyPrice': instance.monthlyPrice,
      'yearlyPrice': instance.yearlyPrice,
      'currency': instance.currency,
      'tier': _$PlanTierEnumMap[instance.tier]!,
      'features': instance.features,
      'maxUsers': instance.maxUsers,
      'maxPatients': instance.maxPatients,
      'maxStorageGB': instance.maxStorageGB,
      'integrations': instance.integrations,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PlanTierEnumMap = {
  PlanTier.starter: 'starter',
  PlanTier.professional: 'professional',
  PlanTier.enterprise: 'enterprise',
  PlanTier.custom: 'custom',
};

PlanFeature _$PlanFeatureFromJson(Map<String, dynamic> json) => PlanFeature(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$FeatureCategoryEnumMap, json['category']),
  isIncluded: json['isIncluded'] as bool,
  limit: json['limit'] as String?,
  additionalCost: json['additionalCost'] as String?,
);

Map<String, dynamic> _$PlanFeatureToJson(PlanFeature instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': _$FeatureCategoryEnumMap[instance.category]!,
      'isIncluded': instance.isIncluded,
      'limit': instance.limit,
      'additionalCost': instance.additionalCost,
    };

const _$FeatureCategoryEnumMap = {
  FeatureCategory.core: 'core',
  FeatureCategory.ai: 'ai',
  FeatureCategory.security: 'security',
  FeatureCategory.compliance: 'compliance',
  FeatureCategory.integrations: 'integrations',
  FeatureCategory.support: 'support',
  FeatureCategory.analytics: 'analytics',
};

OrganizationSubscription _$OrganizationSubscriptionFromJson(
  Map<String, dynamic> json,
) => OrganizationSubscription(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  planId: json['planId'] as String,
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  billingCycle: $enumDecode(_$BillingCycleEnumMap, json['billingCycle']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  nextBillingDate: json['nextBillingDate'] == null
      ? null
      : DateTime.parse(json['nextBillingDate'] as String),
  currentAmount: (json['currentAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  addons: (json['addons'] as List<dynamic>)
      .map((e) => SubscriptionAddon.fromJson(e as Map<String, dynamic>))
      .toList(),
  billingHistory: (json['billingHistory'] as List<dynamic>)
      .map((e) => BillingHistory.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentMethod: PaymentMethod.fromJson(
    json['paymentMethod'] as Map<String, dynamic>,
  ),
  autoRenew: json['autoRenew'] as bool,
  cancellationReason: json['cancellationReason'] as String?,
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
);

Map<String, dynamic> _$OrganizationSubscriptionToJson(
  OrganizationSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'planId': instance.planId,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'billingCycle': _$BillingCycleEnumMap[instance.billingCycle]!,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'nextBillingDate': instance.nextBillingDate?.toIso8601String(),
  'currentAmount': instance.currentAmount,
  'currency': instance.currency,
  'addons': instance.addons,
  'billingHistory': instance.billingHistory,
  'paymentMethod': instance.paymentMethod,
  'autoRenew': instance.autoRenew,
  'cancellationReason': instance.cancellationReason,
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.inactive: 'inactive',
  SubscriptionStatus.suspended: 'suspended',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.pending: 'pending',
};

const _$BillingCycleEnumMap = {
  BillingCycle.monthly: 'monthly',
  BillingCycle.yearly: 'yearly',
  BillingCycle.custom: 'custom',
};

SubscriptionAddon _$SubscriptionAddonFromJson(Map<String, dynamic> json) =>
    SubscriptionAddon(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      isActive: json['isActive'] as bool,
      addedAt: DateTime.parse(json['addedAt'] as String),
      removedAt: json['removedAt'] == null
          ? null
          : DateTime.parse(json['removedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionAddonToJson(SubscriptionAddon instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'monthlyPrice': instance.monthlyPrice,
      'yearlyPrice': instance.yearlyPrice,
      'currency': instance.currency,
      'isActive': instance.isActive,
      'addedAt': instance.addedAt.toIso8601String(),
      'removedAt': instance.removedAt?.toIso8601String(),
    };

BillingHistory _$BillingHistoryFromJson(Map<String, dynamic> json) =>
    BillingHistory(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      billingDate: DateTime.parse(json['billingDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$BillingStatusEnumMap, json['status']),
      invoiceNumber: json['invoiceNumber'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BillingHistoryToJson(BillingHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subscriptionId': instance.subscriptionId,
      'billingDate': instance.billingDate.toIso8601String(),
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$BillingStatusEnumMap[instance.status]!,
      'invoiceNumber': instance.invoiceNumber,
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'notes': instance.notes,
    };

const _$BillingStatusEnumMap = {
  BillingStatus.pending: 'pending',
  BillingStatus.paid: 'paid',
  BillingStatus.failed: 'failed',
  BillingStatus.refunded: 'refunded',
  BillingStatus.cancelled: 'cancelled',
};

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      type: $enumDecode(_$PaymentTypeEnumMap, json['type']),
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      holderName: json['holderName'] as String,
      isDefault: json['isDefault'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'type': _$PaymentTypeEnumMap[instance.type]!,
      'last4': instance.last4,
      'brand': instance.brand,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'holderName': instance.holderName,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PaymentTypeEnumMap = {
  PaymentType.creditCard: 'creditCard',
  PaymentType.debitCard: 'debitCard',
  PaymentType.bankTransfer: 'bankTransfer',
  PaymentType.paypal: 'paypal',
  PaymentType.applePay: 'applePay',
  PaymentType.googlePay: 'googlePay',
};

UsageMetrics _$UsageMetricsFromJson(Map<String, dynamic> json) => UsageMetrics(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  date: DateTime.parse(json['date'] as String),
  activeUsers: (json['activeUsers'] as num).toInt(),
  totalPatients: (json['totalPatients'] as num).toInt(),
  storageUsedGB: (json['storageUsedGB'] as num).toDouble(),
  aiRequests: (json['aiRequests'] as num).toInt(),
  apiCalls: (json['apiCalls'] as num).toInt(),
  featureUsage: Map<String, int>.from(json['featureUsage'] as Map),
);

Map<String, dynamic> _$UsageMetricsToJson(UsageMetrics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'date': instance.date.toIso8601String(),
      'activeUsers': instance.activeUsers,
      'totalPatients': instance.totalPatients,
      'storageUsedGB': instance.storageUsedGB,
      'aiRequests': instance.aiRequests,
      'apiCalls': instance.apiCalls,
      'featureUsage': instance.featureUsage,
    };

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  subscriptionId: json['subscriptionId'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  issueDate: DateTime.parse(json['issueDate'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  subtotal: (json['subtotal'] as num).toDouble(),
  tax: (json['tax'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  currency: json['currency'] as String,
  status: $enumDecode(_$InvoiceStatusEnumMap, json['status']),
  items: (json['items'] as List<dynamic>)
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  paymentTerms: json['paymentTerms'] as String?,
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'subscriptionId': instance.subscriptionId,
  'invoiceNumber': instance.invoiceNumber,
  'issueDate': instance.issueDate.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'subtotal': instance.subtotal,
  'tax': instance.tax,
  'total': instance.total,
  'currency': instance.currency,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'items': instance.items,
  'notes': instance.notes,
  'paymentTerms': instance.paymentTerms,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
};

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => InvoiceItem(
  id: json['id'] as String,
  description: json['description'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
      'notes': instance.notes,
    };
