import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/incident_severity.dart';

void main() {
  group('IncidentSeverity.fromId', () {
    test('round-trips every enum value', () {
      for (final s in IncidentSeverity.values) {
        expect(IncidentSeverity.fromId(s.name), s);
      }
    });

    test('defaults to P3 for unknown / null ids', () {
      expect(IncidentSeverity.fromId(null), IncidentSeverity.p3);
      expect(IncidentSeverity.fromId(''), IncidentSeverity.p3);
      expect(IncidentSeverity.fromId('sev99'), IncidentSeverity.p3);
    });
  });

  group('targetsFor', () {
    test('returns a target row for every severity', () {
      for (final s in IncidentSeverity.values) {
        final t = targetsFor(s);
        expect(t.severity, s);
        expect(t.rto.inSeconds, greaterThan(0));
        expect(t.rpo.inSeconds, greaterThan(0));
        expect(t.customerNotifyWithin.inSeconds, greaterThan(0));
      }
    });

    test('RTO is strictly tighter as severity gets worse', () {
      for (var i = 0; i < IncidentSeverity.values.length - 1; i++) {
        final tighter = targetsFor(IncidentSeverity.values[i]);
        final looser = targetsFor(IncidentSeverity.values[i + 1]);
        expect(
          tighter.rto,
          lessThan(looser.rto),
          reason:
              '${tighter.severity.name} should have a tighter RTO than '
              '${looser.severity.name}',
        );
      }
    });

    test('P0 RTO is 1h and RPO is 15 min', () {
      final t = targetsFor(IncidentSeverity.p0);
      expect(t.rto, const Duration(hours: 1));
      expect(t.rpo, const Duration(minutes: 15));
    });

    test('P0 and P1 require a post-mortem; P2-P4 do not by default', () {
      expect(targetsFor(IncidentSeverity.p0).postMortemRequired, isTrue);
      expect(targetsFor(IncidentSeverity.p1).postMortemRequired, isTrue);
      expect(targetsFor(IncidentSeverity.p2).postMortemRequired, isFalse);
      expect(targetsFor(IncidentSeverity.p3).postMortemRequired, isFalse);
      expect(targetsFor(IncidentSeverity.p4).postMortemRequired, isFalse);
    });
  });

  group('isWithinNotificationWindow', () {
    test('true when elapsed < SLA', () {
      expect(
        isWithinNotificationWindow(
          IncidentSeverity.p1,
          const Duration(hours: 1),
        ),
        isTrue,
      );
    });

    test('false when elapsed exceeds the SLA', () {
      expect(
        isWithinNotificationWindow(
          IncidentSeverity.p0,
          const Duration(hours: 5),
        ),
        isFalse,
      );
    });
  });

  group('HIPAA breach guard rails', () {
    test('statutory deadline is 60 days', () {
      expect(hipaaBreachStatutoryDeadline.inDays, 60);
    });

    test(
      'internal target gives at least 5x slack on the statutory deadline',
      () {
        expect(
          hipaaBreachInternalTarget,
          lessThan(hipaaBreachStatutoryDeadline),
        );
        expect(
          hipaaBreachStatutoryDeadline.inHours /
              hipaaBreachInternalTarget.inHours,
          greaterThanOrEqualTo(5),
        );
      },
    );

    test('P0 customer notification beats the HIPAA target', () {
      expect(
        targetsFor(IncidentSeverity.p0).customerNotifyWithin,
        lessThan(hipaaBreachInternalTarget),
      );
    });
  });
}
