import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/education_service.dart';
import 'package:psyclinicai/models/education_models.dart';

void main() {
  group('EducationService Tests', () {
    late EducationService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = EducationService();
    });

    test('initialize and list contents', () async {
      await service.initialize();
      final all = await service.listContents();
      expect(all, isNotEmpty);
      expect(all.first.title, isNotEmpty);
    });

    test('filter by language and difficulty', () async {
      await service.initialize();
      final filtered = await service.listContents(
        filter: const EducationFilter(language: 'tr', difficulty: EduDifficulty.beginner),
      );
      expect(filtered, isNotEmpty);
      expect(filtered.every((c) => c.language == 'tr'), isTrue);
      expect(filtered.every((c) => c.difficulty.index >= EduDifficulty.beginner.index), isTrue);
    });

    test('recommendation by skills and diagnosis', () async {
      await service.initialize();
      final result = await service.recommend(
        const EducationRecommendationRequest(
          diagnosisCodes: ['6B00.0', 'F32'],
          skills: ['CBT', 'risk'],
          level: EduDifficulty.intermediate,
          language: 'tr',
        ),
      );
      expect(result.contents, isNotEmpty);
      expect(result.rationale['level'], 'intermediate');
    });

    test('content stream emits items', () async {
      await service.initialize();
      final emitted = <EducationContent>[];
      final sub = service.contentStream.listen(emitted.add);
      await service.listContents();
      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(emitted, isNotEmpty);
    });
  });
}
