// Education Library models (manual JSON)

enum EduContentType { video, article, pdf, course }

enum EduDifficulty { beginner, intermediate, advanced }

class EducationContent {
  final String id;
  final String title;
  final String description;
  final EduContentType type;
  final List<String> tags;
  final String language; // en, tr, fr
  final EduDifficulty difficulty;
  final int durationMinutes; // video/course
  final String url;
  final String provider; // e.g., APA, WHO, Local
  final double rating; // 0-5
  final DateTime publishedAt;
  final Map<String, dynamic> metadata;

  const EducationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tags,
    required this.language,
    required this.difficulty,
    required this.durationMinutes,
    required this.url,
    required this.provider,
    required this.rating,
    required this.publishedAt,
    this.metadata = const {},
  });

  factory EducationContent.fromJson(Map<String, dynamic> json) => EducationContent(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: EduContentType.values.firstWhere((e) => e.name == (json['type'] as String)),
        tags: List<String>.from((json['tags'] ?? []) as List),
        language: json['language'] as String,
        difficulty: EduDifficulty.values.firstWhere((e) => e.name == (json['difficulty'] as String)),
        durationMinutes: (json['durationMinutes'] as num).toInt(),
        url: json['url'] as String,
        provider: json['provider'] as String,
        rating: (json['rating'] as num).toDouble(),
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'tags': tags,
        'language': language,
        'difficulty': difficulty.name,
        'durationMinutes': durationMinutes,
        'url': url,
        'provider': provider,
        'rating': rating,
        'publishedAt': publishedAt.toIso8601String(),
        'metadata': metadata,
      };
}

class EducationFilter {
  final List<EduContentType>? types;
  final List<String>? tags;
  final String? language;
  final EduDifficulty? difficulty;
  final int? maxDurationMinutes;

  const EducationFilter({
    this.types,
    this.tags,
    this.language,
    this.difficulty,
    this.maxDurationMinutes,
  });
}

class EducationRecommendationRequest {
  final List<String> diagnosisCodes; // ICD/DSM codes
  final List<String> skills; // CBT, DBT, Risk, Sleep, etc.
  final EduDifficulty level;
  final String language;

  const EducationRecommendationRequest({
    required this.diagnosisCodes,
    required this.skills,
    required this.level,
    required this.language,
  });
}

class EducationRecommendationResult {
  final List<EducationContent> contents;
  final Map<String, dynamic> rationale;

  const EducationRecommendationResult({
    required this.contents,
    this.rationale = const {},
  });
}
