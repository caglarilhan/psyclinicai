import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treatment_plan_models.dart';

class TreatmentPlanService {
  static final TreatmentPlanService _instance = TreatmentPlanService._internal();
  factory TreatmentPlanService() => _instance;
  TreatmentPlanService._internal();

  final List<TreatmentPlan> _treatmentPlans = [];
  final List<TreatmentProgress> _progressRecords = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadTreatmentPlans();
    await _loadProgressRecords();
  }

  // Load treatment plans from storage
  Future<void> _loadTreatmentPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList('treatment_plans') ?? [];
      _treatmentPlans.clear();
      
      for (final planJson in plansJson) {
        final plan = TreatmentPlan.fromJson(jsonDecode(planJson));
        _treatmentPlans.add(plan);
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
      final plansJson = _treatmentPlans
          .map((plan) => jsonEncode(plan.toJson()))
          .toList();
      await prefs.setStringList('treatment_plans', plansJson);
    } catch (e) {
      print('Error saving treatment plans: $e');
    }
  }

  // Load progress records from storage
  Future<void> _loadProgressRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getStringList('treatment_progress') ?? [];
      _progressRecords.clear();
      
      for (final progress in progressJson) {
        final progressRecord = TreatmentProgress.fromJson(jsonDecode(progress));
        _progressRecords.add(progressRecord);
      }
    } catch (e) {
      print('Error loading treatment progress: $e');
      _progressRecords.clear();
    }
  }

  // Save progress records to storage
  Future<void> _saveProgressRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = _progressRecords
          .map((progress) => jsonEncode(progress.toJson()))
          .toList();
      await prefs.setStringList('treatment_progress', progressJson);
    } catch (e) {
      print('Error saving treatment progress: $e');
    }
  }

  // Create new treatment plan
  Future<TreatmentPlan> createTreatmentPlan({
    required String patientId,
    required String clinicianId,
    required String primaryDiagnosis,
    List<String>? secondaryDiagnoses,
    required String clinicalFormulation,
    String? prognosis,
    String? notes,
  }) async {
    final plan = TreatmentPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      clinicianId: clinicianId,
      createdAt: DateTime.now(),
      primaryDiagnosis: primaryDiagnosis,
      secondaryDiagnoses: secondaryDiagnoses ?? [],
      clinicalFormulation: clinicalFormulation,
      prognosis: prognosis,
      notes: notes,
      status: TreatmentPlanStatus.active,
    );

    _treatmentPlans.add(plan);
    await _saveTreatmentPlans();

    return plan;
  }

  // Get treatment plan for patient
  TreatmentPlan? getTreatmentPlanForPatient(String patientId) {
    return _treatmentPlans
        .where((plan) => plan.patientId == patientId && plan.status == TreatmentPlanStatus.active)
        .firstOrNull;
  }

  // Get all treatment plans for patient
  List<TreatmentPlan> getAllTreatmentPlansForPatient(String patientId) {
    return _treatmentPlans
        .where((plan) => plan.patientId == patientId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Add treatment goal
  Future<TreatmentGoal> addTreatmentGoal({
    required String treatmentPlanId,
    required String description,
    required GoalCategory category,
    required GoalPriority priority,
    required DateTime targetDate,
    String? notes,
    List<String>? milestones,
    String? measurementMethod,
  }) async {
    final goal = TreatmentGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      category: category,
      priority: priority,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      notes: notes,
      milestones: milestones ?? [],
      measurementMethod: measurementMethod,
    );

    final planIndex = _treatmentPlans.indexWhere((plan) => plan.id == treatmentPlanId);
    if (planIndex != -1) {
      final plan = _treatmentPlans[planIndex];
      final updatedGoals = [...plan.goals, goal];
      final updatedPlan = TreatmentPlan(
        id: plan.id,
        patientId: plan.patientId,
        clinicianId: plan.clinicianId,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
        primaryDiagnosis: plan.primaryDiagnosis,
        secondaryDiagnoses: plan.secondaryDiagnoses,
        clinicalFormulation: plan.clinicalFormulation,
        goals: updatedGoals,
        interventions: plan.interventions,
        prognosis: plan.prognosis,
        notes: plan.notes,
        status: plan.status,
        reviewDate: plan.reviewDate,
        reviewNotes: plan.reviewNotes,
      );

      _treatmentPlans[planIndex] = updatedPlan;
      await _saveTreatmentPlans();
    }

    return goal;
  }

  // Update goal progress
  Future<bool> updateGoalProgress({
    required String treatmentPlanId,
    required String goalId,
    required int progress,
    String? notes,
  }) async {
    try {
      final planIndex = _treatmentPlans.indexWhere((plan) => plan.id == treatmentPlanId);
      if (planIndex == -1) return false;

      final plan = _treatmentPlans[planIndex];
      final goalIndex = plan.goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex == -1) return false;

      final goal = plan.goals[goalIndex];
      final updatedGoal = TreatmentGoal(
        id: goal.id,
        description: goal.description,
        category: goal.category,
        priority: goal.priority,
        targetDate: goal.targetDate,
        status: progress >= 100 ? GoalStatus.completed : goal.status,
        progress: progress.clamp(0, 100),
        notes: notes ?? goal.notes,
        createdAt: goal.createdAt,
        completedAt: progress >= 100 ? DateTime.now() : goal.completedAt,
        milestones: goal.milestones,
        measurementMethod: goal.measurementMethod,
      );

      final updatedGoals = List<TreatmentGoal>.from(plan.goals);
      updatedGoals[goalIndex] = updatedGoal;

      final updatedPlan = TreatmentPlan(
        id: plan.id,
        patientId: plan.patientId,
        clinicianId: plan.clinicianId,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
        primaryDiagnosis: plan.primaryDiagnosis,
        secondaryDiagnoses: plan.secondaryDiagnoses,
        clinicalFormulation: plan.clinicalFormulation,
        goals: updatedGoals,
        interventions: plan.interventions,
        prognosis: plan.prognosis,
        notes: plan.notes,
        status: plan.status,
        reviewDate: plan.reviewDate,
        reviewNotes: plan.reviewNotes,
      );

      _treatmentPlans[planIndex] = updatedPlan;
      await _saveTreatmentPlans();
      return true;
    } catch (e) {
      print('Error updating goal progress: $e');
      return false;
    }
  }

  // Add treatment intervention
  Future<TreatmentIntervention> addTreatmentIntervention({
    required String treatmentPlanId,
    required String name,
    required InterventionType type,
    required String description,
    required InterventionFrequency frequency,
    required Duration duration,
    String? instructions,
    String? expectedOutcome,
    String? notes,
    List<String>? contraindications,
  }) async {
    final intervention = TreatmentIntervention(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      description: description,
      frequency: frequency,
      duration: duration,
      instructions: instructions,
      expectedOutcome: expectedOutcome,
      startDate: DateTime.now(),
      notes: notes,
      contraindications: contraindications ?? [],
    );

    final planIndex = _treatmentPlans.indexWhere((plan) => plan.id == treatmentPlanId);
    if (planIndex != -1) {
      final plan = _treatmentPlans[planIndex];
      final updatedInterventions = [...plan.interventions, intervention];
      final updatedPlan = TreatmentPlan(
        id: plan.id,
        patientId: plan.patientId,
        clinicianId: plan.clinicianId,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
        primaryDiagnosis: plan.primaryDiagnosis,
        secondaryDiagnoses: plan.secondaryDiagnoses,
        clinicalFormulation: plan.clinicalFormulation,
        goals: plan.goals,
        interventions: updatedInterventions,
        prognosis: plan.prognosis,
        notes: plan.notes,
        status: plan.status,
        reviewDate: plan.reviewDate,
        reviewNotes: plan.reviewNotes,
      );

      _treatmentPlans[planIndex] = updatedPlan;
      await _saveTreatmentPlans();
    }

    return intervention;
  }

  // Record treatment progress
  Future<TreatmentProgress> recordTreatmentProgress({
    required String treatmentPlanId,
    required String assessedBy,
    required Map<String, dynamic> goalProgress,
    required Map<String, dynamic> interventionEffectiveness,
    required String overallAssessment,
    String? recommendations,
    String? notes,
    DateTime? nextReviewDate,
  }) async {
    final progress = TreatmentProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      treatmentPlanId: treatmentPlanId,
      assessmentDate: DateTime.now(),
      assessedBy: assessedBy,
      goalProgress: goalProgress,
      interventionEffectiveness: interventionEffectiveness,
      overallAssessment: overallAssessment,
      recommendations: recommendations,
      notes: notes,
      nextReviewDate: nextReviewDate ?? DateTime.now().add(const Duration(days: 30)),
    );

    _progressRecords.add(progress);
    await _saveProgressRecords();

    // Update treatment plan review date
    final planIndex = _treatmentPlans.indexWhere((plan) => plan.id == treatmentPlanId);
    if (planIndex != -1) {
      final plan = _treatmentPlans[planIndex];
      final updatedPlan = TreatmentPlan(
        id: plan.id,
        patientId: plan.patientId,
        clinicianId: plan.clinicianId,
        createdAt: plan.createdAt,
        updatedAt: DateTime.now(),
        primaryDiagnosis: plan.primaryDiagnosis,
        secondaryDiagnoses: plan.secondaryDiagnoses,
        clinicalFormulation: plan.clinicalFormulation,
        goals: plan.goals,
        interventions: plan.interventions,
        prognosis: plan.prognosis,
        notes: plan.notes,
        status: plan.status,
        reviewDate: progress.nextReviewDate,
        reviewNotes: progress.notes,
      );

      _treatmentPlans[planIndex] = updatedPlan;
      await _saveTreatmentPlans();
    }

    return progress;
  }

  // Get progress records for treatment plan
  List<TreatmentProgress> getProgressRecordsForPlan(String treatmentPlanId) {
    return _progressRecords
        .where((progress) => progress.treatmentPlanId == treatmentPlanId)
        .toList()
        ..sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
  }

  // Get overdue goals
  List<TreatmentGoal> getOverdueGoals() {
    final allGoals = _treatmentPlans
        .expand((plan) => plan.goals)
        .where((goal) => goal.isOverdue)
        .toList();
    return allGoals;
  }

  // Get goals due soon
  List<TreatmentGoal> getGoalsDueSoon() {
    final allGoals = _treatmentPlans
        .expand((plan) => plan.goals)
        .where((goal) => goal.isDueSoon)
        .toList();
    return allGoals;
  }

  // Get treatment plan statistics
  Map<String, dynamic> getTreatmentPlanStatistics() {
    final totalPlans = _treatmentPlans.length;
    final activePlans = _treatmentPlans
        .where((plan) => plan.status == TreatmentPlanStatus.active)
        .length;
    final completedPlans = _treatmentPlans
        .where((plan) => plan.status == TreatmentPlanStatus.completed)
        .length;

    final allGoals = _treatmentPlans.expand((plan) => plan.goals).toList();
    final totalGoals = allGoals.length;
    final activeGoals = allGoals
        .where((goal) => goal.status == GoalStatus.active)
        .length;
    final completedGoals = allGoals
        .where((goal) => goal.status == GoalStatus.completed)
        .length;
    final overdueGoals = allGoals
        .where((goal) => goal.isOverdue)
        .length;

    final allInterventions = _treatmentPlans.expand((plan) => plan.interventions).toList();
    final totalInterventions = allInterventions.length;
    final activeInterventions = allInterventions
        .where((intervention) => intervention.isActive)
        .length;

    final totalProgressRecords = _progressRecords.length;

    return {
      'totalPlans': totalPlans,
      'activePlans': activePlans,
      'completedPlans': completedPlans,
      'totalGoals': totalGoals,
      'activeGoals': activeGoals,
      'completedGoals': completedGoals,
      'overdueGoals': overdueGoals,
      'totalInterventions': totalInterventions,
      'activeInterventions': activeInterventions,
      'totalProgressRecords': totalProgressRecords,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_treatmentPlans.isNotEmpty) return;

    final demoPlans = [
      TreatmentPlan(
        id: 'plan_001',
        patientId: '1',
        clinicianId: 'psychiatrist_001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        primaryDiagnosis: 'Major Depresif Bozukluk',
        secondaryDiagnoses: ['Uyku Bozukluğu'],
        clinicalFormulation: 'Stres faktörleri ile tetiklenen depresif epizod. Hasta iş stresi ve aile sorunları yaşıyor.',
        prognosis: 'İyi. Uygun tedavi ile 6-12 ay içinde düzelme bekleniyor.',
        notes: 'Hasta tedaviye uyumlu, motivasyonu yüksek.',
        status: TreatmentPlanStatus.active,
        reviewDate: DateTime.now().add(const Duration(days: 30)),
        goals: [
          TreatmentGoal(
            id: 'goal_001',
            description: 'Depresif belirtilerde %50 azalma',
            category: GoalCategory.symptomReduction,
            priority: GoalPriority.high,
            targetDate: DateTime.now().add(const Duration(days: 90)),
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            progress: 30,
            milestones: ['İlk 4 hafta: %20 azalma', '8. hafta: %40 azalma', '12. hafta: %50 azalma'],
            measurementMethod: 'BDI-II ölçeği',
          ),
          TreatmentGoal(
            id: 'goal_002',
            description: 'Uyku kalitesinde iyileşme',
            category: GoalCategory.functionalImprovement,
            priority: GoalPriority.medium,
            targetDate: DateTime.now().add(const Duration(days: 60)),
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            progress: 50,
            milestones: ['Uyku hijyeni eğitimi', 'Düzenli uyku saatleri', 'Uyku günlüğü tutma'],
            measurementMethod: 'Uyku günlüğü ve Pittsburgh Uyku Kalitesi İndeksi',
          ),
        ],
        interventions: [
          TreatmentIntervention(
            id: 'intervention_001',
            name: 'SSRI Antidepresan',
            type: InterventionType.medication,
            description: 'Escitalopram 10mg/gün',
            frequency: InterventionFrequency.daily,
            duration: const Duration(minutes: 0),
            instructions: 'Sabah kahvaltıdan sonra alınacak',
            expectedOutcome: 'Depresif belirtilerde azalma',
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            contraindications: ['MAO inhibitörleri', 'Gebelik'],
          ),
          TreatmentIntervention(
            id: 'intervention_002',
            name: 'Bilişsel Davranışçı Terapi',
            type: InterventionType.psychotherapy,
            description: 'Haftalık CBT seansları',
            frequency: InterventionFrequency.weekly,
            duration: const Duration(minutes: 50),
            instructions: 'Düşünce kayıtları ve davranış aktivasyonu',
            expectedOutcome: 'Olumsuz düşünce kalıplarının değişimi',
            startDate: DateTime.now().subtract(const Duration(days: 25)),
          ),
        ],
      ),
    ];

    for (final plan in demoPlans) {
      _treatmentPlans.add(plan);
    }

    await _saveTreatmentPlans();

    // Add demo progress records
    final demoProgress = [
      TreatmentProgress(
        id: 'progress_001',
        treatmentPlanId: 'plan_001',
        assessmentDate: DateTime.now().subtract(const Duration(days: 15)),
        assessedBy: 'psychiatrist_001',
        goalProgress: {
          'goal_001': {'progress': 20, 'notes': 'Hafif iyileşme görülüyor'},
          'goal_002': {'progress': 30, 'notes': 'Uyku hijyeni eğitimi tamamlandı'},
        },
        interventionEffectiveness: {
          'intervention_001': {'effectiveness': 'Orta', 'sideEffects': 'Minimal'},
          'intervention_002': {'effectiveness': 'İyi', 'compliance': 'Yüksek'},
        },
        overallAssessment: 'Tedavi planı başarılı şekilde ilerliyor. Hasta uyumlu.',
        recommendations: 'İlaç dozunu artırmayı düşünülebilir.',
        nextReviewDate: DateTime.now().add(const Duration(days: 15)),
      ),
    ];

    for (final progress in demoProgress) {
      _progressRecords.add(progress);
    }

    await _saveProgressRecords();

    print('✅ Demo treatment plans created: ${demoPlans.length}');
    print('✅ Demo progress records created: ${demoProgress.length}');
  }
}