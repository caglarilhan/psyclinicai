import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/wcag_contrast.dart';

void main() {
  // Common test pairs. We use 0xFF__ for fully-opaque ARGB so the helper
  // can ignore the alpha channel.
  const black = 0xFF000000;
  const white = 0xFFFFFFFF;
  const grey = 0xFF808080;
  const teal500 = 0xFF0F766E; // PsyClinicAI primary
  const slate900 = 0xFF0F172A; // PsyClinicAI body text
  const surface = 0xFFFFFFFF;
  const muted = 0xFF94A3B8; // PsyColors n400 — caption candidate

  group('relativeLuminance', () {
    test('pure black is 0 and pure white is 1', () {
      expect(relativeLuminance(black), closeTo(0.0, 1e-6));
      expect(relativeLuminance(white), closeTo(1.0, 1e-6));
    });

    test('mid-grey lands between black and white', () {
      final l = relativeLuminance(grey);
      expect(l, greaterThan(0.2));
      expect(l, lessThan(0.3));
    });
  });

  group('contrastRatio', () {
    test('black on white is the maximum 21:1', () {
      expect(contrastRatio(black, white), closeTo(21.0, 0.01));
    });

    test('identical colours yield 1:1', () {
      expect(contrastRatio(teal500, teal500), closeTo(1.0, 1e-6));
    });

    test('ordering does not matter (commutative)', () {
      expect(
        contrastRatio(teal500, white),
        closeTo(contrastRatio(white, teal500), 1e-9),
      );
    });
  });

  group('WCAG gates against the brand palette', () {
    test('slate body text on white passes AA-small (≥ 4.5)', () {
      final ratio = contrastRatio(slate900, surface);
      expect(ratio, greaterThanOrEqualTo(wcagAaSmallText));
      expect(passesWcagAa(slate900, surface), isTrue);
    });

    test('teal-on-white passes AA-large at minimum', () {
      // Sanity — for many brand teals this is the realistic boundary.
      expect(passesWcagAa(teal500, surface, largeText: true), isTrue);
    });

    test('muted grey on white fails AA-small (caption-only colour)', () {
      expect(
        passesWcagAa(muted, surface),
        isFalse,
        reason: 'PsyColors.n400 is meant for captions, not body text',
      );
    });

    test('passesWcagAaa never holds when passesWcagAa is false', () {
      // For body text on white, the AAA gate (7.0) is stricter than the
      // AA gate (4.5). The pair must satisfy AA before it can satisfy
      // AAA.
      final aa = passesWcagAa(muted, surface);
      final aaa = passesWcagAaa(muted, surface);
      if (aaa) expect(aa, isTrue);
    });

    test('AAA thresholds are correctly numbered (7.0 small, 4.5 large)', () {
      expect(wcagAaaSmallText, 7.0);
      expect(wcagAaSmallText, 4.5);
      expect(wcagAaLargeText, 3.0);
    });
  });
}
