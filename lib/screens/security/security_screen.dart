import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/security_models.dart';
import '../../services/security_service.dart';
import '../../utils/theme.dart';
import '../../widgets/security/security_dashboard_widget.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _securityAnimationController;
  late Animation<double> _fadeAnimation;

  final SecurityService _securityService = SecurityService();
  
  // State variables
  bool _isLoading = false;
  SecurityAssessment? _securityAssessment;
  List<AuditLog> _recentAuditLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _securityAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _securityAnimationController, curve: Curves.easeInOut),
    );

    _initializeSecurity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _securityAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeSecurity() async {
    setState(() => _isLoading = true);

    try {
      await _securityService.initialize();
      
      // Perform security assessment
      _securityAssessment = _securityService.assessSecurity();
      
      // Load recent audit logs
      _recentAuditLogs = _securityService.auditLogs.take(10).toList();
      
      _securityAnimationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güvenlik servisi başlatılamadı: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik & Uyumluluk'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış', icon: Icon(Icons.security)),
            Tab(text: 'Denetim Kayıtları', icon: Icon(Icons.audit)),
            Tab(text: 'Erişim Kontrolü', icon: Icon(Icons.lock)),
            Tab(text: 'Ayarlar', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAuditTab(),
          _buildAccessControlTab(),
          _buildSettingsTab(),
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
          Text(
            'Güvenlik Durumu',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_securityAssessment != null)
            _buildSecurityOverview(_securityAssessment!)
          else
            const Center(
              child: Text('Güvenlik değerlendirmesi yapılamadı'),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityOverview(SecurityAssessment assessment) {
    return Column(
      children: [
        // Security Score Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _getSecurityIcon(assessment.securityLevel),
                      size: 48,
                      color: _getSecurityColor(assessment.securityLevel),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Güvenlik Seviyesi: ${_getSecurityText(assessment.securityLevel)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Son değerlendirme: ${_formatDate(assessment.timestamp)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Security Score
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getSecurityColor(assessment.securityLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSecurityColor(assessment.securityLevel).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${assessment.overallScore.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getSecurityColor(assessment.securityLevel),
                        ),
                      ),
                      Text(
                        'Güvenlik Puanı',
                        style: TextStyle(
                          fontSize: 16,
                          color: _getSecurityColor(assessment.securityLevel),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Vulnerabilities Card
        if (assessment.vulnerabilities.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Güvenlik Açıkları (${assessment.vulnerabilities.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...assessment.vulnerabilities.map((vuln) => _buildVulnerabilityItem(vuln)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
        
        // Recommendations Card
        if (assessment.recommendations.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Öneriler (${assessment.recommendations.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...assessment.recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(rec)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVulnerabilityItem(SecurityVulnerability vulnerability) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getVulnerabilityColor(vulnerability.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getVulnerabilityColor(vulnerability.severity).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getVulnerabilityIcon(vulnerability.severity),
                color: _getVulnerabilityColor(vulnerability.severity),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vulnerability.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVulnerabilityColor(vulnerability.severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getVulnerabilityText(vulnerability.severity),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Öneri: ${vulnerability.recommendation}',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Denetim Kayıtları',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: _exportAuditLogs,
                icon: const Icon(Icons.download),
                label: const Text('Dışa Aktar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_recentAuditLogs.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.audit_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz denetim kaydı yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._recentAuditLogs.map((log) => _buildAuditLogItem(log)),
        ],
      ),
    );
  }

  Widget _buildAuditLogItem(AuditLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAuditEventIcon(log.eventType),
                  color: _getSecurityColor(log.securityLevel),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_formatDate(log.timestamp)} - ${log.userId}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSecurityColor(log.securityLevel).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSecurityText(log.securityLevel),
                    style: TextStyle(
                      color: _getSecurityColor(log.securityLevel),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (log.resourceId != null || log.action != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (log.action != null) ...[
                    Text('Eylem: ${log.action}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                  ],
                  if (log.resourceId != null)
                    Text('Kaynak: ${log.resourceId}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
            
            if (log.metadata.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Meta: ${log.metadata.toString()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccessControlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erişim Kontrolü',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kullanıcı Rolleri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...UserRole.values.map((role) => _buildRoleItem(role)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İzin Kontrolü',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildPermissionTest(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem(UserRole role) {
    return ListTile(
      leading: Icon(
        _getRoleIcon(role),
        color: _getRoleColor(role),
      ),
      title: Text(_getRoleText(role)),
      subtitle: Text(_getRoleDescription(role)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getRoleColor(role).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _getRolePermissions(role).length.toString(),
          style: TextStyle(
            color: _getRoleColor(role),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTest() {
    return Column(
      children: [
        const Text('Test kullanıcısı için izin kontrolü:'),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'read:clients',
            'write:sessions',
            'admin:users',
            'audit:view',
          ].map((permission) => ElevatedButton(
            onPressed: () => _testPermission(permission),
            child: Text(permission),
          )).toList(),
        ),
        
        const SizedBox(height: 16),
        
        const Text('Sonuç:'),
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Test kullanıcısı için izin kontrolü yapıldı'),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenlik Ayarları',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temel Güvenlik',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Veri Şifreleme'),
                    subtitle: const Text('Hassas verileri şifrele'),
                    value: _securityService.encryptionEnabled,
                    onChanged: (value) => _updateSecuritySetting('encryption', value),
                  ),
                  
                  SwitchListTile(
                    title: const Text('Denetim Kaydı'),
                    subtitle: const Text('Tüm işlemleri kaydet'),
                    value: _securityService.auditLoggingEnabled,
                    onChanged: (value) => _updateSecuritySetting('audit', value),
                  ),
                  
                  SwitchListTile(
                    title: const Text('Rol Tabanlı Erişim'),
                    subtitle: const Text('Kullanıcı izinlerini sınırla'),
                    value: _securityService.roleBasedAccessEnabled,
                    onChanged: (value) => _updateSecuritySetting('access', value),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oturum Ayarları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    title: const Text('Oturum Zaman Aşımı'),
                    subtitle: const Text('30 dakika'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showSessionTimeoutDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Maksimum Giriş Denemesi'),
                    subtitle: const Text('5 deneme'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLoginAttemptsDialog(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bakım İşlemleri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: _runSecurityAssessment,
                    icon: const Icon(Icons.security),
                    label: const Text('Güvenlik Değerlendirmesi Çalıştır'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ElevatedButton.icon(
                    onPressed: _clearAuditLogs,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Denetim Kayıtlarını Temizle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getSecurityIcon(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.low:
        return Icons.warning;
      case SecurityLevel.standard:
        return Icons.check_circle;
      case SecurityLevel.medium:
        return Icons.security;
      case SecurityLevel.high:
        return Icons.verified;
      case SecurityLevel.critical:
        return Icons.dangerous;
    }
  }

  Color _getSecurityColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.low:
        return Colors.red;
      case SecurityLevel.standard:
        return Colors.orange;
      case SecurityLevel.medium:
        return Colors.yellow;
      case SecurityLevel.high:
        return Colors.green;
      case SecurityLevel.critical:
        return Colors.purple;
    }
  }

  String _getSecurityText(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.low:
        return 'Düşük';
      case SecurityLevel.standard:
        return 'Standart';
      case SecurityLevel.medium:
        return 'Orta';
      case SecurityLevel.high:
        return 'Yüksek';
      case SecurityLevel.critical:
        return 'Kritik';
    }
  }

  IconData _getVulnerabilityIcon(VulnerabilitySeverity severity) {
    switch (severity) {
      case VulnerabilitySeverity.low:
        return Icons.info;
      case VulnerabilitySeverity.medium:
        return Icons.warning;
      case VulnerabilitySeverity.high:
        return Icons.error;
      case VulnerabilitySeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getVulnerabilityColor(VulnerabilitySeverity severity) {
    switch (severity) {
      case VulnerabilitySeverity.low:
        return Colors.blue;
      case VulnerabilitySeverity.medium:
        return Colors.orange;
      case VulnerabilitySeverity.high:
        return Colors.red;
      case VulnerabilitySeverity.critical:
        return Colors.purple;
    }
  }

  String _getVulnerabilityText(VulnerabilitySeverity severity) {
    switch (severity) {
      case VulnerabilitySeverity.low:
        return 'Düşük';
      case VulnerabilitySeverity.medium:
        return 'Orta';
      case VulnerabilitySeverity.high:
        return 'Yüksek';
      case VulnerabilitySeverity.critical:
        return 'Kritik';
    }
  }

  IconData _getAuditEventIcon(AuditEventType eventType) {
    switch (eventType) {
      case AuditEventType.authentication:
        return Icons.login;
      case AuditEventType.authorization:
        return Icons.lock;
      case AuditEventType.data_access:
        return Icons.visibility;
      case AuditEventType.data_modification:
        return Icons.edit;
      case AuditEventType.system:
        return Icons.computer;
      case AuditEventType.security:
        return Icons.security;
      case AuditEventType.audit:
        return Icons.audit;
      case AuditEventType.user_management:
        return Icons.people;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.therapist:
        return Icons.psychology;
      case UserRole.supervisor:
        return Icons.supervisor_account;
      case UserRole.client:
        return Icons.person;
      case UserRole.guest:
        return Icons.person_outline;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.therapist:
        return Colors.blue;
      case UserRole.supervisor:
        return Colors.purple;
      case UserRole.client:
        return Colors.green;
      case UserRole.guest:
        return Colors.grey;
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Yönetici';
      case UserRole.therapist:
        return 'Terapist';
      case UserRole.supervisor:
        return 'Süpervizör';
      case UserRole.client:
        return 'Danışan';
      case UserRole.guest:
        return 'Misafir';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Tam sistem erişimi';
      case UserRole.therapist:
        return 'Terapi ve danışan yönetimi';
      case UserRole.supervisor:
        return 'Terapist süpervizyonu';
      case UserRole.client:
        return 'Kendi verilerine erişim';
      case UserRole.guest:
        return 'Sınırlı erişim';
    }
  }

  List<String> _getRolePermissions(UserRole role) {
    // This would come from the security service
    switch (role) {
      case UserRole.admin:
        return ['read:all', 'write:all', 'delete:all', 'admin:users'];
      case UserRole.therapist:
        return ['read:clients', 'write:clients', 'read:sessions', 'write:sessions'];
      case UserRole.supervisor:
        return ['read:therapists', 'read:clients', 'audit:view'];
      case UserRole.client:
        return ['read:own_profile', 'write:own_profile'];
      case UserRole.guest:
        return ['read:public'];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  // Action methods
  Future<void> _exportAuditLogs() async {
    try {
      final logsJson = await _securityService.exportAuditLogs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denetim kayıtları dışa aktarıldı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dışa aktarma başarısız: $e')),
        );
      }
    }
  }

  void _testPermission(String permission) {
    // TODO: Implement permission testing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('İzin test edildi: $permission')),
    );
  }

  Future<void> _updateSecuritySetting(String setting, bool value) async {
    try {
      switch (setting) {
        case 'encryption':
          await _securityService.updateSecuritySettings(encryptionEnabled: value);
          break;
        case 'audit':
          await _securityService.updateSecuritySettings(auditLoggingEnabled: value);
          break;
        case 'access':
          await _securityService.updateSecuritySettings(roleBasedAccessEnabled: value);
          break;
      }
      
      // Refresh assessment
      _securityAssessment = _securityService.assessSecurity();
      
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güvenlik ayarı güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ayar güncellenemedi: $e')),
        );
      }
    }
  }

  void _showSessionTimeoutDialog() {
    // TODO: Implement session timeout dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oturum zaman aşımı ayarı yakında')),
    );
  }

  void _showLoginAttemptsDialog() {
    // TODO: Implement login attempts dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Giriş denemesi ayarı yakında')),
    );
  }

  Future<void> _runSecurityAssessment() async {
    try {
      _securityAssessment = _securityService.assessSecurity();
      
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güvenlik değerlendirmesi tamamlandı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Değerlendirme başarısız: $e')),
        );
      }
    }
  }

  Future<void> _clearAuditLogs() async {
    try {
      await _securityService.clearAuditLogs(keepLast: 100);
      _recentAuditLogs = _securityService.auditLogs.take(10).toList();
      
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denetim kayıtları temizlendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Temizleme başarısız: $e')),
        );
      }
    }
  }
}
