import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/session_note_models.dart';
import '../../services/session_note_service.dart';
import '../../utils/theme.dart';

class SessionNoteEditorWidget extends StatefulWidget {
  final String? noteId;
  final String sessionId;
  final String clientId;
  final String therapistId;
  final SessionNoteType? initialType;

  const SessionNoteEditorWidget({
    super.key,
    this.noteId,
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
    this.initialType,
  });

  @override
  State<SessionNoteEditorWidget> createState() => _SessionNoteEditorWidgetState();
}

class _SessionNoteEditorWidgetState extends State<SessionNoteEditorWidget> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  SessionNoteService _noteService = SessionNoteService();
  SessionNote? _currentNote;
  SessionNoteType _selectedType = SessionNoteType.general;
  SessionNoteStatus _currentStatus = SessionNoteStatus.draft;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLocked = false;
  int _currentVersion = 1;
  List<SessionNoteTemplate> _templates = [];
  SessionNoteTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    if (widget.noteId != null) {
      _loadNote();
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _noteService.getTemplates();
      setState(() {
        _templates = templates;
      });
    } catch (e) {
      _showError('Şablonlar yüklenemedi: $e');
    }
  }

  Future<void> _loadNote() async {
    if (widget.noteId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final note = await _noteService.getSessionNote(widget.noteId!);
      if (note != null) {
        setState(() {
          _currentNote = note;
          _contentController.text = note.content;
          _selectedType = note.type;
          _currentStatus = note.status;
          _currentVersion = note.version;
          _isLocked = note.status == SessionNoteStatus.locked;
        });
      }
    } catch (e) {
      _showError('Not yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      if (_currentNote == null) {
        // Create new note
        final noteId = await _noteService.createSessionNote(
          sessionId: widget.sessionId,
          clientId: widget.clientId,
          therapistId: widget.therapistId,
          type: _selectedType,
          templateId: _selectedTemplate?.id,
        );
        
        await _noteService.updateSessionNote(
          noteId,
          _contentController.text,
          widget.therapistId,
        );
        
        _showSuccess('Not başarıyla oluşturuldu');
        Navigator.pop(context, true);
      } else {
        // Update existing note
        final success = await _noteService.updateSessionNote(
          _currentNote!.id,
          _contentController.text,
          widget.therapistId,
        );
        
        if (success) {
          _showSuccess('Not başarıyla güncellendi');
          await _loadNote(); // Reload to get updated version
        } else {
          _showError('Not güncellenemedi (kilitli olabilir)');
        }
      }
    } catch (e) {
      _showError('Kaydetme hatası: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _lockNote() async {
    if (_currentNote == null) return;
    
    final confirmed = await _showConfirmDialog(
      'Notu Kilitle',
      'Bu notu kilitlemek istediğinizden emin misiniz? Kilitlendikten sonra düzenlenemez.',
    );
    
    if (!confirmed) return;
    
    try {
      final success = await _noteService.lockSessionNote(
        _currentNote!.id,
        widget.therapistId,
      );
      
      if (success) {
        _showSuccess('Not başarıyla kilitlendi');
        await _loadNote();
      } else {
        _showError('Not kilitlenemedi');
      }
    } catch (e) {
      _showError('Kilitleme hatası: $e');
    }
  }

  Future<void> _unlockNote() async {
    if (_currentNote == null) return;
    
    final confirmed = await _showConfirmDialog(
      'Notu Aç',
      'Bu notu açmak istediğinizden emin misiniz?',
    );
    
    if (!confirmed) return;
    
    try {
      final success = await _noteService.unlockSessionNote(
        _currentNote!.id,
        widget.therapistId,
      );
      
      if (success) {
        _showSuccess('Not başarıyla açıldı');
        await _loadNote();
      } else {
        _showError('Not açılamadı');
      }
    } catch (e) {
      _showError('Açma hatası: $e');
    }
  }

  void _showVersionHistory() {
    if (_currentNote == null) return;
    
    showDialog(
      context: context,
      builder: (context) => _VersionHistoryDialog(noteId: _currentNote!.id),
    );
  }

  void _applyTemplate(SessionNoteTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _selectedType = template.type;
      _contentController.text = template.content;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentNote == null ? 'Yeni Seans Notu' : 'Seans Notu Düzenle'),
        actions: [
          if (_currentNote != null) ...[
            IconButton(
              onPressed: _showVersionHistory,
              icon: const Icon(Icons.history),
              tooltip: 'Versiyon Geçmişi',
            ),
            IconButton(
              onPressed: _isLocked ? _unlockNote : _lockNote,
              icon: Icon(_isLocked ? Icons.lock_open : Icons.lock),
              tooltip: _isLocked ? 'Kilidi Aç' : 'Kilitle',
            ),
          ],
          IconButton(
            onPressed: _isSaving ? null : _saveNote,
            icon: _isSaving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Template Selection
            if (_templates.isNotEmpty && _currentNote == null)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Şablon Seç',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _templates.map((template) {
                        return FilterChip(
                          label: Text(template.name),
                          selected: _selectedTemplate?.id == template.id,
                          onSelected: (selected) {
                            if (selected) {
                              _applyTemplate(template);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            
            // Note Type and Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SessionNoteType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Not Türü',
                        border: OutlineInputBorder(),
                      ),
                      items: SessionNoteType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: _isLocked ? null : (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durum',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _getStatusDisplayName(_currentStatus),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_currentStatus),
                            ),
                          ),
                          if (_currentNote != null)
                            Text(
                              'Versiyon: $_currentVersion',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content Editor
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Not İçeriği',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  enabled: !_isLocked,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Not içeriği boş olamaz';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getStatusDisplayName(SessionNoteStatus status) {
    switch (status) {
      case SessionNoteStatus.draft:
        return 'Taslak';
      case SessionNoteStatus.locked:
        return 'Kilitli';
      case SessionNoteStatus.archived:
        return 'Arşivlenmiş';
    }
  }

  Color _getStatusColor(SessionNoteStatus status) {
    switch (status) {
      case SessionNoteStatus.draft:
        return Colors.orange;
      case SessionNoteStatus.locked:
        return Colors.green;
      case SessionNoteStatus.archived:
        return Colors.grey;
    }
  }
}

class _VersionHistoryDialog extends StatefulWidget {
  final String noteId;

  const _VersionHistoryDialog({required this.noteId});

  @override
  State<_VersionHistoryDialog> createState() => _VersionHistoryDialogState();
}

class _VersionHistoryDialogState extends State<_VersionHistoryDialog> {
  final _noteService = SessionNoteService();
  List<SessionNoteVersion> _versions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    try {
      final versions = await _noteService.getNoteVersions(widget.noteId);
      setState(() {
        _versions = versions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Versiyon Geçmişi'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _versions.isEmpty
                ? const Center(child: Text('Versiyon bulunamadı'))
                : ListView.builder(
                    itemCount: _versions.length,
                    itemBuilder: (context, index) {
                      final version = _versions[index];
                      return Card(
                        child: ListTile(
                          title: Text('Versiyon ${version.version}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(version.changeDescription),
                              Text(
                                '${version.createdBy} - ${_formatDate(version.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: TextButton(
                            onPressed: () => _restoreVersion(version.version),
                            child: const Text('Geri Yükle'),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Future<void> _restoreVersion(int version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Versiyonu Geri Yükle'),
        content: Text('Versiyon $version geri yüklenecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _noteService.restoreVersion(
          widget.noteId,
          version,
          'current_user', // TODO: Get actual user ID
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Versiyon başarıyla geri yüklendi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Versiyon geri yüklenemedi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
