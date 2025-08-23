# 👨‍💻 PsyClinicAI Developer Guide

## 🎯 Welcome Developers!

This guide will help you understand the PsyClinicAI architecture, set up your development environment, and contribute to the platform. Whether you're building integrations, extending features, or contributing to the core platform, this guide has everything you need.

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Development Setup](#development-setup)
3. [Code Structure](#code-structure)
4. [API Development](#api-development)
5. [Frontend Development](#frontend-development)
6. [AI Services](#ai-services)
7. [Security Implementation](#security-implementation)
8. [Testing](#testing)
9. [Deployment](#deployment)
10. [Contributing](#contributing)

## 🏗️ Architecture Overview

### System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   API Gateway   │    │   Core Services │
│   (Flutter)     │◄──►│   (Rate Limit)  │◄──►│   (Business     │
│                 │    │   (Auth)        │    │    Logic)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   AI Services   │    │   Data Layer    │
                       │   (ML Models)   │    │   (Database)    │
                       │   (Analytics)   │    │   (Cache)       │
                       └─────────────────┘    └─────────────────┘
```

### Technology Stack

#### **Frontend**
- **Framework**: Flutter 3.29+
- **Language**: Dart 3.0+
- **State Management**: BLoC Pattern
- **UI Components**: Material Design 3

#### **Backend Services**
- **Runtime**: Dart VM
- **Framework**: Shelf (HTTP server)
- **Database**: PostgreSQL 15+
- **Cache**: Redis 7+
- **Message Queue**: Redis Streams

#### **AI & ML**
- **Core Engine**: TensorFlow Lite
- **Voice Analysis**: Librosa + Custom Models
- **Facial Analysis**: OpenCV + Deep Learning
- **Natural Language**: Custom NLP Pipeline

#### **Infrastructure**
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack

## 🚀 Development Setup

### Prerequisites

#### **Required Software**
```bash
# Flutter SDK
flutter --version  # Should be 3.29.0 or higher

# Dart SDK
dart --version     # Should be 3.0.0 or higher

# PostgreSQL
psql --version     # Should be 15.0 or higher

# Redis
redis-server --version  # Should be 7.0 or higher

# Docker
docker --version   # Should be 20.10 or higher
```

#### **System Requirements**
- **OS**: macOS 12+, Ubuntu 20.04+, Windows 11
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 20GB available space
- **CPU**: 4 cores minimum, 8 cores recommended

### Environment Setup

#### **1. Clone Repository**
```bash
git clone https://github.com/caglarilhan/psyclinicai.git
cd psyclinicai
```

#### **2. Install Dependencies**
```bash
# Flutter dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Install development tools
dart pub global activate dart_style
dart pub global activate dart_analyzer
```

#### **3. Database Setup**
```bash
# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database
sudo -u postgres createdb psyclinicai_dev
sudo -u postgres createuser psyclinicai_dev

# Set password
sudo -u postgres psql
postgres=# ALTER USER psyclinicai_dev WITH PASSWORD 'dev_password';
postgres=# GRANT ALL PRIVILEGES ON DATABASE psyclinicai_dev TO psyclinicai_dev;
postgres=# \q
```

#### **4. Redis Setup**
```bash
# Start Redis
sudo systemctl start redis
sudo systemctl enable redis

# Test connection
redis-cli ping  # Should return PONG
```

#### **5. Environment Configuration**
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

**Environment Variables**:
```bash
# Database
DATABASE_URL=postgresql://psyclinicai_dev:dev_password@localhost:5432/psyclinicai_dev

# Redis
REDIS_URL=redis://localhost:6379

# Security
JWT_SECRET=your-super-secret-jwt-key-here
ENCRYPTION_KEY=your-32-character-encryption-key
ENCRYPTION_IV=your-16-character-iv

# AI Services
AI_MODEL_PATH=./models/
AI_API_KEY=your-ai-service-key

# External Services
FHIR_SERVER_URL=https://fhir.example.com
PAYMENT_GATEWAY_KEY=your-payment-key
```

### Development Tools

#### **IDE Setup**
- **VS Code**: Install Flutter and Dart extensions
- **Android Studio**: Configure Flutter SDK
- **IntelliJ IDEA**: Install Flutter plugin

#### **Code Quality Tools**
```bash
# Code formatting
dart format lib/

# Static analysis
flutter analyze

# Code coverage
flutter test --coverage

# Performance profiling
flutter run --profile
```

## 📁 Code Structure

### Directory Organization

```
psyclinicai/
├── lib/                          # Main application code
│   ├── main.dart                # Application entry point
│   ├── app/                     # App configuration
│   ├── models/                  # Data models
│   ├── services/                # Business logic services
│   ├── widgets/                 # UI components
│   ├── utils/                   # Utility functions
│   └── constants/               # App constants
├── test/                        # Test files
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── widget/                  # Widget tests
├── docs/                        # Documentation
├── deployment/                  # Deployment configs
├── scripts/                     # Build and utility scripts
└── pubspec.yaml                 # Dependencies
```

### Key Components

#### **Models** (`lib/models/`)
```dart
// Example: Patient model
@JsonSerializable()
class Patient {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String email;
  final String? phone;
  final String? diagnosis;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.email,
    this.phone,
    this.diagnosis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => 
      _$PatientFromJson(json);
  
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
```

#### **Services** (`lib/services/`)
```dart
// Example: Patient service
class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  Future<List<Patient>> getPatients({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    // Implementation
  }

  Future<Patient> createPatient(Patient patient) async {
    // Implementation
  }

  Future<Patient> updatePatient(String id, Patient patient) async {
    // Implementation
  }

  Future<void> deletePatient(String id) async {
    // Implementation
  }
}
```

#### **Widgets** (`lib/widgets/`)
```dart
// Example: Patient list widget
class PatientListWidget extends StatefulWidget {
  final Function(Patient) onPatientSelected;
  
  const PatientListWidget({
    Key? key,
    required this.onPatientSelected,
  }) : super(key: key);

  @override
  State<PatientListWidget> createState() => _PatientListWidgetState();
}

class _PatientListWidgetState extends State<PatientListWidget> {
  late Future<List<Patient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService().getPatients();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Patient>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        final patients = snapshot.data ?? [];
        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return ListTile(
              title: Text(patient.name),
              subtitle: Text(patient.email),
              onTap: () => widget.onPatientSelected(patient),
            );
          },
        );
      },
    );
  }
}
```

## 🔌 API Development

### REST API Structure

#### **Endpoint Patterns**
```dart
// Base URL structure
const String baseUrl = 'https://api.psyclinicai.com/v1';

// Resource endpoints
const String patientsEndpoint = '$baseUrl/patients';
const String sessionsEndpoint = '$baseUrl/sessions';
const String aiDiagnosisEndpoint = '$baseUrl/ai/diagnosis';
```

#### **HTTP Methods**
```dart
// GET - Retrieve resources
Future<List<Patient>> getPatients() async {
  final response = await http.get(
    Uri.parse('$baseUrl/patients'),
    headers: await _getAuthHeaders(),
  );
  
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((json) => Patient.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load patients');
  }
}

// POST - Create resources
Future<Patient> createPatient(Patient patient) async {
  final response = await http.post(
    Uri.parse('$baseUrl/patients'),
    headers: await _getAuthHeaders(),
    body: json.encode(patient.toJson()),
  );
  
  if (response.statusCode == 201) {
    return Patient.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create patient');
  }
}

// PUT - Update resources
Future<Patient> updatePatient(String id, Patient patient) async {
  final response = await http.put(
    Uri.parse('$baseUrl/patients/$id'),
    headers: await _getAuthHeaders(),
    body: json.encode(patient.toJson()),
  );
  
  if (response.statusCode == 200) {
    return Patient.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update patient');
  }
}

// DELETE - Remove resources
Future<void> deletePatient(String id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/patients/$id'),
    headers: await _getAuthHeaders(),
  );
  
  if (response.statusCode != 204) {
    throw Exception('Failed to delete patient');
  }
}
```

### Authentication & Authorization

#### **JWT Token Management**
```dart
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token');
    }
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
```

#### **Role-Based Access Control**
```dart
enum UserRole {
  admin,
  clinician,
  assistant,
  patient,
}

class PermissionService {
  static bool canAccessPatient(UserRole role, String patientId) {
    switch (role) {
      case UserRole.admin:
        return true;
      case UserRole.clinician:
        return _isAssignedClinician(patientId);
      case UserRole.assistant:
        return _isAssignedAssistant(patientId);
      case UserRole.patient:
        return _isOwnPatient(patientId);
    }
  }
  
  static bool canModifyPatient(UserRole role, String patientId) {
    return role == UserRole.admin || 
           (role == UserRole.clinician && _isAssignedClinician(patientId));
  }
}
```

## 🎨 Frontend Development

### Flutter Widget Architecture

#### **Custom Widgets**
```dart
// Example: Custom card widget
class PsyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  
  const PsyCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2.0,
      color: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
```

#### **State Management with BLoC**
```dart
// Example: Patient BLoC
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientService _patientService;
  
  PatientBloc(this._patientService) : super(PatientInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<CreatePatient>(_onCreatePatient);
    on<UpdatePatient>(_onUpdatePatient);
    on<DeletePatient>(_onDeletePatient);
  }
  
  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    
    try {
      final patients = await _patientService.getPatients(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );
      emit(PatientLoaded(patients));
    } catch (error) {
      emit(PatientError(error.toString()));
    }
  }
  
  Future<void> _onCreatePatient(
    CreatePatient event,
    Emitter<PatientState> emit,
  ) async {
    try {
      final patient = await _patientService.createPatient(event.patient);
      final currentState = state;
      if (currentState is PatientLoaded) {
        emit(PatientLoaded([...currentState.patients, patient]));
      }
    } catch (error) {
      emit(PatientError(error.toString()));
    }
  }
}
```

### UI/UX Guidelines

#### **Design System**
```dart
// Color palette
class PsyColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  
  // Semantic colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
}

