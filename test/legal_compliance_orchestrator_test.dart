import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/legal_compliance_orchestrator.dart';
import 'package:psyclinicai/services/legal_policy_service.dart';
import 'package:psyclinicai/services/alerting_service.dart';
import 'package:psyclinicai/models/legal_policy_models.dart';

void main() {
  group('LegalComplianceOrchestrator', () {
    late LegalPolicyService policyService;
    late AlertingService alertingService;
    late LegalComplianceOrchestrator orchestrator;

    setUp(() async {
      policyService = LegalPolicyService();
      await policyService.initialize();
      alertingService = AlertingService();
      alertingService.clearAll();
      orchestrator = LegalComplianceOrchestrator(
        policyService: policyService,
        alertingService: alertingService,
      );
    });

    test('should evaluate and send notifications', () async {
      final context = LegalEvaluationContext(
        patientId: 'p1',
        clinicianId: 'c1',
        crisisType: 'suicide_risk',
        severity: 'critical',
        description: 'Kritik intihar riski',
        symptoms: ['Umutsuzluk'],
        riskFactors: ['Geçmiş girişim'],
        immediateActions: ['Güvenlik planı'],
        timestamp: DateTime.now(),
        state: UsStateCode.ca,
        facts: {
          'patientId': 'p1',
          'risk_level': 'Kritik',
          'threat_to_others': false,
        },
      );

      final decision = await orchestrator.evaluateAndNotify(context);

      expect(decision.notifications, isNotEmpty);
      expect(alertingService.events.length, decision.notifications.length);
    });

    test('should de-dup notifications within cooldown', () async {
      final context = LegalEvaluationContext(
        patientId: 'p2',
        clinicianId: 'c1',
        crisisType: 'suicide_risk',
        severity: 'critical',
        description: 'Kritik intihar riski',
        symptoms: ['Umutsuzluk'],
        riskFactors: ['Depresyon'],
        immediateActions: ['Yakın takip'],
        timestamp: DateTime.now(),
        state: UsStateCode.ca,
        facts: {
          'patientId': 'p2',
          'risk_level': 'Kritik',
        },
      );

      await orchestrator.evaluateAndNotify(context);
      final before = alertingService.events.length;

      // Aynı karar tekrar üretilecek → cool-down içinde olduğundan yeni event gelmemeli
      await orchestrator.evaluateAndNotify(context);
      final after = alertingService.events.length;

      expect(after, equals(before));
    });
  });
}
