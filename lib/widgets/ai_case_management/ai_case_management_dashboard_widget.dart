import 'package:flutter/material.dart';
import '../../models/ai_case_management_models.dart';
import '../../services/ai_case_management_service.dart';
import '../../utils/theme.dart';

class AICaseManagementDashboardWidget extends StatefulWidget {
  final String therapistId;

  const AICaseManagementDashboardWidget({
    super.key,
    required this.therapistId,
  });

  @override
  State<AICaseManagementDashboardWidget> createState() => _AICaseManagementDashboardWidgetState();
}

class _AICaseManagementDashboardWidgetState extends State<AICaseManagementDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final AICaseManagementService _aiService = AICaseManagementService();

  List<AICaseAnalysis> _caseAnalyses = [];
  List<ProgressTracking> _progressTracking = [];
  List<DevelopmentReport> _developmentReports = [];
  List<SecurityAudit> _securityAudits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
      await _aiService.initialize();
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Vaka Yöneticisi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Yapay zeka destekli vaka analizi ve ilerleme takibi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricCard(
                'Vaka Analizleri',
                _caseAnalyses.length.toString(),
                Icons.analytics,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'İlerleme Takibi',
                _progressTracking.length.toString(),
                Icons.trending_up,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Gelişim Raporları',
                _developmentReports.length.toString(),
                Icons.assessment,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Güvenlik Denetimleri',
                _securityAudits.length.toString(),
                Icons.security,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Vaka Analizleri'),
          Tab(text: 'İlerleme Takibi'),
          Tab(text: 'Gelişim Raporları'),
          Tab(text: 'Güvenlik'),
          Tab(text: 'Bölge Ayarları'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildCaseAnalysesTab(),
        _buildProgressTrackingTab(),
        _buildDevelopmentReportsTab(),
        _buildSecurityTab(),
        _buildRegionConfigTab(),
      ],
    );
  }

  Widget _buildCaseAnalysesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildCreateAnalysisCard(),
        const SizedBox(height: 20),
        ..._caseAnalyses.map((analysis) => _buildAnalysisCard(analysis)),
      ],
    );
  }

  Widget _buildCreateAnalysisCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeni Vaka Analizi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CaseAnalysisType>(
                    decoration: const InputDecoration(
                      labelText: 'Analiz Türü',
                      border: OutlineInputBorder(),
                    ),
                    items: CaseAnalysisType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getAnalysisTypeText(type)),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _createNewAnalysis(),
                  child: const Text('Analiz Başlat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getAnalysisTypeText(CaseAnalysisType type) {
    switch (type) {
      case CaseAnalysisType.initial:
        return 'İlk Değerlendirme';
      case CaseAnalysisType.progress:
        return 'İlerleme Analizi';
      case CaseAnalysisType.risk:
        return 'Risk Değerlendirmesi';
      case CaseAnalysisType.outcome:
        return 'Sonuç Analizi';
      case CaseAnalysisType.relapse:
        return 'Nüks Analizi';
      case CaseAnalysisType.maintenance:
        return 'Bakım Analizi';
      case CaseAnalysisType.crisis:
        return 'Kriz Analizi';
    }
  }

  Widget _buildAnalysisCard(AICaseAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAnalysisIcon(analysis.type),
                  color: _getAnalysisColor(analysis.type),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getAnalysisTypeText(analysis.type),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    '${(analysis.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getAnalysisColor(analysis.type),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(analysis.summary),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInsightChip('Öngörüler', analysis.insights.length),
                const SizedBox(width: 8),
                _buildInsightChip('Risk Faktörleri', analysis.riskFactors.length),
                const SizedBox(width: 8),
                _buildInsightChip('Öneriler', analysis.recommendations.length),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAnalysisIcon(CaseAnalysisType type) {
    switch (type) {
      case CaseAnalysisType.initial:
        return Icons.first_page;
      case CaseAnalysisType.progress:
        return Icons.trending_up;
      case CaseAnalysisType.risk:
        return Icons.warning;
      case CaseAnalysisType.outcome:
        return Icons.check_circle;
      case CaseAnalysisType.relapse:
        return Icons.replay;
      case CaseAnalysisType.maintenance:
        return Icons.maintenance;
      case CaseAnalysisType.crisis:
        return Icons.emergency;
    }
  }

  Color _getAnalysisColor(CaseAnalysisType type) {
    switch (type) {
      case CaseAnalysisType.initial:
        return Colors.blue;
      case CaseAnalysisType.progress:
        return Colors.green;
      case CaseAnalysisType.risk:
        return Colors.orange;
      case CaseAnalysisType.outcome:
        return Colors.purple;
      case CaseAnalysisType.relapse:
        return Colors.red;
      case CaseAnalysisType.maintenance:
        return Colors.teal;
      case CaseAnalysisType.crisis:
        return Colors.red[800]!;
    }
  }

  Widget _buildInsightChip(String label, int count) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: Colors.grey[200],
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  Widget _buildProgressTrackingTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildProgressOverview(),
        const SizedBox(height: 20),
        ..._progressTracking.map((progress) => _buildProgressCard(progress)),
      ],
    );
  }

  Widget _buildProgressOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Genel İlerleme Durumu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildProgressMetric(
                    'Ortalama İlerleme',
                    '75%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildProgressMetric(
                    'Aktif Hedefler',
                    '12',
                    Icons.flag,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildProgressMetric(
                    'Tamamlanan',
                    '8',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressCard(ProgressTracking progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getProgressIcon(progress.status),
                  color: _getProgressColor(progress.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vaka: ${progress.caseId}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${(progress.overallProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(progress.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.overallProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress.status)),
            ),
            const SizedBox(height: 12),
            Text('Durum: ${_getProgressStatusText(progress.status)}'),
            Text('Metrikler: ${progress.metrics.length}'),
            Text('Hedefler: ${progress.goals.length}'),
          ],
        ),
      ),
    );
  }

  IconData _getProgressIcon(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.improving:
        return Icons.trending_up;
      case ProgressStatus.stable:
        return Icons.trending_flat;
      case ProgressStatus.declining:
        return Icons.trending_down;
      case ProgressStatus.crisis:
        return Icons.emergency;
      case ProgressStatus.maintenance:
        return Icons.maintenance;
    }
  }

  Color _getProgressColor(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.improving:
        return Colors.green;
      case ProgressStatus.stable:
        return Colors.blue;
      case ProgressStatus.declining:
        return Colors.orange;
      case ProgressStatus.crisis:
        return Colors.red;
      case ProgressStatus.maintenance:
        return Colors.teal;
    }
  }

  String _getProgressStatusText(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.improving:
        return 'İyileşiyor';
      case ProgressStatus.stable:
        return 'Stabil';
      case ProgressStatus.declining:
        return 'Azalıyor';
      case ProgressStatus.crisis:
        return 'Kriz';
      case ProgressStatus.maintenance:
        return 'Bakım';
    }
  }

  Widget _buildDevelopmentReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildCreateReportCard(),
        const SizedBox(height: 20),
        ..._developmentReports.map((report) => _buildReportCard(report)),
      ],
    );
  }

  Widget _buildCreateReportCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeni Gelişim Raporu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createNewReport(),
              child: const Text('Rapor Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(DevelopmentReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gelişim Raporu - ${report.caseId}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${(report.overallProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(report.executiveSummary),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInsightChip('Metrikler', report.keyMetrics.length),
                const SizedBox(width: 8),
                _buildInsightChip('Öngörüler', report.keyInsights.length),
                const SizedBox(width: 8),
                _buildInsightChip('Riskler', report.activeRisks.length),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSecurityOverview(),
        const SizedBox(height: 20),
        ..._securityAudits.map((audit) => _buildAuditCard(audit)),
      ],
    );
  }

  Widget _buildSecurityOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Güvenlik Durumu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSecurityMetric(
                    'Toplam Olay',
                    _securityAudits.length.toString(),
                    Icons.security,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSecurityMetric(
                    'Başarılı',
                    _securityAudits.where((a) => a.isSuccessful).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSecurityMetric(
                    'Başarısız',
                    _securityAudits.where((a) => !a.isSuccessful).length.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuditCard(SecurityAudit audit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAuditColor(audit.severity),
          child: Icon(
            _getAuditIcon(audit.severity),
            color: Colors.white,
          ),
        ),
        title: Text(audit.action),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kullanıcı: ${audit.userId}'),
            Text('Kaynak: ${audit.resource}'),
            Text('Zaman: ${_formatDateTime(audit.timestamp)}'),
            Text('Durum: ${audit.isSuccessful ? "Başarılı" : "Başarısız"}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            _getAuditSeverityText(audit.severity),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          backgroundColor: _getAuditColor(audit.severity),
        ),
      ),
    );
  }

  Color _getAuditColor(AuditSeverity severity) {
    switch (severity) {
      case AuditSeverity.info:
        return Colors.blue;
      case AuditSeverity.warning:
        return Colors.orange;
      case AuditSeverity.error:
        return Colors.red;
      case AuditSeverity.critical:
        return Colors.red[800]!;
    }
  }

  IconData _getAuditIcon(AuditSeverity severity) {
    switch (severity) {
      case AuditSeverity.info:
        return Icons.info;
      case AuditSeverity.warning:
        return Icons.warning;
      case AuditSeverity.error:
        return Icons.error;
      case AuditSeverity.critical:
        return Icons.emergency;
    }
  }

  String _getAuditSeverityText(AuditSeverity severity) {
    switch (severity) {
      case AuditSeverity.info:
        return 'Bilgi';
      case AuditSeverity.warning:
        return 'Uyarı';
      case AuditSeverity.error:
        return 'Hata';
      case AuditSeverity.critical:
        return 'Kritik';
    }
  }

  Widget _buildRegionConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildRegionSelector(),
        const SizedBox(height: 20),
        _buildRegionInfo(),
      ],
    );
  }

  Widget _buildRegionSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bölge Seçimi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Ülke',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'TR', child: Text('Türkiye')),
                DropdownMenuItem(value: 'US', child: Text('Amerika Birleşik Devletleri')),
                DropdownMenuItem(value: 'DE', child: Text('Almanya')),
                DropdownMenuItem(value: 'FR', child: Text('Fransa')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _changeRegion(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bölge Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Seçilen bölge: Türkiye'),
            const Text('Dil: Türkçe'),
            const Text('Para Birimi: TRY'),
            const Text('Saat Dilimi: Europe/Istanbul'),
            const SizedBox(height: 16),
            const Text('Sağlık Standartları:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• ICD-11, DSM-5-TR'),
            const Text('• WHO Drug Dictionary'),
            const Text('• Turkey İlaç Kurumu'),
            const SizedBox(height: 16),
            const Text('Gizlilik Yasaları:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• KVKK (Birincil)'),
            const Text('• GDPR, HIPAA (İkincil)'),
          ],
        ),
      ),
    );
  }

  void _createNewAnalysis() {
    // TODO: Implement new analysis creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni analiz oluşturuluyor...')),
    );
  }

  void _createNewReport() {
    // TODO: Implement new report creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni rapor oluşturuluyor...')),
    );
  }

  void _changeRegion(String countryCode) {
    // TODO: Implement region change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bölge değiştiriliyor: $countryCode')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
