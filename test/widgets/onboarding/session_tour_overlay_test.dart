import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/onboarding/session_tour_overlay.dart';

void main() {
  group('SessionTourController (Sprint 31 P2)', () {
    test('shouldShow returns true on a fresh persistence', () async {
      final c = SessionTourController(
        persistence: InMemoryTourPersistence(),
      );
      expect(await c.shouldShow(), true);
    });

    test('shouldShow returns false after markSeen', () async {
      final p = InMemoryTourPersistence();
      await p.markSeen();
      final c = SessionTourController(persistence: p);
      expect(await c.shouldShow(), false);
    });

    test('first step is index 0, isFirstStep is true', () {
      final c = SessionTourController();
      expect(c.currentIndex, 0);
      expect(c.isFirstStep, true);
      expect(c.isLastStep, false);
    });

    test('next advances index up to the last step', () async {
      final c = SessionTourController();
      await c.next();
      expect(c.currentIndex, 1);
      await c.next();
      expect(c.currentIndex, 2);
      await c.next();
      expect(c.currentIndex, 3);
      expect(c.isLastStep, true);
    });

    test('next on last step marks completed + persists seen', () async {
      final p = InMemoryTourPersistence();
      final c = SessionTourController(persistence: p);
      while (!c.isLastStep) {
        await c.next();
      }
      await c.next(); // past the last step
      expect(c.isCompleted, true);
      expect(await p.hasSeen(), true);
    });

    test('skip marks completed even from the first step', () async {
      final p = InMemoryTourPersistence();
      final c = SessionTourController(persistence: p);
      await c.skip();
      expect(c.isCompleted, true);
      expect(await p.hasSeen(), true);
    });

    test('previous decreases index, clamped at 0', () async {
      final c = SessionTourController();
      await c.previous(); // no-op at first step
      expect(c.currentIndex, 0);
      await c.next();
      await c.previous();
      expect(c.currentIndex, 0);
    });

    test('next after completion is a no-op', () async {
      final c = SessionTourController();
      await c.skip();
      await c.next();
      expect(c.isCompleted, true);
    });

    test('totalSteps is 4 with the default tour', () {
      final c = SessionTourController();
      expect(c.totalSteps, 4);
      expect(kDefaultSessionTour.length, 4);
    });
  });
}
