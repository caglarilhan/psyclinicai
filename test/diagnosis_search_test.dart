import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/diagnosis_search_service.dart';
import 'package:psyclinicai/models/diagnosis_search_models.dart';

void main() {
  group('DiagnosisSearchService Tests', () {
    late DiagnosisSearchService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = DiagnosisSearchService();
    });

    group('Initialization & Region', () {
      test('should initialize and set default region', () async {
        await service.initialize();
        final region = service.getCurrentRegion();
        expect(region, isNotNull);
        expect(region!.region, 'US');
        expect(region.defaultSystem, DxSystem.dsm5tr);
      });

      test('should change region to TR and EU', () async {
        await service.initialize();
        await service.setRegion('TR');
        expect(service.getCurrentRegion()!.region, 'TR');
        await service.setRegion('EU');
        expect(service.getCurrentRegion()!.region, 'EU');
      });
    });

    group('Search', () {
      test('should search DSM by title/synonym/code', () async {
        await service.initialize();
        final filters = DxSearchFilters(
          system: DxSystem.dsm5tr,
          query: 'depresyon',
          limit: 10,
        );
        final list = await service.search(filters);
        expect(list, isNotEmpty);
        expect(list.any((e) => e.code == '6B00.0'), isTrue);
      });

      test('should filter by severity', () async {
        await service.initialize();
        final filters = DxSearchFilters(
          system: DxSystem.dsm5tr,
          minSeverity: DxSeverity.high,
          limit: 10,
        );
        final list = await service.search(filters);
        // should include 6B00.1 (high)
        expect(list.any((e) => e.code == '6B00.1'), isTrue);
        // and exclude 6B00.0 (medium)
        expect(list.any((e) => e.code == '6B00.0'), isFalse);
      });

      test('should search ICD-10', () async {
        await service.initialize();
        final filters = DxSearchFilters(
          system: DxSystem.icd10,
          query: 'F32',
          limit: 10,
        );
        final list = await service.search(filters);
        expect(list.any((e) => e.code == 'F32.0'), isTrue);
      });
    });

    group('Suggestions', () {
      test('should suggest by prefix', () async {
        await service.initialize();
        final sugg = await service.suggest('dep', DxSystem.dsm5tr);
        expect(sugg.suggestions, isNotEmpty);
        expect(sugg.system, DxSystem.dsm5tr);
      });
    });

    group('Streams', () {
      test('should emit entries and suggestions on streams', () async {
        await service.initialize();
        final entries = <DxEntry>[];
        final suggs = <dynamic>[];
        final sub1 = service.entryStream.listen(entries.add);
        final sub2 = service.suggestionStream.listen(suggs.add);

        final list = await service.search(const DxSearchFilters(system: DxSystem.dsm5tr, query: 'depresyon'));
        expect(list, isNotEmpty);
        await service.suggest('an', DxSystem.icd11);
        await Future.delayed(const Duration(milliseconds: 50));

        await sub1.cancel();
        await sub2.cancel();

        expect(entries.length, greaterThan(0));
        expect(suggs.length, greaterThan(0));
      });
    });
  });
}
