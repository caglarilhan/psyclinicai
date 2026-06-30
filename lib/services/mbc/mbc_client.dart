import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin client for the `mbcSubmitAssessment` PUBLIC Cloud Function.
/// No Firebase ID token is sent — the URL-bound token is the only
/// credential. See `functions/src/mbc_submit_assessment.ts`.
class MbcPublicClient {
  MbcPublicClient({
    required this.submitUrl,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Expected to be `${BuildConfig.backendUrl}/mbcSubmitAssessment`.
  final String submitUrl;
  final http.Client _http;

  Future<MbcSubmitResult> submit({
    required String token,
    required List<int> answers,
  }) async {
    final res = await _http.post(
      Uri.parse(submitUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'answers': answers}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MbcSubmitException(res.statusCode, res.body);
    }
    return MbcSubmitResult.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  void close() => _http.close();
}

class MbcSubmitResult {
  const MbcSubmitResult({
    required this.scaleId,
    required this.score,
    required this.maxScore,
    required this.severity,
    required this.alarmTriggered,
    required this.clinicianAction,
  });

  factory MbcSubmitResult.fromJson(Map<String, dynamic> j) => MbcSubmitResult(
        scaleId: j['scaleId'] as String,
        score: j['score'] as int,
        maxScore: j['maxScore'] as int,
        severity: j['severity'] as String,
        alarmTriggered: j['alarmTriggered'] as bool,
        clinicianAction: j['clinicianAction'] as String,
      );

  final String scaleId;
  final int score;
  final int maxScore;
  final String severity;
  final bool alarmTriggered;
  final String clinicianAction;
}

class MbcSubmitException implements Exception {
  const MbcSubmitException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'MbcSubmitException($statusCode): $body';
}
