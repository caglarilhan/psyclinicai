import 'package:cloud_firestore/cloud_firestore.dart';

import '../copilot/soap_generator_service.dart';
import 'firestore_schema.dart';

/// Session + note persistence. A session has one or more notes (drafts /
/// finalized). Notes carry SOAP/DAP/BIRP markdown and AI metadata.
class SessionRepository {
  SessionRepository._();
  static final SessionRepository instance = SessionRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessions(
    String clinicId,
    String patientId,
  ) => _db
      .collection(FirestoreSchema.clinics)
      .doc(clinicId)
      .collection(FirestoreSchema.patients)
      .doc(patientId)
      .collection(FirestoreSchema.sessions);

  Stream<List<SessionDoc>> watchForPatient(String clinicId, String patientId) {
    return _sessions(clinicId, patientId)
        .orderBy(FirestoreSchema.fieldStartedAt, descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(SessionDoc.fromSnapshot).toList(growable: false),
        );
  }

  Future<String> createSession({
    required String clinicId,
    required String patientId,
    required String clinicianId,
    required DateTime startedAt,
  }) async {
    final ref = await _sessions(clinicId, patientId).add({
      FirestoreSchema.fieldClinicianId: clinicianId,
      FirestoreSchema.fieldStartedAt: Timestamp.fromDate(startedAt),
      FirestoreSchema.fieldCreatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> endSession({
    required String clinicId,
    required String patientId,
    required String sessionId,
    required DateTime endedAt,
    required int durationMinutes,
  }) async {
    await _sessions(clinicId, patientId).doc(sessionId).update({
      FirestoreSchema.fieldEndedAt: Timestamp.fromDate(endedAt),
      FirestoreSchema.fieldDurationMinutes: durationMinutes,
      FirestoreSchema.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<String> saveNote({
    required String clinicId,
    required String patientId,
    required String sessionId,
    required SoapNote note,
    String transcript = '',
  }) async {
    final ref = await _sessions(clinicId, patientId)
        .doc(sessionId)
        .collection(FirestoreSchema.notes)
        .add({
          FirestoreSchema.fieldFormat: note.format.id,
          FirestoreSchema.fieldMarkdown: note.rawMarkdown,
          FirestoreSchema.fieldTranscript: transcript,
          FirestoreSchema.fieldFlaggedRisk: note.flaggedRisk,
          FirestoreSchema.fieldGeneratedByAi: true,
          FirestoreSchema.fieldCreatedAt: FieldValue.serverTimestamp(),
          FirestoreSchema.fieldUpdatedAt: FieldValue.serverTimestamp(),
        });
    return ref.id;
  }
}

extension SoapFormatId on SoapFormat {
  String get id => name;
}

class SessionDoc {
  SessionDoc({
    required this.id,
    required this.clinicianId,
    this.startedAt,
    this.endedAt,
    this.durationMinutes,
  });

  factory SessionDoc.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data() ?? const {};
    return SessionDoc(
      id: snap.id,
      clinicianId: d[FirestoreSchema.fieldClinicianId] as String? ?? '',
      startedAt: (d[FirestoreSchema.fieldStartedAt] as Timestamp?)?.toDate(),
      endedAt: (d[FirestoreSchema.fieldEndedAt] as Timestamp?)?.toDate(),
      durationMinutes: d[FirestoreSchema.fieldDurationMinutes] as int?,
    );
  }

  final String id;
  final String clinicianId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
}
