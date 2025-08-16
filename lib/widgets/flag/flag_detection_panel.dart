import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class FlagDetectionPanel extends StatefulWidget {
  final Function(String) onAnalyzeNotes;
  final bool isAnalyzing;

  const FlagDetectionPanel({
    super.key,
    required this.onAnalyzeNotes,
    required this.isAnalyzing,
  });

  @override
  State<FlagDetectionPanel> createState() => _FlagDetectionPanelState();
}

class _FlagDetectionPanelState extends State<FlagDetectionPanel> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
                Icons.psychology,
                color: AppTheme.errorColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Risk Tespiti',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Açıklama
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.errorColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 Risk Tespit Sistemi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seans notlarınızı AI ile analiz ederek potansiyel risk durumlarını tespit edin. '
                  'Sistem otomatik olarak intihar riski, kriz durumu, şiddet riski gibi kritik durumları belirler.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seans notu girişi
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              children: [
                // Not metni
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: '''Seans notlarınızı buraya yazın...

AI şu risk durumlarını tespit eder:
• İntihar riski (ölüm, intihar, öldürmek)
• Kriz durumu (ajite, agresif, kriz)
• Kendine zarar verme
• Şiddet riski

Not: Hassas bilgiler güvenli şekilde işlenir.''',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                // Hızlı örnekler
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hızlı Örnekler:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildExampleChip('İntihar Riski',
                              'Danışan ölüm düşüncelerini ifade etti'),
                          _buildExampleChip(
                              'Kriz Durumu', 'Danışan aşırı ajite ve agresif'),
                          _buildExampleChip('Kendine Zarar',
                              'Danışan kendine zarar vermek istiyor'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Analiz butonu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _notesController.text.trim().isNotEmpty &&
                            !widget.isAnalyzing
                        ? () => widget.onAnalyzeNotes(_notesController.text)
                        : null,
                    icon: widget.isAnalyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.security),
                    label: Text(widget.isAnalyzing
                        ? 'AI Analiz Ediyor...'
                        : 'Risk Analizi Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bilgi paneli
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Önemli Bilgi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu sistem sadece yardımcı bir araçtır. Tespit edilen riskler için mutlaka '
                  'profesyonel klinik değerlendirme yapılmalıdır. Acil durumlarda 112\'yi arayın.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String label, String example) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _notesController.text = example;
      },
      backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: AppTheme.errorColor),
      avatar: Icon(
        Icons.add,
        size: 16,
        color: AppTheme.errorColor,
      ),
    );
  }
}
