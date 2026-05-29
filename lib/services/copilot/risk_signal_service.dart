import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/telemetry_service.dart';
import 'api_key_storage.dart';

/// Real-time clinical **risk-signal** detection over a live session transcript.
///
/// Decision-support only — surfaces risk *language* for the clinician to review.
/// It is NOT a diagnosis and does NOT take any autonomous action. Two tiers:
///
///  - [scanSegment] — Tier 1: deterministic, offline, free keyword/phrase
///    lexicon. Runs on every final transcript segment. Recall-biased by design
///    (better to surface for review than to miss); the clinician decides.
///  - [classifyWindow] — Tier 2: optional Anthropic Claude pass (BYOK) that
///    refines/adds nuanced signals. Returns `[]` when no key is configured or on
///    any network/parse error — it never throws into the UI.
class RiskSignalService {
  RiskSignalService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// Curated lexicon. Phrases are matched case-insensitively as substrings on a
  /// space-padded, punctuation-stripped form of the text. Kept deliberately
  /// small and reviewable; expand with clinical input.
  static const Map<RiskCategory, List<String>> _lexicon = {
    RiskCategory.suicidalIdeation: [
      'kill myself', 'end my life', 'take my own life', 'want to die',
      'better off dead', 'no reason to live', 'not worth living',
      'suicidal', 'suicide', 'ending it all',
    ],
    RiskCategory.selfHarm: [
      'cut myself', 'hurt myself', 'harm myself', 'harming myself',
      'self harm', 'burning myself', 'cutting again',
    ],
    RiskCategory.harmToOthers: [
      'kill him', 'kill her', 'kill them', 'hurt him', 'hurt her',
      'want to hurt', 'homicidal', 'make them pay',
    ],
    RiskCategory.substanceUse: [
      'overdose', 'using again', 'relapsed', 'relapse', 'drinking too much',
      'cant stop drinking', 'high every day', 'pills to cope', 'blackout',
    ],
    RiskCategory.hopelessness: [
      'hopeless', 'no way out', 'nothing matters', 'cant go on',
      'give up on everything', 'trapped', 'no future',
    ],
  };

  /// High-severity categories — explicit intent toward self/others.
  static const Set<RiskCategory> _highSeverity = {
    RiskCategory.suicidalIdeation,
    RiskCategory.selfHarm,
    RiskCategory.harmToOthers,
  };

