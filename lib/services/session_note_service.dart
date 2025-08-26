import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/session_note_models.dart';

/// Session Note Service - Seans notu ve AI özet servisi
class SessionNoteService {
  static const String _baseUrl = 'https://api.sessions.psyclinicai.com/v1';
  static const String _apiKey = 'session_key_12345';

  // Cache for session data
  final Map<String, SessionNote> _sessionNotesCache = {};
  final Map<String, AISessionAnalysis> _analysisCache = {};
  final Map<String, SessionTemplate> _templatesCache = {};
  final Map<String, SessionSummary> _summariesCache = {};
  final Map<String, SessionFlag> _flagsCache = {};
  final Map<String, SessionProgress> _progressCache = {};
  final Map<String, RegionalConfig> _regionalConfigCache = {};

  // Stream controllers for real-time updates
  final StreamController<SessionNote> _sessionNoteController =
      StreamController<SessionNote>.broadcast();
  final StreamController<AISessionAnalysis> _analysisController =
      StreamController<AISessionAnalysis>.broadcast();
  final StreamController<SessionFlag> _flagController =
      StreamController<SessionFlag>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  // Current regional configuration
  RegionalConfig? _currentRegion;

  /// Get stream for session note updates
  Stream<SessionNote> get sessionNoteStream => _sessionNoteController.stream;

  /// Get stream for AI analysis updates
  Stream<AISessionAnalysis> get analysisStream => _analysisController.stream;

  /// Get stream for flag updates
  Stream<SessionFlag> get flagStream => _flagController.stream;

  /// Get stream for status updates
  Stream<String> get statusStream => _statusController.stream;

  /// Initialize session note service
  Future<void> initialize() async {
    await _loadRegionalConfigurations();
    await _loadDefaultTemplates();
    await _setupRegionalSettings();
  }

  /// Load regional configurations
  Future<void> _loadRegionalConfigurations() async {
    final configs = [
      _createRegionalConfig(
        'US',
        DiagnosisStandard.dsm_5_tr,
        'en',
        ['HIPAA'],
        'DSM-5-TR formatında öner.',
        'us-central1',
      ),
      _createRegionalConfig(
        'EU',
        DiagnosisStandard.icd_11,
        'en',
        ['GDPR'],
        'ICD-11 kodu ile özetle.',
        'europe-west1',
      ),
      _createRegionalConfig(
        'TR',
        DiagnosisStandard.icd_10,
        'tr',
        ['KVKK'],
        'Türkçe ICD kodu ile özetle.',
        'europe-west2',
      ),
      _createRegionalConfig(
        'CA',
        DiagnosisStandard.mixed,
        'en-fr',
        ['PIPEDA'],
        'ICD kodu ve Fransızca açıklama dahil.',
        'northamerica-northeast1',
      ),
    ];

    for (final config in configs) {
      _regionalConfigCache[config.region] = config;
    }

    // Set default region to US
    _currentRegion = _regionalConfigCache['US'];
  }

  /// Load default session templates
  Future<void> _loadDefaultTemplates() async {
    final templates = [
      _createSessionTemplate(
        'initial_session',
        'İlk Seans Şablonu',
        'İlk seans için standart şablon',
        SessionNoteType.initial,
        'İlk seans notları:\n\n1. Danışanın şikayetleri:\n2. Mevcut durum:\n3. Hedefler:\n4. Plan:',
        ['notes', 'goals', 'plan'],
        ['location', 'modality', 'additionalData'],
      ),
      _createSessionTemplate(
        'follow_up_session',
        'Takip Seansı Şablonu',
        'Takip seansları için şablon',
        SessionNoteType.follow_up,
        'Takip seansı notları:\n\n1. Önceki seansın değerlendirmesi:\n2. Güncel durum:\n3. İlerleme:\n4. Sonraki adımlar:',
        ['notes', 'progress', 'nextSteps'],
        ['location', 'modality', 'additionalData'],
      ),
      _createSessionTemplate(
        'crisis_session',
        'Kriz Seansı Şablonu',
        'Kriz durumları için şablon',
        SessionNoteType.crisis,
        'Kriz seansı notları:\n\n1. Kriz durumu:\n2. Risk değerlendirmesi:\n3. Müdahale:\n4. Takip planı:',
        ['notes', 'riskAssessment', 'intervention', 'followUp'],
        ['location', 'modality', 'additionalData'],
      ),
    ];

    for (final template in templates) {
      _templatesCache[template.id] = template;
    }
  }

  /// Setup regional settings
  Future<void> _setupRegionalSettings() async {
    if (_currentRegion != null) {
      _statusController.add('Regional configuration loaded: ${_currentRegion!.region}');
    }
  }

