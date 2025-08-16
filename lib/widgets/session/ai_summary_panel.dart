import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AISummaryPanel extends StatelessWidget {
  final String summary;
  final VoidCallback onRegenerate;
  final bool isGenerating;

  const AISummaryPanel({
    super.key,
    required this.summary,
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
              child: summary.isEmpty
                  ? _buildEmptyState(context)
                  : _buildSummaryContent(context),
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
    final lines = summary.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Analizi Tamamlandı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Özet içeriği
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map((line) {
                if (line.trim().isEmpty) return const SizedBox(height: 8);

                if (line.contains(':')) {
                  final parts = line.split(':');
                  final key = parts[0].trim();
                  final value = parts.length > 1 ? parts[1].trim() : '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
              }).toList(),
            ),
          ),
        ),

        // Alt bilgi
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bu özet AI tarafından oluşturulmuştur. Klinik kararlar için ek değerlendirme gerekebilir.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentColor,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
