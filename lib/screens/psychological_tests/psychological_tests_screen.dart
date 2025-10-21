import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/psychiatric_assessment_models.dart';
import '../../services/psychiatric_assessment_service.dart';
import '../../services/patient_service.dart';

class PsychologicalTestsScreen extends StatefulWidget {
  const PsychologicalTestsScreen({super.key});

  @override
  State<PsychologicalTestsScreen> createState() => _PsychologicalTestsScreenState();
}

class _PsychologicalTestsScreenState extends State<PsychologicalTestsScreen> {
  final PsychiatricAssessmentService _assessmentService = PsychiatricAssessmentService();
  String? _selectedPatientId;
  String _selectedCategory = 'Tümü';
  String _selectedTestId;

  final List<String> _categories = [
    'Tümü',
    'personality',
    'cognitive',
    'mood',
    'anxiety',
    'trauma',
    'substance',
    'developmental',
    'neuropsychological',
  ];

  @override
  void initState() {
    super.initState();
    _assessmentService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Psikolojik Testler'),
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
            
            // Kategori Filtresi
            Card(
              color: Colors.purple[700],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Kategorisi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Testler Listesi
            if (_selectedPatientId != null) ...[
              _buildTestsList(),
              const SizedBox(height: 16),
              _buildTestResults(),
            ] else ...[
              Card(
                color: Colors.purple[600],
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Psikolojik testleri görüntülemek için hasta seçin',
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

  Widget _buildTestsList() {
    final theme = Theme.of(context);
    final tests = _getFilteredTests();

    return Card(
      color: Colors.purple[600],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mevcut Testler',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (tests.isEmpty)
              const Text(
                'Bu kategoride test bulunamadı',
                style: TextStyle(color: Colors.white70),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return _buildTestCard(test);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(PsychologicalTest test) {
    final theme = Theme.of(context);
    final patient = context.read<PatientService>().patients
        .firstWhere((p) => p.id == _selectedPatientId);
    final age = DateTime.now().year - patient.birthDate.year;
    final isAgeAppropriate = age >= test.ageRangeMin && age <= test.ageRangeMax;

    return Card(
      color: Colors.purple[500],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(test.category),
          child: Icon(
            _getCategoryIcon(test.category),
            color: Colors.white,
          ),
        ),
        title: Text(
          test.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              test.description,
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
                  '${test.estimatedDuration.inMinutes} dk',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  '${test.ageRangeMin}-${test.ageRangeMax} yaş',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (!isAgeAppropriate) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAgeAppropriate)
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 20,
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isAgeAppropriate ? () => _administerTest(test) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple[800],
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    final theme = Theme.of(context);
    final results = _assessmentService.getTestResultsForPatient(_selectedPatientId!);

    return Card(
      color: Colors.purple[500],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Sonuçları',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (results.isEmpty)
              const Text(
                'Bu hasta için test sonucu bulunamadı',
                style: TextStyle(color: Colors.white70),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return _buildResultCard(result);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(TestResult result) {
    final test = _assessmentService.getAllTests()
        .firstWhere((t) => t.id == result.testId);

    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getValidityIcon(result.validity),
          color: _getValidityColor(result.validity),
        ),
        title: Text(
          test.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulanma: ${_formatDate(result.administeredAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              result.interpretation,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.white),
          onPressed: () => _showTestResult(result),
        ),
      ),
    );
  }

  List<PsychologicalTest> _getFilteredTests() {
    var tests = _assessmentService.getAllTests();

    if (_selectedCategory != 'Tümü') {
      tests = tests.where((test) => test.category.name == _selectedCategory).toList();
    }

    return tests;
  }

  Color _getCategoryColor(TestCategory category) {
    switch (category) {
      case TestCategory.personality:
        return Colors.blue;
      case TestCategory.cognitive:
        return Colors.green;
      case TestCategory.mood:
        return Colors.red;
      case TestCategory.anxiety:
        return Colors.orange;
      case TestCategory.trauma:
        return Colors.purple;
      case TestCategory.substance:
        return Colors.brown;
      case TestCategory.developmental:
        return Colors.teal;
      case TestCategory.neuropsychological:
        return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(TestCategory category) {
    switch (category) {
      case TestCategory.personality:
        return Icons.person;
      case TestCategory.cognitive:
        return Icons.psychology;
      case TestCategory.mood:
        return Icons.mood;
      case TestCategory.anxiety:
        return Icons.anxiety;
      case TestCategory.trauma:
        return Icons.healing;
      case TestCategory.substance:
        return Icons.local_pharmacy;
      case TestCategory.developmental:
        return Icons.child_care;
      case TestCategory.neuropsychological:
        return Icons.memory;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'Tümü':
        return 'Tümü';
      case 'personality':
        return 'Kişilik';
      case 'cognitive':
        return 'Bilişsel';
      case 'mood':
        return 'Duygudurum';
      case 'anxiety':
        return 'Anksiyete';
      case 'trauma':
        return 'Travma';
      case 'substance':
        return 'Madde Kullanımı';
      case 'developmental':
        return 'Gelişimsel';
      case 'neuropsychological':
        return 'Nöropsikolojik';
      default:
        return category;
    }
  }

  IconData _getValidityIcon(TestValidity validity) {
    switch (validity) {
      case TestValidity.valid:
        return Icons.check_circle;
      case TestValidity.questionable:
        return Icons.warning;
      case TestValidity.invalid:
        return Icons.error;
      case TestValidity.incomplete:
        return Icons.incomplete_circle;
    }
  }

  Color _getValidityColor(TestValidity validity) {
    switch (validity) {
      case TestValidity.valid:
        return Colors.green;
      case TestValidity.questionable:
        return Colors.orange;
      case TestValidity.invalid:
        return Colors.red;
      case TestValidity.incomplete:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _administerTest(PsychologicalTest test) async {
    // Test uygulama ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestAdministrationScreen(
          test: test,
          patientId: _selectedPatientId!,
        ),
      ),
    );
  }

  void _showTestResult(TestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Sonucu'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sonuç: ${result.interpretation}'),
              const SizedBox(height: 8),
              if (result.recommendations != null) ...[
                Text('Öneriler: ${result.recommendations}'),
                const SizedBox(height: 8),
              ],
              Text('Geçerlilik: ${_getValidityDisplayName(result.validity)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _getValidityDisplayName(TestValidity validity) {
    switch (validity) {
      case TestValidity.valid:
        return 'Geçerli';
      case TestValidity.questionable:
        return 'Şüpheli';
      case TestValidity.invalid:
        return 'Geçersiz';
      case TestValidity.incomplete:
        return 'Eksik';
    }
  }
}

class TestAdministrationScreen extends StatefulWidget {
  final PsychologicalTest test;
  final String patientId;

  const TestAdministrationScreen({
    super.key,
    required this.test,
    required this.patientId,
  });

  @override
  State<TestAdministrationScreen> createState() => _TestAdministrationScreenState();
}

class _TestAdministrationScreenState extends State<TestAdministrationScreen> {
  final Map<String, dynamic> _responses = {};
  int _currentQuestionIndex = 0;
  final PsychiatricAssessmentService _assessmentService = PsychiatricAssessmentService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.test.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == widget.test.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.test.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Soru ${_currentQuestionIndex + 1}/${widget.test.questions.length}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.questionText,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Answer options
                    if (question.type == QuestionType.multipleChoice) ...[
                      ...question.options!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isSelected = _responses[question.id] == index;
                        
                        return Card(
                          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
                          child: ListTile(
                            title: Text(option),
                            leading: Radio<int>(
                              value: index,
                              groupValue: _responses[question.id],
                              onChanged: (value) {
                                setState(() {
                                  _responses[question.id] = value;
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                _responses[question.id] = index;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                  child: const Text('Önceki'),
                ),
                ElevatedButton(
                  onPressed: _responses[question.id] != null ? _nextQuestion : null,
                  child: Text(isLastQuestion ? 'Tamamla' : 'Sonraki'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _previousQuestion() {
    setState(() {
      _currentQuestionIndex--;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.test.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeTest();
    }
  }

  Future<void> _completeTest() async {
    try {
      await _assessmentService.administerTest(
        testId: widget.test.id,
        patientId: widget.patientId,
        administeredBy: 'current_therapist', // In real app, get from auth
        responses: _responses,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.test.name} testi tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
