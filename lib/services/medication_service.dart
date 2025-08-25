import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_models.dart';
import '../models/laboratory_models.dart';
import '../services/ai_orchestration_service.dart';
import '../utils/ai_logger.dart';

class MedicationService extends ChangeNotifier {
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  final AILogger _logger = AILogger();
  final AIOrchestrationService _aiService = AIOrchestrationService();
  
  // Medication data
  List<Medication> _medications = [];
  List<Prescription> _prescriptions = [];
  List<DrugInteraction> _drugInteractions = [];
  List<DosageTitration> _dosageTitrations = [];
  List<MedicationAdherence> _adherenceRecords = [];
  List<SideEffectReport> _sideEffectReports = [];
  List<MedicationReminder> _reminders = [];
  List<MedicationHistory> _medicationHistory = [];
  
  // Laboratory data
  List<LaboratoryTest> _labTests = [];
  List<LaboratoryResult> _labResults = [];
  List<MedicationMonitoring> _monitoringRecords = [];
  
  // Getters
  List<Medication> get medications => List.unmodifiable(_medications);
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  List<DrugInteraction> get drugInteractions => List.unmodifiable(_drugInteractions);
  List<DosageTitration> get dosageTitrations => List.unmodifiable(_dosageTitrations);
  List<MedicationAdherence> get adherenceRecords => List.unmodifiable(_adherenceRecords);
  List<SideEffectReport> get sideEffectReports => List.unmodifiable(_sideEffectReports);
  List<MedicationReminder> get reminders => List.unmodifiable(_reminders);
  List<MedicationHistory> get medicationHistory => List.unmodifiable(_medicationHistory);
  List<LaboratoryTest> get labTests => List.unmodifiable(_labTests);
  List<LaboratoryResult> get labResults => List.unmodifiable(_labResults);
  List<MedicationMonitoring> get monitoringRecords => List.unmodifiable(_monitoringRecords);

  Future<void> initialize() async {
    try {
      _logger.info('MedicationService initializing...', context: 'MedicationService');
      
      await _loadMedicationData();
      await _loadLaboratoryData();
      await _loadPrescriptions();
      await _loadAdherenceRecords();
      
      _logger.info('MedicationService initialized successfully', context: 'MedicationService');
    } catch (e) {
      _logger.error('Failed to initialize MedicationService', context: 'MedicationService', error: e);
      rethrow;
    }
  }

  Future<void> _loadMedicationData() async {
    try {
      // Load common psychiatric medications
      await _loadPsychiatricMedications();
      
      // Load drug interactions
      await _loadDrugInteractions();
      
      // Load dosage titration protocols
      await _loadDosageTitrations();
      
      _logger.info('Medication data loaded: ${_medications.length} medications, ${_drugInteractions.length} interactions', 
                   context: 'MedicationService');
    } catch (e) {
      _logger.error('Failed to load medication data', context: 'MedicationService', error: e);
    }
  }

