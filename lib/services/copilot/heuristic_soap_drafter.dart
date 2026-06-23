/// Pure heuristic transcript -> SOAP/DAP/BIRP draft. Complements
/// the LLM-backed `SoapGeneratorService` — when the clinician has
/// no API key configured, this still produces a usable starter
/// draft the clinician can edit. Same `SoapNote` envelope so the
/// session screen does not branch on which path produced the
/// draft.
///
/// Extraction rules:
///   - Subjective: sentences led by "I feel / I noticed / I
///     thought / lately / recently". Patient-voice clauses.
///   - Objective: clinician-voice observations (sentence starts
///     with "patient" / "client") plus explicit hh:mm times.
///   - Assessment: thematic tagging — depression / anxiety /
///     sleep / suicide-risk / substance — keyword-driven.
///   - Plan: action verbs (homework, scheduled, refer, next
///     session, call).
library;

import 'soap_generator_service.dart';

class HeuristicSoapDrafter {
  const HeuristicSoapDrafter();

  /// Returns a SOAP draft. When the transcript is empty the
  /// markdown reads "No transcript content provided." so the
  /// clinician sees a clean shell rather than a wrong-looking card.
  SoapNote draft({
    required String transcript,
    SoapFormat format = SoapFormat.soap,
  }) {
    if (transcript.trim().isEmpty) {
      return SoapNote(
        rawMarkdown: _empty(format),
        format: format,
        generatedAt: DateTime.now().toUtc(),
      );
    }

    final sentences = _splitSentences(transcript);
    final s = _extractSubjective(sentences);
    final o = _extractObjective(sentences);
    final a = _extractAssessmentThemes(sentences);
    final p = _extractPlan(sentences);

    final flaggedRisk = a.contains('suicide-risk');
    final markdown = _render(format: format, s: s, o: o, a: a, p: p);
    return SoapNote(
      rawMarkdown: markdown,
      format: format,
      generatedAt: DateTime.now().toUtc(),
      flaggedRisk: flaggedRisk,
    );
  }

  /// Sub-extractors — exposed so tests can pin each rule without
  /// re-rendering the whole markdown.
  List<String> extractSubjective(String transcript) =>
      _extractSubjective(_splitSentences(transcript));

  List<String> extractObjective(String transcript) =>
      _extractObjective(_splitSentences(transcript));

  List<String> extractAssessmentThemes(String transcript) =>
      _extractAssessmentThemes(_splitSentences(transcript));

  List<String> extractPlan(String transcript) =>
      _extractPlan(_splitSentences(transcript));

  List<String> _splitSentences(String text) {
    return text
        .replaceAll('\r', ' ')
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static final _subjectiveLead = RegExp(
    r"^(i\s|my\s|me\s|it has been|it's been|its been|lately|recently)",
    caseSensitive: false,
  );

  List<String> _extractSubjective(List<String> sentences) =>
      sentences.where(_subjectiveLead.hasMatch).toList();

  static final _objectiveLead = RegExp(
    r'^(patient|client|pt|the patient|the client)\b',
    caseSensitive: false,
  );
  static final _timeRegex = RegExp(r'\b\d{1,2}:\d{2}\b');

  List<String> _extractObjective(List<String> sentences) {
    final out = <String>[];
    for (final s in sentences) {
      if (_objectiveLead.hasMatch(s) || _timeRegex.hasMatch(s)) {
        out.add(s);
      }
    }
    return out;
  }

  static const _themeKeywords = <String, List<String>>{
    'depression': [
      'hopeless',
      'depressed',
      'low mood',
      'anhedonia',
      'crying',
      'worthless',
    ],
    'anxiety': [
      'anxious',
      'worry',
      'worried',
      'panic',
      'rumination',
      'on edge',
    ],
    'sleep': ['insomnia', 'sleep', 'nightmare', 'cannot sleep', "can't sleep"],
    'suicide-risk': [
      'suicid',
      'kill myself',
      'end my life',
      'not worth living',
      'self-harm',
      'self harm',
    ],
    'substance': [
      'alcohol',
      'drinking',
      'drank',
      'using',
      'relapse',
      'cravings',
    ],
    'sleep-meds-side-effect': ['drowsy', 'sedated', 'fatigue'],
  };

  List<String> _extractAssessmentThemes(List<String> sentences) {
    final hay = sentences.join(' ').toLowerCase();
    final themes = <String>[];
    for (final entry in _themeKeywords.entries) {
      if (entry.value.any(hay.contains)) themes.add(entry.key);
    }
    return themes;
  }

  static final _planLead = RegExp(
    r'\b(homework|scheduled|refer|next session|call|follow[- ]?up|will\s)',
    caseSensitive: false,
  );

  List<String> _extractPlan(List<String> sentences) =>
      sentences.where(_planLead.hasMatch).toList();

  String _render({
    required SoapFormat format,
    required List<String> s,
    required List<String> o,
    required List<String> a,
    required List<String> p,
  }) {
    String join(List<String> xs) => xs.isEmpty
        ? '_(none extracted; clinician to fill)_'
        : xs.map((x) => '- $x').join('\n');
    final assessmentBlock = a.isEmpty
        ? '_(no themes detected; clinician to fill)_'
        : 'Themes detected:\n${a.map((t) => '- $t').join('\n')}';

    switch (format) {
      case SoapFormat.soap:
        return 'S — Subjective\n${join(s)}\n\n'
            'O — Objective\n${join(o)}\n\n'
            'A — Assessment\n$assessmentBlock\n\n'
            'P — Plan\n${join(p)}';
      case SoapFormat.dap:
        return 'D — Data\n${join([...s, ...o])}\n\n'
            'A — Assessment\n$assessmentBlock\n\n'
            'P — Plan\n${join(p)}';
      case SoapFormat.birp:
        return 'B — Behaviour\n${join(o)}\n\n'
            'I — Intervention\n${join(p)}\n\n'
            'R — Response\n${join(s)}\n\n'
            'P — Plan\n${join(p)}';
      case SoapFormat.girp:
        return 'G — Goal\n${join([])}\n\n'
            'I — Intervention\n${join(p)}\n\n'
            'R — Response\n${join(s)}\n\n'
            'P — Plan\n${join(p)}';
      case SoapFormat.psychiatry:
        return 'Subjective\n${join(s)}\n\n'
            'Mental status / objective\n${join(o)}\n\n'
            'Assessment\n$assessmentBlock\n\n'
            'Plan\n${join(p)}';
    }
  }

  String _empty(SoapFormat format) =>
      'No transcript content provided.\n\n_Heuristic draft skipped — '
      'paste the session transcript to populate the ${format.name} note._';
}
