import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/onboarding/onboarding_signals_repository.dart';

void main() {
  group('OnboardingSignals', () {
    test('empty state has completed=0 and no pillars touched', () {
      const s = OnboardingSignals.empty();
      expect(s.completed, 0);
      expect(s.allPillarsTouched, isFalse);
    });

    test('completed counts every touched pillar', () {
      const s = OnboardingSignals(
        hasSoapDraft: true,
        hasMbcDispatch: false,
        hasNoShowPrediction: true,
        hasTpPlan: true,
      );
      expect(s.completed, 3);
      expect(s.allPillarsTouched, isFalse);
    });

    test('allPillarsTouched trips at 4', () {
      const s = OnboardingSignals(
        hasSoapDraft: true,
        hasMbcDispatch: true,
        hasNoShowPrediction: true,
        hasTpPlan: true,
      );
      expect(s.completed, 4);
      expect(s.allPillarsTouched, isTrue);
    });
  });

  group('OnboardingSignalsRepository.watchAll', () {
    late FakeFirebaseFirestore db;
    late OnboardingSignalsRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = OnboardingSignalsRepository(db: db);
    });

    test('emits an empty baseline immediately', () async {
      final first = await repo.watchAll('clin-a').first;
      expect(first.completed, 0);
    });

    test('flips hasSoapDraft when an ai_scribe_drafts row exists', () async {
      await db.collection('ai_scribe_drafts').add({
        'clinic_id': 'clin-a',
        'tenant_id': 'clin-a',
        'session_id': 'sess-1',
        'created_at': Timestamp.fromDate(DateTime(2026, 7, 1)),
      });
      final signals = await repo.watchAll('clin-a').firstWhere(
        (s) => s.hasSoapDraft,
      );
      expect(signals.hasSoapDraft, isTrue);
      expect(signals.completed, 1);
    });

    test(
      'flips every flag independently and never leaks across clinics',
      () async {
        // Seed one row per collection for clin-a + one for clin-b.
        await db.collection('ai_scribe_drafts').add({
          'clinic_id': 'clin-a',
          'created_at': Timestamp.fromDate(DateTime(2026, 7, 1)),
        });
        await db.collection('mbc_dispatch').add({
          'clinic_id': 'clin-a',
          'created_at': Timestamp.fromDate(DateTime(2026, 7, 1)),
        });
        await db.collection('noshow_predictions').add({
          'clinic_id': 'clin-a',
          'created_at': Timestamp.fromDate(DateTime(2026, 7, 1)),
        });
        await db.collection('tp_drafted_plans').add({
          'clinic_id': 'clin-a',
          'created_at': Timestamp.fromDate(DateTime(2026, 7, 1)),
        });
        // Cross-clinic — must not surface as clin-a activation.
        await db.collection('ai_scribe_drafts').add({
          'clinic_id': 'clin-b',
          'created_at': Timestamp.fromDate(DateTime(2026, 7, 1)),
        });

        final aSignals = await repo
            .watchAll('clin-a')
            .firstWhere((s) => s.allPillarsTouched);
        expect(aSignals.completed, 4);

        // Now check clin-c (no rows) — must never flip.
        final cSignals = await repo.watchAll('clin-c').first;
        expect(cSignals.completed, 0);
      },
    );

    test('exposes the exact 4 collection paths as a public contract', () {
      expect(
        OnboardingSignalsRepository.watchedCollections,
        equals([
          'ai_scribe_drafts',
          'mbc_dispatch',
          'noshow_predictions',
          'tp_drafted_plans',
        ]),
      );
    });
  });
}
