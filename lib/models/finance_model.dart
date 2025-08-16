import 'package:flutter/material.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled
}

enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  cash,
  stripe,
  paypal
}

enum InvoiceStatus {
  draft,
  sent,
  viewed,
  paid,
  overdue,
  cancelled
}

enum BillingType {
  hourly,
  session,
  package,
  subscription,
  consultation
}

class ClientBilling {
  final String id;
  final String clientId;
  final String clientName;
  final String therapistId;
  final String therapistName;
  final BillingType billingType;
  final double hourlyRate;
  final double sessionRate;
  final double packageRate;
  final double consultationRate;
  final Map<String, dynamic> customRates;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientBilling({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.therapistId,
    required this.therapistName,
    required this.billingType,
    this.hourlyRate = 0.0,
    this.sessionRate = 0.0,
    this.packageRate = 0.0,
    this.consultationRate = 0.0,
    this.customRates = const {},
    required this.effectiveDate,
    this.expiryDate,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get currentRate {
    switch (billingType) {
      case BillingType.hourly:
        return hourlyRate;
      case BillingType.session:
        return sessionRate;
      case BillingType.package:
        return packageRate;
      case BillingType.subscription:
        return packageRate;
      case BillingType.consultation:
        return consultationRate;
    }
  }

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  ClientBilling copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? therapistId,
    String? therapistName,
    BillingType? billingType,
    double? hourlyRate,
    double? sessionRate,
    double? packageRate,
    double? consultationRate,
    Map<String, dynamic>? customRates,
    DateTime? effectiveDate,
    DateTime? expiryDate,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientBilling(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      therapistId: therapistId ?? this.therapistId,
      therapistName: therapistName ?? this.therapistName,
      billingType: billingType ?? this.billingType,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      sessionRate: sessionRate ?? this.sessionRate,
      packageRate: packageRate ?? this.packageRate,
      consultationRate: consultationRate ?? this.consultationRate,
      customRates: customRates ?? this.customRates,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'therapistId': therapistId,
      'therapistName': therapistName,
      'billingType': billingType.name,
      'hourlyRate': hourlyRate,
      'sessionRate': sessionRate,
      'packageRate': packageRate,
      'consultationRate': consultationRate,
      'customRates': customRates,
      'effectiveDate': effectiveDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ClientBilling.fromJson(Map<String, dynamic> json) {
    return ClientBilling(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      therapistId: json['therapistId'],
      therapistName: json['therapistName'],
      billingType: BillingType.values.firstWhere((e) => e.name == json['billingType']),
      hourlyRate: json['hourlyRate']?.toDouble() ?? 0.0,
      sessionRate: json['sessionRate']?.toDouble() ?? 0.0,
      packageRate: json['packageRate']?.toDouble() ?? 0.0,
      consultationRate: json['consultationRate']?.toDouble() ?? 0.0,
      customRates: Map<String, dynamic>.from(json['customRates'] ?? {}),
      effectiveDate: DateTime.parse(json['effectiveDate']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      isActive: json['isActive'] ?? true,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String therapistId;
  final String therapistName;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? notes;
  final String? terms;
  final Map<String, dynamic> stripeData;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.therapistId,
    required this.therapistName,
    required this.items,
    required this.subtotal,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.currency = 'TRY',
    this.status = InvoiceStatus.draft,
    required this.issueDate,
    required this.dueDate,
    this.paidDate,
    this.notes,
    this.terms,
    this.stripeData = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != InvoiceStatus.paid;
  bool get isPaid => status == InvoiceStatus.paid;
  int get daysOverdue => isOverdue ? DateTime.now().difference(dueDate).inDays : 0;

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    String? therapistId,
    String? therapistName,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paidDate,
    String? notes,
    String? terms,
    Map<String, dynamic>? stripeData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      therapistId: therapistId ?? this.therapistId,
      therapistName: therapistName ?? this.therapistName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      stripeData: stripeData ?? this.stripeData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'clientName': clientName,
      'therapistId': therapistId,
      'therapistName': therapistName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status.name,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'notes': notes,
      'terms': terms,
      'stripeData': stripeData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      therapistId: json['therapistId'],
      therapistName: json['therapistName'],
      items: (json['items'] as List).map((item) => InvoiceItem.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      taxAmount: json['taxAmount']?.toDouble() ?? 0.0,
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount'].toDouble(),
      currency: json['currency'] ?? 'TRY',
      status: InvoiceStatus.values.firstWhere((e) => e.name == json['status']),
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      notes: json['notes'],
      terms: json['terms'],
      stripeData: Map<String, dynamic>.from(json['stripeData'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? sessionId;
  final DateTime? sessionDate;
  final String? notes;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.sessionId,
    this.sessionDate,
    this.notes,
  });

  InvoiceItem copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? sessionId,
    DateTime? sessionDate,
    String? notes,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      sessionId: sessionId ?? this.sessionId,
      sessionDate: sessionDate ?? this.sessionDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'sessionId': sessionId,
      'sessionDate': sessionDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      sessionId: json['sessionId'],
      sessionDate: json['sessionDate'] != null ? DateTime.parse(json['sessionDate']) : null,
      notes: json['notes'],
    );
  }
}

class Payment {
  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? stripePaymentIntentId;
  final Map<String, dynamic> stripeData;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.amount,
    this.currency = 'TRY',
    this.status = PaymentStatus.pending,
    required this.method,
    this.transactionId,
    this.stripePaymentIntentId,
    this.stripeData = const {},
    required this.paymentDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isSuccessful => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isRefunded => status == PaymentStatus.refunded;

  Payment copyWith({
    String? id,
    String? invoiceId,
    String? invoiceNumber,
    String? clientId,
    String? clientName,
    double? amount,
    String? currency,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionId,
    String? stripePaymentIntentId,
    Map<String, dynamic>? stripeData,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeData: stripeData ?? this.stripeData,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'invoiceNumber': invoiceNumber,
      'clientId': clientId,
      'clientName': clientName,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'method': method.name,
      'transactionId': transactionId,
      'stripePaymentIntentId': stripePaymentIntentId,
      'stripeData': stripeData,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      invoiceId: json['invoiceId'],
      invoiceNumber: json['invoiceNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'TRY',
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
      method: PaymentMethod.values.firstWhere((e) => e.name == json['method']),
      transactionId: json['transactionId'],
      stripePaymentIntentId: json['stripePaymentIntentId'],
      stripeData: Map<String, dynamic>.from(json['stripeData'] ?? {}),
      paymentDate: DateTime.parse(json['paymentDate']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class FinancialMetrics {
  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalRevenue;
  final double totalExpenses;
  final double netIncome;
  final int totalInvoices;
  final int paidInvoices;
  final int overdueInvoices;
  final double averageInvoiceAmount;
  final double collectionRate;
  final Map<String, dynamic> breakdown;
  final List<String> insights;
  final DateTime createdAt;

  FinancialMetrics({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netIncome,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.overdueInvoices,
    required this.averageInvoiceAmount,
    required this.collectionRate,
    this.breakdown = const {},
    this.insights = const [],
    required this.createdAt,
  });

  double get profitMargin => totalRevenue > 0 ? (netIncome / totalRevenue) * 100 : 0.0;
  bool get isProfitable => netIncome > 0;
  int get unpaidInvoices => totalInvoices - paidInvoices;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'netIncome': netIncome,
      'totalInvoices': totalInvoices,
      'paidInvoices': paidInvoices,
      'overdueInvoices': overdueInvoices,
      'averageInvoiceAmount': averageInvoiceAmount,
      'collectionRate': collectionRate,
      'breakdown': breakdown,
      'insights': insights,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) {
    return FinancialMetrics(
      id: json['id'],
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      totalRevenue: json['totalRevenue'].toDouble(),
      totalExpenses: json['totalExpenses'].toDouble(),
      netIncome: json['netIncome'].toDouble(),
      totalInvoices: json['totalInvoices'],
      paidInvoices: json['paidInvoices'],
      overdueInvoices: json['overdueInvoices'],
      averageInvoiceAmount: json['averageInvoiceAmount'].toDouble(),
      collectionRate: json['collectionRate'].toDouble(),
      breakdown: Map<String, dynamic>.from(json['breakdown'] ?? {}),
      insights: List<String>.from(json['insights'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
