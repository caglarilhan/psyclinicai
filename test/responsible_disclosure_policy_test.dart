import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/responsible_disclosure_policy.dart';

void main() {
  group('ResponsibleDisclosurePolicy — severity invariants', () {
    test('every VulnSeverity has exactly one pinned record', () {
      final pinned = ResponsibleDisclosurePolicy.severities
          .map((p) => p.severity)
          .toSet();
      expect(pinned, equals(VulnSeverity.values.toSet()));
      expect(
        ResponsibleDisclosurePolicy.severities.length,
        VulnSeverity.values.length,
        reason: 'duplicate record for a severity',
      );
    });

    test('forSeverity resolves every enum value', () {
      for (final s in VulnSeverity.values) {
        expect(ResponsibleDisclosurePolicy.forSeverity(s).severity, s);
      }
    });

    test('every record has populated fields + positive timings', () {
      for (final p in ResponsibleDisclosurePolicy.severities) {
        expect(p.exampleVulnClass, isNotEmpty, reason: p.severity.name);
        expect(
          p.acknowledgeWithinHours,
          greaterThan(0),
          reason: p.severity.name,
        );
        expect(
          p.remediationTargetDays,
          greaterThan(0),
          reason: p.severity.name,
        );
        expect(
          p.publicDisclosureAfterDays,
          greaterThanOrEqualTo(0),
          reason: p.severity.name,
        );
      }
    });

    test('critical < high < medium < low for acknowledge speed', () {
      final c = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.critical);
      final h = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.high);
      final m = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.medium);
      final l = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.low);
      expect(c.acknowledgeWithinHours, lessThan(h.acknowledgeWithinHours));
      expect(h.acknowledgeWithinHours, lessThan(m.acknowledgeWithinHours));
      expect(m.acknowledgeWithinHours, lessThan(l.acknowledgeWithinHours));
    });

    test('critical < high < medium < low for remediation target', () {
      final c = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.critical);
      final h = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.high);
      final m = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.medium);
      final l = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.low);
      expect(c.remediationTargetDays, lessThan(h.remediationTargetDays));
      expect(h.remediationTargetDays, lessThan(m.remediationTargetDays));
      expect(m.remediationTargetDays, lessThan(l.remediationTargetDays));
    });

    test('critical acknowledgement is within 4 hours', () {
      final c = ResponsibleDisclosurePolicy.forSeverity(VulnSeverity.critical);
      expect(c.acknowledgeWithinHours, lessThanOrEqualTo(4));
    });

    test('critical + high + medium + low honour the 90-day coordinated '
        'disclosure standard', () {
      for (final sev in [
        VulnSeverity.critical,
        VulnSeverity.high,
        VulnSeverity.medium,
        VulnSeverity.low,
      ]) {
        final p = ResponsibleDisclosurePolicy.forSeverity(sev);
        expect(
          p.publicDisclosureAfterDays,
          90,
          reason:
              '${sev.name}: industry-standard coordinated disclosure '
              'window is 90 days post-remediation',
        );
      }
    });
  });

  group('ResponsibleDisclosurePolicy — scopes', () {
    test('every scope id is unique', () {
      final ids = ResponsibleDisclosurePolicy.scopes.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('scopeById resolves every entry', () {
      for (final s in ResponsibleDisclosurePolicy.scopes) {
        expect(ResponsibleDisclosurePolicy.scopeById(s.id), same(s));
      }
      expect(ResponsibleDisclosurePolicy.scopeById('does-not-exist'), isNull);
    });

    test('web app + RAG hub + Cloud Functions + Firestore rules in scope', () {
      const must = ['web-app', 'rag-hub', 'cloud-functions', 'firestore-rules'];
      for (final id in must) {
        final s = ResponsibleDisclosurePolicy.scopeById(id)!;
        expect(
          s.inScope,
          isTrue,
          reason: '$id MUST be in scope for the disclosure programme',
        );
      }
    });

    test('DoS + social engineering + third-party domains out of scope', () {
      const must = [
        'denial-of-service',
        'social-engineering',
        'third-party-domains',
      ];
      for (final id in must) {
        final s = ResponsibleDisclosurePolicy.scopeById(id)!;
        expect(s.inScope, isFalse, reason: '$id MUST be out of scope');
      }
    });

    test('every scope has populated surface + exampleVuln', () {
      for (final s in ResponsibleDisclosurePolicy.scopes) {
        expect(s.surface, isNotEmpty, reason: s.id);
        expect(s.exampleVuln, isNotEmpty, reason: s.id);
      }
    });
  });

  group('ResponsibleDisclosurePolicy — security.txt parity', () {
    test(
      'web/.well-known/security.txt mirrors the pinned contact + expiry',
      () async {
        final f = File('web/.well-known/security.txt');
        expect(
          f.existsSync(),
          isTrue,
          reason: 'security.txt is mandatory under RFC 9116',
        );
        final content = await f.readAsString();
        expect(
          content,
          contains(
            'Contact: mailto:${ResponsibleDisclosurePolicy.contactEmail}',
          ),
          reason:
              'security.txt Contact must match ResponsibleDisclosurePolicy.'
              'contactEmail',
        );
        expect(
          content,
          contains(
            'Expires: ${ResponsibleDisclosurePolicy.securityTxtExpiresIso}',
          ),
          reason:
              'security.txt Expires must match ResponsibleDisclosurePolicy.'
              'securityTxtExpiresIso',
        );
        for (final lang in ResponsibleDisclosurePolicy.preferredLanguages) {
          expect(
            content,
            contains(lang),
            reason: 'security.txt must list $lang under Preferred-Languages',
          );
        }
      },
    );

    test('safe-harbor language is non-empty + names "good faith"', () {
      expect(ResponsibleDisclosurePolicy.researcherSafeHarbor, isNotEmpty);
      expect(
        ResponsibleDisclosurePolicy.researcherSafeHarbor,
        contains('good faith'),
        reason:
            'safe-harbor language must explicitly say "good faith" so '
            'researchers know what is covered',
      );
    });
  });

  group('daysUntilSecurityTxtExpiry', () {
    test('positive when expiry is in the future', () {
      final today = DateTime.parse('2027-04-23T00:00:00.000Z');
      final left = daysUntilSecurityTxtExpiry(today);
      expect(left, 30);
    });

    test('zero on the expiry day itself', () {
      final today = DateTime.parse('2027-05-23T00:00:00.000Z');
      expect(daysUntilSecurityTxtExpiry(today), 0);
    });

    test('negative once expired', () {
      final today = DateTime.parse('2027-06-23T00:00:00.000Z');
      expect(daysUntilSecurityTxtExpiry(today), -31);
    });

    test('the pinned expiry is at least 60 days away from today date', () {
      final today = DateTime.parse('2026-06-26T00:00:00.000Z');
      final left = daysUntilSecurityTxtExpiry(today);
      expect(
        left,
        greaterThan(60),
        reason:
            'security.txt should be ≥ 60 days from rotation as of the '
            'lastReviewed stamp; if this drops below 60, rotate the file '
            'and bump securityTxtExpiresIso',
      );
    });
  });
}
