import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/therapy_note_service.dart';
import '../../services/treatment_plan_service.dart';
import '../../services/homework_service.dart';
import '../../services/assessment_scoring_service.dart';

class TherapistToolsDashboardWidget extends StatelessWidget {
  const TherapistToolsDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧰 Terapist Araçları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickTile(
                  icon: Icons.note_alt,
                  color: Colors.indigo,
                  title: 'Seans Notu',
                  subtitle: 'DAP / SOAP',
                  onTap: () {
                    final templates = context.read<TherapyNoteService>().templates;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Şablonlar: ${templates.map((t) => t.name).join(', ')}')),
                    );
                  },
                ),
                _QuickTile(
                  icon: Icons.flag,
                  color: Colors.teal,
                  title: 'Hedef/Plan',
                  subtitle: 'SMART',
                  onTap: () {
                    final plan = context.read<TreatmentPlanService>().getOrCreatePlan(
                          clientId: 'demo_client_001', clinicianId: 'demo_therapist_001');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hedef sayısı: ${plan.goals.length}')),
                    );
                  },
                ),
                _QuickTile(
                  icon: Icons.assignment,
                  color: Colors.orange,
                  title: 'Ev Ödevi',
                  subtitle: 'CBT kütüphanesi',
                  onTap: () {
                    final templates = context.read<HomeworkService>().templates;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ödevler: ${templates.map((t) => t.title).join(', ')}')),
                    );
                  },
                ),
                _QuickTile(
                  icon: Icons.analytics,
                  color: Colors.purple,
                  title: 'Ölçekler',
                  subtitle: 'PHQ-9 / GAD-7',
                  onTap: () {
                    final s = context.read<AssessmentScoringService>();
                    final phq = s.interpretPhq9(s.scorePhq9(List.filled(9, 1)));
                    final gad = s.interpretGad7(s.scoreGad7(List.filled(7, 2)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PHQ-9: $phq, GAD-7: $gad')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
