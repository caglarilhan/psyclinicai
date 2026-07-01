import 'package:cloud_firestore/cloud_firestore.dart';

import 'noshow_feature_catalog.dart';

/// One row surfaced by the no-show dashboard stream.
class NoShowRecentRow {
  const NoShowRecentRow({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.probability,
    required this.tier,
    required this.modelVersion,
    required this.createdAt,
  });

  final String id;
  final String appointmentId;
  final String patientId;
  final double probability;
  final NoShowRiskTier tier;
  final String modelVersion;
  final DateTime createdAt;

  static NoShowRecentRow fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data();
    return NoShowRecentRow(
      id: snap.id,
      appointmentId: (d['appointment_id'] as String?) ?? '',
      patientId: (d['patient_id'] as String?) ?? '',
      probability: ((d['probability'] as num?) ?? 0).toDouble(),
      tier: _tierFromString((d['tier'] as String?) ?? 'low'),
      modelVersion: (d['model_version'] as String?) ?? '',
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }
}

NoShowRiskTier _tierFromString(String v) {
  switch (v) {
    case 'high':
      return NoShowRiskTier.high;
    case 'medium':
      return NoShowRiskTier.medium;
    default:
      return NoShowRiskTier.low;
  }
}

/// Read-only Firestore stream over the clinician's recent no-show
/// predictions. Backed by the `noshow_predictions` collection secured
/// in `firestore.rules` (client can read own rows by `clinic_id`).
class NoShowRecentRepository {
  NoShowRecentRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<NoShowRecentRow>> watchRecent({
    required String clinicId,
    int limit = 10,
  }) {
    return _db
        .collection('noshow_predictions')
        .where('clinic_id', isEqualTo: clinicId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) =>
              s.docs.map(NoShowRecentRow.fromSnapshot).toList(growable: false),
        );
  }
}
