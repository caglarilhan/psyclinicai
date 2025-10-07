import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../services/teletherapy_service.dart';
import '../../utils/theme.dart';

class TeletherapySessionWidget extends StatefulWidget {
  final String clientName;
  final String therapistName;
  const TeletherapySessionWidget({super.key, required this.clientName, required this.therapistName});

  @override
  State<TeletherapySessionWidget> createState() => _TeletherapySessionWidgetState();
}

class _TeletherapySessionWidgetState extends State<TeletherapySessionWidget> {
  final TeletherapyService _service = TeletherapyService();
  TeletherapySession? _session;
  bool _busy = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.videocam, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Teleterapi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          if (_session == null) ...[
            Text('Danışan: ${widget.clientName}'),
            Text('Terapist: ${widget.therapistName}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _create,
                icon: _busy ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.play_circle),
                label: Text(_busy ? 'Oluşturuluyor...' : 'Oturumu Başlat'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              ),
            )
          ] else ...[
            Text('Oturum ID: ${_session!.sessionId}'),
            const SizedBox(height: 4),
            SelectableText(_session!.meetingUrl, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => Clipboard.setData(ClipboardData(text: _session!.meetingUrl)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bağlantı kopyalandı')));
                  }),
                  icon: const Icon(Icons.copy),
                  label: const Text('Linki Kopyala'),
                ),
                const SizedBox(width: 12),
                Chip(label: Text('Süre: ' + _format(_elapsed))),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _join,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Bağlantıyı Aç'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _end,
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('Oturumu Bitir'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
                ),
              ),
            ])
          ]
        ],
      ),
    );
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    try {
      final s = await _service.createSession(clientName: widget.clientName, therapistName: widget.therapistName);
      if (mounted) {
        setState(() => _session = s);
        _startTimer();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    final s = _session; if (s == null) return;
    setState(() => _busy = true);
    try {
      await _service.openMeetingUrl(s.meetingUrl, clientName: s.clientName, therapistName: s.therapistName);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _end() async {
    final s = _session; if (s == null) return;
    setState(() => _busy = true);
    try {
      await _service.endSession(s);
      if (mounted) setState(() { _session = null; _stopTimer(); _elapsed = Duration.zero; });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _elapsed + const Duration(seconds: 1));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}


