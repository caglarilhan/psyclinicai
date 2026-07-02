import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  /// Null when the source row has no `created_at` timestamp — this is a
  /// schema-drift signal, not a legitimate value. The UI renders "—" in
  /// that case; a `DateTime(1970)` sentinel would sort the row to the
  /// bottom of a `desc` list and hide it silently.
  final DateTime? createdAt;

  static NoShowRecentRow fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data();
    return NoShowRecentRow(
      id: snap.id,
      appointmentId: (d['appointment_id'] as String?) ?? '',
      patientId: (d['patient_id'] as String?) ?? '',
      probability: ((d['probability'] as num?) ?? 0).toDouble(),
      tier: _tierFromString((d['tier'] as String?) ?? 'low', snap.id),
      modelVersion: (d['model_version'] as String?) ?? '',
      createdAt: (d['created_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Downgrading a real "high" prediction to "low" because of a schema
  /// mismatch would silence a clinical alert. Debug builds log the
  /// unknown value so a server-side tier rename (e.g. adding `critical`)
  /// is caught in test/staging before it ships.
  static NoShowRiskTier _tierFromString(String v, String rowId) {
    switch (v) {
      case 'high':
        return NoShowRiskTier.high;
      case 'medium':
        return NoShowRiskTier.medium;
      case 'low':
        return NoShowRiskTier.low;
      default:
        assert(() {
          debugPrint(
            '[noshow_recent_repository] unknown tier "$v" on row $rowId '
            '— defaulting to `low`; server-side rename may need a sync.',
          );
          return true;
        }());
        return NoShowRiskTier.low;
    }
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
