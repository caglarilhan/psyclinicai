import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/dpia_register.dart';

void main() {
  group('DpiaRegister — pinned invariants', () {
    test('register is non-empty', () {
      expect(DpiaRegister.entries, isNotEmpty);
    });

    test('every entry has a unique id', () {
      final ids = DpiaRegister.entries.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final r in DpiaRegister.entries) {
        expect(DpiaRegister.byId(r.id), same(r));
      }
      expect(DpiaRegister.byId('does-not-exist'), isNull);
    });

    test('every entry has fields populated', () {
      for (final r in DpiaRegister.entries) {
        expect(r.activity, isNotEmpty, reason: r.id);
        expect(r.triggers, isNotEmpty, reason: r.id);
        expect(r.owner, isNotEmpty, reason: r.id);
        expect(r.evidencePath, isNotEmpty, reason: r.id);
        expect(r.ropaActivityId, isNotEmpty, reason: r.id);
      }
    });

    test('every entry parses both ISO dates', () {
      for (final r in DpiaRegister.entries) {
        expect(
          () => DateTime.parse(r.firstDraftedIso),
          returnsNormally,
          reason: r.id,
        );
        expect(
          () => DateTime.parse(r.nextReviewIso),
          returnsNormally,
          reason: r.id,
        );
      }
    });

    test('nextReviewIso is after firstDraftedIso for every entry', () {
      for (final r in DpiaRegister.entries) {
        final first = DateTime.parse(r.firstDraftedIso);
        final next = DateTime.parse(r.nextReviewIso);
        expect(
          next.isAfter(first),
          isTrue,
          reason: '${r.id}: nextReviewIso not after firstDraftedIso',
        );
      }
    });

    test(
      'medium + high residual risk DPIAs review at least annually (Art. 35(11))',
      () {
        for (final r in DpiaRegister.entries) {
          if (r.residualRisk == DpiaResidualRisk.low) continue;
          final first = DateTime.parse(r.firstDraftedIso);
          final next = DateTime.parse(r.nextReviewIso);
          final span = next.difference(first).inDays;
          expect(
            span,
            lessThanOrEqualTo(366),
            reason:
                '${r.id}: residual ${r.residualRisk.name} requires review '
                'within 12 months — span is $span days',
          );
        }
      },
    );

    test('high-residual DPIAs require Art. 36 prior consultation flag', () {
      for (final r in DpiaRegister.entries) {
        expect(
          requiresPriorConsultation(r),
          r.residualRisk == DpiaResidualRisk.high,
          reason: r.id,
        );
      }
    });

    test('cross-border DPIAs cite the trigger explicitly', () {
      const crossBorderIds = {
        'dpia-ai-assistance',
        'dpia-telehealth',
        'dpia-billing',
      };
      for (final id in crossBorderIds) {
        final r = DpiaRegister.byId(id)!;
        expect(
          r.triggers,
          contains(DpiaTrigger.crossBorderTransfer),
          reason: '$id involves a US sub-processor; trigger must be declared',
        );
      }
    });

    test(
      'every DPIA cross-references a ROPA activity id (Art. 30 → 35 walk)',
      () {
        for (final r in DpiaRegister.entries) {
          expect(
            r.ropaActivityId,
            isNotEmpty,
            reason: '${r.id}: missing ROPA cross-reference',
          );
        }
      },
    );

    test('every DPIA evidencePath lives under docs/compliance/ + ends .md', () {
      for (final r in DpiaRegister.entries) {
        expect(r.evidencePath, startsWith('docs/compliance/'), reason: r.id);
        expect(r.evidencePath, endsWith('.md'), reason: r.id);
      }
    });
  });

  group('daysUntilReview', () {
    test('returns positive days when review is in the future', () {
      final r = DpiaRegister.byId('dpia-ai-assistance')!;
      final today = DateTime.parse('2027-04-03'); // 60 days before
      expect(daysUntilReview(r, today), 60);
    });

    test('returns 0 on the review day', () {
      final r = DpiaRegister.byId('dpia-ai-assistance')!;
      final today = DateTime.parse('2027-06-02');
      expect(daysUntilReview(r, today), 0);
    });

    test('returns negative days when overdue', () {
      final r = DpiaRegister.byId('dpia-ai-assistance')!;
      final today = DateTime.parse('2027-07-02'); // 30 days overdue
      expect(daysUntilReview(r, today), -30);
    });
  });
}
