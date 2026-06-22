import 'dart:ui' show Locale;

import '../../models/crisis_resource.dart';

/// Curated registry of crisis support resources, grouped by region.
///
/// Sources (last reviewed June 2026):
/// - **US 988**: SAMHSA Suicide & Crisis Lifeline (988lifeline.org), 24/7,
///   free, call or text.
/// - **US Crisis Text Line**: text HOME to 741741 (crisistextline.org).
/// - **EU 112**: pan-European emergency (eena.org).
/// - **UK 116 123**: Samaritans, 24/7, free (samaritans.org).
/// - **DE 0800 111 0 111 / 0800 111 0 222**: TelefonSeelsorge, 24/7, free.
/// - **FR 3114**: national suicide prevention line (2021 launch, 3114.fr).
/// - **NL 0800-0113**: 113 Zelfmoordpreventie, 24/7 (113.nl).
/// - **IT 02 2327 2327**: Telefono Amico (telefonoamico.it).
/// - **ES 024**: Línea de atención a la conducta suicida (2022 launch).
/// - **TR 112**: emergency. No national 24/7 suicide-specific line exists at
///   time of writing — we surface 112 and the international directory.
/// - **INTL findahelpline.com**: IASP-backed directory of vetted lines in
///   130+ countries.
///
/// If a number is added or changes, update the source comment above and bump
/// [lastReviewed]. Numbers are baked in (no remote fetch) so the panel works
/// offline on a clinician's device.
class CrisisResourceRegistry {
  const CrisisResourceRegistry._();

  /// YYYY-MM date the list was last reviewed against official sources.
  static const String lastReviewed = '2026-06';

  /// L-9 fix (audit 2026-06-21): semantic version of the registry's
  /// content. Bumped when ANY hotline number changes, OR when a new
  /// region is added. Lets the UI render "Last updated: …" + lets the
  /// audit log + DSAR export pin the exact registry shape a patient
  /// saw at the time of a crisis-handoff event. Versioning happens
  /// here (not in pubspec) so it tracks data changes, not code shape.
  ///
  /// Pattern: `YYYY.MM.PATCH` — e.g. `2026.06.0` for the June 2026
  /// review; `2026.06.1` for the first in-month correction.
  static const String contentVersion = '2026.06.0';

  // ─────────────────────────── United States ───────────────────────────
  static const CrisisResource us988 = CrisisResource(
    id: 'us-988',
    region: 'US',
    name: '988 Suicide & Crisis Lifeline',
    displayNumber: '988',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · free · call or text',
    description:
        'Confidential support for anyone in distress, in English or '
        'Spanish.',
    dialUri: 'tel:988',
    webUri: 'https://988lifeline.org',
  );

  static const CrisisResource usTextLine = CrisisResource(
    id: 'us-741741',
    region: 'US',
    name: 'Crisis Text Line',
    displayNumber: 'Text HOME to 741741',
    kind: CrisisResourceKind.textLine,
    availability: '24/7 · free',
    description: 'Text-based support with a trained crisis counselor.',
    smsInstruction: 'Text HOME to 741741',
    webUri: 'https://www.crisistextline.org',
  );

  static const CrisisResource us911 = CrisisResource(
    id: 'us-911',
    region: 'US',
    name: '911 Emergency',
    displayNumber: '911',
    kind: CrisisResourceKind.emergency,
    availability: '24/7',
    description: 'For imminent danger to life.',
    dialUri: 'tel:911',
  );

  // ─────────────────────────────── Europe ───────────────────────────────
  static const CrisisResource eu112 = CrisisResource(
    id: 'eu-112',
    region: 'EU',
    name: '112 European Emergency',
    displayNumber: '112',
    kind: CrisisResourceKind.emergency,
    availability: '24/7',
    description: 'Pan-European emergency number for imminent danger.',
    dialUri: 'tel:112',
  );

  static const CrisisResource uk116123 = CrisisResource(
    id: 'uk-116123',
    region: 'GB',
    name: 'Samaritans',
    displayNumber: '116 123',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · free',
    description: 'Confidential listening for anyone in emotional distress.',
    dialUri: 'tel:116123',
    webUri: 'https://www.samaritans.org',
  );

  static const CrisisResource de0800 = CrisisResource(
    id: 'de-telefonseelsorge',
    region: 'DE',
    name: 'TelefonSeelsorge',
    displayNumber: '0800 111 0 111 · 0800 111 0 222',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · gebührenfrei',
    description: 'Vertrauliche Beratung in akuten Krisen.',
    dialUri: 'tel:+498001110111',
    webUri: 'https://www.telefonseelsorge.de',
  );

  static const CrisisResource fr3114 = CrisisResource(
    id: 'fr-3114',
    region: 'FR',
    name: 'Numéro national de prévention du suicide',
    displayNumber: '3114',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · gratuit',
    description: 'Soutien confidentiel par des professionnels de santé.',
    dialUri: 'tel:3114',
    webUri: 'https://3114.fr',
  );

