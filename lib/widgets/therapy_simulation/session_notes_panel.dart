import 'package:flutter/material.dart';

class SessionNotesPanel extends StatefulWidget {
  final String sessionNotes;
  final void Function(String) onNotesChanged;
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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.sessionNotes);
  }

  @override
  void didUpdateWidget(covariant SessionNotesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionNotes != widget.sessionNotes) {
      _controller.text = widget.sessionNotes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seans Notları',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onNotesChanged,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText:
                    'Seans notlarınızı buraya yazın... (DSM/ICD odaklı başlıklar kullanın)\n\nÖrnek şablon:\n- Sunulan Problem\n- Duygulanım\n- Bilişsel İçerik\n- Davranışlar\n- Müdahaleler\n- Ev Ödevi\n- Plan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onSaveNotes,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
