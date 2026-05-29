import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_schema.dart';

/// Patient CRUD scoped to a single clinic. Caller supplies clinicId from the
/// authenticated session.
class PatientRepository {
  PatientRepository._();
  static final PatientRepository instance = PatientRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _coll(String clinicId) => _db
      .collection(FirestoreSchema.clinics)
      .doc(clinicId)
      .collection(FirestoreSchema.patients);

  Stream<List<PatientDoc>> watchAll(String clinicId) {
    return _coll(clinicId)
        .orderBy(FirestoreSchema.fieldCreatedAt, descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(PatientDoc.fromSnapshot).toList(growable: false),
        );
  }

  Future<PatientDoc?> get(String clinicId, String patientId) async {
    final s = await _coll(clinicId).doc(patientId).get();
    if (!s.exists) return null;
    return PatientDoc.fromSnapshot(s);
  }

  /// Live stream of all patients in a clinic, newest first.
  Stream<List<PatientDoc>> watch(String clinicId) {
    return _coll(clinicId)
        .orderBy(FirestoreSchema.fieldUpdatedAt, descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(PatientDoc.fromSnapshot).toList(growable: false),
        );
  }

  Future<String> create(String clinicId, PatientDraft draft) async {
    final now = FieldValue.serverTimestamp();
    final ref = await _coll(clinicId).add({
      FirestoreSchema.fieldFullName: draft.fullName,
      FirestoreSchema.fieldEmail: draft.email,
      FirestoreSchema.fieldPhone: draft.phone,
      FirestoreSchema.fieldDob: draft.dob != null
          ? Timestamp.fromDate(draft.dob!)
          : null,
      FirestoreSchema.fieldMemberId: draft.memberId,
      FirestoreSchema.fieldInsurer: draft.insurer,
      FirestoreSchema.fieldAddressLine1: draft.addressLine1,
      FirestoreSchema.fieldAddressLine2: draft.addressLine2,
      FirestoreSchema.fieldNotes: draft.notes,
      FirestoreSchema.fieldCreatedAt: now,
      FirestoreSchema.fieldUpdatedAt: now,
    });
    return ref.id;
  }

  Future<void> update(
    String clinicId,
    String patientId,
    PatientDraft draft,
  ) async {
    await _coll(clinicId).doc(patientId).update({
      FirestoreSchema.fieldFullName: draft.fullName,
      FirestoreSchema.fieldEmail: draft.email,
      FirestoreSchema.fieldPhone: draft.phone,
      FirestoreSchema.fieldDob: draft.dob != null
          ? Timestamp.fromDate(draft.dob!)
          : null,
      FirestoreSchema.fieldMemberId: draft.memberId,
      FirestoreSchema.fieldInsurer: draft.insurer,
      FirestoreSchema.fieldAddressLine1: draft.addressLine1,
      FirestoreSchema.fieldAddressLine2: draft.addressLine2,
      FirestoreSchema.fieldNotes: draft.notes,
      FirestoreSchema.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String clinicId, String patientId) async {
    await _coll(clinicId).doc(patientId).delete();
  }

  /// Upsert a patient under a fixed [patientId]. Useful when the caller
  /// already has a stable identifier (e.g. legacy demo data).
  Future<void> upsert(
    String clinicId,
    String patientId,
    PatientDraft draft,
  ) async {
    final now = FieldValue.serverTimestamp();
    await _coll(clinicId).doc(patientId).set({
      FirestoreSchema.fieldFullName: draft.fullName,
      FirestoreSchema.fieldEmail: draft.email,
      FirestoreSchema.fieldPhone: draft.phone,
      FirestoreSchema.fieldDob: draft.dob != null
          ? Timestamp.fromDate(draft.dob!)
          : null,
      FirestoreSchema.fieldMemberId: draft.memberId,
      FirestoreSchema.fieldInsurer: draft.insurer,
      FirestoreSchema.fieldAddressLine1: draft.addressLine1,
      FirestoreSchema.fieldAddressLine2: draft.addressLine2,
      FirestoreSchema.fieldNotes: draft.notes,
      FirestoreSchema.fieldUpdatedAt: now,
      FirestoreSchema.fieldCreatedAt: now,
    }, SetOptions(merge: true));
  }
}

class PatientDraft {
  PatientDraft({
    required this.fullName,
    this.email = '',
    this.phone = '',
    this.dob,
    this.memberId = '',
    this.insurer = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.notes = '',
  });

  final String fullName;
  final String email;
  final String phone;
  final DateTime? dob;
  final String memberId;
  final String insurer;
  final String addressLine1;
  final String addressLine2;
  final String notes;
}

class PatientDoc {
  PatientDoc({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.dob,
    required this.memberId,
    required this.insurer,
    required this.addressLine1,
    required this.addressLine2,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientDoc.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data() ?? const {};
    return PatientDoc(
      id: snap.id,
      fullName: d[FirestoreSchema.fieldFullName] as String? ?? '',
      email: d[FirestoreSchema.fieldEmail] as String? ?? '',
      phone: d[FirestoreSchema.fieldPhone] as String? ?? '',
      dob: (d[FirestoreSchema.fieldDob] as Timestamp?)?.toDate(),
      memberId: d[FirestoreSchema.fieldMemberId] as String? ?? '',
      insurer: d[FirestoreSchema.fieldInsurer] as String? ?? '',
      addressLine1: d[FirestoreSchema.fieldAddressLine1] as String? ?? '',
      addressLine2: d[FirestoreSchema.fieldAddressLine2] as String? ?? '',
      notes: d[FirestoreSchema.fieldNotes] as String? ?? '',
      createdAt: (d[FirestoreSchema.fieldCreatedAt] as Timestamp?)?.toDate(),
      updatedAt: (d[FirestoreSchema.fieldUpdatedAt] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime? dob;
  final String memberId;
  final String insurer;
  final String addressLine1;
  final String addressLine2;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
