import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai_scribe/soap_section_catalog.dart';

void main() {
  group('SoapSectionCatalog invariants', () {
    test('all four SOAP sections present, in canonical order', () {
      final order = SoapSectionCatalog.sections.map((s) => s.section).toList();
      expect(order, [
        SoapSection.subjective,
        SoapSection.objective,
        SoapSection.assessment,
        SoapSection.plan,
      ]);
    });

    test('every section has at least one required field', () {
      for (final spec in SoapSectionCatalog.sections) {
        final reqs = spec.fields.where((f) => f.required).toList();
        expect(
          reqs.isNotEmpty,
          isTrue,
          reason: '${spec.title} has no required field',
        );
      }
    });

    test('every section has a non-empty regulatory anchor', () {
      for (final spec in SoapSectionCatalog.sections) {
        expect(
          spec.regulatoryRefs.isNotEmpty,
          isTrue,
          reason: '${spec.title} missing regulatory anchor',
        );
      }
    });

    test('every section has temperature in [0.0, 1.0]', () {
      for (final spec in SoapSectionCatalog.sections) {
        final t = SoapSectionCatalog.sectionTemperature[spec.section];
        expect(t, isNotNull, reason: '${spec.title} missing temperature');
        expect(t! >= 0.0 && t <= 1.0, isTrue);
      }
    });

    test('field keys are unique within each section', () {
      for (final spec in SoapSectionCatalog.sections) {
        final keys = spec.fields.map((f) => f.key).toSet();
        expect(
          keys.length,
          spec.fields.length,
          reason: '${spec.title} has duplicate field keys',
        );
      }
    });

    test('Assessment carries risk_assessment as required', () {
      final spec = SoapSectionCatalog.bySection(SoapSection.assessment);
      final risk = spec.fields.firstWhere((f) => f.key == 'risk_assessment');
      expect(risk.required, isTrue);
      expect(risk.citationRequired, isTrue);
    });

    test('Plan carries safety_plan_reference (req-on-elevated)', () {
      final spec = SoapSectionCatalog.bySection(SoapSection.plan);
      final keys = spec.fields.map((f) => f.key).toList();
      expect(keys.contains('safety_plan_reference'), isTrue);
    });

    test('schema version is positive int', () {
      expect(SoapSectionCatalog.schemaVersion > 0, isTrue);
    });

    test('lastReviewed matches YYYY-MM', () {
      expect(
        SoapSectionCatalog.lastReviewed,
        matches(RegExp(r'^\d{4}-\d{2}$')),
      );
    });
  });

  group('isSectionComplete', () {
    test('returns false when a required field is missing', () {
      final spec = SoapSectionCatalog.bySection(SoapSection.subjective);
      expect(isSectionComplete(spec, const {}), isFalse);
    });

    test('returns false when a required string is whitespace-only', () {
      final spec = SoapSectionCatalog.bySection(SoapSection.subjective);
      expect(
        isSectionComplete(spec, const {
          'chief_complaint': '   ',
          'history_present_illness': 'x',
          'patient_reported_symptoms': ['x'],
        }),
        isFalse,
      );
    });

    test('returns true when every required field has content', () {
      final spec = SoapSectionCatalog.bySection(SoapSection.subjective);
      expect(
        isSectionComplete(spec, const {
          'chief_complaint': 'Anxiety',
          'history_present_illness': '2-week onset',
          'patient_reported_symptoms': ['Sleep loss'],
        }),
        isTrue,
      );
    });
  });

  group('soapDraftCacheKey', () {
    test('embeds schema version, tenant, section', () {
      final key = soapDraftCacheKey(
        tenantId: 'tenant-x',
        section: SoapSection.plan,
      );
      expect(key, 'soap:v1:tenant-x:plan');
    });
  });
}
