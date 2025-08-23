import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class FHIRIntegrationService {
  static const String _fhirConfigKey = 'fhir_config';
  static const String _fhirCacheKey = 'fhir_cache';
  
  // Singleton pattern
  static final FHIRIntegrationService _instance = FHIRIntegrationService._internal();
  factory FHIRIntegrationService() => _instance;
  FHIRIntegrationService._internal();

  // Stream controllers
  final StreamController<FHIRStatus> _statusStreamController = 
      StreamController<FHIRStatus>.broadcast();
  
  final StreamController<FHIRSyncProgress> _syncProgressStreamController = 
      StreamController<FHIRSyncProgress>.broadcast();

  // Get streams
  Stream<FHIRStatus> get statusStream => _statusStreamController.stream;
  Stream<FHIRSyncProgress> get syncProgressStream => _syncProgressStreamController.stream;

  // FHIR configuration
  FHIRConfig? _config;
  bool _isConnected = false;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;

  // Getters
  bool get isConnected => _isConnected;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;
  FHIRConfig? get config => _config;

  // Initialize FHIR service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load FHIR configuration
      final configJson = prefs.getString(_fhirConfigKey);
      if (configJson != null) {
        _config = FHIRConfig.fromJson(json.decode(configJson));
      } else {
        // Set default configuration
        _config = const FHIRConfig(
          baseUrl: 'https://hapi.fhir.org/baseR4',
          version: 'R4',
          timeout: 30000,
          retryAttempts: 3,
          enableCaching: true,
          cacheExpiry: 3600,
          authentication: FHIRAuthentication.none,
          apiKey: '',
          clientId: '',
          clientSecret: '',
          scope: '',
          redirectUri: '',
        );
        await _saveConfig();
      }
      
      // Test connection
      await _testConnection();
      
      print('✅ FHIR service initialized');
      
    } catch (e) {
      print('Error initializing FHIR service: $e');
    }
  }

  // Test FHIR connection
  Future<void> _testConnection() async {
    try {
      if (_config == null) return;
      
      // Simulate connection test
      await Future.delayed(const Duration(milliseconds: 500));
      
      final random = Random();
      _isConnected = random.nextDouble() > 0.1; // 90% success rate
      
      _statusStreamController.add(FHIRStatus(
        isConnected: _isConnected,
        timestamp: DateTime.now(),
        message: _isConnected ? 'Connected to FHIR server' : 'Connection failed',
        serverInfo: _isConnected ? _getMockServerInfo() : null,
      ));
      
      if (_isConnected) {
        print('✅ FHIR connection established');
      } else {
        print('❌ FHIR connection failed');
      }
      
    } catch (e) {
      print('Error testing FHIR connection: $e');
      _isConnected = false;
    }
  }

  // Get mock server info
  Map<String, dynamic> _getMockServerInfo() {
    return {
      'name': 'HAPI FHIR Test Server',
      'version': '5.7.0',
      'fhirVersion': 'R4',
      'software': 'HAPI FHIR',
      'implementation': {
        'description': 'HAPI FHIR Test Server',
        'url': 'https://hapi.fhir.org',
      },
    };
  }

  // Save configuration
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fhirConfigKey, json.encode(_config!.toJson()));
    } catch (e) {
      print('Error saving FHIR config: $e');
    }
  }

  // Update configuration
  Future<void> updateConfig(FHIRConfig newConfig) async {
    try {
      _config = newConfig;
      await _saveConfig();
      
      // Test new connection
      await _testConnection();
      
      print('✅ FHIR configuration updated');
      
    } catch (e) {
      print('Error updating FHIR config: $e');
    }
  }

  // Search patients
  Future<List<FHIRPatient>> searchPatients({
    String? name,
    String? identifier,
    String? birthDate,
    String? gender,
    int limit = 50,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Generate mock patients
      final patients = <FHIRPatient>[];
      final random = Random();
      
      for (int i = 0; i < min(limit, 20); i++) {
        patients.add(_generateMockPatient(i + 1, random));
      }
      
      // Filter by search criteria
      if (name != null && name.isNotEmpty) {
        patients.removeWhere((p) => 
          !p.name.toLowerCase().contains(name.toLowerCase())
        );
      }
      
      if (identifier != null && identifier.isNotEmpty) {
        patients.removeWhere((p) => 
          !p.identifier.contains(identifier)
        );
      }
      
      print('🔍 Found ${patients.length} patients');
      return patients;
      
    } catch (e) {
      print('Error searching patients: $e');
      return [];
    }
  }

  // Get patient by ID
  Future<FHIRPatient?> getPatient(String patientId) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Generate mock patient
      final random = Random();
      final patient = _generateMockPatient(int.parse(patientId), random);
      
      print('👤 Retrieved patient: ${patient.name}');
      return patient;
      
    } catch (e) {
      print('Error getting patient: $e');
      return null;
    }
  }

  // Create patient
  Future<FHIRPatient?> createPatient(FHIRPatient patient) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate new ID
      final random = Random();
      final newPatient = patient.copyWith(
        id: 'patient_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('✅ Created patient: ${newPatient.name}');
      return newPatient;
      
    } catch (e) {
      print('Error creating patient: $e');
      return null;
    }
  }

  // Update patient
  Future<FHIRPatient?> updatePatient(FHIRPatient patient) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      final updatedPatient = patient.copyWith(
        updatedAt: DateTime.now(),
      );
      
      print('✅ Updated patient: ${updatedPatient.name}');
      return updatedPatient;
      
    } catch (e) {
      print('Error updating patient: $e');
      return null;
    }
  }

  // Search observations
  Future<List<FHIRObservation>> searchObservations({
    String? patientId,
    String? category,
    String? code,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 50,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 400));
      
      // Generate mock observations
      final observations = <FHIRObservation>[];
      final random = Random();
      
      for (int i = 0; i < min(limit, 15); i++) {
        observations.add(_generateMockObservation(i + 1, random));
      }
      
      // Filter by search criteria
      if (patientId != null && patientId.isNotEmpty) {
        observations.removeWhere((o) => o.patientId != patientId);
      }
      
      if (category != null && category.isNotEmpty) {
        observations.removeWhere((o) => o.category != category);
      }
      
      print('🔍 Found ${observations.length} observations');
      return observations;
      
    } catch (e) {
      print('Error searching observations: $e');
      return [];
    }
  }

  // Get observation by ID
  Future<FHIRObservation?> getObservation(String observationId) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Generate mock observation
      final random = Random();
      final observation = _generateMockObservation(int.parse(observationId), random);
      
      print('📊 Retrieved observation: ${observation.code}');
      return observation;
      
    } catch (e) {
      print('Error getting observation: $e');
      return null;
    }
  }

  // Create observation
  Future<FHIRObservation?> createObservation(FHIRObservation observation) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate new ID
      final random = Random();
      final newObservation = observation.copyWith(
        id: 'obs_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('✅ Created observation: ${newObservation.code}');
      return newObservation;
      
    } catch (e) {
      print('Error creating observation: $e');
      return null;
    }
  }

  // Search medications
  Future<List<FHIRMedication>> searchMedications({
    String? name,
    String? code,
    String? manufacturer,
    int limit = 50,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Generate mock medications
      final medications = <FHIRMedication>[];
      final random = Random();
      
      for (int i = 0; i < min(limit, 25); i++) {
        medications.add(_generateMockMedication(i + 1, random));
      }
      
      // Filter by search criteria
      if (name != null && name.isNotEmpty) {
        medications.removeWhere((m) => 
          !m.name.toLowerCase().contains(name.toLowerCase())
        );
      }
      
      if (code != null && code.isNotEmpty) {
        medications.removeWhere((m) => 
          !m.code.contains(code)
        );
      }
      
      print('🔍 Found ${medications.length} medications');
      return medications;
      
    } catch (e) {
      print('Error searching medications: $e');
      return [];
    }
  }

  // Get medication by ID
  Future<FHIRMedication?> getMedication(String medicationId) async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Generate mock medication
      final random = Random();
      final medication = _generateMockMedication(int.parse(medicationId), random);
      
      print('💊 Retrieved medication: ${medication.name}');
      return medication;
      
    } catch (e) {
      print('Error getting medication: $e');
      return null;
    }
  }

  // Generate mock patient
  FHIRPatient _generateMockPatient(int id, Random random) {
    final names = [
      'John Doe', 'Jane Smith', 'Michael Johnson', 'Sarah Williams',
      'David Brown', 'Lisa Davis', 'Robert Wilson', 'Emily Taylor',
      'James Anderson', 'Maria Garcia', 'William Martinez', 'Jennifer Rodriguez',
    ];
    
    final genders = ['male', 'female', 'other', 'unknown'];
    
    return FHIRPatient(
      id: 'patient_$id',
      identifier: 'ID_${id.toString().padLeft(6, '0')}',
      name: names[random.nextInt(names.length)],
      gender: genders[random.nextInt(genders.length)],
      birthDate: DateTime.now().subtract(Duration(days: random.nextInt(365 * 80))),
      address: '${random.nextInt(9999)} Main St, City, State ${random.nextInt(99999)}',
      phone: '+1-555-${random.nextInt(999).toString().padLeft(3, '0')}-${random.nextInt(9999).toString().padLeft(4, '0')}',
      email: 'patient$id@example.com',
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      updatedAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  }

  // Generate mock observation
  FHIRObservation _generateMockObservation(int id, Random random) {
    final categories = ['vital-signs', 'laboratory', 'survey', 'exam', 'therapy'];
    final codes = ['blood-pressure', 'heart-rate', 'temperature', 'weight', 'height'];
    final values = ['120/80', '72', '98.6', '70.5', '175'];
    final units = ['mmHg', 'bpm', '°F', 'kg', 'cm'];
    
    final category = categories[random.nextInt(categories.length)];
    final codeIndex = random.nextInt(codes.length);
    
    return FHIRObservation(
      id: 'obs_$id',
      patientId: 'patient_${random.nextInt(100) + 1}',
      category: category,
      code: codes[codeIndex],
      value: values[codeIndex],
      unit: units[codeIndex],
      effectiveDate: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      status: 'final',
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      updatedAt: DateTime.now().subtract(Duration(days: random.nextInt(7))),
    );
  }

  // Generate mock medication
  FHIRMedication _generateMockMedication(int id, Random random) {
    final names = [
      'Aspirin', 'Ibuprofen', 'Acetaminophen', 'Lisinopril',
      'Metformin', 'Atorvastatin', 'Omeprazole', 'Amlodipine',
      'Metoprolol', 'Losartan', 'Sertraline', 'Fluoxetine',
    ];
    
    final codes = ['RX123', 'RX456', 'RX789', 'RX012', 'RX345', 'RX678'];
    
    return FHIRMedication(
      id: 'med_$id',
      name: names[random.nextInt(names.length)],
      code: codes[random.nextInt(codes.length)],
      manufacturer: 'Pharma Corp ${random.nextInt(10) + 1}',
      form: 'tablet',
      strength: '${random.nextInt(500) + 50}mg',
      isActive: random.nextBool(),
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      updatedAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  }

  // Sync data with FHIR server
  Future<void> syncWithFHIR() async {
    try {
      if (!_isConnected) {
        throw Exception('Not connected to FHIR server');
      }
      
      setState(() => _isConnected = true);
      
      // Simulate sync process
      for (int i = 0; i < 5; i++) {
        _syncProgressStreamController.add(FHIRSyncProgress(
          current: i + 1,
          total: 5,
          status: 'Syncing ${['patients', 'observations', 'medications', 'appointments', 'documents'][i]}...',
          details: 'Processing data...',
        ));
        
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      _lastSyncTime = DateTime.now();
      _pendingSyncCount = 0;
      
      _syncProgressStreamController.add(FHIRSyncProgress(
        current: 5,
        total: 5,
        status: 'Sync completed',
        details: 'All data synchronized successfully',
      ));
      
      print('✅ FHIR sync completed');
      
    } catch (e) {
      print('Error syncing with FHIR: $e');
      _syncProgressStreamController.add(FHIRSyncProgress(
        current: 0,
        total: 0,
        status: 'Sync failed',
        details: 'Error: $e',
      ));
    } finally {
      setState(() => _isConnected = false);
    }
  }

  // Set state
  void setState(Function fn) {
    fn();
    // Notify listeners if needed
  }

  // Get FHIR statistics
  Future<FHIRStatistics> getFHIRStatistics() async {
    try {
      return FHIRStatistics(
        totalPatients: 1250,
        totalObservations: 8750,
        totalMedications: 450,
        lastSyncTime: _lastSyncTime,
        isConnected: _isConnected,
        pendingSyncCount: _pendingSyncCount,
        serverInfo: _isConnected ? _getMockServerInfo() : null,
      );
    } catch (e) {
      print('Error getting FHIR statistics: $e');
      return FHIRStatistics(
        totalPatients: 0,
        totalObservations: 0,
        totalMedications: 0,
        lastSyncTime: null,
        isConnected: false,
        pendingSyncCount: 0,
        serverInfo: null,
      );
    }
  }

  // Dispose resources
  void dispose() {
    _statusStreamController.close();
    _syncProgressStreamController.close();
  }
}

// Data classes
class FHIRConfig {
  final String baseUrl;
  final String version;
  final int timeout;
  final int retryAttempts;
  final bool enableCaching;
  final int cacheExpiry;
  final FHIRAuthentication authentication;
  final String apiKey;
  final String clientId;
  final String clientSecret;
  final String scope;
  final String redirectUri;

  const FHIRConfig({
    required this.baseUrl,
    required this.version,
    required this.timeout,
    required this.retryAttempts,
    required this.enableCaching,
    required this.cacheExpiry,
    required this.authentication,
    required this.apiKey,
    required this.clientId,
    required this.clientSecret,
    required this.scope,
    required this.redirectUri,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'version': version,
      'timeout': timeout,
      'retryAttempts': retryAttempts,
      'enableCaching': enableCaching,
      'cacheExpiry': cacheExpiry,
      'authentication': authentication.name,
      'apiKey': apiKey,
      'clientId': clientId,
      'clientSecret': clientSecret,
      'scope': scope,
      'redirectUri': redirectUri,
    };
  }

  factory FHIRConfig.fromJson(Map<String, dynamic> json) {
    return FHIRConfig(
      baseUrl: json['baseUrl'] ?? '',
      version: json['version'] ?? 'R4',
      timeout: json['timeout'] ?? 30000,
      retryAttempts: json['retryAttempts'] ?? 3,
      enableCaching: json['enableCaching'] ?? true,
      cacheExpiry: json['cacheExpiry'] ?? 3600,
      authentication: FHIRAuthentication.values.firstWhere(
        (e) => e.name == json['authentication'],
        orElse: () => FHIRAuthentication.none,
      ),
      apiKey: json['apiKey'] ?? '',
      clientId: json['clientId'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      scope: json['scope'] ?? '',
      redirectUri: json['redirectUri'] ?? '',
    );
  }

  FHIRConfig copyWith({
    String? baseUrl,
    String? version,
    int? timeout,
    int? retryAttempts,
    bool? enableCaching,
    int? cacheExpiry,
    FHIRAuthentication? authentication,
    String? apiKey,
    String? clientId,
    String? clientSecret,
    String? scope,
    String? redirectUri,
  }) {
    return FHIRConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      version: version ?? this.version,
      timeout: timeout ?? this.timeout,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      enableCaching: enableCaching ?? this.enableCaching,
      cacheExpiry: cacheExpiry ?? this.cacheExpiry,
      authentication: authentication ?? this.authentication,
      apiKey: apiKey ?? this.apiKey,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      scope: scope ?? this.scope,
      redirectUri: redirectUri ?? this.redirectUri,
    );
  }
}

enum FHIRAuthentication {
  none,
  basic,
  bearer,
  oauth2,
  smart,
}

class FHIRPatient {
  final String id;
  final String identifier;
  final String name;
  final String gender;
  final DateTime birthDate;
  final String address;
  final String phone;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FHIRPatient({
    required this.id,
    required this.identifier,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  FHIRPatient copyWith({
    String? id,
    String? identifier,
    String? name,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? phone,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FHIRPatient(
      id: id ?? this.id,
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FHIRObservation {
  final String id;
  final String patientId;
  final String category;
  final String code;
  final String value;
  final String unit;
  final DateTime effectiveDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FHIRObservation({
    required this.id,
    required this.patientId,
    required this.category,
    required this.code,
    required this.value,
    required this.unit,
    required this.effectiveDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  FHIRObservation copyWith({
    String? id,
    String? patientId,
    String? category,
    String? code,
    String? value,
    String? unit,
    DateTime? effectiveDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FHIRObservation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      category: category ?? this.category,
      code: code ?? this.code,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FHIRMedication {
  final String id;
  final String name;
  final String code;
  final String manufacturer;
  final String form;
  final String strength;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FHIRMedication({
    required this.id,
    required this.name,
    required this.code,
    required this.manufacturer,
    required this.form,
    required this.strength,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  FHIRMedication copyWith({
    String? id,
    String? name,
    String? code,
    String? manufacturer,
    String? form,
    String? strength,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FHIRMedication(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      manufacturer: manufacturer ?? this.manufacturer,
      form: form ?? this.form,
      strength: strength ?? this.strength,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FHIRStatus {
  final bool isConnected;
  final DateTime timestamp;
  final String message;
  final Map<String, dynamic>? serverInfo;

  const FHIRStatus({
    required this.isConnected,
    required this.timestamp,
    required this.message,
    this.serverInfo,
  });
}

class FHIRSyncProgress {
  final int current;
  final int total;
  final String status;
  final String details;

  const FHIRSyncProgress({
    required this.current,
    required this.total,
    required this.status,
    required this.details,
  });
}

class FHIRStatistics {
  final int totalPatients;
  final int totalObservations;
  final int totalMedications;
  final DateTime? lastSyncTime;
  final bool isConnected;
  final int pendingSyncCount;
  final Map<String, dynamic>? serverInfo;

  const FHIRStatistics({
    required this.totalPatients,
    required this.totalObservations,
    required this.totalMedications,
    this.lastSyncTime,
    required this.isConnected,
    required this.pendingSyncCount,
    this.serverInfo,
  });
}
