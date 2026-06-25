/// K4 — Personal data breach notification helpers.
///
/// **Why pure helpers first**: the regulatory clock is the whole
/// game. KVKK md. 12/5 + GDPR Art. 33(1) + HIPAA §164.408(b) all
/// pin a 72-hour notification window from *awareness* of a breach.
/// Getting that arithmetic wrong is the breach turning into a
/// fine. We lift the deadline math + the template body into
/// dependency-free Dart so a unit test can pin both, and the UI /
/// email-send layer (separate PR) wraps them.
///
/// Coverage:
///   * KVK Kurumu (KVKK md. 12/5 — "en kısa sürede ve her halükarda
///     72 saat içinde") — Turkish template.
///   * EU supervisory authority (GDPR Art. 33(1)) — English EU
///     template; the controller routes to their lead SA via the
///     Trust Center DPO contact.
///   * US HHS Office for Civil Rights (HIPAA §164.408(b)) —
///     "without unreasonable delay and in no case later than 60
///     days". We surface BOTH the GDPR 72h *and* the HIPAA 60d
///     deadlines so the on-call doesn't have to remember which
///     timer governs which jurisdiction.
///
/// Scope explicitly OUT of this helper:
///   * Sending the email (separate PR — wires `functions/src/
///     breach_dispatch.ts` once the on-call confirms the draft).
///   * Storing the incident record (Firestore + rules — separate).
library;

/// Categories of personal data exposed in a breach. Enum so the
/// template builder can render the right Turkish + English label
/// without free-text drift between filings.
enum BreachDataCategory {
  /// HIPAA PHI (medical, mental-health notes, assessments).
  phi,

  /// Demographics (name, DOB, address, phone, email).
  identifiers,

  /// Special-category data under GDPR Art. 9 / KVKK md. 6 —
  /// health, biometric, sexual orientation, ethnic origin.
  specialCategory,

  /// Auth credentials (password hashes, MFA seeds, recovery codes).
  credentials,

  /// Financial (Stripe customer ids, billing addresses, deposit
  /// charge metadata — never card numbers; we don't store those).
  financial,

  /// Audit / metadata only (no clinical content).
  metadata,
}

extension BreachDataCategoryLabel on BreachDataCategory {
  String get id => name;

  String get englishLabel {
    switch (this) {
      case BreachDataCategory.phi:
        return 'Protected Health Information (HIPAA PHI)';
      case BreachDataCategory.identifiers:
        return 'Identifiers (name, DOB, contact)';
      case BreachDataCategory.specialCategory:
        return 'Special-category data (GDPR Art. 9 / KVKK md. 6)';
      case BreachDataCategory.credentials:
        return 'Authentication credentials';
      case BreachDataCategory.financial:
        return 'Financial metadata (Stripe customer ids, billing)';
      case BreachDataCategory.metadata:
        return 'Audit metadata (no clinical content)';
    }
  }

  String get turkishLabel {
    switch (this) {
      case BreachDataCategory.phi:
        return 'Sağlık verisi (HIPAA PHI)';
      case BreachDataCategory.identifiers:
        return 'Kimlik bilgisi (ad, doğum tarihi, iletişim)';
      case BreachDataCategory.specialCategory:
        return 'Özel nitelikli kişisel veri (KVKK md. 6)';
      case BreachDataCategory.credentials:
        return 'Kimlik doğrulama bilgisi (parola, MFA)';
      case BreachDataCategory.financial:
        return 'Finansal üst veri (Stripe müşteri kimliği, fatura)';
      case BreachDataCategory.metadata:
        return 'Denetim üst verisi (klinik içerik yok)';
    }
  }
}

/// Severity tiers — drives both the dashboard color and (via
/// `requiresIndividualNotice`) whether the patients themselves
/// must be notified in addition to the regulator.
enum BreachSeverity {
  /// Limited metadata exposure, no PHI / special-category content.
  low,

  /// PHI / identifiers exposed but contained (single patient,
  /// non-special-category, fast revocation).
  medium,

  /// Special-category data exposed OR > 50 patients OR persistent
  /// exposure. Always requires individual patient notification
  /// (GDPR Art. 34(1) "high risk to rights and freedoms").
  high,

  /// Active exploitation, ongoing exfiltration, ransomware. Triage
  /// runbook splits this into containment + notification streams.
  critical,
}

extension BreachSeverityLabel on BreachSeverity {
  String get id => name;

  /// True when the patients themselves must receive individual
  /// notifications (GDPR Art. 34(1) + HIPAA §164.404). low /
  /// medium → regulator only; high / critical → individuals too.
  bool get requiresIndividualNotice =>
      this == BreachSeverity.high || this == BreachSeverity.critical;
}

