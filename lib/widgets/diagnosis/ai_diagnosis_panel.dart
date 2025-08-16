import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AIDiagnosisPanel extends StatefulWidget {
  final Function(String) onGenerateRecommendation;
  final String suggestion;

  const AIDiagnosisPanel({
    super.key,
    required this.onGenerateRecommendation,
    required this.suggestion,
  });

  @override
  State<AIDiagnosisPanel> createState() => _AIDiagnosisPanelState();
}

class _AIDiagnosisPanelState extends State<AIDiagnosisPanel> {
  final TextEditingController _symptomsController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _symptomsController.dispose();
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
                'AI Tanı Önerisi',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Belirti girişi
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
                // Belirti metni
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _symptomsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '''Belirtileri buraya yazın...

Örnek:
- Danışan sürekli üzgün hissediyor
- Uyku düzeni bozuldu
- İlgi kaybı yaşıyor
- Enerji düşüklüğü var
- Konsantrasyon güçlüğü

AI bu bilgilere göre olası tanıları önerecektir.''',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                // Hızlı belirti şablonları
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hızlı Şablonlar:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSymptomChip(
                              'Depresyon', 'Üzgün, umutsuz, ilgi kaybı'),
                          _buildSymptomChip(
                              'Anksiyete', 'Endişe, huzursuzluk, panik'),
                          _buildSymptomChip(
                              'PTSD', 'Travma, flashback, kaçınma'),
                          _buildSymptomChip(
                              'Bipolar', 'Mood değişimi, enerji dalgalanması'),
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
                    onPressed: _symptomsController.text.trim().isNotEmpty &&
                            !_isGenerating
                        ? () {
                            widget.onGenerateRecommendation(
                                _symptomsController.text);
                            setState(() => _isGenerating = true);
                            // Simülasyon için timer
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() => _isGenerating = false);
                              }
                            });
                          }
                        : null,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(_isGenerating
                        ? 'AI Analiz Ediyor...'
                        : 'AI ile Analiz Et'),
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
          if (widget.suggestion.isNotEmpty) ...[
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
                        'AI Tanı Önerisi',
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
                  _buildSuggestionContent(widget.suggestion),
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
                    Icons.psychology,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Tanı Önerisi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belirtileri yazıp AI analizi başlatın',
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

  Widget _buildSymptomChip(String label, String description) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _symptomsController.text = description;
      },
      backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: AppTheme.secondaryColor),
      avatar: Icon(
        Icons.add,
        size: 16,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildSuggestionContent(String suggestion) {
    final lines = suggestion.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        if (line.startsWith('✅')) {
          // Belirti eşleşmesi
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
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        } else if (line.startsWith('1.') ||
            line.startsWith('2.') ||
            line.startsWith('3.') ||
            line.startsWith('4.')) {
          // Önerilen müdahale
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.medical_services,
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
