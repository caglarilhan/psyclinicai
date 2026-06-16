import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/auto_logout_controller.dart';
import 'package:psyclinicai/services/data/shared_device_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedDeviceService.setTestInstance(SharedPreferences.getInstance);
  });

  tearDown(() {
    SharedDeviceService.resetTestInstance();
  });

  test('does nothing on a non-shared device, even after 10 minutes', () {
    fakeAsync((async) {
      var fired = 0;
      var clock = DateTime(2026, 6, 16, 12, 0, 0);
      final svc = SharedDeviceService.instance;
      final ctl = AutoLogoutController(
        sharedDevice: svc,
        onLogout: () async => fired++,
        sharedIdleTimeout: const Duration(minutes: 5),
        tickInterval: const Duration(seconds: 1),
        now: () => clock,
      );

      for (var i = 0; i < 600; i++) {
        clock = clock.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
      }
      expect(fired, 0,
          reason: 'auto-logout must NOT fire when shared-device is off');
      ctl.dispose();
    });
  });

  test('fires sign-out after 5 minutes idle on a shared device', () async {
    var fired = 0;
    var clock = DateTime(2026, 6, 16, 12, 0, 0);
    final svc = SharedDeviceService.instance;
    await svc.setShared(true);

    fakeAsync((async) {
      final ctl = AutoLogoutController(
        sharedDevice: svc,
        onLogout: () async => fired++,
        sharedIdleTimeout: const Duration(minutes: 5),
        tickInterval: const Duration(seconds: 1),
        now: () => clock,
      );

      for (var i = 0; i < 240; i++) {
        clock = clock.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
      }
      expect(fired, 0);

      for (var i = 0; i < 61; i++) {
        clock = clock.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
      }
      async.flushMicrotasks();
      expect(fired, 1,
          reason: 'auto-logout must fire once after 5min idle');

      ctl.dispose();
    });
  });

  test('recordActivity resets the idle window', () async {
    var fired = 0;
    var clock = DateTime(2026, 6, 16, 12, 0, 0);
    final svc = SharedDeviceService.instance;
    await svc.setShared(true);

    fakeAsync((async) {
      final ctl = AutoLogoutController(
        sharedDevice: svc,
        onLogout: () async => fired++,
        sharedIdleTimeout: const Duration(minutes: 5),
        tickInterval: const Duration(seconds: 1),
        now: () => clock,
      );

      for (var i = 0; i < 240; i++) {
        clock = clock.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
      }
      ctl.recordActivity();
      for (var i = 0; i < 240; i++) {
        clock = clock.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
      }
      async.flushMicrotasks();
      expect(fired, 0,
          reason: 'activity must reset the 5min window');

      ctl.dispose();
    });
  });
}
