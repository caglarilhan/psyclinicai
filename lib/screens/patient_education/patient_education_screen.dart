import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient_education_models.dart';
import '../../services/patient_education_service.dart';
import '../../services/patient_service.dart';

class PatientEducationScreen extends StatefulWidget {
  const PatientEducationScreen({super.key});

  @override
  State<PatientEducationScreen> createState() => _PatientEducationScreenState();
}

class _PatientEducationScreenState extends State<PatientEducationScreen> {
  final PatientEducationService _educationService = PatientEducationService();
  String? _selectedPatientId;
  String _selectedCategory = 'Tümü';
  String _selectedDifficulty = 'Tümü';

  final List<String> _categories = [
    'Tümü',
    'diabetes',
    'hypertension',
    'mentalHealth',
    'medication',
    'nutrition',
    'exercise',
    'generalHealth',
  ];

  final List<String> _difficulties = [
    'Tümü',
    'Kolay',
    'Orta',
    'Zor',
  ];

  @override
  void initState() {
    super.initState();
    _educationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Eğitimi'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hasta Seçimi
            Card(
              color: Colors.purple[800],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasta Seçimi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<PatientService>(
                      builder: (context, patientService, child) {
                        return DropdownButtonFormField<String>(
                          value: _selectedPatientId,
                          decoration: InputDecoration(
                            labelText: 'Hasta',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          dropdownColor: Colors.purple[700],
                          items: patientService.patients.map((patient) {
                            return DropdownMenuItem(
                              value: patient.id,
                              child: Text(
                                patient.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPatientId = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filtreler
            Card(
              color: Colors.purple[700],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtreler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Kategori',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: Colors.purple[600],
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  _getCategoryDisplayName(category),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: InputDecoration(
                              labelText: 'Zorluk',
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: Colors.purple[600],
                            items: _difficulties.map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(
                                  difficulty,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Eğitim Modülleri
            if (_selectedPatientId != null) ...[
              _buildEducationModules(),
              const SizedBox(height: 16),
              _buildPatientProgress(),
              const SizedBox(height: 16),
              _buildRecommendations(),
            ] else ...[
              Card(
                color: Colors.purple[600],
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.school,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Eğitim modüllerini görüntülemek için hasta seçin',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationModules() {
    final theme = Theme.of(context);
    final modules = _getFilteredModules();

    return Card(
      color: Colors.purple[600],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eğitim Modülleri',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (modules.isEmpty)
              const Text(
                'Bu kriterlere uygun modül bulunamadı',
                style: TextStyle(color: Colors.white70),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return _buildModuleCard(module);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(PatientEducationModule module) {
    final theme = Theme.of(context);
    final progress = _educationService.getProgressForModule(_selectedPatientId!, module.id);

    return Card(
      color: Colors.purple[500],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(module.difficulty),
          child: Icon(
            _getCategoryIcon(module.category),
            color: Colors.white,
          ),
        ),
        title: Text(
          module.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.description,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  '${module.estimatedDuration} dk',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.star,
                  size: 16,
                  color: _getDifficultyColor(module.difficulty),
                ),
                const SizedBox(width: 4),
                Text(
                  module.difficulty,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.progressPercentage / 100,
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.status == EducationStatus.completed 
                      ? Colors.green 
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'İlerleme: ${progress.progressPercentage}%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            progress != null ? Icons.play_arrow : Icons.play_circle_outline,
            color: Colors.white,
          ),
          onPressed: () => _startModule(module),
        ),
      ),
    );
  }

  Widget _buildPatientProgress() {
    final theme = Theme.of(context);
    final progressRecords = _educationService.getProgressForPatient(_selectedPatientId!);
    final statistics = _educationService.getEducationStatistics(_selectedPatientId!);

    return Card(
      color: Colors.purple[500],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eğitim İlerlemesi',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Toplam Modül',
                    '${statistics['totalModules']}',
                    Icons.library_books,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Tamamlanan',
                    '${statistics['completedModules']}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Devam Eden',
                    '${statistics['inProgressModules']}',
                    Icons.play_circle,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ortalama İlerleme: ${statistics['averageProgress'].toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Toplam Çalışma Süresi: ${statistics['totalStudyTime']} dakika',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final theme = Theme.of(context);
    final recommendations = _educationService.getRecommendationsForPatient(_selectedPatientId!);

    return Card(
      color: Colors.purple[400],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Önerilen Modüller',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recommendations.isEmpty)
              const Text(
                'Henüz önerilen modül yok',
                style: TextStyle(color: Colors.white70),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
                  return _buildRecommendationCard(recommendation);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(EducationRecommendation recommendation) {
    final module = _educationService.getAllModules()
        .firstWhere((m) => m.id == recommendation.moduleId);

    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.recommend,
          color: Colors.white,
        ),
        title: Text(
          module.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          recommendation.reason,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: Icon(
            recommendation.isViewed ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () => _viewRecommendation(recommendation),
        ),
      ),
    );
  }

  List<PatientEducationModule> _getFilteredModules() {
    var modules = _educationService.getAllModules();

    if (_selectedCategory != 'Tümü') {
      modules = modules.where((module) => module.category == _selectedCategory).toList();
    }

    if (_selectedDifficulty != 'Tümü') {
      modules = modules.where((module) => module.difficulty == _selectedDifficulty).toList();
    }

    return modules;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Kolay':
        return Colors.green;
      case 'Orta':
        return Colors.orange;
      case 'Zor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'diabetes':
        return Icons.bloodtype;
      case 'hypertension':
        return Icons.monitor_heart;
      case 'mentalHealth':
        return Icons.psychology;
      case 'medication':
        return Icons.medication;
      case 'nutrition':
        return Icons.restaurant;
      case 'exercise':
        return Icons.fitness_center;
      default:
        return Icons.health_and_safety;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'Tümü':
        return 'Tümü';
      case 'diabetes':
        return 'Diyabet';
      case 'hypertension':
        return 'Hipertansiyon';
      case 'mentalHealth':
        return 'Ruh Sağlığı';
      case 'medication':
        return 'İlaç';
      case 'nutrition':
        return 'Beslenme';
      case 'exercise':
        return 'Egzersiz';
      case 'generalHealth':
        return 'Genel Sağlık';
      default:
        return category;
    }
  }

  Future<void> _startModule(PatientEducationModule module) async {
    try {
      await _educationService.startModule(
        patientId: _selectedPatientId!,
        moduleId: module.id,
      );

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${module.title} modülü başlatıldı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewRecommendation(EducationRecommendation recommendation) async {
    try {
      await _educationService.markRecommendationAsViewed(recommendation.id);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}