/// Immutable breach record. The id is set by the writer (UUID
/// minted at intake time); the timestamps are UTC throughout to
/// avoid daylight-savings off-by-ones in the regulator clock.
class BreachIncident {
  const BreachIncident({
    required this.id,
    required this.detectedAtUtc,
    required this.severity,
    required this.affectedPatientCount,
    required this.dataCategories,
    required this.description,
    this.containedAtUtc,
    this.regulatorNotifiedAtUtc,
    this.individualsNotifiedAtUtc,
  });

  /// Opaque incident id — minted by the intake form; surfaces in
  /// every audit row + every notification template.
  final String id;

  /// When the controller *became aware* of the breach. GDPR Art.
  /// 33(1) clock starts here, NOT when the breach happened.
  final DateTime detectedAtUtc;

  final BreachSeverity severity;

  /// Number of distinct data subjects affected. Drives the
  /// HIPAA "500 individuals" threshold for HHS media notice
  /// (§164.408(b)) and the GDPR "scale of processing" weighting.
  final int affectedPatientCount;

  final List<BreachDataCategory> dataCategories;

  /// One-paragraph factual description — what happened, what
  /// systems, what wasn't accessed. Goes verbatim into the
  /// notification template. Keep < 500 chars for KVK Kurumu form.
  final String description;

  /// Set when containment completed (revoked credentials,
  /// rotated keys, isolated affected system).
  final DateTime? containedAtUtc;

  /// Set when the regulator notification was filed.
  final DateTime? regulatorNotifiedAtUtc;

  /// Set when individual data subjects were notified (high /
  /// critical only). Required by GDPR Art. 34(2) + HIPAA §164.404.
  final DateTime? individualsNotifiedAtUtc;
}

/// 72-hour clock per GDPR Art. 33(1) + KVKK md. 12/5. Lifted out
/// so the on-call dashboard can render "X hours remaining" with
/// the same math the template uses for the deadline footer.
class BreachDeadlines {
  const BreachDeadlines({required this.regulator72h, required this.hipaa60d});

  /// Latest moment the GDPR / KVKK regulator can be notified.
  final DateTime regulator72h;

  /// Latest moment OCR can be notified under HIPAA §164.408(b)
  /// (without-unreasonable-delay + 60-day cap).
  final DateTime hipaa60d;
}

BreachDeadlines deadlinesForBreach(BreachIncident incident) {
  return BreachDeadlines(
    regulator72h: incident.detectedAtUtc.add(const Duration(hours: 72)),
    hipaa60d: incident.detectedAtUtc.add(const Duration(days: 60)),
  );
}

/// Time-remaining bucket used by the dashboard chip. Pure so the
/// snapshot test pins the boundaries.
enum BreachDeadlineUrgency {
  /// > 24h to deadline.
  green,

  /// 24h ≥ remaining > 6h.
  yellow,

  /// 6h ≥ remaining > 0h.
  red,

  /// Past deadline — the on-call has missed it; escalate to DPO +
  /// legal + CEO immediately.
  overdue,
}

BreachDeadlineUrgency urgencyAt({
  required DateTime deadline,
  required DateTime now,
}) {
  final remaining = deadline.difference(now);
  if (remaining.isNegative) return BreachDeadlineUrgency.overdue;
  if (remaining <= const Duration(hours: 6)) return BreachDeadlineUrgency.red;
  if (remaining <= const Duration(hours: 24)) {
    return BreachDeadlineUrgency.yellow;
  }
  return BreachDeadlineUrgency.green;
}

/// Jurisdiction the notification template targets.
enum BreachJurisdiction {
  /// KVK Kurumu (Türkiye).
  kvkkTurkey,

  /// EU lead supervisory authority (DPA route).
  euGdpr,

  /// US HHS Office for Civil Rights.
  hipaaUs,
}

/// Pure template renderer — returns the markdown body the on-call
/// pastes into the regulator portal (or the email send helper
/// wires it into a draft). Deterministic: the same input always
/// produces the same body, byte-for-byte, so the test pins the
/// contract.
String buildNotificationTemplate({
  required BreachIncident incident,
  required BreachJurisdiction jurisdiction,
  required String controllerName,
  required String dpoEmail,
}) {
  final deadlines = deadlinesForBreach(incident);
  switch (jurisdiction) {
    case BreachJurisdiction.kvkkTurkey:
      return _kvkkTemplate(
        incident: incident,
        deadlines: deadlines,
        controllerName: controllerName,
        dpoEmail: dpoEmail,
      );
    case BreachJurisdiction.euGdpr:
      return _gdprTemplate(
        incident: incident,
        deadlines: deadlines,
        controllerName: controllerName,
        dpoEmail: dpoEmail,
      );
    case BreachJurisdiction.hipaaUs:
      return _hipaaTemplate(
        incident: incident,
        deadlines: deadlines,
        controllerName: controllerName,
        dpoEmail: dpoEmail,
      );
  }
}

