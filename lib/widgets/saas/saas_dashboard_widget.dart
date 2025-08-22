import 'package:flutter/material.dart';
import '../../models/saas_models.dart';
import '../../services/saas_tenant_service.dart';
import '../../services/saas_usage_service.dart';
import '../../utils/theme.dart';

class SAASDashboardWidget extends StatefulWidget {
  const SAASDashboardWidget({super.key});

  @override
  State<SAASDashboardWidget> createState() => _SAASDashboardWidgetState();
}

class _SAASDashboardWidgetState extends State<SAASDashboardWidget> {
  final SAASTenantService _tenantService = SAASTenantService();
  final SAASUsageService _usageService = SAASUsageService();
  
  Tenant? _currentTenant;
  Subscription? _currentSubscription;
  UsageMetrics? _currentMonthUsage;
  Map<String, dynamic>? _usageReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      await _tenantService.initialize();
      _currentTenant = _tenantService.currentTenant;
      _currentSubscription = _tenantService.currentSubscription;
      
      if (_currentTenant != null) {
        _currentMonthUsage = await _usageService.getCurrentMonthUsage(_currentTenant!.id);
        _usageReport = await _usageService.generateUsageReport(
          _currentTenant!.id,
          DateTime.now().subtract(const Duration(days: 30)),
          DateTime.now(),
        );
      }
    } catch (e) {
      print('Error initializing SAAS data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentTenant == null) {
      return _buildNoTenantView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTenantInfo(),
          const SizedBox(height: 24),
          _buildSubscriptionStatus(),
          const SizedBox(height: 24),
          _buildUsageMetrics(),
          const SizedBox(height: 24),
          _buildFeatureFlags(),
          const SizedBox(height: 24),
          _buildBillingInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.business,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAAS Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Multi-tenant Management & Analytics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (_currentTenant == null) return const SizedBox.shrink();
    
    Color badgeColor;
    String statusText;
    
    switch (_currentTenant!.status) {
      case TenantStatus.active:
        badgeColor = Colors.green;
        statusText = 'Active';
        break;
      case TenantStatus.trial:
        badgeColor = Colors.orange;
        statusText = 'Trial';
        break;
      case TenantStatus.suspended:
        badgeColor = Colors.red;
        statusText = 'Suspended';
        break;
      case TenantStatus.cancelled:
        badgeColor = Colors.grey;
        statusText = 'Cancelled';
        break;
      case TenantStatus.expired:
        badgeColor = Colors.red;
        statusText = 'Expired';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTenantInfo() {
    if (_currentTenant == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tenant Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _currentTenant!.name),
            _buildInfoRow('Domain', _currentTenant!.domain),
            _buildInfoRow('Region', _currentTenant!.region),
            _buildInfoRow('Plan', _currentTenant!.plan.name.toUpperCase()),
            _buildInfoRow('Created', _formatDate(_currentTenant!.createdAt)),
            if (_currentTenant!.trialEndsAt != null)
              _buildInfoRow('Trial Ends', _formatDate(_currentTenant!.trialEndsAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    if (_currentSubscription == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.subscriptions,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Subscription Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar('Users', _currentSubscription!.maxUsers, 100),
            _buildProgressBar('Storage', _currentSubscription!.maxStorageGB, 200),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentSubscription!.features.map((feature) {
                return Chip(
                  label: Text(feature),
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageMetrics() {
    if (_currentMonthUsage == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month Usage',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'AI Requests',
                    '${_currentMonthUsage!.aiRequests}',
                    Icons.psychology,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Sessions',
                    '${_currentMonthUsage!.totalSessions}',
                    Icons.video_call,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Storage',
                    '${(_currentMonthUsage!.storageUsedMB / 1024).toStringAsFixed(1)} GB',
                    Icons.storage,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'API Calls',
                    '${_currentMonthUsage!.apiCalls}',
                    Icons.api,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureFlags() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Flags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureFlagRow('AI Diagnosis', _tenantService.isFeatureAvailable('ai_diagnosis')),
            _buildFeatureFlagRow('Telehealth', _tenantService.isFeatureAvailable('telehealth')),
            _buildFeatureFlagRow('Advanced Analytics', _tenantService.isFeatureAvailable('advanced_analytics')),
            _buildFeatureFlagRow('Multi-tenant', _tenantService.isFeatureAvailable('multi_tenant')),
            _buildFeatureFlagRow('API Access', _tenantService.isFeatureAvailable('api_access')),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfo() {
    if (_currentSubscription == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Plan', _currentSubscription!.planId.toUpperCase()),
            _buildInfoRow('Status', _currentSubscription!.status.name.toUpperCase()),
            _buildInfoRow('Start Date', _formatDate(_currentSubscription!.startDate)),
            _buildInfoRow('End Date', _formatDate(_currentSubscription!.endDate)),
            if (_currentSubscription!.trialEndsAt != null)
              _buildInfoRow('Trial Ends', _formatDate(_currentSubscription!.trialEndsAt!)),
            const SizedBox(height: 16),
            if (_tenantService.isInTrial)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trial ends in ${_tenantService.trialDaysRemaining} days',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTenantView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Tenant Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact your administrator to set up tenant access.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _tenantService.loadMockTenant();
              _initializeData();
            },
            child: Text('Load Demo Tenant'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int max) {
    final percentage = current / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$current / $max'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.8 ? Colors.red : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagRow(String feature, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: enabled ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: enabled ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              enabled ? 'ON' : 'OFF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
