import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class PDFExportPanel extends StatelessWidget {
  final VoidCallback onExport;
  final bool isExporting;

  const PDFExportPanel({
    super.key,
    required this.onExport,
    required this.isExporting,
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
                Icons.picture_as_pdf,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'PDF Export',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Export seçenekleri
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Export formatları
                  Text(
                    'Export Formatları',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Format seçenekleri
                  _buildFormatOption(
                    context,
                    'Klinik Not',
                    'Seans notu + AI özeti',
                    Icons.medical_services,
                    true,
                  ),
                  const SizedBox(height: 8),

                  _buildFormatOption(
                    context,
                    'Danışan Raporu',
                    'Sadece seans notu',
                    Icons.person,
                    false,
                  ),
                  const SizedBox(height: 8),

                  _buildFormatOption(
                    context,
                    'Süpervizyon',
                    'Detaylı analiz + öneriler',
                    Icons.supervisor_account,
                    false,
                  ),

                  const Spacer(),

                  // Export butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isExporting ? null : onExport,
                      icon: isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                          isExporting ? 'PDF Oluşturuluyor...' : 'PDF Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bilgi metni
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
                            'PDF\'ler otomatik olarak kaydedilir ve paylaşılabilir',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accentColor,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accentColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTheme.accentColor : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.accentColor : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.accentColor : null,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? AppTheme.accentColor
                            : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: AppTheme.accentColor,
              size: 20,
            ),
        ],
      ),
    );
  }
}
