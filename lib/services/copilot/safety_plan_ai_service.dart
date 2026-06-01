import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/safety_plan.dart';
import '../compliance/consent_guard.dart';
import 'api_key_storage.dart';

/// AI-drafts a Stanley-Brown crisis safety plan (BYOK Claude) the clinician
/// reviews and completes WITH the client. Decision-support scaffold — not a
/// substitute for clinical risk assessment; the clinician owns the plan.
class SafetyPlanAiService {
  SafetyPlanAiService({
    ApiKeyStorage? keyStorage,
    http.Client? client,
    ConsentGuard? consentGuard,
  })  : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client(),
        // Default to a fail-closed guard — production callers MUST inject
        // an IntakeRepository-backed lookup before invoking [draft].
        _guard = consentGuard ?? ConsentGuard();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;
  final ConsentGuard _guard;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// Drafts a [SafetyPlan] for [patientId] from a short [context] (e.g. flagged
  /// risk language or presenting concern). Throws [SafetyPlanAiException]
  /// (noKey set) when no key.
  Future<SafetyPlan> draft({
    required String patientId,
    required String context,
    String region = 'US',
  }) async {
    // GDPR Art. 7 / Art. 9(2)(a) gate. Throws [ConsentDeniedException]
    // when the patient has not granted AI-assistance consent; callers
    // surface that as a UI banner with a link to the consent screen.
    _guard.requireAi(patientId);
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const SafetyPlanAiException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    final crisisHint = region == 'EU'
        ? 'Use generic EU crisis-line placeholders (e.g. 112 emergency, '
              'national crisis line) — do not invent specific numbers.'
        : 'Include US 988 Suicide & Crisis Lifeline and 911 for emergencies.';

    final system =
        'You are a clinician drafting a Stanley-Brown crisis Safety Plan to '
        'complete collaboratively WITH the client. Produce concrete, '
        'client-voice starter items per section the clinician will edit. '
        '$crisisHint Decision-support — not a risk assessment. Respond STRICT '
        'JSON only: {"warningSigns":[],"copingStrategies":[],'
        '"socialDistractions":[],"supportContacts":[],"professionals":[],'
        '"crisisLines":[],"meansSafety":"one sentence on making the '
        'environment safer"}';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 800,
      'temperature': 0.4,
      'system': system,
      'messages': [
        {'role': 'user', 'content': 'Context: $context'},
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
          .timeout(const Duration(seconds: 40));
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw const SafetyPlanAiException(
          'Anthropic rejected the API key. Verify it in Settings → API Keys.',
        );
      }
      if (resp.statusCode != 200) {
        throw SafetyPlanAiException(
          'Anthropic error ${resp.statusCode}. Try again shortly.',
        );
      }
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      final plan = _parse(patientId, content);
      if (plan == null) {
        throw const SafetyPlanAiException(
          'Could not parse the safety plan. Try again.',
        );
      }
      return plan;
    } on SafetyPlanAiException {
      rethrow;
    } catch (e) {
      throw SafetyPlanAiException('Network error reaching Anthropic. $e');
    }
  }

  SafetyPlan? _parse(String patientId, String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final j =
          jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      List<String> l(String k) => (j[k] as List<dynamic>? ?? const [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return SafetyPlan(
        patientId: patientId,
        warningSigns: l('warningSigns'),
        copingStrategies: l('copingStrategies'),
        socialDistractions: l('socialDistractions'),
        supportContacts: l('supportContacts'),
        professionals: l('professionals'),
        crisisLines: l('crisisLines'),
        meansSafety: (j['meansSafety'] as String?)?.trim() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}

class SafetyPlanAiException implements Exception {
  const SafetyPlanAiException(this.message, {this.noKey = false});
  final String message;
  final bool noKey;

  @override
  String toString() => 'SafetyPlanAiException: $message';
}
