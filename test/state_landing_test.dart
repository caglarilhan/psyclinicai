import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/state_landing.dart';

void main() {
  group('StateLanding', () {
    test('canonical URL routes US states to /usa and EU to /eu', () {
      const us = StateLanding(
        slug: 'california',
        country: 'US',
        region: 'California',
        displayName: 'California therapists',
        therapistEstimate: 38000,
        headlinePrice: r'$49/mo',
        framework: 'HIPAA',
      );
      const de = StateLanding(
        slug: 'germany',
        country: 'DE',
        region: 'Germany',
        displayName: 'Deutschland Psychotherapeuten',
        therapistEstimate: 47000,
        headlinePrice: '€45/Monat',
        framework: 'GDPR',
      );
      expect(us.canonicalUrl, 'https://psyclinicai.com/usa/california');
      expect(de.canonicalUrl, 'https://psyclinicai.com/eu/germany');
    });

    test('JSON includes optional fields only when set', () {
      const sparse = StateLanding(
        slug: 'florida',
        country: 'US',
        region: 'Florida',
        displayName: 'Florida clinicians',
        therapistEstimate: 17500,
        headlinePrice: r'$49/mo',
        framework: 'HIPAA',
      );
      final j = sparse.toJson();
      expect(j.containsKey('timezone_hint'), isFalse);
      expect(j.containsKey('local_board'), isFalse);
      expect(j['canonical_url'], isA<String>());
    });
  });

  group('kSprint25LandingCatalog', () {
    test('ships 12 unique slugs covering US + EU + TR', () {
      expect(kSprint25LandingCatalog.length, 12);
      final slugs = kSprint25LandingCatalog.map((e) => e.slug).toSet();
      expect(slugs.length, 12, reason: 'no duplicate slugs');
      final countries =
          kSprint25LandingCatalog.map((e) => e.country).toSet();
      expect(countries, containsAll(['US', 'DE', 'TR', 'GB']));
    });

    test('every entry carries a compliance framework string', () {
      for (final l in kSprint25LandingCatalog) {
        expect(l.framework, isNotEmpty,
            reason: '${l.slug} missing framework');
      }
    });

    test('TR entry uses KVKK + local board references', () {
      final tr =
          kSprint25LandingCatalog.firstWhere((e) => e.country == 'TR');
      expect(tr.framework, contains('KVKK'));
      expect(tr.localBoard, contains('Türk Psikologlar'));
      expect(tr.headlinePrice, contains('₺'));
    });
  });
}
