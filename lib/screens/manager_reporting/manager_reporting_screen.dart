import 'package:flutter/material.dart';
import '../../models/manager_reporting_models.dart';
import '../../services/manager_reporting_service.dart';
import '../../services/role_service.dart';

class ManagerReportingScreen extends StatefulWidget {
  const ManagerReportingScreen({super.key});

  @override
  State<ManagerReportingScreen> createState() => _ManagerReportingScreenState();
}

class _ManagerReportingScreenState extends State<ManagerReportingScreen> with TickerProviderStateMixin {
  final ManagerReportingService _reportingService = ManagerReportingService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<ManagerReport> _reports = [];
  List<DashboardWidget> _dashboardWidgets = [];
  List<PerformanceMetric> _performanceMetrics = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedType = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      await _reportingService.initialize();
      await _reportingService.generateDemoData();
      
      _reports = _reportingService.getReportsByStatus(ReportStatus.published);
      _dashboardWidgets = _reportingService.getActiveDashboardWidgets();
      _performanceMetrics = _reportingService.getPerformanceMetricsByCategory('Hasta');
    } catch (e) {
      print('Error loading manager reporting data: $e');
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
          'Yönetici Raporlama',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Raporlar'),
            Tab(text: 'Dashboard'),
            Tab(text: 'Performans'),
            Tab(text: 'İstatistikler'),
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
                _buildReportsTab(),
                _buildDashboardTab(),
                _buildPerformanceTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildReportsTab() {
    final filteredReports = _getFilteredReports();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredReports.isEmpty
              ? const Center(
                  child: Text(
                    'Rapor bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return _buildReportCard(report);
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
                labelText: 'Rapor Türü',
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
                DropdownMenuItem(value: 'financial', child: Text('Finansal')),
                DropdownMenuItem(value: 'patient', child: Text('Hasta')),
                DropdownMenuItem(value: 'staff', child: Text('Personel')),
                DropdownMenuItem(value: 'system', child: Text('Sistem')),
                DropdownMenuItem(value: 'performance', child: Text('Performans')),
                DropdownMenuItem(value: 'compliance', child: Text('Uyumluluk')),
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
                labelText: 'Durum',
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
                DropdownMenuItem(value: 'draft', child: Text('Taslak')),
                DropdownMenuItem(value: 'generated', child: Text('Oluşturuldu')),
                DropdownMenuItem(value: 'published', child: Text('Yayınlandı')),
                DropdownMenuItem(value: 'archived', child: Text('Arşivlendi')),
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

  List<ManagerReport> _getFilteredReports() {
    var filtered = _reports;
    
    if (_selectedType != 'all') {
      filtered = filtered.where((report) => report.type.toString().split('.').last == _selectedType).toList();
    }
    
    if (_selectedStatus != 'all') {
      filtered = filtered.where((report) => report.status.toString().split('.').last == _selectedStatus).toList();
    }
    
    return filtered;
  }

  Widget _buildReportCard(ManagerReport report) {
    final typeColor = _getReportTypeColor(report.type);
    final statusColor = _getReportStatusColor(report.status);
    
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
                    report.title,
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
                    _getReportTypeName(report.type),
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
              report.description,
              style: const TextStyle(color: Colors.white70),
            ),
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
                    _getReportStatusName(report.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Sıklık: ${_getReportFrequencyName(report.frequency)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Oluşturulma: ${_formatDateTime(report.createdAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (report.generatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Oluşturulma: ${_formatDateTime(report.generatedAt!)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (report.publishedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Yayınlanma: ${_formatDateTime(report.publishedAt!)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showReportDetails(report),
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
                    onPressed: () => _generateReport(report),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadReport(report),
                    icon: const Icon(Icons.download),
                    label: const Text('İndir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  Widget _buildDashboardTab() {
    return _dashboardWidgets.isEmpty
        ? const Center(
            child: Text(
              'Dashboard widget bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _dashboardWidgets.length,
            itemBuilder: (context, index) {
              final widget = _dashboardWidgets[index];
              return _buildDashboardWidgetCard(widget);
            },
          );
  }

  Widget _buildDashboardWidgetCard(DashboardWidget widget) {
    return Card(
      color: Colors.purple[800],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editWidget(widget),
                  icon: const Icon(Icons.edit, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tür: ${widget.widgetType}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Pozisyon: ${widget.position}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWidgetDetails(widget),
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
                    onPressed: () => _removeWidget(widget),
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

  Widget _buildPerformanceTab() {
    return _performanceMetrics.isEmpty
        ? const Center(
            child: Text(
              'Performans metrik bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _performanceMetrics.length,
            itemBuilder: (context, index) {
              final metric = _performanceMetrics[index];
              return _buildPerformanceMetricCard(metric);
            },
          );
  }

  Widget _buildPerformanceMetricCard(PerformanceMetric metric) {
    final progress = _calculateProgress(metric.currentValue, metric.targetValue);
    final progressColor = _getProgressColor(progress);
    
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
                    metric.name,
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metric.category,
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
              metric.description,
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
                        'Mevcut: ${metric.currentValue} ${metric.unit}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Hedef: ${metric.targetValue} ${metric.unit}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Önceki: ${metric.previousValue} ${metric.unit}',
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
                        '${progress.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Hesaplanma: ${_formatDateTime(metric.calculatedAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final statistics = _reportingService.getStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Raporlama İstatistikleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Rapor', statistics['totalReports'].toString(), Colors.blue),
          _buildStatCard('Taslak Rapor', statistics['draftReports'].toString(), Colors.orange),
          _buildStatCard('Oluşturulan Rapor', statistics['generatedReports'].toString(), Colors.green),
          _buildStatCard('Yayınlanan Rapor', statistics['publishedReports'].toString(), Colors.blue),
          _buildStatCard('Arşivlenen Rapor', statistics['archivedReports'].toString(), Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Dashboard ve Performans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Widget', statistics['totalWidgets'].toString(), Colors.purple),
          _buildStatCard('Aktif Widget', statistics['activeWidgets'].toString(), Colors.green),
          _buildStatCard('Toplam Metrik', statistics['totalMetrics'].toString(), Colors.blue),
          _buildStatCard('Kategori Sayısı', statistics['categories'].toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.financial:
        return Colors.green;
      case ReportType.patient:
        return Colors.blue;
      case ReportType.staff:
        return Colors.orange;
      case ReportType.system:
        return Colors.purple;
      case ReportType.performance:
        return Colors.red;
      case ReportType.compliance:
        return Colors.indigo;
      case ReportType.custom:
        return Colors.grey;
    }
  }

  Color _getReportStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return Colors.orange;
      case ReportStatus.generated:
        return Colors.blue;
      case ReportStatus.published:
        return Colors.green;
      case ReportStatus.archived:
        return Colors.grey;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.financial:
        return 'FİNANSAL';
      case ReportType.patient:
        return 'HASTA';
      case ReportType.staff:
        return 'PERSONEL';
      case ReportType.system:
        return 'SİSTEM';
      case ReportType.performance:
        return 'PERFORMANS';
      case ReportType.compliance:
        return 'UYUMLULUK';
      case ReportType.custom:
        return 'ÖZEL';
    }
  }

  String _getReportStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return 'TASLAK';
      case ReportStatus.generated:
        return 'OLUŞTURULDU';
      case ReportStatus.published:
        return 'YAYINLANDI';
      case ReportStatus.archived:
        return 'ARŞİVLENDİ';
    }
  }

  String _getReportFrequencyName(ReportFrequency frequency) {
    switch (frequency) {
      case ReportFrequency.daily:
        return 'Günlük';
      case ReportFrequency.weekly:
        return 'Haftalık';
      case ReportFrequency.monthly:
        return 'Aylık';
      case ReportFrequency.quarterly:
        return 'Çeyrek Yıllık';
      case ReportFrequency.yearly:
        return 'Yıllık';
      case ReportFrequency.onDemand:
        return 'Talep Üzerine';
    }
  }

  double _calculateProgress(dynamic current, dynamic target) {
    if (target == 0) return 0;
    return (current / target) * 100;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showReportDetails(ManagerReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Rapor Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Başlık: ${report.title}', style: const TextStyle(color: Colors.white70)),
              Text('Açıklama: ${report.description}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getReportTypeName(report.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${_getReportStatusName(report.status)}', style: const TextStyle(color: Colors.white70)),
              Text('Sıklık: ${_getReportFrequencyName(report.frequency)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(report.createdAt)}', style: const TextStyle(color: Colors.white70)),
              if (report.generatedAt != null)
                Text('Oluşturulma: ${_formatDateTime(report.generatedAt!)}', style: const TextStyle(color: Colors.white70)),
              if (report.publishedAt != null)
                Text('Yayınlanma: ${_formatDateTime(report.publishedAt!)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${report.createdBy}', style: const TextStyle(color: Colors.white70)),
              if (report.generatedBy != null)
                Text('Oluşturan: ${report.generatedBy}', style: const TextStyle(color: Colors.white70)),
              Text('Metrikler: ${report.metrics.length}', style: const TextStyle(color: Colors.white70)),
              Text('Grafikler: ${report.charts.length}', style: const TextStyle(color: Colors.white70)),
              if (report.notes != null)
                Text('Notlar: ${report.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _generateReport(ManagerReport report) {
    // TODO: Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor oluşturma özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _downloadReport(ManagerReport report) {
    // TODO: Implement report download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rapor indirme özelliği yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showWidgetDetails(DashboardWidget widget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Widget Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Başlık: ${widget.title}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${widget.widgetType}', style: const TextStyle(color: Colors.white70)),
              Text('Pozisyon: ${widget.position}', style: const TextStyle(color: Colors.white70)),
              Text('Görünür: ${widget.isVisible ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(widget.createdAt)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${widget.createdBy}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Konfigürasyon:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...widget.configuration.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• ${entry.key}: ${entry.value}', style: const TextStyle(color: Colors.white70)),
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

  void _editWidget(DashboardWidget widget) {
    // TODO: Implement widget editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Widget düzenleme özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeWidget(DashboardWidget widget) {
    // TODO: Implement widget removal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Widget silme özelliği yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
