import 'package:flutter/material.dart';
import '../../models/manager_financial_models.dart';
import '../../services/manager_financial_service.dart';
import '../../services/role_service.dart';

class ManagerFinancialScreen extends StatefulWidget {
  const ManagerFinancialScreen({super.key});

  @override
  State<ManagerFinancialScreen> createState() => _ManagerFinancialScreenState();
}

class _ManagerFinancialScreenState extends State<ManagerFinancialScreen> with TickerProviderStateMixin {
  final ManagerFinancialService _financialService = ManagerFinancialService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<FinancialTransaction> _transactions = [];
  List<Invoice> _invoices = [];
  List<Budget> _budgets = [];
  List<TaxCalculation> _taxCalculations = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedType = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await _financialService.initialize();
      await _financialService.generateDemoData();
      
      _transactions = _financialService.getTransactionsByType(TransactionType.income);
      _invoices = _financialService.getInvoicesByStatus(InvoiceStatus.sent);
      _budgets = _financialService.getActiveBudgets();
      _taxCalculations = [];
    } catch (e) {
      print('Error loading manager financial data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        title: const Text(
          'Finansal Yönetim',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'İşlemler'),
            Tab(text: 'Faturalar'),
            Tab(text: 'Bütçeler'),
            Tab(text: 'Vergi'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildTransactionsTab(),
                _buildInvoicesTab(),
                _buildBudgetsTab(),
                _buildTaxTab(),
              ],
            ),
    );
  }

  Widget _buildSummaryTab() {
    final summary = _financialService.getFinancialSummary();
    final categoryAnalysis = _financialService.getCategoryAnalysis();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Finansal Özet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Aylık Gelir',
                  '${summary['monthlyIncome'].toStringAsFixed(2)} TL',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Aylık Gider',
                  '${summary['monthlyExpenses'].toStringAsFixed(2)} TL',
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Aylık Kar',
                  '${summary['monthlyProfit'].toStringAsFixed(2)} TL',
                  summary['monthlyProfit'] >= 0 ? Colors.green : Colors.red,
                  Icons.account_balance,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Bekleyen Fatura',
                  '${summary['pendingInvoices']} adet',
                  Colors.orange,
                  Icons.receipt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Kategori Analizi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryAnalysisCard('Gelir Kategorileri', categoryAnalysis['incomeByCategory'], Colors.green),
          const SizedBox(height: 16),
          _buildCategoryAnalysisCard('Gider Kategorileri', categoryAnalysis['expenseByCategory'], Colors.red),
          const SizedBox(height: 24),
          const Text(
            'Bütçe Durumu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBudgetStatusCard(summary['budgetUtilization']),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      color: Colors.purple[800],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysisCard(String title, Map<String, double> categories, Color color) {
    return Card(
      color: Colors.purple[800],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getCategoryName(entry.key),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(2)} TL',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStatusCard(double utilization) {
    final utilizationColor = utilization >= 90 ? Colors.red : 
                            utilization >= 70 ? Colors.orange : Colors.green;
    
    return Card(
      color: Colors.purple[800],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bütçe Kullanımı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${utilization.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: utilizationColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: utilization / 100,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final filteredTransactions = _getFilteredTransactions();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredTransactions.isEmpty
              ? const Center(
                  child: Text(
                    'İşlem bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'İşlem Türü',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.purple[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tümü')),
                DropdownMenuItem(value: 'income', child: Text('Gelir')),
                DropdownMenuItem(value: 'expense', child: Text('Gider')),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                DropdownMenuItem(value: 'adjustment', child: Text('Düzeltme')),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Ödeme Durumu',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.purple[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tümü')),
                DropdownMenuItem(value: 'pending', child: Text('Bekliyor')),
                DropdownMenuItem(value: 'paid', child: Text('Ödendi')),
                DropdownMenuItem(value: 'overdue', child: Text('Gecikmiş')),
                DropdownMenuItem(value: 'cancelled', child: Text('İptal')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<FinancialTransaction> _getFilteredTransactions() {
    var filtered = _transactions;
    
    if (_selectedType != 'all') {
      filtered = filtered.where((transaction) => 
          transaction.type.toString().split('.').last == _selectedType).toList();
    }
    
    if (_selectedStatus != 'all') {
      filtered = filtered.where((transaction) => 
          transaction.paymentStatus.toString().split('.').last == _selectedStatus).toList();
    }
    
    return filtered;
  }

  Widget _buildTransactionCard(FinancialTransaction transaction) {
    final typeColor = _getTransactionTypeColor(transaction.type);
    final statusColor = _getPaymentStatusColor(transaction.paymentStatus);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTransactionTypeName(transaction.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tutar: ${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
              style: TextStyle(
                color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tarih: ${_formatDateTime(transaction.transactionDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (transaction.category != null) ...[
              const SizedBox(height: 4),
              Text(
                'Kategori: ${_getCategoryName(transaction.category!)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPaymentStatusName(transaction.paymentStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Oluşturan: ${transaction.createdBy}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (transaction.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${transaction.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTransactionDetails(transaction),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editTransaction(transaction),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteTransaction(transaction),
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesTab() {
    return _invoices.isEmpty
        ? const Center(
            child: Text(
              'Fatura bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _invoices.length,
            itemBuilder: (context, index) {
              final invoice = _invoices[index];
              return _buildInvoiceCard(invoice);
            },
          );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final statusColor = _getInvoiceStatusColor(invoice.status);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fatura #${invoice.invoiceNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getInvoiceStatusName(invoice.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Toplam: ${invoice.totalAmount.toStringAsFixed(2)} TL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'KDV Hariç: ${invoice.subtotal.toStringAsFixed(2)} TL',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'KDV: ${invoice.taxAmount.toStringAsFixed(2)} TL',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Düzenleme: ${_formatDateTime(invoice.issueDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Vade: ${_formatDateTime(invoice.dueDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showInvoiceDetails(invoice),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _markInvoiceAsPaid(invoice),
                    icon: const Icon(Icons.check),
                    label: const Text('Ödendi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadInvoice(invoice),
                    icon: const Icon(Icons.download),
                    label: const Text('İndir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetsTab() {
    return _budgets.isEmpty
        ? const Center(
            child: Text(
              'Bütçe bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _budgets.length,
            itemBuilder: (context, index) {
              final budget = _budgets[index];
              return _buildBudgetCard(budget);
            },
          );
  }

  Widget _buildBudgetCard(Budget budget) {
    final utilization = (budget.spentAmount / budget.totalBudget) * 100;
    final utilizationColor = utilization >= 90 ? Colors.red : 
                            utilization >= 70 ? Colors.orange : Colors.green;
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: budget.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    budget.isActive ? 'AKTİF' : 'PASİF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              budget.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toplam Bütçe: ${budget.totalBudget.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Harcanan: ${budget.spentAmount.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Kalan: ${(budget.totalBudget - budget.spentAmount).toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${utilization.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: utilizationColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: utilization / 100,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Dönem: ${_formatDate(budget.startDate)} - ${_formatDate(budget.endDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showBudgetDetails(budget),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editBudget(budget),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxTab() {
    return _taxCalculations.isEmpty
        ? const Center(
            child: Text(
              'Vergi hesaplaması bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _taxCalculations.length,
            itemBuilder: (context, index) {
              final taxCalculation = _taxCalculations[index];
              return _buildTaxCalculationCard(taxCalculation);
            },
          );
  }

  Widget _buildTaxCalculationCard(TaxCalculation taxCalculation) {
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vergi Hesaplaması - ${taxCalculation.taxPeriod}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hesaplama Tarihi: ${_formatDateTime(taxCalculation.calculationDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toplam Gelir: ${taxCalculation.totalIncome.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Toplam Gider: ${taxCalculation.totalExpenses.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Vergiye Tabi Gelir: ${taxCalculation.taxableIncome.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Gelir Vergisi: ${taxCalculation.taxAmount.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.red),
                      ),
                      Text(
                        'SGK Primi: ${taxCalculation.socialSecurity.toStringAsFixed(2)} TL',
                        style: const TextStyle(color: Colors.orange),
                      ),
                      Text(
                        'Toplam Vergi: ${taxCalculation.totalTax.toStringAsFixed(2)} TL',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTaxDetails(taxCalculation),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadTaxReport(taxCalculation),
                    icon: const Icon(Icons.download),
                    label: const Text('Rapor İndir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.adjustment:
        return Colors.orange;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.overdue:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  Color _getInvoiceStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.orange;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getTransactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'GELİR';
      case TransactionType.expense:
        return 'GİDER';
      case TransactionType.transfer:
        return 'TRANSFER';
      case TransactionType.adjustment:
        return 'DÜZELTME';
    }
  }

  String _getPaymentStatusName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'BEKLİYOR';
      case PaymentStatus.paid:
        return 'ÖDENDİ';
      case PaymentStatus.overdue:
        return 'GECİKMİŞ';
      case PaymentStatus.cancelled:
        return 'İPTAL';
      case PaymentStatus.refunded:
        return 'İADE';
    }
  }

  String _getInvoiceStatusName(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'TASLAK';
      case InvoiceStatus.sent:
        return 'GÖNDERİLDİ';
      case InvoiceStatus.paid:
        return 'ÖDENDİ';
      case InvoiceStatus.overdue:
        return 'GECİKMİŞ';
      case InvoiceStatus.cancelled:
        return 'İPTAL';
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'consultation':
        return 'Konsültasyon';
      case 'therapy':
        return 'Terapi';
      case 'medication':
        return 'İlaç';
      case 'lab':
        return 'Laboratuvar';
      case 'personnel':
        return 'Personel';
      case 'rent':
        return 'Kira';
      case 'equipment':
        return 'Ekipman';
      case 'supplies':
        return 'Malzeme';
      case 'utilities':
        return 'Faturalar';
      case 'marketing':
        return 'Pazarlama';
      case 'other':
        return 'Diğer';
      default:
        return category;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTransactionDetails(FinancialTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'İşlem Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklama: ${transaction.description}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getTransactionTypeName(transaction.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Tutar: ${transaction.amount.toStringAsFixed(2)} ${transaction.currency}', style: const TextStyle(color: Colors.white70)),
              Text('Tarih: ${_formatDateTime(transaction.transactionDate)}', style: const TextStyle(color: Colors.white70)),
              if (transaction.category != null)
                Text('Kategori: ${_getCategoryName(transaction.category!)}', style: const TextStyle(color: Colors.white70)),
              Text('Ödeme Durumu: ${_getPaymentStatusName(transaction.paymentStatus)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${transaction.createdBy}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(transaction.createdAt)}', style: const TextStyle(color: Colors.white70)),
              if (transaction.notes != null)
                Text('Notlar: ${transaction.notes}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editTransaction(FinancialTransaction transaction) {
    // TODO: Implement transaction editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İşlem düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteTransaction(FinancialTransaction transaction) {
    // TODO: Implement transaction deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İşlem silme formu yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Fatura Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fatura No: ${invoice.invoiceNumber}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${_getInvoiceStatusName(invoice.status)}', style: const TextStyle(color: Colors.white70)),
              Text('Toplam: ${invoice.totalAmount.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('KDV Hariç: ${invoice.subtotal.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('KDV: ${invoice.taxAmount.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Düzenleme: ${_formatDateTime(invoice.issueDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Vade: ${_formatDateTime(invoice.dueDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${invoice.createdBy}', style: const TextStyle(color: Colors.white70)),
              if (invoice.paidAt != null)
                Text('Ödeme: ${_formatDateTime(invoice.paidAt!)}', style: const TextStyle(color: Colors.white70)),
              if (invoice.paymentMethod != null)
                Text('Ödeme Yöntemi: ${invoice.paymentMethod}', style: const TextStyle(color: Colors.white70)),
              if (invoice.notes != null)
                Text('Notlar: ${invoice.notes}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Kalemler:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...invoice.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• ${item.description} (${item.quantity}x ${item.unitPrice.toStringAsFixed(2)} TL)', style: const TextStyle(color: Colors.white70)),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _markInvoiceAsPaid(Invoice invoice) {
    // TODO: Implement invoice payment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fatura ödeme formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadInvoice(Invoice invoice) {
    // TODO: Implement invoice download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fatura indirme özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showBudgetDetails(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Bütçe Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ad: ${budget.name}', style: const TextStyle(color: Colors.white70)),
              Text('Açıklama: ${budget.description}', style: const TextStyle(color: Colors.white70)),
              Text('Toplam Bütçe: ${budget.totalBudget.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Harcanan: ${budget.spentAmount.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Kalan: ${(budget.totalBudget - budget.spentAmount).toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Dönem: ${_formatDate(budget.startDate)} - ${_formatDate(budget.endDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Aktif: ${budget.isActive ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${budget.createdBy}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Kategori Bütçeleri:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...budget.categoryBudgets.entries.map((entry) {
                final spent = budget.categorySpent[entry.key] ?? 0.0;
                final utilization = (spent / entry.value) * 100;
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• ${_getCategoryName(entry.key)}: ${entry.value.toStringAsFixed(2)} TL (${spent.toStringAsFixed(2)} TL harcandı - %${utilization.toStringAsFixed(1)})', style: const TextStyle(color: Colors.white70)),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editBudget(Budget budget) {
    // TODO: Implement budget editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bütçe düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showTaxDetails(TaxCalculation taxCalculation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Vergi Hesaplama Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dönem: ${taxCalculation.taxPeriod}', style: const TextStyle(color: Colors.white70)),
              Text('Hesaplama Tarihi: ${_formatDateTime(taxCalculation.calculationDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Toplam Gelir: ${taxCalculation.totalIncome.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Toplam Gider: ${taxCalculation.totalExpenses.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Vergiye Tabi Gelir: ${taxCalculation.taxableIncome.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Gelir Vergisi: ${taxCalculation.taxAmount.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('SGK Primi: ${taxCalculation.socialSecurity.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Toplam Vergi: ${taxCalculation.totalTax.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              Text('Hesaplayan: ${taxCalculation.calculatedBy}', style: const TextStyle(color: Colors.white70)),
              if (taxCalculation.details != null) ...[
                const SizedBox(height: 8),
                const Text('Detaylar:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ...taxCalculation.details!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• ${entry.key}: ${entry.value}', style: const TextStyle(color: Colors.white70)),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _downloadTaxReport(TaxCalculation taxCalculation) {
    // TODO: Implement tax report download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vergi raporu indirme özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
