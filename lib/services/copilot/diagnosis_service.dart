import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_storage.dart';

/// Real DSM-5 differential generator. Given a free-text clinical
/// vignette + selected symptoms, returns up to 3 candidate diagnoses
/// with confidence, supporting / missing criteria, and the next steps
/// the clinician should take to confirm or rule out.
///
/// We do NOT return a single diagnosis — the clinician owns it.
class DiagnosisService {
  DiagnosisService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  static const String _systemPrompt = '''
You are a DSM-5 differential-diagnosis assistant for licensed mental
health clinicians. The clinician owns the final diagnosis.

Given a clinical vignette (chief complaint, observations, selected
symptoms), return up to 3 candidate DSM-5 diagnoses ranked by clinical
likelihood. For each: ICD-10 + DSM-5 code, confidence (low/medium/
high), the matching criteria you see in the vignette, the criteria
still missing or worth confirming, and 1-3 differential-tightening
next steps the clinician should take.

Always include at least one differential to rule out (not just the
top candidate). Cite DSM-5 sections (e.g. "Criterion A.3") when you
reference symptoms.

Return strictly JSON in this shape, no prose:
{
  "candidates": [
    {
      "name": "Major Depressive Disorder, single episode, moderate",
      "icd10": "F32.1",
      "dsm5": "296.22",
      "confidence": "high",
      "matchingCriteria": ["Depressed mood (Criterion A.1)", "..."],
      "missingCriteria": ["Duration unclear — confirm symptoms >= 2 weeks"],
      "nextSteps": ["Administer PHQ-9 to quantify severity", "..."]
    }
  ]
}
''';

  Future<List<DxCandidate>> suggest({
    required String vignette,
    required List<String> selectedSymptoms,
  }) async {
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const DiagnosisException(
        DiagnosisErrorCode.noApiKey,
        'No Anthropic API key configured. Add one under Settings → API keys.',
      );
    }

    final userPrompt = StringBuffer()
      ..writeln('Clinical vignette:')
      ..writeln(vignette.trim().isEmpty
          ? '(none provided)'
          : vignette.trim())
      ..writeln()
      ..writeln('Selected symptoms:')
      ..writeln(selectedSymptoms.isEmpty
          ? '(none)'
          : selectedSymptoms.map((s) => '- $s').join('\n'))
      ..writeln()
      ..writeln('Return JSON only.');

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 1200,
      'temperature': 0.2,
      'system': _systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt.toString()}
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
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw DiagnosisException(
        DiagnosisErrorCode.network,
        'Network error reaching Anthropic. $e',
      );
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw const DiagnosisException(
        DiagnosisErrorCode.unauthorized,
        'Anthropic rejected the API key.',
      );
    }
    if (resp.statusCode == 429) {
      throw const DiagnosisException(
        DiagnosisErrorCode.rateLimit,
        'Rate limit hit. Wait a moment and retry.',
      );
    }
    if (resp.statusCode != 200) {
      throw DiagnosisException(
        DiagnosisErrorCode.unknown,
        'Anthropic returned ${resp.statusCode}: ${resp.body}',
      );
    }

    final outer = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = (outer['content'] as List<dynamic>?) ?? const [];
    if (content.isEmpty) {
      throw const DiagnosisException(
        DiagnosisErrorCode.parse,
        'Anthropic returned an empty response.',
      );
    }
    final text =
        (content.first as Map<String, dynamic>)['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw const DiagnosisException(
        DiagnosisErrorCode.parse,
        'Anthropic response had no text content.',
      );
    }

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end < 0 || end <= start) {
      throw DiagnosisException(
        DiagnosisErrorCode.parse,
        'Could not find JSON in model output:\n$text',
      );
    }
    final jsonStr = text.substring(start, end + 1);
    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      throw DiagnosisException(
        DiagnosisErrorCode.parse,
        'Could not parse JSON: $e\n$jsonStr',
      );
    }
    final list = (parsed['candidates'] as List<dynamic>?) ?? const [];
    return list
        .map((e) => DxCandidate.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  void dispose() => _client.close();
}

class DxCandidate {
  DxCandidate({
    required this.name,
    required this.icd10,
    required this.dsm5,
    required this.confidence,
    required this.matchingCriteria,
    required this.missingCriteria,
    required this.nextSteps,
  });

  factory DxCandidate.fromJson(Map<String, dynamic> j) => DxCandidate(
        name: j['name'] as String? ?? '',
        icd10: j['icd10'] as String? ?? '',
        dsm5: j['dsm5'] as String? ?? '',
        confidence: j['confidence'] as String? ?? 'medium',
        matchingCriteria:
            ((j['matchingCriteria'] as List<dynamic>?) ?? [])
                .map((e) => e.toString())
                .toList(),
        missingCriteria: ((j['missingCriteria'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList(),
        nextSteps: ((j['nextSteps'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList(),
      );

  final String name;
  final String icd10;
  final String dsm5;
  final String confidence; // low | medium | high
  final List<String> matchingCriteria;
  final List<String> missingCriteria;
  final List<String> nextSteps;
}

enum DiagnosisErrorCode {
  noApiKey,
  unauthorized,
  rateLimit,
  network,
  parse,
  unknown,
}

class DiagnosisException implements Exception {
  const DiagnosisException(this.code, this.message);
  final DiagnosisErrorCode code;
  final String message;
  @override
  String toString() => 'DiagnosisException($code): $message';
}