  Future<void> _loadPsychiatricMedications() async {
    // SSRIs
    final sertraline = Medication(
      id: 'sertraline',
      name: 'Sertraline',
      genericName: 'Sertraline',
      brandName: 'Zoloft',
      atcCode: 'N06AB06',
      rxNormCode: '89478',
      dinCode: '02245678',
      barcode: '1234567890123',
      medicationClass: MedicationClass.antidepressants,
      activeIngredients: ['Sertraline'],
      inactiveIngredients: ['Microcrystalline cellulose', 'Calcium phosphate'],
      dosageForm: 'tablet',
      strengths: ['25mg', '50mg', '100mg'],
      manufacturer: 'Pfizer',
      country: 'US',
      isControlled: false,
      requiresPrescription: true,
      indications: ['Major Depressive Disorder', 'Generalized Anxiety Disorder', 'Panic Disorder'],
      contraindications: ['Bipolar Disorder', 'Pregnancy', 'MAOI use'],
      sideEffects: ['Nausea', 'Sexual dysfunction', 'Weight gain', 'Insomnia'],
      warnings: ['Suicidal thoughts', 'Serotonin syndrome risk'],
      precautions: ['Monitor for mood changes', 'Check liver function'],
      drugInteractions: ['MAOIs', 'Warfarin', 'Lithium'],
      foodInteractions: ['Grapefruit juice'],
      labInteractions: ['Liver function tests'],
      monitoringRequirements: ['Liver function', 'Complete blood count'],
      pregnancyCategory: ['Category C'],
      breastfeedingCategory: ['Use with caution'],
      pediatricUse: ['Not recommended under 6'],
      geriatricUse: ['Monitor for side effects'],
      renalAdjustment: ['No adjustment needed'],
      hepaticAdjustment: ['Reduce dose in severe impairment'],
      metadata: {'halfLife': '26 hours', 'metabolism': 'CYP2D6'},
      isActive: true,
      lastUpdated: DateTime.now(),
    );

    // SNRIs
    final venlafaxine = Medication(
      id: 'venlafaxine',
      name: 'Venlafaxine',
      genericName: 'Venlafaxine',
      brandName: 'Effexor',
      atcCode: 'N06AX16',
      rxNormCode: '99367',
      dinCode: '02245679',
      barcode: '1234567890124',
      medicationClass: MedicationClass.antidepressants,
      activeIngredients: ['Venlafaxine'],
      inactiveIngredients: ['Microcrystalline cellulose', 'Lactose'],
      dosageForm: 'tablet',
      strengths: ['37.5mg', '75mg', '150mg', '225mg'],
      manufacturer: 'Wyeth',
      country: 'US',
      isControlled: false,
      requiresPrescription: true,
      indications: ['Major Depressive Disorder', 'Generalized Anxiety Disorder', 'Social Anxiety Disorder'],
      contraindications: ['Bipolar Disorder', 'Pregnancy', 'MAOI use'],
      sideEffects: ['Nausea', 'Headache', 'Insomnia', 'Hypertension'],
      warnings: ['Suicidal thoughts', 'Serotonin syndrome risk', 'Blood pressure monitoring'],
      precautions: ['Monitor blood pressure', 'Check liver function'],
      drugInteractions: ['MAOIs', 'Warfarin', 'Aspirin'],
      foodInteractions: ['Alcohol'],
      labInteractions: ['Liver function tests', 'Blood pressure'],
      monitoringRequirements: ['Blood pressure', 'Liver function'],
      pregnancyCategory: ['Category C'],
      breastfeedingCategory: ['Use with caution'],
      pediatricUse: ['Not recommended under 18'],
      geriatricUse: ['Monitor blood pressure'],
      renalAdjustment: ['Reduce dose in renal impairment'],
      hepaticAdjustment: ['Reduce dose in hepatic impairment'],
      metadata: {'halfLife': '5 hours', 'metabolism': 'CYP2D6, CYP3A4'},
      isActive: true,
      lastUpdated: DateTime.now(),
    );

    // Atypical Antipsychotics
    final risperidone = Medication(
      id: 'risperidone',
      name: 'Risperidone',
      genericName: 'Risperidone',
      brandName: 'Risperdal',
      atcCode: 'N05AX08',
      rxNormCode: '10631',
      dinCode: '02245680',
      barcode: '1234567890125',
      medicationClass: MedicationClass.antipsychotics,
      activeIngredients: ['Risperidone'],
      inactiveIngredients: ['Microcrystalline cellulose', 'Lactose'],
      dosageForm: 'tablet',
      strengths: ['0.25mg', '0.5mg', '1mg', '2mg', '3mg', '4mg'],
      manufacturer: 'Janssen',
      country: 'US',
      isControlled: false,
      requiresPrescription: true,
      indications: ['Schizophrenia', 'Bipolar Disorder', 'Autism-related irritability'],
      contraindications: ['Pregnancy', 'Lactation', 'Severe renal impairment'],
      sideEffects: ['Weight gain', 'Diabetes risk', 'Extrapyramidal symptoms', 'Prolactin elevation'],
      warnings: ['Metabolic syndrome', 'Tardive dyskinesia', 'Neuroleptic malignant syndrome'],
      precautions: ['Monitor weight', 'Check blood glucose', 'Monitor prolactin'],
      drugInteractions: ['CYP2D6 inhibitors', 'Carbamazepine', 'Fluoxetine'],
      foodInteractions: ['High-fat meals'],
      labInteractions: ['Blood glucose', 'Lipids', 'Prolactin'],
      monitoringRequirements: ['Weight', 'Blood glucose', 'Lipids', 'Prolactin'],
      pregnancyCategory: ['Category C'],
      breastfeedingCategory: ['Not recommended'],
      pediatricUse: ['Use with caution'],
      geriatricUse: ['Monitor for side effects'],
      renalAdjustment: ['Reduce dose in renal impairment'],
      hepaticAdjustment: ['Reduce dose in hepatic impairment'],
      metadata: {'halfLife': '3 hours', 'metabolism': 'CYP2D6'},
      isActive: true,
      lastUpdated: DateTime.now(),
    );

    _medications.addAll([sertraline, venlafaxine, risperidone]);
  }

