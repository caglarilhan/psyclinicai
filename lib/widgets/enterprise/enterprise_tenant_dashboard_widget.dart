import 'package:flutter/material.dart';
import 'package:psyclinicai/models/enterprise_models.dart';
import 'package:psyclinicai/services/enterprise_tenant_service.dart';

/// Enterprise Tenant Dashboard Widget for PsyClinicAI
/// Provides comprehensive tenant management and analytics
class EnterpriseTenantDashboardWidget extends StatefulWidget {
  const EnterpriseTenantDashboardWidget({Key? key}) : super(key: key);

  @override
  State<EnterpriseTenantDashboardWidget> createState() => _EnterpriseTenantDashboardWidgetState();
}

class _EnterpriseTenantDashboardWidgetState extends State<EnterpriseTenantDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final EnterpriseTenantService _tenantService = EnterpriseTenantService();

  // State variables
  bool _isLoading = false;
  List<EnterpriseTenant> _tenants = [];
  EnterpriseTenant? _selectedTenant;
  List<EnterpriseUser> _tenantUsers = [];
  List<Role> _tenantRoles = [];
  Map<String, dynamic> _tenantAnalytics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadTenantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load tenant data
  Future<void> _loadTenantData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _tenantService.initialize();
      _tenants = await _tenantService.getAllTenants();
      
      if (_tenants.isNotEmpty) {
        _selectedTenant = _tenants.first;
        await _loadTenantDetails(_selectedTenant!.id);
      }
      
      print('✅ Enterprise tenant data loaded successfully');
    } catch (e) {
      print('❌ Failed to load tenant data: $e');
      _showErrorSnackBar('Failed to load tenant data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load details for a specific tenant
  Future<void> _loadTenantDetails(String tenantId) async {
    try {
      final futures = await Future.wait([
        _tenantService.getTenantUsers(tenantId),
        _tenantService.getTenantRoles(tenantId),
        _tenantService.getTenantAnalytics(tenantId),
      ]);

      setState(() {
        _tenantUsers = futures[0] as List<EnterpriseUser>;
        _tenantRoles = futures[1] as List<Role>;
        _tenantAnalytics = futures[2] as Map<String, dynamic>;
      });
    } catch (e) {
      print('❌ Failed to load tenant details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏢 Enterprise Tenant Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: _showCreateTenantDialog,
            tooltip: 'Create New Tenant',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTenantData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.business), text: 'Tenants'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.security), text: 'Security'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTenantsTab(),
                _buildUsersTab(),
                _buildSecurityTab(),
                _buildAnalyticsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  /// Overview Tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTenantSelector(),
          const SizedBox(height: 24),
          _buildOverviewCards(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  /// Tenant Selector
  Widget _buildTenantSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏢 Select Tenant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EnterpriseTenant>(
              value: _selectedTenant,
              decoration: const InputDecoration(
                labelText: 'Current Tenant',
                border: OutlineInputBorder(),
              ),
              items: _tenants.map((tenant) {
                return DropdownMenuItem(
                  value: tenant,
                  child: Row(
                    children: [
                      _buildTenantStatusIndicator(tenant.status),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(tenant.domain, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      _buildTenantTierChip(tenant.tier),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (tenant) async {
                if (tenant != null) {
                  setState(() {
                    _selectedTenant = tenant;
                  });
                  await _loadTenantDetails(tenant.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Overview Cards
  Widget _buildOverviewCards() {
    if (_selectedTenant == null) return Container();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildOverviewCard(
          title: 'Total Users',
          value: '${_selectedTenant!.currentUsers}/${_selectedTenant!.maxUsers}',
          icon: Icons.people,
          color: Colors.blue,
          subtitle: 'Active users',
        ),
        _buildOverviewCard(
          title: 'Storage Usage',
          value: '${_selectedTenant!.storageUsagePercentage.toStringAsFixed(1)}%',
          icon: Icons.storage,
          color: _selectedTenant!.isStorageCritical ? Colors.red : 
                  _selectedTenant!.isStorageWarning ? Colors.orange : Colors.green,
          subtitle: '${_selectedTenant!.storageUsedGB.toStringAsFixed(1)}GB / ${_selectedTenant!.storageQuotaGB.toStringAsFixed(1)}GB',
        ),
        _buildOverviewCard(
          title: 'Security Score',
          value: _calculateSecurityScore(_selectedTenant!),
          icon: Icons.security,
          color: Colors.green,
          subtitle: 'Security rating',
        ),
        _buildOverviewCard(
          title: 'Compliance',
          value: _getComplianceStatus(_selectedTenant!),
          icon: Icons.verified_user,
          color: Colors.purple,
          subtitle: 'Compliance status',
        ),
      ],
    );
  }

  /// Overview Card
  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Actions
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(
                  label: 'Add User',
                  icon: Icons.person_add,
                  onPressed: _showCreateUserDialog,
                ),
                _buildActionChip(
                  label: 'Security Audit',
                  icon: Icons.security,
                  onPressed: _performSecurityAudit,
                ),
                _buildActionChip(
                  label: 'Export Data',
                  icon: Icons.download,
                  onPressed: _exportTenantData,
                ),
                _buildActionChip(
                  label: 'Generate Report',
                  icon: Icons.description,
                  onPressed: _generateTenantReport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tenants Tab
  Widget _buildTenantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🏢 Enterprise Tenants',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateTenantDialog,
                icon: const Icon(Icons.add),
                label: const Text('New Tenant'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_tenants.map((tenant) => _buildTenantCard(tenant)).toList()),
        ],
      ),
    );
  }

  /// Tenant Card
  Widget _buildTenantCard(EnterpriseTenant tenant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tenant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTenantStatusIndicator(tenant.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tenant.domain,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTenantTierChip(tenant.tier),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTenantMetric(
                    'Users',
                    '${tenant.currentUsers}/${tenant.maxUsers}',
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildTenantMetric(
                    'Storage',
                    '${tenant.storageUsagePercentage.toStringAsFixed(1)}%',
                    Icons.storage,
                  ),
                ),
                Expanded(
                  child: _buildTenantMetric(
                    'Created',
                    _formatDate(tenant.createdAt),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewTenantDetails(tenant),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editTenant(tenant),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Users Tab
  Widget _buildUsersTab() {
    if (_selectedTenant == null) {
      return const Center(
        child: Text('Please select a tenant to view users'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👥 Users for ${_selectedTenant!.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateUserDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Roles')),
                  DataColumn(label: Text('Last Login')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _tenantUsers.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user.fullName)),
                      DataCell(Text(user.email)),
                      DataCell(_buildUserStatusChip(user.status)),
                      DataCell(Text(user.roles.map((r) => r.name).join(', '))),
                      DataCell(Text(user.lastLoginAt != null ? _formatDate(user.lastLoginAt!) : 'Never')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editUser(user),
                              tooltip: 'Edit User',
                            ),
                            IconButton(
                              icon: const Icon(Icons.security),
                              onPressed: () => _resetUserPassword(user),
                              tooltip: 'Reset Password',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Security Tab
  Widget _buildSecurityTab() {
    if (_selectedTenant == null) {
      return const Center(
        child: Text('Please select a tenant to view security settings'),
      );
    }

    final securityConfig = _selectedTenant!.securityConfig;
    final complianceSettings = _selectedTenant!.complianceSettings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔐 Security Configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authentication Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildSecuritySetting('Multi-Factor Authentication', securityConfig.mfaRequired),
                  _buildSecuritySetting('Password Complexity', securityConfig.passwordComplexity),
                  _buildSecuritySetting('IP Whitelisting', securityConfig.ipWhitelisting),
                  const SizedBox(height: 16),
                  Text('Minimum Password Length: ${securityConfig.passwordMinLength} characters'),
                  Text('Session Timeout: ${securityConfig.sessionTimeout} seconds'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compliance Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildComplianceSetting('HIPAA Compliant', complianceSettings.hipaaCompliant),
                  _buildComplianceSetting('GDPR Compliant', complianceSettings.gdprCompliant),
                  _buildComplianceSetting('SOC 2 Compliant', complianceSettings.soc2Compliant),
                  const SizedBox(height: 16),
                  Text('Certifications: ${complianceSettings.certifications.join(', ')}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Analytics Tab
  Widget _buildAnalyticsTab() {
    if (_selectedTenant == null || _tenantAnalytics.isEmpty) {
      return const Center(
        child: Text('Please select a tenant to view analytics'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Tenant Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildAnalyticsCard(
                'Total Users',
                _tenantAnalytics['total_users'].toString(),
                Icons.people,
                Colors.blue,
              ),
              _buildAnalyticsCard(
                'Active Users',
                _tenantAnalytics['active_users'].toString(),
                Icons.person,
                Colors.green,
              ),
              _buildAnalyticsCard(
                'Recent Logins',
                _tenantAnalytics['recent_logins'].toString(),
                Icons.login,
                Colors.orange,
              ),
              _buildAnalyticsCard(
                'Storage Usage',
                '${_tenantAnalytics['storage_usage']['usage_percentage'].toStringAsFixed(1)}%',
                Icons.storage,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Settings Tab
  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Tenant settings configuration coming soon...'),
    );
  }

  // Helper Methods
  Widget _buildTenantStatusIndicator(TenantStatus status) {
    Color color;
    switch (status) {
      case TenantStatus.active:
        color = Colors.green;
        break;
      case TenantStatus.suspended:
        color = Colors.orange;
        break;
      case TenantStatus.terminated:
        color = Colors.red;
        break;
      case TenantStatus.pending:
        color = Colors.blue;
        break;
      case TenantStatus.trial:
        color = Colors.purple;
        break;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTenantTierChip(TenantTier tier) {
    return Chip(
      label: Text(tier.name.toUpperCase()),
      backgroundColor: _getTierColor(tier).withOpacity(0.1),
      labelStyle: TextStyle(
        color: _getTierColor(tier),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getTierColor(TenantTier tier) {
    switch (tier) {
      case TenantTier.starter:
        return Colors.blue;
      case TenantTier.professional:
        return Colors.green;
      case TenantTier.enterprise:
        return Colors.purple;
      case TenantTier.premium:
        return Colors.amber;
      case TenantTier.custom:
        return Colors.grey;
    }
  }

  Widget _buildTenantMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStatusChip(UserStatus status) {
    Color color;
    switch (status) {
      case UserStatus.active:
        color = Colors.green;
        break;
      case UserStatus.inactive:
        color = Colors.grey;
        break;
      case UserStatus.suspended:
        color = Colors.orange;
        break;
      case UserStatus.pending:
        color = Colors.blue;
        break;
      case UserStatus.locked:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _buildSecuritySetting(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceSetting(String label, bool compliant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            compliant ? Icons.verified : Icons.warning,
            color: compliant ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
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
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _calculateSecurityScore(EnterpriseTenant tenant) {
    int score = 0;
    final config = tenant.securityConfig;
    
    if (config.mfaRequired) score += 20;
    if (config.passwordComplexity) score += 15;
    if (config.passwordMinLength >= 12) score += 15;
    if (config.ipWhitelisting) score += 20;
    if (config.encryption.dataAtRest) score += 15;
    if (config.encryption.dataInTransit) score += 15;
    
    return '$score%';
  }

  String _getComplianceStatus(EnterpriseTenant tenant) {
    final compliance = tenant.complianceSettings;
    int compliantCount = 0;
    
    if (compliance.hipaaCompliant) compliantCount++;
    if (compliance.gdprCompliant) compliantCount++;
    if (compliance.soc2Compliant) compliantCount++;
    
    return '$compliantCount/3';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🕒 Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Recent activity logs will be displayed here...'),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _showCreateTenantDialog() {
    // TODO: Implement create tenant dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create tenant feature coming soon...')),
    );
  }

  void _showCreateUserDialog() {
    // TODO: Implement create user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create user feature coming soon...')),
    );
  }

  void _performSecurityAudit() {
    // TODO: Implement security audit
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security audit initiated...')),
    );
  }

  void _exportTenantData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export started...')),
    );
  }

  void _generateTenantReport() {
    // TODO: Implement report generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report generation started...')),
    );
  }

  void _viewTenantDetails(EnterpriseTenant tenant) {
    setState(() {
      _selectedTenant = tenant;
    });
    _tabController.animateTo(0); // Switch to overview tab
  }

  void _editTenant(EnterpriseTenant tenant) {
    // TODO: Implement tenant editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit tenant: ${tenant.name}')),
    );
  }

  void _editUser(EnterpriseUser user) {
    // TODO: Implement user editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user: ${user.fullName}')),
    );
  }

  void _resetUserPassword(EnterpriseUser user) {
    // TODO: Implement password reset
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset for: ${user.email}')),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
