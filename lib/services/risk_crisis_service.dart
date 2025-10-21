import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/risk_crisis_models.dart';

class RiskCrisisService {
  static final RiskCrisisService _instance = RiskCrisisService._internal();
  factory RiskCrisisService() => _instance;
  RiskCrisisService._internal();

  final List<RiskAssessment> _assessments = [];
  final List<CrisisIncident> _incidents = [];
  final List<SafetyPlan> _safetyPlans = [];
  final List<RiskAlert> _alerts = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadAssessments();
    await _loadIncidents();
    await _loadSafetyPlans();
    await _loadAlerts();
  }

  // Load assessments from storage
  Future<void> _loadAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getStringList('risk_assessments') ?? [];
      _assessments.clear();
      
      for (final assessmentJson in assessmentsJson) {
        final assessment = RiskAssessment.fromJson(jsonDecode(assessmentJson));
        _assessments.add(assessment);
      }
    } catch (e) {
      print('Error loading risk assessments: $e');
      _assessments.clear();
    }
  }

  // Save assessments to storage
  Future<void> _saveAssessments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = _assessments
          .map((assessment) => jsonEncode(assessment.toJson()))
          .toList();
      await prefs.setStringList('risk_assessments', assessmentsJson);
    } catch (e) {
      print('Error saving risk assessments: $e');
    }
  }

  // Load incidents from storage
  Future<void> _loadIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentsJson = prefs.getStringList('crisis_incidents') ?? [];
      _incidents.clear();
      
      for (final incidentJson in incidentsJson) {
        final incident = CrisisIncident.fromJson(jsonDecode(incidentJson));
        _incidents.add(incident);
      }
    } catch (e) {
      print('Error loading crisis incidents: $e');
      _incidents.clear();
    }
  }

  // Save incidents to storage
  Future<void> _saveIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentsJson = _incidents
          .map((incident) => jsonEncode(incident.toJson()))
          .toList();
      await prefs.setStringList('crisis_incidents', incidentsJson);
    } catch (e) {
      print('Error saving crisis incidents: $e');
    }
  }

  // Load safety plans from storage
  Future<void> _loadSafetyPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final safetyPlansJson = prefs.getStringList('safety_plans') ?? [];
      _safetyPlans.clear();
      
      for (final safetyPlanJson in safetyPlansJson) {
        final safetyPlan = SafetyPlan.fromJson(jsonDecode(safetyPlanJson));
        _safetyPlans.add(safetyPlan);
      }
    } catch (e) {
      print('Error loading safety plans: $e');
      _safetyPlans.clear();
    }
  }

  // Save safety plans to storage
  Future<void> _saveSafetyPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final safetyPlansJson = _safetyPlans
          .map((safetyPlan) => jsonEncode(safetyPlan.toJson()))
          .toList();
      await prefs.setStringList('safety_plans', safetyPlansJson);
    } catch (e) {
      print('Error saving safety plans: $e');
    }
  }

  // Load alerts from storage
  Future<void> _loadAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('risk_alerts') ?? [];
      _alerts.clear();
      
      for (final alertJson in alertsJson) {
        final alert = RiskAlert.fromJson(jsonDecode(alertJson));
        _alerts.add(alert);
      }
    } catch (e) {
      print('Error loading risk alerts: $e');
      _alerts.clear();
    }
  }

  // Save alerts to storage
  Future<void> _saveAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = _alerts
          .map((alert) => jsonEncode(alert.toJson()))
          .toList();
      await prefs.setStringList('risk_alerts', alertsJson);
    } catch (e) {
      print('Error saving risk alerts: $e');
    }
  }

  // Conduct risk assessment
  Future<RiskAssessment> conductRiskAssessment({
    required String patientId,
    required String assessorId,
    required RiskType type,
    String? assessmentTool,
    Map<String, dynamic>? responses,
    String? notes,
  }) async {
    // Calculate risk level based on responses
    final scores = _calculateRiskScores(type, responses ?? {});
    final level = _determineRiskLevel(scores);
    final interpretation = _generateRiskInterpretation(level, scores);
    final riskFactors = _identifyRiskFactors(type, responses ?? {});
    final protectiveFactors = _identifyProtectiveFactors(type, responses ?? {});
    final recommendations = _generateRiskRecommendations(level, riskFactors);

    final assessment = RiskAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      assessorId: assessorId,
      type: type,
      level: level,
      assessedAt: DateTime.now(),
      assessmentTool: assessmentTool,
      responses: responses ?? {},
      scores: scores,
      interpretation: interpretation,
      riskFactors: riskFactors,
      protectiveFactors: protectiveFactors,
      recommendations: recommendations,
      followUpDate: _calculateFollowUpDate(level),
      notes: notes,
    );

    _assessments.add(assessment);
    await _saveAssessments();

    // Trigger alert if high risk
    if (assessment.isHighRisk) {
      await _triggerRiskAlert(assessment);
    }

    return assessment;
  }

  // Calculate risk scores
  Map<String, dynamic> _calculateRiskScores(RiskType type, Map<String, dynamic> responses) {
    switch (type) {
      case RiskType.suicide:
        return _calculateSuicideRiskScores(responses);
      case RiskType.selfHarm:
        return _calculateSelfHarmRiskScores(responses);
      case RiskType.violence:
        return _calculateViolenceRiskScores(responses);
      default:
        return _calculateGenericRiskScores(responses);
    }
  }

  // Calculate suicide risk scores
  Map<String, dynamic> _calculateSuicideRiskScores(Map<String, dynamic> responses) {
    int totalScore = 0;
    int itemCount = 0;

    responses.forEach((key, value) {
      if (value is int) {
        totalScore += value;
        itemCount++;
      }
    });

    return {
      'totalScore': totalScore,
      'averageScore': itemCount > 0 ? totalScore / itemCount : 0,
      'itemCount': itemCount,
    };
  }

  // Calculate self-harm risk scores
  Map<String, dynamic> _calculateSelfHarmRiskScores(Map<String, dynamic> responses) {
    int totalScore = 0;
    int itemCount = 0;

    responses.forEach((key, value) {
      if (value is int) {
        totalScore += value;
        itemCount++;
      }
    });

    return {
      'totalScore': totalScore,
      'averageScore': itemCount > 0 ? totalScore / itemCount : 0,
      'itemCount': itemCount,
    };
  }

  // Calculate violence risk scores
  Map<String, dynamic> _calculateViolenceRiskScores(Map<String, dynamic> responses) {
    int totalScore = 0;
    int itemCount = 0;

    responses.forEach((key, value) {
      if (value is int) {
        totalScore += value;
        itemCount++;
      }
    });

    return {
      'totalScore': totalScore,
      'averageScore': itemCount > 0 ? totalScore / itemCount : 0,
      'itemCount': itemCount,
    };
  }

  // Calculate generic risk scores
  Map<String, dynamic> _calculateGenericRiskScores(Map<String, dynamic> responses) {
    int totalScore = 0;
    int itemCount = 0;

    responses.forEach((key, value) {
      if (value is int) {
        totalScore += value;
        itemCount++;
      }
    });

    return {
      'totalScore': totalScore,
      'averageScore': itemCount > 0 ? totalScore / itemCount : 0,
      'itemCount': itemCount,
    };
  }

  // Determine risk level
  RiskLevel _determineRiskLevel(Map<String, dynamic> scores) {
    final totalScore = scores['totalScore'] as int? ?? 0;
    
    if (totalScore >= 20) return RiskLevel.critical;
    if (totalScore >= 15) return RiskLevel.high;
    if (totalScore >= 10) return RiskLevel.medium;
    return RiskLevel.low;
  }

  // Generate risk interpretation
  String _generateRiskInterpretation(RiskLevel level, Map<String, dynamic> scores) {
    switch (level) {
      case RiskLevel.low:
        return 'Düşük risk düzeyi. Rutin takip önerilir.';
      case RiskLevel.medium:
        return 'Orta risk düzeyi. Yakın takip ve müdahale gerekebilir.';
      case RiskLevel.high:
        return 'Yüksek risk düzeyi. Acil müdahale ve yakın takip gerekir.';
      case RiskLevel.critical:
        return 'Kritik risk düzeyi. Acil müdahale ve sürekli gözlem gerekir.';
    }
  }

  // Identify risk factors
  List<String> _identifyRiskFactors(RiskType type, Map<String, dynamic> responses) {
    final riskFactors = <String>[];
    
    switch (type) {
      case RiskType.suicide:
        if (responses['previousAttempts'] == 1) riskFactors.add('Önceki intihar girişimi');
        if (responses['familyHistory'] == 1) riskFactors.add('Aile öyküsü');
        if (responses['substanceUse'] == 1) riskFactors.add('Madde kullanımı');
        if (responses['hopelessness'] == 1) riskFactors.add('Umutsuzluk');
        break;
      case RiskType.selfHarm:
        if (responses['previousSelfHarm'] == 1) riskFactors.add('Önceki kendine zarar verme');
        if (responses['emotionalDysregulation'] == 1) riskFactors.add('Duygusal düzensizlik');
        if (responses['impulsivity'] == 1) riskFactors.add('Dürtüsellik');
        break;
      case RiskType.violence:
        if (responses['previousViolence'] == 1) riskFactors.add('Önceki şiddet öyküsü');
        if (responses['angerIssues'] == 1) riskFactors.add('Öfke sorunları');
        if (responses['substanceUse'] == 1) riskFactors.add('Madde kullanımı');
        break;
      default:
        break;
    }
    
    return riskFactors;
  }

  // Identify protective factors
  List<String> _identifyProtectiveFactors(RiskType type, Map<String, dynamic> responses) {
    final protectiveFactors = <String>[];
    
    switch (type) {
      case RiskType.suicide:
        if (responses['socialSupport'] == 1) protectiveFactors.add('Sosyal destek');
        if (responses['treatmentCompliance'] == 1) protectiveFactors.add('Tedavi uyumu');
        if (responses['futurePlans'] == 1) protectiveFactors.add('Gelecek planları');
        break;
      case RiskType.selfHarm:
        if (responses['copingSkills'] == 1) protectiveFactors.add('Başa çıkma becerileri');
        if (responses['therapeuticRelationship'] == 1) protectiveFactors.add('Terapötik ilişki');
        break;
      case RiskType.violence:
        if (responses['angerManagement'] == 1) protectiveFactors.add('Öfke yönetimi');
        if (responses['socialSupport'] == 1) protectiveFactors.add('Sosyal destek');
        break;
      default:
        break;
    }
    
    return protectiveFactors;
  }

  // Generate risk recommendations
  String _generateRiskRecommendations(RiskLevel level, List<String> riskFactors) {
    switch (level) {
      case RiskLevel.low:
        return 'Rutin takip ve destekleyici müdahaleler önerilir.';
      case RiskLevel.medium:
        return 'Yakın takip, güvenlik planı ve müdahale stratejileri önerilir.';
      case RiskLevel.high:
        return 'Acil müdahale, güvenlik planı ve sürekli gözlem önerilir.';
      case RiskLevel.critical:
        return 'Acil müdahale, güvenlik planı ve sürekli gözlem önerilir. Acil servis ile iletişim kurulmalı.';
    }
  }

  // Calculate follow-up date
  DateTime? _calculateFollowUpDate(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return DateTime.now().add(const Duration(days: 30));
      case RiskLevel.medium:
        return DateTime.now().add(const Duration(days: 14));
      case RiskLevel.high:
        return DateTime.now().add(const Duration(days: 7));
      case RiskLevel.critical:
        return DateTime.now().add(const Duration(days: 3));
    }
  }

  // Trigger risk alert
  Future<void> _triggerRiskAlert(RiskAssessment assessment) async {
    final alert = RiskAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: assessment.patientId,
      triggeredBy: 'system',
      type: AlertType.risk,
      severity: assessment.level == RiskLevel.critical 
          ? AlertSeverity.critical 
          : AlertSeverity.high,
      triggeredAt: DateTime.now(),
      message: 'Yüksek risk değerlendirmesi: ${assessment.type.name} - ${assessment.level.name}',
      triggerData: {
        'assessmentId': assessment.id,
        'riskType': assessment.type.name,
        'riskLevel': assessment.level.name,
        'scores': assessment.scores,
      },
    );

    _alerts.add(alert);
    await _saveAlerts();
  }

  // Report crisis incident
  Future<CrisisIncident> reportCrisisIncident({
    required String patientId,
    required String reportedBy,
    required CrisisType type,
    required CrisisSeverity severity,
    required DateTime occurredAt,
    required String description,
    String? location,
    List<String>? witnesses,
    List<String>? involvedStaff,
    String? notes,
  }) async {
    final incident = CrisisIncident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      reportedBy: reportedBy,
      type: type,
      severity: severity,
      occurredAt: occurredAt,
      location: location,
      description: description,
      witnesses: witnesses ?? [],
      involvedStaff: involvedStaff ?? [],
      notes: notes,
    );

    _incidents.add(incident);
    await _saveIncidents();

    // Trigger alert if urgent
    if (incident.isUrgent) {
      await _triggerCrisisAlert(incident);
    }

    return incident;
  }

  // Trigger crisis alert
  Future<void> _triggerCrisisAlert(CrisisIncident incident) async {
    final alert = RiskAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: incident.patientId,
      triggeredBy: 'system',
      type: AlertType.crisis,
      severity: incident.severity == CrisisSeverity.critical 
          ? AlertSeverity.critical 
          : AlertSeverity.high,
      triggeredAt: DateTime.now(),
      message: 'Kriz olayı raporlandı: ${incident.type.name} - ${incident.severity.name}',
      triggerData: {
        'incidentId': incident.id,
        'crisisType': incident.type.name,
        'severity': incident.severity.name,
        'description': incident.description,
      },
    );

    _alerts.add(alert);
    await _saveAlerts();
  }

  // Create safety plan
  Future<SafetyPlan> createSafetyPlan({
    required String patientId,
    required String createdBy,
    List<String>? warningSigns,
    List<String>? copingStrategies,
    List<String>? socialSupports,
    List<String>? professionalSupports,
    List<String>? environmentalSafeguards,
    String? emergencyContacts,
    String? notes,
    DateTime? reviewDate,
  }) async {
    final safetyPlan = SafetyPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      warningSigns: warningSigns ?? [],
      copingStrategies: copingStrategies ?? [],
      socialSupports: socialSupports ?? [],
      professionalSupports: professionalSupports ?? [],
      environmentalSafeguards: environmentalSafeguards ?? [],
      emergencyContacts: emergencyContacts,
      notes: notes,
      reviewDate: reviewDate,
    );

    _safetyPlans.add(safetyPlan);
    await _saveSafetyPlans();

    return safetyPlan;
  }

  // Update safety plan
  Future<bool> updateSafetyPlan({
    required String safetyPlanId,
    List<String>? warningSigns,
    List<String>? copingStrategies,
    List<String>? socialSupports,
    List<String>? professionalSupports,
    List<String>? environmentalSafeguards,
    String? emergencyContacts,
    String? notes,
    DateTime? reviewDate,
  }) async {
    try {
      final index = _safetyPlans.indexWhere((sp) => sp.id == safetyPlanId);
      if (index == -1) return false;

      final safetyPlan = _safetyPlans[index];
      final updatedSafetyPlan = SafetyPlan(
        id: safetyPlan.id,
        patientId: safetyPlan.patientId,
        createdBy: safetyPlan.createdBy,
        createdAt: safetyPlan.createdAt,
        updatedAt: DateTime.now(),
        status: safetyPlan.status,
        warningSigns: warningSigns ?? safetyPlan.warningSigns,
        copingStrategies: copingStrategies ?? safetyPlan.copingStrategies,
        socialSupports: socialSupports ?? safetyPlan.socialSupports,
        professionalSupports: professionalSupports ?? safetyPlan.professionalSupports,
        environmentalSafeguards: environmentalSafeguards ?? safetyPlan.environmentalSafeguards,
        emergencyContacts: emergencyContacts ?? safetyPlan.emergencyContacts,
        notes: notes ?? safetyPlan.notes,
        reviewDate: reviewDate ?? safetyPlan.reviewDate,
        metadata: safetyPlan.metadata,
      );

      _safetyPlans[index] = updatedSafetyPlan;
      await _saveSafetyPlans();
      return true;
    } catch (e) {
      print('Error updating safety plan: $e');
      return false;
    }
  }

  // Acknowledge alert
  Future<bool> acknowledgeAlert({
    required String alertId,
    required String acknowledgedBy,
  }) async {
    try {
      final index = _alerts.indexWhere((a) => a.id == alertId);
      if (index == -1) return false;

      final alert = _alerts[index];
      final updatedAlert = RiskAlert(
        id: alert.id,
        patientId: alert.patientId,
        triggeredBy: alert.triggeredBy,
        type: alert.type,
        severity: alert.severity,
        triggeredAt: alert.triggeredAt,
        message: alert.message,
        triggerData: alert.triggerData,
        status: AlertStatus.acknowledged,
        acknowledgedBy: acknowledgedBy,
        acknowledgedAt: DateTime.now(),
        resolvedBy: alert.resolvedBy,
        resolvedAt: alert.resolvedAt,
        resolution: alert.resolution,
        metadata: alert.metadata,
      );

      _alerts[index] = updatedAlert;
      await _saveAlerts();
      return true;
    } catch (e) {
      print('Error acknowledging alert: $e');
      return false;
    }
  }

  // Resolve alert
  Future<bool> resolveAlert({
    required String alertId,
    required String resolvedBy,
    required String resolution,
  }) async {
    try {
      final index = _alerts.indexWhere((a) => a.id == alertId);
      if (index == -1) return false;

      final alert = _alerts[index];
      final updatedAlert = RiskAlert(
        id: alert.id,
        patientId: alert.patientId,
        triggeredBy: alert.triggeredBy,
        type: alert.type,
        severity: alert.severity,
        triggeredAt: alert.triggeredAt,
        message: alert.message,
        triggerData: alert.triggerData,
        status: AlertStatus.resolved,
        acknowledgedBy: alert.acknowledgedBy,
        acknowledgedAt: alert.acknowledgedAt,
        resolvedBy: resolvedBy,
        resolvedAt: DateTime.now(),
        resolution: resolution,
        metadata: alert.metadata,
      );

      _alerts[index] = updatedAlert;
      await _saveAlerts();
      return true;
    } catch (e) {
      print('Error resolving alert: $e');
      return false;
    }
  }

  // Get assessments for patient
  List<RiskAssessment> getAssessmentsForPatient(String patientId) {
    return _assessments
        .where((assessment) => assessment.patientId == patientId)
        .toList()
        ..sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
  }

  // Get high-risk assessments
  List<RiskAssessment> getHighRiskAssessments() {
    return _assessments
        .where((assessment) => assessment.isHighRisk)
        .toList()
        ..sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
  }

  // Get assessments needing follow-up
  List<RiskAssessment> getAssessmentsNeedingFollowUp() {
    return _assessments
        .where((assessment) => assessment.needsFollowUp)
        .toList()
        ..sort((a, b) => a.followUpDate?.compareTo(b.followUpDate ?? DateTime.now()) ?? 0);
  }

  // Get overdue assessments
  List<RiskAssessment> getOverdueAssessments() {
    return _assessments
        .where((assessment) => assessment.isFollowUpOverdue)
        .toList()
        ..sort((a, b) => a.followUpDate?.compareTo(b.followUpDate ?? DateTime.now()) ?? 0);
  }

  // Get incidents for patient
  List<CrisisIncident> getIncidentsForPatient(String patientId) {
    return _incidents
        .where((incident) => incident.patientId == patientId)
        .toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  // Get active incidents
  List<CrisisIncident> getActiveIncidents() {
    return _incidents
        .where((incident) => incident.isActive)
        .toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  }

  // Get urgent incidents
  List<CrisisIncident> getUrgentIncidents() {
    return _incidents
        .where((incident) => incident.isUrgent)
        .toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  }

  // Get overdue incidents
  List<CrisisIncident> getOverdueIncidents() {
    return _incidents
        .where((incident) => incident.isOverdue)
        .toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  }

  // Get safety plan for patient
  SafetyPlan? getSafetyPlanForPatient(String patientId) {
    return _safetyPlans
        .where((sp) => sp.patientId == patientId && sp.status == SafetyPlanStatus.active)
        .firstOrNull;
  }

  // Get safety plans needing review
  List<SafetyPlan> getSafetyPlansNeedingReview() {
    return _safetyPlans
        .where((sp) => sp.needsReview)
        .toList()
        ..sort((a, b) => a.reviewDate?.compareTo(b.reviewDate ?? DateTime.now()) ?? 0);
  }

  // Get active alerts
  List<RiskAlert> getActiveAlerts() {
    return _alerts
        .where((alert) => alert.isActive)
        .toList()
        ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
  }

  // Get urgent alerts
  List<RiskAlert> getUrgentAlerts() {
    return _alerts
        .where((alert) => alert.isUrgent)
        .toList()
        ..sort((a, b) => b.triggeredAt.compareTo(a.triggeredAt));
  }

  // Get overdue alerts
  List<RiskAlert> getOverdueAlerts() {
    return _alerts
        .where((alert) => alert.isOverdue)
        .toList()
        ..sort((a, b) => a.triggeredAt.compareTo(b.triggeredAt));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalAssessments = _assessments.length;
    final highRiskAssessments = _assessments
        .where((assessment) => assessment.isHighRisk)
        .length;
    final assessmentsNeedingFollowUp = _assessments
        .where((assessment) => assessment.needsFollowUp)
        .length;
    final overdueAssessments = _assessments
        .where((assessment) => assessment.isFollowUpOverdue)
        .length;

    final totalIncidents = _incidents.length;
    final activeIncidents = _incidents
        .where((incident) => incident.isActive)
        .length;
    final urgentIncidents = _incidents
        .where((incident) => incident.isUrgent)
        .length;
    final overdueIncidents = _incidents
        .where((incident) => incident.isOverdue)
        .length;

    final totalSafetyPlans = _safetyPlans.length;
    final safetyPlansNeedingReview = _safetyPlans
        .where((sp) => sp.needsReview)
        .length;

    final totalAlerts = _alerts.length;
    final activeAlerts = _alerts
        .where((alert) => alert.isActive)
        .length;
    final urgentAlerts = _alerts
        .where((alert) => alert.isUrgent)
        .length;
    final overdueAlerts = _alerts
        .where((alert) => alert.isOverdue)
        .length;

    return {
      'totalAssessments': totalAssessments,
      'highRiskAssessments': highRiskAssessments,
      'assessmentsNeedingFollowUp': assessmentsNeedingFollowUp,
      'overdueAssessments': overdueAssessments,
      'totalIncidents': totalIncidents,
      'activeIncidents': activeIncidents,
      'urgentIncidents': urgentIncidents,
      'overdueIncidents': overdueIncidents,
      'totalSafetyPlans': totalSafetyPlans,
      'safetyPlansNeedingReview': safetyPlansNeedingReview,
      'totalAlerts': totalAlerts,
      'activeAlerts': activeAlerts,
      'urgentAlerts': urgentAlerts,
      'overdueAlerts': overdueAlerts,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_assessments.isNotEmpty) return;

    // Add demo assessments
    final demoAssessments = [
      RiskAssessment(
        id: 'assessment_001',
        patientId: '1',
        assessorId: 'clinician_001',
        type: RiskType.suicide,
        level: RiskLevel.medium,
        assessedAt: DateTime.now().subtract(const Duration(days: 5)),
        assessmentTool: 'Columbia-Suicide Severity Rating Scale',
        responses: {'q1': 2, 'q2': 1, 'q3': 3},
        scores: {'totalScore': 6, 'averageScore': 2.0},
        interpretation: 'Orta risk düzeyi. Yakın takip ve müdahale gerekebilir.',
        riskFactors: ['Önceki intihar girişimi', 'Umutsuzluk'],
        protectiveFactors: ['Sosyal destek', 'Tedavi uyumu'],
        recommendations: 'Yakın takip, güvenlik planı ve müdahale stratejileri önerilir.',
        followUpDate: DateTime.now().add(const Duration(days: 9)),
        notes: 'Hasta işbirliği iyi',
      ),
    ];

    for (final assessment in demoAssessments) {
      _assessments.add(assessment);
    }

    await _saveAssessments();

    // Add demo incidents
    final demoIncidents = [
      CrisisIncident(
        id: 'incident_001',
        patientId: '2',
        reportedBy: 'clinician_001',
        type: CrisisType.suicide,
        severity: CrisisSeverity.high,
        occurredAt: DateTime.now().subtract(const Duration(hours: 2)),
        location: 'Klinik',
        description: 'Hasta intihar düşüncelerini ifade etti',
        witnesses: ['witness_001'],
        involvedStaff: ['clinician_001', 'nurse_001'],
        status: CrisisStatus.investigating,
        notes: 'Acil müdahale gerekli',
      ),
    ];

    for (final incident in demoIncidents) {
      _incidents.add(incident);
    }

    await _saveIncidents();

    // Add demo safety plans
    final demoSafetyPlans = [
      SafetyPlan(
        id: 'safety_plan_001',
        patientId: '1',
        createdBy: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        warningSigns: [
          'Uyku sorunları',
          'İştahsızlık',
          'Sosyal izolasyon',
        ],
        copingStrategies: [
          'Nefes egzersizleri',
          'Gevşeme teknikleri',
          'Sosyal destek arama',
        ],
        socialSupports: [
          'Aile üyeleri',
          'Arkadaşlar',
          'Destek grubu',
        ],
        professionalSupports: [
          'Psikiyatrist',
          'Psikolog',
          'Hemşire',
        ],
        environmentalSafeguards: [
          'İlaçların güvenli saklanması',
          'Kesici aletlerin kaldırılması',
          'Güvenli ortam sağlama',
        ],
        emergencyContacts: '112, Acil Servis, Klinik',
        notes: 'Hasta güvenlik planını anladı',
        reviewDate: DateTime.now().add(const Duration(days: 20)),
      ),
    ];

    for (final safetyPlan in demoSafetyPlans) {
      _safetyPlans.add(safetyPlan);
    }

    await _saveSafetyPlans();

    // Add demo alerts
    final demoAlerts = [
      RiskAlert(
        id: 'alert_001',
        patientId: '2',
        triggeredBy: 'system',
        type: AlertType.crisis,
        severity: AlertSeverity.high,
        triggeredAt: DateTime.now().subtract(const Duration(hours: 2)),
        message: 'Kriz olayı raporlandı: suicide - high',
        triggerData: {
          'incidentId': 'incident_001',
          'crisisType': 'suicide',
          'severity': 'high',
        },
        status: AlertStatus.active,
      ),
    ];

    for (final alert in demoAlerts) {
      _alerts.add(alert);
    }

    await _saveAlerts();

    print('✅ Demo risk assessments created: ${demoAssessments.length}');
    print('✅ Demo crisis incidents created: ${demoIncidents.length}');
    print('✅ Demo safety plans created: ${demoSafetyPlans.length}');
    print('✅ Demo risk alerts created: ${demoAlerts.length}');
  }
}
