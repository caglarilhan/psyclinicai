import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ethics_violation_models.dart';

class EthicsViolationService {
  static final EthicsViolationService _instance = EthicsViolationService._internal();
  factory EthicsViolationService() => _instance;
  EthicsViolationService._internal();

  final List<EthicsViolation> _violations = [];
  final List<RedFlag> _redFlags = [];
  final List<EthicsPolicy> _policies = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadViolations();
    await _loadRedFlags();
    await _loadPolicies();
  }

  // Load violations from storage
  Future<void> _loadViolations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final violationsJson = prefs.getStringList('ethics_violations') ?? [];
      _violations.clear();
      
      for (final violationJson in violationsJson) {
        final violation = EthicsViolation.fromJson(jsonDecode(violationJson));
        _violations.add(violation);
      }
    } catch (e) {
      print('Error loading ethics violations: $e');
      _violations.clear();
    }
  }

  // Save violations to storage
  Future<void> _saveViolations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final violationsJson = _violations
          .map((violation) => jsonEncode(violation.toJson()))
          .toList();
      await prefs.setStringList('ethics_violations', violationsJson);
    } catch (e) {
      print('Error saving ethics violations: $e');
    }
  }

  // Load red flags from storage
  Future<void> _loadRedFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final redFlagsJson = prefs.getStringList('red_flags') ?? [];
      _redFlags.clear();
      
      for (final redFlagJson in redFlagsJson) {
        final redFlag = RedFlag.fromJson(jsonDecode(redFlagJson));
        _redFlags.add(redFlag);
      }
    } catch (e) {
      print('Error loading red flags: $e');
      _redFlags.clear();
    }
  }

  // Save red flags to storage
  Future<void> _saveRedFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final redFlagsJson = _redFlags
          .map((redFlag) => jsonEncode(redFlag.toJson()))
          .toList();
      await prefs.setStringList('red_flags', redFlagsJson);
    } catch (e) {
      print('Error saving red flags: $e');
    }
  }

  // Load policies from storage
  Future<void> _loadPolicies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final policiesJson = prefs.getStringList('ethics_policies') ?? [];
      _policies.clear();
      
      for (final policyJson in policiesJson) {
        final policy = EthicsPolicy.fromJson(jsonDecode(policyJson));
        _policies.add(policy);
      }
    } catch (e) {
      print('Error loading ethics policies: $e');
      _policies.clear();
    }
  }

  // Save policies to storage
  Future<void> _savePolicies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final policiesJson = _policies
          .map((policy) => jsonEncode(policy.toJson()))
          .toList();
      await prefs.setStringList('ethics_policies', policiesJson);
    } catch (e) {
      print('Error saving ethics policies: $e');
    }
  }

  // Report ethics violation
  Future<EthicsViolation> reportViolation({
    required String title,
    required String description,
    required ViolationType type,
    required ViolationSeverity severity,
    required String reportedBy,
    String? reportedByRole,
    String? patientId,
    String? caseId,
    String? clinicianId,
    List<String>? evidence,
    List<String>? witnesses,
  }) async {
    final violation = EthicsViolation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      severity: severity,
      reportedBy: reportedBy,
      reportedByRole: reportedByRole,
      reportedAt: DateTime.now(),
      patientId: patientId,
      caseId: caseId,
      clinicianId: clinicianId,
      evidence: evidence ?? [],
      witnesses: witnesses ?? [],
    );

    _violations.add(violation);
    await _saveViolations();

    // Auto-assign based on severity
    if (violation.isUrgent) {
      await _autoAssignViolation(violation.id);
    }

    return violation;
  }

  // Auto-assign violation
  Future<void> _autoAssignViolation(String violationId) async {
    try {
      final index = _violations.indexWhere((v) => v.id == violationId);
      if (index == -1) return;

      final violation = _violations[index];
      final updatedViolation = EthicsViolation(
        id: violation.id,
        title: violation.title,
        description: violation.description,
        type: violation.type,
        severity: violation.severity,
        reportedBy: violation.reportedBy,
        reportedByRole: violation.reportedByRole,
        reportedAt: violation.reportedAt,
        patientId: violation.patientId,
        caseId: violation.caseId,
        clinicianId: violation.clinicianId,
        evidence: violation.evidence,
        witnesses: violation.witnesses,
        status: ViolationStatus.assigned,
        assignedTo: 'ethics_committee',
        assignedAt: DateTime.now(),
        investigationNotes: violation.investigationNotes,
        investigationStartedAt: violation.investigationStartedAt,
        investigationCompletedAt: violation.investigationCompletedAt,
        resolution: violation.resolution,
        resolvedAt: violation.resolvedAt,
        resolvedBy: violation.resolvedBy,
        actions: violation.actions,
        metadata: violation.metadata,
      );

      _violations[index] = updatedViolation;
      await _saveViolations();
    } catch (e) {
      print('Error auto-assigning violation: $e');
    }
  }

  // Assign violation
  Future<bool> assignViolation({
    required String violationId,
    required String assignedTo,
  }) async {
    try {
      final index = _violations.indexWhere((v) => v.id == violationId);
      if (index == -1) return false;

      final violation = _violations[index];
      final updatedViolation = EthicsViolation(
        id: violation.id,
        title: violation.title,
        description: violation.description,
        type: violation.type,
        severity: violation.severity,
        reportedBy: violation.reportedBy,
        reportedByRole: violation.reportedByRole,
        reportedAt: violation.reportedAt,
        patientId: violation.patientId,
        caseId: violation.caseId,
        clinicianId: violation.clinicianId,
        evidence: violation.evidence,
        witnesses: violation.witnesses,
        status: ViolationStatus.assigned,
        assignedTo: assignedTo,
        assignedAt: DateTime.now(),
        investigationNotes: violation.investigationNotes,
        investigationStartedAt: violation.investigationStartedAt,
        investigationCompletedAt: violation.investigationCompletedAt,
        resolution: violation.resolution,
        resolvedAt: violation.resolvedAt,
        resolvedBy: violation.resolvedBy,
        actions: violation.actions,
        metadata: violation.metadata,
      );

      _violations[index] = updatedViolation;
      await _saveViolations();
      return true;
    } catch (e) {
      print('Error assigning violation: $e');
      return false;
    }
  }

  // Start investigation
  Future<bool> startInvestigation({
    required String violationId,
    required String investigationNotes,
  }) async {
    try {
      final index = _violations.indexWhere((v) => v.id == violationId);
      if (index == -1) return false;

      final violation = _violations[index];
      final updatedViolation = EthicsViolation(
        id: violation.id,
        title: violation.title,
        description: violation.description,
        type: violation.type,
        severity: violation.severity,
        reportedBy: violation.reportedBy,
        reportedByRole: violation.reportedByRole,
        reportedAt: violation.reportedAt,
        patientId: violation.patientId,
        caseId: violation.caseId,
        clinicianId: violation.clinicianId,
        evidence: violation.evidence,
        witnesses: violation.witnesses,
        status: ViolationStatus.investigating,
        assignedTo: violation.assignedTo,
        assignedAt: violation.assignedAt,
        investigationNotes: investigationNotes,
        investigationStartedAt: DateTime.now(),
        investigationCompletedAt: violation.investigationCompletedAt,
        resolution: violation.resolution,
        resolvedAt: violation.resolvedAt,
        resolvedBy: violation.resolvedBy,
        actions: violation.actions,
        metadata: violation.metadata,
      );

      _violations[index] = updatedViolation;
      await _saveViolations();
      return true;
    } catch (e) {
      print('Error starting investigation: $e');
      return false;
    }
  }

  // Resolve violation
  Future<bool> resolveViolation({
    required String violationId,
    required String resolution,
    required String resolvedBy,
    List<String>? actions,
  }) async {
    try {
      final index = _violations.indexWhere((v) => v.id == violationId);
      if (index == -1) return false;

      final violation = _violations[index];
      final updatedViolation = EthicsViolation(
        id: violation.id,
        title: violation.title,
        description: violation.description,
        type: violation.type,
        severity: violation.severity,
        reportedBy: violation.reportedBy,
        reportedByRole: violation.reportedByRole,
        reportedAt: violation.reportedAt,
        patientId: violation.patientId,
        caseId: violation.caseId,
        clinicianId: violation.clinicianId,
        evidence: violation.evidence,
        witnesses: violation.witnesses,
        status: ViolationStatus.resolved,
        assignedTo: violation.assignedTo,
        assignedAt: violation.assignedAt,
        investigationNotes: violation.investigationNotes,
        investigationStartedAt: violation.investigationStartedAt,
        investigationCompletedAt: DateTime.now(),
        resolution: resolution,
        resolvedAt: DateTime.now(),
        resolvedBy: resolvedBy,
        actions: actions ?? violation.actions,
        metadata: violation.metadata,
      );

      _violations[index] = updatedViolation;
      await _saveViolations();
      return true;
    } catch (e) {
      print('Error resolving violation: $e');
      return false;
    }
  }

  // Detect red flag
  Future<RedFlag> detectRedFlag({
    required String title,
    required String description,
    required RedFlagType type,
    required RedFlagSeverity severity,
    required String detectedBy,
    String? patientId,
    String? caseId,
    String? clinicianId,
    Map<String, dynamic>? triggerData,
  }) async {
    final redFlag = RedFlag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      severity: severity,
      detectedBy: detectedBy,
      detectedAt: DateTime.now(),
      patientId: patientId,
      caseId: caseId,
      clinicianId: clinicianId,
      triggerData: triggerData ?? {},
    );

    _redFlags.add(redFlag);
    await _saveRedFlags();

    // Auto-assign based on severity
    if (redFlag.isUrgent) {
      await _autoAssignRedFlag(redFlag.id);
    }

    return redFlag;
  }

  // Auto-assign red flag
  Future<void> _autoAssignRedFlag(String redFlagId) async {
    try {
      final index = _redFlags.indexWhere((rf) => rf.id == redFlagId);
      if (index == -1) return;

      final redFlag = _redFlags[index];
      final updatedRedFlag = RedFlag(
        id: redFlag.id,
        title: redFlag.title,
        description: redFlag.description,
        type: redFlag.type,
        severity: redFlag.severity,
        detectedBy: redFlag.detectedBy,
        detectedAt: redFlag.detectedAt,
        patientId: redFlag.patientId,
        caseId: redFlag.caseId,
        clinicianId: redFlag.clinicianId,
        triggerData: redFlag.triggerData,
        status: RedFlagStatus.assigned,
        assignedTo: 'risk_management',
        assignedAt: DateTime.now(),
        investigationNotes: redFlag.investigationNotes,
        investigationStartedAt: redFlag.investigationStartedAt,
        investigationCompletedAt: redFlag.investigationCompletedAt,
        resolution: redFlag.resolution,
        resolvedAt: redFlag.resolvedAt,
        resolvedBy: redFlag.resolvedBy,
        actions: redFlag.actions,
        metadata: redFlag.metadata,
      );

      _redFlags[index] = updatedRedFlag;
      await _saveRedFlags();
    } catch (e) {
      print('Error auto-assigning red flag: $e');
    }
  }

  // Get violations by status
  List<EthicsViolation> getViolationsByStatus(ViolationStatus status) {
    return _violations
        .where((v) => v.status == status)
        .toList()
        ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
  }

  // Get urgent violations
  List<EthicsViolation> getUrgentViolations() {
    return _violations
        .where((v) => v.isUrgent && v.status != ViolationStatus.resolved)
        .toList()
        ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
  }

  // Get overdue violations
  List<EthicsViolation> getOverdueViolations() {
    return _violations
        .where((v) => v.isOverdue)
        .toList()
        ..sort((a, b) => a.reportedAt.compareTo(b.reportedAt));
  }

  // Get red flags by status
  List<RedFlag> getRedFlagsByStatus(RedFlagStatus status) {
    return _redFlags
        .where((rf) => rf.status == status)
        .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  // Get urgent red flags
  List<RedFlag> getUrgentRedFlags() {
    return _redFlags
        .where((rf) => rf.isUrgent && rf.status != RedFlagStatus.resolved)
        .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  // Get overdue red flags
  List<RedFlag> getOverdueRedFlags() {
    return _redFlags
        .where((rf) => rf.isOverdue)
        .toList()
        ..sort((a, b) => a.detectedAt.compareTo(b.detectedAt));
  }

  // Get violations for clinician
  List<EthicsViolation> getViolationsForClinician(String clinicianId) {
    return _violations
        .where((v) => v.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
  }

  // Get red flags for clinician
  List<RedFlag> getRedFlagsForClinician(String clinicianId) {
    return _redFlags
        .where((rf) => rf.clinicianId == clinicianId)
        .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  // Get violations for patient
  List<EthicsViolation> getViolationsForPatient(String patientId) {
    return _violations
        .where((v) => v.patientId == patientId)
        .toList()
        ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
  }

  // Get red flags for patient
  List<RedFlag> getRedFlagsForPatient(String patientId) {
    return _redFlags
        .where((rf) => rf.patientId == patientId)
        .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalViolations = _violations.length;
    final resolvedViolations = _violations
        .where((v) => v.status == ViolationStatus.resolved)
        .length;
    final pendingViolations = _violations
        .where((v) => v.status != ViolationStatus.resolved)
        .length;
    final urgentViolations = _violations
        .where((v) => v.isUrgent)
        .length;

    final totalRedFlags = _redFlags.length;
    final resolvedRedFlags = _redFlags
        .where((rf) => rf.status == RedFlagStatus.resolved)
        .length;
    final pendingRedFlags = _redFlags
        .where((rf) => rf.status != RedFlagStatus.resolved)
        .length;
    final urgentRedFlags = _redFlags
        .where((rf) => rf.isUrgent)
        .length;

    return {
      'totalViolations': totalViolations,
      'resolvedViolations': resolvedViolations,
      'pendingViolations': pendingViolations,
      'urgentViolations': urgentViolations,
      'totalRedFlags': totalRedFlags,
      'resolvedRedFlags': resolvedRedFlags,
      'pendingRedFlags': pendingRedFlags,
      'urgentRedFlags': urgentRedFlags,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_violations.isNotEmpty) return;

    // Add demo violations
    final demoViolations = [
      EthicsViolation(
        id: 'violation_001',
        title: 'Gizlilik İhlali',
        description: 'Hasta bilgilerinin yetkisiz kişilerle paylaşılması',
        type: ViolationType.confidentiality,
        severity: ViolationSeverity.high,
        reportedBy: 'supervisor_001',
        reportedByRole: 'Süpervizör',
        reportedAt: DateTime.now().subtract(const Duration(days: 3)),
        patientId: '1',
        caseId: 'case_001',
        clinicianId: 'clinician_001',
        evidence: ['E-posta kayıtları', 'Görüşme notları'],
        witnesses: ['witness_001'],
        status: ViolationStatus.investigating,
        assignedTo: 'ethics_committee',
        assignedAt: DateTime.now().subtract(const Duration(days: 2)),
        investigationNotes: 'İnceleme devam ediyor',
        investigationStartedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final violation in demoViolations) {
      _violations.add(violation);
    }

    await _saveViolations();

    // Add demo red flags
    final demoRedFlags = [
      RedFlag(
        id: 'redflag_001',
        title: 'Yüksek Risk Hastası',
        description: 'Hasta intihar riski açısından yüksek risk grubunda',
        type: RedFlagType.risk,
        severity: RedFlagSeverity.critical,
        detectedBy: 'system',
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
        patientId: '2',
        caseId: 'case_002',
        clinicianId: 'clinician_002',
        triggerData: {'risk_score': 8, 'assessment_tool': 'PHQ-9'},
        status: RedFlagStatus.assigned,
        assignedTo: 'risk_management',
        assignedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    for (final redFlag in demoRedFlags) {
      _redFlags.add(redFlag);
    }

    await _saveRedFlags();

    print('✅ Demo ethics violations created: ${demoViolations.length}');
    print('✅ Demo red flags created: ${demoRedFlags.length}');
  }
}
