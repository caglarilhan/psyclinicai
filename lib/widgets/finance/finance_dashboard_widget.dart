import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../services/finance_service.dart';
import '../../utils/theme.dart';

class FinanceDashboardWidget extends StatefulWidget {
  final String therapistId;

  const FinanceDashboardWidget({
    super.key,
    required this.therapistId,
  });

  @override
  State<FinanceDashboardWidget> createState() => _FinanceDashboardWidgetState();
}

class _FinanceDashboardWidgetState extends State<FinanceDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FinanceService _financeService = FinanceService();
  
  FinancialReport? _currentReport;
  List<FinancialAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      await _financeService.initialize();
      
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 2, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);
      
      _currentReport = await _financeService.generateFinancialReport(
        therapistId: widget.therapistId,
        startDate: startDate,
        endDate: endDate,
      );
      
      _alerts = await _financeService.getAlerts(resolved: false);
      
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (_currentReport == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: AppColors.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finansal Özet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  '${_currentReport!.startDate.day}/${_currentReport!.startDate.month}/${_currentReport!.startDate.year} - ${_currentReport!.endDate.day}/${_currentReport!.endDate.month}/${_currentReport!.endDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _buildSummaryCard(
            'Toplam Gelir',
            '${_currentReport!.totalIncome.toStringAsFixed(2)} TRY',
            Colors.green,
            Icons.trending_up,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Toplam Gider',
            '${_currentReport!.totalExpenses.toStringAsFixed(2)} TRY',
            Colors.red,
            Icons.trending_down,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Net Kar',
            '${_currentReport!.netProfit.toStringAsFixed(2)} TRY',
            _currentReport!.netProfit >= 0 ? Colors.blue : Colors.orange,
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Genel Bakış'),
          Tab(icon: Icon(Icons.receipt), text: 'Faturalar'),
          Tab(icon: Icon(Icons.account_balance), text: 'Bütçe'),
          Tab(icon: Icon(Icons.warning), text: 'Uyarılar'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildInvoicesTab(),
        _buildBudgetTab(),
        _buildAlertsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    if (_currentReport == null) return const Center(child: Text('Veri bulunamadı'));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartSection(),
          const SizedBox(height: 24),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gelir ve Gider Analizi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPieChart(
                'Gelir Dağılımı',
                _currentReport!.incomeByCategory,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieChart(
                'Gider Dağılımı',
                _currentReport!.expenseByCategory,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(String title, Map<String, double> data, Color baseColor) {
    if (data.isEmpty) {
      return _buildEmptyChart(title);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: _buildSimplePieChart(data, baseColor),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(data, baseColor),
        ],
      ),
    );
  }

  Widget _buildSimplePieChart(Map<String, double> data, Color baseColor) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return const Center(child: Text('Veri yok'));
    
    return CustomPaint(
      size: const Size(120, 120),
      painter: PieChartPainter(data, total, baseColor),
    );
  }

  Widget _buildChartLegend(Map<String, double> data, Color baseColor) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    
    return Column(
      children: data.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyChart(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Veri bulunamadı',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son İşlemler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildTransactionList() {
    final allTransactions = <Map<String, dynamic>>[];
    
    // Add incomes
    for (final income in _currentReport!.incomes.take(5)) {
      allTransactions.add({
        'type': 'income',
        'data': income,
        'date': income.date,
      });
    }
    
    // Add expenses
    for (final expense in _currentReport!.expenses.take(5)) {
      allTransactions.add({
        'type': 'expense',
        'data': expense,
        'date': expense.date,
      });
    }
    
    // Sort by date
    allTransactions.sort((a, b) => b['date'].compareTo(a['date']));
    
    return Column(
      children: allTransactions.take(10).map((transaction) {
        if (transaction['type'] == 'income') {
          final income = transaction['data'] as Income;
          return _buildTransactionTile(
            title: income.description,
            subtitle: 'Gelir - ${income.type.name}',
            amount: '+${income.amount.toStringAsFixed(2)} TRY',
            color: Colors.green,
            icon: Icons.trending_up,
            date: income.date,
          );
        } else {
          final expense = transaction['data'] as Expense;
          return _buildTransactionTile(
            title: expense.description,
            subtitle: 'Gider - ${expense.type.name}',
            amount: '-${expense.amount.toStringAsFixed(2)} TRY',
            color: Colors.red,
            icon: Icons.trending_down,
            date: expense.date,
          );
        }
      }).toList(),
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required IconData icon,
    required DateTime date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Placeholder methods for other tabs
  Widget _buildInvoicesTab() {
    return const Center(child: Text('Faturalar Tab - Geliştiriliyor'));
  }

  Widget _buildBudgetTab() {
    return const Center(child: Text('Bütçe Tab - Geliştiriliyor'));
  }

  Widget _buildAlertsTab() {
    return const Center(child: Text('Uyarılar Tab - Geliştiriliyor'));
  }
}

// ===== PIE CHART PAINTER =====

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  final Color baseColor;

  PieChartPainter(this.data, this.total, this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    
    double startAngle = 0;
    int colorIndex = 0;
    
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = _getColor(colorIndex)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  Color _getColor(int index) {
    final colors = [
      baseColor,
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.6),
      baseColor.withOpacity(0.4),
      baseColor.withOpacity(0.2),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