  Future<void> _loadDrugInteractions() async {
    // SSRI + MAOI interaction
    final ssriMaoiInteraction = DrugInteraction(
      id: 'ssri_maoi_interaction',
      medication1Id: 'sertraline',
      medication1Name: 'Sertraline',
      medication2Id: 'maoi',
      medication2Name: 'MAOIs',
      severity: InteractionSeverity.contraindicated,
      type: InteractionType.pharmacodynamic,
      mechanism: 'Serotonin syndrome risk due to increased serotonin levels',
      description: 'Combination of SSRIs with MAOIs can lead to serotonin syndrome',
      clinicalSignificance: 'Life-threatening interaction requiring immediate discontinuation',
      symptoms: ['Agitation', 'Confusion', 'Hyperthermia', 'Tachycardia', 'Rigidity'],
      recommendations: ['Discontinue both medications', 'Monitor for serotonin syndrome', 'Wait 2 weeks between medications'],
      alternatives: ['Switch to non-serotonergic antidepressant', 'Use alternative MAOI'],
      monitoring: ['Vital signs', 'Mental status', 'Neurological examination'],
      evidence: 'Multiple case reports and clinical studies',
      source: 'FDA, Clinical Pharmacology',
    );

    // Lithium + SSRI interaction
    final lithiumSsriInteraction = DrugInteraction(
      id: 'lithium_ssri_interaction',
      medication1Id: 'lithium',
      medication1Name: 'Lithium',
      medication2Id: 'sertraline',
      medication2Name: 'Sertraline',
      severity: InteractionSeverity.moderate,
      type: InteractionType.pharmacodynamic,
      mechanism: 'Increased risk of serotonin syndrome and lithium toxicity',
      description: 'SSRIs may increase lithium levels and serotonin syndrome risk',
      clinicalSignificance: 'Moderate interaction requiring careful monitoring',
      symptoms: ['Tremor', 'Confusion', 'Nausea', 'Diarrhea', 'Serotonin syndrome symptoms'],
      recommendations: ['Monitor lithium levels closely', 'Reduce lithium dose if needed', 'Monitor for serotonin syndrome'],
      alternatives: ['Consider alternative mood stabilizer', 'Use lower SSRI dose'],
      monitoring: ['Lithium levels', 'Serum creatinine', 'Thyroid function', 'Mental status'],
      evidence: 'Clinical studies and case reports',
      source: 'Clinical Pharmacology, Drug Interactions',
    );

    _drugInteractions.addAll([ssriMaoiInteraction, lithiumSsriInteraction]);
  }

  Future<void> _loadDosageTitrations() async {
    // Sertraline titration
    final sertralineTitration = DosageTitration(
      id: 'sertraline_titration',
      medicationId: 'sertraline',
      medicationName: 'Sertraline',
      indication: 'Major Depressive Disorder',
      steps: [
        TitrationStep(
          id: 'sertraline_step1',
          stepNumber: 1,
          dosage: '25mg',
          frequency: 'Once daily',
          duration: '1 week',
          instructions: 'Start with 25mg daily in the morning',
          monitoring: ['Side effects', 'Mood changes', 'Suicidal thoughts'],
          sideEffects: ['Nausea', 'Insomnia', 'Headache'],
          warnings: ['Monitor for worsening depression'],
          requiresAdjustment: true,
          adjustmentCriteria: 'If well tolerated, increase to 50mg',
        ),
        TitrationStep(
          id: 'sertraline_step2',
          stepNumber: 2,
          dosage: '50mg',
          frequency: 'Once daily',
          duration: '2 weeks',
          instructions: 'Increase to 50mg daily if 25mg well tolerated',
          monitoring: ['Side effects', 'Mood improvement', 'Liver function'],
          sideEffects: ['Nausea', 'Sexual dysfunction', 'Weight changes'],
          warnings: ['Monitor for serotonin syndrome'],
          requiresAdjustment: true,
          adjustmentCriteria: 'If response inadequate, increase to 100mg',
        ),
        TitrationStep(
          id: 'sertraline_step3',
          stepNumber: 3,
          dosage: '100mg',
          frequency: 'Once daily',
          duration: 'Maintenance',
          instructions: 'Target dose for most patients',
          monitoring: ['Therapeutic response', 'Side effects', 'Liver function'],
          sideEffects: ['Sexual dysfunction', 'Weight gain', 'Fatigue'],
          warnings: ['Monitor for long-term side effects'],
          requiresAdjustment: false,
          adjustmentCriteria: 'Maintain unless side effects occur',
        ),
      ],
      strategy: TitrationStrategy.startLowGoSlow,
      rationale: 'Gradual titration reduces side effects and improves tolerability',
      monitoringParameters: ['Side effects', 'Mood improvement', 'Liver function', 'Suicidal thoughts'],
      adverseEffects: ['Serotonin syndrome', 'Suicidal thoughts', 'Liver toxicity'],
      contraindications: ['Bipolar disorder', 'Pregnancy', 'MAOI use'],
      duration: '6-8 weeks for full effect',
    );

    _dosageTitrations.add(sertralineTitration);
  }

