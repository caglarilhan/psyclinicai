import 'package:flutter/foundation.dart';

/// Environment configuration class for managing app-wide configuration
class EnvConfig {
  // API Configuration
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  static const String claudeApiKey = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: '',
  );
  
  static const String openaiBaseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );
  
  static const String claudeBaseUrl = String.fromEnvironment(
    'CLAUDE_BASE_URL',
    defaultValue: 'https://api.anthropic.com/v1',
  );
  
  // App Configuration
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'PsyClinic AI',
  );
  
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );
  
  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  
  // Feature Flags
  static const bool enableAIFeatures = bool.fromEnvironment(
    'ENABLE_AI_FEATURES',
    defaultValue: true,
  );
  
  static const bool enableFlagAI = bool.fromEnvironment(
    'ENABLE_FLAG_AI',
    defaultValue: true,
  );
  
  static const bool enableDiagnosisAI = bool.fromEnvironment(
    'ENABLE_DIAGNOSIS_AI',
    defaultValue: true,
  );
  
  static const bool enableTelemedicine = bool.fromEnvironment(
    'ENABLE_TELEMEDICINE',
    defaultValue: true,
  );
  
  // Security Configuration
  static const bool enableEncryption = bool.fromEnvironment(
    'ENABLE_ENCRYPTION',
    defaultValue: true,
  );
  
  static const bool enableBiometricAuth = bool.fromEnvironment(
    'ENABLE_BIOMETRIC_AUTH',
    defaultValue: true,
  );
  
  static const bool enableMultiFactorAuth = bool.fromEnvironment(
    'ENABLE_MULTI_FACTOR_AUTH',
    defaultValue: true,
  );
  
  // Performance Configuration
  static const int maxConcurrentAIRequests = int.fromEnvironment(
    'MAX_CONCURRENT_AI_REQUESTS',
    defaultValue: 5,
  );
  
  static const int aiRequestTimeout = int.fromEnvironment(
    'AI_REQUEST_TIMEOUT',
    defaultValue: 30000,
  );
  
  static const int maxRetryAttempts = int.fromEnvironment(
    'MAX_RETRY_ATTEMPTS',
    defaultValue: 3,
  );
  
  // Logging Configuration
  static const bool enableDebugLogging = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGGING',
    defaultValue: kDebugMode,
  );
  
  static const bool enablePerformanceLogging = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_LOGGING',
    defaultValue: true,
  );
  
  static const bool enableSecurityLogging = bool.fromEnvironment(
    'ENABLE_SECURITY_LOGGING',
    defaultValue: true,
  );
  
  // Database Configuration
  static const String databaseUrl = String.fromEnvironment(
    'DATABASE_URL',
    defaultValue: '',
  );
  
  static const String databaseName = String.fromEnvironment(
    'DATABASE_NAME',
    defaultValue: 'psyclinic_ai.db',
  );
  
  // Analytics Configuration
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  
  static const String analyticsKey = String.fromEnvironment(
    'ANALYTICS_KEY',
    defaultValue: '',
  );
  
  // Notification Configuration
  static const bool enablePushNotifications = bool.fromEnvironment(
    'ENABLE_PUSH_NOTIFICATIONS',
    defaultValue: true,
  );
  
  static const String fcmServerKey = String.fromEnvironment(
    'FCM_SERVER_KEY',
    defaultValue: '',
  );
  
  // Multi-Country Configuration
  static const String defaultCountry = String.fromEnvironment(
    'DEFAULT_COUNTRY',
    defaultValue: 'TR',
  );
  
  static const List<String> supportedCountries = [
    'TR', // Turkey
    'US', // United States
    'ES', // Spain
    'DE', // Germany
    'FR', // France
    'GB', // United Kingdom
    'CA', // Canada
    'AU', // Australia
    'JP', // Japan
    'KR', // South Korea
  ];
  
  // Compliance Configuration
  static const bool enableHIPAACompliance = bool.fromEnvironment(
    'ENABLE_HIPAA_COMPLIANCE',
    defaultValue: true,
  );
  
  static const bool enableGDPRCompliance = bool.fromEnvironment(
    'ENABLE_GDPR_COMPLIANCE',
    defaultValue: true,
  );
  
  static const bool enableKVKKCompliance = bool.fromEnvironment(
    'ENABLE_KVKK_COMPLIANCE',
    defaultValue: true,
  );
  
  // AI Model Configuration
  static const String defaultAIModel = String.fromEnvironment(
    'DEFAULT_AI_MODEL',
    defaultValue: 'gpt-4',
  );
  
  static const String fallbackAIModel = String.fromEnvironment(
    'FALLBACK_AI_MODEL',
    defaultValue: 'gpt-3.5-turbo',
  );
  
  static const double aiConfidenceThreshold = 0.8;
  
  // Crisis Intervention Configuration
  static const bool enableCrisisIntervention = bool.fromEnvironment(
    'ENABLE_CRISIS_INTERVENTION',
    defaultValue: true,
  );
  
  static const int crisisResponseTime = int.fromEnvironment(
    'CRISIS_RESPONSE_TIME',
    defaultValue: 300, // 5 minutes
  );
  
  static const bool enableEmergencyProtocols = bool.fromEnvironment(
    'ENABLE_EMERGENCY_PROTOCOLS',
    defaultValue: true,
  );
  
  // Validation Methods
  static bool get isConfigured {
    return openaiApiKey.isNotEmpty || claudeApiKey.isNotEmpty;
  }
  
  static bool get hasValidAPIKeys {
    return openaiApiKey.isNotEmpty || claudeApiKey.isNotEmpty;
  }
  
  static bool get isProductionReady {
    return isProduction && hasValidAPIKeys && enableEncryption;
  }
  
  // Debug Information
  static Map<String, dynamic> get debugInfo {
    return {
      'environment': environment,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
      'enableAIFeatures': enableAIFeatures,
      'enableFlagAI': enableFlagAI,
      'enableDiagnosisAI': enableDiagnosisAI,
      'enableTelemedicine': enableTelemedicine,
      'enableEncryption': enableEncryption,
      'enableBiometricAuth': enableBiometricAuth,
      'enableMultiFactorAuth': enableMultiFactorAuth,
      'maxConcurrentAIRequests': maxConcurrentAIRequests,
      'aiRequestTimeout': aiRequestTimeout,
      'maxRetryAttempts': maxRetryAttempts,
      'enableDebugLogging': enableDebugLogging,
      'enablePerformanceLogging': enablePerformanceLogging,
      'enableSecurityLogging': enableSecurityLogging,
      'enableAnalytics': enableAnalytics,
      'enablePushNotifications': enablePushNotifications,
      'defaultCountry': defaultCountry,
      'supportedCountries': supportedCountries,
      'enableHIPAACompliance': enableHIPAACompliance,
      'enableGDPRCompliance': enableGDPRCompliance,
      'enableKVKKCompliance': enableKVKKCompliance,
      'defaultAIModel': defaultAIModel,
      'fallbackAIModel': fallbackAIModel,
      'aiConfidenceThreshold': aiConfidenceThreshold,
      'enableCrisisIntervention': enableCrisisIntervention,
      'crisisResponseTime': crisisResponseTime,
      'enableEmergencyProtocols': enableEmergencyProtocols,
      'isConfigured': isConfigured,
      'hasValidAPIKeys': hasValidAPIKeys,
      'isProductionReady': isProductionReady,
    };
  }
}
