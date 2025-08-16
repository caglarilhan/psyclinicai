import 'package:flutter/foundation.dart';

class EnvConfig {
  // OpenAI Configuration
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY',
  );
  
  static const String openaiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4-turbo-preview',
  );
  
  static const int openaiMaxTokens = int.fromEnvironment(
    'OPENAI_MAX_TOKENS',
    defaultValue: 2000,
  );
  
  static const double openaiTemperature = 0.7; // const value olarak tanımla

  // Claude Configuration
  static const String claudeApiKey = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: 'YOUR_CLAUDE_API_KEY',
  );
  
  static const String claudeModel = String.fromEnvironment(
    'CLAUDE_MODEL',
    defaultValue: 'claude-3-sonnet-20240229',
  );

  // AI Service Configuration
  static const int maxRequestsPerMinute = int.fromEnvironment(
    'AI_MAX_REQUESTS_PER_MINUTE',
    defaultValue: 60,
  );
  
  static const int timeoutSeconds = int.fromEnvironment(
    'AI_TIMEOUT_SECONDS',
    defaultValue: 30,
  );
  
  static const bool enableFallback = true; // const value olarak tanımla
  
  static const String logLevel = String.fromEnvironment(
    'AI_LOG_LEVEL',
    defaultValue: 'info',
  );

  // Development Settings
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );
  
  static const bool mockAiResponses = bool.fromEnvironment(
    'MOCK_AI_RESPONSES',
    defaultValue: false,
  );

  // Environment Detection
  static bool get isProduction => !debugMode;
  static bool get isDevelopment => debugMode;
  static bool get isTest => !kReleaseMode;

  // API Key Validation
  static bool get hasValidOpenAIKey => 
      openaiApiKey.isNotEmpty && openaiApiKey != 'YOUR_OPENAI_API_KEY';
  
  static bool get hasValidClaudeKey => 
      claudeApiKey.isNotEmpty && claudeApiKey != 'YOUR_CLAUDE_API_KEY';

  // Logging Configuration
  static bool get shouldLog => logLevel != 'none';
  static bool get shouldLogDebug => logLevel == 'debug';
  static bool get shouldLogInfo => logLevel == 'info' || logLevel == 'debug';
  static bool get shouldLogWarning => logLevel == 'warning' || shouldLogInfo;
  static bool get shouldLogError => logLevel == 'error' || shouldLogWarning;
}
