import 'package:flutter/material.dart';
import '../../services/teletherapy_service.dart';
import '../../services/audit_log_service.dart';
import '../../utils/theme.dart';

class WaitingRoomWidget extends StatefulWidget {
  final String clientName;
  final String therapistName;
  const WaitingRoomWidget({super.key, required this.clientName, required this.therapistName});

  @override
  State<WaitingRoomWidget> createState() => _WaitingRoomWidgetState();
}

class _WaitingRoomWidgetState extends State<WaitingRoomWidget> {
  final TeletherapyService _tele = TeletherapyService();

  @override
  void initState() {
    super.initState();
    _tele.enterWaitingRoom();
    unawaited(AuditLogService().insertLog(
      action: 'tele.waiting.enter',
      actor: widget.therapistName,
      target: widget.clientName,
      metadataJson: '{}',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bekleme Odası', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Danışan: ${widget.clientName}'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              const Icon(Icons.videocam, size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text('Görüşme hazır olduğunda bağlanabilirsiniz.')),
              ElevatedButton.icon(
                onPressed: _tele.status == TeleCallStatus.waiting ? _connect : null,
                icon: const Icon(Icons.call),
                label: const Text('Bağlan'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _connect() {
    _tele.startConnecting();
    unawaited(AuditLogService().insertLog(
      action: 'tele.call.connect',
      actor: widget.therapistName,
      target: widget.clientName,
      metadataJson: '{}',
    ));
  }
}


