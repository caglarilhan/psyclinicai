import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/ai_response_models.dart';

class AISummaryPanel extends StatelessWidget {
  final SessionSummaryResponse? summary;
  final String? error;
  final VoidCallback onRegenerate;
  final bool isGenerating;

  const AISummaryPanel({
    super.key,
    this.summary,
    this.error,
    required this.onRegenerate,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Özeti',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isGenerating ? Icons.refresh : Icons.refresh,
                  color: isGenerating ? Colors.grey : AppTheme.secondaryColor,
                ),
                onPressed: isGenerating ? null : onRegenerate,
                tooltip: 'Yeniden Oluştur',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AI özeti içeriği
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isGenerating) {
      return _buildLoadingState(context);
    } else if (error != null) {
      return _buildErrorState(context);
    } else if (summary == null) {
      return _buildEmptyState(context);
    } else {
      return _buildSummaryContent(context);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'AI Özeti Oluşturuluyor...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu işlem birkaç saniye sürebilir',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'AI Özeti Hatası',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.errorColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Bilinmeyen hata',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'AI Özeti Yok',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seans notu yazıp AI özeti oluşturun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context) {
    if (summary == null) return _buildEmptyState(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem(
            context,
            'Duygu Durumu',
            summary!.affect,
            Icons.sentiment_satisfied,
            AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          
          _buildSummaryItem(
            context,
            'Ana Tema',
            summary!.theme,
            Icons.psychology,
            AppTheme.secondaryColor,
          ),
          const SizedBox(height: 16),
          
          _buildSummaryItem(
            context,
            'ICD Önerisi',
            summary!.icdSuggestion,
            Icons.medical_services,
            AppTheme.warningColor,
          ),
          const SizedBox(height: 16),
          
          _buildSummaryItem(
            context,
            'Risk Seviyesi',
            summary!.riskLevel,
            Icons.warning,
            _getRiskColor(summary!.riskLevel),
          ),
          const SizedBox(height: 16),
          
          _buildSummaryItem(
            context,
            'Önerilen Müdahale',
            summary!.recommendedIntervention,
            Icons.healing,
            AppTheme.accentColor,
          ),
          const SizedBox(height: 16),
          
          // Güven seviyesi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Güven Seviyesi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(summary!.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'düşük':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'yüksek':
        return Colors.red;
      default:
        return AppTheme.warningColor;
    }
  }
}
