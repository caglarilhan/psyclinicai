import 'package:cloud_firestore/cloud_firestore.dart';

import '../assessments/gad7_service.dart';
import '../assessments/phq9_service.dart';
import 'firestore_schema.dart';

/// Persists PHQ-9 / GAD-7 assessment results so a longitudinal outcome
/// dashboard can chart improvement over time (measurement-based care).
class AssessmentRepository {
  AssessmentRepository._();
  static final AssessmentRepository instance = AssessmentRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _coll(
          String clinicId, String patientId) =>
      _db
          .collection(FirestoreSchema.clinics)
          .doc(clinicId)
          .collection(FirestoreSchema.patients)
          .doc(patientId)
          .collection(FirestoreSchema.assessments);

  Stream<List<AssessmentDoc>> watchForPatient(
      String clinicId, String patientId) {
    return _coll(clinicId, patientId)
        .orderBy(FirestoreSchema.fieldCompletedAt, descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map(AssessmentDoc.fromSnapshot).toList(growable: false));
  }

  Future<String> savePhq9({
    required String clinicId,
    required String patientId,
    required String clinicianId,
    required Phq9Result result,
  }) async {
    final ref = await _coll(clinicId, patientId).add({
      FirestoreSchema.fieldAssessmentType: 'phq9',
      FirestoreSchema.fieldClinicianId: clinicianId,
      FirestoreSchema.fieldAnswers: result.answers,
      FirestoreSchema.fieldScore: result.total,
      FirestoreSchema.fieldSeverity: result.severity.name,
      FirestoreSchema.fieldSelfHarmFlag: result.selfHarmFlag,
      FirestoreSchema.fieldCompletedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.fieldCreatedAt: FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> saveGad7({
    required String clinicId,
    required String patientId,
    required String clinicianId,
    required Gad7Result result,
  }) async {
    final ref = await _coll(clinicId, patientId).add({
      FirestoreSchema.fieldAssessmentType: 'gad7',
      FirestoreSchema.fieldClinicianId: clinicianId,
      FirestoreSchema.fieldAnswers: result.answers,
      FirestoreSchema.fieldScore: result.total,
      FirestoreSchema.fieldSeverity: result.severity.name,
      FirestoreSchema.fieldCompletedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.fieldCreatedAt: FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}

class AssessmentDoc {
  AssessmentDoc({
    required this.id,
    required this.type,
    required this.score,
    required this.severity,
    required this.answers,
    this.selfHarmFlag = false,
    this.completedAt,
  });

  factory AssessmentDoc.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data() ?? const {};
    final rawAnswers = d[FirestoreSchema.fieldAnswers];
    return AssessmentDoc(
      id: snap.id,
      type: d[FirestoreSchema.fieldAssessmentType] as String? ?? '',
      score: (d[FirestoreSchema.fieldScore] as num?)?.toInt() ?? 0,
      severity: d[FirestoreSchema.fieldSeverity] as String? ?? '',
      selfHarmFlag: d[FirestoreSchema.fieldSelfHarmFlag] as bool? ?? false,
      answers: rawAnswers is List
          ? rawAnswers.map((e) => (e as num).toInt()).toList(growable: false)
          : const [],
      completedAt:
          (d[FirestoreSchema.fieldCompletedAt] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final String type;
  final int score;
  final String severity;
  final List<int> answers;
  final bool selfHarmFlag;
  final DateTime? completedAt;
}
