import 'package:json_annotation/json_annotation.dart';

part 'finance_models.g.dart';

// ===== GELİR MODELLERİ =====

@JsonSerializable()
class Income {
  final String id;
  final String clientId;
  final String therapistId;
  final double amount;
  final String currency;
  final IncomeType type;
  final DateTime date;
  final String description;
  final PaymentStatus status;
  final String? invoiceId;
  final String? paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? metadata;

  const Income({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.date,
    required this.description,
    required this.status,
    this.invoiceId,
    this.paymentMethod,
    this.transactionId,
    this.metadata,
  });

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
  Map<String, dynamic> toJson() => _$IncomeToJson(this);
}

enum IncomeType {
  sessionFee,
  consultationFee,
  assessmentFee,
  reportFee,
  medicationFee,
  emergencyFee,
  lateCancellationFee,
  noShowFee,
  other
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
  cancelled,
  disputed
}

// ===== GİDER MODELLERİ =====

@JsonSerializable()
class Expense {
  final String id;
  final String therapistId;
  final double amount;
  final String currency;
  final ExpenseType type;
  final DateTime date;
  final String description;
  final ExpenseStatus status;
  final String? receiptId;
  final String? category;
  final bool isReimbursable;
  final Map<String, dynamic>? metadata;

  const Expense({
    required this.id,
    required this.therapistId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.date,
    required this.description,
    required this.status,
    this.receiptId,
    this.category,
    required this.isReimbursable,
    this.metadata,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

enum ExpenseType {
  officeRent,
  utilities,
  insurance,
  software,
  marketing,
  training,
  travel,
  supplies,
  legal,
  accounting,
  other
}

enum ExpenseStatus {
  pending,
  approved,
  rejected,
  paid,
  cancelled
}

// ===== FATURA MODELLERİ =====

@JsonSerializable()
class Invoice {
  final String id;
  final String clientId;
  final String therapistId;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final String? notes;
  final String? paymentTerms;
  final Map<String, dynamic>? metadata;

  const Invoice({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    this.notes,
    this.paymentTerms,
    this.metadata,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}

@JsonSerializable()
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? serviceCode;
  final String? category;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.serviceCode,
    this.category,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemToJson(this);
}

enum InvoiceStatus {
  draft,
  sent,
  viewed,
  paid,
  overdue,
  cancelled,
  disputed
}

// ===== FİNANSAL RAPORLAR =====

@JsonSerializable()
class FinancialReport {
  final String id;
  final String therapistId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final String currency;
  final List<Income> incomes;
  final List<Expense> expenses;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expenseByCategory;
  final Map<String, double> monthlyTrends;
  final List<FinancialAlert> alerts;

  const FinancialReport({
    required this.id,
    required this.therapistId,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.currency,
    required this.incomes,
    required this.expenses,
    required this.incomeByCategory,
    required this.expenseByCategory,
    required this.monthlyTrends,
    required this.alerts,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) => _$FinancialReportFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialReportToJson(this);
}

@JsonSerializable()
class FinancialAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final Map<String, dynamic>? metadata;

  const FinancialAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isResolved,
    this.resolvedAt,
    this.resolvedBy,
    this.metadata,
  });

  factory FinancialAlert.fromJson(Map<String, dynamic> json) => _$FinancialAlertFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialAlertToJson(this);
}

enum AlertType {
  lowBalance,
  overdueInvoice,
  highExpense,
  unusualActivity,
  taxDeadline,
  insuranceExpiry,
  budgetExceeded,
  other
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical
}

// ===== BÜTÇE YÖNETİMİ =====

@JsonSerializable()
class Budget {
  final String id;
  final String therapistId;
  final String name;
  final String description;
  final double totalAmount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final List<BudgetCategory> categories;
  final BudgetStatus status;
  final Map<String, dynamic>? metadata;

  const Budget({
    required this.id,
    required this.therapistId,
    required this.name,
    required this.description,
    required this.totalAmount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.status,
    this.metadata,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}

@JsonSerializable()
class BudgetCategory {
  final String name;
  final double allocatedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;

  const BudgetCategory({
    required this.name,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => _$BudgetCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetCategoryToJson(this);
}

enum BudgetStatus {
  active,
  completed,
  cancelled,
  draft
}

// ===== ÖDEME ENTEGRASYONU =====

@JsonSerializable()
class PaymentMethod {
  final String id;
  final String therapistId;
  final PaymentMethodType type;
  final String name;
  final String? last4Digits;
  final String? expiryDate;
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const PaymentMethod({
    required this.id,
    required this.therapistId,
    required this.type,
    required this.name,
    this.last4Digits,
    this.expiryDate,
    required this.isDefault,
    required this.isActive,
    this.metadata,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

enum PaymentMethodType {
  creditCard,
  debitCard,
  bankTransfer,
  paypal,
  stripe,
  applePay,
  googlePay,
  other
}

@JsonSerializable()
class PaymentTransaction {
  final String id;
  final String invoiceId;
  final String clientId;
  final String therapistId;
  final double amount;
  final String currency;
  final PaymentMethodType paymentMethod;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const PaymentTransaction({
    required this.id,
    required this.invoiceId,
    required this.clientId,
    required this.therapistId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.errorMessage,
    this.metadata,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) => _$PaymentTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentTransactionToJson(this);
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  disputed
}
