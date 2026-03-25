import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () {
        // Yeni fatura
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      () {
        // Raporlar
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Finans Yonetimi',
      child: Column(
        children: [
          _buildKpiCards(),
          const SizedBox(height: 16),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add),
          tooltip: 'Yeni Fatura (Ctrl+N)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.assessment),
          tooltip: 'Raporlar (Ctrl+R)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Genel Bakis',
          icon: Icons.dashboard,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Faturalar',
          icon: Icons.receipt_long,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Odemeler',
          icon: Icons.payment,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Muhasebe',
          icon: Icons.account_balance,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Cards
  // ---------------------------------------------------------------------------

  Widget _buildKpiCards() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'Aylik Gelir',
            value: '\u20BA47.850',
            icon: Icons.trending_up,
            color: AppTheme.successColor,
            subtitle: 'Bu ay',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Bekleyen Odemeler',
            value: '\u20BA12.400',
            icon: Icons.hourglass_empty,
            color: AppTheme.warningColor,
            subtitle: '8 fatura',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Tahsilat Orani',
            value: '%87,5',
            icon: Icons.pie_chart,
            color: AppTheme.primaryColor,
            subtitle: 'Son 30 gun',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Aylik Gider',
            value: '\u20BA18.200',
            icon: Icons.trending_down,
            color: AppTheme.errorColor,
            subtitle: 'Bu ay',
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Bar
  // ---------------------------------------------------------------------------

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: AppTheme.primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Genel Bakis'),
          Tab(text: 'Faturalar'),
          Tab(text: 'Odemeler'),
          Tab(text: 'Muhasebe'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildInvoicesTab(),
        _buildPaymentsTab(),
        _buildAccountingTab(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Genel Bakis Tab
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Son Faturalar', Icons.receipt_long),
          const SizedBox(height: 8),
          ..._invoices.take(3).map((inv) => _buildInvoiceRow(inv)),
          const SizedBox(height: 24),
          _buildSectionHeader('Son Odemeler', Icons.payment),
          const SizedBox(height: 8),
          ..._payments.take(3).map((p) => _buildPaymentRow(p)),
          const SizedBox(height: 24),
          _buildSectionHeader('Aylik Ozet', Icons.bar_chart),
          const SizedBox(height: 8),
          _buildMiniSummaryTable(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniSummaryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildSummaryDataRow('Toplam Gelir', '\u20BA47.850', AppTheme.successColor),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSummaryDataRow('Toplam Gider', '\u20BA18.200', AppTheme.errorColor),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _buildSummaryDataRow(
            'Net Kar',
            '\u20BA29.650',
            AppTheme.primaryColor,
            bold: true,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Faturalar Tab
  // ---------------------------------------------------------------------------

  Widget _buildInvoicesTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _invoices.length,
      itemBuilder: (context, index) => _buildInvoiceRow(_invoices[index]),
    );
  }

  Widget _buildInvoiceRow(_Invoice inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.id,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  inv.patient,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              inv.date,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              inv.description,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '\u20BA${inv.amount}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildStatusBadge(inv.status),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Odemeler Tab
  // ---------------------------------------------------------------------------

  Widget _buildPaymentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _payments.length,
      itemBuilder: (context, index) => _buildPaymentRow(_payments[index]),
    );
  }

  Widget _buildPaymentRow(_Payment payment) {
    final methodIcon = switch (payment.method) {
      'Kredi Karti' => Icons.credit_card,
      'Nakit' => Icons.money,
      'Havale' => Icons.account_balance,
      _ => Icons.payment,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(methodIcon, color: AppTheme.successColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.patient,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.invoiceId,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              payment.date,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(methodIcon, size: 14, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  payment.method,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '\u20BA${payment.amount}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Muhasebe Tab
  // ---------------------------------------------------------------------------

  Widget _buildAccountingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Aylik Muhasebe Ozeti', Icons.account_balance),
          const SizedBox(height: 12),
          _buildAccountingTable(),
        ],
      ),
    );
  }

  Widget _buildAccountingTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Ay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gelir',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gider',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Net Kar',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ..._accountingRows.map((row) {
            final profit = row.income - row.expense;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          row.month,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '\u20BA${_formatNumber(row.income)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '\u20BA${_formatNumber(row.expense)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '\u20BA${_formatNumber(profit)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: profit >= 0
                                ? AppTheme.primaryColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ],
            );
          }),
          // Toplam row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'TOPLAM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\u20BA${_formatNumber(_accountingRows.fold<int>(0, (s, r) => s + r.income))}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\u20BA${_formatNumber(_accountingRows.fold<int>(0, (s, r) => s + r.expense))}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '\u20BA${_formatNumber(_accountingRows.fold<int>(0, (s, r) => s + r.income - r.expense))}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared Widgets
  // ---------------------------------------------------------------------------

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Odendi':
        bg = AppTheme.successColor.withOpacity(0.1);
        fg = AppTheme.successColor;
        break;
      case 'Beklemede':
        bg = AppTheme.warningColor.withOpacity(0.1);
        fg = AppTheme.warningColor;
        break;
      case 'Gecikmis':
        bg = AppTheme.errorColor.withOpacity(0.1);
        fg = AppTheme.errorColor;
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildSummaryDataRow(
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Mock Data
  // ---------------------------------------------------------------------------

  static final List<_Invoice> _invoices = [
    _Invoice(
      id: 'INV-2024-001',
      patient: 'Ahmet Yilmaz',
      date: '22.03.2026',
      description: 'Bireysel Terapi (4 Seans)',
      amount: '3.200',
      status: 'Odendi',
    ),
    _Invoice(
      id: 'INV-2024-002',
      patient: 'Elif Kara',
      date: '20.03.2026',
      description: 'Cift Terapisi (2 Seans)',
      amount: '2.400',
      status: 'Beklemede',
    ),
    _Invoice(
      id: 'INV-2024-003',
      patient: 'Mehmet Demir',
      date: '18.03.2026',
      description: 'Bireysel Terapi (4 Seans)',
      amount: '3.200',
      status: 'Odendi',
    ),
    _Invoice(
      id: 'INV-2024-004',
      patient: 'Zeynep Ozturk',
      date: '15.03.2026',
      description: 'Psikolojik Degerlendirme',
      amount: '1.800',
      status: 'Gecikmis',
    ),
    _Invoice(
      id: 'INV-2024-005',
      patient: 'Fatma Sahin',
      date: '12.03.2026',
      description: 'Bireysel Terapi (2 Seans)',
      amount: '1.600',
      status: 'Odendi',
    ),
    _Invoice(
      id: 'INV-2024-006',
      patient: 'Ali Celik',
      date: '10.03.2026',
      description: 'Grup Terapisi (4 Seans)',
      amount: '1.200',
      status: 'Beklemede',
    ),
    _Invoice(
      id: 'INV-2024-007',
      patient: 'Ayse Yildiz',
      date: '08.03.2026',
      description: 'Bireysel Terapi (4 Seans)',
      amount: '3.200',
      status: 'Odendi',
    ),
    _Invoice(
      id: 'INV-2024-008',
      patient: 'Hasan Arslan',
      date: '05.03.2026',
      description: 'Bireysel Terapi (2 Seans)',
      amount: '1.600',
      status: 'Gecikmis',
    ),
    _Invoice(
      id: 'INV-2024-009',
      patient: 'Merve Koc',
      date: '03.03.2026',
      description: 'Cift Terapisi (2 Seans)',
      amount: '2.400',
      status: 'Beklemede',
    ),
    _Invoice(
      id: 'INV-2024-010',
      patient: 'Burak Tas',
      date: '01.03.2026',
      description: 'Psikolojik Degerlendirme',
      amount: '1.800',
      status: 'Odendi',
    ),
  ];

  static final List<_Payment> _payments = [
    _Payment(
      patient: 'Ahmet Yilmaz',
      invoiceId: 'INV-2024-001',
      date: '22.03.2026',
      amount: '3.200',
      method: 'Kredi Karti',
    ),
    _Payment(
      patient: 'Mehmet Demir',
      invoiceId: 'INV-2024-003',
      date: '18.03.2026',
      amount: '3.200',
      method: 'Havale',
    ),
    _Payment(
      patient: 'Fatma Sahin',
      invoiceId: 'INV-2024-005',
      date: '13.03.2026',
      amount: '1.600',
      method: 'Nakit',
    ),
    _Payment(
      patient: 'Ayse Yildiz',
      invoiceId: 'INV-2024-007',
      date: '08.03.2026',
      amount: '3.200',
      method: 'Kredi Karti',
    ),
    _Payment(
      patient: 'Burak Tas',
      invoiceId: 'INV-2024-010',
      date: '02.03.2026',
      amount: '1.800',
      method: 'Havale',
    ),
    _Payment(
      patient: 'Selin Acar',
      invoiceId: 'INV-2024-011',
      date: '28.02.2026',
      amount: '2.400',
      method: 'Kredi Karti',
    ),
    _Payment(
      patient: 'Emre Dogan',
      invoiceId: 'INV-2024-012',
      date: '25.02.2026',
      amount: '1.600',
      method: 'Nakit',
    ),
    _Payment(
      patient: 'Deniz Korkmaz',
      invoiceId: 'INV-2024-013',
      date: '22.02.2026',
      amount: '3.200',
      method: 'Havale',
    ),
  ];

  static final List<_AccountingRow> _accountingRows = [
    _AccountingRow(month: 'Ocak 2026', income: 42500, expense: 16800),
    _AccountingRow(month: 'Subat 2026', income: 45200, expense: 17500),
    _AccountingRow(month: 'Mart 2026', income: 47850, expense: 18200),
  ];
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

class _Invoice {
  final String id;
  final String patient;
  final String date;
  final String description;
  final String amount;
  final String status;

  const _Invoice({
    required this.id,
    required this.patient,
    required this.date,
    required this.description,
    required this.amount,
    required this.status,
  });
}

class _Payment {
  final String patient;
  final String invoiceId;
  final String date;
  final String amount;
  final String method;

  const _Payment({
    required this.patient,
    required this.invoiceId,
    required this.date,
    required this.amount,
    required this.method,
  });
}

class _AccountingRow {
  final String month;
  final int income;
  final int expense;

  const _AccountingRow({
    required this.month,
    required this.income,
    required this.expense,
  });
}