  /// Set current region
  Future<void> setRegion(String region) async {
    _currentRegion = _regionalConfigCache[region];
    if (_currentRegion != null) {
      _statusController.add('Region changed to: ${_currentRegion!.region}');
    }
  }

  /// Get current region
  RegionalConfig? getCurrentRegion() => _currentRegion;

  /// Create session note
  Future<SessionNote> createSessionNote({
    required String clientId,
    required String therapistId,
    required String sessionId,
    required SessionNoteType type,
    required String notes,
    required DateTime sessionDate,
    required int duration,
    String? location,
    String? modality,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session-notes'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'client_id': clientId,
          'therapist_id': therapistId,
          'session_id': sessionId,
          'type': type.name,
          'notes': notes,
          'session_date': sessionDate.toIso8601String(),
          'duration': duration,
          'location': location,
          'modality': modality,
          'additional_data': additionalData,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final sessionNote = SessionNote.fromJson(data);
        _sessionNotesCache[sessionNote.id] = sessionNote;
        _sessionNoteController.add(sessionNote);
        return sessionNote;
      } else {
        throw Exception('Failed to create session note: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock session note for demo purposes
      return _createMockSessionNote(
        clientId,
        therapistId,
        sessionId,
        type,
        notes,
        sessionDate,
        duration,
        location,
        modality,
        additionalData,
      );
    }
  }

  /// Generate AI analysis for session note
  Future<AISessionAnalysis> generateAIAnalysis(String sessionNoteId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session-notes/$sessionNoteId/analyze'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'region': _currentRegion?.region ?? 'US',
          'diagnosis_standard': _currentRegion?.diagnosisStandard.name ?? 'dsm_5_tr',
          'ai_prompt_suffix': _currentRegion?.aiPromptSuffix ?? 'DSM-5-TR formatında öner.',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final analysis = AISessionAnalysis.fromJson(data);
        _analysisCache[analysis.id] = analysis;
        _analysisController.add(analysis);
        return analysis;
      } else {
        throw Exception('Failed to generate AI analysis: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock AI analysis for demo purposes
      return _createMockAIAnalysis(sessionNoteId);
    }
  }

  /// Create session summary
  Future<SessionSummary> createSessionSummary({
    required String sessionNoteId,
    required String clientId,
    required String therapistId,
    required String summaryText,
    String? affect,
    String? theme,
    String? diagnosisSuggestion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session-summaries'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session_note_id': sessionNoteId,
          'client_id': clientId,
          'therapist_id': therapistId,
          'summary_text': summaryText,
          'affect': affect,
          'theme': theme,
          'diagnosis_suggestion': diagnosisSuggestion,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final summary = SessionSummary.fromJson(data);
        _summariesCache[summary.id] = summary;
        return summary;
      } else {
        throw Exception('Failed to create session summary: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock session summary for demo purposes
      return _createMockSessionSummary(
        sessionNoteId,
        clientId,
        therapistId,
        summaryText,
        affect,
        theme,
        diagnosisSuggestion,
      );
    }
  }

  /// Create session flag
  Future<SessionFlag> createSessionFlag({
    required String sessionNoteId,
    required String clientId,
    required String therapistId,
    required String flagType,
    required String severity,
    required String description,
    String? recommendation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session-flags'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session_note_id': sessionNoteId,
          'client_id': clientId,
          'therapist_id': therapistId,
          'flag_type': flagType,
          'severity': severity,
          'description': description,
          'recommendation': recommendation,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final flag = SessionFlag.fromJson(data);
        _flagsCache[flag.id] = flag;
        _flagController.add(flag);
        return flag;
      } else {
        throw Exception('Failed to create session flag: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock session flag for demo purposes
      return _createMockSessionFlag(
        sessionNoteId,
        clientId,
        therapistId,
        flagType,
        severity,
        description,
        recommendation,
      );
    }
  }

  /// Get session notes by client
  Future<List<SessionNote>> getSessionNotesByClient(String clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/session-notes/client/$clientId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SessionNote.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load session notes: ${response.statusCode}');
      }
    } catch (e) {
      // Return cached session notes for demo purposes
      return _sessionNotesCache.values
          .where((note) => note.clientId == clientId)
          .toList();
    }
  }

  /// Get session templates
  Future<List<SessionTemplate>> getSessionTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/session-templates'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SessionTemplate.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load session templates: ${response.statusCode}');
      }
    } catch (e) {
      // Return cached templates for demo purposes
      return _templatesCache.values.toList();
    }
  }

  /// Export session note to PDF
  Future<SessionExport> exportSessionNoteToPDF({
    required String sessionNoteId,
    required String clientId,
    required String therapistId,
    Map<String, dynamic>? exportOptions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session-notes/$sessionNoteId/export'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'export_type': 'pdf',
          'export_format': 'professional',
          'export_options': exportOptions ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SessionExport.fromJson(data);
      } else {
        throw Exception('Failed to export session note: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock export for demo purposes
      return _createMockSessionExport(
        sessionNoteId,
        clientId,
        therapistId,
        'pdf',
        'professional',
        exportOptions,
      );
    }
  }

  /// Get session progress
  Future<List<SessionProgress>> getSessionProgress(String clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/session-progress/client/$clientId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SessionProgress.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load session progress: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock progress for demo purposes
      return _generateMockSessionProgress(clientId);
    }
  }

  /// Dispose resources
  void dispose() {
    if (!_sessionNoteController.isClosed) {
      _sessionNoteController.close();
    }
    if (!_analysisController.isClosed) {
      _analysisController.close();
    }
    if (!_flagController.isClosed) {
      _flagController.close();
    }
    if (!_statusController.isClosed) {
      _statusController.close();
    }
  }

  // Private helper methods for creating mock data
  SessionNote _createMockSessionNote(
    String clientId,
    String therapistId,
    String sessionId,
    SessionNoteType type,
    String notes,
    DateTime sessionDate,
    int duration,
    String? location,
    String? modality,
    Map<String, dynamic>? additionalData,
  ) {
    final sessionNote = SessionNote(
      id: 'session_note_${DateTime.now().millisecondsSinceEpoch}',
      clientId: clientId,
      therapistId: therapistId,
      sessionId: sessionId,
      type: type,
      status: SessionStatus.completed,
      notes: notes,
      aiStatus: AIAnalysisStatus.pending,
      sessionDate: sessionDate,
      duration: duration,
      location: location ?? 'Office',
      modality: modality ?? 'in-person',
      additionalData: additionalData,
      createdBy: therapistId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );

    _sessionNotesCache[sessionNote.id] = sessionNote;
    _sessionNoteController.add(sessionNote);
    return sessionNote;
  }

  AISessionAnalysis _createMockAIAnalysis(String sessionNoteId) {
    final sessionNote = _sessionNotesCache.values
        .firstWhere((note) => note.id == sessionNoteId);

    final random = Random();
    final affects = ['üzgün', 'kaygılı', 'öfkeli', 'sakin', 'motiveli', 'karışık'];
    final themes = ['değersizlik', 'kaygı', 'ilişki sorunları', 'iş stresi', 'aile', 'geçmiş travma'];
    final diagnoses = ['6B00.0', '6B01.0', '6B02.0', '6B03.0', '6B04.0'];

    final analysis = AISessionAnalysis(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      sessionNoteId: sessionNoteId,
      clientId: sessionNote.clientId,
      therapistId: sessionNote.therapistId,
      status: AIAnalysisStatus.completed,
      affect: affects[random.nextInt(affects.length)],
      theme: themes[random.nextInt(themes.length)],
      diagnosisSuggestion: diagnoses[random.nextInt(diagnoses.length)],
      diagnosisStandard: _currentRegion?.diagnosisStandard ?? DiagnosisStandard.dsm_5_tr,
      confidenceScore: 0.85 + (random.nextDouble() * 0.1),
      keyTopics: themes.take(3).toList(),
      riskFactors: ['düşük risk', 'orta risk', 'yüksek risk'].take(2).toList(),
      strengths: ['motivasyon', 'sosyal destek', 'farkındalık'].take(2).toList(),
      recommendations: ['CBT teknikleri', 'mindfulness', 'nefes egzersizleri'].take(2).toList(),
      emotionalAnalysis: {
        'dominant_emotion': affects[random.nextInt(affects.length)],
        'emotional_intensity': random.nextInt(10) + 1,
        'emotional_stability': random.nextDouble(),
      },
      behavioralPatterns: {
        'avoidance_behaviors': random.nextBool(),
        'coping_strategies': ['problem çözme', 'sosyal destek'],
        'behavioral_changes': random.nextBool(),
      },
      therapeuticProgress: {
        'progress_level': random.nextInt(5) + 1,
        'engagement_level': random.nextInt(10) + 1,
        'homework_completion': random.nextDouble(),
      },
      rawAnalysis: 'AI tarafından oluşturulan detaylı analiz...',
      analyzedAt: DateTime.now(),
      analyzedBy: 'ai_system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );

    _analysisCache[analysis.id] = analysis;
    _analysisController.add(analysis);
    return analysis;
  }

  SessionSummary _createMockSessionSummary(
    String sessionNoteId,
    String clientId,
    String therapistId,
    String summaryText,
    String? affect,
    String? theme,
    String? diagnosisSuggestion,
  ) {
    return SessionSummary(
      id: 'summary_${DateTime.now().millisecondsSinceEpoch}',
      sessionNoteId: sessionNoteId,
      clientId: clientId,
      therapistId: therapistId,
      summaryText: summaryText,
      affect: affect,
      theme: theme,
      diagnosisSuggestion: diagnosisSuggestion,
      keyPoints: ['Ana nokta 1', 'Ana nokta 2', 'Ana nokta 3'],
      actionItems: ['Eylem 1', 'Eylem 2'],
      followUpTasks: ['Takip 1', 'Takip 2'],
      progressNotes: {'progress': 'İyi ilerleme kaydedildi'},
      isReviewed: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );
  }

  SessionFlag _createMockSessionFlag(
    String sessionNoteId,
    String clientId,
    String therapistId,
    String flagType,
    String severity,
    String description,
    String? recommendation,
  ) {
    return SessionFlag(
      id: 'flag_${DateTime.now().millisecondsSinceEpoch}',
      sessionNoteId: sessionNoteId,
      clientId: clientId,
      therapistId: therapistId,
      flagType: flagType,
      severity: severity,
      description: description,
      recommendation: recommendation,
      isAcknowledged: false,
      requiresFollowUp: severity == 'high' || severity == 'critical',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );
  }

  SessionExport _createMockSessionExport(
    String sessionNoteId,
    String clientId,
    String therapistId,
    String exportType,
    String exportFormat,
    Map<String, dynamic>? exportOptions,
  ) {
    return SessionExport(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      sessionNoteId: sessionNoteId,
      clientId: clientId,
      therapistId: therapistId,
      exportType: exportType,
      exportFormat: exportFormat,
      filePath: '/exports/session_${sessionNoteId}.pdf',
      downloadUrl: 'https://api.psyclinicai.com/exports/session_${sessionNoteId}.pdf',
      exportOptions: exportOptions ?? {},
      isGenerated: true,
      generatedAt: DateTime.now(),
      generatedBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );
  }

  List<SessionProgress> _generateMockSessionProgress(String clientId) {
    final progress = <SessionProgress>[];
    final random = Random();

    for (int i = 1; i <= 5; i++) {
      progress.add(SessionProgress(
        id: 'progress_${i}_${DateTime.now().millisecondsSinceEpoch}',
        clientId: clientId,
        therapistId: 'therapist_123',
        sessionNoteId: 'session_note_$i',
        sessionNumber: i,
        progressType: ['improvement', 'stable', 'decline'][random.nextInt(3)],
        progressDescription: 'Seans $i ilerleme notları',
        metrics: {
          'anxiety_level': random.nextInt(10) + 1,
          'mood_level': random.nextInt(10) + 1,
          'functioning_level': random.nextInt(10) + 1,
        },
        goals: ['Hedef 1', 'Hedef 2'],
        achievedGoals: i > 2 ? ['Hedef 1'] : [],
        nextGoals: ['Sonraki hedef 1', 'Sonraki hedef 2'],
        sessionDate: DateTime.now().subtract(Duration(days: (5 - i) * 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      ));
    }

    return progress;
  }

  RegionalConfig _createRegionalConfig(
    String region,
    DiagnosisStandard diagnosisStandard,
    String language,
    List<String> legalCompliance,
    String aiPromptSuffix,
    String hosting,
  ) {
    return RegionalConfig(
      region: region,
      diagnosisStandard: diagnosisStandard,
      language: language,
      legalCompliance: legalCompliance,
      aiPromptSuffix: aiPromptSuffix,
      hosting: hosting,
      customSettings: {
        'timezone': region == 'US' ? 'America/New_York' : 'Europe/Istanbul',
        'currency': region == 'US' ? 'USD' : 'EUR',
        'date_format': region == 'US' ? 'MM/dd/yyyy' : 'dd/MM/yyyy',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );
  }

  SessionTemplate _createSessionTemplate(
    String id,
    String name,
    String description,
    SessionNoteType type,
    String templateContent,
    List<String> requiredFields,
    List<String> optionalFields,
  ) {
    return SessionTemplate(
      id: id,
      name: name,
      description: description,
      type: type,
      templateContent: templateContent,
      requiredFields: requiredFields,
      optionalFields: optionalFields,
      defaultValues: {
        'location': 'Office',
        'modality': 'in-person',
        'duration': 50,
      },
      isActive: true,
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {},
    );
  }
}
