import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/noshow/noshow_feature_catalog.dart';
import 'package:psyclinicai/services/noshow/noshow_recent_repository.dart';

void main() {
  group('NoShowRecentRepository', () {
    late FakeFirebaseFirestore db;
    late NoShowRecentRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = NoShowRecentRepository(db: db);
    });

    test('watchRecent scopes to clinic_id + orders desc by created_at', () async {
      final now = DateTime(2026, 6, 30, 10);
      await db.collection('noshow_predictions').add({
        'clinic_id': 'clin-a',
        'appointment_id': 'appt-1',
        'patient_id': 'pt-1',
        'probability': 0.22,
        'tier': 'low',
        'model_version': 'v1',
        'created_at': Timestamp.fromDate(now),
      });
      await db.collection('noshow_predictions').add({
        'clinic_id': 'clin-a',
        'appointment_id': 'appt-2',
        'patient_id': 'pt-2',
        'probability': 0.78,
        'tier': 'high',
        'model_version': 'v1',
        'created_at': Timestamp.fromDate(now.add(const Duration(hours: 1))),
      });
      // A row on a DIFFERENT clinic — must not leak.
      await db.collection('noshow_predictions').add({
        'clinic_id': 'clin-b',
        'appointment_id': 'appt-3',
        'patient_id': 'pt-3',
        'probability': 0.5,
        'tier': 'medium',
        'model_version': 'v1',
        'created_at': Timestamp.fromDate(now.add(const Duration(hours: 3))),
      });

      final rows = await repo.watchRecent(clinicId: 'clin-a').first;
      expect(rows.length, 2);
      expect(rows.first.appointmentId, 'appt-2', reason: 'newest first');
      expect(rows.first.tier, NoShowRiskTier.high);
      expect(
        rows.every((r) => r.appointmentId != 'appt-3'),
        isTrue,
        reason: 'clinic-b row must not appear for clinic-a',
      );
    });

    test('parses probability + tier defensively (bad payload → low tier)', () async {
      await db.collection('noshow_predictions').add({
        'clinic_id': 'clin-a',
        'appointment_id': 'appt-x',
        'patient_id': 'pt-x',
        // Missing probability + tier — must fall back to safe defaults.
        'model_version': 'v1',
        'created_at': Timestamp.fromDate(DateTime(2026, 6, 30, 10)),
      });
      final rows = await repo.watchRecent(clinicId: 'clin-a').first;
      expect(rows.single.probability, 0);
      expect(rows.single.tier, NoShowRiskTier.low);
    });

    test('watchRecent honours the limit', () async {
      final base = DateTime(2026, 6, 30, 10);
      for (var i = 0; i < 15; i++) {
        await db.collection('noshow_predictions').add({
          'clinic_id': 'clin-a',
          'appointment_id': 'appt-$i',
          'patient_id': 'pt-$i',
          'probability': 0.3,
          'tier': 'low',
          'model_version': 'v1',
          'created_at': Timestamp.fromDate(base.add(Duration(hours: i))),
        });
      }
      final rows = await repo.watchRecent(clinicId: 'clin-a', limit: 5).first;
      expect(rows.length, 5);
    });
  });
}
