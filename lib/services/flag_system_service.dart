import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/flag_system_models.dart';
import '../utils/ai_logger.dart';

/// Flag Sistemi Servisi
/// Kriz, intihar riski ve ajitasyon durumlarını yönetir
class FlagSystemService extends ChangeNotifier {
  static final FlagSystemService _instance = FlagSystemService._internal();
  factory FlagSystemService() => _instance;
  FlagSystemService._internal();

  final AILogger _logger = AILogger();

  // Durum listeleri
  final List<CrisisFlag> _crisisFlags = <CrisisFlag>[];
  final List<SuicideRiskAssessment> _suicideAssessments = <SuicideRiskAssessment>[];
  final List<AgitationAssessment> _agitationAssessments = <AgitationAssessment>[];
  final List<SafetyPlan> _safetyPlans = <SafetyPlan>[];
  final List<CrisisInterventionProtocol> _interventionProtocols = <CrisisInterventionProtocol>[];
  final List<FlagHistory> _flagHistory = <FlagHistory>[];

  // Streamler
  final StreamController<CrisisFlag> _crisisFlagController = StreamController<CrisisFlag>.broadcast();
  final StreamController<SuicideRiskAssessment> _suicideAssessmentController =
      StreamController<SuicideRiskAssessment>.broadcast();
  final StreamController<AgitationAssessment> _agitationAssessmentController =
      StreamController<AgitationAssessment>.broadcast();

  // Getters
  List<CrisisFlag> get crisisFlags => List.unmodifiable(_crisisFlags);
  List<SuicideRiskAssessment> get suicideAssessments => List.unmodifiable(_suicideAssessments);
  List<AgitationAssessment> get agitationAssessments => List.unmodifiable(_agitationAssessments);
  List<SafetyPlan> get safetyPlans => List.unmodifiable(_safetyPlans);
  List<CrisisInterventionProtocol> get interventionProtocols => List.unmodifiable(_interventionProtocols);
  List<FlagHistory> get flagHistory => List.unmodifiable(_flagHistory);

  Stream<CrisisFlag> get crisisFlagStream => _crisisFlagController.stream;
  Stream<SuicideRiskAssessment> get suicideAssessmentStream => _suicideAssessmentController.stream;
  Stream<AgitationAssessment> get agitationAssessmentStream => _agitationAssessmentController.stream;

  /// Başlatma
  Future<void> initialize() async {
    _logger.info('FlagSystemService initializing...', context: 'FlagSystemService');
    _loadMockData();
    _loadInterventionProtocols();
    _logger.info('FlagSystemService initialized', context: 'FlagSystemService');
  }

