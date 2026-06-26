import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/ai_model_card_review_schedule.dart';

void main() {
  group('AiModelCardReviewSchedule — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(AiModelCardReviewSchedule.reviews, isNotEmpty);
    });

    test('every modelCardId is unique', () {
      final ids = AiModelCardReviewSchedule.reviews
          .map((r) => r.modelCardId)
          .toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate model ids');
    });

    test('byModelCardId resolves every entry', () {
      for (final r in AiModelCardReviewSchedule.reviews) {
        expect(AiModelCardReviewSchedule.byModelCardId(r.modelCardId), same(r));
      }
      expect(AiModelCardReviewSchedule.byModelCardId('does-not-exist'), isNull);
    });

    test('every review has reviewerRoles + evidence path + anchors', () {
      for (final r in AiModelCardReviewSchedule.reviews) {
        expect(r.reviewerRoles, isNotEmpty, reason: r.modelCardId);
        expect(
          r.evidencePathTemplate,
          startsWith('docs/ai/cards/'),
          reason: r.modelCardId,
        );
        expect(
          r.evidencePathTemplate,
          endsWith('.MANUAL.md'),
          reason: r.modelCardId,
        );
        expect(r.regulatoryRefs, isNotEmpty, reason: r.modelCardId);
        expect(r.reminderDaysBefore, greaterThan(0), reason: r.modelCardId);
      }
    });

    test('reminderDaysBefore < cycle length (must fire inside the cycle)', () {
      for (final r in AiModelCardReviewSchedule.reviews) {
        final cycle = r.cadence == ModelCardReviewCadence.semiAnnual
            ? 180
            : 365;
        expect(
          r.reminderDaysBefore,
          lessThan(cycle),
          reason: '${r.modelCardId}: reminder must land inside the cycle',
        );
      }
    });

    test('clinical / safety-tier cards require DPO + clinical_advisor', () {
      const clinicalIds = [
        'claude-3-5-sonnet-clinical-draft',
        'claude-3-5-sonnet-soap-summary',
        'claude-3-5-sonnet-cssrs-triage',
      ];
      for (final id in clinicalIds) {
        final r = AiModelCardReviewSchedule.byModelCardId(id)!;
        expect(
          r.reviewerRoles,
          containsAll(['dpo', 'clinical_advisor']),
          reason: '$id: clinical cards must be co-signed by DPO + advisor',
        );
      }
    });

    test('CSSRS triage card additionally requires CISO sign-off', () {
      final cssrs = AiModelCardReviewSchedule.byModelCardId(
        'claude-3-5-sonnet-cssrs-triage',
      )!;
      expect(cssrs.reviewerRoles, contains('ciso'));
    });

    test('clinical / safety cards review at most semi-annually', () {
      const clinicalIds = [
        'claude-3-5-sonnet-clinical-draft',
        'claude-3-5-sonnet-soap-summary',
        'claude-3-5-sonnet-cssrs-triage',
      ];
      for (final id in clinicalIds) {
        final r = AiModelCardReviewSchedule.byModelCardId(id)!;
        expect(
          r.cadence,
          ModelCardReviewCadence.semiAnnual,
          reason:
              '$id: clinical/safety cards must review at least semi-'
              'annually under EU AI Act Art. 13/14',
        );
      }
    });

    test('every review cites at least one AI-Act anchor', () {
      for (final r in AiModelCardReviewSchedule.reviews) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob,
          contains('AI Act'),
          reason: '${r.modelCardId}: regulatoryRefs must cite the EU AI Act',
        );
      }
    });

    test('evidence path uses canonical <YYYY> or <YYYY-mm> placeholder', () {
      for (final r in AiModelCardReviewSchedule.reviews) {
        expect(
          r.evidencePathTemplate.contains('<YYYY>') ||
              r.evidencePathTemplate.contains('<YYYY-mm>'),
          isTrue,
          reason:
              '${r.modelCardId}: evidence path must contain a date '
              'placeholder for the scheduler',
        );
      }
    });
  });

  group('daysUntilModelCardReview', () {
    test('semi-annual card: positive when in the future', () {
      final r = AiModelCardReviewSchedule.byModelCardId(
        'claude-3-5-sonnet-clinical-draft',
      )!;
      // 180 day cycle, reviewed 2026-01-01 → due 2026-06-30
      expect(
        daysUntilModelCardReview(
          record: r,
          lastReviewedIso: '2026-01-01',
          today: DateTime.parse('2026-05-01'),
        ),
        60,
      );
    });

    test('annual card: zero on the due day', () {
      final r = AiModelCardReviewSchedule.byModelCardId(
        'llama-3-3-70b-rag-grounded',
      )!;
      // 365 day cycle, reviewed 2026-01-01 → due 2027-01-01
      expect(
        daysUntilModelCardReview(
          record: r,
          lastReviewedIso: '2026-01-01',
          today: DateTime.parse('2027-01-01'),
        ),
        0,
      );
    });

    test('negative when overdue', () {
      final r = AiModelCardReviewSchedule.byModelCardId(
        'llama-3-3-70b-rag-grounded',
      )!;
      expect(
        daysUntilModelCardReview(
          record: r,
          lastReviewedIso: '2026-01-01',
          today: DateTime.parse('2027-02-01'),
        ),
        -31,
      );
    });
  });

  group('isInModelCardReviewWindow', () {
    test('false when far away', () {
      final r = AiModelCardReviewSchedule.byModelCardId(
        'claude-3-5-sonnet-clinical-draft',
      )!;
      expect(
        isInModelCardReviewWindow(
          record: r,
          lastReviewedIso: '2026-01-01',
          today: DateTime.parse('2026-02-01'),
        ),
        isFalse,
      );
    });

    test('true at the reminder edge', () {
      final r = AiModelCardReviewSchedule.byModelCardId(
        'claude-3-5-sonnet-clinical-draft',
      )!;
      // due 2026-06-30, reminder 60d → fire from 2026-05-01 onwards
      expect(
        isInModelCardReviewWindow(
          record: r,
          lastReviewedIso: '2026-01-01',
          today: DateTime.parse('2026-05-01'),
        ),
        isTrue,
      );
    });

    test('false when overdue (escalate, do not remind)', () {
      final r = AiModelCardReviewSchedule.byModelCardId(
        'claude-3-5-sonnet-clinical-draft',
      )!;
      expect(
        isInModelCardReviewWindow(
          record: r,
          lastReviewedIso: '2026-01-01',
          today: DateTime.parse('2026-08-01'),
        ),
        isFalse,
      );
    });
  });
}
