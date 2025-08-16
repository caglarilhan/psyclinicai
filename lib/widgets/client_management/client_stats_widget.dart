import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/client_model.dart';

class ClientStatsWidget extends StatelessWidget {
  final List<ClientModel> clients;

  const ClientStatsWidget({
    super.key,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Danışan İstatistikleri',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Summary Cards
          _buildSummaryCards(context, stats),
          const SizedBox(height: 24),
          
          // Status Distribution
          _buildStatusDistribution(context, stats),
          const SizedBox(height: 24),
          
          // Risk Level Analysis
          _buildRiskLevelAnalysis(context, stats),
          const SizedBox(height: 24),
          
          // Age Distribution
          _buildAgeDistribution(context, stats),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(context, stats),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    if (clients.isEmpty) return {};
    
    final now = DateTime.now();
    final activeClients = clients.where((c) => c.isActive).length;
    final highRiskClients = clients.where((c) => c.isHighRisk).length;
    final totalSessions = clients.fold(0, (sum, c) => sum + c.totalSessions);
    final avgSessions = totalSessions / clients.length;
    
    // Status distribution
    final statusCounts = <ClientStatus, int>{};
    for (final status in ClientStatus.values) {
      statusCounts[status] = clients.where((c) => c.status == status).length;
    }
    
    // Risk level distribution
    final riskCounts = <ClientRiskLevel, int>{};
    for (final risk in ClientRiskLevel.values) {
      riskCounts[risk] = clients.where((c) => c.riskLevel == risk).length;
    }
    
    // Age distribution
    final ages = clients.map((c) => c.age).toList();
    final avgAge = ages.reduce((a, b) => a + b) / ages.length;
    
    // Recent activity (last 30 days)
    final recentClients = clients.where((c) => 
      c.lastSessionDate != null && 
      now.difference(c.lastSessionDate!).inDays <= 30
    ).length;
    
    return {
      'totalClients': clients.length,
      'activeClients': activeClients,
      'highRiskClients': highRiskClients,
      'totalSessions': totalSessions,
      'avgSessions': avgSessions,
      'statusCounts': statusCounts,
      'riskCounts': riskCounts,
      'avgAge': avgAge,
      'recentClients': recentClients,
    };
  }

  Widget _buildSummaryCards(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          context,
          'Toplam Danışan',
          '${stats['totalClients']}',
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          context,
          'Aktif Danışan',
          '${stats['activeClients']}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          context,
          'Yüksek Risk',
          '${stats['highRiskClients']}',
          Icons.warning,
          Colors.red,
        ),
        _buildSummaryCard(
          context,
          'Toplam Seans',
          '${stats['totalSessions']}',
          Icons.schedule,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: color.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    final statusCounts = stats['statusCounts'] as Map<ClientStatus, int>;
    
    return _buildChartSection(
      context,
      'Durum Dağılımı',
      Icons.pie_chart,
      statusCounts.entries.map((entry) {
        final color = _getStatusColor(entry.key);
        return _buildChartItem(
          context,
          _getStatusText(entry.key),
          entry.value,
          stats['totalClients'],
          color,
        );
      }).toList(),
    );
  }

  Widget _buildRiskLevelAnalysis(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    final riskCounts = stats['riskCounts'] as Map<ClientRiskLevel, int>;
    
    return _buildChartSection(
      context,
      'Risk Seviyesi Analizi',
      Icons.security,
      riskCounts.entries.map((entry) {
        final color = _getRiskColor(entry.key);
        return _buildChartItem(
          context,
          _getRiskText(entry.key),
          entry.value,
          stats['totalClients'],
          color,
        );
      }).toList(),
    );
  }

  Widget _buildAgeDistribution(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    final avgAge = stats['avgAge'] as double;
    final ageGroups = _calculateAgeGroups();
    
    return _buildChartSection(
      context,
      'Yaş Dağılımı',
      Icons.person,
      [
        _buildChartItem(
          context,
          '18-25',
          ageGroups['18-25'] ?? 0,
          stats['totalClients'],
          Colors.blue,
        ),
        _buildChartItem(
          context,
          '26-35',
          ageGroups['26-35'] ?? 0,
          stats['totalClients'],
          Colors.green,
        ),
        _buildChartItem(
          context,
          '36-45',
          ageGroups['36-45'] ?? 0,
          stats['totalClients'],
          Colors.orange,
        ),
        _buildChartItem(
          context,
          '46+',
          ageGroups['46+'] ?? 0,
          stats['totalClients'],
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Son 30 Gün Aktivite',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActivityItem(
                  context,
                  'Aktif Danışan',
                  '${stats['recentClients']}',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityItem(
                  context,
                  'Ortalama Seans',
                  '${stats['avgSessions'].toStringAsFixed(1)}',
                  Icons.schedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items,
        ],
      ),
    );
  }

  Widget _buildChartItem(
    BuildContext context,
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$value ($percentage.toStringAsFixed(1)%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateAgeGroups() {
    final groups = <String, int>{};
    for (final client in clients) {
      final age = client.age;
      if (age >= 18 && age <= 25) {
        groups['18-25'] = (groups['18-25'] ?? 0) + 1;
      } else if (age >= 26 && age <= 35) {
        groups['26-35'] = (groups['26-35'] ?? 0) + 1;
      } else if (age >= 36 && age <= 45) {
        groups['36-45'] = (groups['36-45'] ?? 0) + 1;
      } else {
        groups['46+'] = (groups['46+'] ?? 0) + 1;
      }
    }
    return groups;
  }

  Color _getStatusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return Colors.green;
      case ClientStatus.inactive:
        return Colors.grey;
      case ClientStatus.discharged:
        return Colors.blue;
      case ClientStatus.onHold:
        return Colors.orange;
      case ClientStatus.emergency:
        return Colors.red;
    }
  }

  Color _getRiskColor(ClientRiskLevel risk) {
    switch (risk) {
      case ClientRiskLevel.low:
        return Colors.green;
      case ClientRiskLevel.medium:
        return Colors.orange;
      case ClientRiskLevel.high:
        return Colors.red;
      case ClientRiskLevel.critical:
        return Colors.purple;
    }
  }

  String _getStatusText(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return 'Aktif';
      case ClientStatus.inactive:
        return 'Pasif';
      case ClientStatus.discharged:
        return 'Taburcu';
      case ClientStatus.onHold:
        return 'Beklemede';
      case ClientStatus.emergency:
        return 'Acil';
    }
  }

  String _getRiskText(ClientRiskLevel risk) {
    switch (risk) {
      case ClientRiskLevel.low:
        return 'Düşük';
      case ClientRiskLevel.medium:
        return 'Orta';
      case ClientRiskLevel.high:
        return 'Yüksek';
      case ClientRiskLevel.critical:
        return 'Kritik';
    }
  }
}
