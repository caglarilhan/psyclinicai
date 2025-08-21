import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/consent_service.dart';
import '../../services/regional_config_service.dart';

class SecurityDashboardWidget extends StatefulWidget {
  const SecurityDashboardWidget({super.key});

  @override
  State<SecurityDashboardWidget> createState() => _SecurityDashboardWidgetState();
}

class _SecurityDashboardWidgetState extends State<SecurityDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _metricController;
  late Animation<double> _metricAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _metricController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _metricAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _metricController, curve: Curves.easeOut),
    );
    _metricController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConsentService, RegionalConfigService>(
      builder: (context, consentService, regionalService, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🔒 Güvenlik & Uyumluluk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {});
                        _metricController.reset();
                        _metricController.forward();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Genel Bakış'),
                    Tab(text: 'Onam Yönetimi'),
                    Tab(text: 'Uyumluluk'),
                    Tab(text: 'Denetim'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(consentService, regionalService),
                      _buildConsentTab(consentService),
                      _buildComplianceTab(consentService, regionalService),
                      _buildAuditTab(consentService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(ConsentService consentService, RegionalConfigService regionalService) {
    final region = regionalService.currentRegion;
    final activeConsents = consentService.getActiveConsents().length;
    final expiringConsents = consentService.getExpiringConsents().length;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Aktif Onamlar',
                  activeConsents.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Süresi Dolan',
                  expiringConsents.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Bölge',
                  region.name,
                  Icons.location_on,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Uyumluluk',
                  'Aktif',
                  Icons.security,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComplianceStatus(regionalService),
        ],
      ),
    );
  }

  Widget _buildConsentTab(ConsentService consentService) {
    final consents = consentService.getActiveConsents();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktif Onamlar (${consents.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: consents.length,
            itemBuilder: (context, index) {
              final consent = consents[index];
              return Card(
                child: ListTile(
                  title: Text('Hasta: ${consent.patientId}'),
                  subtitle: Text('Tarih: ${consent.createdAt.toString().split(' ')[0]}'),
                  trailing: Icon(
                    consent.status == 'active' ? Icons.check_circle : Icons.pending,
                    color: consent.status == 'active' ? Colors.green : Colors.orange,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceTab(ConsentService consentService, RegionalConfigService regionalService) {
    final region = regionalService.currentRegion;
    final complianceReport = consentService.generateComplianceReport(region.code);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${region.name} Uyumluluk Raporu',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Durum: ${complianceReport.status}'),
                const SizedBox(height: 8),
                Text('Son Güncelleme: ${complianceReport.generatedAt.toString().split(' ')[0]}'),
                const SizedBox(height: 8),
                Text('Öneriler: ${complianceReport.recommendations.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: complianceReport.recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = complianceReport.recommendations[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb, color: Colors.amber),
                  title: Text(recommendation),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTab(ConsentService consentService) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Denetim Logları',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Text('Denetim logları burada görüntülenecek'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _metricAnimation,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplianceStatus(RegionalConfigService regionalService) {
    final region = regionalService.currentRegion;
    String status = 'Aktif';
    Color statusColor = Colors.green;
    
    if (region.code == 'TR') {
      status = 'KVKK Uyumlu';
    } else if (region.code == 'US') {
      status = 'HIPAA Uyumlu';
    } else if (region.code == 'EU') {
      status = 'GDPR Uyumlu';
    }
    
    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: statusColor),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
