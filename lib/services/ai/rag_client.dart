import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thin client for the Clinical RAG Hub.
/// See ~/psyrag/docs/API.md for the endpoint contract.
class RagClient {
  RagClient({required this.baseUrl, required this.apiKey, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _http;

  Map<String, String> get _headers => {
        'X-Api-Key': apiKey,
        'Content-Type': 'application/json',
      };

  Future<RagAnswer> analyze({
    required Map<String, dynamic> patientContext,
    required String question,
    String region = 'EU',
    String? docType,
    String? clientUserRef,
    int topK = 8,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl/api/rag/analyze'),
      headers: _headers,
      body: jsonEncode({
        'patient_context': patientContext,
        'question': question,
        'region': region,
        if (docType != null) 'doc_type': docType,
        if (clientUserRef != null) 'client_user_ref': clientUserRef,
        'top_k': topK,
      }),
    );
    _throwIfError(res);
    return RagAnswer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<RagAnswer> query({
    required String question,
    String region = 'EU',
    String? docType,
    int topK = 8,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl/api/rag/query'),
      headers: _headers,
      body: jsonEncode({
        'question': question,
        'region': region,
        if (docType != null) 'doc_type': docType,
        'top_k': topK,
      }),
    );
    _throwIfError(res);
    return RagAnswer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<String> feedback({
    required String auditId,
    required String score,
    String? note,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl/api/rag/feedback'),
      headers: _headers,
      body: jsonEncode({'audit_id': auditId, 'score': score, if (note != null) 'note': note}),
    );
    _throwIfError(res);
    return (jsonDecode(res.body) as Map<String, dynamic>)['feedback_id'] as String;
  }

  Future<Map<String, dynamic>> health() async {
    final res = await _http.get(Uri.parse('$baseUrl/api/rag/health'));
    _throwIfError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _throwIfError(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw RagException(res.statusCode, res.body);
    }
  }

  void close() => _http.close();
}

class RagAnswer {
  RagAnswer({
    required this.answer,
    required this.citations,
    required this.modelUsed,
    required this.phiDetected,
    required this.auditId,
    required this.requestMs,
  });

  factory RagAnswer.fromJson(Map<String, dynamic> j) => RagAnswer(
        answer: j['answer'] as String,
        citations: (j['citations'] as List)
            .map((c) => RagCitation.fromJson(c as Map<String, dynamic>))
            .toList(),
        modelUsed: j['model_used'] as String,
        phiDetected: j['phi_detected'] as bool,
        auditId: j['audit_id'] as String,
        requestMs: j['request_ms'] as int,
      );

  final String answer;
  final List<RagCitation> citations;
  final String modelUsed;
  final bool phiDetected;
  final String auditId;
  final int requestMs;
}

class RagCitation {
  RagCitation({
    required this.id,
    required this.source,
    required this.country,
    required this.docType,
    required this.url,
    required this.score,
    required this.snippet,
  });

  factory RagCitation.fromJson(Map<String, dynamic> j) => RagCitation(
        id: j['id'] as String,
        source: j['source'] as String,
        country: j['country'] as String,
        docType: j['doc_type'] as String,
        url: j['url'] as String,
        score: (j['score'] as num).toDouble(),
        snippet: j['snippet'] as String,
      );

  final String id;
  final String source;
  final String country;
  final String docType;
  final String url;
  final double score;
  final String snippet;
}

class RagException implements Exception {
  RagException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'RagException($statusCode): $body';
}