  void _loadMockData() {
    // Örnek kriz
    _crisisFlags.add(
      CrisisFlag(
        id: 'flag_001',
        patientId: 'patient_001',
        clinicianId: 'clinician_001',
        type: CrisisType.suicidalIdeation,
        severity: CrisisSeverity.high,
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Hasta intihar düşüncesi belirtti',
        symptoms: const ['Umutsuzluk', 'Veda mesajları'],
        riskFactors: const ['Geçmiş girişim', 'Depresyon'],
        immediateActions: const ['Güvenlik planı', 'Yakın takip'],
        status: FlagStatus.active,
        metadata: const {},
      ),
    );

    // Örnek intihar risk değerlendirmesi
    _suicideAssessments.add(
      SuicideRiskAssessment(
        id: 'assessment_001',
        patientId: 'patient_001',
        clinicianId: 'clinician_001',
        assessmentDate: DateTime.now().subtract(const Duration(hours: 2)),
        suicidalIdeationScore: 4,
        suicidalBehaviorScore: 2,
        lethalityScore: 2,
        riskFactors: const ['Depresyon'],
        protectiveFactors: const ['Aile desteği'],
        riskLevel: 'Yüksek',
        clinicalImpression: 'Yüksek risk',
        safetyPlan: const ['Güvenli ortam', 'Acil iletişim'],
        followUpActions: const ['Günlük takip'],
        metadata: const {},
      ),
    );

    // Örnek ajitasyon değerlendirmesi
    _agitationAssessments.add(
      AgitationAssessment(
        id: 'agitation_001',
        patientId: 'patient_002',
        clinicianId: 'clinician_002',
        assessmentDate: DateTime.now().subtract(const Duration(minutes: 30)),
        motorAgitationScore: 4,
        verbalAgitationScore: 3,
        aggressiveBehaviorScore: 2,
        impulsivityScore: 3,
        agitationLevel: 'Şiddetli',
        triggers: const ['Stres'],
        calmingTechniques: const ['Derin nefes', 'Güvenli ortam'],
        interventionPlan: 'Sakinleştirici ve gözlem',
        metadata: const {},
      ),
    );

    // Örnek güvenlik planı
    _safetyPlans.add(
      SafetyPlan(
        id: 'safety_001',
        patientId: 'patient_001',
        clinicianId: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastUpdated: null,
        warningSigns: const ['İzolasyon'],
        internalCopingStrategies: const ['Meditasyon'],
        socialSupport: const ['Aile', 'Arkadaş'],
        professionalHelp: const ['Klinisyen', 'Kriz hattı'],
        environmentalSafety: const ['İlaç güvenliği'],
        crisisIntervention: const ['Acil iletişim'],
        emergencyContact: '911',
        isActive: true,
        metadata: const {},
      ),
    );
  }

  void _loadInterventionProtocols() {
    _interventionProtocols.add(
      CrisisInterventionProtocol(
        id: 'protocol_001',
        crisisType: CrisisType.suicidalIdeation,
        severity: CrisisSeverity.high,
        steps: <InterventionStep>[
          InterventionStep(
            id: 'step_001',
            stepNumber: 1,
            description: 'Güvenlik değerlendirmesi',
            action: 'Hastanın güvenliğini sağla',
            responsiblePerson: 'Klinisyen',
            estimatedTime: 5,
            prerequisites: const [],
            successIndicators: const ['Hasta güvende'],
            failureIndicators: const ['Risk devam ediyor'],
            metadata: const {},
          ),
        ],
        requiredResources: const ['Kriz hattı bilgileri'],
        teamMembers: const ['Klinisyen', 'Hemşire'],
        estimatedDuration: 20,
        successCriteria: 'Hasta güvende',
        escalationTriggers: const ['Risk yükselmesi'],
        metadata: const {},
      ),
    );

    // Şiddetli ajitasyon için protokol
    _interventionProtocols.add(
      CrisisInterventionProtocol(
        id: 'protocol_002',
        crisisType: CrisisType.severeAgitation,
        severity: CrisisSeverity.critical,
        steps: <InterventionStep>[
          InterventionStep(
            id: 'step_010',
            stepNumber: 1,
            description: 'Çevresel güvenlik',
            action: 'Ortamı güvenli hale getir',
            responsiblePerson: 'Güvenlik',
            estimatedTime: 3,
            prerequisites: const [],
            successIndicators: const ['Ortam güvenli'],
            failureIndicators: const ['Tehlike devam ediyor'],
            metadata: const {},
          ),
          InterventionStep(
            id: 'step_011',
            stepNumber: 2,
            description: 'Sakinleştirici uygulama',
            action: 'Uygun farmakolojik müdahale',
            responsiblePerson: 'Hemşire',
            estimatedTime: 10,
            prerequisites: const ['Ortam güvenli'],
            successIndicators: const ['Ajitasyon azaldı'],
            failureIndicators: const ['Ajitasyon sürüyor'],
            metadata: const {},
          ),
        ],
        requiredResources: const ['Sakinleştirici ilaçlar', 'Güvenlik ekipmanı'],
        teamMembers: const ['Klinisyen', 'Hemşire', 'Güvenlik'],
        estimatedDuration: 20,
        successCriteria: 'Hasta sakin ve güvenli',
        escalationTriggers: const ['Ajitasyon artışı'],
        metadata: const {},
      ),
    );
  }

