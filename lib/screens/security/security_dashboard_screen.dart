import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../config/region_config.dart';
import '../../models/security_models.dart';
import '../../services/security_service.dart';
import '../../widgets/security/compliance_widget.dart';
import '../../widgets/security/audit_log_widget.dart';
import '../../widgets/security/encryption_widget.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> with TickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  bool _isLoading = true;
  SecurityStatus? _securityStatus;
  List<AuditLog> _auditLogs = [];
  List<ComplianceReport> _complianceReports = [];
  List<SecurityIncident> _securityIncidents = [];
  List<DataRetentionPolicy> _retentionPolicies = [];
  List<AccessControlPolicy> _accessPolicies = [];
  EncryptionConfig? _encryptionConfig;
  Map<ComplianceFramework, bool> _complianceStatus = {};

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadSecurityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);
    try {
      await _securityService.initialize();
      
      final status = _securityService.getSecurityStatus();
      final logs = _securityService.getAuditLogs();
      final reports = _securityService.getComplianceReports();
      final incidents = _securityService.getSecurityIncidents();
      final policies = _securityService.getRetentionPolicies();
      final accessPolicies = _securityService.getAccessPolicies();
      final encryptionConfig = _securityService.getEncryptionConfig();
      final compliance = _securityService.checkCompliance();
      
      setState(() {
        _securityStatus = status;
        _auditLogs = logs;
        _complianceReports = reports;
        _securityIncidents = incidents;
        _retentionPolicies = policies;
        _accessPolicies = accessPolicies;
        _encryptionConfig = encryptionConfig;
        _complianceStatus = compliance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güvenlik verisi yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik & Uyumluluk Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış', icon: Icon(Icons.dashboard)),
            Tab(text: 'Uyumluluk', icon: Icon(Icons.verified)),
            Tab(text: 'Güvenlik Olayları', icon: Icon(Icons.security)),
            Tab(text: 'Veri Politikaları', icon: Icon(Icons.policy)),
            Tab(text: 'Erişim Kontrolü', icon: Icon(Icons.lock)),
            Tab(text: 'Denetim Kayıtları', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSecuritySettings,
            tooltip: 'Güvenlik Ayarları',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildComplianceTab(),
                _buildIncidentsTab(),
                _buildPoliciesTab(),
                _buildAccessControlTab(),
                _buildAuditTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölge Bilgisi ve Uyarılar
          _buildRegionInfoSection(),
          
          const SizedBox(height: 24),
          
          // Güvenlik Durumu
          _buildSecurityStatusSection(),
          
          const SizedBox(height: 24),
          
          // Şifreleme Durumu
          _buildEncryptionSection(),
          
          const SizedBox(height: 24),
          
          // Aktif Güvenlik Olayları
          _buildActiveIncidentsSection(),
          
          const SizedBox(height: 24),
          
          // Hızlı Aksiyonlar
          _buildQuickActionsSection(),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yasal Uyumluluk Durumu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Uyumluluk Çerçeveleri
          _buildComplianceFrameworksSection(),
          
          const SizedBox(height: 24),
          
          // Uyumluluk Raporları
          _buildComplianceReportsSection(),
        ],
      ),
    );
  }

  Widget _buildIncidentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Güvenlik Olayları',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateIncidentDialog,
                icon: const Icon(Icons.add),
                label: const Text('Olay Oluştur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Olay İstatistikleri
          _buildIncidentStatistics(),
          
          const SizedBox(height: 24),
          
          // Olay Listesi
          _buildIncidentsList(),
        ],
      ),
    );
  }

  Widget _buildPoliciesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veri Saklama Politikaları',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Veri Saklama Politikaları
          _buildRetentionPoliciesSection(),
          
          const SizedBox(height: 24),
          
          // Anonimleştirme Kuralları
          _buildAnonymizationSection(),
        ],
      ),
    );
  }

  Widget _buildAccessControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Erişim Kontrol Politikaları',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreatePolicyDialog,
                icon: const Icon(Icons.add),
                label: const Text('Politika Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Erişim Politikaları
          _buildAccessPoliciesSection(),
        ],
      ),
    );
  }

  Widget _buildAuditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Denetim Kayıtları',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Denetim Kayıtları
          _buildAuditLogSection(),
        ],
      ),
    );
  }

  Widget _buildRegionInfoSection() {
    final region = RegionConfig.currentRegion;
    final regionInfo = RegionConfig.getRegionInfo(region);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bölge: ${regionInfo.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Uyumluluk: ${regionInfo.compliance}'),
            Text('Veri Merkezi: ${regionInfo.hosting}'),
            if (regionInfo.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ ${regionInfo.warnings.first}',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusSection() {
    if (_securityStatus == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _securityStatus!.securityColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Güvenlik Durumu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Genel Skor
            _buildScoreCard(
              'Genel Skor',
              _securityStatus!.overallScore,
              _securityStatus!.securityColor,
            ),
            
            const SizedBox(height: 16),
            
            // Detay Skorlar
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    'Şifreleme',
                    _securityStatus!.encryptionScore,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildScoreCard(
                    'Erişim Kontrolü',
                    _securityStatus!.accessControlScore,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    'Denetim',
                    _securityStatus!.auditScore,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildScoreCard(
                    'Güncelleme',
                    _securityStatus!.lastUpdated.day.toDouble(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            if (_securityStatus!.issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Güvenlik Sorunları',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._securityStatus!.issues.map((issue) => _buildIssueCard(issue)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, double score, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(SecurityIssue issue) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.red.shade50,
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: Colors.red.shade600,
        ),
        title: Text(
          issue.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(issue.description),
        trailing: Chip(
          label: Text(issue.severity.name.toUpperCase()),
          backgroundColor: Colors.red.shade100,
          labelStyle: TextStyle(color: Colors.red.shade800),
        ),
      ),
    );
  }

  Widget _buildEncryptionSection() {
    if (_encryptionConfig == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Şifreleme Durumu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Algoritma', _encryptionConfig!.algorithm),
            _buildInfoRow('Anahtar Boyutu', '${_encryptionConfig!.keySize} bit'),
            _buildInfoRow('Anahtar Rotasyonu', _encryptionConfig!.keyRotationPeriod),
            _buildInfoRow('Donanım Hızlandırma', _encryptionConfig!.hardwareAcceleration ? 'Aktif' : 'Pasif'),
            _buildInfoRow('Son Rotasyon', _formatDate(_encryptionConfig!.lastKeyRotation)),
            _buildInfoRow('Sonraki Rotasyon', _formatDate(_encryptionConfig!.nextKeyRotation)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveIncidentsSection() {
    final activeIncidents = _securityIncidents.where((i) => !i.isResolved).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aktif Güvenlik Olayları (${activeIncidents.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (activeIncidents.isEmpty)
              const Text('Aktif güvenlik olayı bulunmuyor.')
            else
              ...activeIncidents.take(3).map((incident) => _buildIncidentCard(incident)),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentCard(SecurityIncident incident) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          _getIncidentIcon(incident.type),
          color: _getIncidentColor(incident.severity),
        ),
        title: Text(
          incident.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(incident.description),
        trailing: Chip(
          label: Text(incident.severity.name.toUpperCase()),
          backgroundColor: _getIncidentColor(incident.severity).withOpacity(0.2),
          labelStyle: TextStyle(color: _getIncidentColor(incident.severity)),
        ),
      ),
    );
  }

  IconData _getIncidentIcon(SecurityIncidentType type) {
    switch (type) {
      case SecurityIncidentType.unauthorizedAccess:
        return Icons.person_off;
      case SecurityIncidentType.dataBreach:
        return Icons.data_usage;
      case SecurityIncidentType.malware:
        return Icons.bug_report;
      case SecurityIncidentType.phishing:
        return Icons.fishing;
      case SecurityIncidentType.socialEngineering:
        return Icons.psychology;
      case SecurityIncidentType.physicalSecurity:
        return Icons.security;
      case SecurityIncidentType.networkAttack:
        return Icons.wifi_off;
      case SecurityIncidentType.other:
        return Icons.warning;
    }
  }

  Color _getIncidentColor(SecurityIncidentSeverity severity) {
    switch (severity) {
      case SecurityIncidentSeverity.low:
        return Colors.green;
      case SecurityIncidentSeverity.medium:
        return Colors.orange;
      case SecurityIncidentSeverity.high:
        return Colors.red;
      case SecurityIncidentSeverity.critical:
        return Colors.purple;
    }
  }

  Widget _buildQuickActionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hızlı Aksiyonlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportSecurityReport,
                    icon: const Icon(Icons.download),
                    label: const Text('Rapor İndir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showBackupDialog,
                    icon: const Icon(Icons.backup),
                    label: const Text('Yedekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showKeyRotationDialog,
                    icon: const Icon(Icons.key),
                    label: const Text('Anahtar Rotasyonu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showComplianceCheckDialog,
                    icon: const Icon(Icons.verified),
                    label: const Text('Uyumluluk Kontrolü'),
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

  Widget _buildComplianceFrameworksSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uyumluluk Çerçeveleri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...ComplianceFramework.values.map((framework) {
              final isCompliant = _complianceStatus[framework] ?? false;
              return ListTile(
                leading: Icon(
                  isCompliant ? Icons.check_circle : Icons.cancel,
                  color: isCompliant ? Colors.green : Colors.red,
                ),
                title: Text(_getFrameworkName(framework)),
                subtitle: Text(_getFrameworkDescription(framework)),
                trailing: Chip(
                  label: Text(isCompliant ? 'Uyumlu' : 'Uyumlu Değil'),
                  backgroundColor: isCompliant ? Colors.green.shade100 : Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: isCompliant ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getFrameworkName(ComplianceFramework framework) {
    switch (framework) {
      case ComplianceFramework.hipaa:
        return 'HIPAA (ABD)';
      case ComplianceFramework.gdpr:
        return 'GDPR (Avrupa)';
      case ComplianceFramework.kvkk:
        return 'KVKK (Türkiye)';
      case ComplianceFramework.pipeda:
        return 'PIPEDA (Kanada)';
      case ComplianceFramework.sox:
        return 'SOX (ABD Finansal)';
      case ComplianceFramework.iso27001:
        return 'ISO 27001 (Uluslararası)';
    }
  }

  String _getFrameworkDescription(ComplianceFramework framework) {
    switch (framework) {
      case ComplianceFramework.hipaa:
        return 'Sağlık Bilgilerinin Korunması ve Taşınabilirliği Yasası';
      case ComplianceFramework.gdpr:
        return 'Genel Veri Koruma Yönetmeliği';
      case ComplianceFramework.kvkk:
        return 'Kişisel Verilerin Korunması Kanunu';
      case ComplianceFramework.pipeda:
        return 'Kişisel Bilgilerin Korunması ve Elektronik Belge Yasası';
      case ComplianceFramework.sox:
        return 'Sarbanes-Oxley Yasası';
      case ComplianceFramework.iso27001:
        return 'Bilgi Güvenliği Yönetim Sistemi Standardı';
    }
  }

  Widget _buildComplianceReportsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uyumluluk Raporları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_complianceReports.isEmpty)
              const Text('Uyumluluk raporu bulunmuyor.')
            else
              ..._complianceReports.map((report) => _buildComplianceReportCard(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceReportCard(ComplianceReport report) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          report.status == ComplianceStatus.compliant ? Icons.check_circle : Icons.warning,
          color: report.status == ComplianceStatus.compliant ? Colors.green : Colors.orange,
        ),
        title: Text(
          report.complianceType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.notes),
            Text('Son kontrol: ${_formatDate(report.lastChecked)}'),
            Text('Sonraki kontrol: ${_formatDate(report.nextCheck)}'),
          ],
        ),
        trailing: Chip(
          label: Text(report.status.name.toUpperCase()),
          backgroundColor: report.status == ComplianceStatus.compliant 
              ? Colors.green.shade100 
              : Colors.orange.shade100,
          labelStyle: TextStyle(
            color: report.status == ComplianceStatus.compliant 
                ? Colors.green.shade800 
                : Colors.orange.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentStatistics() {
    final totalIncidents = _securityIncidents.length;
    final activeIncidents = _securityIncidents.where((i) => !i.isResolved).length;
    final criticalIncidents = _securityIncidents.where((i) => i.severity == SecurityIncidentSeverity.critical).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Toplam Olay', totalIncidents.toString(), Colors.blue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Aktif Olay', activeIncidents.toString(), Colors.orange),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Kritik Olay', criticalIncidents.toString(), Colors.red),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentsList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tüm Güvenlik Olayları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_securityIncidents.isEmpty)
              const Text('Güvenlik olayı bulunmuyor.')
            else
              ..._securityIncidents.map((incident) => _buildIncidentCard(incident)),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionPoliciesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Saklama Politikaları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_retentionPolicies.isEmpty)
              const Text('Veri saklama politikası bulunmuyor.')
            else
              ..._retentionPolicies.map((policy) => _buildPolicyCard(policy)),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard(DataRetentionPolicy policy) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          Icons.policy,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          policy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(policy.description),
            Text('Saklama süresi: ${policy.retentionPeriod.inDays} gün'),
            Text('Otomatik silme: ${policy.autoDelete ? 'Aktif' : 'Pasif'}'),
            if (policy.lastReview != null)
              Text('Son inceleme: ${_formatDate(policy.lastReview!)}'),
          ],
        ),
        trailing: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildAnonymizationSection() {
    final rules = _securityService.getAnonymizationRules();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Anonimleştirme Kuralları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (rules.isEmpty)
              const Text('Anonimleştirme kuralı bulunmuyor.')
            else
              ...rules.map((rule) => _buildAnonymizationRuleCard(rule)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymizationRuleCard(DataAnonymizationRule rule) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          Icons.visibility_off,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          rule.fieldName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Tip: ${rule.type.name}'),
        trailing: Switch(
          value: rule.isActive,
          onChanged: (value) {
            // Anonimleştirme kuralını aktif/pasif yap
          },
        ),
      ),
    );
  }

  Widget _buildAccessPoliciesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Erişim Kontrol Politikaları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_accessPolicies.isEmpty)
              const Text('Erişim kontrol politikası bulunmuyor.')
            else
              ..._accessPolicies.map((policy) => _buildAccessPolicyCard(policy)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessPolicyCard(AccessControlPolicy policy) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          Icons.lock,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          policy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(policy.description),
            Text('Roller: ${policy.roles.join(', ')}'),
            Text('İzinler: ${policy.permissions.join(', ')}'),
          ],
        ),
        trailing: Switch(
          value: policy.isActive,
          onChanged: (value) {
            // Politikayı aktif/pasif yap
          },
        ),
      ),
    );
  }

  Widget _buildAuditLogSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Denetim Kayıtları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_auditLogs.isEmpty)
              const Text('Denetim kaydı bulunmuyor.')
            else
              ..._auditLogs.take(10).map((log) => _buildAuditLogCard(log)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogCard(AuditLog log) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          _getAuditLogIcon(log.type),
          color: _getAuditLogColor(log.type),
        ),
        title: Text(
          log.action,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kullanıcı: ${log.userName}'),
            Text('Tarih: ${_formatDate(log.timestamp)}'),
            if (log.resourceType != null)
              Text('Kaynak: ${log.resourceType}'),
          ],
        ),
        trailing: Chip(
          label: Text(log.type.name.toUpperCase()),
          backgroundColor: _getAuditLogColor(log.type).withOpacity(0.2),
          labelStyle: TextStyle(color: _getAuditLogColor(log.type)),
        ),
      ),
    );
  }

  IconData _getAuditLogIcon(AuditLogType type) {
    switch (type) {
      case AuditLogType.login:
        return Icons.login;
      case AuditLogType.logout:
        return Icons.logout;
      case AuditLogType.dataAccess:
        return Icons.visibility;
      case AuditLogType.dataModification:
        return Icons.edit;
      case AuditLogType.security:
        return Icons.security;
      case AuditLogType.system:
        return Icons.settings;
    }
  }

  Color _getAuditLogColor(AuditLogType type) {
    switch (type) {
      case AuditLogType.login:
        return Colors.green;
      case AuditLogType.logout:
        return Colors.blue;
      case AuditLogType.dataAccess:
        return Colors.orange;
      case AuditLogType.dataModification:
        return Colors.purple;
      case AuditLogType.security:
        return Colors.red;
      case AuditLogType.system:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  // Dialog metodları
  void _showSecuritySettings() {
    // Güvenlik ayarları dialog'u
  }

  void _showCreateIncidentDialog() {
    // Güvenlik olayı oluşturma dialog'u
  }

  void _showCreatePolicyDialog() {
    // Politika oluşturma dialog'u
  }

  void _exportSecurityReport() {
    // Güvenlik raporu export etme
  }

  void _showBackupDialog() {
    // Yedekleme dialog'u
  }

  void _showKeyRotationDialog() {
    // Anahtar rotasyonu dialog'u
  }

  void _showComplianceCheckDialog() {
    // Uyumluluk kontrolü dialog'u
  }
}
