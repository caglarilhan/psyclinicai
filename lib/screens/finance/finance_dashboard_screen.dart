import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/finance_models.dart';
import '../../services/finance_service.dart';
import '../../widgets/finance/financial_overview_widget.dart';
import '../../widgets/finance/transaction_list_widget.dart';
import '../../widgets/finance/invoice_list_widget.dart';
import '../../widgets/finance/financial_charts_widget.dart';
import '../../widgets/finance/add_transaction_dialog.dart';
import '../../widgets/finance/add_invoice_dialog.dart';
import '../../utils/theme.dart';
import '../../utils/date_utils.dart';
import '../../config/region_config.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FinanceService _financeService = FinanceService();
  final TextEditingController _searchController = TextEditingController();
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  
  List<FinancialTransaction> _allTransactions = [];
  List<FinancialTransaction> _filteredTransactions = [];
  List<Invoice> _allInvoices = [];
  List<Invoice> _filteredInvoices = [];
  FinancialMetrics? _metrics;
  String _searchQuery = '';
  TransactionType? _selectedTransactionType;
  TransactionCategory? _selectedCategory;
  InvoiceStatus? _selectedInvoiceStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _financeService.initialize();
    _loadData();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _allTransactions = _financeService.getAllTransactions();
      _filteredTransactions = _allTransactions;
      _allInvoices = _financeService.getAllInvoices();
      _filteredInvoices = _allInvoices;
      _metrics = _financeService.getMetrics();
    });
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        if (_selectedTransactionType != null && transaction.type != _selectedTransactionType) {
          return false;
        }
        if (_selectedCategory != null && transaction.category != _selectedCategory) {
          return false;
        }
        if (_searchQuery.isNotEmpty) {
          return transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 transaction.categoryText.toLowerCase().contains(_searchQuery.toLowerCase());
        }
        return true;
      }).toList();
    });
  }

  void _filterInvoices() {
    setState(() {
      _filteredInvoices = _allInvoices.where((invoice) {
        if (_selectedInvoiceStatus != null && invoice.status != _selectedInvoiceStatus) {
          return false;
        }
        if (_searchQuery.isNotEmpty) {
          return invoice.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 invoice.clientId.toLowerCase().contains(_searchQuery.toLowerCase());
        }
        return true;
      }).toList();
    });
  }

  void _refreshData() {
    _loadData();
    _filterTransactions();
    _filterInvoices();
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'Finans Dashboard',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yenile',
          onPressed: _refreshData,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Filtrele',
          onPressed: _showFilterDialog,
          icon: Icons.filter_list,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Yeni İşlem',
          onPressed: _showAddTransactionDialog,
          icon: Icons.add,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Yeni Fatura',
          onPressed: _showAddInvoiceDialog,
          icon: Icons.receipt,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Genel Bakış',
          icon: Icons.dashboard,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'İşlemler',
          icon: Icons.account_balance_wallet,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Faturalar',
          icon: Icons.receipt,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Grafikler',
          icon: Icons.analytics,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return Column(
      children: [
        // Arama çubuğu
        DesktopTheme.desktopCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DesktopTheme.desktopInput(
                    label: 'Arama',
                    controller: _searchController,
                    hintText: 'İşlem veya fatura ara...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterTransactions();
                      _filterInvoices();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                if (_searchQuery.isNotEmpty)
                  DesktopTheme.desktopButton(
                    text: 'Temizle',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _filterTransactions();
                      _filterInvoices();
                    },
                    icon: Icons.clear,
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDesktopOverviewTab(),
              _buildDesktopTransactionsTab(),
              _buildDesktopInvoicesTab(),
              _buildDesktopChartsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finans Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış', icon: Icon(Icons.dashboard)),
            Tab(text: 'İşlemler', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Faturalar', icon: Icon(Icons.receipt)),
            Tab(text: 'Grafikler', icon: Icon(Icons.analytics)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İşlem veya fatura ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterTransactions();
                          _filterInvoices();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterTransactions();
                _filterInvoices();
              },
            ),
          ),
          // Tab içerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Genel Bakış tab'ı
                _buildOverviewTab(),
                // İşlemler tab'ı
                TransactionListWidget(
                  transactions: _filteredTransactions,
                  onTransactionAdded: _refreshData,
                  onTransactionUpdated: _refreshData,
                  onTransactionDeleted: _refreshData,
                ),
                // Faturalar tab'ı
                InvoiceListWidget(
                  invoices: _filteredInvoices,
                  onInvoiceAdded: _refreshData,
                  onInvoiceUpdated: _refreshData,
                  onInvoiceDeleted: _refreshData,
                ),
                // Grafikler tab'ı
                FinancialChartsWidget(
                  metrics: _metrics,
                  transactions: _allTransactions,
                  invoices: _allInvoices,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni İşlem'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Finansal özet kartları
          FinancialOverviewWidget(metrics: _metrics!),
          const SizedBox(height: 16),
          _buildRegionCard(),
          const SizedBox(height: 24),
          
          // Son işlemler
          Text(
            'Son İşlemler',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_allTransactions.isNotEmpty) ...[
            ..._allTransactions.take(5).map((transaction) => _buildTransactionCard(transaction)),
          ] else ...[
            const Center(
              child: Text('Henüz işlem bulunmuyor'),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Son faturalar
          Text(
            'Son Faturalar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_allInvoices.isNotEmpty) ...[
            ..._allInvoices.take(5).map((invoice) => _buildInvoiceCard(invoice)),
          ] else ...[
            const Center(
              child: Text('Henüz fatura bulunmuyor'),
            ),
          ],

          const SizedBox(height: 24),

          // Ödeme Hatırlatıcıları
          Text(
            'Ödeme Hatırlatıcıları',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildRemindersSection(),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(FinancialTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.typeColor.withOpacity(0.1),
          child: Icon(
            transaction.isIncome ? Icons.trending_up : Icons.trending_down,
            color: transaction.typeColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${transaction.categoryText} • ${AppDateUtils.formatDate(transaction.date)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}₺${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.typeColor,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: transaction.paymentStatusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.paymentStatusText,
                style: TextStyle(
                  fontSize: 12,
                  color: transaction.paymentStatusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: invoice.statusColor.withOpacity(0.1),
          child: Icon(
            Icons.receipt,
            color: invoice.statusColor,
          ),
        ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Müşteri: ${invoice.clientId} • ${AppDateUtils.formatDate(invoice.dueDate)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₺${invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: invoice.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                invoice.statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: invoice.statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İşlem tipi filtresi
            DropdownButtonFormField<TransactionType?>(
              value: _selectedTransactionType,
              decoration: const InputDecoration(
                labelText: 'İşlem Tipi',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...TransactionType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type == TransactionType.income ? 'Gelir' : 'Gider'),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTransactionType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Kategori filtresi
            DropdownButtonFormField<TransactionCategory?>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...TransactionCategory.values.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryDisplayName(category)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Fatura durumu filtresi
            DropdownButtonFormField<InvoiceStatus?>(
              value: _selectedInvoiceStatus,
              decoration: const InputDecoration(
                labelText: 'Fatura Durumu',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...InvoiceStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplayName(status)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedInvoiceStatus = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTransactionType = null;
                _selectedCategory = null;
                _selectedInvoiceStatus = null;
              });
              _filterTransactions();
              _filterInvoices();
              Navigator.of(context).pop();
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _filterTransactions();
              _filterInvoices();
              Navigator.of(context).pop();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(TransactionCategory category) {
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

  String _getStatusDisplayName(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Taslak';
      case InvoiceStatus.sent:
        return 'Gönderildi';
      case InvoiceStatus.paid:
        return 'Ödendi';
      case InvoiceStatus.overdue:
        return 'Gecikmiş';
      case InvoiceStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      _showAddTransactionDialog,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyI, LogicalKeyboardKey.control),
      _showAddInvoiceDialog,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _refreshData,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      _showFilterDialog,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyI, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü tab metodları
  Widget _buildDesktopOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finansal Genel Bakış',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          FinancialOverviewWidget(metrics: _metrics),
          const SizedBox(height: 24),
          Text(
            'Son İşlemler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopDataTable(
            headers: const ['Tarih', 'Açıklama', 'Kategori', 'Tutar', 'Durum'],
            rows: _allTransactions.take(10).map((transaction) => [
              DateUtils.formatDate(transaction.date),
              transaction.description,
              _getCategoryDisplayName(transaction.category),
              '${transaction.amount.toStringAsFixed(2)} ${RegionConfig.activeRegion.currency}',
              transaction.type == TransactionType.income ? 'Gelir' : 'Gider',
            ]).toList(),
            onRowTap: (index) {
              // TODO: İşlem detayı
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTransactionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İşlemler',
                style: DesktopTheme.desktopSectionTitleStyle,
              ),
              DesktopTheme.desktopButton(
                text: 'Yeni İşlem',
                onPressed: _showAddTransactionDialog,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TransactionListWidget(
            transactions: _filteredTransactions,
            onTransactionAdded: _refreshData,
            onTransactionUpdated: _refreshData,
            onTransactionDeleted: _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopInvoicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Faturalar',
                style: DesktopTheme.desktopSectionTitleStyle,
              ),
              DesktopTheme.desktopButton(
                text: 'Yeni Fatura',
                onPressed: _showAddInvoiceDialog,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: 16),
          InvoiceListWidget(
            invoices: _filteredInvoices,
            onInvoiceAdded: _refreshData,
            onInvoiceUpdated: _refreshData,
            onInvoiceDeleted: _refreshData,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finansal Grafikler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          FinancialChartsWidget(metrics: _metrics),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Finansal İşlem'),
              subtitle: const Text('Gelir veya gider ekle'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddTransactionDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Fatura'),
              subtitle: const Text('Yeni fatura oluştur'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddInvoiceDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        onTransactionAdded: (transaction) {
          _refreshData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showAddInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AddInvoiceDialog(
        onInvoiceAdded: (invoice) {
          _refreshData();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildRegionCard() {
    final currency = RegionConfig.currency;
    final taxRate = RegionConfig.taxRate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bölge Ayarları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Para birimi: $currency  •  Vergi oranı: ${(taxRate * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    final reminders = FinanceService().getInvoiceReminders(daysThreshold: 7);
    if (reminders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text('Yakında vadesi gelen fatura yok'),
      );
    }

    return Column(
      children: reminders.map((r) => Card(
        child: ListTile(
          leading: const Icon(Icons.alarm, color: Colors.orange),
          title: Text(r),
          trailing: TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hatırlatıcı gönderildi (demo)')),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Gönder'),
          ),
        ),
      )).toList(),
    );
  }
}
