import 'package:flutter/material.dart';
import 'package:psyclinicai/services/enhanced_security_service.dart';
import 'package:psyclinicai/models/security_models.dart';

class EnhancedSecurityDashboardWidget extends StatefulWidget {
  const EnhancedSecurityDashboardWidget({Key? key}) : super(key: key);

  @override
  State<EnhancedSecurityDashboardWidget> createState() => _EnhancedSecurityDashboardWidgetState();
}

class _EnhancedSecurityDashboardWidgetState extends State<EnhancedSecurityDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedSecurityService _securityService = EnhancedSecurityService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _securityService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Güvenlik Yönetimi'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Uyumluluk'),
            Tab(text: 'Veri Saklama'),
            Tab(text: 'Şifreleme'),
            Tab(text: 'Erişim Kontrolü'),
            Tab(text: 'Anonimleştirme'),
            Tab(text: 'Güvenlik Olayları'),
            Tab(text: 'Denetim Kayıtları'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplianceTab(),
          _buildRetentionTab(),
          _buildEncryptionTab(),
          _buildAccessControlTab(),
          _buildAnonymizationTab(),
          _buildIncidentsTab(),
          _buildAuditTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildComplianceTab() {
    return StreamBuilder<List<ComplianceFramework>>(
      stream: _securityService.complianceStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final frameworks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: frameworks.length,
            itemBuilder: (context, index) {
              final framework = frameworks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: framework.isActive ? Colors.green : Colors.grey,
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(framework.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(framework.description),
                      const SizedBox(height: 4),
                      Text('Bölge: ${framework.region}'),
                      Text('Gereksinimler: ${framework.requirements.length}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(framework.isActive ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(framework.isActive ? 'Duraklat' : 'Etkinleştir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleComplianceAction(value, framework),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildRetentionTab() {
    return StreamBuilder<List<DataRetentionPolicy>>(
      stream: _securityService.retentionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final policies = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: policy.isActive ? Colors.blue : Colors.grey,
                    child: const Icon(
                      Icons.schedule,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(policy.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(policy.description),
                      const SizedBox(height: 4),
                      Text('Veri Türleri: ${policy.dataTypes.length}'),
                      Text('Silme Yöntemi: ${policy.deletionMethod}'),
                      if (policy.requiresApproval) Text('Onay Gerekli: Evet'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(policy.isActive ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(policy.isActive ? 'Duraklat' : 'Etkinleştir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleRetentionAction(value, policy),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEncryptionTab() {
    return StreamBuilder<List<EncryptionConfig>>(
      stream: _securityService.encryptionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final configs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: configs.length,
            itemBuilder: (context, index) {
              final config = configs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: config.isActive ? Colors.purple : Colors.grey,
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(config.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Algoritma: ${config.algorithm}'),
                      Text('Anahtar Boyutu: ${config.keySize} bit'),
                      Text('Anahtar Yönetimi: ${config.keyManagement}'),
                      if (config.isHardwareAccelerated) Text('Donanım Hızlandırılmış: Evet'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(config.isActive ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(config.isActive ? 'Duraklat' : 'Etkinleştir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleEncryptionAction(value, config),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAccessControlTab() {
    return StreamBuilder<List<AccessControlPolicy>>(
      stream: _securityService.accessStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final policies = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: policy.isActive ? Colors.orange : Colors.grey,
                    child: const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(policy.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(policy.description),
                      const SizedBox(height: 4),
                      Text('Roller: ${policy.roles.join(', ')}'),
                      Text('İzinler: ${policy.permissions.length}'),
                      Text('Zorunluluk Seviyesi: ${policy.enforcementLevel}'),
                      if (policy.requiresMFA) Text('MFA Gerekli: Evet'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(policy.isActive ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(policy.isActive ? 'Duraklat' : 'Etkinleştir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleAccessAction(value, policy),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAnonymizationTab() {
    return StreamBuilder<List<DataAnonymizationRule>>(
      stream: _securityService.anonymizationStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rules = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rule.isActive ? Colors.teal : Colors.grey,
                    child: const Icon(
                      Icons.visibility_off,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(rule.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.description),
                      const SizedBox(height: 4),
                      Text('Veri Alanları: ${rule.dataFields.join(', ')}'),
                      Text('Yöntem: ${rule.anonymizationMethod}'),
                      Text('Geri Döndürülebilir: ${rule.isReversible ? 'Evet' : 'Hayır'}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(rule.isActive ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(rule.isActive ? 'Duraklat' : 'Etkinleştir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleAnonymizationAction(value, rule),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildIncidentsTab() {
    return StreamBuilder<List<SecurityIncident>>(
      stream: _securityService.incidentStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final incidents = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSeverityColor(incident.severity),
                    child: Icon(
                      _getSeverityIcon(incident.severity),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(incident.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.description),
                      const SizedBox(height: 4),
                      Text('Durum: ${incident.status}'),
                      Text('Kategori: ${incident.category}'),
                      Text('Bildiren: ${incident.reportedBy}'),
                      Text('Tarih: ${_formatDate(incident.reportedAt)}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Görüntüle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Düzenle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleIncidentAction(value, incident),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAuditTab() {
    return StreamBuilder<List<SecurityAuditLog>>(
      stream: _securityService.auditStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final logs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: log.isSuccessful ? Colors.green : Colors.red,
                    child: Icon(
                      log.isSuccessful ? Icons.check : Icons.error,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('${log.action} - ${log.userId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kaynak: ${log.resource}'),
                      Text('IP: ${log.ipAddress}'),
                      Text('Tarih: ${_formatDate(log.timestamp)}'),
                      if (!log.isSuccessful && log.errorMessage != null)
                        Text('Hata: ${log.errorMessage}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Görüntüle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Sil', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleAuditAction(value, log),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showAddDialog() {
    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0:
        _showAddComplianceDialog();
        break;
      case 1:
        _showAddRetentionDialog();
        break;
      case 2:
        _showAddEncryptionDialog();
        break;
      case 3:
        _showAddAccessDialog();
        break;
      case 4:
        _showAddAnonymizationDialog();
        break;
      case 5:
        _showAddIncidentDialog();
        break;
    }
  }

  void _showAddComplianceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyumluluk Çerçevesi Ekle'),
        content: const Text('Bu özellik demo amaçlıdır. Gerçek uygulamada form alanları eklenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo compliance framework
              final framework = ComplianceFramework(
                id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                name: 'Demo Framework',
                region: 'Demo',
                description: 'Demo compliance framework',
                requirements: ['Requirement 1', 'Requirement 2'],
                configurations: {'demo': true},
                createdAt: DateTime.now(),
              );
              _securityService.createComplianceFramework(framework);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddRetentionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Saklama Politikası Ekle'),
        content: const Text('Bu özellik demo amaçlıdır. Gerçek uygulamada form alanları eklenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo retention policy
              final policy = DataRetentionPolicy(
                id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                name: 'Demo Policy',
                description: 'Demo retention policy',
                retentionPeriods: {'demo_data': 365},
                dataTypes: ['demo_data'],
                deletionMethod: 'secure_deletion',
                createdAt: DateTime.now(),
              );
              _securityService.createRetentionPolicy(policy);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddEncryptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifreleme Konfigürasyonu Ekle'),
        content: const Text('Bu özellik demo amaçlıdır. Gerçek uygulamada form alanları eklenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo encryption config
              final config = EncryptionConfig(
                id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                name: 'Demo Config',
                algorithm: 'AES-256',
                keySize: 256,
                keyManagement: 'Demo KMS',
                settings: {'demo': true},
                createdAt: DateTime.now(),
              );
              _securityService.createEncryptionConfig(config);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erişim Kontrol Politikası Ekle'),
        content: const Text('Bu özellik demo amaçlıdır. Gerçek uygulamada form alanları eklenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo access policy
              final policy = AccessControlPolicy(
                id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                name: 'Demo Policy',
                description: 'Demo access policy',
                roles: ['demo_role'],
                permissions: ['demo_permission'],
                resourceAccess: {'demo_resource': ['read']},
                enforcementLevel: 'strict',
                createdAt: DateTime.now(),
              );
              _securityService.createAccessPolicy(policy);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddAnonymizationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anonimleştirme Kuralı Ekle'),
        content: const Text('Bu özellik demo amaçlıdır. Gerçek uygulamada form alanları eklenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo anonymization rule
              final rule = DataAnonymizationRule(
                id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                name: 'Demo Rule',
                description: 'Demo anonymization rule',
                dataFields: ['demo_field'],
                anonymizationMethod: 'hashing',
                parameters: {'demo': true},
                createdAt: DateTime.now(),
              );
              _securityService.createAnonymizationRule(rule);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddIncidentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güvenlik Olayı Ekle'),
        content: const Text('Bu özellik demo amaçlıdır. Gerçek uygulamada form alanları eklenir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Demo security incident
              final incident = SecurityIncident(
                id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                title: 'Demo Incident',
                description: 'Demo security incident',
                severity: 'medium',
                status: 'investigating',
                category: 'demo',
                reportedBy: 'demo_user',
                reportedAt: DateTime.now(),
                details: {'demo': true},
                createdAt: DateTime.now(),
              );
              _securityService.createSecurityIncident(incident);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _handleComplianceAction(String action, ComplianceFramework framework) {
    switch (action) {
      case 'edit':
        // Edit functionality
        break;
      case 'toggle':
        final updated = ComplianceFramework(
          id: framework.id,
          name: framework.name,
          region: framework.region,
          description: framework.description,
          requirements: framework.requirements,
          configurations: framework.configurations,
          isActive: !framework.isActive,
          createdAt: framework.createdAt,
          updatedAt: DateTime.now(),
        );
        _securityService.updateComplianceFramework(framework.id, updated);
        break;
      case 'delete':
        _securityService.deleteComplianceFramework(framework.id);
        break;
    }
  }

  void _handleRetentionAction(String action, DataRetentionPolicy policy) {
    switch (action) {
      case 'edit':
        // Edit functionality
        break;
      case 'toggle':
        final updated = DataRetentionPolicy(
          id: policy.id,
          name: policy.name,
          description: policy.description,
          retentionPeriods: policy.retentionPeriods,
          dataTypes: policy.dataTypes,
          deletionMethod: policy.deletionMethod,
          requiresApproval: policy.requiresApproval,
          approvers: policy.approvers,
          isActive: !policy.isActive,
          createdAt: policy.createdAt,
          updatedAt: DateTime.now(),
        );
        _securityService.updateRetentionPolicy(policy.id, updated);
        break;
      case 'delete':
        _securityService.deleteRetentionPolicy(policy.id);
        break;
    }
  }

  void _handleEncryptionAction(String action, EncryptionConfig config) {
    switch (action) {
      case 'edit':
        // Edit functionality
        break;
      case 'toggle':
        final updated = EncryptionConfig(
          id: config.id,
          name: config.name,
          algorithm: config.algorithm,
          keySize: config.keySize,
          keyManagement: config.keyManagement,
          isHardwareAccelerated: config.isHardwareAccelerated,
          settings: config.settings,
          isActive: !config.isActive,
          createdAt: config.createdAt,
          updatedAt: DateTime.now(),
        );
        _securityService.updateEncryptionConfig(config.id, updated);
        break;
      case 'delete':
        _securityService.deleteEncryptionConfig(config.id);
        break;
    }
  }

  void _handleAccessAction(String action, AccessControlPolicy policy) {
    switch (action) {
      case 'edit':
        // Edit functionality
        break;
      case 'toggle':
        final updated = AccessControlPolicy(
          id: policy.id,
          name: policy.name,
          description: policy.description,
          roles: policy.roles,
          permissions: policy.permissions,
          resourceAccess: policy.resourceAccess,
          enforcementLevel: policy.enforcementLevel,
          requiresMFA: policy.requiresMFA,
          allowedIPs: policy.allowedIPs,
          allowedDevices: policy.allowedDevices,
          isActive: !policy.isActive,
          createdAt: policy.createdAt,
          updatedAt: DateTime.now(),
        );
        _securityService.updateAccessPolicy(policy.id, updated);
        break;
      case 'delete':
        _securityService.deleteAccessPolicy(policy.id);
        break;
    }
  }

  void _handleAnonymizationAction(String action, DataAnonymizationRule rule) {
    switch (action) {
      case 'edit':
        // Edit functionality
        break;
      case 'toggle':
        final updated = DataAnonymizationRule(
          id: rule.id,
          name: rule.name,
          description: rule.description,
          dataFields: rule.dataFields,
          anonymizationMethod: rule.anonymizationMethod,
          parameters: rule.parameters,
          isReversible: rule.isReversible,
          retentionKey: rule.retentionKey,
          isActive: !rule.isActive,
          createdAt: rule.createdAt,
          updatedAt: DateTime.now(),
        );
        _securityService.updateAnonymizationRule(rule.id, updated);
        break;
      case 'delete':
        _securityService.deleteAnonymizationRule(rule.id);
        break;
    }
  }

  void _handleIncidentAction(String action, SecurityIncident incident) {
    switch (action) {
      case 'view':
        // View functionality
        break;
      case 'edit':
        // Edit functionality
        break;
      case 'delete':
        _securityService.deleteSecurityIncident(incident.id);
        break;
    }
  }

  void _handleAuditAction(String action, SecurityAuditLog log) {
    switch (action) {
      case 'view':
        // View functionality
        break;
      case 'delete':
        // Delete functionality would be implemented here
        break;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class SecurityStatsWidget extends StatefulWidget {
  const SecurityStatsWidget({Key? key}) : super(key: key);

  @override
  State<SecurityStatsWidget> createState() => _SecurityStatsWidgetState();
}

class _SecurityStatsWidgetState extends State<SecurityStatsWidget> {
  final EnhancedSecurityService _securityService = EnhancedSecurityService();

  @override
  Widget build(BuildContext context) {
    final stats = _securityService.getSecurityStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Güvenlik İstatistikleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Uyumluluk Çerçeveleri',
                    '${stats['activeComplianceFrameworks']}/${stats['totalComplianceFrameworks']}',
                    Icons.security,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Aktif Olaylar',
                    '${stats['activeSecurityIncidents']}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Denetim Kayıtları',
                    '${stats['totalAuditLogs']}',
                    Icons.assessment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Başarılı İşlemler',
                    '${stats['successfulAuditLogs']}',
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
