import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/legal_policy_service.dart';
import 'package:psyclinicai/models/legal_policy_models.dart';

void main() {
  group('LegalPolicyService', () {
    late LegalPolicyService service;

    setUp(() async {
      service = LegalPolicyService();
      await service.initialize();
    });

    test('should load mock policies', () async {
      expect(service.policies, isNotEmpty);
      expect(service.getPolicy(UsStateCode.ca), isNotNull);
      expect(service.getPolicy(UsStateCode.ny), isNotNull);
    });

    test('CA: critical suicide risk triggers mandatory report and safety plan', () async {
      final decision = await service.evaluate(
        LegalEvaluationContext(
          patientId: 'p1',
          clinicianId: 'c1',
          crisisType: 'suicide_risk',
          severity: 'critical',
          description: 'Kritik intihar riski',
          symptoms: ['Umutsuzluk', 'Veda mesajları'],
          riskFactors: ['Geçmiş girişim'],
          immediateActions: ['Güvenlik planı'],
          timestamp: DateTime.now(),
          state: UsStateCode.ca,
          facts: {
            'patientId': 'p1',
            'risk_level': 'Kritik',
            'threat_to_others': false,
          },
        ),
      );

      expect(decision.requiredActions.length, 2);
      expect(decision.notifications, isNotEmpty);
      expect(decision.notifications.any((n) => n.contains('CA Zorunlu Bildirim')), isTrue);
      expect(decision.notifications.any((n) => n.contains('CA Güvenlik Planı gerekli')), isTrue);
    });

    test('CA: threat to others triggers duty to warn', () async {
      final decision = await service.evaluate(
        LegalEvaluationContext(
          patientId: 'p2',
          clinicianId: 'c1',
          crisisType: 'threat_to_others',
          severity: 'medium',
          description: 'Başkalarına tehdit',
          symptoms: ['Öfke', 'Tehdit'],
          riskFactors: ['Geçmiş şiddet'],
          immediateActions: ['Güvenlik değerlendirmesi'],
          timestamp: DateTime.now(),
          state: UsStateCode.ca,
          facts: {
            'patientId': 'p2',
            'risk_level': 'Orta',
            'threat_to_others': true,
          },
        ),
      );

      expect(decision.requiredActions.any((a) => a.obligation == LegalObligationType.dutyToWarn), isTrue);
      expect(decision.notifications.any((n) => n.contains('Duty to Warn')), isTrue);
    });

    test('NY: high risk triggers mandatory report', () async {
      final decision = await service.evaluate(
        LegalEvaluationContext(
          patientId: 'p3',
          clinicianId: 'c1',
          crisisType: 'suicide_risk',
          severity: 'high',
          description: 'Yüksek intihar riski',
          symptoms: ['Umutsuzluk'],
          riskFactors: ['Depresyon'],
          immediateActions: ['Yakın takip'],
          timestamp: DateTime.now(),
          state: UsStateCode.ny,
          facts: {
            'patientId': 'p3',
            'risk_level': 'Yüksek',
          },
        ),
      );

      expect(decision.requiredActions.any((a) => a.obligation == LegalObligationType.mandatoryReporting), isTrue);
      expect(decision.notifications.any((n) => n.contains('NY Zorunlu Bildirim')), isTrue);
    });

    test('NY: low risk produces no actions', () async {
      final decision = await service.evaluate(
        LegalEvaluationContext(
          patientId: 'p4',
          clinicianId: 'c1',
          crisisType: 'general_crisis',
          severity: 'low',
          description: 'Düşük risk',
          symptoms: ['Hafif kaygı'],
          riskFactors: [],
          immediateActions: ['Rutin takip'],
          timestamp: DateTime.now(),
          state: UsStateCode.ny,
          facts: {
            'patientId': 'p4',
            'risk_level': 'Düşük',
          },
        ),
      );

      expect(decision.requiredActions, isEmpty);
      expect(decision.notifications, isEmpty);
    });
  });
}
