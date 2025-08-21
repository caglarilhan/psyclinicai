import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/homework_service.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HomeworkService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ev Ödevi Atama')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Şablon'),
                    items: service.templates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      await service.assign(
                        clientId: 'demo_client_001',
                        clinicianId: 'demo_therapist_001',
                        templateId: v,
                        customInstructions: 'Kısa talimat',
                        dueDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödev atandı')));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: service.assignments.length,
                itemBuilder: (context, i) {
                  final a = service.assignments[i];
                  return Card(
                    child: ListTile(
                      title: Text(a.templateId),
                      subtitle: Text('Son tarih: ${a.dueDate?.toIso8601String() ?? '-'}'),
                      trailing: a.completed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.done),
                              onPressed: () => service.markCompleted(a.id),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
