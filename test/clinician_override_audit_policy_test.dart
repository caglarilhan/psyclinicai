import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/clinician_override_audit_policy.dart';

void main() {
  group('ClinicianOverrideAuditPolicy — pinned invariants', () {
    test('records is non-empty', () {
      expect(ClinicianOverrideAuditPolicy.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = ClinicianOverrideAuditPolicy.records
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in ClinicianOverrideAuditPolicy.records) {
        expect(ClinicianOverrideAuditPolicy.byId(r.id), same(r));
      }
      expect(ClinicianOverrideAuditPolicy.byId('does-not-exist'), isNull);
    });

    test('every OverrideOutcome has exactly one pinned record', () {
      for (final o in OverrideOutcome.values) {
        final matches = ClinicianOverrideAuditPolicy.records
            .where((r) => r.outcome == o)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${o.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in ClinicianOverrideAuditPolicy.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('overrodeBlock MUST require justification + second reviewer', () {
      final r = ClinicianOverrideAuditPolicy.byId('overrode-block')!;
      expect(r.outcome, OverrideOutcome.overrodeBlock);
      expect(r.requiresJustification, isTrue);
      expect(r.secondReviewerRequired, isTrue);
      expect(r.retention, OverrideRetentionClass.patientSafetyCritical);
    });

    test(
      'overrodeVerify MUST require justification (second reviewer optional)',
      () {
        final r = ClinicianOverrideAuditPolicy.byId('overrode-verify')!;
        expect(r.requiresJustification, isTrue);
        expect(r.secondReviewerRequired, isFalse);
      },
    );

    test('rejectedSuggestion MUST require justification', () {
      final r = ClinicianOverrideAuditPolicy.byId('rejected-suggestion')!;
      expect(r.requiresJustification, isTrue);
    });

    test(
      'acceptedSuggestion + editedSuggestion MUST NOT require justification',
      () {
        for (final id in ['accepted-suggestion', 'edited-suggestion']) {
          final r = ClinicianOverrideAuditPolicy.byId(id)!;
          expect(
            r.requiresJustification,
            isFalse,
            reason:
                '$id: forcing justification on routine outcomes burns clinician trust',
          );
        }
      },
    );

    test('only overrodeBlock uses patientSafetyCritical retention', () {
      for (final r in ClinicianOverrideAuditPolicy.records) {
        if (r.id == 'overrode-block') {
          expect(r.retention, OverrideRetentionClass.patientSafetyCritical);
        } else {
          expect(
            r.retention,
            OverrideRetentionClass.routineClinical,
            reason:
                '${r.id}: patientSafetyCritical retention is reserved for overrodeBlock',
          );
        }
      }
    });

    test('overrodeBlock MUST cite FDA CDS + EU AI Act + HIPAA', () {
      final r = ClinicianOverrideAuditPolicy.byId('overrode-block')!;
      final blob = r.regulatoryRefs.join(' | ');
      expect(
        blob.contains('FDA CDS'),
        isTrue,
        reason: 'block override needs FDA CDS anchor',
      );
      expect(
        blob.contains('EU AI Act'),
        isTrue,
        reason: 'block override needs EU AI Act Art. 14 anchor',
      );
      expect(
        blob.contains('HIPAA'),
        isTrue,
        reason: 'block override needs HIPAA retention anchor',
      );
    });

    test(
      'every record MUST cite EU AI Act Art. 14 human oversight or FDA CDS',
      () {
        for (final r in ClinicianOverrideAuditPolicy.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('EU AI Act Art. 14') || blob.contains('FDA CDS'),
            isTrue,
            reason: '${r.id}: every override outcome is a human-oversight act',
          );
        }
      },
    );

    test(
      'every record requiring secondReviewer MUST also require justification',
      () {
        for (final r in ClinicianOverrideAuditPolicy.records) {
          if (!r.secondReviewerRequired) continue;
          expect(
            r.requiresJustification,
            isTrue,
            reason:
                '${r.id}: cannot escalate to second reviewer without a justification artifact',
          );
        }
      },
    );
  });

  group('requiresJustification / requiresSecondReviewer helpers', () {
    test('requiresJustification true for the 3 override outcomes', () {
      expect(requiresJustification(OverrideOutcome.rejectedSuggestion), isTrue);
      expect(requiresJustification(OverrideOutcome.overrodeBlock), isTrue);
      expect(requiresJustification(OverrideOutcome.overrodeVerify), isTrue);
    });

    test('requiresJustification false for the 2 routine outcomes', () {
      expect(
        requiresJustification(OverrideOutcome.acceptedSuggestion),
        isFalse,
      );
      expect(requiresJustification(OverrideOutcome.editedSuggestion), isFalse);
    });

    test('requiresSecondReviewer true ONLY for overrodeBlock', () {
      for (final o in OverrideOutcome.values) {
        if (o == OverrideOutcome.overrodeBlock) {
          expect(requiresSecondReviewer(o), isTrue, reason: o.name);
        } else {
          expect(requiresSecondReviewer(o), isFalse, reason: o.name);
        }
      }
    });
  });
}
