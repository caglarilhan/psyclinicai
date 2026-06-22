import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/phq9_item9_router.dart';

void main() {
  const router = Phq9Item9Router();

  group('Phq9Item9Router', () {
    test('score 0 — none (no interruption)', () {
      final r = router.evaluate({'phq9_9': 0});
      expect(r.severity, Phq9Item9Severity.none);
      expect(r.primaryAction, Phq9Item9Action.none);
      expect(r.secondaryActions, isEmpty);
      expect(r.reason, isEmpty);
    });

    test('score 1 — suggest C-SSRS only', () {
      final r = router.evaluate({'phq9_9': 1});
      expect(r.severity, Phq9Item9Severity.several);
      expect(r.primaryAction, Phq9Item9Action.openCssrs);
      expect(r.secondaryActions, isEmpty);
      expect(r.reason, contains('C-SSRS'));
    });

    test('score 2 — C-SSRS + safety plan review', () {
      final r = router.evaluate({'phq9_9': 2});
      expect(r.severity, Phq9Item9Severity.moreThanHalf);
      expect(r.primaryAction, Phq9Item9Action.openCssrs);
      expect(r.secondaryActions, contains(Phq9Item9Action.openSafetyPlan));
    });

    test('score 3 — crisis modal + cascading actions', () {
      final r = router.evaluate({'phq9_9': 3});
      expect(r.severity, Phq9Item9Severity.nearlyEveryDay);
      expect(r.primaryAction, Phq9Item9Action.showCrisisModal);
      expect(
        r.secondaryActions,
        containsAll(<Phq9Item9Action>[
          Phq9Item9Action.openCssrs,
          Phq9Item9Action.openSafetyPlan,
        ]),
      );
    });

    test('out-of-range positive (e.g. 5) clamps to crisis modal', () {
      final r = router.evaluate({'phq9_9': 5});
      expect(r.severity, Phq9Item9Severity.nearlyEveryDay);
      expect(r.primaryAction, Phq9Item9Action.showCrisisModal);
    });

    test('alternative response keys (`item_9`, `q9`) work', () {
      expect(
        router.evaluate({'item_9': 2}).severity,
        Phq9Item9Severity.moreThanHalf,
      );
      expect(
        router.evaluate({'q9': 3}).severity,
        Phq9Item9Severity.nearlyEveryDay,
      );
    });

    test('missing item — defaults to none', () {
      expect(router.evaluate({}).severity, Phq9Item9Severity.none);
    });

    test('negative input is treated as none (defensive)', () {
      expect(router.evaluate({'phq9_9': -1}).severity, Phq9Item9Severity.none);
    });
  });
}
