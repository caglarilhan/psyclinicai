import 'package:flutter/material.dart';
import '../../models/diagnosis_model.dart';
import '../../utils/theme.dart';

class DiagnosisResults extends StatelessWidget {
  final List<DiagnosisModel> results;
  final bool isSearching;
  final Function(DiagnosisModel) onDiagnosisSelected;

  const DiagnosisResults({
    super.key,
    required this.results,
    required this.isSearching,
    required this.onDiagnosisSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return _buildLoadingState(context);
    }

    if (results.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildResultsList(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tanılar Aranıyor...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'ICD/DSM veritabanında arama yapılıyor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
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
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç Bulunamadı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı anahtar kelimeler deneyin\nveya filtreleri değiştirin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Öneriler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '💡 Arama İpuçları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                _buildTip('ICD kodları ile arayın (örn: F32.1)'),
                _buildTip('DSM kodları ile arayın (örn: 296.32)'),
                _buildTip('Belirti adları ile arayın (örn: depresyon)'),
                _buildTip('Tedavi yöntemleri ile arayın (örn: CBT)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final diagnosis = results[index];
        return _buildDiagnosisCard(context, diagnosis, index);
      },
    );
  }

  Widget _buildDiagnosisCard(
      BuildContext context, DiagnosisModel diagnosis, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => onDiagnosisSelected(diagnosis),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst satır - Kod ve kategori
                Row(
                  children: [
                    // Tanı kodu
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryColor),
                      ),
                      child: Text(
                        diagnosis.code,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Kategori
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        diagnosis.category,
                        style: TextStyle(
                          color: AppTheme.secondaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Standard
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        diagnosis.standard,
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tanı adı
                Text(
                  diagnosis.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 8),

                // Açıklama
                Text(
                  diagnosis.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),

                const SizedBox(height: 16),

                // Alt bilgiler
                Row(
                  children: [
                    // Şiddet
                    _buildInfoChip(
                      Icons.signal_cellular_alt,
                      diagnosis.severity,
                      _getSeverityColor(diagnosis.severity),
                    ),

                    const SizedBox(width: 12),

                    // Belirti sayısı
                    _buildInfoChip(
                      Icons.psychology,
                      '${diagnosis.symptoms.length} Belirti',
                      AppTheme.primaryColor,
                    ),

                    const SizedBox(width: 12),

                    // Tedavi sayısı
                    _buildInfoChip(
                      Icons.medical_services,
                      '${diagnosis.treatments.length} Tedavi',
                      AppTheme.accentColor,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Belirtiler (ilk 3 tanesi)
                if (diagnosis.symptoms.isNotEmpty) ...[
                  Text(
                    'Ana Belirtiler:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: diagnosis.symptoms.take(3).map((symptom) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          symptom,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),

                // Detay butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onDiagnosisSelected(diagnosis),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Detayları Gör'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
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

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return AppTheme.accentColor;
      case 'moderate':
        return AppTheme.warningColor;
      case 'severe':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}
