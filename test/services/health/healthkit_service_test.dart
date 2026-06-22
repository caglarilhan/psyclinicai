import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/health/healthkit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PromValidation (Sprint 33 P3)', () {
    test('accepts a valid PHQ-9 sample', () {
      final r = PromValidation.validate(
        const PromScore(
          instrument: 'PHQ-9',
          score: 14,
          takenAtIso: '2026-07-15T12:30:00Z',
        ),
      );
      expect(r, isNull);
    });

    test('rejects unsupported instrument', () {
      final r = PromValidation.validate(
        const PromScore(
          instrument: 'MADRS',
          score: 10,
          takenAtIso: '2026-07-15T12:30:00Z',
        ),
      );
      expect(r, 'unsupported_instrument');
    });

    test('rejects negative score', () {
      final r = PromValidation.validate(
        const PromScore(
          instrument: 'PHQ-9',
          score: -1,
          takenAtIso: '2026-07-15T12:30:00Z',
        ),
      );
      expect(r, 'score_negative');
    });

    test('rejects PHQ-9 score above 27', () {
      final r = PromValidation.validate(
        const PromScore(
          instrument: 'PHQ-9',
          score: 28,
          takenAtIso: '2026-07-15T12:30:00Z',
        ),
      );
      expect(r, 'score_above_max');
    });

    test('GAD-7 max is 21 (not 27 like PHQ-9)', () {
      final r = PromValidation.validate(
        const PromScore(
          instrument: 'GAD-7',
          score: 22,
          takenAtIso: '2026-07-15T12:30:00Z',
        ),
      );
      expect(r, 'score_above_max');
    });

    test('rejects malformed timestamp', () {
      final r = PromValidation.validate(
        const PromScore(
          instrument: 'PHQ-9',
          score: 10,
          takenAtIso: '2026-07-15',
        ),
      );
      expect(r, 'taken_at_not_iso');
    });
  });

  group('PromScore.toChannelArgs', () {
    test('includes LOINC for PHQ-9', () {
      const s = PromScore(
        instrument: 'PHQ-9',
        score: 14,
        takenAtIso: '2026-07-15T12:30:00Z',
      );
      expect(s.toChannelArgs()['loinc'], '44261-6');
    });

    test('includes LOINC for GAD-7', () {
      const s = PromScore(
        instrument: 'GAD-7',
        score: 9,
        takenAtIso: '2026-07-15T12:30:00Z',
      );
      expect(s.toChannelArgs()['loinc'], '70274-6');
    });
  });

  group('HealthKitService (no platform channel)', () {
    const channel = MethodChannel('psyclinicai.health/healthkit');
    late HealthKitService svc;

    setUp(() {
      svc = HealthKitService(channel: channel);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'requestAuthorization returns false when channel unimplemented',
      () async {
        expect(await svc.requestAuthorization(), false);
      },
    );

    test('returns true when the native side answers true', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'requestAuthorization') return true;
            if (call.method == 'writePromScore') return true;
            return null;
          });
      expect(await svc.requestAuthorization(), true);
      expect(
        await svc.writePromScore(
          const PromScore(
            instrument: 'PHQ-9',
            score: 14,
            takenAtIso: '2026-07-15T12:30:00Z',
          ),
        ),
        true,
      );
    });

    test('writePromScore rejects locally before the channel hop', () async {
      var called = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            called = true;
            return true;
          });
      final ok = await svc.writePromScore(
        const PromScore(
          instrument: 'MADRS',
          score: 10,
          takenAtIso: '2026-07-15T12:30:00Z',
        ),
      );
      expect(ok, false);
      expect(called, false, reason: 'must reject before hitting channel');
    });
  });
}