// Typography
class PsyTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
}
```

#### **Responsive Design**
```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

## 🤖 AI Services

### AI Service Architecture

#### **Service Interface**
```dart
abstract class AIService {
  Future<AIAnalysisResult> analyzeVoice(AudioData audio);
  Future<AIAnalysisResult> analyzeFacial(ImageData image);
  Future<AIDiagnosisResult> generateDiagnosis(DiagnosisRequest request);
  Future<PredictionResult> generatePrediction(PredictionRequest request);
}

class AIServiceImpl implements AIService {
  final TensorFlowLite _tflite;
  final VoiceAnalyzer _voiceAnalyzer;
  final FacialAnalyzer _facialAnalyzer;
  final DiagnosisEngine _diagnosisEngine;
  
  AIServiceImpl({
    required TensorFlowLite tflite,
    required VoiceAnalyzer voiceAnalyzer,
    required FacialAnalyzer facialAnalyzer,
    required DiagnosisEngine diagnosisEngine,
  }) : _tflite = tflite,
       _voiceAnalyzer = voiceAnalyzer,
       _facialAnalyzer = facialAnalyzer,
       _diagnosisEngine = diagnosisEngine;

  @override
  Future<AIAnalysisResult> analyzeVoice(AudioData audio) async {
    try {
      // Preprocess audio
      final processedAudio = await _voiceAnalyzer.preprocess(audio);
      
      // Run AI model
      final result = await _tflite.runModel(
        modelPath: 'assets/models/voice_analysis.tflite',
        input: processedAudio,
      );
      
      // Post-process results
      return _voiceAnalyzer.postprocess(result);
    } catch (e) {
      throw AIAnalysisException('Voice analysis failed: $e');
    }
  }
}
```

