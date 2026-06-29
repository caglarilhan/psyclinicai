import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/training_data_taxonomy.dart';

void main() {
  group('TrainingDataTaxonomy — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(TrainingDataTaxonomy.buckets, isNotEmpty);
    });

    test('every bucket has a unique id', () {
      final ids = TrainingDataTaxonomy.buckets.map((b) => b.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final b in TrainingDataTaxonomy.buckets) {
        expect(TrainingDataTaxonomy.byId(b.id), same(b));
      }
      expect(TrainingDataTaxonomy.byId('does-not-exist'), isNull);
    });

    test('every bucket has fields populated', () {
      for (final b in TrainingDataTaxonomy.buckets) {
        expect(b.label, isNotEmpty, reason: b.id);
        expect(b.examplePayload, isNotEmpty, reason: b.id);
        expect(b.regulatoryRefs, isNotEmpty, reason: b.id);
      }
    });

    test('PHI-tinged bucket is a hard quarantine (no eligible uses)', () {
      final phi = TrainingDataTaxonomy.byId('phi-tinged-do-not-train')!;
      expect(phi.eligibleUses, isEmpty);
      expect(isQuarantineBucket(phi), isTrue);
      for (final use in TrainingUse.values) {
        expect(
          isUseAllowed(phi, use),
          isFalse,
          reason: 'PHI-tinged bucket must forbid ${use.name}',
        );
      }
    });

    test('every non-quarantine bucket declares at least one eligible use', () {
      for (final b in TrainingDataTaxonomy.buckets) {
        if (isQuarantineBucket(b)) continue;
        expect(
          b.eligibleUses,
          isNotEmpty,
          reason:
              '${b.id}: a non-quarantine bucket without eligible uses is '
              'dead weight — either delete it or list the uses',
        );
      }
    });

    test('clinician-derived buckets require BOTH anonymisation AND opt-in', () {
      const clinicianBucketIds = [
        'clinician-edit-anonymised',
        'clinician-thumbs-feedback',
      ];
      for (final id in clinicianBucketIds) {
        final b = TrainingDataTaxonomy.byId(id)!;
        expect(
          b.requiresIrreversibleAnonymisation,
          isTrue,
          reason: '$id: clinician data must be anonymised before train',
        );
        expect(
          b.requiresClinicianOptIn,
          isTrue,
          reason: '$id: clinicians must explicitly opt in',
        );
      }
    });

    test('no clinician-derived bucket is eligible for public release without '
        'further controls', () {
      const clinicianBucketIds = [
        'clinician-edit-anonymised',
        'clinician-thumbs-feedback',
      ];
      for (final id in clinicianBucketIds) {
        final b = TrainingDataTaxonomy.byId(id)!;
        expect(
          isUseAllowed(b, TrainingUse.evalPublic),
          isFalse,
          reason:
              '$id: anonymised clinician data MUST NOT enter a public '
              'eval set without an explicit second-level review',
        );
      }
    });

    test('public-domain buckets need no clinician opt-in', () {
      const publicIds = ['rag-grounded-public-qa', 'red-team-jailbreak-probes'];
      for (final id in publicIds) {
        final b = TrainingDataTaxonomy.byId(id)!;
        expect(b.requiresClinicianOptIn, isFalse, reason: id);
      }
    });

    test('synthetic augmentation may flow into public evals', () {
      final synth = TrainingDataTaxonomy.byId('synthetic-augmentation')!;
      expect(isUseAllowed(synth, TrainingUse.evalPublic), isTrue);
    });

    test('every bucket cites at least one EU AI Act / HIPAA / GDPR anchor', () {
      const must = ['EU AI Act', 'HIPAA', 'GDPR', 'CC-BY', 'OWASP'];
      for (final b in TrainingDataTaxonomy.buckets) {
        final blob = b.regulatoryRefs.join(' | ');
        expect(
          must.any(blob.contains),
          isTrue,
          reason: '${b.id}: regulatoryRefs cite no anchor we recognise',
        );
      }
    });

    test('quarantine retention is the shortest of any bucket', () {
      final phi = TrainingDataTaxonomy.byId('phi-tinged-do-not-train')!;
      for (final b in TrainingDataTaxonomy.buckets) {
        if (b.id == phi.id) continue;
        // 0 means "kept until manually purged"; treat as longer than
        // any finite retention.
        if (b.retentionDays == 0) continue;
        expect(
          phi.retentionDays,
          lessThanOrEqualTo(b.retentionDays),
          reason: 'PHI quarantine must purge faster than ${b.id}',
        );
      }
    });
  });

  group('isUseAllowed', () {
    test('returns true for a listed use', () {
      final b = TrainingDataTaxonomy.byId('clinician-edit-anonymised')!;
      expect(isUseAllowed(b, TrainingUse.fineTune), isTrue);
    });

    test('returns false for an unlisted use', () {
      final b = TrainingDataTaxonomy.byId('clinician-edit-anonymised')!;
      expect(isUseAllowed(b, TrainingUse.evalPublic), isFalse);
    });
  });

  group('isQuarantineBucket', () {
    test('true for the PHI-tinged bucket', () {
      final phi = TrainingDataTaxonomy.byId('phi-tinged-do-not-train')!;
      expect(isQuarantineBucket(phi), isTrue);
    });

    test('false for normal buckets', () {
      final rag = TrainingDataTaxonomy.byId('rag-grounded-public-qa')!;
      expect(isQuarantineBucket(rag), isFalse);
    });
  });
}
