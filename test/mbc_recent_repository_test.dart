import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/mbc/mbc_recent_repository.dart';

void main() {
  group('MbcRecentRepository', () {
    late FakeFirebaseFirestore db;
    late MbcRecentRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = MbcRecentRepository(db: db);
    });

    test('watchRecent scopes to clinic_id + orders desc by created_at', () async {
      final now = DateTime(2026, 6, 30, 10);
      await db.collection('mbc_dispatch').add({
        'clinic_id': 'clin-a',
        'scale_id': 'phq9',
        'patient_id': 'pt-1',
        'form_url': 'https://ex.com/1',
        'expires_at_millis': now
            .add(const Duration(days: 3))
            .millisecondsSinceEpoch,
        'created_at': Timestamp.fromDate(now),
      });
      await db.collection('mbc_dispatch').add({
        'clinic_id': 'clin-a',
        'scale_id': 'gad7',
        'patient_id': 'pt-2',
        'form_url': 'https://ex.com/2',
        'expires_at_millis': now
            .add(const Duration(days: 3))
            .millisecondsSinceEpoch,
        'created_at': Timestamp.fromDate(now.add(const Duration(hours: 2))),
      });
      // A row on a DIFFERENT clinic — must not leak.
      await db.collection('mbc_dispatch').add({
        'clinic_id': 'clin-b',
        'scale_id': 'phq9',
        'patient_id': 'pt-3',
        'form_url': 'https://ex.com/3',
        'expires_at_millis': 0,
        'created_at': Timestamp.fromDate(now.add(const Duration(hours: 5))),
      });

      final rows = await repo.watchRecent(clinicId: 'clin-a').first;
      expect(rows.length, 2);
      expect(rows.first.scaleId, 'gad7', reason: 'newest first');
      expect(rows.last.scaleId, 'phq9');
      expect(
        rows.every((r) => r.patientId != 'pt-3'),
        isTrue,
        reason: 'clinic-b row must not appear for clinic-a',
      );
    });

    test('submitted flag flips true once submitted_at is set', () async {
      await db.collection('mbc_dispatch').add({
        'clinic_id': 'clin-a',
        'scale_id': 'phq9',
        'patient_id': 'pt-1',
        'form_url': 'https://ex.com/1',
        'expires_at_millis': 0,
        'created_at': Timestamp.fromDate(DateTime(2026, 6, 30, 10)),
        'submitted_at': Timestamp.fromDate(DateTime(2026, 6, 30, 11)),
      });
      final rows = await repo.watchRecent(clinicId: 'clin-a').first;
      expect(rows.single.submitted, isTrue);
      expect(rows.single.submittedAt, isNotNull);
    });

    test('watchRecent honours the limit', () async {
      final base = DateTime(2026, 6, 30, 10);
      for (var i = 0; i < 15; i++) {
        await db.collection('mbc_dispatch').add({
          'clinic_id': 'clin-a',
          'scale_id': 'phq9',
          'patient_id': 'pt-$i',
          'form_url': 'https://ex.com/$i',
          'expires_at_millis': 0,
          'created_at': Timestamp.fromDate(base.add(Duration(hours: i))),
        });
      }
      final rows = await repo.watchRecent(clinicId: 'clin-a', limit: 5).first;
      expect(rows.length, 5);
    });
  });
}