#### **Model Management**
```dart
class ModelManager {
  static const Map<String, String> _models = {
    'voice_analysis': 'assets/models/voice_analysis.tflite',
    'facial_analysis': 'assets/models/facial_analysis.tflite',
    'diagnosis': 'assets/models/diagnosis.tflite',
    'prediction': 'assets/models/prediction.tflite',
  };
  
  static Future<void> downloadModels() async {
    for (final entry in _models.entries) {
      await _downloadModel(entry.key, entry.value);
    }
  }
  
  static Future<void> _downloadModel(String name, String path) async {
    // Implementation for model download
  }
  
  static Future<void> updateModels() async {
    // Implementation for model updates
  }
}
```

### AI Model Integration

#### **TensorFlow Lite Integration**
```dart
class TensorFlowLite {
  static const MethodChannel _channel = MethodChannel('tensorflow_lite');
  
  Future<Map<String, dynamic>> runModel({
    required String modelPath,
    required List<double> input,
    List<int>? inputShape,
  }) async {
    try {
      final result = await _channel.invokeMethod('runModel', {
        'modelPath': modelPath,
        'input': input,
        'inputShape': inputShape,
      });
      
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw AIException('Model execution failed: $e');
    }
  }
  
  Future<void> loadModel(String modelPath) async {
    await _channel.invokeMethod('loadModel', {
      'modelPath': modelPath,
    });
  }
}
```

