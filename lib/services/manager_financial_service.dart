import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manager_financial_models.dart';

class ManagerFinancialService {
  static final ManagerFinancialService _instance = ManagerFinancialService._internal();
  factory ManagerFinancialService() => _instance;
  ManagerFinancialService._internal();

  final List<FinancialTransaction> _transactions = [];
  final List<Invoice> _invoices = [];
  final List<Budget> _budgets = [];
  final List<TaxCalculation> _taxCalculations = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadTransactions();
    await _loadInvoices();
    await _loadBudgets();
    await _loadTaxCalculations();
  }

  // Load transactions from storage
  Future<void> _loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList('manager_financial_transactions') ?? [];
      _transactions.clear();
      
      for (final transactionJson in transactionsJson) {
        final transaction = FinancialTransaction.fromJson(jsonDecode(transactionJson));
        _transactions.add(transaction);
      }
    } catch (e) {
      print('Error loading financial transactions: $e');
      _transactions.clear();
    }
  }

  // Save transactions to storage
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = _transactions
          .map((transaction) => jsonEncode(transaction.toJson()))
          .toList();
      await prefs.setStringList('manager_financial_transactions', transactionsJson);
    } catch (e) {
      print('Error saving financial transactions: $e');
    }
  }

  // Load invoices from storage
  Future<void> _loadInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = prefs.getStringList('manager_financial_invoices') ?? [];
      _invoices.clear();
      
      for (final invoiceJson in invoicesJson) {
        final invoice = Invoice.fromJson(jsonDecode(invoiceJson));
        _invoices.add(invoice);
      }
    } catch (e) {
      print('Error loading invoices: $e');
      _invoices.clear();
    }
  }

  // Save invoices to storage
  Future<void> _saveInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesJson = _invoices
          .map((invoice) => jsonEncode(invoice.toJson()))
          .toList();
      await prefs.setStringList('manager_financial_invoices', invoicesJson);
    } catch (e) {
      print('Error saving invoices: $e');
    }
  }

  // Load budgets from storage
  Future<void> _loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getStringList('manager_financial_budgets') ?? [];
      _budgets.clear();
      
      for (final budgetJson in budgetsJson) {
        final budget = Budget.fromJson(jsonDecode(budgetJson));
        _budgets.add(budget);
      }
    } catch (e) {
      print('Error loading budgets: $e');
      _budgets.clear();
    }
  }

  // Save budgets to storage
  Future<void> _saveBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = _budgets
          .map((budget) => jsonEncode(budget.toJson()))
          .toList();
      await prefs.setStringList('manager_financial_budgets', budgetsJson);
    } catch (e) {
      print('Error saving budgets: $e');
    }
  }

  // Load tax calculations from storage
  Future<void> _loadTaxCalculations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taxCalculationsJson = prefs.getStringList('manager_financial_tax_calculations') ?? [];
      _taxCalculations.clear();
      
      for (final taxCalculationJson in taxCalculationsJson) {
        final taxCalculation = TaxCalculation.fromJson(jsonDecode(taxCalculationJson));
        _taxCalculations.add(taxCalculation);
      }
    } catch (e) {
      print('Error loading tax calculations: $e');
      _taxCalculations.clear();
    }
  }

  // Save tax calculations to storage
  Future<void> _saveTaxCalculations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taxCalculationsJson = _taxCalculations
          .map((taxCalculation) => jsonEncode(taxCalculation.toJson()))
          .toList();
      await prefs.setStringList('manager_financial_tax_calculations', taxCalculationsJson);
    } catch (e) {
      print('Error saving tax calculations: $e');
    }
  }

  // Add transaction
  Future<FinancialTransaction> addTransaction({
    required String description,
    required TransactionType type,
    required double amount,
    String currency = 'TL',
    required DateTime transactionDate,
    String? category,
    String? patientId,
    String? doctorId,
    String? invoiceId,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    String? notes,
    required String createdBy,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = FinancialTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      type: type,
      amount: amount,
      currency: currency,
      transactionDate: transactionDate,
      category: category,
      patientId: patientId,
      doctorId: doctorId,
      invoiceId: invoiceId,
      paymentStatus: paymentStatus,
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _transactions.add(transaction);
    await _saveTransactions();

    return transaction;
  }

  // Update transaction
  Future<bool> updateTransaction(FinancialTransaction updatedTransaction, String updatedBy) async {
    try {
      final index = _transactions.indexWhere((transaction) => transaction.id == updatedTransaction.id);
      if (index == -1) return false;

      _transactions[index] = updatedTransaction.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _saveTransactions();
      return true;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      final index = _transactions.indexWhere((transaction) => transaction.id == transactionId);
      if (index == -1) return false;

      _transactions.removeAt(index);
      await _saveTransactions();

      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  // Create invoice
  Future<Invoice> createInvoice({
    required String patientId,
    required String doctorId,
    required DateTime issueDate,
    required DateTime dueDate,
    required List<InvoiceItem> items,
    String? notes,
    required String createdBy,
    Map<String, dynamic>? metadata,
  }) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final taxAmount = subtotal * 0.18; // %18 KDV
    final totalAmount = subtotal + taxAmount;

    final invoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      doctorId: doctorId,
      issueDate: issueDate,
      dueDate: dueDate,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      items: items,
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _invoices.add(invoice);
    await _saveInvoices();

    return invoice;
  }

  // Update invoice
  Future<bool> updateInvoice(Invoice updatedInvoice) async {
    try {
      final index = _invoices.indexWhere((invoice) => invoice.id == updatedInvoice.id);
      if (index == -1) return false;

      _invoices[index] = updatedInvoice;
      await _saveInvoices();

      return true;
    } catch (e) {
      print('Error updating invoice: $e');
      return false;
    }
  }

  // Mark invoice as paid
  Future<bool> markInvoiceAsPaid(String invoiceId, String paymentMethod) async {
    try {
      final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
      if (index == -1) return false;

      _invoices[index] = _invoices[index].copyWith(
        status: InvoiceStatus.paid,
        paidAt: DateTime.now(),
        paymentMethod: paymentMethod,
      );

      await _saveInvoices();
      return true;
    } catch (e) {
      print('Error marking invoice as paid: $e');
      return false;
    }
  }

  // Create budget
  Future<Budget> createBudget({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required double totalBudget,
    Map<String, double>? categoryBudgets,
    required String createdBy,
    Map<String, dynamic>? metadata,
  }) async {
    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      totalBudget: totalBudget,
      categoryBudgets: categoryBudgets ?? {},
      createdBy: createdBy,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _budgets.add(budget);
    await _saveBudgets();

    return budget;
  }

  // Update budget
  Future<bool> updateBudget(Budget updatedBudget) async {
    try {
      final index = _budgets.indexWhere((budget) => budget.id == updatedBudget.id);
      if (index == -1) return false;

      _budgets[index] = updatedBudget;
      await _saveBudgets();

      return true;
    } catch (e) {
      print('Error updating budget: $e');
      return false;
    }
  }

  // Calculate tax
  Future<TaxCalculation> calculateTax({
    required DateTime calculationDate,
    required String taxPeriod,
    required String calculatedBy,
  }) async {
    final startDate = DateTime(calculationDate.year, calculationDate.month, 1);
    final endDate = DateTime(calculationDate.year, calculationDate.month + 1, 0);

    final incomeTransactions = _transactions.where((t) => 
        t.type == TransactionType.income &&
        t.transactionDate.isAfter(startDate) &&
        t.transactionDate.isBefore(endDate)).toList();

    final expenseTransactions = _transactions.where((t) => 
        t.type == TransactionType.expense &&
        t.transactionDate.isAfter(startDate) &&
        t.transactionDate.isBefore(endDate)).toList();

    final totalIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final taxableIncome = totalIncome - totalExpenses;
    
    // Basit vergi hesaplama (gerçek hesaplama daha karmaşık olacak)
    final taxAmount = taxableIncome * 0.20; // %20 gelir vergisi
    final socialSecurity = totalIncome * 0.15; // %15 SGK primi
    final totalTax = taxAmount + socialSecurity;

    final taxCalculation = TaxCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      calculationDate: calculationDate,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      taxableIncome: taxableIncome,
      taxAmount: taxAmount,
      socialSecurity: socialSecurity,
      totalTax: totalTax,
      taxPeriod: taxPeriod,
      calculatedBy: calculatedBy,
      createdAt: DateTime.now(),
      details: {
        'incomeTransactions': incomeTransactions.length,
        'expenseTransactions': expenseTransactions.length,
        'taxRate': 0.20,
        'socialSecurityRate': 0.15,
      },
    );

    _taxCalculations.add(taxCalculation);
    await _saveTaxCalculations();

    return taxCalculation;
  }

  // Get transactions by type
  List<FinancialTransaction> getTransactionsByType(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  // Get transactions by date range
  List<FinancialTransaction> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return _transactions
        .where((transaction) => 
            transaction.transactionDate.isAfter(startDate) &&
            transaction.transactionDate.isBefore(endDate))
        .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  // Get transactions by category
  List<FinancialTransaction> getTransactionsByCategory(String category) {
    return _transactions
        .where((transaction) => transaction.category == category)
        .toList()
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  // Get invoices by status
  List<Invoice> getInvoicesByStatus(InvoiceStatus status) {
    return _invoices
        .where((invoice) => invoice.status == status)
        .toList()
        ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
  }

  // Get overdue invoices
  List<Invoice> getOverdueInvoices() {
    final now = DateTime.now();
    return _invoices
        .where((invoice) => 
            invoice.status != InvoiceStatus.paid &&
            invoice.dueDate.isBefore(now))
        .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get active budgets
  List<Budget> getActiveBudgets() {
    return _budgets
        .where((budget) => budget.isActive)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get current budget
  Budget? getCurrentBudget() {
    final now = DateTime.now();
    return _budgets
        .where((budget) => 
            budget.isActive &&
            budget.startDate.isBefore(now) &&
            budget.endDate.isAfter(now))
        .firstOrNull;
  }

  // Get financial summary
  Map<String, dynamic> getFinancialSummary() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyTransactions = getTransactionsByDateRange(currentMonth, nextMonth);
    final monthlyIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthlyExpenses = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final pendingInvoices = _invoices
        .where((i) => i.status == InvoiceStatus.sent)
        .length;
    final overdueInvoices = getOverdueInvoices().length;

    final currentBudget = getCurrentBudget();
    final budgetUtilization = currentBudget != null 
        ? (currentBudget.spentAmount / currentBudget.totalBudget) * 100
        : 0.0;

    return {
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'monthlyProfit': monthlyIncome - monthlyExpenses,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalProfit': totalIncome - totalExpenses,
      'pendingInvoices': pendingInvoices,
      'overdueInvoices': overdueInvoices,
      'budgetUtilization': budgetUtilization,
      'totalTransactions': _transactions.length,
      'totalInvoices': _invoices.length,
      'activeBudgets': _budgets.where((b) => b.isActive).length,
    };
  }

  // Get category analysis
  Map<String, dynamic> getCategoryAnalysis() {
    final incomeByCategory = <String, double>{};
    final expenseByCategory = <String, double>{};

    for (final transaction in _transactions) {
      if (transaction.category != null) {
        if (transaction.type == TransactionType.income) {
          incomeByCategory[transaction.category!] = 
              (incomeByCategory[transaction.category!] ?? 0) + transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          expenseByCategory[transaction.category!] = 
              (expenseByCategory[transaction.category!] ?? 0) + transaction.amount;
        }
      }
    }

    return {
      'incomeByCategory': incomeByCategory,
      'expenseByCategory': expenseByCategory,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_transactions.isNotEmpty) return;

    // Add demo transactions
    final demoTransactions = [
      FinancialTransaction(
        id: 'trans_001',
        description: 'Konsültasyon ücreti',
        type: TransactionType.income,
        amount: 500.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        category: 'consultation',
        patientId: '1',
        doctorId: 'doctor_001',
        paymentStatus: PaymentStatus.paid,
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FinancialTransaction(
        id: 'trans_002',
        description: 'Personel maaşı',
        type: TransactionType.expense,
        amount: 15000.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        category: 'personnel',
        paymentStatus: PaymentStatus.paid,
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FinancialTransaction(
        id: 'trans_003',
        description: 'Kira ödemesi',
        type: TransactionType.expense,
        amount: 5000.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 3)),
        category: 'rent',
        paymentStatus: PaymentStatus.paid,
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    for (final transaction in demoTransactions) {
      _transactions.add(transaction);
    }

    await _saveTransactions();

    // Add demo invoices
    final demoInvoices = [
      Invoice(
        id: 'inv_001',
        invoiceNumber: 'INV-2024-001',
        patientId: '1',
        doctorId: 'doctor_001',
        issueDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 25)),
        subtotal: 500.0,
        taxAmount: 90.0,
        totalAmount: 590.0,
        status: InvoiceStatus.sent,
        items: [
          InvoiceItem(
            id: 'item_001',
            description: 'Konsültasyon',
            quantity: 1,
            unitPrice: 500.0,
            totalPrice: 500.0,
            category: 'consultation',
          ),
        ],
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    for (final invoice in demoInvoices) {
      _invoices.add(invoice);
    }

    await _saveInvoices();

    // Add demo budget
    final demoBudget = Budget(
      id: 'budget_001',
      name: '2024 Yıllık Bütçe',
      description: '2024 yılı için genel bütçe',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      totalBudget: 500000.0,
      spentAmount: 125000.0,
      categoryBudgets: {
        'personnel': 300000.0,
        'rent': 60000.0,
        'equipment': 50000.0,
        'medication': 40000.0,
        'supplies': 20000.0,
        'utilities': 15000.0,
        'marketing': 10000.0,
        'other': 5000.0,
      },
      categorySpent: {
        'personnel': 75000.0,
        'rent': 15000.0,
        'equipment': 10000.0,
        'medication': 8000.0,
        'supplies': 5000.0,
        'utilities': 4000.0,
        'marketing': 3000.0,
        'other': 1000.0,
      },
      createdBy: 'manager_001',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    _budgets.add(demoBudget);
    await _saveBudgets();

    print('✅ Demo manager financial data created:');
    print('   - Transactions: ${demoTransactions.length}');
    print('   - Invoices: ${demoInvoices.length}');
    print('   - Budgets: 1');
  }
}
