import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/telemetry_service.dart';

void main() {
  group('TelemetryHealth', () {
    test('label is "wired" when DSN set + Sentry init succeeded', () {
      const h = TelemetryHealth(
        telemetryEnabled: true,
        dsnConfigured: true,
        sentryReady: true,
        environment: 'production',
      );
      expect(h.label, 'wired');
    });

    test('label is "misconfigured" when DSN set but init failed', () {
      const h = TelemetryHealth(
        telemetryEnabled: true,
        dsnConfigured: true,
        sentryReady: false,
        environment: 'production',
      );
      expect(h.label, 'misconfigured');
    });

    test('label is "off" when DSN not set (expected in demo builds)', () {
      const h = TelemetryHealth(
        telemetryEnabled: false,
        dsnConfigured: false,
        sentryReady: false,
        environment: 'development',
      );
      expect(h.label, 'off');
    });

    test(
      'TelemetryService exposes a health snapshot that never throws',
      () {
        final h = TelemetryService.instance.health;
        expect(h, isA<TelemetryHealth>());
        expect(
          const {'wired', 'misconfigured', 'off'},
          contains(h.label),
        );
        expect(
          const {'production', 'development'},
          contains(h.environment),
        );
      },
    );
  });
}
