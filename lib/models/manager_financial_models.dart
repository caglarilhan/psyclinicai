import 'package:flutter/foundation.dart';

enum TransactionType { income, expense, transfer, adjustment }
enum PaymentStatus { pending, paid, overdue, cancelled, refunded }
enum InvoiceStatus { draft, sent, paid, overdue, cancelled }
enum ExpenseCategory { personnel, rent, equipment, medication, supplies, utilities, marketing, other }
enum IncomeCategory { consultation, therapy, medication, lab, other }

class FinancialTransaction {
  final String id;
  final String description;
  final TransactionType type;
  final double amount;
  final String currency;
  final DateTime transactionDate;
  final String? category;
  final String? patientId;
  final String? doctorId;
  final String? invoiceId;
  final PaymentStatus paymentStatus;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  FinancialTransaction({
    required this.id,
    required this.description,
    required this.type,
    required this.amount,
    this.currency = 'TL',
    required this.transactionDate,
    this.category,
    this.patientId,
    this.doctorId,
    this.invoiceId,
    this.paymentStatus = PaymentStatus.pending,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  FinancialTransaction copyWith({
    String? id,
    String? description,
    TransactionType? type,
    double? amount,
    String? currency,
    DateTime? transactionDate,
    String? category,
    String? patientId,
    String? doctorId,
    String? invoiceId,
    PaymentStatus? paymentStatus,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionDate: transactionDate ?? this.transactionDate,
      category: category ?? this.category,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'category': category,
      'patientId': patientId,
      'doctorId': doctorId,
      'invoiceId': invoiceId,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      category: json['category'] as String?,
      patientId: json['patientId'] as String?,
      doctorId: json['doctorId'] as String?,
      invoiceId: json['invoiceId'] as String?,
      paymentStatus: PaymentStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['paymentStatus'] as String),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String patientId;
  final String doctorId;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  DateTime? paidAt;
  final String? paymentMethod;
  final Map<String, dynamic>? metadata;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    required this.doctorId,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.status = InvoiceStatus.draft,
    this.items = const [],
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.paidAt,
    this.paymentMethod,
    this.metadata,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? patientId,
    String? doctorId,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    InvoiceStatus? status,
    List<InvoiceItem>? items,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'patientId': patientId,
      'doctorId': doctorId,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'metadata': metadata,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: InvoiceStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? category;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.category,
  });

  InvoiceItem copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? category,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'category': category,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      category: json['category'] as String?,
    );
  }
}

class Budget {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double spentAmount;
  final Map<String, double> categoryBudgets;
  final Map<String, double> categorySpent;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Budget({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    this.spentAmount = 0.0,
    this.categoryBudgets = const {},
    this.categorySpent = const {},
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.metadata,
  });

  Budget copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? totalBudget,
    double? spentAmount,
    Map<String, double>? categoryBudgets,
    Map<String, double>? categorySpent,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalBudget: totalBudget ?? this.totalBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      categorySpent: categorySpent ?? this.categorySpent,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalBudget': totalBudget,
      'spentAmount': spentAmount,
      'categoryBudgets': categoryBudgets,
      'categorySpent': categorySpent,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalBudget: (json['totalBudget'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      categoryBudgets: Map<String, double>.from(json['categoryBudgets'] as Map),
      categorySpent: Map<String, double>.from(json['categorySpent'] as Map),
      isActive: json['isActive'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class TaxCalculation {
  final String id;
  final DateTime calculationDate;
  final double totalIncome;
  final double totalExpenses;
  final double taxableIncome;
  final double taxAmount;
  final double socialSecurity;
  final double totalTax;
  final String taxPeriod;
  final Map<String, dynamic>? details;
  final String calculatedBy;
  final DateTime createdAt;

  TaxCalculation({
    required this.id,
    required this.calculationDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.taxableIncome,
    required this.taxAmount,
    required this.socialSecurity,
    required this.totalTax,
    required this.taxPeriod,
    this.details,
    required this.calculatedBy,
    required this.createdAt,
  });

  TaxCalculation copyWith({
    String? id,
    DateTime? calculationDate,
    double? totalIncome,
    double? totalExpenses,
    double? taxableIncome,
    double? taxAmount,
    double? socialSecurity,
    double? totalTax,
    String? taxPeriod,
    Map<String, dynamic>? details,
    String? calculatedBy,
    DateTime? createdAt,
  }) {
    return TaxCalculation(
      id: id ?? this.id,
      calculationDate: calculationDate ?? this.calculationDate,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      taxAmount: taxAmount ?? this.taxAmount,
      socialSecurity: socialSecurity ?? this.socialSecurity,
      totalTax: totalTax ?? this.totalTax,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      details: details ?? this.details,
      calculatedBy: calculatedBy ?? this.calculatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calculationDate': calculationDate.toIso8601String(),
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'taxableIncome': taxableIncome,
      'taxAmount': taxAmount,
      'socialSecurity': socialSecurity,
      'totalTax': totalTax,
      'taxPeriod': taxPeriod,
      'details': details,
      'calculatedBy': calculatedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaxCalculation.fromJson(Map<String, dynamic> json) {
    return TaxCalculation(
      id: json['id'] as String,
      calculationDate: DateTime.parse(json['calculationDate'] as String),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      taxableIncome: (json['taxableIncome'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      socialSecurity: (json['socialSecurity'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      taxPeriod: json['taxPeriod'] as String,
      details: json['details'] as Map<String, dynamic>?,
      calculatedBy: json['calculatedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