  // İşlevler
  Future<CrisisFlag> createCrisisFlag({
    required String patientId,
    required String clinicianId,
    required CrisisType type,
    required CrisisSeverity severity,
    required String description,
    required List<String> symptoms,
    required List<String> riskFactors,
    required List<String> immediateActions,
  }) async {
    final flag = CrisisFlag(
      id: 'flag_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      type: type,
      severity: severity,
      detectedAt: DateTime.now(),
      description: description,
      symptoms: symptoms,
      riskFactors: riskFactors,
      immediateActions: immediateActions,
      status: FlagStatus.active,
      metadata: const {},
    );

    _crisisFlags.add(flag);
    _flagHistory.add(
      FlagHistory(
        id: 'history_${DateTime.now().millisecondsSinceEpoch}',
        flagId: flag.id,
        patientId: flag.patientId,
        timestamp: DateTime.now(),
        previousStatus: flag.status,
        newStatus: flag.status,
        changeReason: 'Yeni kriz flag\'ı oluşturuldu',
        notes: null,
        changedBy: 'system',
        metadata: const {},
      ),
    );

    _crisisFlagController.add(flag);
    notifyListeners();
    _logger.info('Crisis flag created: ${flag.id}', context: 'FlagSystemService');
    return flag;
  }

  Future<void> updateFlagStatus(String flagId, FlagStatus newStatus, String reason) async {
    final index = _crisisFlags.indexWhere((f) => f.id == flagId);
    if (index == -1) {
      throw Exception('Flag not found: $flagId');
    }

    final current = _crisisFlags[index];
    final updated = CrisisFlag(
      id: current.id,
      patientId: current.patientId,
      clinicianId: current.clinicianId,
      type: current.type,
      severity: current.severity,
      detectedAt: current.detectedAt,
      resolvedAt: newStatus == FlagStatus.resolved ? DateTime.now() : current.resolvedAt,
      description: current.description,
      symptoms: current.symptoms,
      riskFactors: current.riskFactors,
      immediateActions: current.immediateActions,
      resolutionNotes: newStatus == FlagStatus.resolved ? reason : current.resolutionNotes,
      status: newStatus,
      metadata: current.metadata,
    );

    _crisisFlags[index] = updated;

    _flagHistory.add(
      FlagHistory(
        id: 'history_${DateTime.now().millisecondsSinceEpoch}',
        flagId: updated.id,
        patientId: updated.patientId,
        timestamp: DateTime.now(),
        previousStatus: current.status,
        newStatus: updated.status,
        changeReason: reason,
        notes: null,
        changedBy: 'system',
        metadata: const {},
      ),
    );

    notifyListeners();
    _logger.info('Crisis flag updated: $flagId -> $newStatus', context: 'FlagSystemService');
  }

