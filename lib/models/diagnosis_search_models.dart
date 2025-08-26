// Lightweight models for diagnosis search (manual JSON, no codegen)

enum DxSystem { dsm5tr, icd11, icd10 }

enum DxSeverity { low, medium, high, critical }

class DxEntry {
  final String id;
  final DxSystem system;
  final String code;
  final String title;
  final String description;
  final List<String> synonyms;
  final DxSeverity typicalSeverity;
  final Map<String, dynamic> metadata;

  const DxEntry({
    required this.id,
    required this.system,
    required this.code,
    required this.title,
    required this.description,
    required this.synonyms,
    required this.typicalSeverity,
    this.metadata = const {},
  });

  factory DxEntry.fromJson(Map<String, dynamic> json) => DxEntry(
        id: json['id'] as String,
        system: DxSystem.values.firstWhere((e) => e.name == (json['system'] as String? ?? 'dsm5tr')),
        code: json['code'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        synonyms: List<String>.from((json['synonyms'] ?? []) as List),
        typicalSeverity: DxSeverity.values.firstWhere((e) => e.name == (json['typicalSeverity'] as String? ?? 'medium')),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'system': system.name,
        'code': code,
        'title': title,
        'description': description,
        'synonyms': synonyms,
        'typicalSeverity': typicalSeverity.name,
        'metadata': metadata,
      };
}

class DxSearchFilters {
  final DxSystem system;
  final String? query;
  final DxSeverity? minSeverity;
  final bool includeSynonyms;
  final int limit;

  const DxSearchFilters({
    required this.system,
    this.query,
    this.minSeverity,
    this.includeSynonyms = true,
    this.limit = 20,
  });

  factory DxSearchFilters.fromJson(Map<String, dynamic> json) => DxSearchFilters(
        system: DxSystem.values.firstWhere((e) => e.name == (json['system'] as String? ?? 'dsm5tr')),
        query: json['query'] as String?,
        minSeverity: (json['minSeverity'] as String?) == null
            ? null
            : DxSeverity.values.firstWhere((e) => e.name == json['minSeverity']),
        includeSynonyms: (json['includeSynonyms'] as bool?) ?? true,
        limit: (json['limit'] as int?) ?? 20,
      );
  Map<String, dynamic> toJson() => {
        'system': system.name,
        'query': query,
        'minSeverity': minSeverity?.name,
        'includeSynonyms': includeSynonyms,
        'limit': limit,
      };
}

class DxSuggestionLight {
  final String query;
  final List<String> suggestions;
  final DxSystem system;
  final DateTime generatedAt;

  const DxSuggestionLight({
    required this.query,
    required this.suggestions,
    required this.system,
    required this.generatedAt,
  });

  factory DxSuggestionLight.fromJson(Map<String, dynamic> json) => DxSuggestionLight(
        query: json['query'] as String,
        suggestions: List<String>.from((json['suggestions'] ?? []) as List),
        system: DxSystem.values.firstWhere((e) => e.name == (json['system'] as String? ?? 'dsm5tr')),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
  Map<String, dynamic> toJson() => {
        'query': query,
        'suggestions': suggestions,
        'system': system.name,
        'generatedAt': generatedAt.toIso8601String(),
      };
}

class RegionalDxConfig {
  final String region;
  final DxSystem defaultSystem;
  final String language;
  final Map<String, String> codeMappings;
  final Map<String, dynamic> metadata;

  const RegionalDxConfig({
    required this.region,
    required this.defaultSystem,
    required this.language,
    required this.codeMappings,
    this.metadata = const {},
  });

  factory RegionalDxConfig.fromJson(Map<String, dynamic> json) => RegionalDxConfig(
        region: json['region'] as String,
        defaultSystem: DxSystem.values.firstWhere((e) => e.name == (json['defaultSystem'] as String? ?? 'dsm5tr')),
        language: json['language'] as String,
        codeMappings: Map<String, String>.from(json['codeMappings'] ?? {}),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
  Map<String, dynamic> toJson() => {
        'region': region,
        'defaultSystem': defaultSystem.name,
        'language': language,
        'codeMappings': codeMappings,
        'metadata': metadata,
      };
}
