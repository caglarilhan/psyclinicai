import 'package:cloud_firestore/cloud_firestore.dart';

import '../billing/superbill_pdf_service.dart';
import 'firestore_schema.dart';

/// Persists superbill metadata so a patient's billing history can be browsed
/// in their chart. PDF storage URL filled in Sprint 5 (Firebase Storage).
class SuperbillRepository {
  SuperbillRepository._();
  static final SuperbillRepository instance = SuperbillRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _coll(
          String clinicId, String patientId) =>
      _db
          .collection(FirestoreSchema.clinics)
          .doc(clinicId)
          .collection(FirestoreSchema.patients)
          .doc(patientId)
          .collection(FirestoreSchema.superbills);

  Stream<List<SuperbillRecordDoc>> watchForPatient(
      String clinicId, String patientId) {
    return _coll(clinicId, patientId)
        .orderBy(FirestoreSchema.fieldServiceDate, descending: true)
        .snapshots()
        .map((s) => s.docs
            .map(SuperbillRecordDoc.fromSnapshot)
            .toList(growable: false));
  }

  Future<String> save({
    required String clinicId,
    required String patientId,
    required String clinicianId,
    required SuperbillData data,
    String pdfUrl = '',
    String status = 'draft',
  }) async {
    final totalCharges =
        data.serviceLines.fold<double>(0, (s, l) => s + l.totalCharge);
    final balanceDue =
        (totalCharges - data.amountPaid).clamp(0.0, double.infinity);

    final ref = await _coll(clinicId, patientId).add({
      FirestoreSchema.fieldClinicianId: clinicianId,
      FirestoreSchema.fieldInvoiceNumber: data.invoiceNumber,
      FirestoreSchema.fieldServiceDate: Timestamp.fromDate(data.serviceDate),
      FirestoreSchema.fieldTotalCharges: totalCharges,
      FirestoreSchema.fieldAmountPaid: data.amountPaid,
      FirestoreSchema.fieldBalanceDue: balanceDue,
      FirestoreSchema.fieldStatus: status,
      FirestoreSchema.fieldDiagnoses: data.diagnoses
          .map((d) => {'code': d.code, 'label': d.label})
          .toList(),
      FirestoreSchema.fieldServiceLines: data.serviceLines
          .map((l) => {
                'date': Timestamp.fromDate(l.date),
                'cptCode': l.cpt.code,
                'cptLabel': l.cpt.shortLabel,
                'units': l.units,
                'chargePerUnit': l.chargePerUnit,
                'totalCharge': l.totalCharge,
                'diagnosisPointers': l.diagnosisPointers,
              })
          .toList(),
      FirestoreSchema.fieldPdfUrl: pdfUrl,
      FirestoreSchema.fieldCreatedAt: FieldValue.serverTimestamp(),
      FirestoreSchema.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}

class SuperbillRecordDoc {
  SuperbillRecordDoc({
    required this.id,
    required this.invoiceNumber,
    required this.totalCharges,
    required this.amountPaid,
    required this.balanceDue,
    required this.status,
    this.serviceDate,
    this.pdfUrl = '',
  });

  factory SuperbillRecordDoc.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final d = snap.data() ?? const {};
    return SuperbillRecordDoc(
      id: snap.id,
      invoiceNumber: d[FirestoreSchema.fieldInvoiceNumber] as String? ?? '',
      totalCharges:
          (d[FirestoreSchema.fieldTotalCharges] as num?)?.toDouble() ?? 0,
      amountPaid:
          (d[FirestoreSchema.fieldAmountPaid] as num?)?.toDouble() ?? 0,
      balanceDue:
          (d[FirestoreSchema.fieldBalanceDue] as num?)?.toDouble() ?? 0,
      status: d[FirestoreSchema.fieldStatus] as String? ?? 'draft',
      serviceDate:
          (d[FirestoreSchema.fieldServiceDate] as Timestamp?)?.toDate(),
      pdfUrl: d[FirestoreSchema.fieldPdfUrl] as String? ?? '',
    );
  }

  final String id;
  final String invoiceNumber;
  final double totalCharges;
  final double amountPaid;
  final double balanceDue;
  final String status;
  final DateTime? serviceDate;
  final String pdfUrl;
}
