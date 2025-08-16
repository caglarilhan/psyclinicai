import 'package:flutter/material.dart';
import '../../models/flag_model.dart';
import '../../utils/theme.dart';

class FlagHistoryPanel extends StatelessWidget {
  final List<FlagModel> flags;
  final Function(FlagModel) onFlagSelected;

  const FlagHistoryPanel({
    super.key,
    required this.flags,
    required this.onFlagSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Flag Geçmişi Yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Çözülen flaglar burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flags.length,
      itemBuilder: (context, index) {
        final flag = flags[index];
        return _buildHistoryCard(context, flag);
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, FlagModel flag) {
    final severityColor = _getSeverityColor(flag.severity);
    final flagTypeIcon = _getFlagTypeIcon(flag.flagType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => onFlagSelected(flag),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır - Flag tipi ve durumu
                Row(
                  children: [
                    Icon(
                      flagTypeIcon,
                      color: severityColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFlagTypeText(flag.flagType),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            flag.patientName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Çözüldü',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Açıklama
                Text(
                  flag.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Alt bilgiler
                Row(
                  children: [
                    // Şiddet
                    _buildInfoChip(
                      Icons.signal_cellular_alt,
                      _getSeverityText(flag.severity),
                      severityColor,
                    ),

                    const SizedBox(width: 12),

                    // Risk skoru
                    _buildInfoChip(
                      Icons.assessment,
                      'Risk: ${flag.riskLevel}',
                      _getRiskColor(flag.riskScore),
                    ),

                    const Spacer(),

                    // Tarih
                    Text(
                      _formatDate(flag.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return AppTheme.accentColor;
      case FlagSeverity.medium:
        return AppTheme.warningColor;
      case FlagSeverity.high:
        return AppTheme.errorColor;
    }
  }

  String _getSeverityText(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return 'Düşük';
      case FlagSeverity.medium:
        return 'Orta';
      case FlagSeverity.high:
        return 'Yüksek';
    }
  }

  IconData _getFlagTypeIcon(FlagType type) {
    switch (type) {
      case FlagType.suicide:
        return Icons.warning;
      case FlagType.crisis:
        return Icons.psychology;
      case FlagType.selfHarm:
        return Icons.healing;
      case FlagType.violence:
        return Icons.security;
    }
  }

  String _getFlagTypeText(FlagType type) {
    switch (type) {
      case FlagType.suicide:
        return 'İntihar Riski';
      case FlagType.crisis:
        return 'Kriz Durumu';
      case FlagType.selfHarm:
        return 'Kendine Zarar Verme';
      case FlagType.violence:
        return 'Şiddet Riski';
    }
  }

  Color _getRiskColor(int riskScore) {
    if (riskScore >= 10) return AppTheme.errorColor;
    if (riskScore >= 7) return AppTheme.warningColor;
    if (riskScore >= 4) return AppTheme.primaryColor;
    return AppTheme.accentColor;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
