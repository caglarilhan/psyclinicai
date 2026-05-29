import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/supervision_report.dart';
import '../data/telemetry_service.dart';
import 'api_key_storage.dart';
import 'prompt_safety.dart';
import 'soap_generator_service.dart' show Modality, ModalityX;

/// Produces a de-identified supervision report from a session: fidelity to the
/// chosen modality + strengths, growth areas, and reflective questions for a
/// trainee. The academic / clinical-supervision wedge.
///
/// SAFETY: the report is meant to be shared with a supervisor, so the prompt
/// strips all client-identifying information (names, dates, locations,
/// identifiers). Decision-support for supervision — not a competency or
/// licensure determination. BYOK Claude (mirrors the SOAP generator pattern).
class SupervisionService {
  SupervisionService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// Generates the supervision report for [modality] from [transcript].
  /// Throws [SupervisionException] (noKey set) when no key is configured.
  Future<SupervisionReport> generate({
    required String transcript,
    required Modality modality,
  }) async {
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const SupervisionException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    final system =
        'You are a clinical supervisor reviewing a session for trainee '
        'development in the ${modality.label} modality. FIRST de-identify: '
        'never repeat names, dates, locations, or any identifier — refer only '
        'to "the client" and "the therapist". Then: score adherence to the '
        '${modality.label} evidence-based method (0-100) with one sentence of '
        'fidelity notes; list the therapist\'s strengths, growth areas, and '
        'reflective questions for supervision. Ground everything in the '
        'transcript; do not invent. Decision-support for supervision — not a '
        'competency or licensure determination. Respond STRICT JSON only: '
        '{"fidelityScore":0-100,"fidelityNotes":"...","strengths":["..."],'
        '"growthAreas":["..."],"reflectiveQuestions":["..."],'
        '"summary":"<=25 words, de-identified"}. '
        '${PromptSafety.dataOnlyDirective}';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 900,
      'temperature': 0.3,
      'system': system,
      'messages': [
        {'role': 'user', 'content': PromptSafety.fence('transcript', transcript)}
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
          .timeout(const Duration(seconds: 45));
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw const SupervisionException(
            'Anthropic rejected the API key. Verify it in Settings → API Keys.');
      }
      if (resp.statusCode != 200) {
        throw SupervisionException(
            'Anthropic error ${resp.statusCode}. Try again shortly.');
      }
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      final report = parse(content, modality);
      if (report == null) {
        throw const SupervisionException(
            'Could not parse the supervision report. Try again.');
      }
      return report;
    } on SupervisionException {
      rethrow;
    } catch (e) {
      throw SupervisionException('Network error reaching Anthropic. $e');
    }
  }

  /// Parses the model's JSON into a [SupervisionReport]. Pure + testable.
  SupervisionReport? parse(String content, Modality modality) {
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
      final scoreRaw = j['fidelityScore'];
      final score = scoreRaw is num
          ? scoreRaw.round().clamp(0, 100)
          : int.tryParse('$scoreRaw') ?? 0;
      final report = SupervisionReport(
        modalityLabel: modality.label,
        fidelityScore: score,
        fidelityNotes: (j['fidelityNotes'] as String?)?.trim() ?? '',
        strengths: l('strengths'),
        growthAreas: l('growthAreas'),
        reflectiveQuestions: l('reflectiveQuestions'),
        summary: (j['summary'] as String?)?.trim() ?? '',
      );
      final empty = report.strengths.isEmpty &&
          report.growthAreas.isEmpty &&
          report.reflectiveQuestions.isEmpty &&
          report.summary.isEmpty &&
          report.fidelityNotes.isEmpty;
      return empty ? null : report;
    } catch (e, st) {
      TelemetryService.instance.captureError(e, st, hint: 'supervision_parse');
      return null;
    }
  }

  void dispose() => _client.close();
}

class SupervisionException implements Exception {
  const SupervisionException(this.message, {this.noKey = false});
  final String message;
  final bool noKey;

  @override
  String toString() => 'SupervisionException: $message';
}
