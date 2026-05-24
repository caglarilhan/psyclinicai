import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_schema.dart';

/// Mood / sleep / anxiety daily check-in entries for a patient. Three
/// 1–5 Likert scores + a free-text note. Lives under the patient's
/// existing tenant document so the standard security rules apply.
class MoodRepository {
  MoodRepository._();
  static final MoodRepository instance = MoodRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _coll(
          String clinicId, String patientId) =>
      _db
          .collection(FirestoreSchema.clinics)
          .doc(clinicId)
          .collection(FirestoreSchema.patients)
          .doc(patientId)
          .collection('mood');

  /// Newest first. UI can reverse for time-series plots.
  Stream<List<MoodEntry>> watch(String clinicId, String patientId) {
    return _coll(clinicId, patientId)
        .orderBy('completedAt', descending: true)
        .limit(60)
        .snapshots()
        .map((s) =>
            s.docs.map(MoodEntry.fromSnapshot).toList(growable: false));
  }

  Future<String> add({
    required String clinicId,
    required String patientId,
    required int mood,
    required int sleep,
    required int anxiety,
    String notes = '',
    DateTime? completedAt,
  }) async {
    assert(mood >= 1 && mood <= 5);
    assert(sleep >= 1 && sleep <= 5);
    assert(anxiety >= 1 && anxiety <= 5);
    final now = completedAt ?? DateTime.now();
    final ref = await _coll(clinicId, patientId).add({
      'mood': mood,
      'sleep': sleep,
      'anxiety': anxiety,
      'notes': notes,
      'completedAt': Timestamp.fromDate(now),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> delete({
    required String clinicId,
    required String patientId,
    required String entryId,
  }) async {
    await _coll(clinicId, patientId).doc(entryId).delete();
  }
}

class MoodEntry {
  MoodEntry({
    required this.id,
    required this.mood,
    required this.sleep,
    required this.anxiety,
    required this.notes,
    this.completedAt,
  });

  factory MoodEntry.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data() ?? const {};
    return MoodEntry(
      id: snap.id,
      mood: (d['mood'] as num?)?.toInt() ?? 3,
      sleep: (d['sleep'] as num?)?.toInt() ?? 3,
      anxiety: (d['anxiety'] as num?)?.toInt() ?? 3,
      notes: d['notes'] as String? ?? '',
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final int mood;
  final int sleep;
  final int anxiety;
  final String notes;
  final DateTime? completedAt;
}
