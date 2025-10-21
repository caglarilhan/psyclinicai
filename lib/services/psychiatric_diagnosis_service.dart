import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/psychiatric_diagnosis_models.dart';

class PsychiatricDiagnosisService {
  static final PsychiatricDiagnosisService _instance = PsychiatricDiagnosisService._internal();
  factory PsychiatricDiagnosisService() => _instance;
  PsychiatricDiagnosisService._internal();

  final List<PsychiatricDiagnosis> _diagnoses = [];
  final List<TreatmentPlan> _treatmentPlans = [];
  final List<TreatmentProgress> _progresses = [];
  final List<PsychiatricConsultation> _consultations = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadDiagnoses();
    await _loadTreatmentPlans();
    await _loadProgresses();
    await _loadConsultations();
  }

  // Load diagnoses from storage
  Future<void> _loadDiagnoses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final diagnosesJson = prefs.getStringList('psychiatric_diagnoses') ?? [];
      _diagnoses.clear();
      
      for (final diagnosisJson in diagnosesJson) {
        final diagnosis = PsychiatricDiagnosis.fromJson(jsonDecode(diagnosisJson));
        _diagnoses.add(diagnosis);
      }
    } catch (e) {
      print('Error loading psychiatric diagnoses: $e');
      _diagnoses.clear();
    }
  }

  // Save diagnoses to storage
  Future<void> _saveDiagnoses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final diagnosesJson = _diagnoses
          .map((diagnosis) => jsonEncode(diagnosis.toJson()))
          .toList();
      await prefs.setStringList('psychiatric_diagnoses', diagnosesJson);
    } catch (e) {
      print('Error saving psychiatric diagnoses: $e');
    }
  }

  // Load treatment plans from storage
  Future<void> _loadTreatmentPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treatmentPlansJson = prefs.getStringList('treatment_plans') ?? [];
      _treatmentPlans.clear();
      
      for (final treatmentPlanJson in treatmentPlansJson) {
        final treatmentPlan = TreatmentPlan.fromJson(jsonDecode(treatmentPlanJson));
        _treatmentPlans.add(treatmentPlan);
      }
    } catch (e) {
      print('Error loading treatment plans: $e');
      _treatmentPlans.clear();
    }
  }

  // Save treatment plans to storage
  Future<void> _saveTreatmentPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treatmentPlansJson = _treatmentPlans
          .map((treatmentPlan) => jsonEncode(treatmentPlan.toJson()))
          .toList();
      await prefs.setStringList('treatment_plans', treatmentPlansJson);
    } catch (e) {
      print('Error saving treatment plans: $e');
    }
  }

  // Load progresses from storage
  Future<void> _loadProgresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressesJson = prefs.getStringList('treatment_progresses') ?? [];
      _progresses.clear();
      
      for (final progressJson in progressesJson) {
        final progress = TreatmentProgress.fromJson(jsonDecode(progressJson));
        _progresses.add(progress);
      }
    } catch (e) {
      print('Error loading treatment progresses: $e');
      _progresses.clear();
    }
  }

  // Save progresses to storage
  Future<void> _saveProgresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressesJson = _progresses
          .map((progress) => jsonEncode(progress.toJson()))
          .toList();
      await prefs.setStringList('treatment_progresses', progressesJson);
    } catch (e) {
      print('Error saving treatment progresses: $e');
    }
  }

  // Load consultations from storage
  Future<void> _loadConsultations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultationsJson = prefs.getStringList('psychiatric_consultations') ?? [];
      _consultations.clear();
      
      for (final consultationJson in consultationsJson) {
        final consultation = PsychiatricConsultation.fromJson(jsonDecode(consultationJson));
        _consultations.add(consultation);
      }
    } catch (e) {
      print('Error loading psychiatric consultations: $e');
      _consultations.clear();
    }
  }

  // Save consultations to storage
  Future<void> _saveConsultations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultationsJson = _consultations
          .map((consultation) => jsonEncode(consultation.toJson()))
          .toList();
      await prefs.setStringList('psychiatric_consultations', consultationsJson);
    } catch (e) {
      print('Error saving psychiatric consultations: $e');
    }
  }

  // Make psychiatric diagnosis
  Future<PsychiatricDiagnosis> makeDiagnosis({
    required String patientId,
    required String psychiatristId,
    required String diagnosis,
    required String icdCode,
    required String dsmCode,
    required DiagnosisType type,
    required DiagnosisSeverity severity,
    String? differentialDiagnosis,
    String? rationale,
    String? prognosis,
    String? treatmentPlan,
    String? notes,
  }) async {
    final psychiatricDiagnosis = PsychiatricDiagnosis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      psychiatristId: psychiatristId,
      diagnosis: diagnosis,
      icdCode: icdCode,
      dsmCode: dsmCode,
      type: type,
      severity: severity,
      diagnosedAt: DateTime.now(),
      differentialDiagnosis: differentialDiagnosis,
      rationale: rationale,
      prognosis: prognosis,
      treatmentPlan: treatmentPlan,
      notes: notes,
    );

    _diagnoses.add(psychiatricDiagnosis);
    await _saveDiagnoses();

    return psychiatricDiagnosis;
  }

  // Create treatment plan
  Future<TreatmentPlan> createTreatmentPlan({
    required String patientId,
    required String psychiatristId,
    required String diagnosisId,
    required String title,
    required String description,
    required TreatmentType type,
    required TreatmentPhase phase,
    required DateTime startDate,
    DateTime? endDate,
    List<String>? goals,
    List<String>? interventions,
    List<String>? medications,
    List<String>? therapies,
    String? monitoring,
    String? notes,
  }) async {
    final treatmentPlan = TreatmentPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      psychiatristId: psychiatristId,
      diagnosisId: diagnosisId,
      title: title,
      description: description,
      type: type,
      phase: phase,
      startDate: startDate,
      endDate: endDate,
      goals: goals ?? [],
      interventions: interventions ?? [],
      medications: medications ?? [],
      therapies: therapies ?? [],
      monitoring: monitoring,
      notes: notes,
    );

    _treatmentPlans.add(treatmentPlan);
    await _saveTreatmentPlans();

    return treatmentPlan;
  }

  // Record treatment progress
  Future<TreatmentProgress> recordProgress({
    required String treatmentPlanId,
    required String patientId,
    required String psychiatristId,
    required DateTime date,
    required ProgressType type,
    required String parameter,
    required String value,
    required String unit,
    String? notes,
    String? actionTaken,
  }) async {
    final progress = TreatmentProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      treatmentPlanId: treatmentPlanId,
      patientId: patientId,
      psychiatristId: psychiatristId,
      date: date,
      type: type,
      parameter: parameter,
      value: value,
      unit: unit,
      notes: notes,
      actionTaken: actionTaken,
    );

    _progresses.add(progress);
    await _saveProgresses();

    return progress;
  }

  // Request psychiatric consultation
  Future<PsychiatricConsultation> requestConsultation({
    required String patientId,
    required String requestingPhysicianId,
    required String consultingPsychiatristId,
    required String reason,
    required String question,
    String? notes,
  }) async {
    final consultation = PsychiatricConsultation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      requestingPhysicianId: requestingPhysicianId,
      consultingPsychiatristId: consultingPsychiatristId,
      reason: reason,
      question: question,
      requestedAt: DateTime.now(),
      notes: notes,
    );

    _consultations.add(consultation);
    await _saveConsultations();

    return consultation;
  }

  // Complete psychiatric consultation
  Future<bool> completeConsultation({
    required String consultationId,
    required String assessment,
    required String recommendations,
    String? followUp,
    String? notes,
  }) async {
    try {
      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index == -1) return false;

      final consultation = _consultations[index];
      final updatedConsultation = PsychiatricConsultation(
        id: consultation.id,
        patientId: consultation.patientId,
        requestingPhysicianId: consultation.requestingPhysicianId,
        consultingPsychiatristId: consultation.consultingPsychiatristId,
        reason: consultation.reason,
        question: consultation.question,
        requestedAt: consultation.requestedAt,
        completedAt: DateTime.now(),
        status: ConsultationStatus.completed,
        assessment: assessment,
        recommendations: recommendations,
        followUp: followUp,
        notes: notes ?? consultation.notes,
        metadata: consultation.metadata,
      );

      _consultations[index] = updatedConsultation;
      await _saveConsultations();
      return true;
    } catch (e) {
      print('Error completing consultation: $e');
      return false;
    }
  }

  // Get diagnoses for patient
  List<PsychiatricDiagnosis> getDiagnosesForPatient(String patientId) {
    return _diagnoses
        .where((diagnosis) => diagnosis.patientId == patientId)
        .toList()
        ..sort((a, b) => b.diagnosedAt.compareTo(a.diagnosedAt));
  }

  // Get diagnoses for psychiatrist
  List<PsychiatricDiagnosis> getDiagnosesForPsychiatrist(String psychiatristId) {
    return _diagnoses
        .where((diagnosis) => diagnosis.psychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => b.diagnosedAt.compareTo(a.diagnosedAt));
  }

  // Get primary diagnoses for patient
  List<PsychiatricDiagnosis> getPrimaryDiagnosesForPatient(String patientId) {
    return _diagnoses
        .where((diagnosis) => 
            diagnosis.patientId == patientId && 
            diagnosis.type == DiagnosisType.primary)
        .toList()
        ..sort((a, b) => b.diagnosedAt.compareTo(a.diagnosedAt));
  }

  // Get treatment plans for patient
  List<TreatmentPlan> getTreatmentPlansForPatient(String patientId) {
    return _treatmentPlans
        .where((plan) => plan.patientId == patientId)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get active treatment plans for patient
  List<TreatmentPlan> getActiveTreatmentPlansForPatient(String patientId) {
    return _treatmentPlans
        .where((plan) => 
            plan.patientId == patientId && 
            plan.isActive)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get treatment plans for psychiatrist
  List<TreatmentPlan> getTreatmentPlansForPsychiatrist(String psychiatristId) {
    return _treatmentPlans
        .where((plan) => plan.psychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get progress for treatment plan
  List<TreatmentProgress> getProgressForTreatmentPlan(String treatmentPlanId) {
    return _progresses
        .where((progress) => progress.treatmentPlanId == treatmentPlanId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get progress for patient
  List<TreatmentProgress> getProgressForPatient(String patientId) {
    return _progresses
        .where((progress) => progress.patientId == patientId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get consultations for patient
  List<PsychiatricConsultation> getConsultationsForPatient(String patientId) {
    return _consultations
        .where((consultation) => consultation.patientId == patientId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get consultations for psychiatrist
  List<PsychiatricConsultation> getConsultationsForPsychiatrist(String psychiatristId) {
    return _consultations
        .where((consultation) => consultation.consultingPsychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get pending consultations
  List<PsychiatricConsultation> getPendingConsultations() {
    return _consultations
        .where((consultation) => consultation.isPending)
        .toList()
        ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  // Get completed consultations
  List<PsychiatricConsultation> getCompletedConsultations() {
    return _consultations
        .where((consultation) => consultation.isCompleted)
        .toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalDiagnoses = _diagnoses.length;
    final primaryDiagnoses = _diagnoses
        .where((diagnosis) => diagnosis.type == DiagnosisType.primary)
        .length;
    final severeDiagnoses = _diagnoses
        .where((diagnosis) => diagnosis.severity == DiagnosisSeverity.severe)
        .length;

    final totalTreatmentPlans = _treatmentPlans.length;
    final activeTreatmentPlans = _treatmentPlans
        .where((plan) => plan.isActive)
        .length;
    final completedTreatmentPlans = _treatmentPlans
        .where((plan) => plan.isCompleted)
        .length;

    final totalProgresses = _progresses.length;
    final totalConsultations = _consultations.length;
    final pendingConsultations = _consultations
        .where((consultation) => consultation.isPending)
        .length;
    final completedConsultations = _consultations
        .where((consultation) => consultation.isCompleted)
        .length;

    return {
      'totalDiagnoses': totalDiagnoses,
      'primaryDiagnoses': primaryDiagnoses,
      'severeDiagnoses': severeDiagnoses,
      'totalTreatmentPlans': totalTreatmentPlans,
      'activeTreatmentPlans': activeTreatmentPlans,
      'completedTreatmentPlans': completedTreatmentPlans,
      'totalProgresses': totalProgresses,
      'totalConsultations': totalConsultations,
      'pendingConsultations': pendingConsultations,
      'completedConsultations': completedConsultations,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_diagnoses.isNotEmpty) return;

    // Add demo diagnoses
    final demoDiagnoses = [
      PsychiatricDiagnosis(
        id: 'diagnosis_001',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        diagnosis: 'Major Depressive Disorder',
        icdCode: 'F32.9',
        dsmCode: '296.20',
        type: DiagnosisType.primary,
        severity: DiagnosisSeverity.moderate,
        diagnosedAt: DateTime.now().subtract(const Duration(days: 15)),
        differentialDiagnosis: 'Bipolar Disorder, Adjustment Disorder',
        rationale: 'Patient meets DSM-5 criteria for MDD',
        prognosis: 'Good with treatment',
        treatmentPlan: 'SSRI + CBT',
        notes: 'Patient motivated for treatment',
      ),
      PsychiatricDiagnosis(
        id: 'diagnosis_002',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        diagnosis: 'Generalized Anxiety Disorder',
        icdCode: 'F41.1',
        dsmCode: '300.02',
        type: DiagnosisType.secondary,
        severity: DiagnosisSeverity.mild,
        diagnosedAt: DateTime.now().subtract(const Duration(days: 10)),
        rationale: 'Excessive worry and anxiety symptoms',
        prognosis: 'Good with treatment',
        treatmentPlan: 'SSRI + relaxation techniques',
        notes: 'Comorbid with depression',
      ),
    ];

    for (final diagnosis in demoDiagnoses) {
      _diagnoses.add(diagnosis);
    }

    await _saveDiagnoses();

    // Add demo treatment plans
    final demoTreatmentPlans = [
      TreatmentPlan(
        id: 'treatment_plan_001',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        diagnosisId: 'diagnosis_001',
        title: 'Depression Treatment Plan',
        description: 'Comprehensive treatment plan for major depressive disorder',
        type: TreatmentType.combined,
        phase: TreatmentPhase.initial,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        goals: [
          'Reduce depressive symptoms',
          'Improve sleep quality',
          'Increase daily functioning',
        ],
        interventions: [
          'SSRI medication',
          'Cognitive Behavioral Therapy',
          'Sleep hygiene education',
        ],
        medications: ['fluoxetine'],
        therapies: ['CBT'],
        monitoring: 'Weekly mood assessment',
        notes: 'Patient responding well to treatment',
      ),
    ];

    for (final treatmentPlan in demoTreatmentPlans) {
      _treatmentPlans.add(treatmentPlan);
    }

    await _saveTreatmentPlans();

    // Add demo progresses
    final demoProgresses = [
      TreatmentProgress(
        id: 'progress_001',
        treatmentPlanId: 'treatment_plan_001',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: ProgressType.clinical,
        parameter: 'Mood',
        value: 'Improved',
        unit: 'Subjective',
        notes: 'Patient reports improved mood',
        actionTaken: 'Continue current treatment',
      ),
      TreatmentProgress(
        id: 'progress_002',
        treatmentPlanId: 'treatment_plan_001',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: ProgressType.clinical,
        parameter: 'Sleep',
        value: 'Improved',
        unit: 'Hours',
        notes: 'Patient sleeping better',
        actionTaken: 'Continue current treatment',
      ),
    ];

    for (final progress in demoProgresses) {
      _progresses.add(progress);
    }

    await _saveProgresses();

    // Add demo consultations
    final demoConsultations = [
      PsychiatricConsultation(
        id: 'consultation_001',
        patientId: '2',
        requestingPhysicianId: 'physician_001',
        consultingPsychiatristId: 'psychiatrist_001',
        reason: 'Depression assessment',
        question: 'Does this patient need psychiatric evaluation?',
        requestedAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: ConsultationStatus.completed,
        assessment: 'Patient shows signs of depression',
        recommendations: 'Refer to psychiatrist for evaluation',
        followUp: 'Schedule psychiatric appointment',
        notes: 'Patient cooperative',
      ),
    ];

    for (final consultation in demoConsultations) {
      _consultations.add(consultation);
    }

    await _saveConsultations();

    print('✅ Demo psychiatric diagnoses created: ${demoDiagnoses.length}');
    print('✅ Demo treatment plans created: ${demoTreatmentPlans.length}');
    print('✅ Demo treatment progresses created: ${demoProgresses.length}');
    print('✅ Demo psychiatric consultations created: ${demoConsultations.length}');
  }
}
