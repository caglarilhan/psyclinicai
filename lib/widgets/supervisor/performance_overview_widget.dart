import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/supervision_models.dart';

class PerformanceOverviewWidget extends StatelessWidget {
  final List<SupervisionSession> supervisionSessions;
  final List<TherapistPerformance> therapistPerformances;
  final List<QualityMetric> qualityMetrics;

  const PerformanceOverviewWidget({
    super.key,
    required this.supervisionSessions,
    required this.therapistPerformances,
    required this.qualityMetrics,
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
            'Performans Genel Bakış',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Key Metrics Cards
          _buildKeyMetricsCards(context, stats),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(context),
          const SizedBox(height: 24),
          
          // Performance Trends
          _buildPerformanceTrends(context, stats),
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    if (supervisionSessions.isEmpty) return {};
    
    final now = DateTime.now();
    final totalSessions = supervisionSessions.length;
    final completedSessions = supervisionSessions.where((s) => s.status == SupervisionStatus.completed).length;
    final pendingSessions = supervisionSessions.where((s) => s.status == SupervisionStatus.pending).length;
    final overdueSessions = supervisionSessions.where((s) => s.scheduledDate.isBefore(now) && s.status != SupervisionStatus.completed).length;
    
    final totalTherapists = therapistPerformances.length;
    final excellentTherapists = therapistPerformances.where((t) => t.successRate >= 0.9).length;
    final needsImprovementTherapists = therapistPerformances.where((t) => t.successRate < 0.7).length;
    
    final avgCompletionRate = therapistPerformances.isNotEmpty 
        ? therapistPerformances.map((t) => t.successRate).reduce((a, b) => a + b) / therapistPerformances.length
        : 0.0;
    
    final avgClientSatisfaction = therapistPerformances.isNotEmpty
        ? therapistPerformances.map((t) => t.averageRating).reduce((a, b) => a + b) / therapistPerformances.length
        : 0.0;
    
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'pendingSessions': pendingSessions,
      'overdueSessions': overdueSessions,
      'totalTherapists': totalTherapists,
      'excellentTherapists': excellentTherapists,
      'needsImprovementTherapists': needsImprovementTherapists,
      'avgCompletionRate': avgCompletionRate,
      'avgClientSatisfaction': avgClientSatisfaction,
    };
  }

  Widget _buildKeyMetricsCards(BuildContext context, Map<String, dynamic> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          context,
          'Toplam Süpervizyon',
          '${stats['totalSessions']}',
          Icons.supervisor_account,
          Colors.blue,
          '${stats['completedSessions']} tamamlandı',
        ),
        _buildMetricCard(
          context,
          'Aktif Terapistler',
          '${stats['totalTherapists']}',
          Icons.people,
          Colors.green,
          '${stats['excellentTherapists']} mükemmel',
        ),
        _buildMetricCard(
          context,
          'Tamamlama Oranı',
          '${(stats['avgCompletionRate'] * 100).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.orange,
          'Hedef: %90',
        ),
        _buildMetricCard(
          context,
          'Müşteri Memnuniyeti',
          '${stats['avgClientSatisfaction'].toStringAsFixed(1)}',
          Icons.sentiment_satisfied,
          Colors.purple,
          '/5.0 puan',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
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
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final recentSessions = supervisionSessions
        .where((s) => s.actualDate != null)
        .take(3)
        .toList();

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
                'Son Aktiviteler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentSessions.isEmpty)
            Center(
              child: Text(
                'Henüz aktivite bulunmuyor',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            )
          else
            ...recentSessions.map((session) => _buildActivityItem(context, session)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, SupervisionSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(session.status).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(session.status),
              color: _getStatusColor(session.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSupervisionTypeText(session.type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.duration.inMinutes} dakika',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(session.actualDate!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(session.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(session.status),
                  style: TextStyle(
                    color: _getStatusColor(session.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrends(BuildContext context, Map<String, dynamic> stats) {
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
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Performans Trendleri',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTrendItem(
                  context,
                  'Tamamlama Oranı',
                  '${(stats['avgCompletionRate'] * 100).toStringAsFixed(1)}%',
                  stats['avgCompletionRate'] >= 0.9 ? Colors.green : Colors.orange,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTrendItem(
                  context,
                  'Müşteri Memnuniyeti',
                  '${stats['avgClientSatisfaction'].toStringAsFixed(1)}/5.0',
                  stats['avgClientSatisfaction'] >= 4.5 ? Colors.green : Colors.orange,
                  Icons.sentiment_satisfied,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: stats['avgCompletionRate'],
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              stats['avgCompletionRate'] >= 0.9 ? Colors.green : Colors.orange,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            'Genel Performans: ${(stats['avgCompletionRate'] * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
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

  Widget _buildQuickActions(BuildContext context) {
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
          Text(
            'Hızlı İşlemler',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Yeni Süpervizyon',
                  Icons.add,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Rapor Oluştur',
                  Icons.assessment,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Kalite Analizi',
                  Icons.analytics,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Eğitim Planı',
                  Icons.school,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SupervisionStatus status) {
    switch (status) {
      case SupervisionStatus.completed:
        return Colors.green;
      case SupervisionStatus.inProgress:
        return Colors.blue;
      case SupervisionStatus.pending:
        return Colors.orange;
      case SupervisionStatus.cancelled:
        return Colors.red;
      case SupervisionStatus.requiresFollowUp:
        return Colors.purple;
      case SupervisionStatus.scheduled:
        return Colors.indigo;
    }
  }

  IconData _getStatusIcon(SupervisionStatus status) {
    switch (status) {
      case SupervisionStatus.completed:
        return Icons.check_circle;
      case SupervisionStatus.inProgress:
        return Icons.play_circle;
      case SupervisionStatus.pending:
        return Icons.schedule;
      case SupervisionStatus.cancelled:
        return Icons.cancel;
      case SupervisionStatus.requiresFollowUp:
        return Icons.warning;
      case SupervisionStatus.scheduled:
        return Icons.calendar_today;
    }
  }

  String _getStatusText(SupervisionStatus status) {
    switch (status) {
      case SupervisionStatus.completed:
        return 'Tamamlandı';
      case SupervisionStatus.inProgress:
        return 'Devam Ediyor';
      case SupervisionStatus.pending:
        return 'Bekliyor';
      case SupervisionStatus.cancelled:
        return 'İptal';
      case SupervisionStatus.requiresFollowUp:
        return 'Takip Gerekli';
      case SupervisionStatus.scheduled:
        return 'Planlandı';
    }
  }

  String _getSupervisionTypeText(SupervisionType type) {
    switch (type) {
      case SupervisionType.individual:
        return 'Bireysel Süpervizyon';
      case SupervisionType.group:
        return 'Grup Süpervizyonu';
      case SupervisionType.caseReview:
        return 'Vaka İncelemesi';
      case SupervisionType.skillAssessment:
        return 'Beceri Değerlendirmesi';
      case SupervisionType.crisis:
        return 'Kriz';
      case SupervisionType.supervision:
        return 'Genel Süpervizyon';
      case SupervisionType.crisisManagement:
        return 'Kriz Yönetimi';
      case SupervisionType.documentationReview:
        return 'Dokümantasyon İncelemesi';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Dün';
    } else if (difference < 7) {
      return '$difference gün önce';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
