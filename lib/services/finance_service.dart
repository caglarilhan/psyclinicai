import 'dart:math';
import '../models/finance_models.dart';
import '../config/region_config.dart';
import '../services/security_service.dart';
import '../models/security_models.dart';
import '../models/appointment_models.dart';

class FinanceService {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();

  List<FinancialTransaction> _transactions = [];
  List<Invoice> _invoices = [];
  FinancialMetrics? _metrics;

  void initialize() {
    _createDemoData();
    _calculateMetrics();
  }

  void _createDemoData() {
    final now = DateTime.now();
    final random = Random();

    // Demo finansal işlemler
    _transactions = [
      // Gelir işlemleri
      FinancialTransaction(
        id: 'trans_001',
        type: TransactionType.income,
        category: TransactionCategory.sessionFee,
        amount: 450.0,
        description: 'Bireysel terapi seansı - Ahmet Yılmaz',
        date: now.subtract(const Duration(days: 1)),
        clientId: 'client_001',
        therapistId: 'therapist_001',
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Standart seans ücreti',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      FinancialTransaction(
        id: 'trans_002',
        type: TransactionType.income,
        category: TransactionCategory.groupTherapyFee,
        amount: 300.0,
        description: 'Grup terapi seansı - Aile terapisi',
        date: now.subtract(const Duration(days: 2)),
        clientId: 'client_002',
        therapistId: 'therapist_001',
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.bankTransfer,
        notes: 'Grup seansı indirimli ücret',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      FinancialTransaction(
        id: 'trans_003',
        type: TransactionType.income,
        category: TransactionCategory.assessmentFee,
        amount: 800.0,
        description: 'Psikolojik değerlendirme - Zeka testi',
        date: now.subtract(const Duration(days: 3)),
        clientId: 'client_003',
        therapistId: 'therapist_002',
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.cash,
        notes: 'Kapsamlı değerlendirme paketi',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      FinancialTransaction(
        id: 'trans_004',
        type: TransactionType.income,
        category: TransactionCategory.insurancePayment,
        amount: 1200.0,
        description: 'Sigorta ödemesi - Travma tedavisi',
        date: now.subtract(const Duration(days: 5)),
        clientId: 'client_004',
        therapistId: 'therapist_002',
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.insurance,
        notes: 'Sigorta şirketi ödemesi',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      FinancialTransaction(
        id: 'trans_005',
        type: TransactionType.income,
        category: TransactionCategory.emergencyFee,
        amount: 600.0,
        description: 'Acil durum konsültasyonu',
        date: now.subtract(const Duration(days: 7)),
        clientId: 'client_005',
        therapistId: 'therapist_001',
        paymentStatus: PaymentStatus.pending,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Acil durum ek ücreti',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),

      // Gider işlemleri
      FinancialTransaction(
        id: 'trans_006',
        type: TransactionType.expense,
        category: TransactionCategory.rent,
        amount: 2500.0,
        description: 'Ofis kirası - Ocak 2024',
        date: now.subtract(const Duration(days: 10)),
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.bankTransfer,
        notes: 'Aylık ofis kirası',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      FinancialTransaction(
        id: 'trans_007',
        type: TransactionType.expense,
        category: TransactionCategory.utilities,
        amount: 450.0,
        description: 'Elektrik, su, internet faturaları',
        date: now.subtract(const Duration(days: 12)),
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.bankTransfer,
        notes: 'Ocak ayı faturaları',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      FinancialTransaction(
        id: 'trans_008',
        type: TransactionType.expense,
        category: TransactionCategory.equipment,
        amount: 1200.0,
        description: 'Yeni bilgisayar ekipmanları',
        date: now.subtract(const Duration(days: 15)),
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Terapist bilgisayarları',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      FinancialTransaction(
        id: 'trans_009',
        type: TransactionType.expense,
        category: TransactionCategory.software,
        amount: 300.0,
        description: 'Psikoloji yazılım lisansları',
        date: now.subtract(const Duration(days: 18)),
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.creditCard,
        notes: 'Yıllık yazılım lisansları',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(days: 18)),
      ),
      FinancialTransaction(
        id: 'trans_010',
        type: TransactionType.expense,
        category: TransactionCategory.marketing,
        amount: 800.0,
        description: 'Dijital pazarlama kampanyası',
        date: now.subtract(const Duration(days: 20)),
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.bankTransfer,
        notes: 'Google Ads ve sosyal medya',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
    ];

    // Demo faturalar
    _invoices = [
      Invoice(
        id: 'inv_001',
        clientId: 'client_001',
        therapistId: 'therapist_001',
        invoiceNumber: 'INV-2024-001',
        issueDate: now.subtract(const Duration(days: 30)),
        dueDate: now.subtract(const Duration(days: 15)),
        subtotal: 1350.0,
        taxAmount: 135.0,
        totalAmount: 1485.0,
        status: InvoiceStatus.paid,
        items: [
          InvoiceItem(
            id: 'item_001',
            description: 'Bireysel terapi seansları (3x)',
            quantity: 3,
            unitPrice: 450.0,
            totalPrice: 1350.0,
          ),
        ],
        notes: 'Ocak ayı terapi seansları',
        terms: 'Ödeme 15 gün içinde yapılmalıdır',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Invoice(
        id: 'inv_002',
        clientId: 'client_002',
        therapistId: 'therapist_001',
        invoiceNumber: 'INV-2024-002',
        issueDate: now.subtract(const Duration(days: 25)),
        dueDate: now.subtract(const Duration(days: 10)),
        subtotal: 900.0,
        taxAmount: 90.0,
        totalAmount: 990.0,
        status: InvoiceStatus.paid,
        items: [
          InvoiceItem(
            id: 'item_002',
            description: 'Grup terapi seansları (3x)',
            quantity: 3,
            unitPrice: 300.0,
            totalPrice: 900.0,
          ),
        ],
        notes: 'Aile terapisi seansları',
        terms: 'Ödeme 15 gün içinde yapılmalıdır',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Invoice(
        id: 'inv_003',
        clientId: 'client_003',
        therapistId: 'therapist_002',
        invoiceNumber: 'INV-2024-003',
        issueDate: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 5)),
        subtotal: 800.0,
        taxAmount: 80.0,
        totalAmount: 880.0,
        status: InvoiceStatus.overdue,
        items: [
          InvoiceItem(
            id: 'item_003',
            description: 'Psikolojik değerlendirme',
            quantity: 1,
            unitPrice: 800.0,
            totalPrice: 800.0,
          ),
        ],
        notes: 'Kapsamlı psikolojik değerlendirme',
        terms: 'Ödeme 15 gün içinde yapılmalıdır',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      Invoice(
        id: 'inv_004',
        clientId: 'client_004',
        therapistId: 'therapist_002',
        invoiceNumber: 'INV-2024-004',
        issueDate: now.subtract(const Duration(days: 15)),
        dueDate: now.add(const Duration(days: 5)),
        subtotal: 2400.0,
        taxAmount: 240.0,
        totalAmount: 2640.0,
        status: InvoiceStatus.sent,
        items: [
          InvoiceItem(
            id: 'item_004',
            description: 'Travma tedavisi seansları (6x)',
            quantity: 6,
            unitPrice: 400.0,
            totalPrice: 2400.0,
          ),
        ],
        notes: 'TSSB tedavi paketi',
        terms: 'Ödeme 15 gün içinde yapılmalıdır',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Invoice(
        id: 'inv_005',
        clientId: 'client_005',
        therapistId: 'therapist_001',
        invoiceNumber: 'INV-2024-005',
        issueDate: now.subtract(const Duration(days: 10)),
        dueDate: now.add(const Duration(days: 10)),
        subtotal: 600.0,
        taxAmount: 60.0,
        totalAmount: 660.0,
        status: InvoiceStatus.draft,
        items: [
          InvoiceItem(
            id: 'item_005',
            description: 'Acil durum konsültasyonu',
            quantity: 1,
            unitPrice: 600.0,
            totalPrice: 600.0,
          ),
        ],
        notes: 'Acil durum değerlendirmesi',
        terms: 'Ödeme 15 gün içinde yapılmalıdır',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  void _calculateMetrics() {
    final totalIncome = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final netProfit = totalIncome - totalExpenses;
    final profitMargin = totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0.0;
    
    final totalTransactions = _transactions.length;
    final paidInvoices = _invoices.where((i) => i.isPaid).length;
    final overdueInvoices = _invoices.where((i) => i.isOverdue).length;
    
    final averageTransactionAmount = totalTransactions > 0 
        ? _transactions.fold(0.0, (sum, t) => sum + t.amount) / totalTransactions 
        : 0.0;

    // Kategori bazında dağılım
    final categoryBreakdown = <String, double>{};
    for (final transaction in _transactions) {
      final category = transaction.categoryText;
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0.0) + transaction.amount;
    }

    // Aylık trendler (son 6 ay)
    final monthlyTrends = <String, double>{};
    final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran'];
    for (final month in months) {
      monthlyTrends[month] = 2000 + (months.indexOf(month) * 500); // Demo veri
    }

    _metrics = FinancialMetrics(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      profitMargin: profitMargin,
      totalTransactions: totalTransactions,
      paidInvoices: paidInvoices,
      overdueInvoices: overdueInvoices,
      averageTransactionAmount: averageTransactionAmount,
      categoryBreakdown: categoryBreakdown,
      monthlyTrends: monthlyTrends,
    );
  }

  // Bölgesel para birimi sembolü
  String get currencySymbol => RegionConfig.currency;

  // Vergi oranı
  double get taxRate => RegionConfig.taxRate;

  // Finansal işlemler
  List<FinancialTransaction> getAllTransactions() => List.unmodifiable(_transactions);
  
  FinancialTransaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<FinancialTransaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<FinancialTransaction> getTransactionsByCategory(TransactionCategory category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<FinancialTransaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
        t.date.isAfter(start.subtract(const Duration(days: 1))) && 
        t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  FinancialTransaction addTransaction(FinancialTransaction transaction) {
    final newTransaction = transaction.copyWith(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _transactions.add(newTransaction);
    _calculateMetrics();
    // Audit log
    SecurityService().addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'system',
        userName: 'System',
        action: 'Finansal işlem oluşturuldu: ${newTransaction.description}',
        type: AuditLogType.dataModification,
        timestamp: DateTime.now(),
        resourceId: newTransaction.id,
        resourceType: 'financial_transaction',
      ),
    );
    return newTransaction;
  }

  FinancialTransaction? updateTransaction(String id, FinancialTransaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final transaction = updatedTransaction.copyWith(
        updatedAt: DateTime.now(),
      );
      _transactions[index] = transaction;
      _calculateMetrics();
      return transaction;
    }
    return null;
  }

  bool deleteTransaction(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions.removeAt(index);
      _calculateMetrics();
      return true;
    }
    return false;
  }

  // Faturalar
  List<Invoice> getAllInvoices() => List.unmodifiable(_invoices);
  
  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Invoice> getInvoicesByStatus(InvoiceStatus status) {
    return _invoices.where((i) => i.status == status).toList();
  }

  List<Invoice> getInvoicesByClient(String clientId) {
    return _invoices.where((i) => i.clientId == clientId).toList();
  }

  List<Invoice> getOverdueInvoices() {
    return _invoices.where((i) => i.isOverdue).toList();
  }

  Invoice addInvoice(Invoice invoice) {
    // Vergi yoksa bölgesel vergi oranını uygula
    final autoSubtotal = invoice.subtotal;
    final autoTax = invoice.taxAmount == 0.0 ? (autoSubtotal * taxRate) : invoice.taxAmount;
    final autoTotal = invoice.totalAmount == 0.0 ? (autoSubtotal + autoTax) : invoice.totalAmount;

    final newInvoice = invoice.copyWith(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      subtotal: autoSubtotal,
      taxAmount: autoTax,
      totalAmount: autoTotal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _invoices.add(newInvoice);
    _calculateMetrics();
    // Audit log
    SecurityService().addAuditLog(
      AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'system',
        userName: 'System',
        action: 'Fatura oluşturuldu: ${newInvoice.invoiceNumber}',
        type: AuditLogType.dataModification,
        timestamp: DateTime.now(),
        resourceId: newInvoice.id,
        resourceType: 'invoice',
      ),
    );
    return newInvoice;
  }

  Invoice? updateInvoice(String id, Invoice updatedInvoice) {
    final index = _invoices.indexWhere((i) => i.id == id);
    if (index != -1) {
      final invoice = updatedInvoice.copyWith(
        updatedAt: DateTime.now(),
      );
      _invoices[index] = invoice;
      _calculateMetrics();
      return invoice;
    }
    return null;
  }

  bool deleteInvoice(String id) {
    final index = _invoices.indexWhere((i) => i.id == id);
    if (index != -1) {
      _invoices.removeAt(index);
      _calculateMetrics();
      return true;
    }
    return false;
  }

  // Metrikler
  FinancialMetrics? getMetrics() => _metrics;

  // Arama ve filtreleme
  List<FinancialTransaction> searchTransactions(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _transactions.where((t) {
      // Basit maskeleme: clientId son 4 karakter hariç maskelenir
      final maskedClient = (t.clientId == null)
          ? ''
          : t.clientId!.replaceAll(RegExp('.(?=.{4})'), '*');
      final haystack = [
        t.description,
        t.categoryText,
        maskedClient,
        t.notes ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(lowercaseQuery);
    }).toList();
  }

  List<Invoice> searchInvoices(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _invoices.where((i) {
      return i.invoiceNumber.toLowerCase().contains(lowercaseQuery) ||
          i.clientId.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Raporlar
  Map<String, dynamic> getIncomeExpenseReport(DateTime start, DateTime end) {
    final transactions = getTransactionsByDateRange(start, end);
    
    final income = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expenses = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final net = income - expenses;
    
    return {
      'period': '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
      'income': income,
      'expenses': expenses,
      'net': net,
      'transactionCount': transactions.length,
    };
  }

  Map<String, dynamic> getCategoryReport() {
    final categoryTotals = <String, double>{};
    
    for (final transaction in _transactions) {
      final category = transaction.categoryText;
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + transaction.amount;
    }
    
    return categoryTotals;
  }

  // Tamamlanan randevudan otomatik gelir ve fatura oluştur
  Map<String, dynamic> createFromAppointment({
    required Appointment appointment,
    double? amount,
  }) {
    // Tutarı randevu tipine göre basitçe belirle (demo)
    final double baseAmount = amount ?? _defaultAmountForType(appointment.type);

    final txn = addTransaction(
      FinancialTransaction(
        id: 'new',
        type: TransactionType.income,
        category: _categoryForType(appointment.type),
        amount: baseAmount,
        description: '${appointment.title} - ${appointment.clientName}',
        date: DateTime.now(),
        clientId: appointment.clientName,
        therapistId: appointment.therapistId,
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.creditCard,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final inv = addInvoice(
      Invoice(
        id: 'new',
        clientId: appointment.clientName,
        therapistId: appointment.therapistId ?? 'unknown',
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        subtotal: baseAmount,
        taxAmount: 0.0, // RegionConfig üzerinden auto hesaplanır
        totalAmount: 0.0,
        status: InvoiceStatus.sent,
        items: [
          InvoiceItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
            description: appointment.title,
            quantity: 1,
            unitPrice: baseAmount,
            totalPrice: baseAmount,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return {
      'transaction': txn,
      'invoice': inv,
    };
  }

  double _defaultAmountForType(AppointmentType type) {
    switch (type) {
      case AppointmentType.individual:
        return 450.0;
      case AppointmentType.group:
        return 300.0;
      case AppointmentType.emergency:
        return 600.0;
      case AppointmentType.followUp:
        return 350.0;
      default:
        return 400.0;
    }
  }

  TransactionCategory _categoryForType(AppointmentType type) {
    switch (type) {
      case AppointmentType.individual:
        return TransactionCategory.sessionFee;
      case AppointmentType.group:
        return TransactionCategory.groupTherapyFee;
      case AppointmentType.emergency:
        return TransactionCategory.emergencyFee;
      case AppointmentType.followUp:
        return TransactionCategory.consultationFee;
      default:
        return TransactionCategory.otherIncome;
    }
  }

  // Vadesi yaklaşan/geçmiş faturalara hatırlatma (basit metin listesi)
  List<String> getInvoiceReminders({int daysThreshold = 3}) {
    final now = DateTime.now();
    final reminders = <String>[];
    for (final i in _invoices) {
      final daysLeft = i.dueDate.difference(now).inDays;
      if ((i.status == InvoiceStatus.sent || i.status == InvoiceStatus.overdue) && daysLeft <= daysThreshold) {
        reminders.add('Fatura ${i.invoiceNumber} için ödeme hatırlatması: Müşteri ${i.clientId}, Tutar ${currencySymbol}${i.totalAmount.toStringAsFixed(2)}, Vade ${i.dueDate.toIso8601String()}');
        // CRM entegrasyonu için audit log
        SecurityService().addAuditLog(
          AuditLog(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            action: 'Ödeme hatırlatıcısı üretildi: ${i.invoiceNumber}',
            type: AuditLogType.dataAccess,
            timestamp: DateTime.now(),
            resourceId: i.id,
            resourceType: 'invoice',
          ),
        );
      }
    }
    return reminders;
  }

  // Veri temizleme
  void clearAllData() {
    _transactions.clear();
    _invoices.clear();
    _metrics = null;
  }
}
