import 'package:flutter/material.dart';
import '../../services/teletherapy_service.dart';
import '../../services/audit_log_service.dart';
import '../../utils/theme.dart';

class CallScreenWidget extends StatefulWidget {
  final String clientName;
  final String therapistName;
  const CallScreenWidget({super.key, required this.clientName, required this.therapistName});

  @override
  State<CallScreenWidget> createState() => _CallScreenWidgetState();
}

class _CallScreenWidgetState extends State<CallScreenWidget> {
  final TeletherapyService _tele = TeletherapyService();

  @override
  void initState() {
    super.initState();
    _tele.statusStream.listen((_) => setState(() {}));
    _tele.eventStream.listen((e) {
      // future: UI hints
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = _tele.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teleterapi Görüşmesi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Durum: $status') ,
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
              color: Colors.black,
            ),
            child: const Text('Sahte video alanı', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(_tele.micOn ? Icons.mic : Icons.mic_off),
              color: Colors.white,
              style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () {
                _tele.toggleMic();
                unawaited(AuditLogService().insertLog(
                  action: _tele.micOn ? 'tele.mic.on' : 'tele.mic.off',
                  actor: widget.therapistName,
                  target: widget.clientName,
                  metadataJson: '{}',
                ));
              },
            ),
            IconButton(
              icon: Icon(_tele.camOn ? Icons.videocam : Icons.videocam_off),
              color: Colors.white,
              style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () {
                _tele.toggleCam();
                unawaited(AuditLogService().insertLog(
                  action: _tele.camOn ? 'tele.cam.on' : 'tele.cam.off',
                  actor: widget.therapistName,
                  target: widget.clientName,
                  metadataJson: '{}',
                ));
              },
            ),
            ElevatedButton.icon(
              onPressed: status == TeleCallStatus.inCall ? _hangup : null,
              icon: const Icon(Icons.call_end),
              label: const Text('Bitir'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            )
          ],
        )
      ],
    );
  }

  void _hangup() {
    _tele.endCall();
    unawaited(AuditLogService().insertLog(
      action: 'tele.call.end',
      actor: widget.therapistName,
      target: widget.clientName,
      metadataJson: '{}',
    ));
  }
}


