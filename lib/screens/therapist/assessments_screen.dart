import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/assessment_scoring_service.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  final _phq9 = List<int>.filled(9, 0);
  final _gad7 = List<int>.filled(7, 0);

  Widget _buildScale(String title, int length, List<int> target) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(length, (i) {
                return DropdownButton<int>(
                  value: target[i],
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0')),
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                  ],
                  onChanged: (v) => setState(() => target[i] = v ?? 0),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scoring = context.watch<AssessmentScoringService>();
    final phqScore = scoring.scorePhq9(_phq9);
    final phqLevel = scoring.interpretPhq9(phqScore);
    final gadScore = scoring.scoreGad7(_gad7);
    final gadLevel = scoring.interpretGad7(gadScore);

    return Scaffold(
      appBar: AppBar(title: const Text('Ölçekler (PHQ‑9 / GAD‑7)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildScale('PHQ‑9', 9, _phq9),
            _buildScale('GAD‑7', 7, _gad7),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('PHQ‑9: $phqScore ($phqLevel)'),
                subtitle: Text('GAD‑7: $gadScore ($gadLevel)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
