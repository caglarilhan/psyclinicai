import 'package:flutter/material.dart';
import '../../services/audit_log_service.dart';

class TeletherapyAuditSummaryWidget extends StatelessWidget {
  final String therapistName;
  const TeletherapyAuditSummaryWidget({super.key, required this.therapistName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuditLogService().listLogs(limit: 500),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = (snapshot.data ?? [])
            .where((e) => e.action.startsWith('tele.') && e.actor == therapistName)
            .toList();
        final created = logs.where((e) => e.action == 'tele.create').length;
        final joined = logs.where((e) => e.action == 'tele.join').length;
        final ended = logs.where((e) => e.action == 'tele.end').length;
        final locked = logs.where((e) => e.action == 'tele.lock').length;
        final unlocked = logs.where((e) => e.action == 'tele.unlock').length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat('Oluşturulan', created, Colors.blue),
            _stat('Katılım', joined, Colors.green),
            _stat('Bitirilen', ended, Colors.red),
            _stat('Kilit', locked, Colors.orange),
            _stat('Açık', unlocked, Colors.teal),
          ],
        );
      },
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Text(value.toString(), style: TextStyle(color: color))),
        const SizedBox(height: 6),
        Text(title),
      ],
    );
  }
}


