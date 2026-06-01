/// WCAG 2.2 contrast-ratio calculator and AA/AAA gating.
///
/// Implementation follows the WCAG relative-luminance formula
/// (https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio):
///
/// 1. Convert each sRGB channel to a linear value with the gamma curve
///    `c ≤ 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)^2.4`.
/// 2. Relative luminance L = 0.2126·R + 0.7152·G + 0.0722·B.
/// 3. Contrast ratio = (L_lighter + 0.05) / (L_darker + 0.05).
///
/// Pure — only `dart:math` is imported, so the helper is callable from a
/// pure-Dart CI check as well as the design-system tests.
library;

import 'dart:math' as math;

/// AA threshold for body text (small text) — WCAG SC 1.4.3.
const double wcagAaSmallText = 4.5;

/// AA threshold for large text (≥18pt or ≥14pt bold).
const double wcagAaLargeText = 3.0;

/// AAA threshold for body text — WCAG SC 1.4.6.
const double wcagAaaSmallText = 7.0;

/// Returns the WCAG relative luminance of an sRGB colour passed as a
/// 32-bit ARGB integer (the same shape Flutter's `Color.value` exposes).
double relativeLuminance(int argb) {
  final r = ((argb >> 16) & 0xFF) / 255.0;
  final g = ((argb >> 8) & 0xFF) / 255.0;
  final b = (argb & 0xFF) / 255.0;
  double lin(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
}

/// Contrast ratio between two sRGB colours. Always returns a value
/// `>= 1.0` (identical colours) up to `21.0` (pure black vs pure white).
double contrastRatio(int fgArgb, int bgArgb) {
  final l1 = relativeLuminance(fgArgb);
  final l2 = relativeLuminance(bgArgb);
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

/// True when the foreground/background pair passes the WCAG AA bar for
/// the given text size class.
bool passesWcagAa(int fgArgb, int bgArgb, {bool largeText = false}) {
  final ratio = contrastRatio(fgArgb, bgArgb);
  return ratio >= (largeText ? wcagAaLargeText : wcagAaSmallText);
}

/// True when the pair passes the stricter AAA bar for small text (and
/// AAA-large collapses to the AA-small bar of 4.5).
bool passesWcagAaa(int fgArgb, int bgArgb, {bool largeText = false}) {
  final ratio = contrastRatio(fgArgb, bgArgb);
  return ratio >= (largeText ? wcagAaSmallText : wcagAaaSmallText);
}
