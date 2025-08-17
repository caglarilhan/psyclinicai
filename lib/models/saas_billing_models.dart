import 'package:json_annotation/json_annotation.dart';

part 'saas_billing_models.g.dart';

@JsonSerializable()
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final PlanTier tier;
  final List<PlanFeature> features;
  final int maxUsers;
  final int maxPatients;
  final int maxStorageGB;
  final List<String> integrations;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.tier,
    required this.features,
    required this.maxUsers,
    required this.maxPatients,
    required this.maxStorageGB,
    required this.integrations,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);

  double get yearlyDiscount => ((monthlyPrice * 12) - yearlyPrice) / (monthlyPrice * 12);
}

@JsonSerializable()
class PlanFeature {
  final String id;
  final String name;
  final String description;
  final FeatureCategory category;
  final bool isIncluded;
  final String? limit;
  final String? additionalCost;

  const PlanFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isIncluded,
    this.limit,
    this.additionalCost,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) =>
      _$PlanFeatureFromJson(json);

  Map<String, dynamic> toJson() => _$PlanFeatureToJson(this);
}

@JsonSerializable()
class OrganizationSubscription {
  final String id;
  final String organizationId;
  final String planId;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? nextBillingDate;
  final double currentAmount;
  final String currency;
  final List<SubscriptionAddon> addons;
  final List<BillingHistory> billingHistory;
  final PaymentMethod paymentMethod;
  final bool autoRenew;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  const OrganizationSubscription({
    required this.id,
    required this.organizationId,
    required this.planId,
    required this.status,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    this.nextBillingDate,
    required this.currentAmount,
    required this.currency,
    required this.addons,
    required this.billingHistory,
    required this.paymentMethod,
    required this.autoRenew,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory OrganizationSubscription.fromJson(Map<String, dynamic> json) =>
      _$OrganizationSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationSubscriptionToJson(this);

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get needsRenewal => DateTime.now().isAfter(endDate.subtract(const Duration(days: 30)));
}

@JsonSerializable()
class SubscriptionAddon {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final bool isActive;
  final DateTime addedAt;
  final DateTime? removedAt;

  const SubscriptionAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.isActive,
    required this.addedAt,
    this.removedAt,
  });

  factory SubscriptionAddon.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionAddonFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionAddonToJson(this);
}

@JsonSerializable()
class BillingHistory {
  final String id;
  final String subscriptionId;
  final DateTime billingDate;
  final double amount;
  final String currency;
  final BillingStatus status;
  final String invoiceNumber;
  final String? paymentMethod;
  final String? transactionId;
  final String? notes;

  const BillingHistory({
    required this.id,
    required this.subscriptionId,
    required this.billingDate,
    required this.amount,
    required this.currency,
    required this.status,
    required this.invoiceNumber,
    this.paymentMethod,
    this.transactionId,
    this.notes,
  });

  factory BillingHistory.fromJson(Map<String, dynamic> json) =>
      _$BillingHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$BillingHistoryToJson(this);
}

@JsonSerializable()
class PaymentMethod {
  final String id;
  final String organizationId;
  final PaymentType type;
  final String last4;
  final String brand;
  final DateTime expiryDate;
  final String holderName;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethod({
    required this.id,
    required this.organizationId,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expiryDate,
    required this.holderName,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}

@JsonSerializable()
class UsageMetrics {
  final String id;
  final String organizationId;
  final DateTime date;
  final int activeUsers;
  final int totalPatients;
  final double storageUsedGB;
  final int aiRequests;
  final int apiCalls;
  final Map<String, int> featureUsage;

  const UsageMetrics({
    required this.id,
    required this.organizationId,
    required this.date,
    required this.activeUsers,
    required this.totalPatients,
    required this.storageUsedGB,
    required this.aiRequests,
    required this.apiCalls,
    required this.featureUsage,
  });

  factory UsageMetrics.fromJson(Map<String, dynamic> json) =>
      _$UsageMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageMetricsToJson(this);
}

@JsonSerializable()
class Invoice {
  final String id;
  final String organizationId;
  final String subscriptionId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final String? notes;
  final String? paymentTerms;

  const Invoice({
    required this.id,
    required this.organizationId,
    required this.subscriptionId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    required this.status,
    required this.items,
    this.notes,
    this.paymentTerms,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != InvoiceStatus.paid;
}

@JsonSerializable()
class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? notes;

  const InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.notes,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);
}

enum PlanTier {
  starter,
  professional,
  enterprise,
  custom,
}

enum FeatureCategory {
  core,
  ai,
  security,
  compliance,
  integrations,
  support,
  analytics,
}

enum SubscriptionStatus {
  active,
  inactive,
  suspended,
  cancelled,
  expired,
  pending,
}

enum BillingCycle {
  monthly,
  yearly,
  custom,
}

enum BillingStatus {
  pending,
  paid,
  failed,
  refunded,
  cancelled,
}

enum PaymentType {
  creditCard,
  debitCard,
  bankTransfer,
  paypal,
  applePay,
  googlePay,
}

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  cancelled,
}