  /// Tier 1 — scan a final transcript segment. Pure & synchronous.
  List<RiskSignal> scanSegment(String segment) {
    final normalized =
        ' ${segment.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ')} ';
    final out = <RiskSignal>[];
    for (final entry in _lexicon.entries) {
      for (final phrase in entry.value) {
        if (normalized.contains(' $phrase ')) {
          out.add(RiskSignal(
            category: entry.key,
            severity: _highSeverity.contains(entry.key)
                ? RiskSeverity.high
                : RiskSeverity.elevated,
            matchedText: phrase,
            snippet: _snippet(segment, phrase),
            source: RiskSource.lexicon,
            at: DateTime.now(),
          ));
          break; // one signal per category per segment
        }
      }
    }
    return out;
  }

  static String _snippet(String text, String phrase) {
    final t = text.trim();
    if (t.length <= 90) return t;
    final i = t.toLowerCase().indexOf(phrase.toLowerCase());
    if (i < 0) return '${t.substring(0, 87)}…';
    final start = (i - 30).clamp(0, t.length);
    final end = (i + phrase.length + 30).clamp(0, t.length);
    return '${start > 0 ? '…' : ''}${t.substring(start, end)}${end < t.length ? '…' : ''}';
  }

  /// Tier 2 — optional Claude refinement over the recent transcript window.
  /// Never throws; returns `[]` when no key / on any error.
  Future<List<RiskSignal>> classifyWindow(String transcript) async {
    final text = transcript.trim();
    if (text.length < 12) return const [];
    String? key;
    try {
      key = await _keyStorage.getAnthropicKey();
    } catch (_) {
      return const [];
    }
    if (key == null || key.isEmpty) return const [];

    const system =
        'You are a clinical safety assistant supporting a licensed therapist '
        'during a live session. Identify ONLY explicit risk language in the '
        'transcript across these categories: suicidal_ideation, self_harm, '
        'harm_to_others, substance_use, hopelessness. This is decision-support '
        'for a clinician, never a diagnosis. Respond with STRICT JSON only: '
        '{"signals":[{"category":"...","severity":"high|elevated|info",'
        '"quote":"<=12 words from the transcript"}]}. Empty list if none.';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 400,
      'temperature': 0.0,
      'system': system,
      'messages': [
        {'role': 'user', 'content': text}
      ],
    });

    try {
      final resp = await _client
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': key,
              'anthropic-version': _anthropicVersion,
              'anthropic-dangerous-direct-browser-access': 'true',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        // Keep the no-throw contract, but record degradation so we can tell
        // when the AI risk layer is silently running on Tier-1 lexicon only.
        await TelemetryService.instance.captureError(
          StateError('risk classifyWindow HTTP ${resp.statusCode}'),
          StackTrace.current,
          hint: 'risk_classify_http',
        );
        return const [];
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      return _parseAiSignals(content);
    } catch (e, st) {
      await TelemetryService.instance
          .captureError(e, st, hint: 'risk_classify');
      return const [];
    }
  }

  List<RiskSignal> _parseAiSignals(String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return const [];
      final json = jsonDecode(content.substring(start, end + 1))
          as Map<String, dynamic>;
      final list = json['signals'] as List<dynamic>? ?? const [];
      return list
          .map((e) => e as Map<String, dynamic>)
          .map((m) => RiskSignal(
                category: _categoryFrom(m['category'] as String? ?? ''),
                severity: _severityFrom(m['severity'] as String? ?? ''),
                matchedText: (m['quote'] as String? ?? '').trim(),
                snippet: (m['quote'] as String? ?? '').trim(),
                source: RiskSource.ai,
                at: DateTime.now(),
              ))
          .where((s) => s.matchedText.isNotEmpty)
          .toList(growable: false);
    } catch (e, st) {
      // Malformed AI JSON — Tier-1 lexicon still ran, but log so prompt/format
      // drift is detectable rather than silently dropping AI signals.
      TelemetryService.instance.captureError(e, st, hint: 'risk_parse');
      return const [];
    }
  }

  static RiskCategory _categoryFrom(String s) => switch (s.trim()) {
        'suicidal_ideation' => RiskCategory.suicidalIdeation,
        'self_harm' => RiskCategory.selfHarm,
        'harm_to_others' => RiskCategory.harmToOthers,
        'substance_use' => RiskCategory.substanceUse,
        _ => RiskCategory.hopelessness,
      };

  static RiskSeverity _severityFrom(String s) => switch (s.trim()) {
        'high' => RiskSeverity.high,
        'info' => RiskSeverity.info,
        _ => RiskSeverity.elevated,
      };

  void dispose() => _client.close();
}

enum RiskSeverity { info, elevated, high }

enum RiskCategory {
  suicidalIdeation,
  selfHarm,
  harmToOthers,
  substanceUse,
  hopelessness,
}

enum RiskSource { lexicon, ai }

extension RiskCategoryX on RiskCategory {
  String get label => switch (this) {
        RiskCategory.suicidalIdeation => 'Suicidal ideation',
        RiskCategory.selfHarm => 'Self-harm',
        RiskCategory.harmToOthers => 'Harm to others',
        RiskCategory.substanceUse => 'Substance use',
        RiskCategory.hopelessness => 'Hopelessness',
      };
}

extension RiskSeverityX on RiskSeverity {
  String get label => switch (this) {
        RiskSeverity.high => 'High',
        RiskSeverity.elevated => 'Elevated',
        RiskSeverity.info => 'Info',
      };
}

/// A single surfaced risk signal. [matchedText] is the trigger; [snippet] is a
/// short context excerpt for the clinician.
class RiskSignal {
  RiskSignal({
    required this.category,
    required this.severity,
    required this.matchedText,
    required this.snippet,
    required this.source,
    required this.at,
  });

  final RiskCategory category;
  final RiskSeverity severity;
  final String matchedText;
  final String snippet;
  final RiskSource source;
  final DateTime at;

  /// Identity for de-duplication across segments.
  String get dedupKey => '${category.name}|${matchedText.toLowerCase()}';
}
