import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/app_lock_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime fakeNow;

  setUp(() {
    fakeNow = DateTime.utc(2026, 6, 2, 12);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppLockService.setTestInstance(
      prefs: SharedPreferences.getInstance,
      clock: () => fakeNow,
    );
  });
  tearDown(AppLockService.resetTestInstance);

  group('AppLockService', () {
    test('defaults to disabled until load + enable', () async {
      await AppLockService.instance.load();
      expect(AppLockService.instance.state, AppLockState.disabled);
      expect(AppLockService.instance.enabled, isFalse);
    });

    test('enable rejects short / non-digit PIN', () async {
      await AppLockService.instance.load();
      expect(() => AppLockService.instance.enable(pin: '12'),
          throwsArgumentError);
      expect(() => AppLockService.instance.enable(pin: 'abcd'),
          throwsArgumentError);
    });

    test('enable persists + arms the lock', () async {
      await AppLockService.instance.load();
      await AppLockService.instance.enable(pin: '1234', idleMinutes: 3);
      expect(AppLockService.instance.state, AppLockState.armed);
      expect(AppLockService.instance.enabled, isTrue);
      expect(AppLockService.instance.idleMinutes, 3);
    });

    test('unlockWithPin rejects wrong + accepts correct pin', () async {
      await AppLockService.instance.load();
      await AppLockService.instance.enable(pin: '1234');
      fakeNow = fakeNow.add(const Duration(minutes: 10));
      expect(AppLockService.instance.maybeAutoLock(), isTrue);
      expect(AppLockService.instance.state, AppLockState.locked);
      expect(AppLockService.instance.unlockWithPin('9999'), isFalse);
      expect(AppLockService.instance.state, AppLockState.locked);
      expect(AppLockService.instance.unlockWithPin('1234'), isTrue);
      expect(AppLockService.instance.state, AppLockState.armed);
    });

    test('disable wipes the pin hash + flag', () async {
      await AppLockService.instance.load();
      await AppLockService.instance.enable(pin: '1234');
      await AppLockService.instance.disable();
      expect(AppLockService.instance.state, AppLockState.disabled);
      expect(AppLockService.instance.enabled, isFalse);
      expect(AppLockService.instance.hasPin, isFalse);
    });

    test('idle timer respects recordActivity', () async {
      await AppLockService.instance.load();
      await AppLockService.instance.enable(pin: '1234', idleMinutes: 5);
      fakeNow = fakeNow.add(const Duration(minutes: 3));
      AppLockService.instance.recordActivity();
      fakeNow = fakeNow.add(const Duration(minutes: 4));
      expect(AppLockService.instance.shouldRelock(), isFalse);
      fakeNow = fakeNow.add(const Duration(minutes: 2));
      expect(AppLockService.instance.shouldRelock(), isTrue);
    });
  });
}
