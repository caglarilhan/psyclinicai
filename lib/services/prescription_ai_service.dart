import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/prescription_ai_models.dart';
import '../models/medication_models.dart';
import '../utils/ai_logger.dart';

class PrescriptionAIService extends ChangeNotifier {
  static final PrescriptionAIService _instance = PrescriptionAIService._internal();
  factory PrescriptionAIService() => _instance;
  PrescriptionAIService._internal();

  final AILogger _logger = AILogger();
  
  // AI Recommendations
  List<AIMedicationRecommendation> _aiRecommendations = [];
  List<PatientMedicationProfile> _patientProfiles = [];
  List<SmartDosageOptimization> _dosageOptimizations = [];
  List<AdvancedDrugInteraction> _advancedInteractions = [];
  List<AIPrescriptionHistory> _prescriptionHistory = [];
  
  // Getters
  List<AIMedicationRecommendation> get aiRecommendations => List.unmodifiable(_aiRecommendations);
  List<PatientMedicationProfile> get patientProfiles => List.unmodifiable(_patientProfiles);
  List<SmartDosageOptimization> get dosageOptimizations => List.unmodifiable(_dosageOptimizations);
  List<AdvancedDrugInteraction> get advancedInteractions => List.unmodifiable(_advancedInteractions);
  List<AIPrescriptionHistory> get prescriptionHistory => List.unmodifiable(_prescriptionHistory);

