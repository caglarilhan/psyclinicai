import 'package:flutter/material.dart';
import '../../models/mbc_models.dart';
import '../../services/assessment_service.dart';

class AssessmentHistory extends StatefulWidget {
  final String clientName;
  const AssessmentHistory({super.key, required this.clientName});

  @override
  State<AssessmentHistory> createState() => _AssessmentHistoryState();
}

class _AssessmentHistoryState extends State<AssessmentHistory> {
  late Future<List<AssessmentResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = AssessmentService().listResults(clientName: widget.clientName, limit: 200);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssessmentResult>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Henüz değerlendirme yok'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = items[i];
            final scoreText = '${r.totalScore}';
            final sub = '${r.type} • ${r.createdAt.toLocal()}';
            return ListTile(
              title: Text('${r.clientName} - ${r.type}'),
              subtitle: Text(sub),
              trailing: CircleAvatar(radius: 14, child: Text(scoreText)),
            );
          },
        );
      },
    );
  }
}


