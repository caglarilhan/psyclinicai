import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_storage.dart';
import 'copilot_endpoint.dart';

/// Real Anthropic Claude chat — replaces the previous 12-pattern
/// hard-coded stub. Multi-turn (we send the rolling conversation history
/// each call). BYOK: clinician's own key, no data ever passes through
/// PsyClinicAI servers.
class ChatService {
  ChatService({
    ApiKeyStorage? keyStorage,
    http.Client? client,
    IdTokenProvider? idTokenProvider,
    String? Function()? patientIdProvider,
  })  : _keyStorage = keyStorage ?? ApiKeyStorage.instance,
        _client = client ?? http.Client(),
        _idTokenProvider = idTokenProvider,
        _patientIdProvider = patientIdProvider;

  final ApiKeyStorage _keyStorage;
  final http.Client _client;
  final IdTokenProvider? _idTokenProvider;
  final String? Function()? _patientIdProvider;

  static const String _model = 'claude-haiku-4-5-20251001';
  static const String _anthropicVersion = '2023-06-01';

  static const String _systemPrompt = '''
You are PsyClinicAI Copilot, a clinical assistant for licensed therapists
and psychiatrists. You help with:
- Summarising patient notes ("summarise the last session for John Demo")
- DSM-5 differential discussion (NOT diagnosis — the clinician decides)
- PHQ-9 / GAD-7 score interpretation + clinical action suggestions
- CPT / ICD-10 lookup
- Evidence-based intervention reminders (CBT, DBT, motivational interviewing)

Rules:
- Speak in clear, concise English unless the clinician switches language.
- Cite the source when you reference a guideline (DSM-5, APA, NICE).
- Never give the clinician a final diagnosis — only offer a differential
  and the criteria they should reconfirm.
- If the clinician asks anything outside clinical scope, politely decline
  and remind them this assistant is for clinical workflow only.
- Never invent patient data. If you need information, ask the clinician.
- Format with short paragraphs and bullet points; max ~250 words per
  reply unless the clinician explicitly asks for more detail.
''';

  /// Maximum number of past turns to send back to the model. Caps
  /// the rolling history so a long-running session can't blow past
  /// Anthropic's context window. L-3 fix (audit 2026-06-21): the
  /// previous implementation sent the entire history every call,
  /// which silently truncates server-side and bills more tokens for
  /// the same answer. 40 turns ≈ 20 user/assistant pairs ≈ a
  /// 60-minute clinical conversation.
  static const int maxHistoryTurns = 40;

  /// Send the rolling [history] (oldest first, alternating user/assistant)
  /// and return the assistant's reply text.
  Future<String> send(List<ChatTurn> history) async {
    final key = await _keyStorage.getAnthropicKey();
    if (key == null || key.isEmpty) {
      throw const ChatException(
        ChatErrorCode.noApiKey,
        'No Anthropic API key configured. Add one under Settings → API keys.',
      );
    }

    // L-3 fix — keep only the most recent `maxHistoryTurns` turns.
    // The oldest turns drop first so the model still sees the
    // immediate context. The UI continues to show the full history
    // to the clinician; this only bounds the model-bound payload.
    final bounded = history.length > maxHistoryTurns
        ? history.sublist(history.length - maxHistoryTurns)
        : history;

    final messages = bounded
        .map(
          (t) => {
            'role': t.role == ChatRole.user ? 'user' : 'assistant',
            'content': t.text,
          },
        )
        .toList();

    // KRİTİK-1 fix (audit 2026-06-21): route through CopilotEndpoint so the
    // relay path (server-side consent gate + PHI scrub) is taken when
    // BACKEND_URL is configured. In direct/BYOK mode this falls back to the
    // pre-existing Anthropic-direct call — testers and BYOK users see no
    // behaviour change. The relay only sees the additional `patientId`
    // hint when the caller wired a provider; Anthropic's API ignores
    // extra top-level fields.
    final patientId = _patientIdProvider?.call();
    final body = jsonEncode({
      'model': _model,
      'max_tokens': 800,
      'temperature': 0.4,
      'system': _systemPrompt,
      'messages': messages,
      if (patientId != null && patientId.isNotEmpty) 'patientId': patientId,
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
          .post(
            CopilotEndpoint.uri,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw ChatException(
        ChatErrorCode.network,
        'Network error reaching Anthropic. $e',
      );
    }

    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw const ChatException(
        ChatErrorCode.unauthorized,
        'Anthropic rejected the API key. Verify it in Settings → API keys.',
      );
    }
    if (resp.statusCode == 429) {
      throw const ChatException(
        ChatErrorCode.rateLimit,
        'Rate limit hit. Wait a moment and retry.',
      );
    }
    if (resp.statusCode >= 500) {
      throw ChatException(
        ChatErrorCode.server,
        'Anthropic server error ${resp.statusCode}.',
      );
    }
    if (resp.statusCode != 200) {
      throw ChatException(
        ChatErrorCode.unknown,
        'Unexpected response ${resp.statusCode}: ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>?;
    if (content == null || content.isEmpty) {
      throw const ChatException(
        ChatErrorCode.parse,
        'Anthropic returned an empty response.',
      );
    }
    final first = content.first as Map<String, dynamic>;
    final text = first['text'] as String?;
    if (text == null || text.isEmpty) {
      throw const ChatException(
        ChatErrorCode.parse,
        'Anthropic response had no text content.',
      );
    }
    return text;
  }

  void dispose() => _client.close();
}

enum ChatRole { user, assistant }

class ChatTurn {
  ChatTurn({required this.role, required this.text, DateTime? at})
    : at = at ?? DateTime.now();

  final ChatRole role;
  final String text;
  final DateTime at;
}

enum ChatErrorCode {
  noApiKey,
  unauthorized,
  rateLimit,
  server,
  network,
  parse,
  unknown,
}

class ChatException implements Exception {
  const ChatException(this.code, this.message);
  final ChatErrorCode code;
  final String message;
  @override
  String toString() => 'ChatException($code): $message';
}
