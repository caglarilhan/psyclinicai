// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Income _$IncomeFromJson(Map<String, dynamic> json) => Income(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  type: $enumDecode(_$IncomeTypeEnumMap, json['type']),
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String,
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  invoiceId: json['invoiceId'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  transactionId: json['transactionId'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$IncomeToJson(Income instance) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'amount': instance.amount,
  'currency': instance.currency,
  'type': _$IncomeTypeEnumMap[instance.type]!,
  'date': instance.date.toIso8601String(),
  'description': instance.description,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'invoiceId': instance.invoiceId,
  'paymentMethod': instance.paymentMethod,
  'transactionId': instance.transactionId,
  'metadata': instance.metadata,
};

const _$IncomeTypeEnumMap = {
  IncomeType.sessionFee: 'sessionFee',
  IncomeType.consultationFee: 'consultationFee',
  IncomeType.assessmentFee: 'assessmentFee',
  IncomeType.reportFee: 'reportFee',
  IncomeType.medicationFee: 'medicationFee',
  IncomeType.emergencyFee: 'emergencyFee',
  IncomeType.lateCancellationFee: 'lateCancellationFee',
  IncomeType.noShowFee: 'noShowFee',
  IncomeType.other: 'other',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.disputed: 'disputed',
};

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  type: $enumDecode(_$ExpenseTypeEnumMap, json['type']),
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String,
  status: $enumDecode(_$ExpenseStatusEnumMap, json['status']),
  receiptId: json['receiptId'] as String?,
  category: json['category'] as String?,
  isReimbursable: json['isReimbursable'] as bool,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'therapistId': instance.therapistId,
  'amount': instance.amount,
  'currency': instance.currency,
  'type': _$ExpenseTypeEnumMap[instance.type]!,
  'date': instance.date.toIso8601String(),
  'description': instance.description,
  'status': _$ExpenseStatusEnumMap[instance.status]!,
  'receiptId': instance.receiptId,
  'category': instance.category,
  'isReimbursable': instance.isReimbursable,
  'metadata': instance.metadata,
};

const _$ExpenseTypeEnumMap = {
  ExpenseType.officeRent: 'officeRent',
  ExpenseType.utilities: 'utilities',
  ExpenseType.insurance: 'insurance',
  ExpenseType.software: 'software',
  ExpenseType.marketing: 'marketing',
  ExpenseType.training: 'training',
  ExpenseType.travel: 'travel',
  ExpenseType.supplies: 'supplies',
  ExpenseType.legal: 'legal',
  ExpenseType.accounting: 'accounting',
  ExpenseType.other: 'other',
};

