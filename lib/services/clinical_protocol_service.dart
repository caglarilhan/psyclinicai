import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clinical_protocol_models.dart';

class ClinicalProtocolService {
  static final ClinicalProtocolService _instance = ClinicalProtocolService._internal();
  factory ClinicalProtocolService() => _instance;
  ClinicalProtocolService._internal();

  final List<ClinicalProtocol> _protocols = [];
  final List<ProtocolTemplate> _templates = [];
  final List<ProtocolUsage> _usages = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadProtocols();
    await _loadTemplates();
    await _loadUsages();
  }

  // Load protocols from storage
  Future<void> _loadProtocols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final protocolsJson = prefs.getStringList('clinical_protocols') ?? [];
      _protocols.clear();
      
      for (final protocolJson in protocolsJson) {
        final protocol = ClinicalProtocol.fromJson(jsonDecode(protocolJson));
        _protocols.add(protocol);
      }
    } catch (e) {
      print('Error loading clinical protocols: $e');
      _protocols.clear();
    }
  }

  // Save protocols to storage
  Future<void> _saveProtocols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final protocolsJson = _protocols
          .map((protocol) => jsonEncode(protocol.toJson()))
          .toList();
      await prefs.setStringList('clinical_protocols', protocolsJson);
    } catch (e) {
      print('Error saving clinical protocols: $e');
    }
  }

  // Load templates from storage
  Future<void> _loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('protocol_templates') ?? [];
      _templates.clear();
      
      for (final templateJson in templatesJson) {
        final template = ProtocolTemplate.fromJson(jsonDecode(templateJson));
        _templates.add(template);
      }
    } catch (e) {
      print('Error loading protocol templates: $e');
      _templates.clear();
    }
  }

  // Save templates to storage
  Future<void> _saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = _templates
          .map((template) => jsonEncode(template.toJson()))
          .toList();
      await prefs.setStringList('protocol_templates', templatesJson);
    } catch (e) {
      print('Error saving protocol templates: $e');
    }
  }

  // Load usages from storage
  Future<void> _loadUsages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usagesJson = prefs.getStringList('protocol_usages') ?? [];
      _usages.clear();
      
      for (final usageJson in usagesJson) {
        final usage = ProtocolUsage.fromJson(jsonDecode(usageJson));
        _usages.add(usage);
      }
    } catch (e) {
      print('Error loading protocol usages: $e');
      _usages.clear();
    }
  }

  // Save usages to storage
  Future<void> _saveUsages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usagesJson = _usages
          .map((usage) => jsonEncode(usage.toJson()))
          .toList();
      await prefs.setStringList('protocol_usages', usagesJson);
    } catch (e) {
      print('Error saving protocol usages: $e');
    }
  }

  // Create new clinical protocol
  Future<ClinicalProtocol> createProtocol({
    required String title,
    required String description,
    required ProtocolCategory category,
    required ProtocolType type,
    required String content,
    List<String>? tags,
    List<String>? applicableDisorders,
    List<String>? targetAudience,
    String? evidenceLevel,
    String? source,
    List<String>? prerequisites,
    List<String>? contraindications,
    String? estimatedDuration,
    String? requiredResources,
    required String createdBy,
    bool isPublic = false,
    List<String>? sharedWith,
  }) async {
    final protocol = ClinicalProtocol(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      type: type,
      version: '1.0',
      content: content,
      tags: tags ?? [],
      applicableDisorders: applicableDisorders ?? [],
      targetAudience: targetAudience ?? [],
      evidenceLevel: evidenceLevel,
      source: source,
      prerequisites: prerequisites ?? [],
      contraindications: contraindications ?? [],
      estimatedDuration: estimatedDuration,
      requiredResources: requiredResources,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: ProtocolStatus.draft,
      isPublic: isPublic,
      sharedWith: sharedWith ?? [],
    );

    _protocols.add(protocol);
    await _saveProtocols();

    return protocol;
  }

  // Get protocols accessible by user
  List<ClinicalProtocol> getProtocolsForUser(String userId) {
    return _protocols
        .where((protocol) => protocol.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get protocols by category
  List<ClinicalProtocol> getProtocolsByCategory(ProtocolCategory category, String userId) {
    return _protocols
        .where((protocol) => 
            protocol.category == category && 
            protocol.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get protocols by disorder
  List<ClinicalProtocol> getProtocolsByDisorder(String disorder, String userId) {
    return _protocols
        .where((protocol) => 
            protocol.applicableDisorders.contains(disorder) && 
            protocol.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get public protocols
  List<ClinicalProtocol> getPublicProtocols() {
    return _protocols
        .where((protocol) => protocol.isPublic)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Update protocol
  Future<bool> updateProtocol({
    required String protocolId,
    String? title,
    String? description,
    String? content,
    List<String>? tags,
    List<String>? applicableDisorders,
    List<String>? targetAudience,
    String? evidenceLevel,
    String? source,
    List<String>? prerequisites,
    List<String>? contraindications,
    String? estimatedDuration,
    String? requiredResources,
    String? reviewedBy,
    ProtocolStatus? status,
    bool? isPublic,
    List<String>? sharedWith,
  }) async {
    try {
      final index = _protocols.indexWhere((protocol) => protocol.id == protocolId);
      if (index == -1) return false;

      final protocol = _protocols[index];
      final updatedProtocol = ClinicalProtocol(
        id: protocol.id,
        title: title ?? protocol.title,
        description: description ?? protocol.description,
        category: protocol.category,
        type: protocol.type,
        version: protocol.version,
        content: content ?? protocol.content,
        tags: tags ?? protocol.tags,
        applicableDisorders: applicableDisorders ?? protocol.applicableDisorders,
        targetAudience: targetAudience ?? protocol.targetAudience,
        evidenceLevel: evidenceLevel ?? protocol.evidenceLevel,
        source: source ?? protocol.source,
        prerequisites: prerequisites ?? protocol.prerequisites,
        contraindications: contraindications ?? protocol.contraindications,
        estimatedDuration: estimatedDuration ?? protocol.estimatedDuration,
        requiredResources: requiredResources ?? protocol.requiredResources,
        createdBy: protocol.createdBy,
        reviewedBy: reviewedBy ?? protocol.reviewedBy,
        createdAt: protocol.createdAt,
        updatedAt: DateTime.now(),
        reviewDate: protocol.reviewDate,
        status: status ?? protocol.status,
        isPublic: isPublic ?? protocol.isPublic,
        sharedWith: sharedWith ?? protocol.sharedWith,
        metadata: protocol.metadata,
      );

      _protocols[index] = updatedProtocol;
      await _saveProtocols();
      return true;
    } catch (e) {
      print('Error updating protocol: $e');
      return false;
    }
  }

  // Use protocol
  Future<ProtocolUsage> useProtocol({
    required String protocolId,
    required String userId,
    required String patientId,
    String? notes,
    Map<String, dynamic>? customizations,
    UsageOutcome outcome = UsageOutcome.successful,
    String? feedback,
  }) async {
    final usage = ProtocolUsage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      protocolId: protocolId,
      userId: userId,
      patientId: patientId,
      usedAt: DateTime.now(),
      notes: notes,
      customizations: customizations ?? {},
      outcome: outcome,
      feedback: feedback,
    );

    _usages.add(usage);
    await _saveUsages();

    return usage;
  }

  // Get protocol usage statistics
  Map<String, dynamic> getProtocolUsageStatistics(String protocolId) {
    final usages = _usages.where((usage) => usage.protocolId == protocolId).toList();
    
    if (usages.isEmpty) {
      return {
        'totalUsage': 0,
        'successfulUsage': 0,
        'partialUsage': 0,
        'unsuccessfulUsage': 0,
        'averageOutcome': 0.0,
      };
    }

    final successfulUsage = usages.where((u) => u.outcome == UsageOutcome.successful).length;
    final partialUsage = usages.where((u) => u.outcome == UsageOutcome.partial).length;
    final unsuccessfulUsage = usages.where((u) => u.outcome == UsageOutcome.unsuccessful).length;

    final averageOutcome = usages.map((u) => _getOutcomeScore(u.outcome)).reduce((a, b) => a + b) / usages.length;

    return {
      'totalUsage': usages.length,
      'successfulUsage': successfulUsage,
      'partialUsage': partialUsage,
      'unsuccessfulUsage': unsuccessfulUsage,
      'averageOutcome': averageOutcome,
    };
  }

  // Get user's protocol usage
  List<ProtocolUsage> getUserProtocolUsage(String userId) {
    return _usages
        .where((usage) => usage.userId == userId)
        .toList()
        ..sort((a, b) => b.usedAt.compareTo(a.usedAt));
  }

  // Create protocol template
  Future<ProtocolTemplate> createTemplate({
    required String name,
    required String description,
    required ProtocolCategory category,
    required String templateContent,
    required List<String> requiredFields,
    List<String>? optionalFields,
    String? instructions,
    required String createdBy,
  }) async {
    final template = ProtocolTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      templateContent: templateContent,
      requiredFields: requiredFields,
      optionalFields: optionalFields ?? [],
      instructions: instructions,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    _templates.add(template);
    await _saveTemplates();

    return template;
  }

  // Get templates by category
  List<ProtocolTemplate> getTemplatesByCategory(ProtocolCategory category) {
    return _templates
        .where((template) => template.category == category && template.isActive)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get protocols that need review
  List<ClinicalProtocol> getProtocolsNeedingReview() {
    return _protocols
        .where((protocol) => protocol.needsReview)
        .toList()
        ..sort((a, b) => a.reviewDate?.compareTo(b.reviewDate ?? DateTime.now()) ?? 0);
  }

  // Search protocols
  List<ClinicalProtocol> searchProtocols(String query, String userId) {
    final lowerQuery = query.toLowerCase();
    return _protocols
        .where((protocol) => 
            protocol.isAccessibleBy(userId) &&
            (protocol.title.toLowerCase().contains(lowerQuery) ||
             protocol.description.toLowerCase().contains(lowerQuery) ||
             protocol.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
             protocol.applicableDisorders.any((disorder) => disorder.toLowerCase().contains(lowerQuery))))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Helper method to get outcome score
  double _getOutcomeScore(UsageOutcome outcome) {
    switch (outcome) {
      case UsageOutcome.successful:
        return 1.0;
      case UsageOutcome.partial:
        return 0.5;
      case UsageOutcome.unsuccessful:
        return 0.0;
      case UsageOutcome.modified:
        return 0.7;
    }
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_protocols.isNotEmpty) return;

    final demoProtocols = [
      ClinicalProtocol(
        id: 'protocol_001',
        title: 'EMDR Standart Protokolü',
        description: 'EMDR (Eye Movement Desensitization and Reprocessing) standart 8 aşamalı protokolü',
        category: ProtocolCategory.therapy,
        type: ProtocolType.standard,
        version: '1.0',
        content: '''
        <h2>EMDR Standart Protokolü</h2>
        
        <h3>Aşama 1: Geçmiş</h3>
        <p>Hastanın geçmişi ve travma öyküsü değerlendirilir...</p>
        
        <h3>Aşama 2: Hazırlık</h3>
        <p>Hasta EMDR sürecine hazırlanır...</p>
        
        <h3>Aşama 3: Değerlendirme</h3>
        <p>Hedef anı ve duygular belirlenir...</p>
        
        <h3>Aşama 4: Desensitizasyon</h3>
        <p>Bilateral stimülasyon uygulanır...</p>
        
        <h3>Aşama 5: Yerleştirme</h3>
        <p>Pozitif inançlar güçlendirilir...</p>
        
        <h3>Aşama 6: Vücut Taraması</h3>
        <p>Fiziksel duyumlar kontrol edilir...</p>
        
        <h3>Aşama 7: Kapanış</h3>
        <p>Seans güvenli şekilde kapatılır...</p>
        
        <h3>Aşama 8: Yeniden Değerlendirme</h3>
        <p>Sonraki seans için değerlendirme yapılır...</p>
        ''',
        tags: ['EMDR', 'Travma', 'PTSD', 'Terapi'],
        applicableDisorders: ['PTSD', 'Travma', 'Anksiyete', 'Fobi'],
        targetAudience: ['Psikolog', 'Terapist'],
        evidenceLevel: 'A',
        source: 'Shapiro, F. (2018). Eye Movement Desensitization and Reprocessing (EMDR) Therapy',
        prerequisites: ['EMDR sertifikası', 'Travma terapisi deneyimi'],
        contraindications: ['Aktif psikoz', 'Dissosiyatif bozukluk'],
        estimatedDuration: '60-90 dakika',
        requiredResources: 'EMDR cihazı, güvenli ortam',
        createdBy: 'supervisor_001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        status: ProtocolStatus.approved,
        isPublic: true,
      ),
      ClinicalProtocol(
        id: 'protocol_002',
        title: 'Kriz Müdahale Protokolü',
        description: 'Akut kriz durumlarında uygulanacak müdahale protokolü',
        category: ProtocolCategory.crisis,
        type: ProtocolType.emergency,
        version: '1.0',
        content: '''
        <h2>Kriz Müdahale Protokolü</h2>
        
        <h3>1. Güvenlik Değerlendirmesi</h3>
        <p>Hasta ve çevresindekilerin güvenliği sağlanır...</p>
        
        <h3>2. Durum Değerlendirmesi</h3>
        <p>Krizin şiddeti ve aciliyeti değerlendirilir...</p>
        
        <h3>3. Müdahale Planı</h3>
        <p>Uygun müdahale stratejisi belirlenir...</p>
        
        <h3>4. Uygulama</h3>
        <p>Müdahale planı uygulanır...</p>
        
        <h3>5. Takip</h3>
        <p>Hasta takip planı oluşturulur...</p>
        ''',
        tags: ['Kriz', 'Acil', 'Müdahale', 'Güvenlik'],
        applicableDisorders: ['Kriz', 'İntihar Riski', 'Panik Atak'],
        targetAudience: ['Psikolog', 'Psikiyatrist', 'Hemşire'],
        evidenceLevel: 'A',
        source: 'Crisis Intervention Handbook',
        prerequisites: ['Kriz müdahale eğitimi'],
        contraindications: [],
        estimatedDuration: '30-60 dakika',
        requiredResources: 'Güvenlik ekibi, acil iletişim',
        createdBy: 'supervisor_001',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        status: ProtocolStatus.approved,
        isPublic: true,
      ),
    ];

    for (final protocol in demoProtocols) {
      _protocols.add(protocol);
    }

    await _saveProtocols();

    // Add demo templates
    final demoTemplates = [
      ProtocolTemplate(
        id: 'template_001',
        name: 'Terapi Protokolü Şablonu',
        description: 'Genel terapi protokolleri için şablon',
        category: ProtocolCategory.therapy,
        templateContent: '''
        <h2>{PROTOCOL_NAME}</h2>
        
        <h3>Hedef</h3>
        <p>{TARGET_DESCRIPTION}</p>
        
        <h3>Gereksinimler</h3>
        <ul>
          <li>{REQUIREMENT_1}</li>
          <li>{REQUIREMENT_2}</li>
        </ul>
        
        <h3>Adımlar</h3>
        <ol>
          <li>{STEP_1}</li>
          <li>{STEP_2}</li>
        </ol>
        
        <h3>Değerlendirme</h3>
        <p>{EVALUATION_CRITERIA}</p>
        ''',
        requiredFields: ['PROTOCOL_NAME', 'TARGET_DESCRIPTION', 'REQUIREMENT_1', 'REQUIREMENT_2', 'STEP_1', 'STEP_2', 'EVALUATION_CRITERIA'],
        optionalFields: ['ADDITIONAL_NOTES', 'RESOURCES'],
        instructions: 'Şablonu doldururken {FIELD_NAME} formatını kullanın',
        createdBy: 'supervisor_001',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    for (final template in demoTemplates) {
      _templates.add(template);
    }

    await _saveTemplates();

    print('✅ Demo clinical protocols created: ${demoProtocols.length}');
    print('✅ Demo protocol templates created: ${demoTemplates.length}');
  }
}
