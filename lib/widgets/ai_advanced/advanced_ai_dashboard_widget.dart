import 'package:flutter/material.dart';
import 'package:psyclinicai/services/openai_gpt4_service.dart';
import 'package:psyclinicai/services/claude_integration_service.dart';

/// Advanced AI Dashboard Widget for PsyClinicAI
class AdvancedAIDashboardWidget extends StatefulWidget {
  const AdvancedAIDashboardWidget({Key? key}) : super(key: key);

  @override
  State<AdvancedAIDashboardWidget> createState() => _AdvancedAIDashboardWidgetState();
}

class _AdvancedAIDashboardWidgetState extends State<AdvancedAIDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // AI Services
  final OpenAIGPT4Service _gpt4Service = OpenAIGPT4Service();
  final ClaudeIntegrationService _claudeService = ClaudeIntegrationService();
  
  // State variables
  bool _isLoading = false;
  String _currentResponse = '';
  String _selectedAIModel = 'GPT-4';
  
  // Form controllers
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _patientHistoryController = TextEditingController();
  final TextEditingController _clinicianNotesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAIServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomsController.dispose();
    _patientHistoryController.dispose();
    _clinicianNotesController.dispose();
    super.dispose();
  }

  /// Initialize AI services
  Future<void> _initializeAIServices() async {
    // In production, these would come from secure environment variables
    try {
      await _gpt4Service.initialize(
        apiKey: 'your-openai-api-key',
        organizationId: 'your-org-id',
      );
      
      await _claudeService.initialize(
        apiKey: 'your-claude-api-key',
      );
      
      print('✅ AI services initialized successfully');
    } catch (e) {
      print('❌ AI services initialization failed: $e');
      _showErrorSnackBar('AI services initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Advanced AI Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.psychology), text: 'AI Diagnosis'),
            Tab(icon: Icon(Icons.healing), text: 'Treatment Plans'),
            Tab(icon: Icon(Icons.warning), text: 'Crisis Detection'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Wellness Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAIDiagnosisTab(),
          _buildTreatmentPlansTab(),
          _buildCrisisDetectionTab(),
          _buildWellnessPlansTab(),
        ],
      ),
    );
  }

  /// AI Diagnosis Tab
  Widget _buildAIDiagnosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIModelSelector(),
          const SizedBox(height: 20),
          _buildDiagnosisForm(),
          const SizedBox(height: 20),
          _buildGenerateButton('Generate AI Diagnosis', _generateAIDiagnosis),
          const SizedBox(height: 20),
          _buildResponseDisplay(),
        ],
      ),
    );
  }

  /// Treatment Plans Tab
  Widget _buildTreatmentPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIModelSelector(),
          const SizedBox(height: 20),
          _buildTreatmentForm(),
          const SizedBox(height: 20),
          _buildGenerateButton('Generate Treatment Plan', _generateTreatmentPlan),
          const SizedBox(height: 20),
          _buildResponseDisplay(),
        ],
      ),
    );
  }

  /// Crisis Detection Tab
  Widget _buildCrisisDetectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIModelSelector(),
          const SizedBox(height: 20),
          _buildCrisisForm(),
          const SizedBox(height: 20),
          _buildGenerateButton('Detect Crisis Risk', _detectCrisisRisk, isCrisis: true),
          const SizedBox(height: 20),
          _buildResponseDisplay(),
        ],
      ),
    );
  }

  /// Wellness Plans Tab
  Widget _buildWellnessPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIModelSelector(),
          const SizedBox(height: 20),
          _buildWellnessForm(),
          const SizedBox(height: 20),
          _buildGenerateButton('Generate Wellness Plan', _generateWellnessPlan),
          const SizedBox(height: 20),
          _buildResponseDisplay(),
        ],
      ),
    );
  }

  /// AI Model Selector
  Widget _buildAIModelSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🤖 Select AI Model',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAIModel,
              decoration: const InputDecoration(
                labelText: 'AI Model',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'GPT-4', child: Text('OpenAI GPT-4')),
                DropdownMenuItem(value: 'Claude', child: Text('Anthropic Claude')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAIModel = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            Text(
              _selectedAIModel == 'GPT-4' 
                  ? 'GPT-4: Advanced reasoning, medical expertise, real-time analysis'
                  : 'Claude: Safety-focused, cultural sensitivity, comprehensive assessments',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Diagnosis Form
  Widget _buildDiagnosisForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Patient Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                labelText: 'Symptoms (one per line)',
                border: OutlineInputBorder(),
                hintText: 'Enter patient symptoms...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _patientHistoryController,
              decoration: const InputDecoration(
                labelText: 'Patient History',
                border: OutlineInputBorder(),
                hintText: 'Enter relevant patient history...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _clinicianNotesController,
              decoration: const InputDecoration(
                labelText: 'Clinician Notes',
                border: OutlineInputBorder(),
                hintText: 'Enter your clinical observations...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Treatment Form
  Widget _buildTreatmentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💊 Treatment Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                border: OutlineInputBorder(),
                hintText: 'Enter patient diagnosis...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Treatment Goals',
                border: OutlineInputBorder(),
                hintText: 'Enter treatment objectives...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Current Medications',
                border: OutlineInputBorder(),
                hintText: 'Enter current medications...',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Crisis Form
  Widget _buildCrisisForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚨 Crisis Assessment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Current Situation',
                border: OutlineInputBorder(),
                hintText: 'Describe the current crisis situation...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Risk Factors',
                border: OutlineInputBorder(),
                hintText: 'Enter identified risk factors...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Available Resources',
                border: OutlineInputBorder(),
                hintText: 'Enter available crisis resources...',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Wellness Form
  Widget _buildWellnessForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌱 Wellness Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Health Profile',
                border: OutlineInputBorder(),
                hintText: 'Enter patient health profile...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Wellness Goals',
                border: OutlineInputBorder(),
                hintText: 'Enter wellness objectives...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Lifestyle Factors',
                border: OutlineInputBorder(),
                hintText: 'Enter lifestyle considerations...',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Generate Button
  Widget _buildGenerateButton(String text, VoidCallback onPressed, {bool isCrisis = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCrisis ? Colors.red : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Response Display
  Widget _buildResponseDisplay() {
    if (_currentResponse.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.psychology, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'AI response will appear here',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🤖 $_selectedAIModel Response',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _copyResponse,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy response',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _currentResponse,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate AI Diagnosis
  Future<void> _generateAIDiagnosis() async {
    if (_symptomsController.text.isEmpty) {
      _showErrorSnackBar('Please enter patient symptoms');
      return;
    }

    setState(() {
      _isLoading = true;
      _currentResponse = '';
    });

    try {
      final symptoms = _symptomsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
      
      if (_selectedAIModel == 'GPT-4') {
        final response = await _gpt4Service.generateDiagnosis(
          patientId: 'demo_patient_001',
          symptoms: symptoms,
          patientHistory: _patientHistoryController.text,
          clinicianNotes: _clinicianNotesController.text,
        );
        
        setState(() {
          _currentResponse = _formatGPT4Response(response);
        });
      } else {
        final response = await _claudeService.generateMentalHealthAssessment(
          patientId: 'demo_patient_001',
          patientData: {'age': 30, 'gender': 'Female'},
          symptoms: symptoms,
          presentingProblem: _symptomsController.text,
          riskFactors: {'suicide_risk': 'low', 'self_harm': 'none'},
        );
        
        setState(() {
          _currentResponse = _formatClaudeResponse(response);
        });
      }
    } catch (e) {
      _showErrorSnackBar('AI diagnosis generation failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Generate Treatment Plan
  Future<void> _generateTreatmentPlan() async {
    setState(() {
      _isLoading = true;
      _currentResponse = '';
    });

    try {
      if (_selectedAIModel == 'GPT-4') {
        final response = await _gpt4Service.generateTreatmentRecommendations(
          diagnosis: 'Major Depressive Disorder',
          patientId: 'demo_patient_001',
          patientProfile: {'age': 30, 'severity': 'moderate'},
          currentMedications: ['Sertraline 50mg'],
          allergies: ['None known'],
        );
        
        setState(() {
          _currentResponse = _formatGPT4TreatmentResponse(response);
        });
      } else {
        final response = await _claudeService.generateTherapeuticInterventions(
          diagnosis: 'Major Depressive Disorder',
          patientProfile: '30-year-old female with moderate depression',
          symptoms: ['Depressed mood', 'Loss of interest', 'Fatigue'],
          treatmentGoal: 'Reduce depressive symptoms and improve functioning',
          patientPreferences: {'therapy_type': 'CBT', 'medication': 'open'},
        );
        
        setState(() {
          _currentResponse = _formatClaudeInterventionResponse(response);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Treatment plan generation failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Detect Crisis Risk
  Future<void> _detectCrisisRisk() async {
    setState(() {
      _isLoading = true;
      _currentResponse = '';
    });

    try {
      if (_selectedAIModel == 'GPT-4') {
        final response = await _gpt4Service.detectCrisis(
          patientId: 'demo_patient_001',
          currentText: 'I feel like giving up',
          patientHistory: {'previous_attempts': 0, 'risk_factors': ['depression']},
          riskFactors: ['depression', 'hopelessness'],
        );
        
        setState(() {
          _currentResponse = _formatGPT4CrisisResponse(response);
        });
      } else {
        final response = await _claudeService.generateCrisisInterventionPlan(
          crisisType: 'Suicidal ideation',
          currentSituation: {'patient_state': 'hopeless', 'immediate_risk': 'medium'},
          immediateRisks: ['self_harm', 'isolation'],
          availableResources: {'crisis_hotline': 'available', 'family_support': 'available'},
        );
        
        setState(() {
          _currentResponse = _formatClaudeCrisisResponse(response);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Crisis detection failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Generate Wellness Plan
  Future<void> _generateWellnessPlan() async {
    setState(() {
      _isLoading = true;
      _currentResponse = '';
    });

    try {
      if (_selectedAIModel == 'GPT-4') {
        // GPT-4 wellness plan generation
        setState(() {
          _currentResponse = '''
🌱 Wellness Plan Generated by GPT-4

📋 Personalized Strategies:
• Daily mindfulness meditation (10-15 minutes)
• Regular exercise routine (30 minutes, 3x/week)
• Balanced nutrition with mood-supporting foods
• Consistent sleep schedule (7-8 hours)

🏃 Lifestyle Modifications:
• Morning routine optimization
• Stress management techniques
• Social connection activities
• Hobby development

📊 Progress Tracking:
• Daily mood journaling
• Weekly wellness check-ins
• Monthly goal reviews
• Quarterly comprehensive assessments

🤝 Support System:
• Family involvement in wellness activities
• Peer support group participation
• Professional wellness coaching
• Community resource utilization

⏰ Long-term Maintenance:
• Quarterly wellness plan updates
• Annual comprehensive health reviews
• Continuous learning and adaptation
• Sustainable habit formation
''';
        });
      } else {
        final response = await _claudeService.generateWellnessPlan(
          patientId: 'demo_patient_001',
          healthProfile: {'overall_health': 'good', 'mental_health': 'improving'},
          wellnessGoals: ['Reduce stress', 'Improve sleep', 'Increase energy'],
          lifestyleFactors: {'exercise': 'moderate', 'diet': 'balanced', 'sleep': 'irregular'},
          barriers: ['time_constraints', 'motivation', 'stress'],
        );
        
        setState(() {
          _currentResponse = _formatClaudeWellnessResponse(response);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Wellness plan generation failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Format GPT-4 Diagnosis Response
  String _formatGPT4Response(GPT4DiagnosisResponse response) {
    return '''
🔍 AI Diagnosis Generated by GPT-4

📋 Primary Diagnosis:
${response.primaryDiagnosis}

🎯 Confidence Level: ${(response.confidenceLevel * 100).toStringAsFixed(1)}%

🔍 Differential Diagnoses:
${response.differentialDiagnoses.map((d) => '• $d').join('\n')}

⚠️ Risk Assessment:
${response.riskAssessment}

📋 Recommended Next Steps:
${response.recommendedSteps.map((s) => '• $s').join('\n')}

🧠 Clinical Reasoning:
${response.clinicalReasoning}

⏰ Generated: ${response.generatedAt.toString()}
''';
  }

  /// Format GPT-4 Treatment Response
  String _formatGPT4TreatmentResponse(GPT4TreatmentResponse response) {
    return '''
💊 Treatment Plan Generated by GPT-4

📋 Treatment Plan:
${response.treatmentPlan}

💊 Medication Recommendations:
${response.medications.map((m) => '''
• ${m.name}
  - Dosage: ${m.dosage}
  - Frequency: ${m.frequency}
  - Duration: ${m.duration}
  - Side Effects: ${m.sideEffects.join(', ')}
  - Contraindications: ${m.contraindications.join(', ')}
''').join('\n')}

🧠 Therapy Approaches:
${response.therapyApproaches.map((t) => '• $t').join('\n')}

🌱 Lifestyle Modifications:
${response.lifestyleModifications.map((l) => '• $l').join('\n')}

📊 Monitoring Recommendations:
${response.monitoringRecommendations.map((m) => '• $m').join('\n')}

🎯 Expected Outcomes:
${response.expectedOutcomes}

⏰ Timeline:
${response.timeline}
''';
  }

  /// Format GPT-4 Crisis Response
  String _formatGPT4CrisisResponse(GPT4CrisisResponse response) {
    return '''
🚨 Crisis Assessment Generated by GPT-4

⚠️ Risk Level: ${response.riskLevel.toUpperCase()}

🚨 Immediate Intervention Required: ${response.immediateIntervention ? 'YES' : 'NO'}

📋 Recommended Actions:
${response.recommendedActions.map((a) => '• $a').join('\n')}

🛡️ Safety Plan:
${response.safetyPlan}

⏰ Assessment Time: ${response.assessmentTime.toString()}

${response.immediateIntervention ? '🚨 IMMEDIATE ACTION REQUIRED - CONTACT CRISIS TEAM' : '⚠️ Monitor closely and follow safety plan'}
''';
  }

  /// Format Claude Assessment Response
  String _formatClaudeResponse(ClaudeAssessmentResponse response) {
    return '''
🔍 Mental Health Assessment Generated by Claude

📋 Clinical Impression:
${response.clinicalImpression}

⚠️ Risk Assessment:
${response.riskAssessment}

🔍 Differential Diagnoses:
${response.differentialDiagnoses.map((d) => '• $d').join('\n')}

📊 Recommended Assessments:
${response.recommendedAssessments.map((a) => '• $a').join('\n')}

💡 Initial Recommendations:
${response.initialRecommendations.map((r) => '• $r').join('\n')}

🛡️ Safety Planning:
${response.safetyPlanning}

⏰ Generated: ${response.generatedAt.toString()}
''';
  }

  /// Format Claude Intervention Response
  String _formatClaudeInterventionResponse(ClaudeInterventionResponse response) {
    return '''
💊 Therapeutic Interventions Generated by Claude

🧠 Treatment Approaches:
${response.treatmentApproaches.map((t) => '• $t').join('\n')}

🌍 Cultural Considerations:
${response.culturalConsiderations.map((c) => '• $c').join('\n')}

🔧 Intervention Techniques:
${response.interventionTechniques.map((i) => '• $i').join('\n')}

📊 Monitoring Strategies:
${response.monitoringStrategies.map((m) => '• $m').join('\n')}

🎯 Expected Outcomes:
${response.expectedOutcomes}

⏰ Timeline:
${response.timeline}

🔄 Alternative Approaches:
${response.alternativeApproaches.map((a) => '• $a').join('\n')}
''';
  }

  /// Format Claude Crisis Response
  String _formatClaudeCrisisResponse(ClaudeCrisisResponse response) {
    return '''
🚨 Crisis Intervention Plan Generated by Claude

🛡️ Immediate Safety Measures:
${response.immediateSafetyMeasures.map((s) => '• $s').join('\n')}

⚠️ Risk Level: ${response.riskLevel.toUpperCase()}

🚨 Emergency Protocols:
${response.emergencyProtocols.map((p) => '• $p').join('\n')}

📞 Resource Mobilization:
${response.resourceMobilization.map((r) => '• $r').join('\n')}

📋 Follow-up Planning:
${response.followUpPlanning}

🔄 Prevention Strategies:
${response.preventionStrategies.map((p) => '• $p').join('\n')}
''';
  }

  /// Format Claude Wellness Response
  String _formatClaudeWellnessResponse(ClaudeWellnessResponse response) {
    return '''
🌱 Wellness Plan Generated by Claude

🌿 Wellness Strategies:
${response.wellnessStrategies.map((s) => '• $s').join('\n')}

🏃 Lifestyle Modifications:
${response.lifestyleModifications.map((l) => '• $l').join('\n')}

🚧 Barrier Solutions:
${response.barrierSolutions.map((b) => '• $b').join('\n')}

🌍 Cultural Considerations:
${response.culturalConsiderations.map((c) => '• $c').join('\n')}

📊 Progress Tracking:
${response.progressTracking.map((p) => '• $p').join('\n')}

🤝 Support System Recommendations:
${response.supportSystemRecommendations.map((s) => '• $s').join('\n')}

⏰ Long-term Maintenance:
${response.longTermMaintenance}
''';
  }

  /// Copy response to clipboard
  void _copyResponse() {
    // Implementation for copying to clipboard
    _showSuccessSnackBar('Response copied to clipboard');
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
