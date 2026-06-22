/// Declarative list of locales we ship strings for. Drives:
/// - the language picker in Settings,
/// - the locale-aware crisis-resource registry,
/// - the runtime fallback chain when a string is missing.
///
/// Pure data + helpers — no Flutter imports — so it can be unit-tested
/// without booting widgets.
library;

import 'dart:ui' show Locale;

class SupportedLocale {
  const SupportedLocale({
    required this.languageCode,
    required this.englishName,
    required this.nativeName,
    this.isRtl = false,
  });

  final String languageCode; // ISO 639-1 (e.g. "tr")
  final String englishName; // "Turkish"
  final String nativeName; // "Türkçe"
  final bool isRtl;

  Locale get locale => Locale(languageCode);
}

/// English is always present and is the runtime fallback.
const SupportedLocale english = SupportedLocale(
  languageCode: 'en',
  englishName: 'English',
  nativeName: 'English',
);

/// Ordered by clinical-market priority: TR first (home market), then the
/// EU languages we have validated PHQ-9 / GAD-7 translations for.
const List<SupportedLocale> supportedLocales = [
  english,
  SupportedLocale(
    languageCode: 'tr',
    englishName: 'Turkish',
    nativeName: 'Türkçe',
  ),
  SupportedLocale(
    languageCode: 'de',
    englishName: 'German',
    nativeName: 'Deutsch',
  ),
  SupportedLocale(
    languageCode: 'fr',
    englishName: 'French',
    nativeName: 'Français',
  ),
  SupportedLocale(
    languageCode: 'nl',
    englishName: 'Dutch',
    nativeName: 'Nederlands',
  ),
  SupportedLocale(
    languageCode: 'it',
    englishName: 'Italian',
    nativeName: 'Italiano',
  ),
  SupportedLocale(
    languageCode: 'es',
    englishName: 'Spanish',
    nativeName: 'Español',
  ),
];

/// Returns the [SupportedLocale] whose [SupportedLocale.languageCode]
/// matches [code] (case-insensitive). Falls back to English when no match
/// — never throws so a corrupt preferences value can't crash startup.
SupportedLocale resolveSupportedLocale(String? code) {
  if (code == null || code.isEmpty) return english;
  final lc = code.toLowerCase();
  for (final s in supportedLocales) {
    if (s.languageCode == lc) return s;
  }
  return english;
}

/// True when the language code is on the shipped list.
bool isLocaleSupported(String? code) {
  if (code == null) return false;
  final lc = code.toLowerCase();
  return supportedLocales.any((s) => s.languageCode == lc);
}

/// Chooses the best locale match for the device locale. Honors the
/// country code when we ship a country-specific variant (none today);
/// otherwise picks the language family or falls through to English.
SupportedLocale bestMatchForDeviceLocale(Locale? deviceLocale) {
  if (deviceLocale == null) return english;
  return resolveSupportedLocale(deviceLocale.languageCode);
}
