import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/outcome_measure_catalog.dart';
import 'package:psyclinicai/services/treatment_plan_drafter/tp_drafter_catalog.dart';

void main() {
  group('TpDrafterCatalog invariants', () {
    test('non-empty + unique (disorder, modality) keys', () {
      expect(TpDrafterCatalog.protocols, isNotEmpty);
      final seen = <String>{};
      for (final p in TpDrafterCatalog.protocols) {
        final key = '${p.disorder.name}_${p.modality.name}';
        expect(seen.contains(key), isFalse,
            reason: '$key: duplicate');
        seen.add(key);
      }
    });

    test('every protocol pins at least one guideline anchor', () {
      for (final p in TpDrafterCatalog.protocols) {
        expect(p.guidelineAnchors, isNotEmpty,
            reason: '${p.label}: missing guideline anchor');
      }
    });

    test('outcomeInstrument refers to a known outcome measure', () {
      for (final p in TpDrafterCatalog.protocols) {
        final m = OutcomeMeasureCatalog.byScaleId(p.outcomeInstrument);
        expect(m, isNotNull,
            reason:
                '${p.label}: outcomeInstrument ${p.outcomeInstrument} unknown');
      }
    });

    test('PTSD + BPD + AUD protocols require supervisor co-sign', () {
      for (final p in TpDrafterCatalog.protocols) {
        final highRisk = p.disorder == TpDisorderId.ptsd ||
            p.disorder == TpDisorderId.borderlinePersonalityDisorder ||
            p.disorder == TpDisorderId.alcoholUseDisorder;
        if (highRisk) {
          expect(p.requiresSupervisorCoSign, isTrue,
              reason: '${p.label}: high-risk modality must require co-sign');
        }
      }
    });

    test('recommendedSessions positive', () {
      for (final p in TpDrafterCatalog.protocols) {
        expect(p.recommendedSessions > 0, isTrue);
      }
    });

    test('byKey returns matching protocol', () {
      final p = TpDrafterCatalog.byKey(
        disorder: TpDisorderId.majorDepressiveDisorder,
        modality: TpModality.cbt,
      );
      expect(p.label, contains('Major Depressive Disorder'));
    });

    test('byKey throws on unsupported tuple', () {
      expect(
        () => TpDrafterCatalog.byKey(
          disorder: TpDisorderId.insomniaDisorder,
          modality: TpModality.emdr,
        ),
        throwsStateError,
      );
    });

    test('modalitiesFor returns non-empty for every disorder we ship', () {
      for (final p in TpDrafterCatalog.protocols) {
        final mods = TpDrafterCatalog.modalitiesFor(p.disorder);
        expect(mods, isNotEmpty);
        expect(mods.contains(p.modality), isTrue);
      }
    });

    test('smartGoalFields + outputSections non-empty + unique', () {
      expect(TpDrafterCatalog.smartGoalFields, isNotEmpty);
      expect(
        TpDrafterCatalog.smartGoalFields.toSet().length,
        TpDrafterCatalog.smartGoalFields.length,
      );
      expect(TpDrafterCatalog.outputSections, isNotEmpty);
      expect(
        TpDrafterCatalog.outputSections.toSet().length,
        TpDrafterCatalog.outputSections.length,
      );
    });

    test('schemaVersion positive + lastReviewed YYYY-MM', () {
      expect(TpDrafterCatalog.schemaVersion > 0, isTrue);
      expect(TpDrafterCatalog.lastReviewed,
          matches(RegExp(r'^\d{4}-\d{2}$')));
    });
  });

  group('requiresCoSign helper', () {
    test('returns true for high-risk PTSD-EMDR', () {
      final spec = TpDrafterCatalog.byKey(
        disorder: TpDisorderId.ptsd,
        modality: TpModality.emdr,
      );
      expect(requiresCoSign(spec), isTrue);
    });

    test('returns false for low-risk MDD-CBT', () {
      final spec = TpDrafterCatalog.byKey(
        disorder: TpDisorderId.majorDepressiveDisorder,
        modality: TpModality.cbt,
      );
      expect(requiresCoSign(spec), isFalse);
    });
  });
}