  // Eksik API: createSuicideRiskAssessment
  Future<SuicideRiskAssessment> createSuicideRiskAssessment({
    required String patientId,
    required String clinicianId,
    required int suicidalIdeationScore,
    required int suicidalBehaviorScore,
    required int lethalityScore,
    required List<String> riskFactors,
    required List<String> protectiveFactors,
    required String clinicalImpression,
  }) async {
    final total = suicidalIdeationScore + suicidalBehaviorScore + lethalityScore;
    late final String riskLevel;
    if (total <= 3) {
      riskLevel = 'Düşük';
    } else if (total <= 6) {
      riskLevel = 'Orta';
    } else if (total <= 9) {
      riskLevel = 'Yüksek';
    } else {
      riskLevel = 'Kritik';
    }

    final assessment = SuicideRiskAssessment(
      id: 'assessment_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      assessmentDate: DateTime.now(),
      suicidalIdeationScore: suicidalIdeationScore,
      suicidalBehaviorScore: suicidalBehaviorScore,
      lethalityScore: lethalityScore,
      riskFactors: riskFactors,
      protectiveFactors: protectiveFactors,
      riskLevel: riskLevel,
      clinicalImpression: clinicalImpression,
      safetyPlan: _safetyPlanForRisk(riskLevel),
      followUpActions: _followUpsForRisk(riskLevel),
      metadata: const {},
    );

    _suicideAssessments.add(assessment);

    if (riskLevel == 'Yüksek' || riskLevel == 'Kritik') {
      await createCrisisFlag(
        patientId: patientId,
        clinicianId: clinicianId,
        type: CrisisType.suicidalIdeation,
        severity: riskLevel == 'Kritik' ? CrisisSeverity.critical : CrisisSeverity.high,
        description: 'İntihar riski: $riskLevel',
        symptoms: const ['İntihar düşüncesi'],
        riskFactors: riskFactors,
        immediateActions: const ['Güvenlik planı', 'Yakın takip'],
      );
    }

    _suicideAssessmentController.add(assessment);
    notifyListeners();
    return assessment;
  }

  // Eksik API: createAgitationAssessment
  Future<AgitationAssessment> createAgitationAssessment({
    required String patientId,
    required String clinicianId,
    required int motorAgitationScore,
    required int verbalAgitationScore,
    required int aggressiveBehaviorScore,
    required int impulsivityScore,
    required List<String> triggers,
  }) async {
    final total = motorAgitationScore + verbalAgitationScore + aggressiveBehaviorScore + impulsivityScore;
    late final String level;
    if (total <= 5) {
      level = 'Hafif';
    } else if (total <= 10) {
      level = 'Orta';
    } else if (total < 15) {
      level = 'Şiddetli';
    } else {
      level = 'Kritik';
    }

    final assessment = AgitationAssessment(
      id: 'agitation_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      assessmentDate: DateTime.now(),
      motorAgitationScore: motorAgitationScore,
      verbalAgitationScore: verbalAgitationScore,
      aggressiveBehaviorScore: aggressiveBehaviorScore,
      impulsivityScore: impulsivityScore,
      agitationLevel: level,
      triggers: triggers,
      calmingTechniques: _calmingTechniques(level),
      interventionPlan: _interventionForLevel(level),
      metadata: const {},
    );

    _agitationAssessments.add(assessment);

    if (level == 'Şiddetli' || level == 'Kritik') {
      await createCrisisFlag(
        patientId: patientId,
        clinicianId: clinicianId,
        type: CrisisType.severeAgitation,
        severity: level == 'Kritik' ? CrisisSeverity.critical : CrisisSeverity.high,
        description: 'Ajitasyon: $level',
        symptoms: const ['Ajitasyon'],
        riskFactors: triggers,
        immediateActions: const ['Güvenlik', 'Sakinleştirici'],
      );
    }

    _agitationAssessmentController.add(assessment);
    notifyListeners();
    return assessment;
  }

  // Eksik API: createSafetyPlan
  Future<SafetyPlan> createSafetyPlan({
    required String patientId,
    required String clinicianId,
    required List<String> warningSigns,
    required List<String> internalCopingStrategies,
    required List<String> socialSupport,
    required String emergencyContact,
  }) async {
    final plan = SafetyPlan(
      id: 'safety_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      createdAt: DateTime.now(),
      lastUpdated: null,
      warningSigns: warningSigns,
      internalCopingStrategies: internalCopingStrategies,
      socialSupport: socialSupport,
      professionalHelp: const ['Klinisyen', 'Kriz hattı', 'Acil servis'],
      environmentalSafety: const ['Silah ve kesici alet güvenliği', 'İlaç güvenliği'],
      crisisIntervention: const ['Acil iletişim', 'Güvenlik kontrolü'],
      emergencyContact: emergencyContact,
      isActive: true,
      metadata: const {},
    );

    _safetyPlans.add(plan);
    notifyListeners();
    return plan;
  }