String _isoDay(DateTime t) =>
    '${t.toUtc().toIso8601String().substring(0, 19)}Z';

String _kvkkTemplate({
  required BreachIncident incident,
  required BreachDeadlines deadlines,
  required String controllerName,
  required String dpoEmail,
}) {
  final categories = incident.dataCategories
      .map((c) => '- ${c.turkishLabel}')
      .join('\n');
  return '''
# KVKK md. 12/5 — Veri İhlali Bildirimi

**Veri Sorumlusu**: $controllerName
**Veri Sorumlusu Temsilcisi**: $dpoEmail
**Olay Kimliği**: ${incident.id}

## 1. İhlal tarihi
Farkına varma anı (UTC): ${_isoDay(incident.detectedAtUtc)}
72 saatlik bildirim son tarihi (UTC): ${_isoDay(deadlines.regulator72h)}

## 2. Etkilenen veri öznesi sayısı
${incident.affectedPatientCount}

## 3. Etkilenen kişisel veri kategorileri
$categories

## 4. Olay özeti
${incident.description}

## 5. Olası sonuçlar
${incident.severity.requiresIndividualNotice ? 'Veri özneleri için yüksek risk değerlendirildi — KVKK md. 12/5 + GDPR Art. 34 kapsamında veri özneleri de doğrudan bilgilendirilecektir.' : 'Veri özneleri için yüksek risk değerlendirilmedi; sadece Kurul bildirimi yeterli görüldü.'}

## 6. Alınan önlemler
${incident.containedAtUtc != null ? 'Sınırlandırma tamamlandı: ${_isoDay(incident.containedAtUtc!)}' : 'Sınırlandırma sürmektedir.'}
''';
}

String _gdprTemplate({
  required BreachIncident incident,
  required BreachDeadlines deadlines,
  required String controllerName,
  required String dpoEmail,
}) {
  final categories = incident.dataCategories
      .map((c) => '- ${c.englishLabel}')
      .join('\n');
  return '''
# GDPR Art. 33 — Personal Data Breach Notification

**Controller**: $controllerName
**Data Protection Officer**: $dpoEmail
**Incident reference**: ${incident.id}

## 1. Nature of the breach
${incident.description}

## 2. Awareness timestamp (Art. 33(1))
UTC: ${_isoDay(incident.detectedAtUtc)}
72-hour notification deadline (UTC): ${_isoDay(deadlines.regulator72h)}

## 3. Categories and approximate number of data subjects concerned
${incident.affectedPatientCount} data subjects.

Categories:
$categories

## 4. Likely consequences
${incident.severity.requiresIndividualNotice ? 'High risk to the rights and freedoms of natural persons assessed (Art. 34(1)) — data subjects WILL be notified individually.' : 'No high risk to the rights and freedoms of natural persons; regulator notification only.'}

## 5. Measures taken
${incident.containedAtUtc != null ? 'Containment completed at ${_isoDay(incident.containedAtUtc!)}' : 'Containment in progress.'}
''';
}

String _hipaaTemplate({
  required BreachIncident incident,
  required BreachDeadlines deadlines,
  required String controllerName,
  required String dpoEmail,
}) {
  final categories = incident.dataCategories
      .map((c) => '- ${c.englishLabel}')
      .join('\n');
  return '''
# HIPAA Breach Notification — 45 CFR §164.408

**Covered Entity**: $controllerName
**Designated Privacy Official**: $dpoEmail
**Incident ID**: ${incident.id}

## Discovery date
UTC: ${_isoDay(incident.detectedAtUtc)}
HHS notification deadline (60 days): ${_isoDay(deadlines.hipaa60d)}

## Number of individuals affected
${incident.affectedPatientCount} ${incident.affectedPatientCount >= 500 ? '— MEDIA NOTIFICATION ALSO REQUIRED under §164.406' : '— under 500 threshold; annual HHS log entry, no media notice.'}

## Types of PHI involved
$categories

## Brief description
${incident.description}

## Safeguards in place + actions taken
${incident.containedAtUtc != null ? 'Containment completed at ${_isoDay(incident.containedAtUtc!)}.' : 'Containment in progress as of filing.'}
''';
}
