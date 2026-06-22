import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/treatment_plan_models.dart';
import '../compliance/consent_guard.dart';
import 'api_key_storage.dart';
import 'copilot_endpoint.dart';
import 'prompt_safety.dart';

/// AI-drafts SMART treatment-plan goals from a diagnosis + clinical
/// formulation, using Anthropic Claude (BYOK). Decision-support — the
/// clinician reviews and edits every goal. Mirrors the HTTP/auth pattern of
/// `soap_generator_service.dart`.
class TreatmentPlanAiService {
  TreatmentPlanAiService({
    ApiKeyStorage? keyStorage,
    http.Client? client,
    ConsentGuard? consentGuard,
    IdTokenProvider? idTokenProvider,
    String? Function()? patientIdProvider,
  }) : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
       _client = client ?? http.Client(),
       // Default to fail-closed; production caller injects an
       // IntakeRepository-backed guard.
       _guard = consentGuard ?? ConsentGuard(),
       _idTokenProvider = idTokenProvider,
       _patientIdProvider = patientIdProvider;

  final ApiKeyStorage _keyStorage;
  final http.Client _client;
  final ConsentGuard _guard;
  final IdTokenProvider? _idTokenProvider;
  final String? Function()? _patientIdProvider;

  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  /// Returns 3–5 drafted goals. Throws [TreatmentPlanAiException] only for the
  /// no-key case (so the UI can prompt for a key); other failures surface as a
  /// typed message too, never an opaque crash.
  Future<List<DraftGoal>> draftGoals({
    required String patientId,
    required String diagnosis,
    required String formulation,
  }) async {
    _guard.requireAi(patientId);
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

    // Prompt-injection guard (B7): clinician-supplied free-text is
    // fenced as data-only blocks. Either field can be replayed as
    // "ignore previous instructions" otherwise.
    final user =
        '${PromptSafety.fence('diagnosis', diagnosis)}\n\n'
        '${PromptSafety.fence('formulation', formulation)}';

    // KRİTİK-1 fix (audit 2026-06-21): route through CopilotEndpoint so the
    // relay path (server-side consent gate + PHI scrub) is taken when
    // BACKEND_URL is configured. In direct/BYOK mode this falls back to the
    // pre-existing Anthropic-direct call — testers and BYOK users see no
    // behaviour change. The relay only sees the additional `patientId`
    // hint when the caller wired a provider; Anthropic's API ignores
    // extra top-level fields.
    final relayPatientId = _patientIdProvider?.call() ?? patientId;
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 900,
      'temperature': 0.3,
      'system': '$system\n\n${PromptSafety.dataOnlyDirective}',
      'messages': [
        {'role': 'user', 'content': user},
      ],
      if (relayPatientId.isNotEmpty) 'patientId': relayPatientId,
    });

    Map<String, String> headers;
    if (CopilotEndpoint.useRelay) {
      headers = await CopilotEndpoint.headersAsync(
        key,
        idTokenProvider: _idTokenProvider,
      );
    } else {
      headers = {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': _anthropicVersion,
        'anthropic-dangerous-direct-browser-access': 'true',
      };
    }

    http.Response resp;
    try {
      resp = await _client
          .post(CopilotEndpoint.uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 40));
    } catch (e) {
      throw TreatmentPlanAiException('Network error reaching Anthropic. $e');
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw const TreatmentPlanAiException(
        'Anthropic rejected the API key. Verify it in Settings → API Keys.',
      );
    }
    if (resp.statusCode != 200) {
      throw TreatmentPlanAiException(
        'Anthropic error ${resp.statusCode}. Try again shortly.',
      );
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = (decoded['content'] as List<dynamic>? ?? const [])
        .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
        .join('\n')
        .trim();

    final goals = _parse(content);
    if (goals.isEmpty) {
      throw const TreatmentPlanAiException(
        'Could not parse goals from the AI response. Try again.',
      );
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
          .map(
            (m) => DraftGoal(
              description: (m['description'] as String? ?? '').trim(),
              category: _category(m['category'] as String? ?? ''),
              priority: _priority(m['priority'] as String? ?? ''),
              measurement: (m['measurement'] as String? ?? '').trim(),
              targetWeeks: (m['targetWeeks'] as num?)?.toInt() ?? 12,
            ),
          )
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

  /// Suggests 3–5 concrete homework assignment titles tied to the active
  /// goals. Throws [TreatmentPlanAiException] (noKey set) when no key.
  Future<List<String>> suggestHomework({
    required String patientId,
    required String diagnosis,
    required List<String> goals,
  }) async {
    _guard.requireAi(patientId);
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const TreatmentPlanAiException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    const system =
        'You are an experienced clinician suggesting concrete, doable '
        'between-session homework assignments tied to the treatment goals. '
        'Each is one short actionable sentence the client could do this week. '
        'Respond STRICT JSON only: {"homework":["...","..."]} (3–5 items).';
    // Prompt-injection guard (B7): fence inputs as data-only.
    final user =
        '${PromptSafety.fence('diagnosis', diagnosis)}\n\n'
        '${PromptSafety.fence('active_goals', goals.map((g) => '- $g').join('\n'))}';

    // KRİTİK-1 fix (audit 2026-06-21): route through CopilotEndpoint.
    final relayPatientId = _patientIdProvider?.call() ?? patientId;
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 500,
      'temperature': 0.4,
      'system': '$system\n\n${PromptSafety.dataOnlyDirective}',
      'messages': [
        {'role': 'user', 'content': user},
      ],
      if (relayPatientId.isNotEmpty) 'patientId': relayPatientId,
    });

    Map<String, String> headers;
    if (CopilotEndpoint.useRelay) {
      headers = await CopilotEndpoint.headersAsync(
        key,
        idTokenProvider: _idTokenProvider,
      );
    } else {
      headers = {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': _anthropicVersion,
        'anthropic-dangerous-direct-browser-access': 'true',
      };
    }

    try {
      final resp = await _client
          .post(CopilotEndpoint.uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw const TreatmentPlanAiException(
          'Anthropic rejected the API key. Verify it in Settings → API Keys.',
        );
      }
      if (resp.statusCode != 200) {
        throw TreatmentPlanAiException(
          'Anthropic error ${resp.statusCode}. Try again shortly.',
        );
      }
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start < 0 || end <= start) return const [];
      final json =
          jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      return (json['homework'] as List<dynamic>? ?? const [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    } on TreatmentPlanAiException {
      rethrow;
    } catch (e) {
      throw TreatmentPlanAiException('Network error reaching Anthropic. $e');
    }
  }

  /// Drafts a formal insurance reimbursement-justification letter (EU
  /// Kostenzuschuss / Erstattung / out-of-network), from the diagnosis +
  /// goals. Returns the letter text; throws [TreatmentPlanAiException]
  /// (noKey set) when no key. Decision-support draft — clinician reviews.
  Future<String> draftReimbursementLetter({
    required String patientId,
    required String patientName,
    required String diagnosis,
    required List<String> goals,
    String language = 'English',
  }) async {
    _guard.requireAi(patientId);
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const TreatmentPlanAiException(
        'No Anthropic API key configured. Add one under Settings → API Keys.',
        noKey: true,
      );
    }

    final system =
        'You are a clinician drafting a concise, formal insurance '
        'reimbursement-justification letter (for EU statutory/private '
        'reimbursement such as Kostenzuschuss/Erstattung, or out-of-network). '
        'Write in $language. State the diagnosis, medical necessity, treatment '
        'goals and expected duration/frequency, in a professional letter '
        'format with placeholders [Insurer], [Date], [Clinician], [Credentials]. '
        'Do NOT invent facts beyond what is given. Output the letter text only.';
    // Prompt-injection guard (B7): patient name / diagnosis / goals
    // are all clinician-supplied; fence them as data-only.
    final user =
        '${PromptSafety.fence('patient', patientName)}\n\n'
        '${PromptSafety.fence('diagnosis', diagnosis)}\n\n'
        '${PromptSafety.fence('treatment_goals', goals.map((g) => '- $g').join('\n'))}';

    // KRİTİK-1 fix (audit 2026-06-21): route through CopilotEndpoint.
    final relayPatientId = _patientIdProvider?.call() ?? patientId;
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 900,
      'temperature': 0.3,
      'system': system,
      'messages': [
        {'role': 'user', 'content': user},
      ],
      if (relayPatientId.isNotEmpty) 'patientId': relayPatientId,
    });

    Map<String, String> headers;
    if (CopilotEndpoint.useRelay) {
      headers = await CopilotEndpoint.headersAsync(
        key,
        idTokenProvider: _idTokenProvider,
      );
    } else {
      headers = {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': _anthropicVersion,
        'anthropic-dangerous-direct-browser-access': 'true',
      };
    }

    try {
      final resp = await _client
          .post(CopilotEndpoint.uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 40));
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw const TreatmentPlanAiException(
          'Anthropic rejected the API key. Verify it in Settings → API Keys.',
        );
      }
      if (resp.statusCode != 200) {
        throw TreatmentPlanAiException(
          'Anthropic error ${resp.statusCode}. Try again shortly.',
        );
      }
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = (decoded['content'] as List<dynamic>? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['text'] as String? ?? '')
          .join('\n')
          .trim();
      if (content.isEmpty) {
        throw const TreatmentPlanAiException('Empty response. Try again.');
      }
      return content;
    } on TreatmentPlanAiException {
      rethrow;
    } catch (e) {
      throw TreatmentPlanAiException('Network error reaching Anthropic. $e');
    }
  }

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
