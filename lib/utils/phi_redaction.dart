/// Pre-LLM PHI scrub — minimum-necessary under HIPAA §164.502(b) and
/// GDPR Art. 5(1)(c). Not a guarantee; the full Presidio-style
/// detector lives behind the LLM proxy (Sprint 19 backend). Use this
/// helper as the baseline safety net on the device before egress.
library;

class PhiScrubResult {
  const PhiScrubResult({
    required this.cleanText,
    required this.removed,
  });

  final String cleanText;
  final Map<String, int> removed;

  int get totalRemoved => removed.values.fold(0, (a, b) => a + b);
}

class PhiRedactor {
  PhiRedactor({this.patientNames = const []});

  final List<String> patientNames;

  static final _phoneE164 = RegExp(r'\+\d{8,15}\b');
  static final _phoneUs = RegExp(
      r'(?:\(\d{3}\)\s*|(?<=\b)\d{3}[-.\s])\d{3}[-.\s]?\d{4}\b');
  static final _email =
      RegExp(r'\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b');
  static final _dateIso = RegExp(r'\b(19|20)\d{2}-\d{2}-\d{2}\b');
  static final _dateUs = RegExp(r'\b\d{1,2}/\d{1,2}/(19|20)\d{2}\b');
  static final _dateDe = RegExp(r'\b\d{1,2}\.\d{1,2}\.(19|20)\d{2}\b');
  static final _mrn =
      RegExp(r'\b(?:MRN|Patient\s*#|Member\s*ID)[:\s-]*[A-Z0-9-]{3,}\b',
          caseSensitive: false);
  static final _ssn = RegExp(r'\b\d{3}-\d{2}-\d{4}\b');
  static final _kvnr = RegExp(r'\b[A-Z]\d{9}\b');

  PhiScrubResult scrub(String input) {
    final removed = <String, int>{};
    var text = input;

    text = _replace(text, _email, '[EMAIL]', removed, 'email');
    text = _replace(text, _phoneE164, '[PHONE]', removed, 'phone_e164');
    text = _replace(text, _phoneUs, '[PHONE]', removed, 'phone_us');
    text = _replace(text, _ssn, '[SSN]', removed, 'ssn');
    text = _replace(text, _kvnr, '[KVNR]', removed, 'kvnr');
    text = _replace(text, _mrn, '[MRN]', removed, 'mrn');
    text = _replace(text, _dateIso, '[DATE]', removed, 'date_iso');
    text = _replace(text, _dateUs, '[DATE]', removed, 'date_us');
    text = _replace(text, _dateDe, '[DATE]', removed, 'date_de');

    for (final name in patientNames) {
      final n = name.trim();
      if (n.isEmpty) continue;
      final escaped = RegExp.escape(n);
      final pattern = RegExp('\\b$escaped\\b', caseSensitive: false);
      text = _replace(text, pattern, '[NAME]', removed, 'name');
    }

    return PhiScrubResult(cleanText: text, removed: removed);
  }

  String _replace(
    String text,
    Pattern p,
    String token,
    Map<String, int> counts,
    String label,
  ) {
    final matches = p.allMatches(text).length;
    if (matches == 0) return text;
    counts[label] = (counts[label] ?? 0) + matches;
    return text.replaceAll(p, token);
  }
}
