import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/wcag_contrast.dart';

/// B14 — design-system contrast regression. Pins the brand-token
/// colour pairs against the WCAG 2.2 thresholds so a future palette
/// tweak cannot silently demote a body-text colour below AA.
///
/// We deliberately exercise the *hexes* (not Theme.of, which needs a
/// widget tree) — these tests must work in a pure-Dart CI runner.
void main() {
  // Light scheme — mirrors `PsyTheme.light()` in lib/theme/brand_colors.dart.
  const lightSurface = 0xFFFFFFFF; // n0
  const lightOnSurface = 0xFF0F172A; // n900
  const lightPrimary = 0xFF0F766E; // teal-700
  const lightSurfaceContainerLow = 0xFFF8FAFC; // light tinted card
  const lightMutedCaption = 0xFF94A3B8; // n400 — caption only

  // Dark scheme — mirrors `PsyTheme.dark()`.
  const darkSurface = 0xFF0F172A; // n900
  const darkOnSurface = 0xFFF1F5F9; // n100
  const darkPrimary = 0xFF5EEAD4; // teal-300

  // Risk band colours used on PHQ-9 / GAD-7 charts.
  const riskMinimal = 0xFF16A34A;
  const riskSevere = 0xFFDC2626;

  group('Light scheme — body text', () {
    test('onSurface on surface passes AA-small (slate on white)', () {
      final ratio = contrastRatio(lightOnSurface, lightSurface);
      expect(ratio, greaterThanOrEqualTo(wcagAaSmallText),
          reason: 'Body slate must clear 4.5 against a white card');
      expect(passesWcagAa(lightOnSurface, lightSurface), isTrue);
    });

    test('onSurface on tinted card surface still passes AA-small', () {
      expect(
          passesWcagAa(lightOnSurface, lightSurfaceContainerLow), isTrue);
    });

    test('AAA-small holds for slate body on white (≥ 7.0)', () {
      expect(passesWcagAaa(lightOnSurface, lightSurface), isTrue,
          reason: 'Premium tier — body text should beat 7.0 too');
    });
  });

  group('Light scheme — caption colour discipline', () {
    test('n400 (muted) fails AA-small — caption-only by design', () {
      // The point of this test: keep n400 OUT of body usage. The day a
      // designer drops n400 onto a body label, AA-small starts failing
      // and the regression flares here.
      expect(passesWcagAa(lightMutedCaption, lightSurface), isFalse);
    });
  });

  group('Light scheme — primary actions', () {
    test('primary teal on white passes AA-large (button label)', () {
      expect(passesWcagAa(lightPrimary, lightSurface, largeText: true),
          isTrue);
    });
  });

  group('Dark scheme', () {
    test('onSurface n100 on dark slate passes AA-small', () {
      expect(passesWcagAa(darkOnSurface, darkSurface), isTrue);
    });

    test('dark primary teal-300 still legible on dark slate (AA-large)',
        () {
      expect(passesWcagAa(darkPrimary, darkSurface, largeText: true),
          isTrue);
    });
  });

  group('Risk band chips (white background)', () {
    test('riskMinimal green passes AA-large on white', () {
      expect(passesWcagAa(riskMinimal, lightSurface, largeText: true),
          isTrue);
    });

    test('riskSevere red passes AA-large on white', () {
      expect(passesWcagAa(riskSevere, lightSurface, largeText: true),
          isTrue);
    });
  });
}
