import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/legal/state_law_service.dart';

void main() {
  const svc = StateLawService();

  group('StateLawService US Phase 1 (Sprint 32)', () {
    test('supportedStates contains exactly CA + NY + TX', () {
      expect(StateLawService.supportedStates, {'CA', 'NY', 'TX'});
    });

    test('unknown state returns empty list (no exception)', () {
      expect(svc.alertsForState('XX'), isEmpty);
      expect(svc.alertsForState(''), isEmpty);
    });

    test('case-insensitive lookup', () {
      expect(svc.alertsForState('ca').length,
          svc.alertsForState('CA').length);
    });

    group('California', () {
      final alerts = svc.alertsForState('CA');

      test('5 alerts shipped', () {
        expect(alerts.length, 5);
      });

      test('Tarasoff alert is critical and cites Cal. Civ. Code §43.92', () {
        final t =
            alerts.firstWhere((a) => a.id == 'CA.dutyToWarn.tarasoff');
        expect(t.severity, AlertSeverity.critical);
        expect(t.citation, contains('43.92'));
      });

      test('elder reporting category is mandatoryReporting', () {
        final e = alerts.firstWhere(
            (a) => a.id == 'CA.mandatoryReporting.elder');
        expect(e.category, AlertCategory.mandatoryReporting);
      });
    });

    group('New York', () {
      final alerts = svc.alertsForState('NY');

      test('4 alerts shipped', () {
        expect(alerts.length, 4);
      });

      test('duty-to-warn is warning (not critical — no Tarasoff in NY)', () {
        final dw = alerts.firstWhere(
            (a) => a.id == 'NY.dutyToWarn.modified');
        expect(dw.severity, AlertSeverity.warning);
        expect(dw.citation, contains('Mental Hyg'));
      });

      test('telehealth licensure flags non-PSYPACT', () {
        final t = alerts.firstWhere((a) => a.id == 'NY.telehealthLicensure');
        expect(t.body, contains('PSYPACT'));
        expect(t.severity, AlertSeverity.warning);
      });
    });

    group('Texas', () {
      final alerts = svc.alertsForState('TX');

      test('4 alerts shipped', () {
        expect(alerts.length, 4);
      });

      test('Thapar v. Zezulka cited correctly', () {
        final t = alerts.firstWhere((a) => a.id == 'TX.dutyToWarn.thapar');
        expect(t.citation, contains('Thapar v. Zezulka'));
        expect(t.severity, AlertSeverity.warning);
      });

      test('telehealth alert mentions PSYPACT carve-out', () {
        final t = alerts.firstWhere((a) => a.id == 'TX.telehealthLicensure');
        expect(t.body, contains('PSYPACT'));
      });
    });

    test('alertsForMultipleStates concatenates without dedup', () {
      final bundle = svc.alertsForMultipleStates(['CA', 'NY', 'TX']);
      expect(bundle.length, 5 + 4 + 4);
    });

    test('hasCriticalAlert is true for any state with a Tarasoff/reporting',
        () {
      expect(svc.hasCriticalAlert(svc.alertsForState('CA')), true);
      expect(svc.hasCriticalAlert(svc.alertsForState('NY')), true);
      expect(svc.hasCriticalAlert(svc.alertsForState('TX')), true);
      expect(svc.hasCriticalAlert([]), false);
    });
  });
}
