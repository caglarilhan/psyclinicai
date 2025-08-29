import 'package:flutter/material.dart';
import '../../models/therapy_simulation_model.dart';
import '../../utils/theme.dart';

class SimulationScenarioPanel extends StatelessWidget {
  final List<SimulationScenario> scenarios;
  final Function(SimulationScenario) onScenarioSelected;
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.theater_comedy,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terapi Senaryoları',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerçekçi vakalar ile pratik yapın',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Senaryo listesi
          Expanded(
            child: ListView.builder(
              itemCount: scenarios.length,
              itemBuilder: (context, index) {
                final scenario = scenarios[index];
                return _buildScenarioCard(context, scenario);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, SimulationScenario scenario) {
    final difficultyColor = _getDifficultyColor(scenario.difficulty);
    final difficultyText = _getDifficultyText(scenario.difficulty);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: difficultyColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              difficultyText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              scenario.category,
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.psychology,
                  color: difficultyColor,
                  size: 32,
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Client Profile
                _buildClientProfile(scenario.clientProfile),
                
                const SizedBox(height: 16),
                
                // Therapeutic Approach
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.infoColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: AppTheme.infoColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terapötik Yaklaşım',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.infoColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              scenario.therapeuticApproach,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: scenario.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSessionActive ? null : () => onScenarioSelected(scenario),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      isSessionActive ? 'Seans Devam Ediyor' : 'Senaryoyu Başlat',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSessionActive ? Colors.grey : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientProfile(ClientProfile profile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  profile.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${profile.age} yaşında, ${profile.gender}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildProfileSection('Ana Problem', profile.presentingProblem),
          _buildProfileSection('Arka Plan', profile.background),
          _buildProfileSection('Belirtiler', profile.symptoms.join(', ')),
          _buildProfileSection('Hedefler', profile.goals),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ScenarioDifficulty difficulty) {
    switch (difficulty) {
      case ScenarioDifficulty.beginner:
        return Colors.green;
      case ScenarioDifficulty.intermediate:
        return Colors.orange;
      case ScenarioDifficulty.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyText(ScenarioDifficulty difficulty) {
    switch (difficulty) {
      case ScenarioDifficulty.beginner:
        return 'Başlangıç';
      case ScenarioDifficulty.intermediate:
        return 'Orta';
      case ScenarioDifficulty.advanced:
        return 'İleri';
    }
  }
}
