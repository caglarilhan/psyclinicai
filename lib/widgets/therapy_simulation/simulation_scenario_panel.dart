import 'package:flutter/material.dart';
import '../../models/therapy_simulation_model.dart';

class SimulationScenarioPanel extends StatelessWidget {
  final List<SimulationScenario> scenarios;
  final void Function(SimulationScenario) onScenarioSelected;
  final bool isSessionActive;

  const SimulationScenarioPanel({
    super.key,
    required this.scenarios,
    required this.onScenarioSelected,
    required this.isSessionActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: scenarios.length,
        itemBuilder: (context, index) {
          final scenario = scenarios[index];
          return _buildScenarioCard(context, scenario);
        },
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, SimulationScenario scenario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.theater_comedy,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scenario.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _difficultyColor(scenario.difficulty).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scenario.difficulty.name.toUpperCase(),
                    style: TextStyle(
                      color: _difficultyColor(scenario.difficulty),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scenario.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person,
                    size: 16, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                    '${scenario.clientProfile.name}, ${scenario.clientProfile.age} • ${scenario.category}'),
                const Spacer(),
                Icon(Icons.access_time,
                    size: 16, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text('${scenario.estimatedDuration} dk'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isSessionActive ? null : () => onScenarioSelected(scenario),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Simülasyonu Başlat'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(ScenarioDifficulty difficulty) {
    switch (difficulty) {
      case ScenarioDifficulty.beginner:
        return Colors.green;
      case ScenarioDifficulty.intermediate:
        return Colors.orange;
      case ScenarioDifficulty.advanced:
        return Colors.red;
    }
  }
}