  Future<void> _loadLaboratoryData() async {
    try {
      // Load common psychiatric lab tests
      await _loadPsychiatricLabTests();
      
      // Load medication monitoring requirements
      await _loadMedicationMonitoring();
      
      _logger.info('Laboratory data loaded: ${_labTests.length} tests, ${_monitoringRecords.length} monitoring records', 
                   context: 'MedicationService');
    } catch (e) {
      _logger.error('Failed to load laboratory data', context: 'MedicationService', error: e);
    }
  }

  Future<void> _loadPsychiatricLabTests() async {
    // Lithium level test
    final lithiumTest = LaboratoryTest(
      id: 'lithium_test',
      name: 'Lithium Level',
      code: 'LITH',
      category: 'Therapeutic Drug Monitoring',
      description: 'Measurement of lithium concentration in blood for therapeutic monitoring',
      specimenType: 'Serum',
      preparationInstructions: ['Draw 12 hours after last dose', 'Avoid hemolysis'],
      turnaroundTime: '4 hours',
      normalRanges: ['0.6-1.2 mEq/L'],
      criticalValues: ['<0.4 mEq/L', '>2.0 mEq/L'],
      units: ['mEq/L'],
      methodologies: ['Ion-selective electrode', 'Atomic absorption'],
      relatedTests: ['Creatinine', 'TSH', 'CBC'],
      clinicalIndications: ['Lithium therapy monitoring', 'Toxicity assessment'],
      contraindications: ['None'],
      interferingFactors: ['Hemolysis', 'Lipemia', 'Recent dose'],
      medications: ['Lithium'],
      requiresFasting: false,
      requiresSpecialHandling: false,
      cost: '\$25',
      insuranceCode: '80170',
      metadata: {'criticalLow': '0.4', 'criticalHigh': '2.0'},
      isActive: true,
      lastUpdated: DateTime.now(),
    );

    // Valproate level test
    final valproateTest = LaboratoryTest(
      id: 'valproate_test',
      name: 'Valproate Level',
      code: 'VALP',
      category: 'Therapeutic Drug Monitoring',
      description: 'Measurement of valproic acid concentration in blood',
      specimenType: 'Serum',
      preparationInstructions: ['Draw 12 hours after last dose', 'Avoid hemolysis'],
      turnaroundTime: '4 hours',
      normalRanges: ['50-100 mcg/mL'],
      criticalValues: ['<20 mcg/mL', '>150 mcg/mL'],
      units: ['mcg/mL'],
      methodologies: ['Immunoassay', 'HPLC'],
      relatedTests: ['Liver function tests', 'CBC', 'Ammonia'],
      clinicalIndications: ['Valproate therapy monitoring', 'Toxicity assessment'],
      contraindications: ['None'],
      interferingFactors: ['Hemolysis', 'Lipemia', 'Recent dose'],
      medications: ['Valproate', 'Divalproex'],
      requiresFasting: false,
      requiresSpecialHandling: false,
      cost: '\$30',
      insuranceCode: '80164',
      metadata: {'criticalLow': '20', 'criticalHigh': '150'},
      isActive: true,
      lastUpdated: DateTime.now(),
    );

    _labTests.addAll([lithiumTest, valproateTest]);
  }

