import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/treatment_plan_models.dart';
import 'api_key_storage.dart';

/// AI-drafts SMART treatment-plan goals from a diagnosis + clinical
/// formulation, using Anthropic Claude (BYOK). Decision-support — the
/// clinician reviews and edits every goal. Mirrors the HTTP/auth pattern of
/// `soap_generator_service.dart`.
class TreatmentPlanAiService {
  TreatmentPlanAiService({ApiKeyStorage? keyStorage, http.Client? client})
      : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client();

  final ApiKeyStorage _keyStorage;
  final http.Client _client;

  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// Returns 3–5 drafted goals. Throws [TreatmentPlanAiException] only for the
  /// no-key case (so the UI can prompt for a key); other failures surface as a
  /// typed message too, never an opaque crash.
  Future<List<DraftGoal>> draftGoals({
    required String diagnosis,
    required String formulation,
  }) async {
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const TreatmentPlanAiException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    const system =
        'You are an experienced licensed clinician drafting a treatment plan. '
        'Given a diagnosis and clinical formulation, produce 3–5 SMART goals '
        '(Specific, Measurable, Achievable, Relevant, Time-bound). This is '
        'decision-support for a clinician who will review and edit. Respond '
        'with STRICT JSON only: {"goals":[{"description":"...",'
        '"category":"symptomReduction|functionalImprovement|skillDevelopment|'
        'relationshipImprovement|medicationCompliance|lifestyleChange|'
        'crisisPrevention|other","priority":"low|medium|high|critical",'
        '"measurement":"how progress is measured","targetWeeks":<int>}]}';

    final user = 'Primary diagnosis: $diagnosis\n\n'
        'Clinical formulation:\n$formulation';

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 900,
      'temperature': 0.3,
      'system': system,
      'messages': [
        {'role': 'user', 'content': user}
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
      throw TreatmentPlanAiException('Network error reaching Anthropic. $e');
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw const TreatmentPlanAiException(
          'Anthropic rejected the API key. Verify it in Settings → API Keys.');
    }
    if (resp.statusCode != 200) {
      throw TreatmentPlanAiException(
          'Anthropic error ${resp.statusCode}. Try again shortly.');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = (decoded['content'] as List<dynamic>? ?? const [])
        .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
        .join('\n')
        .trim();

    final goals = _parse(content);
    if (goals.isEmpty) {
      throw const TreatmentPlanAiException(
          'Could not parse goals from the AI response. Try again.');
    }
    return goals;
  }

  List<DraftGoal> _parse(String content) {
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return const [];
      final json =
          jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      final list = json['goals'] as List<dynamic>? ?? const [];
      return list
          .map((e) => e as Map<String, dynamic>)
          .map((m) => DraftGoal(
                description: (m['description'] as String? ?? '').trim(),
                category: _category(m['category'] as String? ?? ''),
                priority: _priority(m['priority'] as String? ?? ''),
                measurement: (m['measurement'] as String? ?? '').trim(),
                targetWeeks: (m['targetWeeks'] as num?)?.toInt() ?? 12,
              ))
          .where((g) => g.description.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static GoalCategory _category(String s) => switch (s.trim()) {
        'symptomReduction' => GoalCategory.symptomReduction,
        'functionalImprovement' => GoalCategory.functionalImprovement,
        'skillDevelopment' => GoalCategory.skillDevelopment,
        'relationshipImprovement' => GoalCategory.relationshipImprovement,
        'medicationCompliance' => GoalCategory.medicationCompliance,
        'lifestyleChange' => GoalCategory.lifestyleChange,
        'crisisPrevention' => GoalCategory.crisisPrevention,
        _ => GoalCategory.other,
      };

  static GoalPriority _priority(String s) => switch (s.trim()) {
        'critical' => GoalPriority.critical,
        'high' => GoalPriority.high,
        'low' => GoalPriority.low,
        _ => GoalPriority.medium,
      };

  void dispose() => _client.close();
}

/// A clinician-reviewable goal drafted by the AI.
class DraftGoal {
  DraftGoal({
    required this.description,
    required this.category,
    required this.priority,
    required this.measurement,
    required this.targetWeeks,
  });

  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final String measurement;
  final int targetWeeks;
}

class TreatmentPlanAiException implements Exception {
  const TreatmentPlanAiException(this.message, {this.noKey = false});
  final String message;
  final bool noKey;

  @override
  String toString() => 'TreatmentPlanAiException: $message';
}
