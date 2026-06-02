import 'dart:async';

import '../../models/differential_candidate.dart';
import 'llm_proxy_client.dart';

/// Bridges the AI diagnosis UI with the LLM proxy. Uses Anthropic
/// tool-use so the model returns structured DSM-5 candidates rather
/// than free text. HIPAA §164.502(b): vignette + symptoms are
/// PHI-scrubbed via [LlmRequest.redacted()] before egress.
class AiDiagnosisService {
  AiDiagnosisService(this._client);

  final LlmProxyClient _client;

  static const Map<String, dynamic> toolSchema = {
    'name': 'submit_differential',
    'description':
        'Return a structured list of DSM-5 differential candidates.',
    'input_schema': {
      'type': 'object',
      'properties': {
        'candidates': {
          'type': 'array',
          'items': {
            'type': 'object',
            'required': ['code', 'name', 'confidence', 'criteriaMet'],
            'properties': {
              'code': {'type': 'string'},
              'name': {'type': 'string'},
              'confidence': {
                'type': 'number',
                'minimum': 0,
                'maximum': 1,
              },
              'criteriaMet': {
                'type': 'array',
                'items': {'type': 'string'},
              },
              'criteriaMissing': {
                'type': 'array',
                'items': {'type': 'string'},
              },
              'differentialFrom': {
                'type': 'array',
                'items': {'type': 'string'},
              },
            },
          },
        },
      },
      'required': ['candidates'],
    },
  };

  /// Default network deadline. Mid-session clinicians cannot afford an
  /// indefinite hang — surface a timeout so the UI can retry or fall
  /// back to manual mode.
  static const Duration defaultTimeout = Duration(seconds: 30);

  Future<List<DifferentialCandidate>> suggestDifferential({
    required String tenantId,
    required String vignette,
    required List<String> symptoms,
    LlmModel model = LlmModel.sonnet46,
    List<String> patientNames = const [],
    Duration timeout = defaultTimeout,
  }) async {
    final prompt = _buildPrompt(vignette: vignette, symptoms: symptoms);
    final request = LlmRequest(
      tenantId: tenantId,
      model: model,
      prompt: prompt,
      systemPrompt:
          'You are a clinical decision-support assistant for licensed '
          'clinicians. Do not diagnose. Surface differential candidates '
          'matched to DSM-5 criteria; the clinician owns the decision.',
      patientNames: patientNames,
      tools: const [toolSchema],
    ).redacted();
    final completion = await _client.complete(request: request).timeout(
          timeout,
          onTimeout: () => throw TimeoutException(
              'LLM proxy did not respond within ${timeout.inSeconds}s',
              timeout),
        );
    final payload = completion.toolUse;
    if (payload == null) {
      throw const FormatException(
          'Model did not return a tool-use payload.');
    }
    final raw = payload['candidates'];
    if (raw is! List) {
      throw const FormatException(
          'Tool-use payload missing "candidates" array.');
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(DifferentialCandidate.fromJson)
        .toList(growable: false);
  }

  String _buildPrompt({
    required String vignette,
    required List<String> symptoms,
  }) {
    final buffer = StringBuffer()
      ..writeln('Vignette:')
      ..writeln(vignette)
      ..writeln()
      ..writeln('Clinician-observed symptoms:');
    if (symptoms.isEmpty) {
      buffer.writeln('(none selected)');
    } else {
      for (final s in symptoms) {
        buffer.writeln('- $s');
      }
    }
    buffer
      ..writeln()
      ..writeln('Return at most five candidates ranked by confidence. '
          'Each candidate must list the DSM-5 criteria met and the '
          'criteria still missing for a confident call.');
    return buffer.toString();
  }
}
