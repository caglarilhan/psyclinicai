import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SessionNotesPanel extends StatefulWidget {
  final String sessionNotes;
  final Function(String) onNotesChanged;
  final VoidCallback onSaveNotes;

  const SessionNotesPanel({
    super.key,
    required this.sessionNotes,
    required this.onNotesChanged,
    required this.onSaveNotes,
  });

  @override
  State<SessionNotesPanel> createState() => _SessionNotesPanelState();
}

class _SessionNotesPanelState extends State<SessionNotesPanel> {
  late TextEditingController _notesController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.sessionNotes);
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void didUpdateWidget(SessionNotesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionNotes != widget.sessionNotes) {
      _notesController.text = widget.sessionNotes;
      _hasUnsavedChanges = false;
    }
  }

  void _onNotesChanged() {
    final hasChanges = _notesController.text != widget.sessionNotes;
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
    widget.onNotesChanged(_notesController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notes,
                  color: AppTheme.infoColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seans Notları',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.infoColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seans sırasında önemli noktaları not edin',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Templates
          _buildQuickTemplates(),
          
          const SizedBox(height: 24),
          
          // Notes Editor
          Expanded(
            child: _buildNotesEditor(),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildQuickTemplates() {
    final templates = [
      {
        'title': 'Genel Gözlemler',
        'template': '• Danışanın genel ruh hali:\n• Göz teması:\n• Beden dili:\n• Konuşma hızı:\n• Duygusal ifadeler:',
      },
      {
        'title': 'Ana Problemler',
        'template': '• Sunulan problem:\n• Problem şiddeti:\n• Problem süresi:\n• Tetikleyiciler:\n• Kaçınma davranışları:',
      },
      {
        'title': 'Müdahale Planı',
        'template': '• Kullanılan teknikler:\n• Danışanın tepkisi:\n• Etkililik:\n• Sonraki adımlar:\n• Ev ödevi:',
      },
      {
        'title': 'Risk Değerlendirmesi',
        'template': '• İntihar riski:\n• Kendine zarar verme:\n• Başkalarına zarar verme:\n• Güvenlik planı:\n• Acil durum protokolü:',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Şablonlar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: templates.map((template) {
            return ElevatedButton(
              onPressed: () => _insertTemplate(template['template']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.infoColor.withOpacity(0.1),
                foregroundColor: AppTheme.infoColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                template['title']!,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Editor Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Seans Notları',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_hasUnsavedChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Kaydedilmemiş',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Text Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Seans sırasında önemli noktaları not edin...\n\nÖrnek:\n• Danışanın genel ruh hali\n• Sunulan problemler\n• Kullanılan teknikler\n• Danışanın tepkisi\n• Sonraki adımlar',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Clear Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showClearDialog,
            icon: const Icon(Icons.clear),
            label: const Text('Temizle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Save Button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _hasUnsavedChanges ? widget.onSaveNotes : null,
            icon: const Icon(Icons.save),
            label: const Text('Kaydet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.infoColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _insertTemplate(String template) {
    final currentText = _notesController.text;
    final newText = currentText.isEmpty ? template : '$currentText\n\n$template';
    _notesController.text = newText;
    
    // Cursor'ı sona taşı
    _notesController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notları Temizle'),
        content: const Text(
          'Tüm seans notlarını silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _notesController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
