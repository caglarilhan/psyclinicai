/// Programmatic SEO state landing record. Each tuple drives one
/// `/usa/{slug}` or `/eu/{country}` URL with localised pricing,
/// HIPAA / GDPR copy and an in-state clinician count claim.
class StateLanding {
  const StateLanding({
    required this.slug,
    required this.country,
    required this.region,
    required this.displayName,
    required this.therapistEstimate,
    required this.headlinePrice,
    required this.framework,
    this.timezoneHint,
    this.localBoard,
  });

  final String slug;
  final String country;
  final String region;
  final String displayName;
  final int therapistEstimate;
  final String headlinePrice;
  final String framework;
  final String? timezoneHint;
  final String? localBoard;

  String get canonicalUrl => country == 'US'
      ? 'https://psyclinicai.com/usa/$slug'
      : 'https://psyclinicai.com/eu/$slug';

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'country': country,
    'region': region,
    'display_name': displayName,
    'therapist_estimate': therapistEstimate,
    'headline_price': headlinePrice,
    'framework': framework,
    if (timezoneHint != null) 'timezone_hint': timezoneHint,
    if (localBoard != null) 'local_board': localBoard,
    'canonical_url': canonicalUrl,
  };
}

const List<StateLanding> kSprint25LandingCatalog = [
  StateLanding(
    slug: 'california',
    country: 'US',
    region: 'California',
    displayName: 'California therapists, psychiatrists & coaches',
    therapistEstimate: 38000,
    headlinePrice: r'$49/mo',
    framework: 'HIPAA + CA Confidentiality of Medical Information Act',
    timezoneHint: 'America/Los_Angeles',
    localBoard: 'California Board of Behavioral Sciences (BBS)',
  ),
  StateLanding(
    slug: 'new-york',
    country: 'US',
    region: 'New York',
    displayName: 'New York mental-health clinicians',
    therapistEstimate: 28000,
    headlinePrice: r'$49/mo',
    framework: 'HIPAA + NY SHIELD Act',
    timezoneHint: 'America/New_York',
    localBoard: 'NY State Education Department',
  ),
  StateLanding(
    slug: 'texas',
    country: 'US',
    region: 'Texas',
    displayName: 'Texas LPCs, LCSWs & psychiatrists',
    therapistEstimate: 21000,
    headlinePrice: r'$49/mo',
    framework: 'HIPAA + Texas Medical Records Privacy Act',
    timezoneHint: 'America/Chicago',
    localBoard: 'Texas Behavioral Health Executive Council',
  ),
  StateLanding(
    slug: 'florida',
    country: 'US',
    region: 'Florida',
    displayName: 'Florida mental-health clinicians',
    therapistEstimate: 17500,
    headlinePrice: r'$49/mo',
    framework: 'HIPAA + Florida Information Protection Act',
    timezoneHint: 'America/New_York',
    localBoard: 'Florida Department of Health · 491 Board',
  ),
  StateLanding(
    slug: 'massachusetts',
    country: 'US',
    region: 'Massachusetts',
    displayName: 'Massachusetts therapists',
    therapistEstimate: 9500,
    headlinePrice: r'$49/mo',
    framework: 'HIPAA + 201 CMR 17.00 (MA data security)',
    timezoneHint: 'America/New_York',
    localBoard: 'MA Board of Registration of Allied Mental Health',
  ),
  StateLanding(
    slug: 'germany',
    country: 'DE',
    region: 'Germany',
    displayName: 'Deutschland Psychotherapeuten & Psychiater',
    therapistEstimate: 47000,
    headlinePrice: '€45/Monat',
    framework: 'GDPR + §203 StGB + BDSG',
    timezoneHint: 'Europe/Berlin',
    localBoard: 'Bundespsychotherapeutenkammer (BPtK)',
  ),
  StateLanding(
    slug: 'netherlands',
    country: 'NL',
    region: 'Netherlands',
    displayName: 'Nederlandse psychotherapeuten',
    therapistEstimate: 11000,
    headlinePrice: '€45/maand',
    framework: 'GDPR + WGBO',
    timezoneHint: 'Europe/Amsterdam',
    localBoard: 'NVP — Nederlandse Vereniging voor Psychotherapie',
  ),
  StateLanding(
    slug: 'france',
    country: 'FR',
    region: 'France',
    displayName: 'Psychothérapeutes et psychiatres en France',
    therapistEstimate: 30000,
    headlinePrice: '45€/mois',
    framework: 'GDPR + Code de la santé publique L1110-4',
    timezoneHint: 'Europe/Paris',
    localBoard: 'Ordre des Médecins · ARS',
  ),
  StateLanding(
    slug: 'italy',
    country: 'IT',
    region: 'Italy',
    displayName: 'Psicoterapeuti e psichiatri in Italia',
    therapistEstimate: 38000,
    headlinePrice: '€45/mese',
    framework: 'GDPR + Codice Privacy (D.Lgs. 196/2003)',
    timezoneHint: 'Europe/Rome',
    localBoard: 'CNOP (Consiglio Nazionale Ordine Psicologi)',
  ),
  StateLanding(
    slug: 'spain',
    country: 'ES',
    region: 'Spain',
    displayName: 'Psicoterapeutas y psiquiatras en España',
    therapistEstimate: 23000,
    headlinePrice: '45€/mes',
    framework: 'GDPR + LOPDGDD (3/2018)',
    timezoneHint: 'Europe/Madrid',
    localBoard: 'Consejo General de Colegios Oficiales de Psicólogos',
  ),
  StateLanding(
    slug: 'united-kingdom',
    country: 'GB',
    region: 'United Kingdom',
    displayName: 'UK therapists, counsellors and psychiatrists',
    therapistEstimate: 32000,
    headlinePrice: '£39/mo',
    framework: 'UK GDPR + Data Protection Act 2018',
    timezoneHint: 'Europe/London',
    localBoard: 'BACP · UKCP · HCPC',
  ),
  StateLanding(
    slug: 'turkey',
    country: 'TR',
    region: 'Türkiye',
    displayName: 'Türkiye psikolog ve psikiyatrlar',
    therapistEstimate: 18000,
    headlinePrice: '₺1.450/ay',
    framework: 'KVKK + Sağlık Bakanlığı Veri Güvenliği Tebliği',
    timezoneHint: 'Europe/Istanbul',
    localBoard: 'Türk Psikologlar Derneği',
  ),
];
