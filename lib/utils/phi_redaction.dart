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
  PhiRedactor({
    this.patientNames = const [],
    this.dateShift,
  });

  final List<String> patientNames;

  /// M-6 fix (audit 2026-06-21): the previous implementation replaced
  /// every detected date with a literal `[DATE]` token, which dropped
  /// the temporal context the model needs for DSM-5 duration criteria
  /// (e.g. ">=2 weeks for MDD"). HIPAA §164.514(e) Limited Dataset
  /// permits a deterministic date *shift* — relative offsets between
  /// dates stay intact, absolute calendars cannot be re-identified.
  ///
  /// When [dateShift] is null (default), we still tokenise dates as
  /// before so the redactor is safe for callers that need full Safe
  /// Harbor de-id. When set (typically a small positive int days),
  /// each matched date is shifted by that many days. ISO + US + DE
  /// formats supported.
  final Duration? dateShift;

  static final _phoneE164 = RegExp(r'\+\d{8,15}\b');
  // Two alternations: parens-style (no leading \b) + dash-style with \b.
  // Dart RegExp lookbehind support is unreliable on \b — split instead.
  static final _phoneUs =
      RegExp(r'(?:\(\d{3}\)\s*\d{3}[-.\s]?\d{4}|\b\d{3}[-.\s]\d{3}[-.\s]?\d{4})\b');
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
  static final _ipV4 = RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b');
  // US NPI is a 10-digit Luhn-validated id. M-9 fix
  // (audit 2026-06-21): we now Luhn-check candidate matches so a
  // 10-digit number that happens to appear in clinical free text
  // (member id, study code, fax number) doesn't get masked as NPI.
  // False negatives are still preferred over PHI egress — but
  // false positives that destroy clinical text are now avoided.
  static final _npiCandidate = RegExp(r'\b(?:NPI\s*[:#-]?\s*)?(\d{10})\b',
      caseSensitive: false);

  PhiScrubResult scrub(String input) {
    final removed = <String, int>{};
    var text = input;

    text = _replace(text, _email, '[EMAIL]', removed, 'email');
    text = _replace(text, _phoneE164, '[PHONE]', removed, 'phone_e164');
    text = _replace(text, _phoneUs, '[PHONE]', removed, 'phone_us');
    text = _replace(text, _ssn, '[SSN]', removed, 'ssn');
    text = _replace(text, _kvnr, '[KVNR]', removed, 'kvnr');
    text = _replace(text, _mrn, '[MRN]', removed, 'mrn');
    text = _replaceNpi(text, removed);
    text = _replaceDate(text, _dateIso, removed, 'date_iso', _shiftIso);
    text = _replaceDate(text, _dateUs, removed, 'date_us', _shiftUs);
    text = _replaceDate(text, _dateDe, removed, 'date_de', _shiftDe);
    text = _replace(text, _ipV4, '[IP]', removed, 'ip_v4');

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

  String _replaceNpi(String text, Map<String, int> counts) {
    return text.replaceAllMapped(_npiCandidate, (m) {
      final candidate = m.group(1)!;
      if (!_luhnValid(candidate)) return m.group(0)!; // not an NPI
      counts['npi'] = (counts['npi'] ?? 0) + 1;
      return '[NPI]';
    });
  }

  /// Luhn check for US NPI (10-digit identifier with a prefix `80840`
  /// added before the checksum is computed, per NPPES spec). The
  /// right-most digit is the check digit (not doubled); every
  /// SECOND digit moving left from there gets doubled.
  static bool _luhnValid(String digits) {
    if (digits.length != 10) return false;
    final prefixed = '80840$digits';
    var sum = 0;
    var alt = false; // right-most digit is the check digit (not doubled)
    for (var i = prefixed.length - 1; i >= 0; i--) {
      var d = prefixed.codeUnitAt(i) - 48;
      if (d < 0 || d > 9) return false;
      if (alt) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  String _replaceDate(
    String text,
    RegExp p,
    Map<String, int> counts,
    String label,
    String Function(Match) shifter,
  ) {
    return text.replaceAllMapped(p, (m) {
      counts[label] = (counts[label] ?? 0) + 1;
      if (dateShift == null) return '[DATE]';
      try {
        return shifter(m);
      } catch (_) {
        return '[DATE]';
      }
    });
  }

  String _shiftIso(Match m) {
    final parsed = DateTime.parse(m.group(0)!);
    final shifted = parsed.add(dateShift!);
    final y = shifted.year.toString().padLeft(4, '0');
    final mo = shifted.month.toString().padLeft(2, '0');
    final d = shifted.day.toString().padLeft(2, '0');
    return '$y-$mo-$d';
  }

  String _shiftUs(Match m) {
    final parts = m.group(0)!.split('/');
    final mo = int.parse(parts[0]);
    final d = int.parse(parts[1]);
    final y = int.parse(parts[2]);
    final shifted = DateTime.utc(y, mo, d).add(dateShift!);
    return '${shifted.month}/${shifted.day}/${shifted.year}';
  }

  String _shiftDe(Match m) {
    final parts = m.group(0)!.split('.');
    final d = int.parse(parts[0]);
    final mo = int.parse(parts[1]);
    final y = int.parse(parts[2]);
    final shifted = DateTime.utc(y, mo, d).add(dateShift!);
    return '${shifted.day}.${shifted.month}.${shifted.year}';
  }
}
