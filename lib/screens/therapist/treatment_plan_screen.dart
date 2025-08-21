import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/treatment_plan_service.dart';
import '../../models/treatment_plan_models.dart';

class TreatmentPlanScreen extends StatelessWidget {
  const TreatmentPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TreatmentPlanService>();
    final plan = service.getOrCreatePlan(
      clientId: 'demo_client_001',
      clinicianId: 'demo_therapist_001',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tedavi Planı / SMART Hedefler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final goal = SmartGoal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Yeni Hedef',
                        description: 'Kısa açıklama',
                        createdAt: DateTime.now(),
                        targetDate: DateTime.now().add(const Duration(days: 30)),
                        status: GoalStatus.active,
                        tasks: [
                          TreatmentTask(id: 't1', title: 'İlk görev'),
                        ],
                      );
                      service.addGoal(plan.clientId, goal);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Hedef Ekle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: plan.goals.length,
                itemBuilder: (context, i) {
                  final g = plan.goals[i];
                  return Card(
                    child: ExpansionTile(
                      title: Text(g.title),
                      subtitle: Text(g.description),
                      children: [
                        ListTile(
                          title: Text('Durum: ${g.status.name}'),
                          subtitle: Text('Hedef Tarih: ${g.targetDate?.toIso8601String() ?? '-'}'),
                        ),
                        ...g.tasks.map((t) => CheckboxListTile(
                              value: t.done,
                              title: Text(t.title),
                              subtitle: t.notes != null ? Text(t.notes!) : null,
                              onChanged: (v) => service.toggleTask(plan.clientId, g.id, t.id, v ?? false),
                            )),
                      ],
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
