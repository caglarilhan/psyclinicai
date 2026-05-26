import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';

void main() {
  late RiskSignalService svc;

  setUp(() => svc = RiskSignalService());
  tearDown(() => svc.dispose());

  group('RiskSignalService.scanSegment (Tier 1 lexicon)', () {
    test('flags suicidal ideation as high severity', () {
      final out = svc.scanSegment('Honestly I just want to die some days.');
      expect(out, isNotEmpty);
      final s = out.first;
      expect(s.category, RiskCategory.suicidalIdeation);
      expect(s.severity, RiskSeverity.high);
      expect(s.source, RiskSource.lexicon);
    });

    test('flags self-harm as high severity', () {
      final out = svc.scanSegment('Last week I cut myself again.');
      expect(out.map((s) => s.category), contains(RiskCategory.selfHarm));
      expect(out.first.severity, RiskSeverity.high);
    });

    test('flags substance use as elevated', () {
      final out = svc.scanSegment('I think I relapsed over the weekend.');
      expect(out.map((s) => s.category), contains(RiskCategory.substanceUse));
      expect(
        out.firstWhere((s) => s.category == RiskCategory.substanceUse).severity,
        RiskSeverity.elevated,
      );
    });

    test('flags hopelessness as elevated', () {
      final out = svc.scanSegment('It all feels hopeless lately.');
      expect(out.map((s) => s.category), contains(RiskCategory.hopelessness));
    });

    test('does not flag benign conversation', () {
      final out = svc.scanSegment(
          'We talked about my new job and the weekend plans with family.');
      expect(out, isEmpty);
    });

    test('is case-insensitive and punctuation-tolerant', () {
      final out = svc.scanSegment('I WANT TO DIE!!!');
      expect(
          out.map((s) => s.category), contains(RiskCategory.suicidalIdeation));
    });

    test('emits at most one signal per category per segment', () {
      final out = svc.scanSegment('suicidal. suicide. want to die.');
      final suicidal =
          out.where((s) => s.category == RiskCategory.suicidalIdeation);
      expect(suicidal.length, 1);
    });

    test('dedupKey is stable for the same trigger', () {
      final a = svc.scanSegment('want to die').first;
      final b = svc.scanSegment('I want to die').first;
      expect(a.dedupKey, b.dedupKey);
    });
  });
}
