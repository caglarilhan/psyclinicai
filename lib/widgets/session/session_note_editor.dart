import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SessionNoteEditor extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onGenerateAI;
  final bool isGeneratingAI;

  const SessionNoteEditor({
    super.key,
    required this.controller,
    required this.onGenerateAI,
    required this.isGeneratingAI,
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
                Icons.edit_note,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Seans Notu',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              // Klavye kısayolları bilgisi
              IconButton(
                icon: const Icon(Icons.keyboard),
                onPressed: () {
                  _showKeyboardShortcuts(context);
                },
                tooltip: 'Klavye Kısayolları',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hızlı şablonlar
          Wrap(
            spacing: 8,
            children: [
              _buildTemplateChip(context, 'Depresyon', 'Danışan bugün...'),
              _buildTemplateChip(context, 'Anksiyete', 'Danışan sürekli...'),
              _buildTemplateChip(context, 'Travma', 'Danışan geçmişte...'),
              _buildTemplateChip(context, 'İlişki', 'Danışan partneri ile...'),
            ],
          ),
          const SizedBox(height: 16),

          // Not editörü
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: '''Seans notunuzu buraya yazın...

Örnek format:
- Danışanın genel durumu
- Ana konular ve duygular
- Kullanılan teknikler
- Sonraki seans planı
- Önemli gözlemler

Not: AI özeti için detaylı yazmanız önerilir.''',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),

          // Alt butonlar
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      controller.text.trim().isNotEmpty ? onGenerateAI : null,
                  icon: isGeneratingAI
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                      isGeneratingAI ? 'AI İşleniyor...' : 'AI Özeti Oluştur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: controller.text.trim().isNotEmpty
                    ? () {
                        // TODO: Save to local storage
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Not kaydedildi')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip(
      BuildContext context, String label, String template) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        if (controller.text.isEmpty) {
          controller.text = template;
        } else {
          controller.text += '\n\n$template';
        }
      },
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: AppTheme.primaryColor),
    );
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klavye Kısayolları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShortcutRow('Ctrl + N', 'Yeni seans başlat'),
            _buildShortcutRow('Ctrl + S', 'Notu kaydet'),
            _buildShortcutRow('Ctrl + P', 'PDF çıktısı'),
            _buildShortcutRow(
                'Ctrl + Shift + A', 'AI özetini yeniden çalıştır'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
