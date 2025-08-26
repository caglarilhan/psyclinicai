import 'dart:async';
import 'dart:math';
import '../models/education_models.dart';

class EducationService {
  final List<EducationContent> _catalog = [];
  final StreamController<EducationContent> _contentStream =
      StreamController<EducationContent>.broadcast();

  Stream<EducationContent> get contentStream => _contentStream.stream;

  Future<void> initialize() async {
    if (_catalog.isEmpty) {
      _loadMockCatalog();
    }
  }

  Future<List<EducationContent>> listContents({EducationFilter? filter}) async {
    final f = filter;
    final res = _catalog.where((c) {
      final okType = f?.types == null || f!.types!.contains(c.type);
      final okTags = f?.tags == null || c.tags.any((t) => f!.tags!.contains(t));
      final okLang = f?.language == null || c.language == f!.language;
      final okDiff = f?.difficulty == null || c.difficulty == f!.difficulty;
      final okDur = f?.maxDurationMinutes == null || c.durationMinutes <= f!.maxDurationMinutes!;
      return okType && okTags && okLang && okDiff && okDur;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    for (final it in res.take(5)) {
      _contentStream.add(it);
    }
    return res;
  }

  Future<EducationRecommendationResult> recommend(EducationRecommendationRequest req) async {
    final rnd = Random();
    final matches = _catalog.where((c) {
      final tagHit = c.tags.any((t) => req.skills.any((s) => t.toLowerCase().contains(s.toLowerCase())));
      final dxHit = c.tags.any((t) => req.diagnosisCodes.any((d) => t.toLowerCase().contains(d.toLowerCase())));
      final levelHit = c.difficulty.index <= req.level.index;
      final langHit = c.language == req.language;
      return (tagHit || dxHit) && levelHit && langHit;
    }).toList()
      ..shuffle(rnd);

    final top = matches.take(10).toList();
    for (final it in top.take(3)) _contentStream.add(it);

    return EducationRecommendationResult(
      contents: top,
      rationale: {
        'matched_skills': req.skills,
        'matched_diagnoses': req.diagnosisCodes,
        'level': req.level.name,
        'language': req.language,
      },
    );
  }

  void dispose() {
    if (!_contentStream.isClosed) _contentStream.close();
  }

  void _loadMockCatalog() {
    final now = DateTime.now();
    _catalog.addAll([
      EducationContent(
        id: 'edu_video_cbt_1',
        title: 'CBT: Temel Teknikler',
        description: 'Bilişsel davranışçı terapinin temel prensipleri ve uygulamaları.',
        type: EduContentType.video,
        tags: ['CBT', 'depresyon', 'anksiyete'],
        language: 'tr',
        difficulty: EduDifficulty.beginner,
        durationMinutes: 25,
        url: 'https://example.com/cbt1',
        provider: 'PsyClinic Academy',
        rating: 4.7,
        publishedAt: now.subtract(const Duration(days: 60)),
      ),
      EducationContent(
        id: 'edu_article_risk_1',
        title: 'Kriz Değerlendirme Protokolleri',
        description: 'Acil kriz yönetimi ve intihar riski değerlendirme rehberi.',
        type: EduContentType.article,
        tags: ['kriz', 'risk', 'suicid'],
        language: 'tr',
        difficulty: EduDifficulty.advanced,
        durationMinutes: 10,
        url: 'https://example.com/risk1',
        provider: 'National Guidelines',
        rating: 4.6,
        publishedAt: now.subtract(const Duration(days: 20)),
      ),
      EducationContent(
        id: 'edu_pdf_sleep',
        title: 'Uyku Hijyeni El Kitabı',
        description: 'İnsomnia için kısa müdahaleler ve hijyen prensipleri.',
        type: EduContentType.pdf,
        tags: ['uyku', 'insomnia', 'CBT-I'],
        language: 'tr',
        difficulty: EduDifficulty.intermediate,
        durationMinutes: 15,
        url: 'https://example.com/sleep.pdf',
        provider: 'WHO',
        rating: 4.5,
        publishedAt: now.subtract(const Duration(days: 120)),
      ),
      EducationContent(
        id: 'edu_course_dbtt',
        title: 'DBT: Duygu Düzenleme Becerileri',
        description: 'DBT modülleri ve pratik seans akışları.',
        type: EduContentType.course,
        tags: ['DBT', 'duygu', 'borderline'],
        language: 'tr',
        difficulty: EduDifficulty.intermediate,
        durationMinutes: 120,
        url: 'https://example.com/dbt-course',
        provider: 'PsyClinic Academy',
        rating: 4.8,
        publishedAt: now.subtract(const Duration(days: 10)),
      ),
      EducationContent(
        id: 'edu_article_icd',
        title: 'ICD-11 Depresyon Güncel Yaklaşımlar',
        description: 'ICD-11 perspektifinden depresif bozukluk yönetimi.',
        type: EduContentType.article,
        tags: ['ICD-11', 'depresyon', 'farmakoloji'],
        language: 'tr',
        difficulty: EduDifficulty.advanced,
        durationMinutes: 12,
        url: 'https://example.com/icd11-depression',
        provider: 'APA',
        rating: 4.4,
        publishedAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }
}