## 🔐 Security Implementation

### Encryption & Security

#### **Data Encryption**
```dart
class EncryptionService {
  static const String _algorithm = 'AES-256-CBC';
  late final enc.Key _key;
  late final enc.IV _iv;
  late final enc.Encrypter _encrypter;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? storedKey = prefs.getString('encryption_key');
    String? storedIV = prefs.getString('encryption_iv');
    
    if (storedKey == null || storedIV == null) {
      // Generate new keys
      final key = enc.Key.fromSecureRandom(32);
      final iv = enc.IV.fromSecureRandom(16);
      
      storedKey = base64.encode(key.bytes);
      storedIV = base64.encode(iv.bytes);
      
      await prefs.setString('encryption_key', storedKey);
      await prefs.setString('encryption_iv', storedIV);
    }
    
    _key = enc.Key.fromBase64(storedKey);
    _iv = enc.IV.fromBase64(storedIV);
    _encrypter = enc.Encrypter(enc.AES(_key));
  }
  
  String encrypt(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }
  
  String decrypt(String encryptedData) {
    final encrypted = enc.Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
```

#### **Secure Storage**
```dart
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
  
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

### Audit Logging

#### **Audit Service**
```dart
class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();
  
  Future<void> logEvent({
    required String userId,
    required String action,
    required String resource,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    final auditLog = AuditLog(
      id: _generateId(),
      userId: userId,
      action: action,
      resource: resource,
      details: details,
      metadata: metadata,
      timestamp: DateTime.now(),
      ipAddress: await _getClientIP(),
      userAgent: await _getUserAgent(),
    );
    
    await _saveAuditLog(auditLog);
  }
  
  Future<List<AuditLog>> getAuditLogs({
    String? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    // Implementation for retrieving audit logs
  }
}
```

## 🧪 Testing

### Testing Strategy

#### **Test Types**
- **Unit Tests**: Individual function/class testing
- **Integration Tests**: Service interaction testing
- **Widget Tests**: UI component testing
- **End-to-End Tests**: Complete workflow testing

#### **Test Structure**
```dart
// Example: Patient service test
void main() {
  group('PatientService Tests', () {
    late PatientService patientService;
    late MockDatabase mockDatabase;
    
    setUp(() {
      mockDatabase = MockDatabase();
      patientService = PatientService(database: mockDatabase);
    });
    
    group('getPatients', () {
      test('should return list of patients', () async {
        // Arrange
        final mockPatients = [
          Patient(id: '1', name: 'John Doe', email: 'john@example.com'),
          Patient(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
        ];
        
        when(mockDatabase.query('patients')).thenAnswer(
          (_) async => mockPatients,
        );
        
        // Act
        final result = await patientService.getPatients();
        
        // Assert
        expect(result, equals(mockPatients));
        verify(mockDatabase.query('patients')).called(1);
      });
      
      test('should handle database errors', () async {
        // Arrange
        when(mockDatabase.query('patients')).thenThrow(
          DatabaseException('Connection failed'),
        );
        
        // Act & Assert
        expect(
          () => patientService.getPatients(),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}
```

### Test Configuration

#### **Test Environment Setup**
```dart
class TestConfig {
  static Future<void> initialize() async {
    // Set up test database
    await _setupTestDatabase();
    
    // Initialize test services
    await _initializeTestServices();
    
    // Set up test data
    await _setupTestData();
  }
  
  static Future<void> cleanup() async {
    // Clean up test database
    await _cleanupTestDatabase();
    
    // Reset test services
    await _resetTestServices();
  }
}
```

## 🚀 Deployment

### Build Process

#### **Release Build**
```bash
# Build for production
flutter build apk --release
flutter build ios --release

# Build for web
flutter build web --release

# Build for desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

#### **Docker Build**
```dockerfile
# Dockerfile
FROM dart:3.0 AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080
CMD ["/app/bin/server"]
```

### Deployment Scripts

#### **Deploy Script**
```bash
#!/bin/bash
# deploy.sh

set -e

echo "🚀 Starting deployment..."

# Build application
echo "📦 Building application..."
flutter build web --release

# Run tests
echo "🧪 Running tests..."
flutter test

# Deploy to server
echo "🌐 Deploying to server..."
rsync -avz --delete build/web/ user@server:/var/www/psyclinicai/

# Restart services
echo "🔄 Restarting services..."
ssh user@server "sudo systemctl restart psyclinicai"

echo "✅ Deployment completed successfully!"
```

## 🤝 Contributing

### Contribution Guidelines

#### **Code Standards**
- Follow Dart style guide
- Use meaningful variable names
- Add comprehensive documentation
- Write unit tests for new features
- Ensure code coverage > 80%

#### **Pull Request Process**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Update documentation
6. Submit pull request

#### **Commit Message Format**
```
type(scope): description

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(ai): add voice analysis service
fix(auth): resolve JWT token expiration issue
docs(api): update authentication documentation
test(patient): add patient service unit tests
```

### Development Workflow

#### **Feature Development**
1. **Planning**: Define requirements and design
2. **Implementation**: Write code following standards
3. **Testing**: Create comprehensive tests
4. **Documentation**: Update relevant docs
5. **Review**: Submit for code review
6. **Integration**: Merge and deploy

#### **Bug Fixes**
1. **Reproduction**: Create minimal reproduction case
2. **Investigation**: Identify root cause
3. **Fix**: Implement solution
4. **Testing**: Verify fix works
5. **Documentation**: Update changelog
6. **Deployment**: Deploy fix

---

## 📞 Support & Resources

### Developer Resources
- **API Documentation**: [docs.psyclinicai.com/api](https://docs.psyclinicai.com/api)
- **SDK Downloads**: [github.com/psyclinicai/sdk](https://github.com/psyclinicai/sdk)
- **Code Examples**: [github.com/psyclinicai/examples](https://github.com/psyclinicai/examples)
- **Community Forum**: [community.psyclinicai.com](https://community.psyclinicai.com)

### Getting Help
- **Documentation**: [docs.psyclinicai.com](https://docs.psyclinicai.com)
- **GitHub Issues**: [github.com/psyclinicai/issues](https://github.com/psyclinicai/issues)
- **Developer Chat**: [discord.gg/psyclinicai](https://discord.gg/psyclinicai)
- **Email Support**: dev-support@psyclinicai.com

---

**Last Updated**: January 2024  
**Version**: 2.0.0  
**For**: PsyClinicAI Developers  
**Maintained by**: PsyClinicAI Development Team