  // Yardımcılar
  List<String> _safetyPlanForRisk(String level) {
    switch (level) {
      case 'Düşük':
        return const ['Rutin takip', 'Kendini izleme'];
      case 'Orta':
        return const ['Haftalık takip', 'Güvenlik planı'];
      case 'Yüksek':
        return const ['Günlük takip', 'Acil iletişim'];
      case 'Kritik':
        return const ['Sürekli gözlem', 'Acil müdahale'];
      default:
        return const ['Temel güvenlik önlemleri'];
    }
  }

  List<String> _followUpsForRisk(String level) {
    switch (level) {
      case 'Düşük':
        return const ['Aylık kontrol'];
      case 'Orta':
        return const ['Haftalık kontrol'];
      case 'Yüksek':
        return const ['Günlük kontrol'];
      case 'Kritik':
        return const ['Sürekli gözlem'];
      default:
        return const ['Rutin takip'];
    }
  }

  List<String> _calmingTechniques(String level) {
    switch (level) {
      case 'Hafif':
        return const ['Derin nefes', 'Progresif gevşeme'];
      case 'Orta':
        return const ['Güvenli ortam', 'Sakinleştirici konuşma'];
      case 'Şiddetli':
        return const ['Güvenlik önlemleri', 'Sakinleştirici ilaç'];
      case 'Kritik':
        return const ['Acil güvenlik', 'Tıbbi yardım'];
      default:
        return const ['Temel yöntemler'];
    }
  }

  String _interventionForLevel(String level) {
    switch (level) {
      case 'Hafif':
        return 'Gözlem ve destek';
      case 'Orta':
        return 'Yakın takip ve müdahale';
      case 'Şiddetli':
        return 'Güvenlik önlemleri ve sakinleştirici';
      case 'Kritik':
        return 'Acil güvenlik ve tıbbi müdahale';
      default:
        return 'Temel müdahale';
    }
  }

  List<CrisisFlag> getActiveFlags() {
    final active = _crisisFlags.where((f) => f.status == FlagStatus.active).toList();
    const order = <CrisisSeverity, int>{
      CrisisSeverity.emergency: 5,
      CrisisSeverity.critical: 4,
      CrisisSeverity.high: 3,
      CrisisSeverity.moderate: 2,
      CrisisSeverity.low: 1,
    };
    active.sort((a, b) => (order[b.severity] ?? 0).compareTo(order[a.severity] ?? 0));
    return active;
  }

  List<CrisisFlag> getFlagsForPatient(String patientId) =>
      _crisisFlags.where((f) => f.patientId == patientId).toList();

  List<CrisisFlag> getFlagsForClinician(String clinicianId) =>
      _crisisFlags.where((f) => f.clinicianId == clinicianId).toList();

  Map<String, dynamic> getFlagStatistics() {
    final total = _crisisFlags.length;
    final active = _crisisFlags.where((f) => f.status == FlagStatus.active).length;
    final resolved = _crisisFlags.where((f) => f.status == FlagStatus.resolved).length;

    final severityDist = <String, int>{};
    for (final f in _crisisFlags) {
      final key = f.severity.toString().split('.').last;
      severityDist[key] = (severityDist[key] ?? 0) + 1;
    }

    final typeDist = <String, int>{};
    for (final f in _crisisFlags) {
      final key = f.type.toString().split('.').last;
      typeDist[key] = (typeDist[key] ?? 0) + 1;
    }

    return {
      'totalFlags': total,
      'activeFlags': active,
      'resolvedFlags': resolved,
      'severityDistribution': severityDist,
      'typeDistribution': typeDist,
    };
  }

  @override
  void dispose() {
    _crisisFlagController.close();
    _suicideAssessmentController.close();
    _agitationAssessmentController.close();
    super.dispose();
  }
}
