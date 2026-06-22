import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/clinical_decision_support.dart';

void main() {
  group('ClinicalDecisionSupport envelope', () {
    test('defaults to decision-support-only risk class', () {
      final cds = ClinicalDecisionSupport<String>(
        suggestion: 'F33.1 Major depressive disorder, recurrent, moderate',
        modelId: 'claude-haiku-4-5',
        modelVersion: 'pyc-2026-06-21',
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      expect(cds.riskClass, ClinicalRiskClass.decisionSupportOnly);
      expect(cds.requiresClinicianConfirmation, isTrue);
    });

    test('disclaimer carries the not-a-diagnosis copy by default', () {
      final cds = ClinicalDecisionSupport<int>(
        suggestion: 0,
        modelId: 'm',
        modelVersion: 'v',
        generatedAt: DateTime.now(),
      );
      expect(cds.disclaimer.toLowerCase(), contains('not a diagnosis'));
      expect(cds.disclaimer.toLowerCase(), contains('clinician'));
    });

    test('toJson surfaces every regulator-relevant field', () {
      final cds = ClinicalDecisionSupport<Map<String, dynamic>>(
        suggestion: {'icd10': 'F32.1', 'label': 'MDD moderate'},
        modelId: 'claude-haiku-4-5',
        modelVersion: 'pyc-2026-06-21',
        generatedAt: DateTime.utc(2026, 6, 21, 12),
        riskClass: ClinicalRiskClass.cdss,
        evidenceSpans: ['Client reports 2 weeks of low mood'],
      );
      final json = cds.toJson();
      expect(json['kind'], 'clinical_decision_support');
      expect(json['modelId'], 'claude-haiku-4-5');
      expect(json['modelVersion'], 'pyc-2026-06-21');
      expect(json['generatedAt'], '2026-06-21T12:00:00.000Z');
      expect(json['riskClass'], 'cdss');
      expect(json['requiresClinicianConfirmation'], isTrue);
      expect(json['evidenceSpans'], hasLength(1));
      expect(json['disclaimer'], isNotEmpty);
      expect((json['suggestion'] as Map)['icd10'], 'F32.1');
    });

    test('serialises a toJson-bearing nested suggestion', () {
      final nested = _DxCandidate(icd10: 'F41.1', confidence: 'medium');
      final cds = ClinicalDecisionSupport<_DxCandidate>(
        suggestion: nested,
        modelId: 'm',
        modelVersion: 'v',
        generatedAt: DateTime.now(),
      );
      final json = cds.toJson();
      expect((json['suggestion'] as Map)['icd10'], 'F41.1');
      expect((json['suggestion'] as Map)['confidence'], 'medium');
    });

    test('falls back to toString when the nested type lacks toJson', () {
      final cds = ClinicalDecisionSupport<_OpaqueSuggestion>(
        suggestion: _OpaqueSuggestion('opaque'),
        modelId: 'm',
        modelVersion: 'v',
        generatedAt: DateTime.now(),
      );
      expect(cds.toJson()['suggestion'], 'OPAQUE:opaque');
    });
  });
}

class _DxCandidate {
  _DxCandidate({required this.icd10, required this.confidence});
  final String icd10;
  final String confidence;
  Map<String, dynamic> toJson() => {'icd10': icd10, 'confidence': confidence};
}

class _OpaqueSuggestion {
  _OpaqueSuggestion(this.value);
  final String value;
  @override
  String toString() => 'OPAQUE:$value';
}
