import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/hallucination_warning_catalog.dart';

void main() {
  group('HallucinationWarningCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(HallucinationWarningCatalog.warnings, isNotEmpty);
    });

    test('every warning id is unique', () {
      final ids = HallucinationWarningCatalog.warnings
          .map((w) => w.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every entry', () {
      for (final w in HallucinationWarningCatalog.warnings) {
        expect(HallucinationWarningCatalog.byId(w.id), same(w));
      }
      expect(HallucinationWarningCatalog.byId('does-not-exist'), isNull);
    });

    test('every warning has populated fields + anchors', () {
      for (final w in HallucinationWarningCatalog.warnings) {
        expect(w.description, isNotEmpty, reason: w.id);
        expect(w.recognitionHints, isNotEmpty, reason: w.id);
        expect(w.regulatoryRefs, isNotEmpty, reason: w.id);
      }
    });

    test('every HallucinationClass has at least one pinned warning', () {
      final pinned = HallucinationWarningCatalog.warnings
          .map((w) => w.warningClass)
          .toSet();
      for (final c in HallucinationClass.values) {
        expect(
          pinned,
          contains(c),
          reason: '${c.name}: no warning pinned — coverage gap',
        );
      }
    });

    test('severity values are only from the known ladder', () {
      const allowed = {'patientHarm', 'clinicalMisinformation', 'cosmetic'};
      for (final w in HallucinationWarningCatalog.warnings) {
        expect(
          allowed,
          contains(w.severity),
          reason: '${w.id}: severity `${w.severity}` is not in the ladder',
        );
      }
    });

    test('byClass slices correctly', () {
      for (final c in HallucinationClass.values) {
        for (final w in HallucinationWarningCatalog.byClass(c)) {
          expect(w.warningClass, c);
        }
      }
    });
  });

  group('safety-critical invariants', () {
    test('fabricatedMedication MUST be patientHarm + block', () {
      final m = HallucinationWarningCatalog.byId('fabricated-medication-name')!;
      expect(m.severity, 'patientHarm');
      expect(m.clinicianAction, ClinicianAction.block);
      expect(isBlocking(m), isTrue);
    });

    test('demographicConfusion MUST be patientHarm + block', () {
      final d = HallucinationWarningCatalog.byId('demographic-confusion')!;
      expect(d.severity, 'patientHarm');
      expect(d.clinicianAction, ClinicianAction.block);
    });

    test('internalContradiction MUST be patientHarm + block', () {
      final c = HallucinationWarningCatalog.byId('internal-contradiction')!;
      expect(c.severity, 'patientHarm');
      expect(c.clinicianAction, ClinicianAction.block);
    });

    test('every patientHarm severity MUST map to block action', () {
      for (final w in HallucinationWarningCatalog.warnings) {
        if (w.severity != 'patientHarm') continue;
        expect(
          w.clinicianAction,
          ClinicianAction.block,
          reason:
              '${w.id}: patientHarm severity MUST block; a "verify" or '
              '"accept" on patient-harm content invites the harm',
        );
      }
    });

    test('fabricatedCitation + fabricatedDsmCode MUST require verify', () {
      for (final id in ['fabricated-citation', 'fabricated-dsm-code']) {
        final w = HallucinationWarningCatalog.byId(id)!;
        expect(w.clinicianAction, ClinicianAction.verify);
      }
    });

    test('every patient-harm warning cites FDA CDS or Joint Commission', () {
      const must = ['FDA CDS', 'Joint Commission', 'EU AI Act'];
      for (final w in HallucinationWarningCatalog.warnings) {
        if (w.severity != 'patientHarm') continue;
        final blob = w.regulatoryRefs.join(' | ');
        expect(
          must.any(blob.contains),
          isTrue,
          reason:
              '${w.id}: patient-harm warnings need a clinical-safety '
              'anchor (FDA CDS / Joint Commission / EU AI Act)',
        );
      }
    });
  });

  group('severityAtLeast ladder', () {
    test('patientHarm ≥ patientHarm', () {
      expect(severityAtLeast('patientHarm', 'patientHarm'), isTrue);
    });

    test('patientHarm > clinicalMisinformation', () {
      expect(severityAtLeast('patientHarm', 'clinicalMisinformation'), isTrue);
    });

    test('clinicalMisinformation > cosmetic', () {
      expect(severityAtLeast('clinicalMisinformation', 'cosmetic'), isTrue);
    });

    test('cosmetic < clinicalMisinformation', () {
      expect(severityAtLeast('cosmetic', 'clinicalMisinformation'), isFalse);
    });
  });

  group('isBlocking', () {
    test('true for block action', () {
      final m = HallucinationWarningCatalog.byId('fabricated-medication-name')!;
      expect(isBlocking(m), isTrue);
    });

    test('false for verify action', () {
      final c = HallucinationWarningCatalog.byId('fabricated-citation')!;
      expect(isBlocking(c), isFalse);
    });

    test('false for accept-with-caveat action', () {
      final s = HallucinationWarningCatalog.byId('fabricated-scheduling-item')!;
      expect(isBlocking(s), isFalse);
    });
  });
}
