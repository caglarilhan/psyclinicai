import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_storage.dart';

/// Post-session "AI supervisor" — turns a session transcript into reflective
/// feedback for the clinician (therapeutic alliance, interventions observed,
/// themes, and concrete suggestions). Inspired by the supervision-style
/// feedback clinicians value most in AI scribes.
///
/// **Decision-support / reflective tool — not a performance evaluation and not
/// a substitute for clinical supervision.** BYOK Claude; mirrors the
/// HTTP/auth pattern of the other co-pilot services.
class SessionInsightsService {
  SessionInsightsService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// Analyze [transcript]. Throws [SessionInsightsException] (with [noKey] set
  /// for the no-key case) so the UI can prompt; never an opaque crash.
  Future<SessionInsights> analyze(String transcript) async {
    final text = transcript.trim();
    if (text.length < 40) {
      throw const SessionInsightsException(
          'Not enough session content to analyze yet.');
    }

    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const SessionInsightsException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    const system =
        'You are a warm, constructive clinical supervisor reviewing a therapy '
        'session transcript. Give brief, specific, supportive reflective '
        'feedback — never a score or a verdict on competence. Note what worked '
        'and gentle growth edges. Respond STRICT JSON only: {"alliance":"one '
        'sentence on the therapeutic alliance/rapport observed","interventions"'
        ':["techniques you observed"],"themes":["client themes raised"],'
        '"strengths":["what the clinician did well"],"suggestions":["concrete, '
        'kind next-time ideas"],"homework":["between-session ideas to consider"]}';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 900,
      'temperature': 0.4,
      'system': system,
      'messages': [
        {'role': 'user', 'content': text}
      ],
    });

    http.Response resp;
    try {
      resp = await _client
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
          .timeout(const Duration(seconds: 40));
    } catch (e) {
      throw SessionInsightsException('Network error reaching Anthropic. $e');
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw const SessionInsightsException(
          'Anthropic rejected the API key. Verify it in Settings → API Keys.');
    }
    if (resp.statusCode != 200) {
      throw SessionInsightsException(
          'Anthropic error ${resp.statusCode}. Try again shortly.');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = (decoded['content'] as List<dynamic>? ?? const [])
        .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
        .join('\n')
        .trim();

    final insights = _parse(content);
    if (insights == null) {
      throw const SessionInsightsException(
          'Could not parse insights from the AI response. Try again.');
    }
    return insights;
  }

  SessionInsights? _parse(String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final json =
          jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      List<String> list(String k) => (json[k] as List<dynamic>? ?? const [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
      return SessionInsights(
        alliance: (json['alliance'] as String?)?.trim() ?? '',
        interventions: list('interventions'),
        themes: list('themes'),
        strengths: list('strengths'),
        suggestions: list('suggestions'),
        homework: list('homework'),
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

class SessionInsights {
  SessionInsights({
    required this.alliance,
    required this.interventions,
    required this.themes,
    required this.strengths,
    required this.suggestions,
    required this.homework,
  });

  final String alliance;
  final List<String> interventions;
  final List<String> themes;
  final List<String> strengths;
  final List<String> suggestions;
  final List<String> homework;
}

class SessionInsightsException implements Exception {
  const SessionInsightsException(this.message, {this.noKey = false});
  final String message;
  final bool noKey;

  @override
  String toString() => 'SessionInsightsException: $message';
}
