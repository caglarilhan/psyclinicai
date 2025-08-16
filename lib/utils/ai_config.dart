

/// AI-specific configuration class for managing AI model settings and behavior
class AIConfig {
  // OpenAI Configuration
  static const String openaiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4',
  );
  
  static const String openaiModelTurbo = String.fromEnvironment(
    'OPENAI_MODEL_TURBO',
    defaultValue: 'gpt-3.5-turbo',
  );
  
  static const int openaiMaxTokens = int.fromEnvironment(
    'OPENAI_MAX_TOKENS',
    defaultValue: 4000,
  );
  
  static const double openaiTemperature = 0.7;
  
  static const double openaiTopP = 1.0;
  
  static const int openaiFrequencyPenalty = int.fromEnvironment(
    'OPENAI_FREQUENCY_PENALTY',
    defaultValue: 0,
  );
  
  static const int openaiPresencePenalty = int.fromEnvironment(
    'OPENAI_PRESENCE_PENALTY',
    defaultValue: 0,
  );
  
  // Claude Configuration
  static const String claudeModel = String.fromEnvironment(
    'CLAUDE_MODEL',
    defaultValue: 'claude-3-sonnet-20240229',
  );
  
  static const String claudeModelHaiku = String.fromEnvironment(
    'CLAUDE_MODEL_HAIKU',
    defaultValue: 'claude-3-haiku-20240307',
  );
  
  static const int claudeMaxTokens = int.fromEnvironment(
    'CLAUDE_MAX_TOKENS',
    defaultValue: 4000,
  );
  
  static const double claudeTemperature = 0.7;
  
  static const double claudeTopP = 1.0;
  
  // AI Behavior Configuration
  static const double confidenceThreshold = 0.8;
  
  static const double highConfidenceThreshold = 0.9;
  
  static const double criticalConfidenceThreshold = 0.95;
  
  static const int maxRetryAttempts = int.fromEnvironment(
    'AI_MAX_RETRY_ATTEMPTS',
    defaultValue: 3,
  );
  
  static const int retryDelayMs = int.fromEnvironment(
    'AI_RETRY_DELAY_MS',
    defaultValue: 1000,
  );
  
  static const int requestTimeoutMs = int.fromEnvironment(
    'AI_REQUEST_TIMEOUT_MS',
    defaultValue: 30000,
  );
  
  // Prompt Configuration
  static const String systemPromptPrefix = String.fromEnvironment(
    'AI_SYSTEM_PROMPT_PREFIX',
    defaultValue: 'You are a world-class AI assistant specialized in psychological and psychiatric care. ',
  );
  
  static const String diagnosisPromptTemplate = String.fromEnvironment(
    'AI_DIAGNOSIS_PROMPT_TEMPLATE',
    defaultValue: 'Analyze the following patient data and provide a comprehensive diagnosis: ',
  );
  
  static const String treatmentPromptTemplate = String.fromEnvironment(
    'AI_TREATMENT_PROMPT_TEMPLATE',
    defaultValue: 'Based on the diagnosis, recommend appropriate treatment options: ',
  );
  
  static const String crisisPromptTemplate = String.fromEnvironment(
    'AI_CRISIS_PROMPT_TEMPLATE',
    defaultValue: 'Assess the following crisis situation and provide immediate intervention guidance: ',
  );
  
  static const String medicationPromptTemplate = String.fromEnvironment(
    'AI_MEDICATION_PROMPT_TEMPLATE',
    defaultValue: 'Review the medication history and suggest appropriate medications: ',
  );
  
  // Safety Configuration
  static const bool enableContentFiltering = bool.fromEnvironment(
    'AI_ENABLE_CONTENT_FILTERING',
    defaultValue: true,
  );
  
  static const bool enableBiasDetection = bool.fromEnvironment(
    'AI_ENABLE_BIAS_DETECTION',
    defaultValue: true,
  );
  
  static const bool enableFactChecking = bool.fromEnvironment(
    'AI_ENABLE_FACT_CHECKING',
    defaultValue: true,
  );
  
  static const List<String> prohibitedTopics = [
    'self-harm',
    'suicide',
    'violence',
    'illegal_activities',
    'harmful_advice',
  ];
  
  static const List<String> sensitiveTopics = [
    'mental_health_crisis',
    'substance_abuse',
    'trauma',
    'grief',
    'relationship_issues',
  ];
  
  // Cultural Sensitivity Configuration
  static const bool enableCulturalAdaptation = bool.fromEnvironment(
    'AI_ENABLE_CULTURAL_ADAPTATION',
    defaultValue: true,
  );
  
  static const bool enableLanguageLocalization = bool.fromEnvironment(
    'AI_ENABLE_LANGUAGE_LOCALIZATION',
    defaultValue: true,
  );
  
  static const bool enableReligiousConsideration = bool.fromEnvironment(
    'AI_ENABLE_RELIGIOUS_CONSIDERATION',
    defaultValue: true,
  );
  
  static const Map<String, List<String>> culturalNorms = {
    'TR': ['family_centric', 'respect_elders', 'community_support'],
    'US': ['individualism', 'professional_boundaries', 'evidence_based'],
    'ES': ['family_values', 'social_connections', 'emotional_expression'],
    'DE': ['efficiency', 'privacy', 'structured_approach'],
    'FR': ['intellectual_discourse', 'personal_autonomy', 'cultural_appreciation'],
    'GB': ['reserved_communication', 'professional_standards', 'evidence_based'],
    'CA': ['multicultural_sensitivity', 'inclusive_language', 'accessibility'],
    'AU': ['casual_communication', 'egalitarian_values', 'outdoor_lifestyle'],
    'JP': ['harmony', 'respect_hierarchy', 'group_consensus'],
    'KR': ['education_emphasis', 'family_responsibility', 'social_harmony'],
  };
  
  // Medical Standards Configuration
  static const bool enableICD11Standards = bool.fromEnvironment(
    'AI_ENABLE_ICD11_STANDARDS',
    defaultValue: true,
  );
  
  static const bool enableDSM5TRStandards = bool.fromEnvironment(
    'AI_ENABLE_DSM5TR_STANDARDS',
    defaultValue: true,
  );
  
  static const bool enableWHOGuidelines = bool.fromEnvironment(
    'AI_ENABLE_WHO_GUIDELINES',
    defaultValue: true,
  );
  
  static const bool enableEvidenceBasedMedicine = bool.fromEnvironment(
    'AI_ENABLE_EVIDENCE_BASED_MEDICINE',
    defaultValue: true,
  );
  
  // Performance Configuration
  static const int maxConcurrentRequests = int.fromEnvironment(
    'AI_MAX_CONCURRENT_REQUESTS',
    defaultValue: 5,
  );
  
  static const int requestQueueSize = int.fromEnvironment(
    'AI_REQUEST_QUEUE_SIZE',
    defaultValue: 100,
  );
  
  static const bool enableRequestCaching = bool.fromEnvironment(
    'AI_ENABLE_REQUEST_CACHING',
    defaultValue: true,
  );
  
  static const int cacheExpirationMinutes = int.fromEnvironment(
    'AI_CACHE_EXPIRATION_MINUTES',
    defaultValue: 60,
  );
  
  static const bool enableResponseOptimization = bool.fromEnvironment(
    'AI_ENABLE_RESPONSE_OPTIMIZATION',
    defaultValue: true,
  );
  
  // Monitoring Configuration
  static const bool enablePerformanceMonitoring = bool.fromEnvironment(
    'AI_ENABLE_PERFORMANCE_MONITORING',
    defaultValue: true,
  );
  
  static const bool enableQualityMetrics = bool.fromEnvironment(
    'AI_ENABLE_QUALITY_METRICS',
    defaultValue: true,
  );
  
  static const bool enableErrorTracking = bool.fromEnvironment(
    'AI_ENABLE_ERROR_TRACKING',
    defaultValue: true,
  );
  
  static const bool enableUsageAnalytics = bool.fromEnvironment(
    'AI_ENABLE_USAGE_ANALYTICS',
    defaultValue: true,
  );
  
  // Validation Methods
  static bool get isOpenAIConfigured {
    return const String.fromEnvironment('OPENAI_API_KEY').isNotEmpty;
  }
  
  static bool get isClaudeConfigured {
    return const String.fromEnvironment('CLAUDE_API_KEY').isNotEmpty;
  }
  
  static bool get hasValidConfiguration {
    return isOpenAIConfigured || isClaudeConfigured;
  }
  
  static bool get isProductionReady {
    return hasValidConfiguration && enableContentFiltering && enableBiasDetection;
  }
  
  // Model Selection
  static String get primaryModel {
    if (isOpenAIConfigured) {
      return openaiModel;
    } else if (isClaudeConfigured) {
      return claudeModel;
    }
    return 'mock'; // Fallback to mock implementation
  }
  
  static String get fallbackModel {
    if (isOpenAIConfigured) {
      return openaiModelTurbo;
    } else if (isClaudeConfigured) {
      return claudeModelHaiku;
    }
    return 'mock';
  }
  
  // Prompt Generation
  static String generateSystemPrompt(String context) {
    return '$systemPromptPrefix$context';
  }
  
  static String generateDiagnosisPrompt(String patientData) {
    return '$diagnosisPromptTemplate$patientData';
  }
  
  static String generateTreatmentPrompt(String diagnosis) {
    return '$treatmentPromptTemplate$diagnosis';
  }
  
  static String generateCrisisPrompt(String crisisData) {
    return '$crisisPromptTemplate$crisisData';
  }
  
  static String generateMedicationPrompt(String medicationData) {
    return '$medicationPromptTemplate$medicationData';
  }
  
  // Safety Validation
  static bool isContentSafe(String content) {
    if (!enableContentFiltering) return true;
    
    final lowerContent = content.toLowerCase();
    for (final topic in prohibitedTopics) {
      if (lowerContent.contains(topic)) {
        return false;
      }
    }
    return true;
  }
  
  static bool requiresSpecialHandling(String content) {
    final lowerContent = content.toLowerCase();
    for (final topic in sensitiveTopics) {
      if (lowerContent.contains(topic)) {
        return true;
      }
    }
    return false;
  }
  
  // Cultural Adaptation
  static List<String> getCulturalNorms(String countryCode) {
    return culturalNorms[countryCode.toUpperCase()] ?? [];
  }
  
  static bool isCulturallySensitive(String countryCode) {
    return enableCulturalAdaptation && culturalNorms.containsKey(countryCode.toUpperCase());
  }
  
  // Debug Information
  static Map<String, dynamic> get debugInfo {
    return {
      'openaiModel': openaiModel,
      'claudeModel': claudeModel,
      'confidenceThreshold': confidenceThreshold,
      'maxRetryAttempts': maxRetryAttempts,
      'requestTimeoutMs': requestTimeoutMs,
      'enableContentFiltering': enableContentFiltering,
      'enableBiasDetection': enableBiasDetection,
      'enableCulturalAdaptation': enableCulturalAdaptation,
      'enableICD11Standards': enableICD11Standards,
      'enableDSM5TRStandards': enableDSM5TRStandards,
      'enableWHOGuidelines': enableWHOGuidelines,
      'maxConcurrentRequests': maxConcurrentRequests,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'isOpenAIConfigured': isOpenAIConfigured,
      'isClaudeConfigured': isClaudeConfigured,
      'hasValidConfiguration': hasValidConfiguration,
      'isProductionReady': isProductionReady,
      'primaryModel': primaryModel,
      'fallbackModel': fallbackModel,
    };
  }
}
