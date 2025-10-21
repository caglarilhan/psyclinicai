import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/external_integration_models.dart';

class ExternalIntegrationService {
  static final ExternalIntegrationService _instance = ExternalIntegrationService._internal();
  factory ExternalIntegrationService() => _instance;
  ExternalIntegrationService._internal();

  final List<ExternalIntegration> _integrations = [];
  final List<DataSync> _syncs = [];
  final List<APICredential> _credentials = [];
  final List<IntegrationLog> _logs = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadIntegrations();
    await _loadSyncs();
    await _loadCredentials();
    await _loadLogs();
  }

  // Load integrations from storage
  Future<void> _loadIntegrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final integrationsJson = prefs.getStringList('external_integrations') ?? [];
      _integrations.clear();
      
      for (final integrationJson in integrationsJson) {
        final integration = ExternalIntegration.fromJson(jsonDecode(integrationJson));
        _integrations.add(integration);
      }
    } catch (e) {
      print('Error loading external integrations: $e');
      _integrations.clear();
    }
  }

  // Save integrations to storage
  Future<void> _saveIntegrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final integrationsJson = _integrations
          .map((integration) => jsonEncode(integration.toJson()))
          .toList();
      await prefs.setStringList('external_integrations', integrationsJson);
    } catch (e) {
      print('Error saving external integrations: $e');
    }
  }

  // Load syncs from storage
  Future<void> _loadSyncs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncsJson = prefs.getStringList('data_syncs') ?? [];
      _syncs.clear();
      
      for (final syncJson in syncsJson) {
        final sync = DataSync.fromJson(jsonDecode(syncJson));
        _syncs.add(sync);
      }
    } catch (e) {
      print('Error loading data syncs: $e');
      _syncs.clear();
    }
  }

  // Save syncs to storage
  Future<void> _saveSyncs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncsJson = _syncs
          .map((sync) => jsonEncode(sync.toJson()))
          .toList();
      await prefs.setStringList('data_syncs', syncsJson);
    } catch (e) {
      print('Error saving data syncs: $e');
    }
  }

  // Load credentials from storage
  Future<void> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getStringList('api_credentials') ?? [];
      _credentials.clear();
      
      for (final credentialJson in credentialsJson) {
        final credential = APICredential.fromJson(jsonDecode(credentialJson));
        _credentials.add(credential);
      }
    } catch (e) {
      print('Error loading API credentials: $e');
      _credentials.clear();
    }
  }

  // Save credentials to storage
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = _credentials
          .map((credential) => jsonEncode(credential.toJson()))
          .toList();
      await prefs.setStringList('api_credentials', credentialsJson);
    } catch (e) {
      print('Error saving API credentials: $e');
    }
  }

  // Load logs from storage
  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList('integration_logs') ?? [];
      _logs.clear();
      
      for (final logJson in logsJson) {
        final log = IntegrationLog.fromJson(jsonDecode(logJson));
        _logs.add(log);
      }
    } catch (e) {
      print('Error loading integration logs: $e');
      _logs.clear();
    }
  }

  // Save logs to storage
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = _logs
          .map((log) => jsonEncode(log.toJson()))
          .toList();
      await prefs.setStringList('integration_logs', logsJson);
    } catch (e) {
      print('Error saving integration logs: $e');
    }
  }

  // Add integration
  Future<ExternalIntegration> addIntegration({
    required String name,
    required String description,
    required IntegrationType type,
    String? apiEndpoint,
    String? apiKey,
    Map<String, dynamic>? configuration,
    List<String>? supportedFeatures,
  }) async {
    final integration = ExternalIntegration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: type,
      status: IntegrationStatus.inactive,
      apiEndpoint: apiEndpoint,
      apiKey: apiKey,
      configuration: configuration ?? {},
      supportedFeatures: supportedFeatures ?? [],
      createdAt: DateTime.now(),
    );

    _integrations.add(integration);
    await _saveIntegrations();

    return integration;
  }

  // Activate integration
  Future<bool> activateIntegration(String integrationId) async {
    try {
      final index = _integrations.indexWhere((i) => i.id == integrationId);
      if (index == -1) return false;

      final integration = _integrations[index];
      final updatedIntegration = ExternalIntegration(
        id: integration.id,
        name: integration.name,
        description: integration.description,
        type: integration.type,
        status: IntegrationStatus.active,
        apiEndpoint: integration.apiEndpoint,
        apiKey: integration.apiKey,
        configuration: integration.configuration,
        supportedFeatures: integration.supportedFeatures,
        createdAt: integration.createdAt,
        lastSyncAt: integration.lastSyncAt,
        lastSyncStatus: integration.lastSyncStatus,
        metadata: integration.metadata,
      );

      _integrations[index] = updatedIntegration;
      await _saveIntegrations();
      return true;
    } catch (e) {
      print('Error activating integration: $e');
      return false;
    }
  }

  // Deactivate integration
  Future<bool> deactivateIntegration(String integrationId) async {
    try {
      final index = _integrations.indexWhere((i) => i.id == integrationId);
      if (index == -1) return false;

      final integration = _integrations[index];
      final updatedIntegration = ExternalIntegration(
        id: integration.id,
        name: integration.name,
        description: integration.description,
        type: integration.type,
        status: IntegrationStatus.inactive,
        apiEndpoint: integration.apiEndpoint,
        apiKey: integration.apiKey,
        configuration: integration.configuration,
        supportedFeatures: integration.supportedFeatures,
        createdAt: integration.createdAt,
        lastSyncAt: integration.lastSyncAt,
        lastSyncStatus: integration.lastSyncStatus,
        metadata: integration.metadata,
      );

      _integrations[index] = updatedIntegration;
      await _saveIntegrations();
      return true;
    } catch (e) {
      print('Error deactivating integration: $e');
      return false;
    }
  }

  // Start data sync
  Future<DataSync> startDataSync({
    required String integrationId,
    required SyncType type,
    Map<String, dynamic>? syncData,
  }) async {
    final sync = DataSync(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      integrationId: integrationId,
      type: type,
      status: SyncStatus.running,
      startedAt: DateTime.now(),
      syncData: syncData ?? {},
    );

    _syncs.add(sync);
    await _saveSyncs();

    // Log sync start
    await _logIntegrationEvent(
      integrationId: integrationId,
      level: LogLevel.info,
      message: 'Data sync started: ${type.name}',
    );

    return sync;
  }

  // Complete data sync
  Future<bool> completeDataSync({
    required String syncId,
    required int totalRecords,
    required int syncedRecords,
    int failedRecords = 0,
    String? errorMessage,
  }) async {
    try {
      final index = _syncs.indexWhere((s) => s.id == syncId);
      if (index == -1) return false;

      final sync = _syncs[index];
      final updatedSync = DataSync(
        id: sync.id,
        integrationId: sync.integrationId,
        type: sync.type,
        status: errorMessage != null ? SyncStatus.failed : SyncStatus.completed,
        startedAt: sync.startedAt,
        completedAt: DateTime.now(),
        totalRecords: totalRecords,
        syncedRecords: syncedRecords,
        failedRecords: failedRecords,
        errorMessage: errorMessage,
        syncData: sync.syncData,
        metadata: sync.metadata,
      );

      _syncs[index] = updatedSync;
      await _saveSyncs();

      // Update integration last sync
      await _updateIntegrationLastSync(sync.integrationId, errorMessage);

      // Log sync completion
      await _logIntegrationEvent(
        integrationId: sync.integrationId,
        level: errorMessage != null ? LogLevel.error : LogLevel.info,
        message: errorMessage != null 
            ? 'Data sync failed: $errorMessage'
            : 'Data sync completed: $syncedRecords/$totalRecords records',
      );

      return true;
    } catch (e) {
      print('Error completing data sync: $e');
      return false;
    }
  }

  // Update integration last sync
  Future<void> _updateIntegrationLastSync(String integrationId, String? errorMessage) async {
    try {
      final index = _integrations.indexWhere((i) => i.id == integrationId);
      if (index == -1) return;

      final integration = _integrations[index];
      final updatedIntegration = ExternalIntegration(
        id: integration.id,
        name: integration.name,
        description: integration.description,
        type: integration.type,
        status: integration.status,
        apiEndpoint: integration.apiEndpoint,
        apiKey: integration.apiKey,
        configuration: integration.configuration,
        supportedFeatures: integration.supportedFeatures,
        createdAt: integration.createdAt,
        lastSyncAt: DateTime.now(),
        lastSyncStatus: errorMessage != null ? 'failed' : 'success',
        metadata: integration.metadata,
      );

      _integrations[index] = updatedIntegration;
      await _saveIntegrations();
    } catch (e) {
      print('Error updating integration last sync: $e');
    }
  }

  // Add API credential
  Future<APICredential> addAPICredential({
    required String integrationId,
    required String name,
    required CredentialType type,
    String? apiKey,
    String? secretKey,
    String? username,
    String? password,
    String? token,
    DateTime? expiresAt,
  }) async {
    final credential = APICredential(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      integrationId: integrationId,
      name: name,
      type: type,
      apiKey: apiKey,
      secretKey: secretKey,
      username: username,
      password: password,
      token: token,
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
    );

    _credentials.add(credential);
    await _saveCredentials();

    return credential;
  }

  // Get credential for integration
  APICredential? getCredentialForIntegration(String integrationId) {
    return _credentials
        .where((c) => c.integrationId == integrationId && c.isValid)
        .firstOrNull;
  }

  // Log integration event
  Future<void> _logIntegrationEvent({
    required String integrationId,
    required LogLevel level,
    required String message,
    String? errorCode,
    String? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    String? sessionId,
  }) async {
    final log = IntegrationLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      integrationId: integrationId,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      errorCode: errorCode,
      stackTrace: stackTrace,
      context: context ?? {},
      userId: userId,
      sessionId: sessionId,
    );

    _logs.add(log);
    await _saveLogs();

    // Keep only last 1000 logs per integration
    final integrationLogs = _logs
        .where((l) => l.integrationId == integrationId)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (integrationLogs.length > 1000) {
      final logsToRemove = integrationLogs.skip(1000).toList();
      _logs.removeWhere((l) => logsToRemove.contains(l));
      await _saveLogs();
    }
  }

  // Get integrations by type
  List<ExternalIntegration> getIntegrationsByType(IntegrationType type) {
    return _integrations
        .where((i) => i.type == type)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get active integrations
  List<ExternalIntegration> getActiveIntegrations() {
    return _integrations
        .where((i) => i.isActive)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get integrations needing sync
  List<ExternalIntegration> getIntegrationsNeedingSync() {
    return _integrations
        .where((i) => i.isActive && i.needsSync)
        .toList()
        ..sort((a, b) => a.lastSyncAt?.compareTo(b.lastSyncAt ?? DateTime.now()) ?? 0);
  }

  // Get syncs for integration
  List<DataSync> getSyncsForIntegration(String integrationId) {
    return _syncs
        .where((s) => s.integrationId == integrationId)
        .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Get logs for integration
  List<IntegrationLog> getLogsForIntegration(String integrationId) {
    return _logs
        .where((l) => l.integrationId == integrationId)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get recent logs
  List<IntegrationLog> getRecentLogs({int limit = 100}) {
    return _logs
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
        ..take(limit);
  }

  // Get error logs
  List<IntegrationLog> getErrorLogs() {
    return _logs
        .where((l) => l.level == LogLevel.error || l.level == LogLevel.critical)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get integration statistics
  Map<String, dynamic> getIntegrationStatistics() {
    final totalIntegrations = _integrations.length;
    final activeIntegrations = _integrations
        .where((i) => i.isActive)
        .length;
    final inactiveIntegrations = _integrations
        .where((i) => !i.isActive)
        .length;

    final totalSyncs = _syncs.length;
    final successfulSyncs = _syncs
        .where((s) => s.status == SyncStatus.completed)
        .length;
    final failedSyncs = _syncs
        .where((s) => s.status == SyncStatus.failed)
        .length;

    final totalLogs = _logs.length;
    final errorLogs = _logs
        .where((l) => l.level == LogLevel.error || l.level == LogLevel.critical)
        .length;

    return {
      'totalIntegrations': totalIntegrations,
      'activeIntegrations': activeIntegrations,
      'inactiveIntegrations': inactiveIntegrations,
      'totalSyncs': totalSyncs,
      'successfulSyncs': successfulSyncs,
      'failedSyncs': failedSyncs,
      'totalLogs': totalLogs,
      'errorLogs': errorLogs,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_integrations.isNotEmpty) return;

    // Add demo integrations
    final demoIntegrations = [
      ExternalIntegration(
        id: 'integration_001',
        name: 'OpenAI GPT-4',
        description: 'OpenAI GPT-4 API entegrasyonu',
        type: IntegrationType.api,
        status: IntegrationStatus.active,
        apiEndpoint: 'https://api.openai.com/v1',
        apiKey: 'sk-demo-key',
        configuration: {
          'model': 'gpt-4',
          'temperature': 0.7,
          'max_tokens': 2000,
        },
        supportedFeatures: ['text_generation', 'analysis', 'summarization'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastSyncStatus: 'success',
      ),
      ExternalIntegration(
        id: 'integration_002',
        name: 'Google Cloud Speech-to-Text',
        description: 'Google Cloud Speech-to-Text API entegrasyonu',
        type: IntegrationType.api,
        status: IntegrationStatus.active,
        apiEndpoint: 'https://speech.googleapis.com/v1',
        apiKey: 'AIzaSyDemo-key',
        configuration: {
          'language': 'tr-TR',
          'encoding': 'LINEAR16',
          'sample_rate': 16000,
        },
        supportedFeatures: ['speech_to_text', 'transcription'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
        lastSyncStatus: 'success',
      ),
      ExternalIntegration(
        id: 'integration_003',
        name: 'TITCK API',
        description: 'Türkiye İlaç ve Tıbbi Cihaz Kurumu API entegrasyonu',
        type: IntegrationType.api,
        status: IntegrationStatus.inactive,
        apiEndpoint: 'https://api.titck.gov.tr',
        apiKey: 'titck-demo-key',
        configuration: {
          'version': 'v1',
          'format': 'json',
        },
        supportedFeatures: ['drug_info', 'interactions', 'prescriptions'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    for (final integration in demoIntegrations) {
      _integrations.add(integration);
    }

    await _saveIntegrations();

    // Add demo syncs
    final demoSyncs = [
      DataSync(
        id: 'sync_001',
        integrationId: 'integration_001',
        type: SyncType.full,
        status: SyncStatus.completed,
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        totalRecords: 100,
        syncedRecords: 98,
        failedRecords: 2,
        syncData: {'records': 'patient_notes', 'format': 'json'},
      ),
    ];

    for (final sync in demoSyncs) {
      _syncs.add(sync);
    }

    await _saveSyncs();

    // Add demo credentials
    final demoCredentials = [
      APICredential(
        id: 'credential_001',
        integrationId: 'integration_001',
        name: 'OpenAI API Key',
        type: CredentialType.apiKey,
        apiKey: 'sk-demo-key',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      APICredential(
        id: 'credential_002',
        integrationId: 'integration_002',
        name: 'Google Cloud API Key',
        type: CredentialType.apiKey,
        apiKey: 'AIzaSyDemo-key',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ];

    for (final credential in demoCredentials) {
      _credentials.add(credential);
    }

    await _saveCredentials();

    print('✅ Demo external integrations created: ${demoIntegrations.length}');
    print('✅ Demo data syncs created: ${demoSyncs.length}');
    print('✅ Demo API credentials created: ${demoCredentials.length}');
  }
}
