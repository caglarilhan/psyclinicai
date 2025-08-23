import 'package:flutter/material.dart';
import 'dart:math';

/// Business Intelligence Dashboard Widget for PsyClinicAI
/// Provides comprehensive analytics and reporting for enterprise clients
class BusinessIntelligenceDashboardWidget extends StatefulWidget {
  const BusinessIntelligenceDashboardWidget({Key? key}) : super(key: key);

  @override
  State<BusinessIntelligenceDashboardWidget> createState() => _BusinessIntelligenceDashboardWidgetState();
}

class _BusinessIntelligenceDashboardWidgetState extends State<BusinessIntelligenceDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // State variables
  bool _isLoading = false;
  String _selectedTimeRange = '30d';
  String _selectedTenant = 'all';
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load analytics data
  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate loading analytics data
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final random = Random();
      _analyticsData = {
        'overview': {
          'total_patients': 15420 + random.nextInt(1000),
          'total_sessions': 89350 + random.nextInt(10000),
          'total_clinicians': 450 + random.nextInt(50),
          'active_tenants': 85 + random.nextInt(15),
          'revenue': 2450000 + random.nextInt(500000),
          'growth_rate': 15.5 + random.nextDouble() * 10,
        },
        'patient_analytics': {
          'new_patients_trend': _generateTrendData(30),
          'patient_outcomes': {
            'improved': 78.5,
            'stable': 15.2,
            'declined': 6.3,
          },
          'engagement_metrics': {
            'high_engagement': 65.4,
            'medium_engagement': 25.1,
            'low_engagement': 9.5,
          },
          'demographics': {
            'age_groups': {
              '18-25': 22.3,
              '26-35': 31.5,
              '36-45': 25.7,
              '46-55': 15.2,
              '55+': 5.3,
            },
            'gender': {
              'female': 58.2,
              'male': 38.5,
              'other': 3.3,
            },
          },
        },
        'clinical_analytics': {
          'session_types': {
            'individual_therapy': 45.2,
            'group_therapy': 22.8,
            'family_therapy': 15.5,
            'crisis_intervention': 8.3,
            'assessment': 8.2,
          },
          'diagnosis_distribution': {
            'anxiety_disorders': 28.5,
            'depression': 24.3,
            'bipolar_disorder': 12.7,
            'ptsd': 9.8,
            'personality_disorders': 8.2,
            'other': 16.5,
          },
          'treatment_effectiveness': _generateEffectivenessData(),
        },
        'operational_analytics': {
          'utilization_rates': {
            'clinician_utilization': 82.4,
            'platform_utilization': 91.2,
            'resource_utilization': 76.8,
          },
          'response_times': {
            'avg_response_time': 2.4,
            'crisis_response_time': 0.8,
            'booking_response_time': 1.2,
          },
          'quality_metrics': {
            'patient_satisfaction': 94.2,
            'clinician_satisfaction': 89.7,
            'platform_reliability': 99.8,
          },
        },
        'financial_analytics': {
          'revenue_breakdown': {
            'subscription_revenue': 65.2,
            'session_fees': 25.8,
            'premium_features': 6.5,
            'api_usage': 2.5,
          },
          'cost_analysis': {
            'infrastructure': 35.2,
            'personnel': 45.8,
            'marketing': 12.3,
            'operations': 6.7,
          },
          'profit_margins': _generateProfitData(),
        },
      };
      
      print('✅ Business intelligence data loaded successfully');
    } catch (e) {
      print('❌ Failed to load analytics data: $e');
      _showErrorSnackBar('Failed to load analytics data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Business Intelligence Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Patients'),
            Tab(icon: Icon(Icons.psychology), text: 'Clinical'),
            Tab(icon: Icon(Icons.business), text: 'Operations'),
            Tab(icon: Icon(Icons.attach_money), text: 'Financial'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildControlPanel(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildPatientAnalyticsTab(),
                      _buildClinicalAnalyticsTab(),
                      _buildOperationalAnalyticsTab(),
                      _buildFinancialAnalyticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Control Panel
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedTimeRange,
              decoration: const InputDecoration(
                labelText: 'Time Range',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                DropdownMenuItem(value: '1y', child: Text('Last year')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTimeRange = value!;
                });
                _loadAnalyticsData();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedTenant,
              decoration: const InputDecoration(
                labelText: 'Tenant',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Tenants')),
                DropdownMenuItem(value: 'enterprise', child: Text('Enterprise')),
                DropdownMenuItem(value: 'professional', child: Text('Professional')),
                DropdownMenuItem(value: 'starter', child: Text('Starter')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTenant = value!;
                });
                _loadAnalyticsData();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Overview Tab
  Widget _buildOverviewTab() {
    if (_analyticsData.isEmpty) return Container();

    final overview = _analyticsData['overview'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Executive Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildKPICards(overview),
          const SizedBox(height: 24),
          _buildTrendChart(),
          const SizedBox(height: 24),
          _buildQuickInsights(),
        ],
      ),
    );
  }

  /// KPI Cards
  Widget _buildKPICards(Map<String, dynamic> overview) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildKPICard(
          title: 'Total Patients',
          value: _formatNumber(overview['total_patients']),
          icon: Icons.people,
          color: Colors.blue,
          trend: '+12.5%',
        ),
        _buildKPICard(
          title: 'Total Sessions',
          value: _formatNumber(overview['total_sessions']),
          icon: Icons.psychology,
          color: Colors.green,
          trend: '+8.3%',
        ),
        _buildKPICard(
          title: 'Active Clinicians',
          value: _formatNumber(overview['total_clinicians']),
          icon: Icons.medical_services,
          color: Colors.orange,
          trend: '+5.7%',
        ),
        _buildKPICard(
          title: 'Active Tenants',
          value: _formatNumber(overview['active_tenants']),
          icon: Icons.business,
          color: Colors.purple,
          trend: '+15.2%',
        ),
        _buildKPICard(
          title: 'Revenue',
          value: '\$${_formatCurrency(overview['revenue'])}',
          icon: Icons.attach_money,
          color: Colors.green,
          trend: '+${overview['growth_rate'].toStringAsFixed(1)}%',
        ),
        _buildKPICard(
          title: 'Growth Rate',
          value: '${overview['growth_rate'].toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.teal,
          trend: '+2.1%',
        ),
      ],
    );
  }

  /// KPI Card
  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
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

  /// Patient Analytics Tab
  Widget _buildPatientAnalyticsTab() {
    if (_analyticsData.isEmpty) return Container();

    final patientData = _analyticsData['patient_analytics'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👥 Patient Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildOutcomesChart(patientData['patient_outcomes'])),
              const SizedBox(width: 16),
              Expanded(child: _buildEngagementChart(patientData['engagement_metrics'])),
            ],
          ),
          const SizedBox(height: 24),
          _buildDemographicsSection(patientData['demographics']),
        ],
      ),
    );
  }

  /// Clinical Analytics Tab
  Widget _buildClinicalAnalyticsTab() {
    if (_analyticsData.isEmpty) return Container();

    final clinicalData = _analyticsData['clinical_analytics'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏥 Clinical Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSessionTypesChart(clinicalData['session_types'])),
              const SizedBox(width: 16),
              Expanded(child: _buildDiagnosisChart(clinicalData['diagnosis_distribution'])),
            ],
          ),
          const SizedBox(height: 24),
          _buildTreatmentEffectivenessChart(clinicalData['treatment_effectiveness']),
        ],
      ),
    );
  }

  /// Operational Analytics Tab
  Widget _buildOperationalAnalyticsTab() {
    if (_analyticsData.isEmpty) return Container();

    final operationalData = _analyticsData['operational_analytics'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Operational Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildUtilizationMetrics(operationalData['utilization_rates']),
          const SizedBox(height: 24),
          _buildResponseTimeMetrics(operationalData['response_times']),
          const SizedBox(height: 24),
          _buildQualityMetrics(operationalData['quality_metrics']),
        ],
      ),
    );
  }

  /// Financial Analytics Tab
  Widget _buildFinancialAnalyticsTab() {
    if (_analyticsData.isEmpty) return Container();

    final financialData = _analyticsData['financial_analytics'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Financial Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRevenueBreakdownChart(financialData['revenue_breakdown'])),
              const SizedBox(width: 16),
              Expanded(child: _buildCostAnalysisChart(financialData['cost_analysis'])),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfitMarginsChart(financialData['profit_margins']),
        ],
      ),
    );
  }

  // Chart building methods
  Widget _buildTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Growth Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text('Interactive trend chart would be displayed here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomesChart(Map<String, dynamic> outcomes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Patient Outcomes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...outcomes.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              _getOutcomeColor(entry.key),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementChart(Map<String, dynamic> engagement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💪 Patient Engagement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...engagement.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              _getEngagementColor(entry.key),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text('${value.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection(Map<String, dynamic> demographics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 Demographics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Age Groups', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...(demographics['age_groups'] as Map<String, dynamic>).entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text('${entry.value.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...(demographics['gender'] as Map<String, dynamic>).entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key.toUpperCase()),
                              Text('${entry.value.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTypesChart(Map<String, dynamic> sessionTypes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🗣️ Session Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...sessionTypes.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              Colors.blue,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisChart(Map<String, dynamic> diagnosis) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🩺 Diagnosis Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...diagnosis.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              Colors.purple,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentEffectivenessChart(List<dynamic> effectiveness) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Treatment Effectiveness Over Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text('Treatment effectiveness timeline chart would be displayed here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizationMetrics(Map<String, dynamic> utilization) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Utilization Rates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...utilization.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              Colors.orange,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTimeMetrics(Map<String, dynamic> responseTimes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⏱️ Response Times',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: responseTimes.entries.map<Widget>((entry) {
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${entry.value.toStringAsFixed(1)}h',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetrics(Map<String, dynamic> quality) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⭐ Quality Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...quality.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              Colors.green,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBreakdownChart(Map<String, dynamic> revenue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💰 Revenue Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...revenue.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              Colors.green,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCostAnalysisChart(Map<String, dynamic> costs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Cost Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...costs.entries.map((entry) => _buildProgressBar(
              entry.key.replaceAll('_', ' ').toUpperCase(),
              entry.value.toDouble(),
              Colors.red,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitMarginsChart(List<dynamic> profits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Profit Margins Over Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text('Profit margins timeline chart would be displayed here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Quick Insights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              icon: Icons.trending_up,
              color: Colors.green,
              title: 'Patient Satisfaction',
              description: 'Up 5.2% from last month, reaching 94.2%',
            ),
            _buildInsightItem(
              icon: Icons.psychology,
              color: Colors.blue,
              title: 'Treatment Effectiveness',
              description: '78.5% of patients showing improvement',
            ),
            _buildInsightItem(
              icon: Icons.schedule,
              color: Colors.orange,
              title: 'Response Time',
              description: 'Crisis response time improved to 0.8 hours',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  Color _getOutcomeColor(String outcome) {
    switch (outcome) {
      case 'improved':
        return Colors.green;
      case 'stable':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEngagementColor(String engagement) {
    switch (engagement) {
      case 'high_engagement':
        return Colors.green;
      case 'medium_engagement':
        return Colors.orange;
      case 'low_engagement':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _generateTrendData(int days) {
    final random = Random();
    return List.generate(days, (index) => {
      'day': index + 1,
      'value': 100 + random.nextInt(50),
    });
  }

  List<Map<String, dynamic>> _generateEffectivenessData() {
    final random = Random();
    return List.generate(12, (index) => {
      'month': index + 1,
      'effectiveness': 75 + random.nextDouble() * 20,
    });
  }

  List<Map<String, dynamic>> _generateProfitData() {
    final random = Random();
    return List.generate(12, (index) => {
      'month': index + 1,
      'profit_margin': 15 + random.nextDouble() * 10,
    });
  }

  // Action methods
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: const Text('Advanced filtering options would be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report export started...')),
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
