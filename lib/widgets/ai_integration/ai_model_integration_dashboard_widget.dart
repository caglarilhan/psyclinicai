import 'package:flutter/material.dart';
import 'package:psyclinicai/services/openai_gpt4_service.dart';
import 'package:psyclinicai/services/claude_integration_service.dart';

/// AI Model Integration Dashboard Widget for PsyClinicAI
/// Provides integration with GPT-4 and Claude for various AI tasks
class AIModelIntegrationDashboardWidget extends StatefulWidget {
  const AIModelIntegrationDashboardWidget({Key? key}) : super(key: key);

  @override
  State<AIModelIntegrationDashboardWidget> createState() => _AIModelIntegrationDashboardWidgetState();
}

class _AIModelIntegrationDashboardWidgetState extends State<AIModelIntegrationDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final OpenAIGPT4Service _gpt4Service = OpenAIGPT4Service();
  final ClaudeIntegrationService _claudeService = ClaudeIntegrationService();

  // Form controllers
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _claudeApiKeyController = TextEditingController();
  final TextEditingController _claudeOrgController = TextEditingController();

  // Input controllers for AI tasks
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _patientProfileController = TextEditingController();
  final TextEditingController _crisisDataController = TextEditingController();
  final TextEditingController _behaviorController = TextEditingController();
  final TextEditingController _therapyTypeController = TextEditingController();
  final TextEditingController _patientNeedsController = TextEditingController();
  final TextEditingController _wellnessGoalsController = TextEditingController();
  final TextEditingController _lifestyleController = TextEditingController();

  // Response data
  Map<String, dynamic>? _gpt4Response;
  Map<String, dynamic>? _claudeResponse;
  bool _isLoading = false;
  String _selectedModel = 'GPT-4';
  String _selectedTask = 'Diagnosis';

  // Stream subscriptions
  StreamSubscription<String>? _gpt4StreamSubscription;
  StreamSubscription<String>? _claudeStreamSubscription;
  String _streamedResponse = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize with mock keys for demo
    _apiKeyController.text = 'demo-gpt4-key';
    _claudeApiKeyController.text = 'demo-claude-key';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiKeyController.dispose();
    _organizationController.dispose();
    _claudeApiKeyController.dispose();
    _claudeOrgController.dispose();
    _symptomsController.dispose();
    _historyController.dispose();
    _diagnosisController.dispose();
    _patientProfileController.dispose();
    _crisisDataController.dispose();
    _behaviorController.dispose();
    _therapyTypeController.dispose();
    _patientNeedsController.dispose();
    _wellnessGoalsController.dispose();
    _lifestyleController.dispose();
    _gpt4StreamSubscription?.cancel();
    _claudeStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Model Integration Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Configuration'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Tasks'),
            Tab(icon: Icon(Icons.compare), text: 'Model Comparison'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConfigurationTab(),
          _buildAITasksTab(),
          _buildModelComparisonTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCard(
            'OpenAI GPT-4 Configuration',
            Icons.smart_toy,
            Colors.blue,
            [
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your OpenAI API key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _organizationController,
                decoration: const InputDecoration(
                  labelText: 'Organization ID (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your OpenAI organization ID',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initializeGPT4,
                icon: const Icon(Icons.check_circle),
                label: const Text('Initialize GPT-4'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Claude Configuration',
            Icons.psychology,
            Colors.green,
            [
              TextField(
                controller: _claudeApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your Anthropic API key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _claudeOrgController,
                decoration: const InputDecoration(
                  labelText: 'Organization ID (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your Anthropic organization ID',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initializeClaude,
                icon: const Icon(Icons.check_circle),
                label: const Text('Initialize Claude'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Service Status',
            Icons.info,
            Colors.orange,
            [
              _buildStatusIndicator('GPT-4 Service', _gpt4Service.getStatus()['status'] == 'initialized'),
              const SizedBox(height: 8),
              _buildStatusIndicator('Claude Service', _claudeService.getStatus()['status'] == 'initialized'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _testAllServices,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test All Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAITasksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCard(
            'AI Task Configuration',
            Icons.tune,
            Colors.purple,
            [
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: const InputDecoration(
                  labelText: 'Select AI Model',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'GPT-4', child: Text('OpenAI GPT-4')),
                  DropdownMenuItem(value: 'Claude', child: Text('Anthropic Claude')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTask,
                decoration: const InputDecoration(
                  labelText: 'Select Task Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Diagnosis', child: Text('Mental Health Diagnosis')),
                  DropdownMenuItem(value: 'Treatment', child: Text('Treatment Recommendations')),
                  DropdownMenuItem(value: 'Crisis', child: Text('Crisis Detection')),
                  DropdownMenuItem(value: 'Therapy', child: Text('Therapy Content')),
                  DropdownMenuItem(value: 'Wellness', child: Text('Wellness Plan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTask = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Task Input',
            Icons.input,
            Colors.teal,
            _buildTaskInputs(),
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'AI Response',
            Icons.chat_bubble,
            Colors.indigo,
            [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_gpt4Response != null || _claudeResponse != null)
                _buildResponseDisplay()
              else
                const Center(
                  child: Text(
                    'No response yet. Configure and run a task to see results.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _runAITask,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Run AI Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _runStreamingTask,
                      icon: const Icon(Icons.stream),
                      label: const Text('Stream Response'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelComparisonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCard(
            'Model Capabilities',
            Icons.compare_arrows,
            Colors.blueGrey,
            [
              _buildCapabilityComparison(),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Performance Metrics',
            Icons.speed,
            Colors.amber,
            [
              _buildPerformanceMetrics(),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Cost Analysis',
            Icons.attach_money,
            Colors.lightGreen,
            [
              _buildCostAnalysis(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCard(
            'Usage Statistics',
            Icons.bar_chart,
            Colors.cyan,
            [
              _buildUsageStatistics(),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Response Quality',
            Icons.star,
            Colors.yellow,
            [
              _buildQualityMetrics(),
            ],
          ),
          const SizedBox(height: 24),
          _buildServiceCard(
            'Error Analysis',
            Icons.bug_report,
            Colors.red,
            [
              _buildErrorAnalysis(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String serviceName, bool isActive) {
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.error,
          color: isActive ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          '$serviceName: ${isActive ? 'Active' : 'Inactive'}',
          style: TextStyle(
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTaskInputs() {
    switch (_selectedTask) {
      case 'Diagnosis':
        return [
          TextField(
            controller: _symptomsController,
            decoration: const InputDecoration(
              labelText: 'Patient Symptoms',
              border: OutlineInputBorder(),
              hintText: 'Describe the patient\'s symptoms...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _historyController,
            decoration: const InputDecoration(
              labelText: 'Patient History',
              border: OutlineInputBorder(),
              hintText: 'Enter relevant patient history...',
            ),
            maxLines: 3,
          ),
        ];
      case 'Treatment':
        return [
          TextField(
            controller: _diagnosisController,
            decoration: const InputDecoration(
              labelText: 'Diagnosis',
              border: OutlineInputBorder(),
              hintText: 'Enter the diagnosis...',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patientProfileController,
            decoration: const InputDecoration(
              labelText: 'Patient Profile',
              border: OutlineInputBorder(),
              hintText: 'Enter patient profile information...',
            ),
            maxLines: 3,
          ),
        ];
      case 'Crisis':
        return [
          TextField(
            controller: _crisisDataController,
            decoration: const InputDecoration(
              labelText: 'Patient Data',
              border: OutlineInputBorder(),
              hintText: 'Enter current patient data...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _behaviorController,
            decoration: const InputDecoration(
              labelText: 'Current Behavior',
              border: OutlineInputBorder(),
              hintText: 'Describe current behavior...',
            ),
            maxLines: 3,
          ),
        ];
      case 'Therapy':
        return [
          TextField(
            controller: _therapyTypeController,
            decoration: const InputDecoration(
              labelText: 'Therapy Type',
              border: OutlineInputBorder(),
              hintText: 'e.g., CBT, DBT, Psychodynamic...',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _patientNeedsController,
            decoration: const InputDecoration(
              labelText: 'Patient Needs',
              border: OutlineInputBorder(),
              hintText: 'Describe patient needs...',
            ),
            maxLines: 3,
          ),
        ];
      case 'Wellness':
        return [
          TextField(
            controller: _wellnessGoalsController,
            decoration: const InputDecoration(
              labelText: 'Wellness Goals',
              border: OutlineInputBorder(),
              hintText: 'Enter wellness goals...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lifestyleController,
            decoration: const InputDecoration(
              labelText: 'Current Lifestyle',
              border: OutlineInputBorder(),
              hintText: 'Describe current lifestyle...',
            ),
            maxLines: 3,
          ),
        ];
      default:
        return [
          const Text('Please select a task type'),
        ];
    }
  }

  Widget _buildResponseDisplay() {
    final response = _selectedModel == 'GPT-4' ? _gpt4Response : _claudeResponse;
    
    if (response == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedModel} Response:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            response.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityComparison() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Capability')),
        DataColumn(label: Text('GPT-4')),
        DataColumn(label: Text('Claude')),
      ],
      rows: const [
        DataRow(cells: [
          DataCell(Text('Mental Health Diagnosis')),
          DataCell(Icon(Icons.check, color: Colors.green)),
          DataCell(Icon(Icons.check, color: Colors.green)),
        ]),
        DataRow(cells: [
          DataCell(Text('Treatment Planning')),
          DataCell(Icon(Icons.check, color: Colors.green)),
          DataCell(Icon(Icons.check, color: Colors.green)),
        ]),
        DataRow(cells: [
          DataCell(Text('Crisis Detection')),
          DataCell(Icon(Icons.check, color: Colors.green)),
          DataCell(Icon(Icons.check, color: Colors.green)),
        ]),
        DataRow(cells: [
          DataCell(Text('Streaming Responses')),
          DataCell(Icon(Icons.check, color: Colors.green)),
          DataCell(Icon(Icons.check, color: Colors.green)),
        ]),
        DataRow(cells: [
          DataCell(Text('Context Length')),
          DataCell(Text('128K tokens')),
          DataCell(Text('200K tokens')),
        ]),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      children: [
        _buildMetricRow('Response Time', 'GPT-4', '2-5 seconds', 'Claude', '3-6 seconds'),
        _buildMetricRow('Accuracy', 'GPT-4', '95%', 'Claude', '93%'),
        _buildMetricRow('Reliability', 'GPT-4', '99.9%', 'Claude', '99.8%'),
        _buildMetricRow('Scalability', 'GPT-4', 'High', 'Claude', 'High'),
      ],
    );
  }

  Widget _buildCostAnalysis() {
    return Column(
      children: [
        _buildMetricRow('Input Cost', 'GPT-4', '\$0.03/1K tokens', 'Claude', '\$0.015/1K tokens'),
        _buildMetricRow('Output Cost', 'GPT-4', '\$0.06/1K tokens', 'Claude', '\$0.075/1K tokens'),
        _buildMetricRow('Monthly Estimate', 'GPT-4', '\$500-1000', 'Claude', '\$400-800'),
      ],
    );
  }

  Widget _buildUsageStatistics() {
    return Column(
      children: [
        _buildStatCard('Total Requests', '1,247', Icons.request_page),
        const SizedBox(height: 16),
        _buildStatCard('Success Rate', '98.5%', Icons.check_circle),
        const SizedBox(height: 16),
        _buildStatCard('Average Response Time', '3.2s', Icons.speed),
        const SizedBox(height: 16),
        _buildStatCard('Monthly Cost', '\$750', Icons.attach_money),
      ],
    );
  }

  Widget _buildQualityMetrics() {
    return Column(
      children: [
        _buildQualityIndicator('Diagnosis Accuracy', 0.95),
        const SizedBox(height: 16),
        _buildQualityIndicator('Treatment Relevance', 0.92),
        const SizedBox(height: 16),
        _buildQualityIndicator('Crisis Detection', 0.98),
        const SizedBox(height: 16),
        _buildQualityIndicator('User Satisfaction', 0.89),
      ],
    );
  }

  Widget _buildErrorAnalysis() {
    return Column(
      children: [
        _buildErrorCard('API Timeouts', '12', '0.96%', Colors.orange),
        const SizedBox(height: 16),
        _buildErrorCard('Rate Limits', '8', '0.64%', Colors.yellow),
        const SizedBox(height: 16),
        _buildErrorCard('Invalid Responses', '5', '0.40%', Colors.red),
        const SizedBox(height: 16),
        _buildErrorCard('Network Errors', '3', '0.24%', Colors.red),
      ],
    );
  }

  Widget _buildMetricRow(String metric, String model1, String value1, String model2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(metric, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text(model1, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: Text(value1)),
          Expanded(flex: 1, child: Text(model2, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: Text(value2)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityIndicator(String metric, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metric, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            score >= 0.9 ? Colors.green : score >= 0.8 ? Colors.orange : Colors.red,
          ),
        ),
        const SizedBox(height: 4),
        Text('${(score * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildErrorCard(String error, String count, String percentage, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(error, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('$count occurrences ($percentage of total)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Service initialization methods
  Future<void> _initializeGPT4() async {
    try {
      await _gpt4Service.initialize(
        apiKey: _apiKeyController.text,
        organizationId: _organizationController.text.isNotEmpty ? _organizationController.text : null,
      );
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPT-4 service initialized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize GPT-4: $e')),
      );
    }
  }

  Future<void> _initializeClaude() async {
    try {
      await _claudeService.initialize(
        apiKey: _claudeApiKeyController.text,
        organizationId: _claudeOrgController.text.isNotEmpty ? _claudeOrgController.text : null,
      );
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claude service initialized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize Claude: $e')),
      );
    }
  }

  Future<void> _testAllServices() async {
    try {
      final gpt4Status = _gpt4Service.getStatus();
      final claudeStatus = _claudeService.getStatus();
      
      String message = 'Service Status:\n';
      message += 'GPT-4: ${gpt4Status['status']}\n';
      message += 'Claude: ${claudeStatus['status']}';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error testing services: $e')),
      );
    }
  }

  // AI task execution methods
  Future<void> _runAITask() async {
    if (_selectedModel == 'GPT-4') {
      await _runGPT4Task();
    } else {
      await _runClaudeTask();
    }
  }

  Future<void> _runGPT4Task() async {
    setState(() {
      _isLoading = true;
      _gpt4Response = null;
    });

    try {
      switch (_selectedTask) {
        case 'Diagnosis':
          final response = await _gpt4Service.generateDiagnosis(
            patientSymptoms: _symptomsController.text,
            patientHistory: _historyController.text,
          );
          setState(() {
            _gpt4Response = response.toJson();
          });
          break;
        case 'Treatment':
          final response = await _gpt4Service.generateTreatmentRecommendations(
            diagnosis: _diagnosisController.text,
            patientProfile: _patientProfileController.text,
          );
          setState(() {
            _gpt4Response = response.toJson();
          });
          break;
        case 'Crisis':
          final response = await _gpt4Service.detectCrisis(
            patientData: _crisisDataController.text,
            currentBehavior: _behaviorController.text,
          );
          setState(() {
            _gpt4Response = response.toJson();
          });
          break;
        case 'Therapy':
          final response = await _gpt4Service.generateTherapyContent(
            therapyType: _therapyTypeController.text,
            patientNeeds: _patientNeedsController.text,
          );
          setState(() {
            _gpt4Response = response.toJson();
          });
          break;
        case 'Wellness':
          final response = await _gpt4Service.generateWellnessPlan(
            patientGoals: _wellnessGoalsController.text,
            currentLifestyle: _lifestyleController.text,
          );
          setState(() {
            _gpt4Response = response.toJson();
          });
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPT-4 task failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runClaudeTask() async {
    setState(() {
      _isLoading = true;
      _claudeResponse = null;
    });

    try {
      switch (_selectedTask) {
        case 'Diagnosis':
          final response = await _claudeService.generateDiagnosis(
            patientSymptoms: _symptomsController.text,
            patientHistory: _historyController.text,
          );
          setState(() {
            _claudeResponse = response.toJson();
          });
          break;
        case 'Treatment':
          final response = await _claudeService.generateTreatmentRecommendations(
            diagnosis: _diagnosisController.text,
            patientProfile: _patientProfileController.text,
          );
          setState(() {
            _claudeResponse = response.toJson();
          });
          break;
        case 'Crisis':
          final response = await _claudeService.detectCrisis(
            patientData: _crisisDataController.text,
            currentBehavior: _behaviorController.text,
          );
          setState(() {
            _claudeResponse = response.toJson();
          });
          break;
        case 'Therapy':
          final response = await _claudeService.generateTherapyContent(
            therapyType: _therapyTypeController.text,
            patientNeeds: _patientNeedsController.text,
          );
          setState(() {
            _claudeResponse = response.toJson();
          });
          break;
        case 'Wellness':
          final response = await _claudeService.generateWellnessPlan(
            patientGoals: _wellnessGoalsController.text,
            currentLifestyle: _lifestyleController.text,
          );
          setState(() {
            _claudeResponse = response.toJson();
          });
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claude task failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runStreamingTask() async {
    setState(() {
      _isLoading = true;
      _streamedResponse = '';
    });

    try {
      final prompt = _buildStreamingPrompt();
      
      if (_selectedModel == 'GPT-4') {
        await _gpt4Service.streamResponse(
          prompt: prompt,
          onChunk: (chunk) {
            setState(() {
              _streamedResponse += chunk;
            });
          },
        );
      } else {
        await _claudeService.streamResponse(
          prompt: prompt,
          onChunk: (chunk) {
            setState(() {
              _streamedResponse += chunk;
            });
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Streaming failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildStreamingPrompt() {
    switch (_selectedTask) {
      case 'Diagnosis':
        return 'Analyze the following symptoms: ${_symptomsController.text}\n\nPatient history: ${_historyController.text}\n\nProvide a comprehensive mental health assessment.';
      case 'Treatment':
        return 'Based on diagnosis: ${_diagnosisController.text}\n\nPatient profile: ${_patientProfileController.text}\n\nDevelop a comprehensive treatment plan.';
      case 'Crisis':
        return 'Assess crisis level for:\nPatient data: ${_crisisDataController.text}\nCurrent behavior: ${_behaviorController.text}\n\nProvide immediate recommendations.';
      case 'Therapy':
        return 'Create therapy content for:\nTherapy type: ${_therapyTypeController.text}\nPatient needs: ${_patientNeedsController.text}\n\nDevelop session structure and techniques.';
      case 'Wellness':
        return 'Design wellness plan for:\nGoals: ${_wellnessGoalsController.text}\nLifestyle: ${_lifestyleController.text}\n\nCreate comprehensive wellness strategies.';
      default:
        return 'Please provide a detailed analysis of the given information.';
    }
  }
}
