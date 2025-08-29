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

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  final SecurityService _securityService = SecurityService();
  bool _isLoading = true;
  SecurityStatus? _securityStatus;
  List<AuditLog> _auditLogs = [];
  List<ComplianceReport> _complianceReports = [];

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);
    try {
      final status = await _securityService.getSecurityStatus();
      final logs = await _securityService.getAuditLogs();
      final reports = await _securityService.getComplianceReports();
      
      setState(() {
        _securityStatus = status;
        _auditLogs = logs;
        _complianceReports = reports;
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
          : _securityStatus == null
              ? const Center(child: Text('Güvenlik verisi bulunamadı'))
              : SingleChildScrollView(
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
                      
                      // Uyumluluk Raporları
                      _buildComplianceSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Denetim Kayıtları
                      _buildAuditLogSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Şifreleme Durumu
                      _buildEncryptionSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Erişim Kontrolü
                      _buildAccessControlSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRegionInfoSection() {
    final regionInfo = RegionConfig.activeRegionInfo;
    
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
                Icons.public,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Aktif Bölge: ${regionInfo.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bölge bilgileri
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Tanı Standardı',
                  regionInfo.diagnosisStandard,
                  Icons.medical_services,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Yasal Uyumluluk',
                  regionInfo.legalCompliance.join(', '),
                  Icons.gavel,
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Uyarılar
          if (regionInfo.warnings.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bölgesel Uyarılar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...regionInfo.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(left: 28, top: 4),
                    child: Text(
                      '• $warning',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityStatusSection() {
    if (_securityStatus == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Güvenlik Durumu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildSecurityCard(
                'Genel Güvenlik',
                _securityStatus!.overallScore,
                _getSecurityColor(_securityStatus!.overallScore),
                Icons.security,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecurityCard(
                'Şifreleme',
                _securityStatus!.encryptionScore,
                _getSecurityColor(_securityStatus!.encryptionScore),
                Icons.lock,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildSecurityCard(
                'Erişim Kontrolü',
                _securityStatus!.accessControlScore,
                _getSecurityColor(_securityStatus!.accessControlScore),
                Icons.verified_user,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecurityCard(
                'Denetim Kaydı',
                _securityStatus!.auditScore,
                _getSecurityColor(_securityStatus!.auditScore),
                Icons.assignment,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplianceSection() {
    if (_complianceReports.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uyumluluk Raporları',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _complianceReports.length,
          itemBuilder: (context, index) {
            final report = _complianceReports[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getComplianceIcon(report.status),
                        color: _getComplianceColor(report.status),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.complianceType,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getComplianceColor(report.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          report.status.name,
                          style: TextStyle(
                            color: _getComplianceColor(report.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Son kontrol: ${_formatDate(report.lastChecked)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (report.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      report.notes,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuditLogSection() {
    if (_auditLogs.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Denetim Kayıtları',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListView.builder(
            itemCount: _auditLogs.length,
            itemBuilder: (context, index) {
              final log = _auditLogs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getLogTypeColor(log.type).withOpacity(0.1),
                  child: Icon(
                    _getLogTypeIcon(log.type),
                    color: _getLogTypeColor(log.type),
                    size: 20,
                  ),
                ),
                title: Text(
                  log.action,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${log.userName} - ${_formatDate(log.timestamp)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLogTypeColor(log.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.type.name,
                    style: TextStyle(
                      color: _getLogTypeColor(log.type),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEncryptionSection() {
    final securityConfig = SecurityConfig.activeSecurityConfig;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şifreleme Durumu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              _buildEncryptionRow('Algoritma', SecurityConfig.encryptionAlgorithm),
              _buildEncryptionRow('Anahtar Boyutu', '${SecurityConfig.keySize} bit'),
              _buildEncryptionRow('Mod', SecurityConfig.encryptionMode),
              _buildEncryptionRow('Denetim Kaydı', SecurityConfig.auditLogRequired ? 'Aktif' : 'Pasif'),
              _buildEncryptionRow('Erişim Kontrolü', SecurityConfig.accessControlRequired ? 'Aktif' : 'Pasif'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Erişim Kontrolü',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildAccessControlCard(
                'Rol Bazlı Erişim',
                SecurityConfig.roleBasedAccessRequired ? 'Aktif' : 'Pasif',
                SecurityConfig.roleBasedAccessRequired ? Colors.green : Colors.grey,
                Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAccessControlCard(
                'Çok Faktörlü Doğrulama',
                'Aktif',
                Colors.green,
                Icons.phone_android,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildAccessControlCard(
                'Oturum Yönetimi',
                'Aktif',
                Colors.green,
                Icons.session,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAccessControlCard(
                'IP Kısıtlaması',
                'Aktif',
                Colors.green,
                Icons.location_on,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(String title, double score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${score.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessControlCard(String title, String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSecurityColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  IconData _getComplianceIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.warning:
        return Icons.warning;
      case ComplianceStatus.nonCompliant:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getComplianceColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Colors.green;
      case ComplianceStatus.warning:
        return Colors.orange;
      case ComplianceStatus.nonCompliant:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLogTypeIcon(AuditLogType type) {
    switch (type) {
      case AuditLogType.login:
        return Icons.login;
      case AuditLogType.dataAccess:
        return Icons.data_usage;
      case AuditLogType.dataModification:
        return Icons.edit;
      case AuditLogType.security:
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  Color _getLogTypeColor(AuditLogType type) {
    switch (type) {
      case AuditLogType.login:
        return Colors.blue;
      case AuditLogType.dataAccess:
        return Colors.green;
      case AuditLogType.dataModification:
        return Colors.orange;
      case AuditLogType.security:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showSecuritySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güvenlik Ayarları'),
        content: const Text('Güvenlik ayarları yakında eklenecek'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