const _$ExpenseStatusEnumMap = {
  ExpenseStatus.pending: 'pending',
  ExpenseStatus.approved: 'approved',
  ExpenseStatus.rejected: 'rejected',
  ExpenseStatus.paid: 'paid',
  ExpenseStatus.cancelled: 'cancelled',
};

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: (json['subtotal'] as num).toDouble(),
  taxAmount: (json['taxAmount'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  issueDate: DateTime.parse(json['issueDate'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  status: $enumDecode(_$InvoiceStatusEnumMap, json['status']),
  notes: json['notes'] as String?,
  paymentTerms: json['paymentTerms'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'items': instance.items,
  'subtotal': instance.subtotal,
  'taxAmount': instance.taxAmount,
  'totalAmount': instance.totalAmount,
  'currency': instance.currency,
  'issueDate': instance.issueDate.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'paymentTerms': instance.paymentTerms,
  'metadata': instance.metadata,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.viewed: 'viewed',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
  InvoiceStatus.disputed: 'disputed',
};

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => InvoiceItem(
  description: json['description'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  serviceCode: json['serviceCode'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'serviceCode': instance.serviceCode,
      'category': instance.category,
    };

FinancialReport _$FinancialReportFromJson(Map<String, dynamic> json) =>
    FinancialReport(
      id: json['id'] as String,
      therapistId: json['therapistId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      currency: json['currency'] as String,
      incomes: (json['incomes'] as List<dynamic>)
          .map((e) => Income.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      incomeByCategory: (json['incomeByCategory'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      expenseByCategory: (json['expenseByCategory'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      monthlyTrends: (json['monthlyTrends'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => FinancialAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FinancialReportToJson(FinancialReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'therapistId': instance.therapistId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalIncome': instance.totalIncome,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
      'currency': instance.currency,
      'incomes': instance.incomes,
      'expenses': instance.expenses,
      'incomeByCategory': instance.incomeByCategory,
      'expenseByCategory': instance.expenseByCategory,
      'monthlyTrends': instance.monthlyTrends,
      'alerts': instance.alerts,
    };

FinancialAlert _$FinancialAlertFromJson(Map<String, dynamic> json) =>
    FinancialAlert(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FinancialAlertToJson(FinancialAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'isResolved': instance.isResolved,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
      'metadata': instance.metadata,
    };

const _$AlertTypeEnumMap = {
  AlertType.lowBalance: 'lowBalance',
  AlertType.overdueInvoice: 'overdueInvoice',
  AlertType.highExpense: 'highExpense',
  AlertType.unusualActivity: 'unusualActivity',
  AlertType.taxDeadline: 'taxDeadline',
  AlertType.insuranceExpiry: 'insuranceExpiry',
  AlertType.budgetExceeded: 'budgetExceeded',
  AlertType.other: 'other',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
  id: json['id'] as String,
  therapistId: json['therapistId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: $enumDecode(_$BudgetStatusEnumMap, json['status']),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'id': instance.id,
  'therapistId': instance.therapistId,
  'name': instance.name,
  'description': instance.description,
  'totalAmount': instance.totalAmount,
  'currency': instance.currency,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'categories': instance.categories,
  'status': _$BudgetStatusEnumMap[instance.status]!,
  'metadata': instance.metadata,
};

const _$BudgetStatusEnumMap = {
  BudgetStatus.active: 'active',
  BudgetStatus.completed: 'completed',
  BudgetStatus.cancelled: 'cancelled',
  BudgetStatus.draft: 'draft',
};

BudgetCategory _$BudgetCategoryFromJson(Map<String, dynamic> json) =>
    BudgetCategory(
      name: json['name'] as String,
      allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      percentageUsed: (json['percentageUsed'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetCategoryToJson(BudgetCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'allocatedAmount': instance.allocatedAmount,
      'spentAmount': instance.spentAmount,
      'remainingAmount': instance.remainingAmount,
      'percentageUsed': instance.percentageUsed,
    };

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      id: json['id'] as String,
      therapistId: json['therapistId'] as String,
      type: $enumDecode(_$PaymentMethodTypeEnumMap, json['type']),
      name: json['name'] as String,
      last4Digits: json['last4Digits'] as String?,
      expiryDate: json['expiryDate'] as String?,
      isDefault: json['isDefault'] as bool,
      isActive: json['isActive'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'therapistId': instance.therapistId,
      'type': _$PaymentMethodTypeEnumMap[instance.type]!,
      'name': instance.name,
      'last4Digits': instance.last4Digits,
      'expiryDate': instance.expiryDate,
      'isDefault': instance.isDefault,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

const _$PaymentMethodTypeEnumMap = {
  PaymentMethodType.creditCard: 'creditCard',
  PaymentMethodType.debitCard: 'debitCard',
  PaymentMethodType.bankTransfer: 'bankTransfer',
  PaymentMethodType.paypal: 'paypal',
  PaymentMethodType.stripe: 'stripe',
  PaymentMethodType.applePay: 'applePay',
  PaymentMethodType.googlePay: 'googlePay',
  PaymentMethodType.other: 'other',
};

PaymentTransaction _$PaymentTransactionFromJson(Map<String, dynamic> json) =>
    PaymentTransaction(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethod: $enumDecode(
        _$PaymentMethodTypeEnumMap,
        json['paymentMethod'],
      ),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      transactionId: json['transactionId'] as String?,
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentTransactionToJson(PaymentTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'amount': instance.amount,
      'currency': instance.currency,
      'paymentMethod': _$PaymentMethodTypeEnumMap[instance.paymentMethod]!,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'transactionId': instance.transactionId,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.processing: 'processing',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
  TransactionStatus.refunded: 'refunded',
  TransactionStatus.disputed: 'disputed',
};