  Future<void> initialize() async {
    try {
      _logger.info('PrescriptionAIService initializing...', context: 'PrescriptionAIService');
      
      await _loadMockData();
      
      _logger.info('PrescriptionAIService initialized successfully', context: 'PrescriptionAIService');
    } catch (e) {
      _logger.error('Failed to initialize PrescriptionAIService', context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  Future<void> _loadMockData() async {
    // Load mock patient profiles
    _patientProfiles = _generateMockPatientProfiles();
    
    // Load mock AI recommendations
    _aiRecommendations = _generateMockAIRecommendations();
    
    // Load mock dosage optimizations
    _dosageOptimizations = _generateMockDosageOptimizations();
    
    // Load mock advanced interactions
    _advancedInteractions = _generateMockAdvancedInteractions();
    
    // Load mock prescription history
    _prescriptionHistory = _generateMockPrescriptionHistory();
  }

  // ===== AI İLAÇ ÖNERİSİ SİSTEMİ =====

  /// AI destekli ilaç önerisi oluştur
  Future<AIMedicationRecommendation> generateMedicationRecommendation({
    required String patientId,
    required String clinicianId,
    required List<String> diagnoses,
    required List<String> currentMedications,
    required Map<String, dynamic> patientData,
  }) async {
    try {
      _logger.info('Generating AI medication recommendation for patient: $patientId', 
                   context: 'PrescriptionAIService');
      
      // AI analizi simülasyonu
      final aiAnalysis = await _performAIAnalysis(
        diagnoses: diagnoses,
        currentMedications: currentMedications,
        patientData: patientData,
      );
      
      // İlaç önerileri oluştur
      final recommendedMedications = _generateRecommendedMedications(
        diagnoses: diagnoses,
        patientData: patientData,
        aiAnalysis: aiAnalysis,
      );
      
      // Alternatif ilaçlar
      final alternatives = _generateAlternatives(recommendedMedications);
      
      // Kontrendikasyonlar ve uyarılar
      final contraindications = _identifyContraindications(
        recommendedMedications: recommendedMedications,
        patientData: patientData,
      );
      
      final warnings = _identifyWarnings(
        recommendedMedications: recommendedMedications,
        patientData: patientData,
      );
      
      // Monitoring gereksinimleri
      final monitoringRequirements = _generateMonitoringRequirements(
        recommendedMedications: recommendedMedications,
        patientData: patientData,
      );
      
      final recommendation = AIMedicationRecommendation(
        id: 'ai_rec_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        clinicianId: clinicianId,
        recommendationDate: DateTime.now(),
        aiModel: 'GPT-4-Clinical',
        aiVersion: '1.0.0',
        confidenceScore: aiAnalysis['confidence'] ?? 0.85,
        recommendedMedications: recommendedMedications,
        alternatives: alternatives,
        contraindications: contraindications,
        warnings: warnings,
        monitoringRequirements: monitoringRequirements,
        clinicalRationale: aiAnalysis['rationale'] ?? 'AI analysis based on clinical guidelines',
        aiAnalysis: aiAnalysis,
        isReviewed: false,
        metadata: {
          'generationTime': DateTime.now().toIso8601String(),
          'modelParameters': {'temperature': 0.3, 'maxTokens': 1000},
        },
      );
      
      _aiRecommendations.add(recommendation);
      notifyListeners();
      
      _logger.info('AI medication recommendation generated successfully', 
                   context: 'PrescriptionAIService');
      
      return recommendation;
    } catch (e) {
      _logger.error('Failed to generate AI medication recommendation', 
                    context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  /// AI analizi gerçekleştir
  Future<Map<String, dynamic>> _performAIAnalysis({
    required List<String> diagnoses,
    required List<String> currentMedications,
    required Map<String, dynamic> patientData,
  }) async {
    // Simüle edilmiş AI analizi
    await Future.delayed(Duration(milliseconds: 500));
    
    final analysis = <String, dynamic>{
      'confidence': 0.85 + (Random().nextDouble() * 0.1),
      'rationale': _generateClinicalRationale(diagnoses, currentMedications),
      'riskFactors': _identifyRiskFactors(patientData),
      'treatmentGoals': _defineTreatmentGoals(diagnoses),
      'expectedOutcomes': _predictExpectedOutcomes(diagnoses),
      'timeline': _estimateTreatmentTimeline(diagnoses),
    };
    
    return analysis;
  }

  /// Önerilen ilaçları oluştur
  List<RecommendedMedication> _generateRecommendedMedications({
    required List<String> diagnoses,
    required Map<String, dynamic> patientData,
    required Map<String, dynamic> aiAnalysis,
  }) {
    final recommendations = <RecommendedMedication>[];
    
    for (final diagnosis in diagnoses) {
      final medications = _getMedicationsForDiagnosis(diagnosis);
      
      for (final medication in medications) {
        final recommendation = RecommendedMedication(
          medicationId: medication['id'],
          medicationName: medication['name'],
          dosage: _calculateOptimalDosage(medication, patientData),
          frequency: _determineFrequency(medication, diagnosis),
          durationDays: _estimateDuration(diagnosis),
          titrationSchedule: _createTitrationSchedule(medication, patientData),
          efficacyScore: _calculateEfficacyScore(medication, diagnosis, patientData),
          safetyScore: _calculateSafetyScore(medication, patientData),
          costEffectivenessScore: _calculateCostEffectiveness(medication),
          expectedBenefits: _identifyExpectedBenefits(medication, diagnosis),
          potentialRisks: _identifyPotentialRisks(medication, patientData),
          monitoringParameters: _defineMonitoringParameters(medication, patientData),
          metadata: {
            'diagnosis': diagnosis,
            'evidenceLevel': 'A',
            'guidelineSource': 'APA Guidelines',
          },
        );
        
        recommendations.add(recommendation);
      }
    }
    
    return recommendations;
  }

  /// Alternatif ilaçları oluştur
  List<MedicationAlternative> _generateAlternatives(List<RecommendedMedication> primaryRecommendations) {
    final alternatives = <MedicationAlternative>[];
    
    for (final primary in primaryRecommendations) {
      final alternativesForMedication = _findAlternatives(primary.medicationId);
      
      for (final alt in alternativesForMedication) {
        final alternative = MedicationAlternative(
          medicationId: alt['id'],
          medicationName: alt['name'],
          reason: alt['reason'],
          similarityScore: alt['similarity'],
          costDifference: alt['costDiff'],
          advantages: alt['advantages'],
          disadvantages: alt['disadvantages'],
          metadata: {'primaryMedication': primary.medicationId},
        );
        
        alternatives.add(alternative);
      }
    }
    
    return alternatives;
  }

  // ===== AKILLI DOZAJ OPTİMİZASYONU =====

  /// Akıllı dozaj optimizasyonu oluştur
  Future<SmartDosageOptimization> optimizeDosage({
    required String patientId,
    required String medicationId,
    required String currentDosage,
    required Map<String, dynamic> patientFactors,
  }) async {
    try {
      _logger.info('Optimizing dosage for patient: $patientId, medication: $medicationId', 
                   context: 'PrescriptionAIService');
      
      // AI dozaj optimizasyonu
      final optimization = await _performDosageOptimization(
        medicationId: medicationId,
        currentDosage: currentDosage,
        patientFactors: patientFactors,
      );
      
      final dosageOptimization = SmartDosageOptimization(
        id: 'dosage_opt_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        medicationId: medicationId,
        currentDosage: currentDosage,
        optimizedDosage: optimization['optimizedDosage'],
        titrationSchedule: optimization['titrationSchedule'],
        optimizationFactors: optimization['factors'],
        expectedEfficacy: optimization['expectedEfficacy'],
        expectedSafety: optimization['expectedSafety'],
        monitoringPoints: optimization['monitoringPoints'],
        optimizationDate: DateTime.now(),
        aiModel: 'GPT-4-Dosage',
        metadata: {
          'optimizationTime': DateTime.now().toIso8601String(),
          'patientFactors': patientFactors,
        },
      );
      
      _dosageOptimizations.add(dosageOptimization);
      notifyListeners();
      
      _logger.info('Dosage optimization completed successfully', 
                   context: 'PrescriptionAIService');
      
      return dosageOptimization;
    } catch (e) {
      _logger.error('Failed to optimize dosage', 
                    context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  /// Dozaj optimizasyonu gerçekleştir
  Future<Map<String, dynamic>> _performDosageOptimization({
    required String medicationId,
    required String currentDosage,
    required Map<String, dynamic> patientFactors,
  }) async {
    // Simüle edilmiş AI dozaj optimizasyonu
    await Future.delayed(Duration(milliseconds: 300));
    
    final optimization = <String, dynamic>{
      'optimizedDosage': _calculateOptimizedDosage(currentDosage, patientFactors),
      'titrationSchedule': _createOptimizedTitrationSchedule(currentDosage, patientFactors),
      'factors': _identifyOptimizationFactors(patientFactors),
      'expectedEfficacy': _calculateExpectedEfficacy(patientFactors),
      'expectedSafety': _calculateExpectedSafety(patientFactors),
      'monitoringPoints': _defineOptimizedMonitoringPoints(patientFactors),
    };
    
    return optimization;
  }

  // ===== GELİŞMİŞ ETKİLEŞİM ANALİZİ =====

  /// Gelişmiş etkileşim analizi gerçekleştir
  Future<AdvancedDrugInteraction> analyzeAdvancedInteraction({
    required List<String> medicationIds,
    required Map<String, dynamic> patientData,
  }) async {
    try {
      _logger.info('Analyzing advanced drug interaction for medications: $medicationIds', 
                   context: 'PrescriptionAIService');
      
      // AI etkileşim analizi
      final analysis = await _performAdvancedInteractionAnalysis(
        medicationIds: medicationIds,
        patientData: patientData,
      );
      
      final interaction = AdvancedDrugInteraction(
        id: 'interaction_${DateTime.now().millisecondsSinceEpoch}',
        medicationIds: medicationIds,
        medicationNames: _getMedicationNames(medicationIds),
        severity: analysis['severity'],
        mechanism: analysis['mechanism'],
        clinicalSignificance: analysis['clinicalSignificance'],
        symptoms: analysis['symptoms'],
        recommendations: analysis['recommendations'],
        monitoringRequirements: analysis['monitoringRequirements'],
        riskScore: analysis['riskScore'],
        evidenceLevel: analysis['evidenceLevel'],
        references: analysis['references'],
        metadata: {
          'analysisTime': DateTime.now().toIso8601String(),
          'patientFactors': patientData,
        },
      );
      
      _advancedInteractions.add(interaction);
      notifyListeners();
      
      _logger.info('Advanced interaction analysis completed successfully', 
                   context: 'PrescriptionAIService');
      
      return interaction;
    } catch (e) {
      _logger.error('Failed to analyze advanced interaction', 
                    context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  /// Gelişmiş etkileşim analizi gerçekleştir
  Future<Map<String, dynamic>> _performAdvancedInteractionAnalysis({
    required List<String> medicationIds,
    required Map<String, dynamic> patientData,
  }) async {
    // Simüle edilmiş AI etkileşim analizi
    await Future.delayed(Duration(milliseconds: 400));
    
    final analysis = <String, dynamic>{
      'severity': _determineInteractionSeverity(medicationIds, patientData),
      'mechanism': _identifyInteractionMechanism(medicationIds),
      'clinicalSignificance': _assessClinicalSignificance(medicationIds, patientData),
      'symptoms': _predictInteractionSymptoms(medicationIds),
      'recommendations': _generateInteractionRecommendations(medicationIds, patientData),
      'monitoringRequirements': _defineInteractionMonitoring(medicationIds, patientData),
      'riskScore': _calculateInteractionRisk(medicationIds, patientData),
      'evidenceLevel': _determineEvidenceLevel(medicationIds),
      'references': _getInteractionReferences(medicationIds),
    };
    
    return analysis;
  }

  // ===== HASTA PROFİLİ YÖNETİMİ =====

  /// Hasta profili oluştur veya güncelle
  Future<PatientMedicationProfile> createOrUpdatePatientProfile({
    required String patientId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final existingIndex = _patientProfiles.indexWhere((p) => p.patientId == patientId);
      
      final profile = PatientMedicationProfile(
        id: existingIndex >= 0 ? _patientProfiles[existingIndex].id : 'profile_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        profileDate: DateTime.now(),
        currentDiagnoses: profileData['diagnoses'] ?? [],
        currentMedications: profileData['medications'] ?? [],
        allergies: profileData['allergies'] ?? [],
        intolerances: profileData['intolerances'] ?? [],
        previousMedications: profileData['previousMedications'] ?? [],
        adverseReactions: profileData['adverseReactions'] ?? [],
        familyHistory: profileData['familyHistory'] ?? [],
        comorbidities: profileData['comorbidities'] ?? [],
        lifestyleFactors: profileData['lifestyleFactors'] ?? [],
        labResults: profileData['labResults'] ?? {},
        vitalSigns: profileData['vitalSigns'] ?? {},
        geneticFactors: profileData['geneticFactors'] ?? {},
        metadata: profileData['metadata'] ?? {},
      );
      
      if (existingIndex >= 0) {
        _patientProfiles[existingIndex] = profile;
      } else {
        _patientProfiles.add(profile);
      }
      
      notifyListeners();
      
      _logger.info('Patient profile ${existingIndex >= 0 ? 'updated' : 'created'} successfully', 
                   context: 'PrescriptionAIService');
      
      return profile;
    } catch (e) {
      _logger.error('Failed to create/update patient profile', 
                    context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  /// Hasta profili getir
  PatientMedicationProfile? getPatientProfile(String patientId) {
    try {
      return _patientProfiles.firstWhere((p) => p.patientId == patientId);
    } catch (e) {
      return null;
    }
  }

  // ===== AI REÇETE GEÇMİŞİ =====

  /// AI reçete geçmişi ekle
  Future<AIPrescriptionHistory> addPrescriptionHistory({
    required String patientId,
    required String clinicianId,
    required List<String> medications,
    required String diagnosis,
    required String aiRecommendation,
    required double aiConfidence,
    AIPrescriptionStatus status = AIPrescriptionStatus.pending,
  }) async {
    try {
      final history = AIPrescriptionHistory(
        id: 'history_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        clinicianId: clinicianId,
        prescriptionDate: DateTime.now(),
        status: status,
        medications: medications,
        diagnosis: diagnosis,
        aiRecommendation: aiRecommendation,
        aiConfidence: aiConfidence,
        metadata: {
          'creationTime': DateTime.now().toIso8601String(),
        },
      );
      
      _prescriptionHistory.add(history);
      notifyListeners();
      
      _logger.info('Prescription history added successfully', 
                   context: 'PrescriptionAIService');
      
      return history;
    } catch (e) {
      _logger.error('Failed to add prescription history', 
                    context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  /// AI reçete durumu güncelle
  Future<void> updatePrescriptionStatus({
    required String historyId,
    required AIPrescriptionStatus status,
    String? rejectionReason,
    String? modificationNotes,
  }) async {
    try {
      final index = _prescriptionHistory.indexWhere((h) => h.id == historyId);
      if (index >= 0) {
        final history = _prescriptionHistory[index];
        final updatedHistory = AIPrescriptionHistory(
          id: history.id,
          patientId: history.patientId,
          clinicianId: history.clinicianId,
          prescriptionDate: history.prescriptionDate,
          status: status,
          medications: history.medications,
          diagnosis: history.diagnosis,
          aiRecommendation: history.aiRecommendation,
          aiConfidence: history.aiConfidence,
          rejectionReason: rejectionReason,
          modificationNotes: modificationNotes,
          metadata: history.metadata,
        );
        
        _prescriptionHistory[index] = updatedHistory;
        notifyListeners();
        
        _logger.info('Prescription status updated successfully', 
                     context: 'PrescriptionAIService');
      }
    } catch (e) {
      _logger.error('Failed to update prescription status', 
                    context: 'PrescriptionAIService', error: e);
      rethrow;
    }
  }

  // ===== YARDIMCI METODLAR =====

  List<PatientMedicationProfile> _generateMockPatientProfiles() {
    return [
      PatientMedicationProfile(
        id: 'profile_1',
        patientId: 'patient_001',
        profileDate: DateTime.now().subtract(Duration(days: 30)),
        currentDiagnoses: ['Major Depressive Disorder', 'Generalized Anxiety Disorder'],
        currentMedications: ['Sertraline', 'Buspirone'],
        allergies: ['Penicillin'],
        intolerances: ['Lactose'],
        previousMedications: ['Fluoxetine', 'Escitalopram'],
        adverseReactions: ['Nausea with Fluoxetine'],
        familyHistory: ['Depression', 'Bipolar Disorder'],
        comorbidities: ['Hypertension'],
        lifestyleFactors: ['Sedentary', 'Poor sleep'],
        labResults: {'CBC': 'Normal', 'Liver Function': 'Elevated ALT'},
        vitalSigns: {'BP': '140/90', 'HR': '72'},
        geneticFactors: {'CYP2D6': 'Intermediate metabolizer'},
        metadata: {},
      ),
    ];
  }

  List<AIMedicationRecommendation> _generateMockAIRecommendations() {
    return [
      AIMedicationRecommendation(
        id: 'ai_rec_1',
        patientId: 'patient_001',
        clinicianId: 'clinician_001',
        recommendationDate: DateTime.now().subtract(Duration(days: 5)),
        aiModel: 'GPT-4-Clinical',
        aiVersion: '1.0.0',
        confidenceScore: 0.87,
        recommendedMedications: [
          RecommendedMedication(
            medicationId: 'sertraline',
            medicationName: 'Sertraline',
            dosage: '50mg',
            frequency: 'Once daily',
            durationDays: 90,
            titrationSchedule: 'Start 25mg, increase to 50mg after 1 week',
            efficacyScore: 0.85,
            safetyScore: 0.90,
            costEffectivenessScore: 0.95,
            expectedBenefits: ['Improved mood', 'Reduced anxiety', 'Better sleep'],
            potentialRisks: ['Nausea', 'Sexual dysfunction', 'Insomnia'],
            monitoringParameters: ['Mood changes', 'Side effects', 'Liver function'],
            metadata: {},
          ),
        ],
        alternatives: [
          MedicationAlternative(
            medicationId: 'escitalopram',
            medicationName: 'Escitalopram',
            reason: 'Alternative SSRI with similar efficacy',
            similarityScore: 0.85,
            costDifference: 15.0,
            advantages: ['Better tolerability', 'Once daily dosing'],
            disadvantages: ['Higher cost', 'Potential QT prolongation'],
            metadata: {},
          ),
        ],
        contraindications: ['MAOI use within 14 days'],
        warnings: ['Monitor for suicidal thoughts', 'Gradual titration'],
        monitoringRequirements: ['Weekly mood assessment', 'Monthly liver function'],
        clinicalRationale: 'Sertraline is first-line treatment for MDD and GAD',
        aiAnalysis: {'confidence': 0.87, 'rationale': 'Evidence-based recommendation'},
        isReviewed: true,
        reviewedBy: 'clinician_001',
        reviewedAt: DateTime.now().subtract(Duration(days: 4)),
        metadata: {},
      ),
    ];
  }

  List<SmartDosageOptimization> _generateMockDosageOptimizations() {
    return [
      SmartDosageOptimization(
        id: 'dosage_opt_1',
        patientId: 'patient_001',
        medicationId: 'sertraline',
        currentDosage: '25mg',
        optimizedDosage: '50mg',
        titrationSchedule: '25mg for 1 week, then 50mg',
        optimizationFactors: ['Patient tolerance', 'Clinical response', 'Side effects'],
        expectedEfficacy: 0.85,
        expectedSafety: 0.90,
        monitoringPoints: ['Week 1: Side effects', 'Week 2: Efficacy', 'Week 4: Full response'],
        optimizationDate: DateTime.now().subtract(Duration(days: 3)),
        aiModel: 'GPT-4-Dosage',
        metadata: {},
      ),
    ];
  }

  List<AdvancedDrugInteraction> _generateMockAdvancedInteractions() {
    return [
      AdvancedDrugInteraction(
        id: 'interaction_1',
        medicationIds: ['sertraline', 'buspirone'],
        medicationNames: ['Sertraline', 'Buspirone'],
        severity: InteractionSeverity.mild,
        mechanism: 'Serotonin syndrome risk',
        clinicalSignificance: 'Low risk, monitor for symptoms',
        symptoms: ['Agitation', 'Confusion', 'Rapid heart rate'],
        recommendations: ['Monitor for serotonin syndrome', 'Gradual titration'],
        monitoringRequirements: ['Watch for CNS symptoms', 'Regular vital signs'],
        riskScore: 0.25,
        evidenceLevel: 'Moderate',
        references: ['Drug Interaction Database', 'Clinical Guidelines'],
        metadata: {},
      ),
    ];
  }

  List<AIPrescriptionHistory> _generateMockPrescriptionHistory() {
    return [
      AIPrescriptionHistory(
        id: 'history_1',
        patientId: 'patient_001',
        clinicianId: 'clinician_001',
        prescriptionDate: DateTime.now().subtract(Duration(days: 5)),
        status: AIPrescriptionStatus.approved,
        medications: ['Sertraline 50mg daily'],
        diagnosis: 'Major Depressive Disorder',
        aiRecommendation: 'Sertraline is recommended as first-line treatment',
        aiConfidence: 0.87,
        metadata: {},
      ),
    ];
  }

  // Helper methods for AI analysis
  String _generateClinicalRationale(List<String> diagnoses, List<String> currentMedications) {
    return 'AI analysis based on clinical guidelines for ${diagnoses.join(", ")}. '
           'Current medications: ${currentMedications.join(", ")}.';
  }

  List<String> _identifyRiskFactors(Map<String, dynamic> patientData) {
    return ['Age >65', 'Multiple comorbidities', 'Polypharmacy'];
  }

  List<String> _defineTreatmentGoals(List<String> diagnoses) {
    return ['Symptom reduction', 'Functional improvement', 'Prevention of relapse'];
  }

  List<String> _predictExpectedOutcomes(List<String> diagnoses) {
    return ['50-70% response rate', 'Improved quality of life', 'Reduced hospitalization'];
  }

  String _estimateTreatmentTimeline(List<String> diagnoses) {
    return '6-12 weeks for initial response, 6-12 months for maintenance';
  }

  List<Map<String, dynamic>> _getMedicationsForDiagnosis(String diagnosis) {
    final medicationDatabase = {
      'Major Depressive Disorder': [
        {'id': 'sertraline', 'name': 'Sertraline', 'class': 'SSRI'},
        {'id': 'escitalopram', 'name': 'Escitalopram', 'class': 'SSRI'},
        {'id': 'venlafaxine', 'name': 'Venlafaxine', 'class': 'SNRI'},
      ],
      'Generalized Anxiety Disorder': [
        {'id': 'sertraline', 'name': 'Sertraline', 'class': 'SSRI'},
        {'id': 'buspirone', 'name': 'Buspirone', 'class': 'Anxiolytic'},
        {'id': 'venlafaxine', 'name': 'Venlafaxine', 'class': 'SNRI'},
      ],
      'Depression': [
        {'id': 'sertraline', 'name': 'Sertraline', 'class': 'SSRI'},
        {'id': 'escitalopram', 'name': 'Escitalopram', 'class': 'SSRI'},
        {'id': 'venlafaxine', 'name': 'Venlafaxine', 'class': 'SNRI'},
      ],
      'Anxiety': [
        {'id': 'sertraline', 'name': 'Sertraline', 'class': 'SSRI'},
        {'id': 'buspirone', 'name': 'Buspirone', 'class': 'Anxiolytic'},
        {'id': 'alprazolam', 'name': 'Alprazolam', 'class': 'Benzodiazepine'},
      ],
    };
    
    return medicationDatabase[diagnosis] ?? [];
  }

  String _calculateOptimalDosage(Map<String, dynamic> medication, Map<String, dynamic> patientData) {
    return '50mg'; // Simplified for demo
  }

  String _determineFrequency(Map<String, dynamic> medication, String diagnosis) {
    return 'Once daily';
  }

  int _estimateDuration(String diagnosis) {
    return 90; // 3 months
  }

  String _createTitrationSchedule(Map<String, dynamic> medication, Map<String, dynamic> patientData) {
    return 'Start 25mg, increase to 50mg after 1 week';
  }

  double _calculateEfficacyScore(Map<String, dynamic> medication, String diagnosis, Map<String, dynamic> patientData) {
    return 0.8 + (Random().nextDouble() * 0.15);
  }

  double _calculateSafetyScore(Map<String, dynamic> medication, Map<String, dynamic> patientData) {
    return 0.85 + (Random().nextDouble() * 0.1);
  }

  double _calculateCostEffectiveness(Map<String, dynamic> medication) {
    return 0.9 + (Random().nextDouble() * 0.1);
  }

  List<String> _identifyExpectedBenefits(Map<String, dynamic> medication, String diagnosis) {
    return ['Symptom reduction', 'Improved function', 'Better quality of life'];
  }

  List<String> _identifyPotentialRisks(Map<String, dynamic> medication, Map<String, dynamic> patientData) {
    return ['Side effects', 'Drug interactions', 'Allergic reactions'];
  }

  List<String> _defineMonitoringParameters(Map<String, dynamic> medication, Map<String, dynamic> patientData) {
    return ['Clinical response', 'Side effects', 'Laboratory values'];
  }

  List<Map<String, dynamic>> _findAlternatives(String medicationId) {
    final alternatives = <Map<String, dynamic>>[];
    
    // Her ilaç için alternatifler
    if (medicationId == 'sertraline') {
      alternatives.add({
        'id': 'escitalopram',
        'name': 'Escitalopram',
        'reason': 'Alternative SSRI with similar efficacy',
        'similarity': 0.85,
        'costDiff': 15.0,
        'advantages': ['Better tolerability', 'Once daily dosing'],
        'disadvantages': ['Higher cost', 'Potential QT prolongation'],
      });
      alternatives.add({
        'id': 'venlafaxine',
        'name': 'Venlafaxine',
        'reason': 'SNRI alternative',
        'similarity': 0.75,
        'costDiff': 25.0,
        'advantages': ['Dual mechanism', 'Good efficacy'],
        'disadvantages': ['Higher cost', 'More side effects'],
      });
    } else if (medicationId == 'escitalopram') {
      alternatives.add({
        'id': 'sertraline',
        'name': 'Sertraline',
        'reason': 'Alternative SSRI',
        'similarity': 0.85,
        'costDiff': -15.0,
        'advantages': ['Lower cost', 'Good tolerability'],
        'disadvantages': ['More frequent dosing'],
      });
    } else {
      // Default alternatifler
      alternatives.add({
        'id': 'sertraline',
        'name': 'Sertraline',
        'reason': 'Standard SSRI',
        'similarity': 0.8,
        'costDiff': 0.0,
        'advantages': ['Well established', 'Good safety profile'],
        'disadvantages': ['Generic only'],
      });
    }
    
    return alternatives;
  }

  List<String> _identifyContraindications({
    required List<RecommendedMedication> recommendedMedications,
    required Map<String, dynamic> patientData,
  }) {
    return ['MAOI use within 14 days', 'Severe liver disease'];
  }

  List<String> _identifyWarnings({
    required List<RecommendedMedication> recommendedMedications,
    required Map<String, dynamic> patientData,
  }) {
    return ['Monitor for suicidal thoughts', 'Gradual titration'];
  }

  List<String> _generateMonitoringRequirements({
    required List<RecommendedMedication> recommendedMedications,
    required Map<String, dynamic> patientData,
  }) {
    return ['Weekly mood assessment', 'Monthly liver function', 'Side effect monitoring'];
  }

  String _calculateOptimizedDosage(String currentDosage, Map<String, dynamic> patientFactors) {
    return '75mg'; // Simplified for demo
  }

  String _createOptimizedTitrationSchedule(String currentDosage, Map<String, dynamic> patientFactors) {
    return '50mg for 2 weeks, then 75mg';
  }

  List<String> _identifyOptimizationFactors(Map<String, dynamic> patientFactors) {
    return ['Age', 'Weight', 'Liver function', 'Previous response'];
  }

  double _calculateExpectedEfficacy(Map<String, dynamic> patientFactors) {
    return 0.85 + (Random().nextDouble() * 0.1);
  }

  double _calculateExpectedSafety(Map<String, dynamic> patientFactors) {
    return 0.90 + (Random().nextDouble() * 0.08);
  }

  List<String> _defineOptimizedMonitoringPoints(Map<String, dynamic> patientFactors) {
    return ['Week 1: Side effects', 'Week 2: Efficacy', 'Week 4: Full response'];
  }

  InteractionSeverity _determineInteractionSeverity(List<String> medicationIds, Map<String, dynamic> patientData) {
    final severityLevels = [InteractionSeverity.none, InteractionSeverity.mild, InteractionSeverity.moderate, InteractionSeverity.major, InteractionSeverity.contraindicated];
    return severityLevels[Random().nextInt(severityLevels.length)];
  }

  String _identifyInteractionMechanism(List<String> medicationIds) {
    return 'Serotonin syndrome risk';
  }

  String _assessClinicalSignificance(List<String> medicationIds, Map<String, dynamic> patientData) {
    return 'Low to moderate risk, monitor closely';
  }

  List<String> _predictInteractionSymptoms(List<String> medicationIds) {
    return ['Agitation', 'Confusion', 'Rapid heart rate'];
  }

  List<String> _generateInteractionRecommendations(List<String> medicationIds, Map<String, dynamic> patientData) {
    return ['Monitor for symptoms', 'Gradual titration', 'Regular follow-up'];
  }

  List<String> _defineInteractionMonitoring(List<String> medicationIds, Map<String, dynamic> patientData) {
    return ['Watch for CNS symptoms', 'Regular vital signs', 'Patient education'];
  }

  double _calculateInteractionRisk(List<String> medicationIds, Map<String, dynamic> patientData) {
    return 0.3 + (Random().nextDouble() * 0.4);
  }

  String _determineEvidenceLevel(List<String> medicationIds) {
    return 'Moderate';
  }

  List<String> _getInteractionReferences(List<String> medicationIds) {
    return ['Drug Interaction Database', 'Clinical Guidelines', 'Literature Review'];
  }

  List<String> _getMedicationNames(List<String> medicationIds) {
    final nameMap = {
      'sertraline': 'Sertraline',
      'escitalopram': 'Escitalopram',
      'buspirone': 'Buspirone',
      'venlafaxine': 'Venlafaxine',
    };
    
    return medicationIds.map((id) => nameMap[id] ?? id).toList();
  }
}
