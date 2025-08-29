import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/crm_models.dart';
import '../../services/crm_service.dart';
import '../../widgets/crm/customer_list_widget.dart';
import '../../widgets/crm/sales_pipeline_widget.dart';
import '../../widgets/crm/analytics_dashboard_widget.dart';

class CRMDashboardScreen extends StatefulWidget {
  const CRMDashboardScreen({super.key});

  @override
  State<CRMDashboardScreen> createState() => _CRMDashboardScreenState();
}

class _CRMDashboardScreenState extends State<CRMDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late CRMService _crmService;
  
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
  }

  @override
  void dispose() {
    _tabController.dispose();
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
}
