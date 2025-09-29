import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/supervision_models.dart';
import '../../services/supervision_service.dart';
// import '../../widgets/supervisor/supervision_list_widget.dart';
// import '../../widgets/supervisor/performance_analytics_widget.dart';
// import '../../widgets/supervisor/quality_assurance_widget.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late SupervisionService _supervisionService;
  
  // Süpervizyon verileri
  List<SupervisionSession> _sessions = [];
  List<TherapistPerformance> _performances = [];
  QualityMetrics _qualityMetrics = QualityMetrics.empty();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _supervisionService = SupervisionService();
    _loadSupervisionData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSupervisionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _supervisionService.initialize();
      
      final sessions = await _supervisionService.getSupervisionSessions();
      final performances = await _supervisionService.getTherapistPerformances();
      final qualityMetrics = await _supervisionService.getQualityMetrics();

      setState(() {
        _sessions = sessions;
        _performances = performances;
        _qualityMetrics = qualityMetrics;
        _isLoading = false;
      });
    } catch (e) {
      print('Supervision data loading failed: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süpervizyon Dashboard'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Genel Bakış'),
            Tab(icon: Icon(Icons.supervisor_account), text: 'Süpervizyon'),
            Tab(icon: Icon(Icons.analytics), text: 'Performans'),
            Tab(icon: Icon(Icons.verified), text: 'Kalite Güvence'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSessionDialog,
            tooltip: 'Yeni Süpervizyon Ekle',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSupervisionData,
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
                
                // Tab 2: Süpervizyon
                SupervisionListWidget(
                  sessions: _sessions,
                  onSessionUpdated: _loadSupervisionData,
                ),
                
                // Tab 3: Performans
                PerformanceAnalyticsWidget(
                  performances: _performances,
                  onPerformanceUpdated: _loadSupervisionData,
                ),
                
                // Tab 4: Kalite Güvence
                QualityAssuranceWidget(
                  qualityMetrics: _qualityMetrics,
                  onMetricsUpdated: _loadSupervisionData,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSessionDialog,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Süpervizyon'),
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
          
          // Kalite Metrikleri
          _buildQualityMetrics(),
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
          'Toplam Süpervizyon',
          '${_sessions.length}',
          Icons.supervisor_account,
          AppTheme.secondaryColor,
        ),
        _buildKPICard(
          'Aktif Terapistler',
          '${_performances.where((p) => p.isActive).length}',
          Icons.people,
          AppTheme.primaryColor,
        ),
        _buildKPICard(
          'Ortalama Skor',
          '${_qualityMetrics.averageScore.toStringAsFixed(1)}/10',
          Icons.star,
          AppTheme.accentColor,
        ),
        _buildKPICard(
          'Kalite Oranı',
          '%${(_qualityMetrics.qualityRate * 100).toStringAsFixed(1)}',
          Icons.verified,
          AppTheme.successColor,
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
                  'Yeni Süpervizyon',
                  Icons.add,
                  AppTheme.secondaryColor,
                  _showAddSessionDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Performans Raporu',
                  Icons.assessment,
                  AppTheme.primaryColor,
                  _generatePerformanceReport,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Kalite Raporu',
                  Icons.verified,
                  AppTheme.accentColor,
                  _generateQualityReport,
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
    final recentActivities = _supervisionService.getRecentActivities();
    
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

  Widget _buildActivityItem(SupervisionActivity activity) {
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

  Widget _buildQualityMetrics() {
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
            'Kalite Metrikleri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildQualityRow('Ortalama Skor', '${_qualityMetrics.averageScore.toStringAsFixed(1)}/10', AppTheme.accentColor),
          _buildQualityRow('Kalite Oranı', '%${(_qualityMetrics.qualityRate * 100).toStringAsFixed(1)}', AppTheme.successColor),
          _buildQualityRow('İyileştirme Alanları', '${_qualityMetrics.improvementAreas.length}', AppTheme.warningColor),
          _buildQualityRow('Başarılı Seanslar', '${_qualityMetrics.successfulSessions}', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(SupervisionActivityType type) {
    switch (type) {
      case SupervisionActivityType.sessionCreated:
        return AppTheme.successColor;
      case SupervisionActivityType.sessionCompleted:
        return AppTheme.primaryColor;
      case SupervisionActivityType.feedbackGiven:
        return AppTheme.accentColor;
      case SupervisionActivityType.performanceUpdated:
        return AppTheme.infoColor;
    }
  }

  IconData _getActivityIcon(SupervisionActivityType type) {
    switch (type) {
      case SupervisionActivityType.sessionCreated:
        return Icons.add;
      case SupervisionActivityType.sessionCompleted:
        return Icons.check_circle;
      case SupervisionActivityType.feedbackGiven:
        return Icons.feedback;
      case SupervisionActivityType.performanceUpdated:
        return Icons.trending_up;
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

  void _showAddSessionDialog() {
    // TODO: Süpervizyon ekleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Süpervizyon ekleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _generatePerformanceReport() {
    // TODO: Performans raporu oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Performans raporu oluşturma özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _generateQualityReport() {
    // TODO: Kalite raporu oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kalite raporu oluşturma özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
