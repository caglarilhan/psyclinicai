import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/dpia_trigger_catalog.dart';

void main() {
  group('DpiaTriggerCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(DpiaTriggerCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = DpiaTriggerCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in DpiaTriggerCatalog.records) {
        expect(DpiaTriggerCatalog.byId(r.id), same(r));
      }
      expect(DpiaTriggerCatalog.byId('does-not-exist'), isNull);
    });

    test('every DpiaTrigger has exactly one pinned record', () {
      for (final t in DpiaTrigger.values) {
        final matches = DpiaTriggerCatalog.records
            .where((r) => r.trigger == t)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${t.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in DpiaTriggerCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.requiredReviewers, isNotEmpty, reason: r.id);
        expect(r.reviewTurnaroundDays, greaterThan(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'every record MUST be mandatory (scope is GDPR Art. 35(3) + EDPB WP248 only)',
      () {
        for (final r in DpiaTriggerCatalog.records) {
          expect(
            r.mandatory,
            isTrue,
            reason:
                '${r.id}: catalog scope is mandatory-only triggers; nice-to-have lives elsewhere',
          );
        }
      },
    );

    test('every record MUST include DPO reviewer (Art. 35(2))', () {
      for (final r in DpiaTriggerCatalog.records) {
        expect(
          r.requiredReviewers,
          contains(DpiaReviewerRole.dpo),
          reason: '${r.id}: GDPR Art. 35(2) mandates DPO advice on every DPIA',
        );
      }
    });

    test('every record MUST cite GDPR or EDPB anchor', () {
      for (final r in DpiaTriggerCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('GDPR Art. 35') ||
              blob.contains('EDPB WP248') ||
              blob.contains('GDPR Art. 9') ||
              blob.contains('GDPR Art. 22'),
          isTrue,
          reason:
              '${r.id}: needs a GDPR Art. 35(3) sub-condition OR EDPB WP248 criterion',
        );
      }
    });

    test('AI / innovative-technology MUST cite EU AI Act + FDA CDS', () {
      final r = DpiaTriggerCatalog.byTrigger(DpiaTrigger.innovativeTechnology)!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(
        blob.contains('EU AI Act'),
        isTrue,
        reason: 'AI clinical decision support needs EU AI Act anchor',
      );
      expect(
        blob.contains('FDA CDS'),
        isTrue,
        reason: 'AI clinical decision support needs FDA CDS anchor',
      );
    });

    test('large-scale-health-data MUST cite Art. 9 (special category)', () {
      final r = DpiaTriggerCatalog.byTrigger(DpiaTrigger.largeScaleHealthData)!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(
        blob.contains('GDPR Art. 9'),
        isTrue,
        reason: 'health data is GDPR Art. 9 special category',
      );
    });

    test('clinical-impacting triggers MUST include clinical lead reviewer', () {
      for (final t in [
        DpiaTrigger.largeScaleHealthData,
        DpiaTrigger.vulnerableSubjects,
        DpiaTrigger.innovativeTechnology,
        DpiaTrigger.preventsRightExercise,
      ]) {
        final r = DpiaTriggerCatalog.byTrigger(t)!;
        expect(
          r.requiredReviewers,
          contains(DpiaReviewerRole.clinicalLead),
          reason:
              '${t.name}: trigger touches patient-safety surface; clinical lead sign-off mandatory',
        );
      }
    });

    test('security-impacting triggers MUST include CISO reviewer', () {
      for (final t in [
        DpiaTrigger.systematicAutomatedProfiling,
        DpiaTrigger.largeScaleHealthData,
        DpiaTrigger.systematicPublicMonitoring,
        DpiaTrigger.innovativeTechnology,
      ]) {
        final r = DpiaTriggerCatalog.byTrigger(t)!;
        expect(
          r.requiredReviewers,
          contains(DpiaReviewerRole.ciso),
          reason:
              '${t.name}: trigger affects security-of-processing axis (Art. 32); CISO sign-off mandatory',
        );
      }
    });

    test('reviewTurnaroundDays MUST be <= 30 (regulator-defensible cadence)', () {
      for (final r in DpiaTriggerCatalog.records) {
        expect(
          r.reviewTurnaroundDays,
          lessThanOrEqualTo(30),
          reason:
              '${r.id}: DPIAs taking > 30 business days suggest rubber-stamp behaviour and undermine the gate',
        );
      }
    });

    test(
      'vulnerable-subjects MUST cite GDPR Art. 8 or CRPD (vulnerability anchor)',
      () {
        final r = DpiaTriggerCatalog.byTrigger(DpiaTrigger.vulnerableSubjects)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('Art. 8') || blob.contains('CRPD'),
          isTrue,
          reason:
              'vulnerable-subjects trigger needs a vulnerability anchor (Art. 8 child consent OR CRPD)',
        );
      },
    );
  });

  group('requiresDpia helper', () {
    test('requiresDpia true for every mandatory trigger', () {
      for (final t in DpiaTrigger.values) {
        expect(requiresDpia(t), isTrue, reason: t.name);
      }
    });
  });
}