  static const CrisisResource nl113 = CrisisResource(
    id: 'nl-113',
    region: 'NL',
    name: '113 Zelfmoordpreventie',
    displayNumber: '113 · 0800-0113',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · gratis',
    description: 'Anoniem gesprek of chat met een hulpverlener.',
    dialUri: 'tel:0800-0113',
    webUri: 'https://www.113.nl',
  );

  static const CrisisResource itTelefonoAmico = CrisisResource(
    id: 'it-telefonoamico',
    region: 'IT',
    name: 'Telefono Amico Italia',
    displayNumber: '02 2327 2327',
    kind: CrisisResourceKind.hotline,
    availability: 'Tutti i giorni · 10:00–24:00',
    description: 'Ascolto anonimo per chi vive un momento difficile.',
    dialUri: 'tel:+390223272327',
    webUri: 'https://www.telefonoamico.it',
  );

  static const CrisisResource es024 = CrisisResource(
    id: 'es-024',
    region: 'ES',
    name: 'Línea de atención a la conducta suicida',
    displayNumber: '024',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · gratuita · confidencial',
    description: 'Atención profesional ante ideación o conducta suicida.',
    dialUri: 'tel:024',
  );

  // ─────────────────────────────── Türkiye ──────────────────────────────
  static const CrisisResource tr112 = CrisisResource(
    id: 'tr-112',
    region: 'TR',
    name: '112 Acil Çağrı',
    displayNumber: '112',
    kind: CrisisResourceKind.emergency,
    availability: '7/24',
    description: 'Yaşamsal tehlike durumunda tek acil numara.',
    dialUri: 'tel:112',
  );

  static const CrisisResource tr182 = CrisisResource(
    id: 'tr-182',
    region: 'TR',
    name: 'SABİM Sağlık Danışma',
    displayNumber: '182',
    kind: CrisisResourceKind.hotline,
    availability: '7/24',
    description:
        'Sağlık Bakanlığı danışma hattı — psikiyatrik krizde acil '
        'yönlendirme alabilirsiniz.',
    dialUri: 'tel:182',
    webUri: 'https://sabim.saglik.gov.tr',
  );

  // ─────────────────────────── International ────────────────────────────
  static const CrisisResource intlFindAHelpline = CrisisResource(
    id: 'intl-findahelpline',
    region: 'INTL',
    name: 'Find a helpline (IASP / ThroughLine)',
    displayNumber: 'findahelpline.com',
    kind: CrisisResourceKind.directory,
    availability: 'Vetted lines in 130+ countries',
    description:
        'International directory of verified crisis support, listed '
        'by country and topic.',
    webUri: 'https://findahelpline.com',
  );

  // ───────────────────────────── Lookup ─────────────────────────────────

  /// Resources to surface when no locale is known — safest universal set.
  static const List<CrisisResource> universal = [
    eu112,
    us988,
    uk116123,
    intlFindAHelpline,
  ];

  static const Map<String, List<CrisisResource>> _byCountry = {
    'US': [us988, usTextLine, us911, intlFindAHelpline],
    'GB': [uk116123, eu112, intlFindAHelpline],
    'DE': [de0800, eu112, intlFindAHelpline],
    'FR': [fr3114, eu112, intlFindAHelpline],
    'NL': [nl113, eu112, intlFindAHelpline],
    'IT': [itTelefonoAmico, eu112, intlFindAHelpline],
    'ES': [es024, eu112, intlFindAHelpline],
    'TR': [tr112, tr182, intlFindAHelpline],
  };

  static const Map<String, List<CrisisResource>> _byLanguageFallback = {
    'en': [us988, uk116123, intlFindAHelpline],
    'de': [de0800, eu112, intlFindAHelpline],
    'fr': [fr3114, eu112, intlFindAHelpline],
    'nl': [nl113, eu112, intlFindAHelpline],
    'it': [itTelefonoAmico, eu112, intlFindAHelpline],
    'es': [es024, eu112, intlFindAHelpline],
    'tr': [tr112, tr182, intlFindAHelpline],
  };

  /// All resources known to the registry (for tests / settings screens).
  static List<CrisisResource> get all => [
    us988,
    usTextLine,
    us911,
    eu112,
    uk116123,
    de0800,
    fr3114,
    nl113,
    itTelefonoAmico,
    es024,
    tr112,
    tr182,
    intlFindAHelpline,
  ];

  /// Country-specific list. Falls back to [universal] for unknown codes.
  /// Country code is uppercased ISO 3166-1 alpha-2.
  static List<CrisisResource> forCountry(String? countryCode) {
    if (countryCode == null) return universal;
    final hit = _byCountry[countryCode.toUpperCase()];
    return hit ?? universal;
  }

  /// Picks the country from a [Locale]. Falls back by language when no
  /// country is set (e.g. `Locale('en')` → US, `Locale('de')` → DE).
  static List<CrisisResource> forLocale(Locale? locale) {
    if (locale == null) return universal;
    final c = locale.countryCode;
    if (c != null && _byCountry.containsKey(c.toUpperCase())) {
      return _byCountry[c.toUpperCase()]!;
    }
    return _byLanguageFallback[locale.languageCode.toLowerCase()] ?? universal;
  }
}
