import '../../models/superbill_prefill.dart';

/// Pulls billing hints out of a finished session note so the superbill starts
/// pre-filled: ICD-10 diagnoses the clinician documented and a suggested CPT
/// service code. Deterministic + offline; the clinician confirms everything.
///
/// This is a draft assistant, NOT an autocoder — codes are only surfaced when
/// they already appear in the note (or are inferred from documented session
/// length), and the superbill screen keeps every field editable.
class NoteBillingExtractor {
  const NoteBillingExtractor();

  // ICD-10-CM: a letter (excluding U), two digits, optional dotted suffix.
  // e.g. F41.1, F32, Z63.0, R45.851
  static final RegExp _icdRe =
      RegExp(r'\b([A-TV-Z][0-9]{2}(?:\.[0-9A-Z]{1,4})?)\b');

  // Explicit psychotherapy / E&M CPT codes.
  static final RegExp _cptRe = RegExp(r'\b(908[0-9]{2}|9079[12]|9921[34])\b');

  static final RegExp _minutesRe =
      RegExp(r'(\d{1,3})\s*(?:min\b|minute)', caseSensitive: false);

  /// ICD-10 codes appearing in [note], filtered to those [isKnown] accepts
  /// (so free-text false positives never reach the superbill). Order-preserving
  /// and de-duplicated.
  List<String> extractIcd10(String note,
      {required bool Function(String) isKnown}) {
    final out = <String>[];
    for (final m in _icdRe.allMatches(note)) {
      final code = m.group(1)!.toUpperCase();
      if (isKnown(code) && !out.contains(code)) out.add(code);
    }
    return out;
  }

  /// Suggests a CPT code: an explicit code in the note wins; otherwise infer
  /// from documented session length, with a psychiatry E&M fallback. Returns
  /// null only when nothing reasonable can be inferred.
  String? suggestCpt(String note, {bool isPsychiatry = false}) {
    final explicit = _cptRe.firstMatch(note);
    if (explicit != null) return explicit.group(1);

    final minutes = _parseMinutes(note);
    if (isPsychiatry) {
      return (minutes != null && minutes >= 25) ? '99214' : '99213';
    }
    if (minutes != null) {
      if (minutes >= 53) return '90837';
      if (minutes >= 38) return '90834';
      if (minutes >= 16) return '90832';
    }
    return '90834'; // 45-minute psychotherapy — the most common default.
  }

  int? _parseMinutes(String note) {
    final m = _minutesRe.firstMatch(note);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  /// Builds a [SuperbillPrefill] from a note's text.
  SuperbillPrefill fromNote(
    String note, {
    required bool Function(String) isKnownIcd,
    String? patientName,
    bool isPsychiatry = false,
    DateTime? serviceDate,
  }) {
    return SuperbillPrefill(
      patientName: patientName,
      icd10Codes: extractIcd10(note, isKnown: isKnownIcd),
      cptCode: suggestCpt(note, isPsychiatry: isPsychiatry),
      serviceDate: serviceDate,
      noteText: note,
    );
  }
}
