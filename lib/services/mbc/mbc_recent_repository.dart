import 'package:cloud_firestore/cloud_firestore.dart';

/// One row surfaced by the MBC dashboard stream. Only fields the UI
/// renders are captured; everything else stays behind the admin SDK
/// writer for audit.
class MbcRecentRow {
  const MbcRecentRow({
    required this.id,
    required this.scaleId,
    required this.patientId,
    required this.createdAt,
    required this.submittedAt,
    required this.expiresAtMillis,
  });

  final String id;
  final String scaleId;
  final String patientId;

  /// Server-timestamped creation time (from mbcDispatchLink).
  final DateTime createdAt;

  /// Flipped by `mbcSubmitAssessment` when the patient posts the form.
  /// Null while the link is still outstanding.
  final DateTime? submittedAt;

  /// Link expiry — clients render "expires in Nh" using this.
  final int expiresAtMillis;

  bool get submitted => submittedAt != null;

  static MbcRecentRow fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data();
    return MbcRecentRow(
      id: snap.id,
      scaleId: (d['scale_id'] as String?) ?? '',
      patientId: (d['patient_id'] as String?) ?? '',
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime(1970),
      submittedAt: (d['submitted_at'] as Timestamp?)?.toDate(),
      expiresAtMillis: (d['expires_at_millis'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Read-only Firestore stream over the clinician's recent MBC
/// dispatches. Backed by the `mbc_dispatch` collection secured in
/// `firestore.rules` (client can read own rows by `clinic_id`).
class MbcRecentRepository {
  MbcRecentRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<MbcRecentRow>> watchRecent({
    required String clinicId,
    int limit = 10,
  }) {
    return _db
        .collection('mbc_dispatch')
        .where('clinic_id', isEqualTo: clinicId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs.map(MbcRecentRow.fromSnapshot).toList(growable: false),
        );
  }
}
