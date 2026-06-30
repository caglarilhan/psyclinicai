import 'dart:convert';

import 'package:http/http.dart' as http;

import 'tp_drafter_catalog.dart';

/// Thin client for the `tpDraftPlan` Cloud Function (PILAR 4 / PR-2).
typedef IdTokenProvider = Future<String?> Function();

class TpDrafterClient {
  TpDrafterClient({
    required this.draftUrl,
    required this.idTokenProvider,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Expected to be `${BuildConfig.backendUrl}/tpDraftPlan`.
  final String draftUrl;
  final IdTokenProvider idTokenProvider;
  final http.Client _http;

  Future<Map<String, String>> _headers() async {
    final token = await idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const TpDrafterException(401, 'No Firebase ID token available.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<TpDraftedPlan> draftPlan({
    required String tenantId,
    String? patientId,
    required TpDisorderId disorder,
    required TpModality modality,
    required List<String> presentingProblems,
    String? extraContext,
  }) async {
    final res = await _http.post(
      Uri.parse(draftUrl),
      headers: await _headers(),
      body: jsonEncode({
        'tenantId': tenantId,
        if (patientId != null) 'patientId': patientId,
        'disorder': disorder.name,
        'modality': modality.name,
        'presentingProblems': presentingProblems,
        if (extraContext != null) 'extraContext': extraContext,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw TpDrafterException(res.statusCode, res.body);
    }
    return TpDraftedPlan.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  void close() => _http.close();
}

class TpDraftedPlan {
  const TpDraftedPlan({
    required this.schemaVersion,
    required this.generatedAtMillis,
    required this.provider,
    required this.model,
    required this.protocolLabel,
    required this.requiresSupervisorCoSign,
    required this.plan,
    required this.phiRedactions,
  });

  factory TpDraftedPlan.fromJson(Map<String, dynamic> j) => TpDraftedPlan(
        schemaVersion: j['schemaVersion'] as int,
        generatedAtMillis: j['generatedAt'] as int,
        provider: j['provider'] as String,
        model: j['model'] as String,
        protocolLabel: j['protocolLabel'] as String,
        requiresSupervisorCoSign:
            j['requiresSupervisorCoSign'] as bool,
        plan: Map<String, dynamic>.from(j['plan'] as Map),
        phiRedactions: (j['phiRedactions'] as int?) ?? 0,
      );

  final int schemaVersion;
  final int generatedAtMillis;
  final String provider;
  final String model;
  final String protocolLabel;
  final bool requiresSupervisorCoSign;
  final Map<String, dynamic> plan;
  final int phiRedactions;

  List<String> presentingProblems() {
    final list = plan['presenting_problems'];
    if (list is List) return list.cast<String>();
    return const [];
  }

  List<Map<String, dynamic>> smartGoals() {
    final list = plan['smart_goals'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> sessionPlan() {
    final list = plan['session_plan'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    return const [];
  }

  String riskReviewCadence() {
    final v = plan['risk_review_cadence'];
    return v is String ? v : '';
  }
}

class TpDrafterException implements Exception {
  const TpDrafterException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'TpDrafterException($statusCode): $body';
}
