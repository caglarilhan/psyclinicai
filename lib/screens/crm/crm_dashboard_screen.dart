import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../models/crm_models.dart';
import '../../services/crm_service.dart';
import '../../widgets/crm/customer_list_widget.dart';
import '../../widgets/crm/sales_pipeline_widget.dart';
import '../../widgets/crm/analytics_dashboard_widget.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class CRMDashboardScreen extends StatefulWidget {
  const CRMDashboardScreen({super.key});

  @override
  State<CRMDashboardScreen> createState() => _CRMDashboardScreenState();
}

class _CRMDashboardScreenState extends State<CRMDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late CRMService _crmService;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  
  // CRM verileri
  List<Customer> _customers = [];
  List<SalesOpportunity> _opportunities = [];
  CRMAnalytics _analytics = CRMAnalytics.empty();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _crmService = CRMService();
    _loadCRMData();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  Future<void> _loadCRMData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _crmService.initialize();
      
      final customers = await _crmService.getCustomers();
      final opportunities = await _crmService.getSalesOpportunities();
      final analytics = await _crmService.getAnalytics();

      setState(() {
        _customers = customers;
        _opportunities = opportunities;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      print('CRM data loading failed: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
      title: 'CRM Dashboard',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Müşteri',
          onPressed: _showAddCustomerDialog,
          icon: Icons.add,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Yenile',
          onPressed: _loadCRMData,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Rapor Oluştur',
          onPressed: _generateCRMReport,
          icon: Icons.assessment,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: _showCRMSettings,
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Genel Bakış',
          icon: Icons.dashboard,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Müşteriler',
          icon: Icons.people,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Satış',
          icon: Icons.trending_up,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Analitik',
          icon: Icons.analytics,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildDesktopOverviewTab(),
        _buildDesktopCustomersTab(),
        _buildDesktopSalesTab(),
        _buildDesktopAnalyticsTab(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Genel Bakış'),
            Tab(icon: Icon(Icons.people), text: 'Müşteriler'),
            Tab(icon: Icon(Icons.trending_up), text: 'Satış'),
            Tab(icon: Icon(Icons.analytics), text: 'Analitik'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCustomerDialog,
            tooltip: 'Yeni Müşteri Ekle',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCRMData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Genel Bakış
                _buildOverviewTab(),
                
                // Tab 2: Müşteriler
                CustomerListWidget(
                  customers: _customers,
                  onCustomerUpdated: _loadCRMData,
                ),
                
                // Tab 3: Satış
                SalesPipelineWidget(
                  opportunities: _opportunities,
                  onOpportunityUpdated: _loadCRMData,
                ),
                
                // Tab 4: Analitik
                AnalyticsDashboardWidget(analytics: _analytics),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOpportunityDialog,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('Yeni Fırsat'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Kartları
          _buildKPICards(),
          
          const SizedBox(height: 24),
          
          // Hızlı İşlemler
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Son Aktiviteler
          _buildRecentActivities(),
          
          const SizedBox(height: 24),
          
          // Müşteri Segmentasyonu
          _buildCustomerSegmentation(),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildKPICard(
          'Toplam Müşteri',
          '${_customers.length}',
          Icons.people,
          AppTheme.primaryColor,
        ),
        _buildKPICard(
          'Aktif Fırsatlar',
          '${_opportunities.where((o) => o.status != SalesStatus.closed).length}',
          Icons.trending_up,
          AppTheme.accentColor,
        ),
        _buildKPICard(
          'Bu Ay Satış',
          '₺${_analytics.monthlyRevenue.toStringAsFixed(0)}',
          Icons.attach_money,
          AppTheme.successColor,
        ),
        _buildKPICard(
          'Ortalama Değer',
          '₺${_analytics.averageDealValue.toStringAsFixed(0)}',
          Icons.assessment,
          AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Yeni Müşteri',
                  Icons.person_add,
                  AppTheme.primaryColor,
                  _showAddCustomerDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Yeni Fırsat',
                  Icons.add_business,
                  AppTheme.accentColor,
                  _showAddOpportunityDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Rapor Oluştur',
                  Icons.assessment,
                  AppTheme.infoColor,
                  _generateReport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final recentActivities = _crmService.getRecentActivities();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Aktiviteler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...recentActivities.take(5).map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(CRMActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getActivityColor(activity.type).withOpacity(0.2),
            child: Icon(
              _getActivityIcon(activity.type),
              size: 16,
              color: _getActivityColor(activity.type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTime(activity.timestamp),
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSegmentation() {
    final segments = _crmService.getCustomerSegments();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Müşteri Segmentasyonu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...segments.map((segment) => _buildSegmentItem(segment)),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(CustomerSegment segment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: segment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              segment.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${segment.customerCount} müşteri',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.customerAdded:
        return AppTheme.successColor;
      case ActivityType.opportunityCreated:
        return AppTheme.accentColor;
      case ActivityType.dealClosed:
        return AppTheme.primaryColor;
      case ActivityType.followUp:
        return AppTheme.warningColor;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.customerAdded:
        return Icons.person_add;
      case ActivityType.opportunityCreated:
        return Icons.add_business;
      case ActivityType.dealClosed:
        return Icons.check_circle;
      case ActivityType.followUp:
        return Icons.schedule;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showAddCustomerDialog() {
    // TODO: Müşteri ekleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Müşteri ekleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showAddOpportunityDialog() {
    // TODO: Fırsat ekleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fırsat ekleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _generateReport() {
    // TODO: Rapor oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor oluşturma özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      _showAddCustomerDialog,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyO, LogicalKeyboardKey.control),
      _showAddOpportunityDialog,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _loadCRMData,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyP, LogicalKeyboardKey.control),
      _generateCRMReport,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyO, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyP, LogicalKeyboardKey.control),
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
            'CRM Genel Bakış',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopGrid(
            children: [
              _buildDesktopKPICard(
                'Toplam Müşteri',
                _analytics.totalCustomers.toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildDesktopKPICard(
                'Aktif Fırsatlar',
                _analytics.activeOpportunities.toString(),
                Icons.trending_up,
                Colors.green,
              ),
              _buildDesktopKPICard(
                'Bu Ay Satış',
                '${_analytics.monthlyRevenue.toStringAsFixed(2)} ₺',
                Icons.account_balance_wallet,
                Colors.orange,
              ),
              _buildDesktopKPICard(
                'Dönüşüm Oranı',
                '${_analytics.conversionRate.toStringAsFixed(1)}%',
                Icons.analytics,
                Colors.purple,
              ),
            ],
            context: context,
          ),
          const SizedBox(height: 32),
          Text(
            'Son Aktiviteler',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          DesktopDataTable(
            headers: const ['Tarih', 'Aktivite', 'Müşteri', 'Durum'],
            rows: _analytics.recentActivities.take(10).map((activity) => [
              _formatTime(activity.timestamp),
              _getActivityDescription(activity.type),
              activity.customerName,
              activity.status,
            ]).toList(),
            onRowTap: (index) {
              // TODO: Aktivite detayı
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCustomersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Müşteriler',
                style: DesktopTheme.desktopSectionTitleStyle,
              ),
              DesktopTheme.desktopButton(
                text: 'Yeni Müşteri',
                onPressed: _showAddCustomerDialog,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomerListWidget(
            customers: _customers,
            onCustomerSelected: (customer) {
              // TODO: Müşteri detayı
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Satış Fırsatları',
                style: DesktopTheme.desktopSectionTitleStyle,
              ),
              DesktopTheme.desktopButton(
                text: 'Yeni Fırsat',
                onPressed: _showAddOpportunityDialog,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SalesPipelineWidget(
            opportunities: _opportunities,
            onOpportunitySelected: (opportunity) {
              // TODO: Fırsat detayı
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CRM Analitik',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          AnalyticsDashboardWidget(
            analytics: _analytics,
            onSegmentSelected: (segment) {
              // TODO: Segment detayı
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopKPICard(String title, String value, IconData icon, Color color) {
    return DesktopGridCard(
      title: title,
      subtitle: value,
      icon: icon,
      color: color,
      onTap: () {
        // TODO: Detay görüntüleme
      },
    );
  }

  String _getActivityDescription(ActivityType type) {
    switch (type) {
      case ActivityType.customerAdded:
        return 'Yeni müşteri eklendi';
      case ActivityType.opportunityCreated:
        return 'Yeni fırsat oluşturuldu';
      case ActivityType.dealClosed:
        return 'Anlaşma kapatıldı';
      case ActivityType.followUp:
        return 'Takip yapıldı';
    }
  }

  void _generateCRMReport() {
    // TODO: CRM raporu oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CRM raporu oluşturuluyor...')),
    );
  }

  void _showCRMSettings() {
    // TODO: CRM ayarları
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CRM ayarları açılıyor...')),
    );
  }
}
