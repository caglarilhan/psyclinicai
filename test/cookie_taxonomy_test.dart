import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/cookie_taxonomy.dart';

void main() {
  group('CookieTaxonomy — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(CookieTaxonomy.cookies, isNotEmpty);
    });

    test('every cookie has a unique id', () {
      final ids = CookieTaxonomy.cookies.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final c in CookieTaxonomy.cookies) {
        expect(CookieTaxonomy.byId(c.id), same(c));
      }
      expect(CookieTaxonomy.byId('does-not-exist'), isNull);
    });

    test('every cookie has fields populated', () {
      for (final c in CookieTaxonomy.cookies) {
        expect(c.name, isNotEmpty, reason: c.id);
        expect(c.vendor, isNotEmpty, reason: c.id);
        expect(c.purpose, isNotEmpty, reason: c.id);
        expect(c.regulatoryRefs, isNotEmpty, reason: c.id);
        expect(c.retentionDays, greaterThanOrEqualTo(0), reason: c.id);
      }
    });

    test('essential cookies DO NOT require opt-in (Art. 5(3) exemption)', () {
      for (final c in CookieTaxonomy.byCategory(CookieCategory.essential)) {
        expect(
          c.requiresOptIn,
          isFalse,
          reason:
              '${c.id}: essential cookies are exempt under ePrivacy Art. '
              '5(3) "strictly necessary"',
        );
      }
    });

    test('non-essential cookies (functional / analytics / marketing) REQUIRE '
        'opt-in', () {
      for (final c in CookieTaxonomy.cookies) {
        if (c.category == CookieCategory.essential) continue;
        expect(
          c.requiresOptIn,
          isTrue,
          reason:
              '${c.id}: category ${c.category.name} requires explicit '
              'opt-in (GDPR Art. 6(1)(a) + ePrivacy Art. 5(3))',
        );
      }
    });

    test('every essential cookie cites the ePrivacy Art. 5(3) exemption', () {
      for (final c in CookieTaxonomy.byCategory(CookieCategory.essential)) {
        final blob = c.regulatoryRefs.join(' | ');
        expect(
          blob,
          contains('Art. 5(3)'),
          reason:
              '${c.id}: essential cookies MUST cite ePrivacy Art. 5(3) so '
              'auditors can verify the "strictly necessary" claim',
        );
      }
    });

    test('zero marketing trackers ship today (banned by default)', () {
      final marketing = CookieTaxonomy.byCategory(CookieCategory.marketing);
      expect(
        marketing,
        isEmpty,
        reason:
            'no marketing tracker may ship without an explicit PR adding '
            'it to the taxonomy + the opt-in UI handling it',
      );
    });

    test(
      'isAllowedOnClinicalSurface allows essential, forbids everything else',
      () {
        expect(isAllowedOnClinicalSurface(CookieCategory.essential), isTrue);
        expect(isAllowedOnClinicalSurface(CookieCategory.functional), isFalse);
        expect(isAllowedOnClinicalSurface(CookieCategory.analytics), isFalse);
        expect(isAllowedOnClinicalSurface(CookieCategory.marketing), isFalse);
      },
    );

    test('byCategory slices correctly', () {
      for (final cat in CookieCategory.values) {
        final slice = CookieTaxonomy.byCategory(cat);
        for (final c in slice) {
          expect(c.category, cat);
        }
      }
    });

    test('cookie acknowledgement marker is itself an essential cookie', () {
      final ack = CookieTaxonomy.byId('cookie-consent-acknowledged');
      expect(ack, isNotNull);
      expect(ack!.category, CookieCategory.essential);
      expect(ack.requiresOptIn, isFalse);
    });

    test('PostHog analytics cite German TTDSG §25 (national impl)', () {
      final ph = CookieTaxonomy.byId('posthog-distinct-id')!;
      final blob = ph.regulatoryRefs.join(' | ');
      expect(blob, contains('TTDSG'));
    });
  });
}
