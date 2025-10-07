import 'package:flutter/material.dart';
import '../../services/teletherapy_service.dart';

class TranscriptPanel extends StatefulWidget {
  const TranscriptPanel({super.key});

  @override
  State<TranscriptPanel> createState() => _TranscriptPanelState();
}

class _TranscriptPanelState extends State<TranscriptPanel> {
  final TeletherapyService _tele = TeletherapyService();
  final List<String> _lines = [];

  @override
  void initState() {
    super.initState();
    _tele.transcriptStream.listen((line) {
      setState(() => _lines.add(line));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const Text('Transkript bekleniyor...');
    }
    return ListView.builder(
      itemCount: _lines.length,
      itemBuilder: (_, i) => ListTile(
        dense: true,
        title: Text(_lines[i]),
      ),
    );
  }
}
