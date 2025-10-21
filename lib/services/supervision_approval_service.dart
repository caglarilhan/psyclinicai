import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supervision_approval_models.dart';

class SupervisionApprovalService {
  static final SupervisionApprovalService _instance = SupervisionApprovalService._internal();
  factory SupervisionApprovalService() => _instance;
  SupervisionApprovalService._internal();

  final List<SupervisionApproval> _approvals = [];
  final List<DataAnonymization> _anonymizations = [];
  final List<AnonymizationRule> _anonymizationRules = [];
  final List<ConsentRecord> _consents = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadApprovals();
    await _loadAnonymizations();
    await _loadAnonymizationRules();
    await _loadConsents();
  }

  // Load approvals from storage
  Future<void> _loadApprovals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final approvalsJson = prefs.getStringList('supervision_approvals') ?? [];
      _approvals.clear();
      
      for (final approvalJson in approvalsJson) {
        final approval = SupervisionApproval.fromJson(jsonDecode(approvalJson));
        _approvals.add(approval);
      }
    } catch (e) {
      print('Error loading supervision approvals: $e');
      _approvals.clear();
    }
  }

  // Save approvals to storage
  Future<void> _saveApprovals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final approvalsJson = _approvals
          .map((approval) => jsonEncode(approval.toJson()))
          .toList();
      await prefs.setStringList('supervision_approvals', approvalsJson);
    } catch (e) {
      print('Error saving supervision approvals: $e');
    }
  }

  // Load anonymizations from storage
  Future<void> _loadAnonymizations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final anonymizationsJson = prefs.getStringList('data_anonymizations') ?? [];
      _anonymizations.clear();
      
      for (final anonymizationJson in anonymizationsJson) {
        final anonymization = DataAnonymization.fromJson(jsonDecode(anonymizationJson));
        _anonymizations.add(anonymization);
      }
    } catch (e) {
      print('Error loading data anonymizations: $e');
      _anonymizations.clear();
    }
  }

  // Save anonymizations to storage
  Future<void> _saveAnonymizations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final anonymizationsJson = _anonymizations
          .map((anonymization) => jsonEncode(anonymization.toJson()))
          .toList();
      await prefs.setStringList('data_anonymizations', anonymizationsJson);
    } catch (e) {
      print('Error saving data anonymizations: $e');
    }
  }

  // Load anonymization rules from storage
  Future<void> _loadAnonymizationRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rulesJson = prefs.getStringList('anonymization_rules') ?? [];
      _anonymizationRules.clear();
      
      for (final ruleJson in rulesJson) {
        final rule = AnonymizationRule.fromJson(jsonDecode(ruleJson));
        _anonymizationRules.add(rule);
      }
    } catch (e) {
      print('Error loading anonymization rules: $e');
      _anonymizationRules.clear();
    }
  }

  // Save anonymization rules to storage
  Future<void> _saveAnonymizationRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rulesJson = _anonymizationRules
          .map((rule) => jsonEncode(rule.toJson()))
          .toList();
      await prefs.setStringList('anonymization_rules', rulesJson);
    } catch (e) {
      print('Error saving anonymization rules: $e');
    }
  }

  // Load consents from storage
  Future<void> _loadConsents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentsJson = prefs.getStringList('consent_records') ?? [];
      _consents.clear();
      
      for (final consentJson in consentsJson) {
        final consent = ConsentRecord.fromJson(jsonDecode(consentJson));
        _consents.add(consent);
      }
    } catch (e) {
      print('Error loading consent records: $e');
      _consents.clear();
    }
  }

  // Save consents to storage
  Future<void> _saveConsents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consentsJson = _consents
          .map((consent) => jsonEncode(consent.toJson()))
          .toList();
      await prefs.setStringList('consent_records', consentsJson);
    } catch (e) {
      print('Error saving consent records: $e');
    }
  }

  // Request supervision approval
  Future<SupervisionApproval> requestSupervisionApproval({
    required String caseId,
    required String superviseeId,
    required String supervisorId,
    required ApprovalType type,
    String? caseSummary,
    String? originalContent,
    List<String>? sensitiveDataFields,
    List<String>? attachments,
    DateTime? expiresAt,
  }) async {
    // Check if consent exists for this case
    final consent = getConsentForCase(caseId, ConsentType.supervision);
    if (consent == null || !consent.isValid) {
      throw Exception('Valid consent required for supervision approval');
    }

    // Anonymize content if provided
    String? anonymizedContent;
    if (originalContent != null) {
      final anonymization = await anonymizeContent(
        originalContent,
        'supervision_approval',
        AnonymizationLevel.high,
      );
      anonymizedContent = anonymization.anonymizedContent;
    }

    final approval = SupervisionApproval(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      caseId: caseId,
      superviseeId: superviseeId,
      supervisorId: supervisorId,
      type: type,
      caseSummary: caseSummary,
      anonymizedContent: anonymizedContent,
      sensitiveDataFields: sensitiveDataFields ?? [],
      requestedAt: DateTime.now(),
      attachments: attachments ?? [],
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 7)),
    );

    _approvals.add(approval);
    await _saveApprovals();

    return approval;
  }

  // Approve supervision request
  Future<bool> approveSupervisionRequest({
    required String approvalId,
    required String approvedBy,
    String? reviewNotes,
  }) async {
    try {
      final index = _approvals.indexWhere((approval) => approval.id == approvalId);
      if (index == -1) return false;

      final approval = _approvals[index];
      final updatedApproval = SupervisionApproval(
        id: approval.id,
        caseId: approval.caseId,
        superviseeId: approval.superviseeId,
        supervisorId: approval.supervisorId,
        type: approval.type,
        status: ApprovalStatus.approved,
        caseSummary: approval.caseSummary,
        anonymizedContent: approval.anonymizedContent,
        sensitiveDataFields: approval.sensitiveDataFields,
        requestedAt: approval.requestedAt,
        reviewedAt: DateTime.now(),
        reviewNotes: reviewNotes ?? approval.reviewNotes,
        rejectionReason: approval.rejectionReason,
        attachments: approval.attachments,
        metadata: approval.metadata,
        expiresAt: approval.expiresAt,
        approvedBy: approvedBy,
      );

      _approvals[index] = updatedApproval;
      await _saveApprovals();
      return true;
    } catch (e) {
      print('Error approving supervision request: $e');
      return false;
    }
  }

  // Reject supervision request
  Future<bool> rejectSupervisionRequest({
    required String approvalId,
    required String rejectedBy,
    required String rejectionReason,
  }) async {
    try {
      final index = _approvals.indexWhere((approval) => approval.id == approvalId);
      if (index == -1) return false;

      final approval = _approvals[index];
      final updatedApproval = SupervisionApproval(
        id: approval.id,
        caseId: approval.caseId,
        superviseeId: approval.superviseeId,
        supervisorId: approval.supervisorId,
        type: approval.type,
        status: ApprovalStatus.rejected,
        caseSummary: approval.caseSummary,
        anonymizedContent: approval.anonymizedContent,
        sensitiveDataFields: approval.sensitiveDataFields,
        requestedAt: approval.requestedAt,
        reviewedAt: DateTime.now(),
        reviewNotes: approval.reviewNotes,
        rejectionReason: rejectionReason,
        attachments: approval.attachments,
        metadata: approval.metadata,
        expiresAt: approval.expiresAt,
        approvedBy: rejectedBy,
      );

      _approvals[index] = updatedApproval;
      await _saveApprovals();
      return true;
    } catch (e) {
      print('Error rejecting supervision request: $e');
      return false;
    }
  }

  // Get approvals for supervisor
  List<SupervisionApproval> getApprovalsForSupervisor(String supervisorId) {
    return _approvals
        .where((approval) => approval.supervisorId == supervisorId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get approvals for supervisee
  List<SupervisionApproval> getApprovalsForSupervisee(String superviseeId) {
    return _approvals
        .where((approval) => approval.superviseeId == superviseeId)
        .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Get pending approvals
  List<SupervisionApproval> getPendingApprovals() {
    return _approvals
        .where((approval) => approval.status == ApprovalStatus.pending)
        .toList()
        ..sort((a, b) => a.requestedAt.compareTo(b.requestedAt));
  }

  // Get urgent approvals
  List<SupervisionApproval> getUrgentApprovals() {
    return _approvals
        .where((approval) => approval.isUrgent && approval.status == ApprovalStatus.pending)
        .toList()
        ..sort((a, b) => a.expiresAt?.compareTo(b.expiresAt ?? DateTime.now()) ?? 0);
  }

  // Anonymize content
  Future<DataAnonymization> anonymizeContent({
    required String content,
    required String processedBy,
    required AnonymizationLevel level,
  }) async {
    String anonymizedContent = content;
    final appliedRules = <AnonymizationRule>[];
    final replacements = <String, String>{};

    // Get active rules sorted by priority
    final activeRules = _anonymizationRules
        .where((rule) => rule.isActive)
        .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final rule in activeRules) {
      if (_shouldApplyRule(rule, level)) {
        final regex = RegExp(rule.pattern, caseSensitive: false);
        final matches = regex.allMatches(anonymizedContent);
        
        for (final match in matches) {
          final original = match.group(0)!;
          final replacement = _generateReplacement(rule, original);
          replacements[original] = replacement;
          anonymizedContent = anonymizedContent.replaceFirst(original, replacement);
        }
        
        appliedRules.add(rule);
      }
    }

    final anonymization = DataAnonymization(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalContent: content,
      anonymizedContent: anonymizedContent,
      appliedRules: appliedRules,
      processedAt: DateTime.now(),
      processedBy: processedBy,
      level: level,
      replacements: replacements,
    );

    _anonymizations.add(anonymization);
    await _saveAnonymizations();

    return anonymization;
  }

  // Check if rule should be applied based on level
  bool _shouldApplyRule(AnonymizationRule rule, AnonymizationLevel level) {
    switch (level) {
      case AnonymizationLevel.low:
        return rule.type == AnonymizationType.name;
      case AnonymizationLevel.medium:
        return rule.type == AnonymizationType.name || 
               rule.type == AnonymizationType.address ||
               rule.type == AnonymizationType.phone;
      case AnonymizationLevel.high:
        return rule.type != AnonymizationType.custom;
      case AnonymizationLevel.maximum:
        return true;
    }
  }

  // Generate replacement based on rule type
  String _generateReplacement(AnonymizationRule rule, String original) {
    switch (rule.type) {
      case AnonymizationType.name:
        return '[İSİM]';
      case AnonymizationType.address:
        return '[ADRES]';
      case AnonymizationType.phone:
        return '[TELEFON]';
      case AnonymizationType.email:
        return '[E-POSTA]';
      case AnonymizationType.idNumber:
        return '[KİMLİK NO]';
      case AnonymizationType.date:
        return '[TARİH]';
      case AnonymizationType.location:
        return '[KONUM]';
      case AnonymizationType.custom:
        return rule.replacement;
    }
  }

  // Add anonymization rule
  Future<AnonymizationRule> addAnonymizationRule({
    required String name,
    required String description,
    required String pattern,
    required String replacement,
    required AnonymizationType type,
    int priority = 0,
  }) async {
    final rule = AnonymizationRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      pattern: pattern,
      replacement: replacement,
      type: type,
      priority: priority,
    );

    _anonymizationRules.add(rule);
    await _saveAnonymizationRules();

    return rule;
  }

  // Get anonymization rules
  List<AnonymizationRule> getAnonymizationRules() {
    return _anonymizationRules
        .where((rule) => rule.isActive)
        .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  // Record consent
  Future<ConsentRecord> recordConsent({
    required String patientId,
    required String caseId,
    required ConsentType type,
    required String description,
    required String givenBy,
    DateTime? expiresAt,
    String? notes,
    List<String>? purposes,
    List<String>? dataTypes,
  }) async {
    final consent = ConsentRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      caseId: caseId,
      type: type,
      description: description,
      givenAt: DateTime.now(),
      givenBy: givenBy,
      expiresAt: expiresAt,
      notes: notes,
      purposes: purposes ?? [],
      dataTypes: dataTypes ?? [],
    );

    _consents.add(consent);
    await _saveConsents();

    return consent;
  }

  // Get consent for case
  ConsentRecord? getConsentForCase(String caseId, ConsentType type) {
    return _consents
        .where((consent) => 
            consent.caseId == caseId && 
            consent.type == type && 
            consent.isValid)
        .firstOrNull;
  }

  // Get consents for patient
  List<ConsentRecord> getConsentsForPatient(String patientId) {
    return _consents
        .where((consent) => consent.patientId == patientId)
        .toList()
        ..sort((a, b) => b.givenAt.compareTo(a.givenAt));
  }

  // Revoke consent
  Future<bool> revokeConsent(String consentId, String revokedBy) async {
    try {
      final index = _consents.indexWhere((consent) => consent.id == consentId);
      if (index == -1) return false;

      final consent = _consents[index];
      final updatedConsent = ConsentRecord(
        id: consent.id,
        patientId: consent.patientId,
        caseId: consent.caseId,
        type: consent.type,
        description: consent.description,
        givenAt: consent.givenAt,
        givenBy: consent.givenBy,
        expiresAt: consent.expiresAt,
        status: ConsentStatus.revoked,
        notes: consent.notes,
        purposes: consent.purposes,
        dataTypes: consent.dataTypes,
        isRevocable: consent.isRevocable,
        revokedAt: DateTime.now(),
        revokedBy: revokedBy,
      );

      _consents[index] = updatedConsent;
      await _saveConsents();
      return true;
    } catch (e) {
      print('Error revoking consent: $e');
      return false;
    }
  }

  // Get approval statistics
  Map<String, dynamic> getApprovalStatistics() {
    final totalApprovals = _approvals.length;
    final pendingApprovals = _approvals
        .where((approval) => approval.status == ApprovalStatus.pending)
        .length;
    final approvedApprovals = _approvals
        .where((approval) => approval.status == ApprovalStatus.approved)
        .length;
    final rejectedApprovals = _approvals
        .where((approval) => approval.status == ApprovalStatus.rejected)
        .length;
    final expiredApprovals = _approvals
        .where((approval) => approval.isExpired)
        .length;

    final totalConsents = _consents.length;
    final activeConsents = _consents
        .where((consent) => consent.isValid)
        .length;
    final expiredConsents = _consents
        .where((consent) => consent.isExpired)
        .length;

    return {
      'totalApprovals': totalApprovals,
      'pendingApprovals': pendingApprovals,
      'approvedApprovals': approvedApprovals,
      'rejectedApprovals': rejectedApprovals,
      'expiredApprovals': expiredApprovals,
      'totalConsents': totalConsents,
      'activeConsents': activeConsents,
      'expiredConsents': expiredConsents,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_approvals.isNotEmpty) return;

    // Add demo anonymization rules
    final demoRules = [
      AnonymizationRule(
        id: 'rule_001',
        name: 'İsim Anonimleştirme',
        description: 'Hasta isimlerini anonimleştirir',
        pattern: r'\b[A-ZÇĞIİÖŞÜ][a-zçğıiöşü]+\s+[A-ZÇĞIİÖŞÜ][a-zçğıiöşü]+\b',
        replacement: '[İSİM]',
        type: AnonymizationType.name,
        priority: 1,
      ),
      AnonymizationRule(
        id: 'rule_002',
        name: 'Telefon Anonimleştirme',
        description: 'Telefon numaralarını anonimleştirir',
        pattern: r'(\+90\s?)?(\(?[0-9]{3}\)?)\s?[0-9]{3}\s?[0-9]{2}\s?[0-9]{2}',
        replacement: '[TELEFON]',
        type: AnonymizationType.phone,
        priority: 2,
      ),
      AnonymizationRule(
        id: 'rule_003',
        name: 'Adres Anonimleştirme',
        description: 'Adres bilgilerini anonimleştirir',
        pattern: r'\b[A-ZÇĞIİÖŞÜ][a-zçğıiöşü]+\s+(Sokak|Cadde|Mahalle|İlçe|İl)\b',
        replacement: '[ADRES]',
        type: AnonymizationType.address,
        priority: 3,
      ),
    ];

    for (final rule in demoRules) {
      _anonymizationRules.add(rule);
    }

    await _saveAnonymizationRules();

    // Add demo consents
    final demoConsents = [
      ConsentRecord(
        id: 'consent_001',
        patientId: '1',
        caseId: 'case_001',
        type: ConsentType.supervision,
        description: 'Süpervizyon için vaka paylaşımı onayı',
        givenAt: DateTime.now().subtract(const Duration(days: 10)),
        givenBy: 'patient_1',
        expiresAt: DateTime.now().add(const Duration(days: 365)),
        purposes: ['Süpervizyon', 'Eğitim'],
        dataTypes: ['Vaka notları', 'Değerlendirme sonuçları'],
      ),
    ];

    for (final consent in demoConsents) {
      _consents.add(consent);
    }

    await _saveConsents();

    // Add demo approvals
    final demoApprovals = [
      SupervisionApproval(
        id: 'approval_001',
        caseId: 'case_001',
        superviseeId: 'supervisee_001',
        supervisorId: 'supervisor_001',
        type: ApprovalType.caseReview,
        status: ApprovalStatus.pending,
        caseSummary: 'Depresyon vakası - CBT uygulaması',
        anonymizedContent: '[İSİM] adlı hasta ile CBT seansları yürütülüyor...',
        sensitiveDataFields: ['isim', 'adres', 'telefon'],
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
    ];

    for (final approval in demoApprovals) {
      _approvals.add(approval);
    }

    await _saveApprovals();

    print('✅ Demo anonymization rules created: ${demoRules.length}');
    print('✅ Demo consent records created: ${demoConsents.length}');
    print('✅ Demo supervision approvals created: ${demoApprovals.length}');
  }
}
