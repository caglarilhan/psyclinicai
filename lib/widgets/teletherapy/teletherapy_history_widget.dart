import 'package:flutter/material.dart';
import '../../services/audit_log_service.dart';

class TeletherapyHistoryWidget extends StatelessWidget {
  final String clientName;
  const TeletherapyHistoryWidget({super.key, required this.clientName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuditLogService().listLogs(limit: 500),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = (snapshot.data ?? [])
            .where((e) => e.action.startsWith('tele.') && e.target.startsWith(clientName + '|'))
            .toList();
        if (logs.isEmpty) return const Center(child: Text('Teleterapi kaydı yok'));
        return ListView.separated(
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = logs[i];
            return ListTile(
              title: Text(e.action),
              subtitle: Text(e.createdAt.toLocal().toString()),
              trailing: Text(e.actor),
            );
          },
        );
      },
    );
  }
}