  Future<void> _loadMedicationMonitoring() async {
    // Lithium monitoring
    final lithiumMonitoring = MedicationMonitoring(
      id: 'lithium_monitoring',
      patientId: 'patient_001',
      medicationId: 'lithium',
      medicationName: 'Lithium',
      requiredTests: ['lithium_test', 'creatinine', 'tsh', 'cbc'],
      tests: _labTests.where((t) => ['lithium_test'].contains(t.id)).toList(),
      monitoringFrequency: 'Weekly initially, then monthly',
      baselineRequired: 'Yes',
      criticalValues: ['Lithium >2.0 mEq/L', 'Creatinine >2.0 mg/dL', 'TSH >10 mIU/L'],
      actionRequired: ['Discontinue if toxic', 'Reduce dose if elevated', 'Monitor thyroid function'],
      monitoringParameters: ['Lithium level', 'Renal function', 'Thyroid function', 'Side effects'],
      duration: 'Lifelong while on lithium',
      notes: 'Monitor for signs of toxicity and renal impairment',
    );

    _monitoringRecords.add(lithiumMonitoring);
  }

  Future<void> _loadPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prescriptionsJson = prefs.getString('medication_prescriptions');
      
      if (prescriptionsJson != null) {
        final List<dynamic> prescriptionsList = json.decode(prescriptionsJson);
        _prescriptions = prescriptionsList.map((prescription) => Prescription.fromJson(prescription)).toList();
      }
      
