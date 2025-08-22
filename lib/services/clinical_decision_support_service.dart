import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clinical_decision_support_models.dart';
import 'ai_service.dart';

class ClinicalDecisionSupportService extends ChangeNotifier {
  static final ClinicalDecisionSupportService _instance = ClinicalDecisionSupportService._internal();
  factory ClinicalDecisionSupportService() => _instance;
  ClinicalDecisionSupportService._internal();

  AIService? _aiService;
  List<ClinicalDecisionTree> _decisionTrees = [];
  List<DrugInteractionSimulation> _drugInteractions = [];
  List<PharmacogeneticProfile> _pharmacogeneticProfiles = [];
  List<TreatmentResistanceAlgorithm> _treatmentAlgorithms = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<ClinicalDecisionTree> get decisionTrees => _decisionTrees;
  List<DrugInteractionSimulation> get drugInteractions => _drugInteractions;
  List<PharmacogeneticProfile> get pharmacogeneticProfiles => _pharmacogeneticProfiles;
  List<TreatmentResistanceAlgorithm> get treatmentAlgorithms => _treatmentAlgorithms;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _aiService = AIService();
      await _loadDecisionTrees();
      await _loadDrugInteractions();
      await _loadPharmacogeneticProfiles();
      await _loadTreatmentAlgorithms();
      _isInitialized = true;
      notifyListeners();
      print('ClinicalDecisionSupportService initialized successfully');
    } catch (e) {
      print('ClinicalDecisionSupportService initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadDecisionTrees() async {
    // DSM-5 based decision trees
    _decisionTrees.addAll([
      ClinicalDecisionTree(
        id: 'depression_diagnosis',
        name: 'Depresyon Teşhis Ağacı',
        description: 'DSM-5 kriterlerine göre depresyon teşhisi',
        rootNode: DecisionNode(
          id: 'depression_root',
          question: 'Hasta son 2 haftada depresif ruh hali yaşıyor mu?',
          type: DecisionNodeType.symptom,
          options: [
            DecisionOption(
              id: 'yes_depressed_mood',
              text: 'Evet',
              nextNode: DecisionNode(
                id: 'depression_core_symptoms',
                question: 'Aşağıdaki belirtilerden kaç tanesi mevcut?\n• İlgi kaybı\n• Kilo değişimi\n• Uyku bozukluğu\n• Yorgunluk\n• Değersizlik hissi',
                type: DecisionNodeType.symptom,
                options: [
                  DecisionOption(
                    id: 'core_symptoms_5plus',
                    text: '5 veya daha fazla',
                    nextNode: DecisionNode(
                      id: 'depression_severity',
                      question: 'Belirtiler günlük işlevselliği etkiliyor mu?',
                      type: DecisionNodeType.symptom,
                      options: [
                        DecisionOption(
                          id: 'severe_impairment',
                          text: 'Ciddi etki',
                          nextNode: DecisionNode(
                            id: 'major_depression_severe',
                            question: 'Sonuç: Major Depresif Bozukluk (Şiddetli)',
                            type: DecisionNodeType.outcome,
                            options: [],
                          ),
                        ),
                        DecisionOption(
                          id: 'moderate_impairment',
                          text: 'Orta etki',
                          nextNode: DecisionNode(
                            id: 'major_depression_moderate',
                            question: 'Sonuç: Major Depresif Bozukluk (Orta)',
                            type: DecisionNodeType.outcome,
                            options: [],
                          ),
                        ),
                        DecisionOption(
                          id: 'mild_impairment',
                          text: 'Hafif etki',
                          nextNode: DecisionNode(
                            id: 'major_depression_mild',
                            question: 'Sonuç: Major Depresif Bozukluk (Hafif)',
                            type: DecisionNodeType.outcome,
                            options: [],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DecisionOption(
                    id: 'core_symptoms_2to4',
                    text: '2-4 arası',
                    nextNode: DecisionNode(
                      id: 'mild_depression',
                      question: 'Sonuç: Hafif Depresif Bozukluk',
                      type: DecisionNodeType.outcome,
                      options: [],
                    ),
                  ),
                  DecisionOption(
                    id: 'core_symptoms_less2',
                    text: '2\'den az',
                    nextNode: DecisionNode(
                      id: 'no_depression',
                      question: 'Sonuç: Depresyon yok',
                      type: DecisionNodeType.outcome,
                      options: [],
                    ),
                  ),
                ],
              ),
            ),
            DecisionOption(
              id: 'no_depressed_mood',
              text: 'Hayır',
              nextNode: DecisionNode(
                id: 'alternative_diagnosis',
                question: 'Sonuç: Alternatif teşhis düşünülmeli',
                type: DecisionNodeType.outcome,
                options: [],
              ),
            ),
          ],
        ),
        tags: ['mood_disorders', 'depression'],
        source: 'DSM-5',
        version: '1.0',
        lastUpdated: DateTime.now(),
        isActive: true,
      ),
    ]);
  }

  Future<void> _loadDrugInteractions() async {
    // Common psychiatric drug interactions
    _drugInteractions.addAll([
      DrugInteractionSimulation(
        id: 'ssri_maoi_interaction',
        medicationIds: ['ssri_sertraline', 'maoi_phenelzine'],
        interactions: [
          DrugInteraction(
            id: 'interaction_1',
            drug1Id: 'ssri_sertraline',
            drug2Id: 'maoi_phenelzine',
            drug1Name: 'SSRI (Sertraline)',
            drug2Name: 'MAOI (Phenelzine)',
            type: InteractionType.pharmacodynamic,
            severity: InteractionSeverity.major,
            mechanism: 'Serotonin sendromu riski',
            description: 'Yüksek risk',
            symptoms: [
              'Yüksek ateş',
              'Ajitasyon',
              'Delirium',
              'Koma',
            ],
            recommendations: [
              'Kesinlikle birlikte kullanılmamalı',
              '14 gün washout period',
              'Alternatif antidepresan seçilmeli',
            ],
          ),
        ],
        overallSeverity: InteractionSeverity.major,
        warnings: ['Serotonin sendromu riski'],
        recommendations: [
          'Kesinlikle birlikte kullanılmamalı',
          '14 gün washout period',
          'Alternatif antidepresan seçilmeli',
        ],
        simulationDate: DateTime.now(),
        patientId: 'demo_patient_001',
        clinicianId: 'demo_clinician_001',
      ),
      DrugInteractionSimulation(
        id: 'lithium_diuretic_interaction',
        medicationIds: ['lithium', 'thiazide_diuretic'],
        interactions: [
          DrugInteraction(
            id: 'interaction_2',
            drug1Id: 'lithium',
            drug2Id: 'thiazide_diuretic',
            drug1Name: 'Lithium',
            drug2Name: 'Thiazide Diuretic',
            type: InteractionType.pharmacokinetic,
            severity: InteractionSeverity.moderate,
            mechanism: 'Lithium klirensinde azalma',
            description: 'Orta risk',
            symptoms: [
              'Lithium toksisitesi',
              'Böbrek fonksiyon bozukluğu',
              'Nörolojik belirtiler',
            ],
            recommendations: [
              'Lithium dozu %50 azaltılmalı',
              'Serum lithium seviyesi sık takip',
              'Böbrek fonksiyonları izlenmeli',
            ],
          ),
        ],
        overallSeverity: InteractionSeverity.moderate,
        warnings: ['Lithium toksisitesi riski'],
        recommendations: [
          'Lithium dozu %50 azaltılmalı',
          'Serum lithium seviyesi sık takip',
          'Böbrek fonksiyonları izlenmeli',
        ],
        simulationDate: DateTime.now(),
        patientId: 'demo_patient_001',
        clinicianId: 'demo_clinician_001',
      ),
    ]);
  }

  Future<void> _loadPharmacogeneticProfiles() async {
    // CYP450 enzyme profiles
    _pharmacogeneticProfiles.addAll([
      PharmacogeneticProfile(
        id: 'cyp2d6_poor_metabolizer',
        patientId: 'demo_patient_001',
        testDate: DateTime.now(),
                  variants: [
            GeneticVariant(
              id: 'variant_1',
              gene: 'CYP2D6',
              variant: 'Poor Metabolizer',
              rsId: 'rs3892097',
              chromosome: '22',
              position: 42526694,
              reference: 'G',
              alternate: 'A',
              genotype: 'AA',
              phenotype: 'Poor Metabolizer',
              clinicalSignificance: 'SSRI metabolizmasında yavaşlama',
            ),
          ],
          drugMetabolisms: [
            DrugMetabolism(
              id: 'dm_1',
              drugId: 'sertraline',
              drugName: 'Sertraline',
              gene: 'CYP2D6',
              status: MetabolismStatus.poor,
              phenotype: 'Poor Metabolizer',
              recommendation: 'Başlangıç dozu %50 azaltılmalı',
              alternatives: ['Escitalopram', 'Venlafaxine'],
            ),
          ],
          recommendations: [
            'Başlangıç dozu %50 azaltılmalı',
            'Yan etki yakından izlenmeli',
            'Alternatif ilaç düşünülmeli',
          ],
      ),
    ]);
  }

  Future<void> _loadTreatmentAlgorithms() async {
    // Treatment resistance algorithms
    _treatmentAlgorithms.addAll([
                              TreatmentResistanceAlgorithm(
                  id: 'depression_treatment_resistance',
                  name: 'Depresyon Tedavi Direnci Algoritması',
                  description: 'SSRI direnci sonrası tedavi seçenekleri',
                  criteria: ['HAM-D skorunda %50 azalma yok'],
                  source: 'Clinical Guidelines',
                  version: '1.0',
        steps: [
          TreatmentStep(
            id: 'step1',
            stepNumber: 1,
            name: 'SSRI dozunu maksimuma çıkar',
            description: 'SSRI dozunu maksimuma çıkar',
            medications: ['Sertraline'],
            therapies: [],
            duration: DurationPeriod(value: 4, unit: DurationUnit.weeks),
            successCriteria: ['HAM-D skorunda %50 azalma'],
            failureCriteria: ['HAM-D skorunda %50 azalma yok'],
          ),
          TreatmentStep(
            id: 'step2',
            stepNumber: 2,
            name: 'Farklı SSRI dene',
            description: 'Farklı SSRI dene',
            medications: ['Escitalopram'],
            therapies: [],
            duration: DurationPeriod(value: 6, unit: DurationUnit.weeks),
            successCriteria: ['HAM-D skorunda %50 azalma'],
            failureCriteria: ['HAM-D skorunda %50 azalma yok'],
          ),
          TreatmentStep(
            id: 'step3',
            stepNumber: 3,
            name: 'SNRI (Venlafaxine) ekle',
            description: 'SNRI (Venlafaxine) ekle',
            medications: ['Venlafaxine'],
            therapies: [],
            duration: DurationPeriod(value: 8, unit: DurationUnit.weeks),
            successCriteria: ['HAM-D skorunda %50 azalma'],
            failureCriteria: ['HAM-D skorunda %50 azalma yok'],
          ),
          TreatmentStep(
            id: 'step4',
            stepNumber: 4,
            name: 'Atypical antidepresan (Mirtazapine)',
            description: 'Atypical antidepresan (Mirtazapine)',
            medications: ['Mirtazapine'],
            therapies: [],
            duration: DurationPeriod(value: 8, unit: DurationUnit.weeks),
            successCriteria: ['HAM-D skorunda %50 azalma'],
            failureCriteria: ['HAM-D skorunda %50 azalma yok'],
          ),
          TreatmentStep(
            id: 'step5',
            stepNumber: 5,
            name: 'MAOI veya ECT düşün',
            description: 'MAOI veya ECT düşün',
            medications: ['Phenelzine'],
            therapies: ['ECT'],
            duration: DurationPeriod(value: 12, unit: DurationUnit.weeks),
            successCriteria: ['HAM-D skorunda %50 azalma'],
            failureCriteria: ['HAM-D skorunda %50 azalma yok'],
          ),
        ],
        isActive: true,
      ),
    ]);
  }

  Future<CDSSResult> evaluateDecisionTree({
    required String treeId,
    required Map<String, String> patientResponses,
  }) async {
    final tree = _decisionTrees.firstWhere((t) => t.id == treeId);
    final rootNode = tree.rootNode;
    
    return _traverseDecisionTree(rootNode, patientResponses, tree);
  }

  CDSSResult _traverseDecisionTree(
    DecisionNode node,
    Map<String, String> responses,
    ClinicalDecisionTree tree,
  ) {
    if (node.type == DecisionNodeType.outcome) {
              return CDSSResult(
          id: 'result_${DateTime.now().millisecondsSinceEpoch}',
          patientId: 'patient_1',
          clinicianId: 'clinician_1',
          analysisDate: DateTime.now(),
          analysisType: 'decision_tree',
          symptoms: ['Depressed mood', 'Anhedonia'],
          diagnosis: node.question,
          recommendations: [],
          drugInteractions: [],
          confidence: 0.8,
          reasoning: node.options.map((o) => o.text).toList(),
          warnings: [],
        );
    }

    final response = responses[node.id];
    if (response == null) {
      return CDSSResult(
        id: 'missing_info_${DateTime.now().millisecondsSinceEpoch}',
        patientId: 'unknown',
        clinicianId: 'unknown',
        analysisDate: DateTime.now(),
        analysisType: 'decision_tree',
        symptoms: [],
        diagnosis: 'Eksik bilgi',
        recommendations: [],
        drugInteractions: [],
        confidence: 0.0,
        reasoning: ['Hasta yanıtları eksik'],
        warnings: [],
      );
    }

    final selectedOption = node.options.firstWhere((o) => o.id == response);
          final nextNode = selectedOption.nextNode;
      if (nextNode == null) {
        return CDSSResult(
          id: 'result_${DateTime.now().millisecondsSinceEpoch}',
          patientId: 'patient_1',
          clinicianId: 'clinician_1',
          analysisDate: DateTime.now(),
          analysisType: 'decision_tree',
          symptoms: ['Depressed mood', 'Anhedonia'],
          diagnosis: 'Decision tree completed',
          recommendations: [],
          drugInteractions: [],
          confidence: 0.8,
          reasoning: selectedOption.recommendations ?? [],
          warnings: [],
        );
      }
    
    return _traverseDecisionTree(nextNode, responses, tree);
  }

  Future<List<DrugInteraction>> checkDrugInteractions({
    required List<String> medications,
  }) async {
    final interactions = <DrugInteraction>[];
    
    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final interaction = _findDrugInteraction(medications[i], medications[j]);
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }
    
    return interactions;
  }

  DrugInteraction? _findDrugInteraction(String drug1, String drug2) {
    try {
      final simulation = _drugInteractions.firstWhere((interaction) {
        return interaction.medicationIds.contains(drug1) && interaction.medicationIds.contains(drug2);
      });
      return simulation.interactions.first;
    } catch (e) {
      return null;
    }
  }

  Future<TreatmentRecommendation> generateTreatmentRecommendation({
    required String diagnosis,
    required String severity,
    required List<String> contraindications,
    required String? pharmacogeneticProfile,
  }) async {
    // AI-powered treatment recommendation
    final prompt = '''
    Diagnosis: $diagnosis
    Severity: $severity
    Contraindications: ${contraindications.join(', ')}
    Pharmacogenetic Profile: ${pharmacogeneticProfile ?? 'Unknown'}
    
    Please provide treatment recommendations including:
    1. First-line medications
    2. Alternative options
    3. Dosing considerations
    4. Monitoring requirements
    5. Expected timeline
    ''';

    try {
      final aiResponse = await _aiService!.generateResponse(prompt);
      
      return TreatmentRecommendation(
        id: _generateId(),
        patientId: 'patient_1',
        clinicianId: 'clinician_1',
        recommendationDate: DateTime.now(),
        diagnosis: diagnosis,
        symptoms: ['Depressed mood', 'Anhedonia'],
        options: [
          TreatmentOption(
            id: 'to_1',
            name: 'Standard Treatment',
            type: 'medication',
            description: 'AI-recommended treatment',
            medications: ['Sertraline'],
            therapies: [],
            duration: DurationPeriod(value: 8, unit: DurationUnit.weeks),
            efficacy: 0.7,
            sideEffects: ['Nausea', 'Insomnia'],
            contraindications: contraindications,
            cost: 50.0,
            evidenceLevel: 'A',
          ),
        ],
        confidence: 0.85,
        reasoning: _parseAIRecommendations(aiResponse),
        contraindications: contraindications,
        warnings: ['Monitor for side effects'],
      );
    } catch (e) {
      return TreatmentRecommendation(
        id: _generateId(),
        patientId: 'patient_1',
        clinicianId: 'clinician_1',
        recommendationDate: DateTime.now(),
        diagnosis: diagnosis,
        symptoms: ['Depressed mood', 'Anhedonia'],
        options: [
          TreatmentOption(
            id: 'to_1',
            name: 'Standard Treatment',
            type: 'medication',
            description: 'Fallback treatment protocol',
            medications: ['Sertraline'],
            therapies: [],
            duration: DurationPeriod(value: 8, unit: DurationUnit.weeks),
            efficacy: 0.6,
            sideEffects: ['Nausea', 'Insomnia'],
            contraindications: contraindications,
            cost: 50.0,
            evidenceLevel: 'B',
          ),
        ],
        confidence: 0.5,
        reasoning: [
          'AI servisi mevcut değil',
          'Standart tedavi protokolleri uygulanmalı',
        ],
        contraindications: contraindications,
        warnings: ['Monitor for side effects'],
      );
    }
  }

  List<String> _parseAIRecommendations(String aiResponse) {
    // Simple parsing - in production, use more sophisticated NLP
    final lines = aiResponse.split('\n');
    return lines.where((line) => line.trim().isNotEmpty).toList();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
