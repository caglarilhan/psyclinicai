import 'package:flutter/foundation.dart';

import '../../utils/phi_redaction.dart';

/// Abstraction over the server-side LLM proxy (Sprint 19 backend).
abstract class LlmProxyClient {
  Future<LlmCompletion> complete({required LlmRequest request});
}

enum LlmModel {
  haiku45('claude-haiku-4-5', 'Haiku 4.5 (fast)', 0.0010),
  sonnet46('claude-sonnet-4-6', 'Sonnet 4.6 (default)', 0.0040),
  opus47('claude-opus-4-7', 'Opus 4.7 (deep)', 0.0150);

  const LlmModel(this.id, this.label, this.usdPer5Min);

  final String id;
  final String label;
  final double usdPer5Min;

  static LlmModel fromId(String id) {
    for (final m in values) {
      if (m.id == id) return m;
    }
    // Loud fallback so cost attribution drift gets caught in QA.
    debugPrint(
        'LlmModel.fromId: unknown model id "$id", falling back to sonnet46');
    return LlmModel.sonnet46;
  }
}

class LlmRequest {
  const LlmRequest({
    required this.tenantId,
    required this.model,
    required this.prompt,
    this.systemPrompt,
    this.patientNames = const [],
    this.maxTokens = 1024,
    this.temperature = 0.2,
    this.tools = const [],
  });

  final String tenantId;
  final LlmModel model;
  final String prompt;
  final String? systemPrompt;
  final List<String> patientNames;
  final int maxTokens;
  final double temperature;
  final List<Map<String, dynamic>> tools;

  LlmRequest redacted({PhiRedactor? redactor}) {
    final r = redactor ?? PhiRedactor(patientNames: patientNames);
    return LlmRequest(
      tenantId: tenantId,
      model: model,
      prompt: r.scrub(prompt).cleanText,
      systemPrompt:
          systemPrompt == null ? null : r.scrub(systemPrompt!).cleanText,
      patientNames: patientNames,
      maxTokens: maxTokens,
      temperature: temperature,
      tools: tools,
    );
  }
}

class LlmCompletion {
  const LlmCompletion({
    required this.text,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.tenantUsdCost,
    this.toolUse,
  });

  final String text;
  final LlmModel model;
  final int inputTokens;
  final int outputTokens;
  final double tenantUsdCost;
  final Map<String, dynamic>? toolUse;
}

class LlmProxyClientStub implements LlmProxyClient {
  LlmProxyClientStub({this.responder});

  final LlmCompletion Function(LlmRequest req)? responder;

  @override
  Future<LlmCompletion> complete({required LlmRequest request}) async {
    if (responder != null) return responder!(request);
    return LlmCompletion(
      text: 'Stub response for tenant ${request.tenantId} using '
          '${request.model.label}.',
      model: request.model,
      inputTokens: request.prompt.length ~/ 4,
      outputTokens: 64,
      tenantUsdCost: request.model.usdPer5Min,
    );
  }
}
