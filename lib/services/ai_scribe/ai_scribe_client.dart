import 'dart:convert';

import 'package:http/http.dart' as http;

import 'soap_section_catalog.dart';

/// Thin client for the `aiScribeDraftSoap` Cloud Function (PILAR 1).
///
/// Mirrors `lib/services/ai/rag_client.dart` — server-side handler
/// owns the prompt + JSON schema; the client just ships the
/// transcript + metadata + a Firebase ID token.
typedef IdTokenProvider = Future<String?> Function();

class AiScribeClient {
  AiScribeClient({
    required this.baseUrl,
    required this.idTokenProvider,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Expected to be `${BuildConfig.backendUrl}/aiScribeDraftSoap`.
  final String baseUrl;
  final IdTokenProvider idTokenProvider;
  final http.Client _http;

  Future<Map<String, String>> _headers() async {
    final token = await idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const AiScribeException(401, 'No Firebase ID token available.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<AiScribeDraft> draftSoap({
    required String tenantId,
    required String sessionId,
    required String transcript,
    String? patientId,
    List<SoapSection>? sections,
  }) async {
    final res = await _http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({
        'tenantId': tenantId,
        'sessionId': sessionId,
        'transcript': transcript,
        if (patientId != null) 'patientId': patientId,
        if (sections != null && sections.isNotEmpty)
          'sections': sections.map((s) => s.name).toList(),
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw AiScribeException(res.statusCode, res.body);
    }
    return AiScribeDraft.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void close() => _http.close();
}

/// Parsed response from `aiScribeDraftSoap`. The `sections` map is
/// keyed by the SOAP section name (subjective/objective/assessment/plan)
/// and carries the LLM's structured payload — the review screen binds
/// each field key from the catalog to its value here.
class AiScribeDraft {
  const AiScribeDraft({
    required this.sessionId,
    required this.schemaVersion,
    required this.generatedAtMillis,
    required this.provider,
    required this.model,
    required this.sections,
    required this.phiRedactions,
  });

  factory AiScribeDraft.fromJson(Map<String, dynamic> j) => AiScribeDraft(
    sessionId: j['sessionId'] as String,
    schemaVersion: j['schemaVersion'] as int,
    generatedAtMillis: j['generatedAt'] as int,
    provider: j['provider'] as String,
    model: j['model'] as String,
    sections: Map<String, dynamic>.from(j['sections'] as Map),
    phiRedactions: (j['phiRedactions'] as int?) ?? 0,
  );

  final String sessionId;
  final int schemaVersion;
  final int generatedAtMillis;
  final String provider;
  final String model;
  final Map<String, dynamic> sections;
  final int phiRedactions;

  /// Pulls the `value` of one field from the section payload. Returns
  /// the empty string when the field is absent.
  String stringField(SoapSection section, String key) {
    final s = sections[section.name];
    if (s is! Map) return '';
    final f = s[key];
    if (f is! Map) return '';
    final v = f['value'];
    if (v is String) return v;
    if (v is List) return v.join('\n');
    return '';
  }
}

class AiScribeException implements Exception {
  const AiScribeException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'AiScribeException($statusCode): $body';
}
