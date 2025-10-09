import 'dart:convert';

enum SubscriptionStatus { active, canceled, pastDue, unpaid, trialing }
enum SubscriptionPlan { basic, professional, enterprise }
enum BillingCycle { monthly, yearly }

class Subscription {
  final String id;
  final String userId;
  final String customerId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final double price;
  final String currency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final DateTime nextBillingDate;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.plan,
    required this.status,
    required this.billingCycle,
    required this.price,
    required this.currency,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    required this.nextBillingDate,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Subscription copyWith({
    String? id,
    String? userId,
    String? customerId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    BillingCycle? billingCycle,
    double? price,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    DateTime? nextBillingDate,
    String? stripeSubscriptionId,
    String? stripeCustomerId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      billingCycle: billingCycle ?? this.billingCycle,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerId': customerId,
      'plan': plan.name,
      'status': status.name,
      'billingCycle': billingCycle.name,
      'price': price,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'stripeSubscriptionId': stripeSubscriptionId,
      'stripeCustomerId': stripeCustomerId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['userId'],
      customerId: json['customerId'],
      plan: SubscriptionPlan.values.firstWhere((e) => e.name == json['plan']),
      status: SubscriptionStatus.values.firstWhere((e) => e.name == json['status']),
      billingCycle: BillingCycle.values.firstWhere((e) => e.name == json['billingCycle']),
      price: json['price'].toDouble(),
      currency: json['currency'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      trialEndDate: json['trialEndDate'] != null ? DateTime.parse(json['trialEndDate']) : null,
      nextBillingDate: DateTime.parse(json['nextBillingDate']),
      stripeSubscriptionId: json['stripeSubscriptionId'],
      stripeCustomerId: json['stripeCustomerId'],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class SubscriptionPlanDetails {
  final SubscriptionPlan plan;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxClients;
  final int maxSessionsPerMonth;
  final bool includesTeletherapy;
  final bool includesAnalytics;
  final bool includesSupport;

  SubscriptionPlanDetails({
    required this.plan,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.maxClients,
    required this.maxSessionsPerMonth,
    required this.includesTeletherapy,
    required this.includesAnalytics,
    required this.includesSupport,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.name,
      'name': name,
      'description': description,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'features': features,
      'maxClients': maxClients,
      'maxSessionsPerMonth': maxSessionsPerMonth,
      'includesTeletherapy': includesTeletherapy,
      'includesAnalytics': includesAnalytics,
      'includesSupport': includesSupport,
    };
  }

  factory SubscriptionPlanDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanDetails(
      plan: SubscriptionPlan.values.firstWhere((e) => e.name == json['plan']),
      name: json['name'],
      description: json['description'],
      monthlyPrice: json['monthlyPrice'].toDouble(),
      yearlyPrice: json['yearlyPrice'].toDouble(),
      features: List<String>.from(json['features']),
      maxClients: json['maxClients'],
      maxSessionsPerMonth: json['maxSessionsPerMonth'],
      includesTeletherapy: json['includesTeletherapy'],
      includesAnalytics: json['includesAnalytics'],
      includesSupport: json['includesSupport'],
    );
  }
}

class PaymentMethod {
  final String id;
  final String userId;
  final String type; // card, bank_account, etc.
  final String last4;
  final String brand; // visa, mastercard, etc.
  final int expMonth;
  final int expYear;
  final bool isDefault;
  final String? stripePaymentMethodId;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
    this.stripePaymentMethodId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expMonth': expMonth,
      'expYear': expYear,
      'isDefault': isDefault,
      'stripePaymentMethodId': stripePaymentMethodId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      last4: json['last4'],
      brand: json['brand'],
      expMonth: json['expMonth'],
      expYear: json['expYear'],
      isDefault: json['isDefault'] ?? false,
      stripePaymentMethodId: json['stripePaymentMethodId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class BillingHistory {
  final String id;
  final String userId;
  final String subscriptionId;
  final double amount;
  final String currency;
  final String status; // paid, failed, pending
  final DateTime billingDate;
  final DateTime? paidDate;
  final String? invoiceUrl;
  final String? stripeInvoiceId;
  final Map<String, dynamic> metadata;

  BillingHistory({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.billingDate,
    this.paidDate,
    this.invoiceUrl,
    this.stripeInvoiceId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'billingDate': billingDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'invoiceUrl': invoiceUrl,
      'stripeInvoiceId': stripeInvoiceId,
      'metadata': metadata,
    };
  }

  factory BillingHistory.fromJson(Map<String, dynamic> json) {
    return BillingHistory(
      id: json['id'],
      userId: json['userId'],
      subscriptionId: json['subscriptionId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      billingDate: DateTime.parse(json['billingDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      invoiceUrl: json['invoiceUrl'],
      stripeInvoiceId: json['stripeInvoiceId'],
      metadata: json['metadata'] ?? {},
    );
  }
}
