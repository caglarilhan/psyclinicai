import '../models/finance_models.dart';

class FinanceService {
  static final FinanceService _instance = FinanceService._internal();
  factory FinanceService() => _instance;
  FinanceService._internal();

  // Logger removed for now
  
  List<Income> _incomes = [];
  List<Expense> _expenses = [];
  List<Invoice> _invoices = [];
  List<Budget> _budgets = [];
  List<FinancialAlert> _alerts = [];

  Future<void> initialize() async {
    print('FinanceService initializing...');
    await _loadMockData();
    await _generateAlerts();
    print('FinanceService initialized successfully');
  }

  Future<List<Income>> getIncomes({String? therapistId}) async {
    if (therapistId != null) {
      return _incomes.where((i) => i.therapistId == therapistId).toList();
    }
    return _incomes;
  }

  Future<List<Expense>> getExpenses({String? therapistId}) async {
    if (therapistId != null) {
      return _expenses.where((e) => e.therapistId == therapistId).toList();
    }
    return _expenses;
  }

  Future<List<Invoice>> getInvoices({String? therapistId}) async {
    if (therapistId != null) {
      return _invoices.where((i) => i.therapistId == therapistId).toList();
    }
    return _invoices;
  }

  Future<List<Budget>> getBudgets({String? therapistId}) async {
    if (therapistId != null) {
      return _budgets.where((b) => b.therapistId == therapistId).toList();
    }
    return _budgets;
  }

  Future<FinancialReport> generateFinancialReport({
    required String therapistId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final incomes = await getIncomes(therapistId: therapistId);
    final expenses = await getExpenses(therapistId: therapistId);
    
    final totalIncome = incomes.fold(0.0, (sum, i) => sum + i.amount);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = totalIncome - totalExpenses;
    
    return FinancialReport(
      id: _generateId(),
      therapistId: therapistId,
      startDate: startDate,
      endDate: endDate,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      currency: 'TRY',
      incomes: incomes,
      expenses: expenses,
      incomeByCategory: {},
      expenseByCategory: {},
      monthlyTrends: {},
      alerts: _alerts,
    );
  }

  Future<List<FinancialAlert>> getAlerts({bool? resolved}) async {
    if (resolved != null) {
      return _alerts.where((a) => a.isResolved == resolved).toList();
    }
    return _alerts;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _generateAlerts() async {
    _alerts.clear();
    final now = DateTime.now();
    
    _alerts.add(FinancialAlert(
      id: _generateId(),
      type: AlertType.highExpense,
      severity: AlertSeverity.medium,
      title: 'Test Uyarısı',
      description: 'Bu bir test uyarısıdır',
      createdAt: now,
      isResolved: false,
    ));
  }

  Future<void> _loadMockData() async {
    _incomes = [
      Income(
        id: '1',
        clientId: 'client1',
        therapistId: 'therapist1',
        amount: 500.0,
        currency: 'TRY',
        type: IncomeType.sessionFee,
        date: DateTime.now(),
        description: 'Terapi seansı',
        status: PaymentStatus.completed,
      ),
    ];

    _expenses = [
      Expense(
        id: '1',
        therapistId: 'therapist1',
        amount: 2000.0,
        currency: 'TRY',
        type: ExpenseType.officeRent,
        date: DateTime.now(),
        description: 'Ofis kirası',
        status: ExpenseStatus.paid,
        isReimbursable: false,
      ),
    ];

    _invoices = [
      Invoice(
        id: '1',
        clientId: 'client1',
        therapistId: 'therapist1',
        items: [
          InvoiceItem(
            description: 'Terapi seansı',
            quantity: 1,
            unitPrice: 500.0,
            totalPrice: 500.0,
          ),
        ],
        subtotal: 500.0,
        taxAmount: 90.0,
        totalAmount: 590.0,
        currency: 'TRY',
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: InvoiceStatus.sent,
      ),
    ];

    _budgets = [
      Budget(
        id: '1',
        therapistId: 'therapist1',
        name: '2025 Bütçesi',
        description: 'Genel bütçe',
        totalAmount: 50000.0,
        currency: 'TRY',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        categories: [
          BudgetCategory(
            name: 'Ofis',
            allocatedAmount: 20000.0,
            spentAmount: 8500.0,
            remainingAmount: 11500.0,
            percentageUsed: 42.5,
          ),
        ],
        status: BudgetStatus.active,
      ),
    ];
  }
}
