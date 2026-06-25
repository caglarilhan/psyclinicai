/// K4 — pins the breach-notification helper contracts.
///
/// The 72h regulator clock + the template body shape are the only
/// two things an auditor will ever spot-check. Both are pure
/// functions, so a unit test can prove them byte-for-byte
/// deterministic.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/breach_notification.dart';

BreachIncident _fixture({
  BreachSeverity severity = BreachSeverity.high,
  int affected = 12,
  DateTime? detected,
  DateTime? contained,
}) => BreachIncident(
  id: 'inc-fixture-1',
  detectedAtUtc: detected ?? DateTime.utc(2026, 6, 25, 10, 0),
  severity: severity,
  affectedPatientCount: affected,
  dataCategories: const [
    BreachDataCategory.phi,
    BreachDataCategory.specialCategory,
  ],
  description: 'Misconfigured Firestore rule on /test path; corrected.',
  containedAtUtc: contained,
);

void main() {
  group('deadlinesForBreach', () {
    test('72h regulator deadline is exactly detection + 72h UTC', () {
      final inc = _fixture(detected: DateTime.utc(2026, 6, 25, 10, 0));
      final d = deadlinesForBreach(inc);
      expect(d.regulator72h, DateTime.utc(2026, 6, 28, 10, 0));
    });

    test('60d HIPAA deadline is exactly detection + 60d UTC', () {
      final inc = _fixture(detected: DateTime.utc(2026, 6, 25, 10, 0));
      final d = deadlinesForBreach(inc);
      expect(d.hipaa60d, DateTime.utc(2026, 8, 24, 10, 0));
    });
  });

  group('urgencyAt buckets', () {
    final deadline = DateTime.utc(2026, 6, 28, 10, 0);

    test('green when > 24h remaining', () {
      expect(
        urgencyAt(deadline: deadline, now: DateTime.utc(2026, 6, 27, 9, 0)),
        BreachDeadlineUrgency.green,
      );
    });

    test('yellow when ≤ 24h and > 6h remaining', () {
      expect(
        urgencyAt(deadline: deadline, now: DateTime.utc(2026, 6, 27, 10, 0)),
        BreachDeadlineUrgency.yellow,
      );
      expect(
        urgencyAt(deadline: deadline, now: DateTime.utc(2026, 6, 28, 3, 59)),
        BreachDeadlineUrgency.yellow,
      );
    });

    test('red when ≤ 6h and > 0h remaining', () {
      expect(
        urgencyAt(deadline: deadline, now: DateTime.utc(2026, 6, 28, 4, 0)),
        BreachDeadlineUrgency.red,
      );
      expect(
        urgencyAt(deadline: deadline, now: DateTime.utc(2026, 6, 28, 9, 59)),
        BreachDeadlineUrgency.red,
      );
    });

    test('overdue when past deadline', () {
      expect(
        urgencyAt(deadline: deadline, now: DateTime.utc(2026, 6, 28, 10, 1)),
        BreachDeadlineUrgency.overdue,
      );
    });
  });

  group('requiresIndividualNotice', () {
    test('high + critical require individual notice', () {
      expect(BreachSeverity.high.requiresIndividualNotice, isTrue);
      expect(BreachSeverity.critical.requiresIndividualNotice, isTrue);
    });

    test('low + medium → regulator only', () {
      expect(BreachSeverity.low.requiresIndividualNotice, isFalse);
      expect(BreachSeverity.medium.requiresIndividualNotice, isFalse);
    });
  });

  group('buildNotificationTemplate — KVKK', () {
    test('renders Turkish header + 72h deadline + Turkish category labels', () {
      final body = buildNotificationTemplate(
        incident: _fixture(),
        jurisdiction: BreachJurisdiction.kvkkTurkey,
        controllerName: 'PsyClinicAI EU Sp. z o.o.',
        dpoEmail: 'dpo@psyclinicai.com',
      );
      expect(body, contains('KVKK md. 12/5'));
      expect(body, contains('Veri Sorumlusu**: PsyClinicAI EU Sp. z o.o.'));
      expect(body, contains('inc-fixture-1'));
      // 72h after 2026-06-25T10:00:00Z = 2026-06-28T10:00:00Z
      expect(body, contains('2026-06-28T10:00:00Z'));
      expect(body, contains('Sağlık verisi (HIPAA PHI)'));
      expect(body, contains('Özel nitelikli kişisel veri'));
      expect(body, contains('veri özneleri de doğrudan bilgilendirilecektir'));
    });

    test('low severity skips the individual-notice line', () {
      final body = buildNotificationTemplate(
        incident: _fixture(severity: BreachSeverity.low),
        jurisdiction: BreachJurisdiction.kvkkTurkey,
        controllerName: 'PsyClinicAI EU Sp. z o.o.',
        dpoEmail: 'dpo@psyclinicai.com',
      );
      expect(body, contains('sadece Kurul bildirimi yeterli görüldü'));
      expect(body, isNot(contains('doğrudan bilgilendirilecektir')));
    });
  });

  group('buildNotificationTemplate — GDPR', () {
    test('renders English Art. 33 header + 72h deadline + English labels', () {
      final body = buildNotificationTemplate(
        incident: _fixture(),
        jurisdiction: BreachJurisdiction.euGdpr,
        controllerName: 'PsyClinicAI EU Sp. z o.o.',
        dpoEmail: 'dpo@psyclinicai.com',
      );
      expect(body, contains('GDPR Art. 33'));
      expect(body, contains('Protected Health Information (HIPAA PHI)'));
      expect(body, contains('2026-06-28T10:00:00Z'));
      expect(body, contains('data subjects WILL be notified individually'));
    });
  });

  group('buildNotificationTemplate — HIPAA', () {
    test('renders 60-day deadline (not 72h) + under-500 anchor', () {
      final body = buildNotificationTemplate(
        incident: _fixture(affected: 12),
        jurisdiction: BreachJurisdiction.hipaaUs,
        controllerName: 'PsyClinicAI EU Sp. z o.o.',
        dpoEmail: 'dpo@psyclinicai.com',
      );
      expect(body, contains('45 CFR §164.408'));
      expect(body, contains('2026-08-24T10:00:00Z'));
      expect(body, contains('under 500 threshold'));
      expect(body, isNot(contains('MEDIA NOTIFICATION ALSO REQUIRED')));
    });

    test('≥500 affected triggers the media-notification anchor', () {
      final body = buildNotificationTemplate(
        incident: _fixture(affected: 500),
        jurisdiction: BreachJurisdiction.hipaaUs,
        controllerName: 'PsyClinicAI EU Sp. z o.o.',
        dpoEmail: 'dpo@psyclinicai.com',
      );
      expect(body, contains('MEDIA NOTIFICATION ALSO REQUIRED'));
    });

    test('contained timestamp surfaces in the safeguards section', () {
      final body = buildNotificationTemplate(
        incident: _fixture(contained: DateTime.utc(2026, 6, 25, 12, 30)),
        jurisdiction: BreachJurisdiction.hipaaUs,
        controllerName: 'PsyClinicAI EU Sp. z o.o.',
        dpoEmail: 'dpo@psyclinicai.com',
      );
      expect(body, contains('Containment completed at 2026-06-25T12:30:00Z'));
    });
  });
}
