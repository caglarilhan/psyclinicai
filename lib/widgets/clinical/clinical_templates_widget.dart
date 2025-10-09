import 'package:flutter/material.dart';
import '../../models/session_note_models.dart';
import '../../services/session_note_service.dart';
import '../../utils/theme.dart';

class ClinicalTemplatesWidget extends StatefulWidget {
  final Function(SessionNoteTemplate)? onTemplateSelected;

  const ClinicalTemplatesWidget({
    super.key,
    this.onTemplateSelected,
  });

  @override
  State<ClinicalTemplatesWidget> createState() => _ClinicalTemplatesWidgetState();
}

class _ClinicalTemplatesWidgetState extends State<ClinicalTemplatesWidget> {
  final _noteService = SessionNoteService();
  List<SessionNoteTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _noteService.getTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Şablonlar yüklenemedi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.description, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Klinik Şablonları',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showCreateTemplateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Şablon'),
              ),
            ],
          ),
        ),
        
        // Templates Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              return _buildTemplateCard(template);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(SessionNoteTemplate template) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _selectTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template Header
              Row(
                children: [
                  Icon(
                    _getTemplateIcon(template.type),
                    color: _getTemplateColor(template.type),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (template.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Varsayılan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Template Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTemplateColor(template.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTypeDisplayName(template.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTemplateColor(template.type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Template Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTemplatePreview(template.content),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTemplate(template),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Kullan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showTemplatePreview(template),
                    icon: const Icon(Icons.visibility, size: 16),
                    tooltip: 'Önizle',
                  ),
                  IconButton(
                    onPressed: () => _editTemplate(template),
                    icon: const Icon(Icons.edit, size: 16),
                    tooltip: 'Düzenle',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTemplate(SessionNoteTemplate template) {
    if (widget.onTemplateSelected != null) {
      widget.onTemplateSelected!(template);
    } else {
      _showTemplatePreview(template);
    }
  }

  void _showTemplatePreview(SessionNoteTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              template.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _selectTemplate(template);
            },
            child: const Text('Kullan'),
          ),
        ],
      ),
    );
  }

  void _editTemplate(SessionNoteTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _TemplateEditorDialog(
        template: template,
        onSaved: (updatedTemplate) {
          Navigator.pop(context);
          _loadTemplates(); // Reload templates
        },
      ),
    );
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplateEditorDialog(
        onSaved: (newTemplate) {
          Navigator.pop(context);
          _loadTemplates(); // Reload templates
        },
      ),
    );
  }

  IconData _getTemplateIcon(SessionNoteType type) {
    switch (type) {
      case SessionNoteType.soap:
        return Icons.medical_services;
      case SessionNoteType.dap:
        return Icons.assessment;
      case SessionNoteType.emdr:
        return Icons.psychology;
      case SessionNoteType.cbt:
        return Icons.psychology;
      case SessionNoteType.general:
        return Icons.description;
    }
  }

  Color _getTemplateColor(SessionNoteType type) {
    switch (type) {
      case SessionNoteType.soap:
        return Colors.blue;
      case SessionNoteType.dap:
        return Colors.green;
      case SessionNoteType.emdr:
        return Colors.purple;
      case SessionNoteType.cbt:
        return Colors.orange;
      case SessionNoteType.general:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(SessionNoteType type) {
    switch (type) {
      case SessionNoteType.soap:
        return 'SOAP';
      case SessionNoteType.dap:
        return 'DAP';
      case SessionNoteType.emdr:
        return 'EMDR';
      case SessionNoteType.cbt:
        return 'CBT';
      case SessionNoteType.general:
        return 'Genel';
    }
  }

  String _getTemplatePreview(String content) {
    // İlk 200 karakteri al ve markdown formatını temizle
    final cleanContent = content
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // **bold** -> bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // *italic* -> italic
        .replaceAll(RegExp(r'#+\s*'), '') // # headers -> plain text
        .trim();
    
    return cleanContent.length > 200 
        ? '${cleanContent.substring(0, 200)}...'
        : cleanContent;
  }
}

class _TemplateEditorDialog extends StatefulWidget {
  final SessionNoteTemplate? template;
  final Function(SessionNoteTemplate) onSaved;

  const _TemplateEditorDialog({
    this.template,
    required this.onSaved,
  });

  @override
  State<_TemplateEditorDialog> createState() => _TemplateEditorDialogState();
}

class _TemplateEditorDialogState extends State<_TemplateEditorDialog> {
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SessionNoteType _selectedType = SessionNoteType.general;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _contentController.text = widget.template!.content;
      _selectedType = widget.template!.type;
      _isDefault = widget.template!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.template == null ? 'Yeni Şablon' : 'Şablon Düzenle'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Template Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Şablon Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Şablon adı gerekli';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Template Type
              DropdownButtonFormField<SessionNoteType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Şablon Türü',
                  border: OutlineInputBorder(),
                ),
                items: SessionNoteType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Is Default Checkbox
              CheckboxListTile(
                title: const Text('Varsayılan Şablon'),
                subtitle: const Text('Bu tür için varsayılan şablon olarak kullan'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value ?? false);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Template Content
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Şablon İçeriği',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Şablon içeriği gerekli';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveTemplate,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  void _saveTemplate() {
    if (!_formKey.currentState!.validate()) return;
    
    final template = SessionNoteTemplate(
      id: widget.template?.id ?? 'template_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      content: _contentController.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.template?.createdAt ?? DateTime.now(),
    );
    
    widget.onSaved(template);
  }

  String _getTypeDisplayName(SessionNoteType type) {
    switch (type) {
      case SessionNoteType.soap:
        return 'SOAP';
      case SessionNoteType.dap:
        return 'DAP';
      case SessionNoteType.emdr:
        return 'EMDR';
      case SessionNoteType.cbt:
        return 'CBT';
      case SessionNoteType.general:
        return 'Genel';
    }
  }
}
