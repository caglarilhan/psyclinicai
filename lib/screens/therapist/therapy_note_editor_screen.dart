import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/therapy_note_service.dart';
import '../../models/therapy_note_models.dart';

class TherapyNoteEditorScreen extends StatefulWidget {
  const TherapyNoteEditorScreen({super.key});

  @override
  State<TherapyNoteEditorScreen> createState() => _TherapyNoteEditorScreenState();
}

class _TherapyNoteEditorScreenState extends State<TherapyNoteEditorScreen> {
  TherapyNoteTemplate? _selectedTemplate;
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTemplateChanged(TherapyNoteTemplate template) {
    setState(() {
      _selectedTemplate = template;
      // Reset controllers
      for (final c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      for (final f in template.fields) {
        _controllers[f.key] = TextEditingController();
      }
    });
  }

  Future<void> _saveNote() async {
    if (_selectedTemplate == null) return;
    setState(() => _saving = true);
    try {
      final values = <String, dynamic>{};
      for (final entry in _controllers.entries) {
        values[entry.key] = entry.value.text.trim();
      }
      await context.read<TherapyNoteService>().createEntry(
            sessionId: 'demo_session_001',
            clinicianId: 'demo_therapist_001',
            clientId: 'demo_client_001',
            templateId: _selectedTemplate!.id,
            values: values,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not kaydedildi')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<TherapyNoteService>().templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seans Notu (DAP/SOAP)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<TherapyNoteTemplate>(
              isExpanded: true,
              hint: const Text('Şablon seçin'),
              value: _selectedTemplate,
              items: templates
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name),
                      ))
                  .toList(),
              onChanged: (t) {
                if (t != null) _onTemplateChanged(t);
              },
            ),
            const SizedBox(height: 16),
            if (_selectedTemplate != null)
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      _selectedTemplate!.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ..._selectedTemplate!.fields.map((f) {
                      final c = _controllers[f.key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: c,
                          maxLines: f.type == NoteFieldType.longText ? 5 : 1,
                          decoration: InputDecoration(
                            labelText: f.label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedTemplate == null || _saving ? null : _saveNote,
                    icon: const Icon(Icons.save),
                    label: _saving
                        ? const Text('Kaydediliyor...')
                        : const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
