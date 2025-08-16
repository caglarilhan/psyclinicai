import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AIRecommendationPanel extends StatefulWidget {
  final Function(String, List<String>) onGenerateRecommendation;
  final String recommendation;
  final bool isGenerating;

  const AIRecommendationPanel({
    super.key,
    required this.onGenerateRecommendation,
    required this.recommendation,
    required this.isGenerating,
  });

  @override
  State<AIRecommendationPanel> createState() => _AIRecommendationPanelState();
}

class _AIRecommendationPanelState extends State<AIRecommendationPanel> {
  final TextEditingController _diagnosisController = TextEditingController();
  final List<String> _currentMeds = [];
  final TextEditingController _medController = TextEditingController();

  @override
  void dispose() {
    _diagnosisController.dispose();
    _medController.dispose();
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
                Icons.auto_awesome,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI İlaç Önerisi',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Açıklama
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.secondaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💊 AI Destekli İlaç Önerisi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tanı ve mevcut ilaçları girerek AI\'dan özelleştirilmiş ilaç önerileri alın. '
                  'Sistem etkileşimleri kontrol eder ve güvenli kombinasyonlar önerir.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tanı girişi
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
                // Tanı metni
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _diagnosisController,
                    decoration: InputDecoration(
                      labelText: 'Tanı',
                      hintText: 'Örn: Major Depressive Disorder (F32.1)',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Mevcut ilaçlar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mevcut İlaçlar:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_currentMeds.isNotEmpty) ...[
                        ..._currentMeds.asMap().entries.map((entry) {
                          final index = entry.key;
                          final med = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(med)),
                                IconButton(
                                  onPressed: () => _removeMedication(index),
                                  icon: const Icon(Icons.close, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _medController,
                              decoration: const InputDecoration(
                                labelText: 'İlaç Ekle',
                                hintText: 'Örn: Sertraline 50mg',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_medController.text.isNotEmpty) {
                                setState(() {
                                  _currentMeds.add(_medController.text);
                                  _medController.clear();
                                });
                              }
                            },
                            child: const Text('Ekle'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // AI analiz butonu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _diagnosisController.text.trim().isNotEmpty &&
                            !widget.isGenerating
                        ? () => widget.onGenerateRecommendation(
                            _diagnosisController.text, _currentMeds)
                        : null,
                    icon: widget.isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(widget.isGenerating
                        ? 'AI Analiz Ediyor...'
                        : 'AI Önerisi Al'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // AI önerisi sonucu
          if (widget.recommendation.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI İlaç Önerisi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '85% Güven',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Öneri içeriği
                  _buildRecommendationContent(widget.recommendation),
                ],
              ),
            ),
          ] else ...[
            // Boş durum
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medication,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI İlaç Önerisi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanı ve mevcut ilaçları girip AI analizi başlatın',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _currentMeds.removeAt(index);
    });
  }

  Widget _buildRecommendationContent(String recommendation) {
    final lines = recommendation.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        if (line.startsWith('1.') || line.startsWith('2.')) {
          // İlaç önerisi
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.medication,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.trim(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        } else if (line.startsWith('✅')) {
          // Güvenli kombinasyon
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.accentColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.replaceFirst('✅', '').trim(),
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (line.startsWith('⚠️')) {
          // Uyarı
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppTheme.warningColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.replaceFirst('⚠️', '').trim(),
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (line.startsWith('❌')) {
          // Tehlikeli kombinasyon
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.dangerous,
                  color: AppTheme.errorColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.replaceFirst('❌', '').trim(),
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (line.contains(':')) {
          // Anahtar-değer çifti
          final parts = line.split(':');
          if (parts.length >= 2) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parts[0].trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    parts[1].trim(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }
        }

        // Normal metin
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
