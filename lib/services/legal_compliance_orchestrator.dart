import 'package:flutter/foundation.dart';
import '../models/legal_policy_models.dart';
import 'legal_policy_service.dart';
import 'alerting_service.dart';

/// Legal uyum orkestratörü: değerlendirme + bildirim
class LegalComplianceOrchestrator extends ChangeNotifier {
  final LegalPolicyService _policyService;
  final AlertingService _alertingService;

  LegalComplianceOrchestrator({
    LegalPolicyService? policyService,
    AlertingService? alertingService,
  })  : _policyService = policyService ?? LegalPolicyService(),
        _alertingService = alertingService ?? AlertingService();

  /// Opsiyonel başlatma (uyumluluk için)
  Future<void> initialize() async {
    // Spesifik init yok; arayüz uyumluluğu için eklendi
  }

  /// Karar üretir ve bildirimlerini gönderir (de-dup/cooldown ile)
  Future<LegalDecision> evaluateAndNotify(LegalEvaluationContext context) async {
    // Eyalet bilgisini facts'e ekle
    final facts = {
      'patientId': context.patientId,
      'clinicianId': context.clinicianId,
      'crisisType': context.crisisType,
      'severity': context.severity,
      'description': context.description,
      'symptoms': context.symptoms,
      'riskFactors': context.riskFactors,
      'immediateActions': context.immediateActions,
      'timestamp': context.timestamp.toIso8601String(),
      ...context.facts,
    };

    final decision = await _policyService.evaluate(
      LegalEvaluationContext(
        patientId: context.patientId,
        clinicianId: context.clinicianId,
        crisisType: context.crisisType,
        severity: context.severity,
        description: context.description,
        symptoms: context.symptoms,
        riskFactors: context.riskFactors,
        immediateActions: context.immediateActions,
        timestamp: context.timestamp,
        state: context.state,
        facts: facts,
      ),
    );

    // Bildirimleri AlertingService üzerinden gönder
    for (final note in decision.notifications) {
      final patientId = context.patientId;
      // Not bazlı anahtar: farklı şablonlar ayrı ayrı gönderilsin
      final key = 'state:${context.state.name}|patient:$patientId|legal|note:${note.hashCode}';
      _alertingService.send(
        key: key,
        message: note,
        cooldown: const Duration(minutes: 5),
        channels: const [AlertChannel.inApp],
      );
    }

    return decision;
  }
}