      _logger.info('Prescriptions loaded: ${_prescriptions.length} prescriptions', context: 'MedicationService');
    } catch (e) {
      _logger.error('Failed to load prescriptions', context: 'MedicationService', error: e);
    }
  }

  Future<void> _loadAdherenceRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adherenceJson = prefs.getString('medication_adherence');
      
      if (adherenceJson != null) {
        final List<dynamic> adherenceList = json.decode(adherenceJson);
        _adherenceRecords = adherenceList.map((adherence) => MedicationAdherence.fromJson(adherence)).toList();
      }
      
      _logger.info('Adherence records loaded: ${_adherenceRecords.length} records', context: 'MedicationService');
    } catch (e) {
      _logger.error('Failed to load adherence records', context: 'MedicationService', error: e);
    }
  }

  // ===== MEDICATION FUNCTIONS =====

  Future<List<Medication>> searchMedications({
    String? query,
    MedicationClass? medicationClass,
    String? indication,
    bool? isControlled,
    int limit = 20,
  }) async {
    try {
      List<Medication> results = _medications;

      // Filter by query
      if (query != null && query.isNotEmpty) {
        results = results.where((medication) =>
          medication.name.toLowerCase().contains(query.toLowerCase()) ||
          medication.genericName.toLowerCase().contains(query.toLowerCase()) ||
          medication.brandName.toLowerCase().contains(query.toLowerCase()) ||
          medication.indications.any((ind) => ind.toLowerCase().contains(query.toLowerCase()))
        ).toList();
      }

      // Filter by medication class
      if (medicationClass != null) {
        results = results.where((medication) => medication.medicationClass == medicationClass).toList();
      }

      // Filter by indication
      if (indication != null) {
        results = results.where((medication) =>
          medication.indications.any((ind) => ind.toLowerCase().contains(indication.toLowerCase()))
        ).toList();
      }

      // Filter by controlled status
      if (isControlled != null) {
        results = results.where((medication) => medication.isControlled == isControlled).toList();
      }

      // Limit results
      if (results.length > limit) {
        results = results.take(limit).toList();
      }

      return results;
    } catch (e) {
      _logger.error('Failed to search medications', context: 'MedicationService', error: e);
      return [];
    }
  }

  Future<Medication?> getMedication(String medicationId) async {
    try {
      return _medications.firstWhere((medication) => medication.id == medicationId);
    } catch (e) {
      _logger.error('Failed to get medication', context: 'MedicationService', error: e);
      return null;
    }
  }

  // ===== DRUG INTERACTION FUNCTIONS =====

  Future<List<DrugInteraction>> checkDrugInteractions({
    required List<String> medicationIds,
    String? patientId,
  }) async {
    try {
      List<DrugInteraction> interactions = [];

      // Check for interactions between all medication pairs
      for (int i = 0; i < medicationIds.length; i++) {
        for (int j = i + 1; j < medicationIds.length; j++) {
          final med1Id = medicationIds[i];
          final med2Id = medicationIds[j];

          // 1) Static catalog lookup
          final staticInteraction = _drugInteractions.firstWhere(
            (interaction) =>
              (interaction.medication1Id == med1Id && interaction.medication2Id == med2Id) ||
              (interaction.medication1Id == med2Id && interaction.medication2Id == med1Id),
            orElse: () => const DrugInteraction(
              id: 'no_interaction',
              medication1Id: '',
              medication1Name: '',
              medication2Id: '',
              medication2Name: '',
              severity: InteractionSeverity.minor,
              type: InteractionType.other,
              mechanism: 'No known interaction',
              description: 'No significant interaction found',
              clinicalSignificance: 'Safe to use together',
              symptoms: [],
              recommendations: ['Monitor for unexpected effects'],
              alternatives: [],
              monitoring: ['General monitoring'],
              evidence: 'No evidence of interaction',
              source: 'Clinical experience',
            ),
          );

          if (staticInteraction.id != 'no_interaction') {
            interactions.add(staticInteraction);
            continue; // static takes precedence
          }

          // 2) Rule-based evaluation using available metadata
          final medA = await getMedication(med1Id);
          final medB = await getMedication(med2Id);
          final ruleResult = _evaluatePairwiseRules(med1Id, med2Id, medA, medB);
          if (ruleResult != null) {
            interactions.add(ruleResult);
          }
        }
      }

      // Sort by severity (most severe first)
      interactions.sort((a, b) {
        final severityOrder = {
          InteractionSeverity.contraindicated: 4,
          InteractionSeverity.major: 3,
          InteractionSeverity.moderate: 2,
          InteractionSeverity.minor: 1,
        };
        return severityOrder[b.severity]!.compareTo(severityOrder[a.severity]!);
      });

      return interactions;
    } catch (e) {
      _logger.error('Failed to check drug interactions', context: 'MedicationService', error: e);
      return [];
    }
  }

  DrugInteraction? _evaluatePairwiseRules(
    String med1Id,
    String med2Id,
    Medication? medA,
    Medication? medB,
  ) {
    final idA = med1Id.toLowerCase();
    final idB = med2Id.toLowerCase();

    String nameA = medA?.name ?? med1Id;
    String nameB = medB?.name ?? med2Id;

    // SSRI + MAOI (generic) safeguard - if we ever lack static entry
    final isSsri = (medA?.medicationClass == MedicationClass.antidepressants &&
                    (medA?.metadata['class']?.toString().toLowerCase().contains('ssri') ?? false)) ||
                   nameA.toLowerCase().contains('sertraline');
    final isMaoi = idA.contains('maoi') || idB.contains('maoi') ||
                   nameA.toLowerCase().contains('maoi') || nameB.toLowerCase().contains('maoi');
    if ((isSsri && isMaoi) ||
        (nameA.toLowerCase().contains('sertraline') && isMaoi) ||
        (nameB.toLowerCase().contains('sertraline') && isMaoi)) {
      return DrugInteraction(
        id: 'rule_ssri_maoi_${med1Id}_$med2Id',
        medication1Id: med1Id,
        medication1Name: nameA,
        medication2Id: med2Id,
        medication2Name: nameB,
        severity: InteractionSeverity.contraindicated,
        type: InteractionType.pharmacodynamic,
        mechanism: 'Serotonin artışı nedeniyle serotonin sendromu riski',
        description: 'SSRI ve MAOI kombinasyonu ciddi serotonin sendromuna yol açabilir',
        clinicalSignificance: 'Birlikte kullanım kontrendikedir',
        symptoms: ['Ajitasyon', 'Konfüzyon', 'Hipertermi', 'Taşikardi', 'Rigidite'],
        recommendations: ['Birlikte kullanmayın', 'İlaçlar arası 14 gün ara verin'],
        alternatives: ['Non-serotonerjik antidepresan düşünün'],
        monitoring: ['Hayati bulgular', 'Nörolojik muayene'],
        evidence: 'Kılavuzlar ve olgu bildirimleri',
        source: 'Clinical guidelines',
      );
    }

    // Lithium + SSRI (fallback if static unavailable)
    if ((idA.contains('lithium') && nameB.toLowerCase().contains('sertraline')) ||
        (idB.contains('lithium') && nameA.toLowerCase().contains('sertraline'))) {
      return DrugInteraction(
        id: 'rule_lithium_ssri_${med1Id}_$med2Id',
        medication1Id: med1Id,
        medication1Name: nameA,
        medication2Id: med2Id,
        medication2Name: nameB,
        severity: InteractionSeverity.moderate,
        type: InteractionType.pharmacodynamic,
        mechanism: 'SSRI ile birlikte lityum düzeyleri ve serotonin sendromu riski artabilir',
        description: 'Yakın izlem ve gerekirse doz ayarlaması önerilir',
        clinicalSignificance: 'Dikkatli kullanım ve yakın takip gerekir',
        symptoms: ['Tremor', 'Konfüzyon', 'Bulantı', 'İshal'],
        recommendations: ['Lityum düzeylerini izleyin', 'Semptomları takip edin'],
        alternatives: ['Alternatif duygu durum dengeleyici düşünün'],
        monitoring: ['Lityum düzeyi', 'Böbrek fonksiyonları', 'Mental durum'],
        evidence: 'Klinik çalışmalar ve olgu bildirimleri',
        source: 'Clinical guidelines',
      );
    }

    // QT uzaması için kaba kural (veri yoksa üretmeyelim)
    // Gerekli meta olmadığından şu an pasif.

    return null;
  }

  // ===== DOSAGE TITRATION FUNCTIONS =====

  Future<DosageTitration?> getDosageTitration({
    required String medicationId,
    String? indication,
  }) async {
    try {
      return _dosageTitrations.firstWhere(
        (titration) => titration.medicationId == medicationId,
        orElse: () => DosageTitration(
          id: 'default_titration',
          medicationId: medicationId,
          medicationName: 'Unknown',
          indication: indication ?? 'General use',
          steps: [],
          strategy: TitrationStrategy.startLowGoSlow,
          rationale: 'Standard titration approach',
          monitoringParameters: ['Side effects', 'Therapeutic response'],
          adverseEffects: ['Monitor for side effects'],
          contraindications: ['Known hypersensitivity'],
          duration: 'Individualized',
        ),
      );
    } catch (e) {
      _logger.error('Failed to get dosage titration', context: 'MedicationService', error: e);
      return null;
    }
  }

  // ===== PRESCRIPTION FUNCTIONS =====

  Future<Prescription> createPrescription({
    required String patientId,
    required String clinicianId,
    required String diagnosis,
    required List<PrescribedMedication> medications,
    required String clinicalNotes,
    List<String>? allergies,
    List<String>? contraindications,
    List<String>? warnings,
    List<String>? instructions,
    int refillsAllowed = 0,
    String? pharmacy,
  }) async {
    try {
      final prescription = Prescription(
        id: _generateId(),
        patientId: patientId,
        clinicianId: clinicianId,
        prescriptionDate: DateTime.now(),
        status: PrescriptionStatus.pending,
        medications: medications,
        diagnosis: diagnosis,
        clinicalNotes: clinicalNotes,
        allergies: allergies ?? [],
        contraindications: contraindications ?? [],
        warnings: warnings ?? [],
        instructions: instructions ?? [],
        refillsAllowed: refillsAllowed,
        refillsUsed: 0,
        pharmacy: pharmacy ?? 'Default Pharmacy',
        prescriberSignature: 'Digital Signature',
        isElectronic: true,
        prescriptionNumber: _generatePrescriptionNumber(),
      );

      _prescriptions.add(prescription);
      await _savePrescriptions();

      _logger.info('Prescription created successfully', context: 'MedicationService', data: {
        'prescriptionId': prescription.id,
        'patientId': patientId,
        'medicationCount': medications.length,
      });

      return prescription;
    } catch (e) {
      _logger.error('Failed to create prescription', context: 'MedicationService', error: e);
      rethrow;
    }
  }

  Future<void> updatePrescription(Prescription prescription) async {
    try {
      final existingIndex = _prescriptions.indexWhere((p) => p.id == prescription.id);
      
      if (existingIndex >= 0) {
        _prescriptions[existingIndex] = prescription;
        await _savePrescriptions();
        
        _logger.info('Prescription updated successfully', context: 'MedicationService', data: {
          'prescriptionId': prescription.id,
        });
        
        notifyListeners();
      }
    } catch (e) {
      _logger.error('Failed to update prescription', context: 'MedicationService', error: e);
      rethrow;
    }
  }

  Future<Prescription?> getPrescription(String prescriptionId) async {
    try {
      return _prescriptions.firstWhere((p) => p.id == prescriptionId);
    } catch (e) {
      _logger.error('Failed to get prescription', context: 'MedicationService', error: e);
      return null;
    }
  }

  List<Prescription> getPatientPrescriptions(String patientId) {
    return _prescriptions.where((p) => p.patientId == patientId).toList();
  }

  List<Prescription> getClinicianPrescriptions(String clinicianId) {
    return _prescriptions.where((p) => p.clinicianId == clinicianId).toList();
  }

  // ===== ADHERENCE FUNCTIONS =====

  Future<void> recordAdherence({
    required String patientId,
    required String medicationId,
    required String medicationName,
    required AdherenceEventType eventType,
    String? reason,
    String? action,
  }) async {
    try {
      final event = AdherenceEvent(
        id: _generateId(),
        timestamp: DateTime.now(),
        type: eventType,
        description: _getAdherenceEventDescription(eventType),
        reason: reason ?? 'Not specified',
        action: action ?? 'None',
      );

      // Find existing adherence record or create new one
      var adherence = _adherenceRecords.firstWhere(
        (a) => a.patientId == patientId && a.medicationId == medicationId,
        orElse: () => MedicationAdherence(
          id: _generateId(),
          patientId: patientId,
          medicationId: medicationId,
          medicationName: medicationName,
          startDate: DateTime.now(),
          status: AdherenceStatus.good,
          adherenceRate: 100.0,
          events: [],
          barriers: [],
          facilitators: [],
          interventions: [],
          notes: 'New adherence record',
        ),
      );

      // Add event and update adherence
      final updatedEvents = [...adherence.events, event];
      final updatedAdherenceRate = _calculateAdherenceRate(updatedEvents);
      final updatedStatus = _calculateAdherenceStatus(updatedAdherenceRate);
      adherence = adherence.copyWith(
        events: updatedEvents,
        adherenceRate: updatedAdherenceRate,
        status: updatedStatus,
      );

      // Save or update record
      final existingIndex = _adherenceRecords.indexWhere((a) => a.id == adherence.id);
      if (existingIndex >= 0) {
        _adherenceRecords[existingIndex] = adherence;
      } else {
        _adherenceRecords.add(adherence);
      }

      await _saveAdherenceRecords();
      
      _logger.info('Adherence recorded successfully', context: 'MedicationService', data: {
        'patientId': patientId,
        'medicationId': medicationId,
        'eventType': eventType.name,
      });
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to record adherence', context: 'MedicationService', error: e);
      rethrow;
    }
  }

  // ===== LABORATORY FUNCTIONS =====

  Future<List<LaboratoryTest>> getRequiredTests({
    required String medicationId,
    String? patientId,
  }) async {
    try {
      final medication = await getMedication(medicationId);
      if (medication == null) return [];

      return _labTests.where((test) =>
        test.medications.contains(medicationId)
      ).toList();
    } catch (e) {
      _logger.error('Failed to get required tests', context: 'MedicationService', error: e);
      return [];
    }
  }

  List<LaboratoryResult> getPatientLabResults(String patientId) {
    return _labResults.where((result) => result.patientId == patientId).toList();
  }

  // ===== UTILITY METHODS =====

  String _getAdherenceEventDescription(AdherenceEventType eventType) {
    switch (eventType) {
      case AdherenceEventType.taken:
        return 'Medication taken as prescribed';
      case AdherenceEventType.missed:
        return 'Medication dose missed';
      case AdherenceEventType.delayed:
        return 'Medication taken later than scheduled';
      case AdherenceEventType.skipped:
        return 'Medication dose intentionally skipped';
      case AdherenceEventType.doubled:
        return 'Extra dose taken';
      case AdherenceEventType.other:
        return 'Other adherence event';
    }
  }

  double _calculateAdherenceRate(List<AdherenceEvent> events) {
    if (events.isEmpty) return 100.0;
    
    final takenEvents = events.where((e) => e.type == AdherenceEventType.taken).length;
    final totalEvents = events.length;
    
    return (takenEvents / totalEvents) * 100;
  }

  AdherenceStatus _calculateAdherenceStatus(double adherenceRate) {
    if (adherenceRate >= 90) return AdherenceStatus.excellent;
    if (adherenceRate >= 80) return AdherenceStatus.good;
    if (adherenceRate >= 70) return AdherenceStatus.fair;
    if (adherenceRate >= 50) return AdherenceStatus.poor;
    return AdherenceStatus.nonAdherent;
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
  
  String _generatePrescriptionNumber() => 'RX${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _savePrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prescriptionsJson = json.encode(_prescriptions.map((p) => p.toJson()).toList());
      await prefs.setString('medication_prescriptions', prescriptionsJson);
    } catch (e) {
      _logger.error('Failed to save prescriptions', context: 'MedicationService', error: e);
      rethrow;
    }
  }

  Future<void> _saveAdherenceRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adherenceJson = json.encode(_adherenceRecords.map((a) => a.toJson()).toList());
      await prefs.setString('medication_adherence', adherenceJson);
    } catch (e) {
      _logger.error('Failed to save adherence records', context: 'MedicationService', error: e);
      rethrow;
    }
  }
}
