import 'dart:convert';

import 'package:http/http.dart' as http;

import 'noshow_feature_catalog.dart';

/// Thin client for the `noshowPredict` Cloud Function (PILAR 3 / PR-2).
typedef IdTokenProvider = Future<String?> Function();

class NoShowPredictClient {
  NoShowPredictClient({
    required this.predictUrl,
    required this.idTokenProvider,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Expected to be `${BuildConfig.backendUrl}/noshowPredict`.
  final String predictUrl;
  final IdTokenProvider idTokenProvider;
  final http.Client _http;

  Future<NoShowPrediction> predict({
    required String tenantId,
    required String appointmentId,
    required String patientId,
    required Map<String, Object> features,
  }) async {
    final token = await idTokenProvider();
    if (token == null || token.isEmpty) {
      throw const NoShowPredictException(401, 'No Firebase ID token.');
    }
    final res = await _http.post(
      Uri.parse(predictUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tenantId': tenantId,
        'appointmentId': appointmentId,
        'patientId': patientId,
        'features': features,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw NoShowPredictException(res.statusCode, res.body);
    }
    return NoShowPrediction.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  void close() => _http.close();
}

class NoShowPrediction {
  const NoShowPrediction({
    required this.probability,
    required this.tier,
    required this.modelVersion,
    required this.playbook,
  });

  factory NoShowPrediction.fromJson(Map<String, dynamic> j) {
    final t = j['tier'] as String;
    final tier = NoShowRiskTier.values.firstWhere(
      (v) => v.name == t,
      orElse: () => NoShowRiskTier.low,
    );
    final pb = j['playbook'] as Map<String, dynamic>;
    return NoShowPrediction(
      probability: (j['probability'] as num).toDouble(),
      tier: tier,
      modelVersion: j['modelVersion'] as String,
      playbook: NoShowPredictedPlaybook(
        confirmCadenceHours: (pb['confirmCadenceHours'] as List).cast<int>(),
        smsConfirmHours: pb['smsConfirmHours'] as int,
        callConfirmHours: pb['callConfirmHours'] as int,
        depositRequired: pb['depositRequired'] as bool,
        waitlistOfferOnCancel: pb['waitlistOfferOnCancel'] as bool,
        estUsdSavedPerSlot: pb['estUsdSavedPerSlot'] as int,
      ),
    );
  }

  final double probability;
  final NoShowRiskTier tier;
  final String modelVersion;
  final NoShowPredictedPlaybook playbook;
}

class NoShowPredictedPlaybook {
  const NoShowPredictedPlaybook({
    required this.confirmCadenceHours,
    required this.smsConfirmHours,
    required this.callConfirmHours,
    required this.depositRequired,
    required this.waitlistOfferOnCancel,
    required this.estUsdSavedPerSlot,
  });

  final List<int> confirmCadenceHours;
  final int smsConfirmHours;
  final int callConfirmHours;
  final bool depositRequired;
  final bool waitlistOfferOnCancel;
  final int estUsdSavedPerSlot;
}

class NoShowPredictException implements Exception {
  const NoShowPredictException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'NoShowPredictException($statusCode): $body';
}
