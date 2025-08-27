import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/alerting_service.dart';

void main() {
  group('AlertingService', () {
    late AlertingService service;

    setUp(() {
      service = AlertingService();
      service.clearAll();
    });

    test('should send alert initially', () {
      final ok = service.send(key: 'state:CA|patient:p1|duty_to_warn', message: 'Duty to Warn', cooldown: const Duration(seconds: 10));
      expect(ok, isTrue);
      expect(service.events.length, 1);
    });

    test('should prevent duplicate within cooldown', () async {
      final key = 'state:CA|patient:p1|mandatory_report';
      final cooldown = const Duration(milliseconds: 300);

      final first = service.send(key: key, message: 'Report now', cooldown: cooldown);
      final second = service.send(key: key, message: 'Report now', cooldown: cooldown);

      expect(first, isTrue);
      expect(second, isFalse);
      expect(service.events.length, 1);

      await Future.delayed(cooldown + const Duration(milliseconds: 50));
      final third = service.send(key: key, message: 'Report now', cooldown: cooldown);
      expect(third, isTrue);
      expect(service.events.length, 2);
    });

    test('should allow different message after cooldown', () async {
      final key = 'state:NY|patient:p2|mandatory_report';
      final cooldown = const Duration(milliseconds: 200);

      final first = service.send(key: key, message: 'Report A', cooldown: cooldown);
      expect(first, isTrue);

      final second = service.send(key: key, message: 'Report B', cooldown: cooldown);
      expect(second, isFalse, reason: 'still within cooldown');

      await Future.delayed(cooldown + const Duration(milliseconds: 20));
      final third = service.send(key: key, message: 'Report B', cooldown: cooldown);
      expect(third, isTrue);
    });

    test('reset should clear cooldown for given key', () {
      final key = 'state:TX|patient:p3|safety_plan';
      final cooldown = const Duration(seconds: 5);

      final first = service.send(key: key, message: 'Plan required', cooldown: cooldown);
      final second = service.send(key: key, message: 'Plan required', cooldown: cooldown);
      expect(first, isTrue);
      expect(second, isFalse);

      service.reset(key);
      final third = service.send(key: key, message: 'Plan required', cooldown: cooldown);
      expect(third, isTrue);
    });
  });
}
