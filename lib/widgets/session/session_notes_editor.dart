import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';

class SessionNotesEditor extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onContentChanged;
  final String? placeholder;
  final bool readOnly;

  const SessionNotesEditor({
    super.key,
    required this.controller,
    this.onContentChanged,
    this.placeholder,
    this.readOnly = false,
  });

  @override
  State<SessionNotesEditor> createState() => _SessionNotesEditorState();
}

class _SessionNotesEditorState extends State<SessionNotesEditor> {
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  bool _showToolbar = true;
  final FocusNode _focusNode = FocusNode();

  final List<String> _quickTemplates = [
    'Danışan bugün...',
    'Ana konular:',
    'Hedefler:',
    'Ev ödevi:',
    'Sonraki seans planı:',
    'Gözlemler:',
    'Müdahale teknikleri:',
    'Danışan tepkisi:',
    'İlerleme:',
    'Zorluklar:',
  ];

  final List<String> _clinicalTerms = [
    'Anksiyete', 'Depresyon', 'Travma', 'Stres', 'Panik',
    'Obsesyon', 'Kompulsiyon', 'Fobi', 'Paranoya', 'Halüsinasyon',
    'Manik', 'Hipomanik', 'Bipolar', 'Şizofreni', 'Borderline',
    'Narsisistik', 'Antisosyal', 'Histrionik', 'Çekingen', 'Bağımlı',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showToolbar = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        if (_showToolbar && !widget.readOnly) _buildToolbar(),
        
        // Editor
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _focusNode.hasFocus 
                    ? AppTheme.primaryColor 
                    : Colors.grey[300]!,
                width: _focusNode.hasFocus ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 16,
                fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                decoration: _isUnderlined 
                    ? TextDecoration.underline 
                    : TextDecoration.none,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder ?? 'Seans notlarınızı buraya yazın...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              onChanged: widget.onContentChanged,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Quick Actions
        if (!widget.readOnly) _buildQuickActions(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Formatting buttons
          _buildFormatButton(
            icon: Icons.format_bold,
            isActive: _isBold,
            onPressed: () => _toggleBold(),
            tooltip: 'Kalın',
          ),
          const SizedBox(width: 8),
          _buildFormatButton(
            icon: Icons.format_italic,
            isActive: _isItalic,
            onPressed: () => _toggleItalic(),
            tooltip: 'İtalik',
          ),
          const SizedBox(width: 8),
          _buildFormatButton(
            icon: Icons.format_underline,
            isActive: _isUnderlined,
            onPressed: () => _toggleUnderline(),
            tooltip: 'Altı çizili',
          ),
          
          const VerticalDivider(width: 24, thickness: 1),
          
          // Clinical terms button
          _buildFormatButton(
            icon: Icons.medical_services,
            isActive: false,
            onPressed: _showClinicalTerms,
            tooltip: 'Klinik terimler',
          ),
          
          const VerticalDivider(width: 24, thickness: 1),
          
          // Templates button
          _buildFormatButton(
            icon: Icons.template,
            isActive: false,
            onPressed: _showTemplates,
            tooltip: 'Hızlı şablonlar',
          ),
          
          const Spacer(),
          
          // Word count
          _buildWordCount(),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: IconButton(
          icon: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.white : Colors.grey[700],
          ),
          onPressed: onPressed,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildWordCount() {
    final wordCount = widget.controller.text.split(' ').length;
    final charCount = widget.controller.text.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$wordCount kelime, $charCount karakter',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Şablonlar',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickTemplates.map((template) => ActionChip(
            label: Text(template),
            onPressed: () => _insertTemplate(template),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          )).toList(),
        ),
      ],
    );
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
    _applyFormatting();
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
    _applyFormatting();
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderlined = !_isUnderlined;
    });
    _applyFormatting();
  }

  void _applyFormatting() {
    // Formatting uygulama (basit implementasyon)
    final text = widget.controller.text;
    if (text.isNotEmpty) {
      // Gerçek uygulamada rich text kullanılabilir
      // Şimdilik sadece state'i güncelliyoruz
      setState(() {});
    }
  }

  void _insertTemplate(String template) {
    final currentText = widget.controller.text;
    final newText = currentText.isEmpty ? template : '$currentText\n$template';
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    
    if (widget.onContentChanged != null) {
      widget.onContentChanged!(newText);
    }
  }

  void _showClinicalTerms() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Klinik Terimler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _clinicalTerms.length,
                itemBuilder: (context, index) {
                  final term = _clinicalTerms[index];
                  return InkWell(
                    onTap: () {
                      _insertClinicalTerm(term);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          term,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insertClinicalTerm(String term) {
    final currentText = widget.controller.text;
    final newText = currentText.isEmpty ? term : '$currentText $term';
    widget.controller.text = newText;
    
    if (widget.onContentChanged != null) {
      widget.onContentChanged!(newText);
    }
  }

  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.template,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Hızlı Şablonlar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _quickTemplates.length,
                itemBuilder: (context, index) {
                  final template = _quickTemplates[index];
                  return ListTile(
                    leading: Icon(
                      Icons.edit_note,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(template),
                    subtitle: Text('Şablonu ekle'),
                    onTap: () {
                      _insertTemplate(template);
                      Navigator.pop(context);
                    },
                    trailing: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
