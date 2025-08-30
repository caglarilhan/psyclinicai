// Unified manual finance models (no codegen), aligned with FinanceService usage

enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  // Income categories
  sessionFee,
  consultationFee,
  assessmentFee,
  groupTherapyFee,
  emergencyFee,
  insurancePayment,
  otherIncome,
  // Expense categories
  rent,
  utilities,
  equipment,
  supplies,
  marketing,
  insurance,
  professionalFees,
  software,
  maintenance,
  otherExpenses,
}

enum PaymentStatus {
  pending,
  paid,
  overdue,
  cancelled,
  refunded,
}

enum PaymentMethod {
  cash,
  creditCard,
  bankTransfer,
  insurance,
  online,
  check,
}

enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  cancelled,
}

class FinancialTransaction {
  final String id;
  final TransactionType type;
  final TransactionCategory category;
  final double amount;
  final String description;
  final DateTime date;
  final String? clientId;
  final String? therapistId;
  final String? invoiceId;
  final String? receiptId;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.clientId,
    this.therapistId,
    this.invoiceId,
    this.receiptId,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  FinancialTransaction copyWith({
    String? id,
    TransactionType? type,
    TransactionCategory? category,
    double? amount,
    String? description,
    DateTime? date,
    String? clientId,
    String? therapistId,
    String? invoiceId,
    String? receiptId,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      invoiceId: invoiceId ?? this.invoiceId,
      receiptId: receiptId ?? this.receiptId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category.name,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'clientId': clientId,
      'therapistId': therapistId,
      'invoiceId': invoiceId,
      'receiptId': receiptId,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod?.name,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.income,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.otherIncome,
      ),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      clientId: json['clientId'] as String?,
      therapistId: json['therapistId'] as String?,
      invoiceId: json['invoiceId'] as String?,
      receiptId: json['receiptId'] as String?,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            )
          : null,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isPaid => paymentStatus == PaymentStatus.paid;
  bool get isOverdue => paymentStatus == PaymentStatus.overdue;

  String get categoryText {
    switch (category) {
      case TransactionCategory.sessionFee:
        return 'Seans Ücreti';
      case TransactionCategory.consultationFee:
        return 'Konsültasyon Ücreti';
      case TransactionCategory.assessmentFee:
        return 'Değerlendirme Ücreti';
      case TransactionCategory.groupTherapyFee:
        return 'Grup Terapisi Ücreti';
      case TransactionCategory.emergencyFee:
        return 'Acil Durum Ücreti';
      case TransactionCategory.insurancePayment:
        return 'Sigorta Ödemesi';
      case TransactionCategory.otherIncome:
        return 'Diğer Gelir';
      case TransactionCategory.rent:
        return 'Kira';
      case TransactionCategory.utilities:
        return 'Faturalar';
      case TransactionCategory.equipment:
        return 'Ekipman';
      case TransactionCategory.supplies:
        return 'Malzeme';
      case TransactionCategory.marketing:
        return 'Pazarlama';
      case TransactionCategory.insurance:
        return 'Sigorta';
      case TransactionCategory.professionalFees:
        return 'Profesyonel Ücretler';
      case TransactionCategory.software:
        return 'Yazılım';
      case TransactionCategory.maintenance:
        return 'Bakım';
      case TransactionCategory.otherExpenses:
        return 'Diğer Giderler';
    }
  }

  String get paymentStatusText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.paid:
        return 'Ödendi';
      case PaymentStatus.overdue:
        return 'Gecikmiş';
      case PaymentStatus.cancelled:
        return 'İptal Edildi';
      case PaymentStatus.refunded:
        return 'İade Edildi';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Invoice {
  final String id;
  final String clientId;
  final String therapistId;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final String? notes;
  final String? terms;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.currency = 'TRY',
    this.status = InvoiceStatus.draft,
    this.items = const [],
    this.notes,
    this.terms,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Invoice copyWith({
    String? id,
    String? clientId,
    String? therapistId,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    String? currency,
    InvoiceStatus? status,
    List<InvoiceItem>? items,
    String? notes,
    String? terms,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'invoiceNumber': invoiceNumber,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'terms': terms,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      terms: json['terms'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue => status == InvoiceStatus.overdue && DateTime.now().isAfter(dueDate);
  bool get isDraft => status == InvoiceStatus.draft;
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  const InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class FinancialMetrics {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final int totalTransactions;
  final int paidInvoices;
  final int overdueInvoices;
  final double averageTransactionAmount;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlyTrends;

  const FinancialMetrics({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.totalTransactions,
    required this.paidInvoices,
    required this.overdueInvoices,
    required this.averageTransactionAmount,
    required this.categoryBreakdown,
    required this.monthlyTrends,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
      'profitMargin': profitMargin,
      'totalTransactions': totalTransactions,
      'paidInvoices': paidInvoices,
      'overdueInvoices': overdueInvoices,
      'averageTransactionAmount': averageTransactionAmount,
      'categoryBreakdown': categoryBreakdown,
      'monthlyTrends': monthlyTrends,
    };
  }

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) {
    return FinancialMetrics(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      paidInvoices: json['paidInvoices'] as int,
      overdueInvoices: json['overdueInvoices'] as int,
      averageTransactionAmount: (json['averageTransactionAmount'] as num).toDouble(),
      categoryBreakdown: Map<String, double>.from(json['categoryBreakdown'] as Map),
      monthlyTrends: Map<String, double>.from(json['monthlyTrends'] as Map),
    );
  }
}
