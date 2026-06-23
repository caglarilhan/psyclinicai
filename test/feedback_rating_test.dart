/// Coverage for the FIT (Feedback-Informed Therapy) scales
/// (ORS + SRS) and the repository / dropout-signal helper.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/feedback_rating.dart';
import 'package:psyclinicai/services/data/feedback_rating_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

FeedbackRating ors(
  String id,
  DateTime at, {
  required int individual,
  required int interpersonal,
  required int social,
  required int overall,
}) => FeedbackRating(
  id: id,
  kind: FitKind.ors,
  sessionId: 's-$id',
  patientId: 'p1',
  clinicianId: 'c1',
  capturedAt: at,
  scores: {
    FitItem.orsIndividual: individual,
    FitItem.orsInterpersonal: interpersonal,
    FitItem.orsSocial: social,
    FitItem.orsOverall: overall,
  },
);

FeedbackRating srs(
  String id,
  DateTime at, {
  required int relationship,
  required int goals,
  required int approach,
  required int overall,
}) => FeedbackRating(
  id: id,
  kind: FitKind.srs,
  sessionId: 's-$id',
  patientId: 'p1',
  clinicianId: 'c1',
  capturedAt: at,
  scores: {
    FitItem.srsRelationship: relationship,
    FitItem.srsGoals: goals,
    FitItem.srsApproach: approach,
    FitItem.srsOverall: overall,
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FeedbackRating', () {
    test('total sums the 4 items and matches the cutoff', () {
      final r = ors(
        'r1',
        DateTime.utc(2026, 6, 23),
        individual: 5,
        interpersonal: 6,
        social: 7,
        overall: 8,
      );
      expect(r.total, 26);
      // ORS cutoff is 25 — 26 is just above.
      expect(r.isBelowCutoff, isFalse);

      final low = ors(
        'r2',
        DateTime.utc(2026, 6, 23),
        individual: 5,
        interpersonal: 5,
        social: 5,
        overall: 5,
      );
      expect(low.total, 20);
      expect(low.isBelowCutoff, isTrue);
    });

    test('SRS cutoff is 36', () {
      final ok = srs(
        's1',
        DateTime.utc(2026, 6, 23),
        relationship: 10,
        goals: 9,
        approach: 9,
        overall: 9,
      );
      expect(ok.total, 37);
      expect(ok.isBelowCutoff, isFalse);

      final risk = srs(
        's2',
        DateTime.utc(2026, 6, 23),
        relationship: 9,
        goals: 9,
        approach: 9,
        overall: 9,
      );
      expect(risk.total, 36);
      expect(risk.isBelowCutoff, isTrue);
    });

    test('JSON round-trip preserves kind + scores + cutoff', () {
      final r = ors(
        'r1',
        DateTime.utc(2026, 6, 23),
        individual: 8,
        interpersonal: 7,
        social: 6,
        overall: 7,
      );
      final back = FeedbackRating.fromJson(r.toJson());
      expect(back.kind, FitKind.ors);
      expect(back.total, 28);
      expect(back.scores[FitItem.orsIndividual], 8);
    });

    test('fromJson tolerates missing scores by defaulting to 0', () {
      final back = FeedbackRating.fromJson({
        'id': 'partial',
        'kind': 'ors',
        'sessionId': 's',
        'patientId': 'p',
        'clinicianId': 'c',
        'capturedAt': '2026-06-23T10:00:00Z',
        'scores': {'ors_individual': 4},
      });
      expect(back.scores[FitItem.orsIndividual], 4);
      expect(back.scores[FitItem.orsOverall], 0);
      expect(back.total, 4);
    });

    test('FitItem.orsItems and srsItems each return 4 in order', () {
      expect(FitItem.orsItems, hasLength(4));
      expect(FitItem.srsItems, hasLength(4));
      expect(FitItem.orsItems.first, FitItem.orsIndividual);
      expect(FitItem.srsItems.last, FitItem.srsOverall);
    });
  });

  group('FeedbackRatingRepository', () {
    test('save round-trips through SharedPreferences', () async {
      final repo = FeedbackRatingRepository(storageKey: 'fit_rt');
      await repo.initialize();
      await repo.save(
        ors(
          'r1',
          DateTime.utc(2026, 6, 20),
          individual: 5,
          interpersonal: 6,
          social: 7,
          overall: 8,
        ),
      );
      final fresh = FeedbackRatingRepository(storageKey: 'fit_rt');
      await fresh.initialize();
      final list = fresh.forPatient('p1', kind: FitKind.ors);
      expect(list, hasLength(1));
      expect(list.first.total, 26);
    });

    test('forPatient sorts oldest-first across kinds', () async {
      final repo = FeedbackRatingRepository(storageKey: 'fit_sort');
      await repo.initialize();
      await repo.save(
        srs(
          's1',
          DateTime.utc(2026, 6, 23),
          relationship: 9,
          goals: 9,
          approach: 9,
          overall: 9,
        ),
      );
      await repo.save(
        ors(
          'r1',
          DateTime.utc(2026, 6, 20),
          individual: 5,
          interpersonal: 5,
          social: 5,
          overall: 5,
        ),
      );
      final all = repo.forPatient('p1');
      expect(all.first.kind, FitKind.ors);
      expect(all.last.kind, FitKind.srs);
    });

    test('patientHasDropoutSignal fires on a 5-point ORS drop', () async {
      final repo = FeedbackRatingRepository(storageKey: 'fit_drop');
      await repo.initialize();
      await repo.save(
        ors(
          'r1',
          DateTime.utc(2026, 6, 20),
          individual: 8,
          interpersonal: 8,
          social: 8,
          overall: 8,
        ),
      ); // total 32
      await repo.save(
        ors(
          'r2',
          DateTime.utc(2026, 6, 23),
          individual: 6,
          interpersonal: 6,
          social: 6,
          overall: 6,
        ),
      ); // total 24, delta -8
      expect(repo.patientHasDropoutSignal('p1'), isTrue);
    });

    test('patientHasDropoutSignal is false on a small drop', () async {
      final repo = FeedbackRatingRepository(storageKey: 'fit_steady');
      await repo.initialize();
      await repo.save(
        ors(
          'r1',
          DateTime.utc(2026, 6, 20),
          individual: 8,
          interpersonal: 8,
          social: 8,
          overall: 8,
        ),
      ); // total 32
      await repo.save(
        ors(
          'r2',
          DateTime.utc(2026, 6, 23),
          individual: 7,
          interpersonal: 8,
          social: 7,
          overall: 7,
        ),
      ); // total 29, delta -3
      expect(repo.patientHasDropoutSignal('p1'), isFalse);
    });

    test('patientHasDropoutSignal needs at least two ORS records', () async {
      final repo = FeedbackRatingRepository(storageKey: 'fit_single');
      await repo.initialize();
      await repo.save(
        ors(
          'r1',
          DateTime.utc(2026, 6, 20),
          individual: 8,
          interpersonal: 8,
          social: 8,
          overall: 8,
        ),
      );
      expect(repo.patientHasDropoutSignal('p1'), isFalse);
    });

    test('initialize drops corrupt records, keeps valid ones', () async {
      SharedPreferences.setMockInitialValues({
        'fit_corrupt': <String>[
          '{"id":"good","kind":"ors","sessionId":"s","patientId":"p","clinicianId":"c","capturedAt":"2026-06-23T10:00:00Z","scores":{"ors_individual":5,"ors_interpersonal":5,"ors_social":5,"ors_overall":5}}',
          'not valid json',
        ],
      });
      final repo = FeedbackRatingRepository(storageKey: 'fit_corrupt');
      await repo.initialize();
      expect(repo.all.length, 1);
      expect(repo.all.first.id, 'good');
    });
  });
}
