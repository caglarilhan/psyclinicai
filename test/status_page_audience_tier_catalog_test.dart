import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/incident_severity.dart';
import 'package:psyclinicai/services/ops/status_page_audience_tier_catalog.dart';

void main() {
  group('StatusPageAudienceTierCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(StatusPageAudienceTierCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = StatusPageAudienceTierCatalog.records
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in StatusPageAudienceTierCatalog.records) {
        expect(StatusPageAudienceTierCatalog.byId(r.id), same(r));
      }
      expect(StatusPageAudienceTierCatalog.byId('does-not-exist'), isNull);
    });

    test('every IncidentSeverity has exactly one pinned record', () {
      for (final s in IncidentSeverity.values) {
        final matches = StatusPageAudienceTierCatalog.records
            .where((r) => r.severity == s)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${s.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in StatusPageAudienceTierCatalog.records) {
        expect(
          r.audiences,
          isNotEmpty,
          reason: '${r.id}: at least internal oncall must be notified',
        );
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'P0 MUST require regulator breach notification + ALL audiences + ALL channels',
      () {
        final r = StatusPageAudienceTierCatalog.bySeverity(
          IncidentSeverity.p0,
        )!;
        expect(r.regulatorBreachNotification, isTrue);
        expect(r.audiences, contains(NotificationAudience.regulator));
        expect(
          r.audiences,
          contains(NotificationAudience.statusPageSubscribers),
        );
        expect(
          r.audiences,
          contains(NotificationAudience.affectedTenantAdmins),
        );
        expect(r.audiences, contains(NotificationAudience.internalOncall));
        expect(r.channels, contains(NotificationChannel.regulatorNotification));
        expect(
          r.channels,
          contains(NotificationChannel.sms),
          reason: 'P0 needs SMS for oncall pager-grade escalation',
        );
      },
    );

    test('non-P0 tiers MUST NOT require regulator breach notification', () {
      for (final s in IncidentSeverity.values) {
        if (s == IncidentSeverity.p0) continue;
        final r = StatusPageAudienceTierCatalog.bySeverity(s)!;
        expect(
          r.regulatorBreachNotification,
          isFalse,
          reason:
              '${s.name}: regulator notification is a P0-only escalation; pinning it lower invites alert fatigue',
        );
      }
    });

    test('non-P0 tiers MUST NOT include regulator in audiences', () {
      for (final s in IncidentSeverity.values) {
        if (s == IncidentSeverity.p0) continue;
        final r = StatusPageAudienceTierCatalog.bySeverity(s)!;
        expect(
          r.audiences.contains(NotificationAudience.regulator),
          isFalse,
          reason:
              '${s.name}: regulator audience reserved for confirmed breach (P0)',
        );
      }
    });

    test(
      'every tier MUST include internalOncall in audiences (team must always know)',
      () {
        for (final r in StatusPageAudienceTierCatalog.records) {
          expect(
            r.audiences,
            contains(NotificationAudience.internalOncall),
            reason:
                '${r.id}: internalOncall presence is the floor — even P4 informational must reach the on-call rotation',
          );
        }
      },
    );

    test('maxLatencyMinutes monotonic: P0 < P1 <= P2 <= P3 <= P4', () {
      final p0 = StatusPageAudienceTierCatalog.bySeverity(
        IncidentSeverity.p0,
      )!.maxLatencyMinutes;
      final p1 = StatusPageAudienceTierCatalog.bySeverity(
        IncidentSeverity.p1,
      )!.maxLatencyMinutes;
      final p2 = StatusPageAudienceTierCatalog.bySeverity(
        IncidentSeverity.p2,
      )!.maxLatencyMinutes;
      final p3 = StatusPageAudienceTierCatalog.bySeverity(
        IncidentSeverity.p3,
      )!.maxLatencyMinutes;
      final p4 = StatusPageAudienceTierCatalog.bySeverity(
        IncidentSeverity.p4,
      )!.maxLatencyMinutes;
      expect(p0, lessThan(p1));
      expect(p1, lessThanOrEqualTo(p2));
      expect(p2, lessThanOrEqualTo(p3));
      expect(p3, lessThanOrEqualTo(p4));
    });

    test(
      'P0 latency MUST be <= 15 minutes (PHI breach 72h clock with oncall buffer)',
      () {
        final r = StatusPageAudienceTierCatalog.bySeverity(
          IncidentSeverity.p0,
        )!;
        expect(
          r.maxLatencyMinutes,
          lessThanOrEqualTo(15),
          reason:
              'P0 first-notification within 15 min preserves the 72h GDPR Art. 33 + 60d HIPAA §164.404 clocks',
        );
      },
    );

    test(
      'audiences monotonic: higher severity reaches at LEAST as many audiences as next-lower',
      () {
        final tiers = [
          IncidentSeverity.p4,
          IncidentSeverity.p3,
          IncidentSeverity.p2,
          IncidentSeverity.p1,
          IncidentSeverity.p0,
        ];
        for (var i = 0; i < tiers.length - 1; i++) {
          final lower = StatusPageAudienceTierCatalog.bySeverity(tiers[i])!;
          final higher = StatusPageAudienceTierCatalog.bySeverity(
            tiers[i + 1],
          )!;
          for (final audience in lower.audiences) {
            if (audience == NotificationAudience.regulator) continue;
            expect(
              higher.audiences,
              contains(audience),
              reason:
                  '${higher.severity.name} MUST include $audience since ${lower.severity.name} requires it',
            );
          }
        }
      },
    );

    test('P0 MUST cite HIPAA §164.404 + GDPR Art. 33 + ISO 27001 A.16', () {
      final r = StatusPageAudienceTierCatalog.bySeverity(IncidentSeverity.p0)!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(blob.contains('HIPAA §164.404'), isTrue);
      expect(blob.contains('GDPR Art. 33'), isTrue);
      expect(blob.contains('ISO 27001 A.16'), isTrue);
    });

    test('every record MUST cite at least one SOC 2 OR ISO 27001 anchor', () {
      for (final r in StatusPageAudienceTierCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('SOC 2') || blob.contains('ISO 27001'),
          isTrue,
          reason: '${r.id}: needs at least a SOC 2 or ISO 27001 anchor',
        );
      }
    });

    test(
      'P4 MUST have empty channels (informational — no user-facing comms by design)',
      () {
        final r = StatusPageAudienceTierCatalog.bySeverity(
          IncidentSeverity.p4,
        )!;
        expect(
          r.channels,
          isEmpty,
          reason:
              'P4 is informational telemetry-only; pinning user-facing channels would alert-fatigue subscribers',
        );
      },
    );
  });

  group('requiresRegulatorNotification helper', () {
    test('true ONLY for P0', () {
      for (final s in IncidentSeverity.values) {
        expect(
          requiresRegulatorNotification(s),
          s == IncidentSeverity.p0,
          reason: s.name,
        );
      }
    });
  });
}
