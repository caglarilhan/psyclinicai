import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/shared_device_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedDeviceService.setTestInstance(SharedPreferences.getInstance);
  });

  tearDown(SharedDeviceService.resetTestInstance);

  test('default is false; load reads persisted value', () async {
    final svc = SharedDeviceService.instance;
    expect(svc.isShared, isFalse);
    await svc.load();
    expect(svc.isLoaded, isTrue);
    expect(svc.isShared, isFalse);
  });

  test('setShared persists across a fresh service instance', () async {
    final svc = SharedDeviceService.instance;
    await svc.setShared(true);
    expect(svc.isShared, isTrue);

    SharedDeviceService.resetTestInstance();
    SharedDeviceService.setTestInstance(SharedPreferences.getInstance);
    final svc2 = SharedDeviceService.instance;
    await svc2.load();
    expect(
      svc2.isShared,
      isTrue,
      reason: 'shared-device flag must survive a restart',
    );
  });

  test('setShared notifies listeners', () async {
    final svc = SharedDeviceService.instance;
    var calls = 0;
    svc.addListener(() => calls++);
    await svc.setShared(true);
    expect(calls, greaterThanOrEqualTo(1));
  });
}
