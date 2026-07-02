// ignore_for_file: avoid_catching_errors
// Schema-drift protection: we deliberately catch `TypeError` /
// `NoSuchMethodError` inside `TpDraftedPlan.fromJson` so a server
// response that grows a new required field surfaces as
// `TpDrafterException(422, …)` instead of an unhandled crash.
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
    // Cloud Function timeout is 45s per provider + 15s free-tier fallover,
    // so the whole request should return in <= 90s worst case. Bounding
    // the client side at 90s keeps the UI from hanging on a socket that
    // outlives the function invocation.
    final res = await _http
        .post(
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
        )
        .timeout(
          const Duration(seconds: 90),
          onTimeout: () => throw const TpDrafterException(
            408,
            'Request timed out — please retry.',
          ),
        );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw TpDrafterException(res.statusCode, res.body);
    }
    return TpDraftedPlan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
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

  /// Defensive constructor — a missing top-level key or type mismatch
  /// throws a `TpDrafterException(422, …)` the UI can surface, instead
  /// of an unhandled `TypeError` that reads as a generic crash.
  factory TpDraftedPlan.fromJson(Map<String, dynamic> j) {
    try {
      return TpDraftedPlan(
        schemaVersion: j['schemaVersion'] as int,
        generatedAtMillis: j['generatedAt'] as int,
        provider: j['provider'] as String,
        model: j['model'] as String,
        protocolLabel: j['protocolLabel'] as String,
        requiresSupervisorCoSign: j['requiresSupervisorCoSign'] as bool,
        plan: Map<String, dynamic>.from(j['plan'] as Map),
        phiRedactions: (j['phiRedactions'] as int?) ?? 0,
      );
    } on TypeError catch (e) {
      throw TpDrafterException(
        422,
        'Malformed tpDraftPlan response — schema drift: $e',
      );
    } on NoSuchMethodError catch (e) {
      throw TpDrafterException(
        422,
        'Missing tpDraftPlan response field: $e',
      );
    }
  }

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
