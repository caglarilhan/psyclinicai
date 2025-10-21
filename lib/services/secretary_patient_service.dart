import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/secretary_patient_models.dart';
import '../models/patient.dart';

class SecretaryPatientService {
  static final SecretaryPatientService _instance = SecretaryPatientService._internal();
  factory SecretaryPatientService() => _instance;
  SecretaryPatientService._internal();

  final List<PatientRecord> _patientRecords = [];
  final List<RecordTemplate> _recordTemplates = [];
  final List<PatientDocument> _patientDocuments = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadPatientRecords();
    await _loadRecordTemplates();
    await _loadPatientDocuments();
  }

  // Load patient records from storage
  Future<void> _loadPatientRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList('secretary_patient_records') ?? [];
      _patientRecords.clear();
      
      for (final recordJson in recordsJson) {
        final record = PatientRecord.fromJson(jsonDecode(recordJson));
        _patientRecords.add(record);
      }
    } catch (e) {
      print('Error loading patient records: $e');
      _patientRecords.clear();
    }
  }

  // Save patient records to storage
  Future<void> _savePatientRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = _patientRecords
          .map((record) => jsonEncode(record.toJson()))
          .toList();
      await prefs.setStringList('secretary_patient_records', recordsJson);
    } catch (e) {
      print('Error saving patient records: $e');
    }
  }

  // Load record templates from storage
  Future<void> _loadRecordTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('secretary_record_templates') ?? [];
      _recordTemplates.clear();
      
      for (final templateJson in templatesJson) {
        final template = RecordTemplate.fromJson(jsonDecode(templateJson));
        _recordTemplates.add(template);
      }
    } catch (e) {
      print('Error loading record templates: $e');
      _recordTemplates.clear();
    }
  }

  // Save record templates to storage
  Future<void> _saveRecordTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = _recordTemplates
          .map((template) => jsonEncode(template.toJson()))
          .toList();
      await prefs.setStringList('secretary_record_templates', templatesJson);
    } catch (e) {
      print('Error saving record templates: $e');
    }
  }

  // Load patient documents from storage
  Future<void> _loadPatientDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getStringList('secretary_patient_documents') ?? [];
      _patientDocuments.clear();
      
      for (final documentJson in documentsJson) {
        final document = PatientDocument.fromJson(jsonDecode(documentJson));
        _patientDocuments.add(document);
      }
    } catch (e) {
      print('Error loading patient documents: $e');
      _patientDocuments.clear();
    }
  }

  // Save patient documents to storage
  Future<void> _savePatientDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = _patientDocuments
          .map((document) => jsonEncode(document.toJson()))
          .toList();
      await prefs.setStringList('secretary_patient_documents', documentsJson);
    } catch (e) {
      print('Error saving patient documents: $e');
    }
  }

  // Create patient record
  Future<PatientRecord> createPatientRecord({
    required String patientId,
    required String secretaryId,
    required RecordType type,
    required String title,
    required String content,
    Map<String, dynamic>? metadata,
    PriorityLevel priority = PriorityLevel.normal,
    bool isConfidential = false,
    String? createdBy,
  }) async {
    final record = PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      secretaryId: secretaryId,
      type: type,
      title: title,
      content: content,
      metadata: metadata,
      priority: priority,
      isConfidential: isConfidential,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _patientRecords.add(record);
    await _savePatientRecords();

    // Add to history
    await _addRecordHistory(
      record.id,
      'created',
      'Kayıt oluşturuldu',
      createdBy ?? secretaryId,
    );

    return record;
  }

  // Update patient record
  Future<bool> updatePatientRecord(PatientRecord updatedRecord, String updatedBy) async {
    try {
      final index = _patientRecords.indexWhere((record) => record.id == updatedRecord.id);
      if (index == -1) return false;

      final oldRecord = _patientRecords[index];
      _patientRecords[index] = updatedRecord.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );
      
      await _savePatientRecords();

      // Add to history
      await _addRecordHistory(
        updatedRecord.id,
        'updated',
        'Kayıt güncellendi',
        updatedBy,
      );

      return true;
    } catch (e) {
      print('Error updating patient record: $e');
      return false;
    }
  }

  // Delete patient record
  Future<bool> deletePatientRecord(String recordId, String deletedBy) async {
    try {
      final index = _patientRecords.indexWhere((record) => record.id == recordId);
      if (index == -1) return false;

      _patientRecords.removeAt(index);
      await _savePatientRecords();

      // Add to history
      await _addRecordHistory(
        recordId,
        'deleted',
        'Kayıt silindi',
        deletedBy,
      );

      return true;
    } catch (e) {
      print('Error deleting patient record: $e');
      return false;
    }
  }

  // Add patient document
  Future<PatientDocument> addPatientDocument({
    required String patientId,
    required String recordId,
    required DocumentType type,
    required String fileName,
    required String filePath,
    required int fileSize,
    required String mimeType,
    String? description,
    bool isEncrypted = false,
    required String uploadedBy,
    Map<String, dynamic>? metadata,
  }) async {
    final document = PatientDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      recordId: recordId,
      type: type,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      description: description,
      isEncrypted: isEncrypted,
      uploadedAt: DateTime.now(),
      uploadedBy: uploadedBy,
      metadata: metadata,
    );

    _patientDocuments.add(document);
    await _savePatientDocuments();

    return document;
  }

  // Remove patient document
  Future<bool> removePatientDocument(String documentId) async {
    try {
      final index = _patientDocuments.indexWhere((doc) => doc.id == documentId);
      if (index == -1) return false;

      _patientDocuments.removeAt(index);
      await _savePatientDocuments();

      return true;
    } catch (e) {
      print('Error removing patient document: $e');
      return false;
    }
  }

  // Create record template
  Future<RecordTemplate> createRecordTemplate({
    required String name,
    required RecordType type,
    required String description,
    required Map<String, dynamic> fields,
    required String createdBy,
  }) async {
    final template = RecordTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      description: description,
      fields: fields,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _recordTemplates.add(template);
    await _saveRecordTemplates();

    return template;
  }

  // Update record template
  Future<bool> updateRecordTemplate(RecordTemplate updatedTemplate) async {
    try {
      final index = _recordTemplates.indexWhere((template) => template.id == updatedTemplate.id);
      if (index == -1) return false;

      _recordTemplates[index] = updatedTemplate;
      await _saveRecordTemplates();

      return true;
    } catch (e) {
      print('Error updating record template: $e');
      return false;
    }
  }

  // Delete record template
  Future<bool> deleteRecordTemplate(String templateId) async {
    try {
      final index = _recordTemplates.indexWhere((template) => template.id == templateId);
      if (index == -1) return false;

      _recordTemplates.removeAt(index);
      await _saveRecordTemplates();

      return true;
    } catch (e) {
      print('Error deleting record template: $e');
      return false;
    }
  }

  // Add record history
  Future<void> _addRecordHistory(String recordId, String action, String description, String performedBy) async {
    final history = RecordHistory(
      id: '${recordId}_${DateTime.now().millisecondsSinceEpoch}',
      recordId: recordId,
      action: action,
      description: description,
      performedBy: performedBy,
      timestamp: DateTime.now(),
    );

    final index = _patientRecords.indexWhere((record) => record.id == recordId);
    if (index != -1) {
      final updatedHistory = List<RecordHistory>.from(_patientRecords[index].history)..add(history);
      _patientRecords[index] = _patientRecords[index].copyWith(history: updatedHistory);
      await _savePatientRecords();
    }
  }

  // Search patients
  List<PatientRecord> searchPatients(PatientSearchCriteria criteria) {
    var results = _patientRecords;

    if (criteria.name != null && criteria.name!.isNotEmpty) {
      results = results.where((record) => 
          record.title.toLowerCase().contains(criteria.name!.toLowerCase()) ||
          record.content.toLowerCase().contains(criteria.name!.toLowerCase())).toList();
    }

    if (criteria.recordType != null) {
      results = results.where((record) => record.type == criteria.recordType).toList();
    }

    if (criteria.priority != null) {
      results = results.where((record) => record.priority == criteria.priority).toList();
    }

    if (criteria.isConfidential != null) {
      results = results.where((record) => record.isConfidential == criteria.isConfidential).toList();
    }

    if (criteria.registrationDateFrom != null) {
      results = results.where((record) => 
          record.createdAt.isAfter(criteria.registrationDateFrom!) ||
          record.createdAt.isAtSameMomentAs(criteria.registrationDateFrom!)).toList();
    }

    if (criteria.registrationDateTo != null) {
      results = results.where((record) => 
          record.createdAt.isBefore(criteria.registrationDateTo!) ||
          record.createdAt.isAtSameMomentAs(criteria.registrationDateTo!)).toList();
    }

    return results..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get records for patient
  List<PatientRecord> getRecordsForPatient(String patientId) {
    return _patientRecords
        .where((record) => record.patientId == patientId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get records for secretary
  List<PatientRecord> getRecordsForSecretary(String secretaryId) {
    return _patientRecords
        .where((record) => record.secretaryId == secretaryId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get records by type
  List<PatientRecord> getRecordsByType(RecordType type) {
    return _patientRecords
        .where((record) => record.type == type)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get urgent records
  List<PatientRecord> getUrgentRecords() {
    return _patientRecords
        .where((record) => record.priority == PriorityLevel.urgent)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get confidential records
  List<PatientRecord> getConfidentialRecords() {
    return _patientRecords
        .where((record) => record.isConfidential)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get documents for patient
  List<PatientDocument> getDocumentsForPatient(String patientId) {
    return _patientDocuments
        .where((doc) => doc.patientId == patientId)
        .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // Get documents for record
  List<PatientDocument> getDocumentsForRecord(String recordId) {
    return _patientDocuments
        .where((doc) => doc.recordId == recordId)
        .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // Get active templates
  List<RecordTemplate> getActiveTemplates() {
    return _recordTemplates
        .where((template) => template.isActive)
        .toList()
        ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  // Get templates by type
  List<RecordTemplate> getTemplatesByType(RecordType type) {
    return _recordTemplates
        .where((template) => template.type == type && template.isActive)
        .toList()
        ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  // Increment template usage
  Future<void> incrementTemplateUsage(String templateId) async {
    final index = _recordTemplates.indexWhere((template) => template.id == templateId);
    if (index != -1) {
      _recordTemplates[index] = _recordTemplates[index].copyWith(
        usageCount: _recordTemplates[index].usageCount + 1,
      );
      await _saveRecordTemplates();
    }
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalRecords = _patientRecords.length;
    final personalRecords = _patientRecords
        .where((record) => record.type == RecordType.personal)
        .length;
    final medicalRecords = _patientRecords
        .where((record) => record.type == RecordType.medical)
        .length;
    final insuranceRecords = _patientRecords
        .where((record) => record.type == RecordType.insurance)
        .length;
    final emergencyRecords = _patientRecords
        .where((record) => record.type == RecordType.emergency)
        .length;
    final familyRecords = _patientRecords
        .where((record) => record.type == RecordType.family)
        .length;
    final legalRecords = _patientRecords
        .where((record) => record.type == RecordType.legal)
        .length;

    final urgentRecords = _patientRecords
        .where((record) => record.priority == PriorityLevel.urgent)
        .length;
    final confidentialRecords = _patientRecords
        .where((record) => record.isConfidential)
        .length;

    final totalDocuments = _patientDocuments.length;
    final totalTemplates = _recordTemplates.length;
    final activeTemplates = _recordTemplates
        .where((template) => template.isActive)
        .length;

    return {
      'totalRecords': totalRecords,
      'personalRecords': personalRecords,
      'medicalRecords': medicalRecords,
      'insuranceRecords': insuranceRecords,
      'emergencyRecords': emergencyRecords,
      'familyRecords': familyRecords,
      'legalRecords': legalRecords,
      'urgentRecords': urgentRecords,
      'confidentialRecords': confidentialRecords,
      'totalDocuments': totalDocuments,
      'totalTemplates': totalTemplates,
      'activeTemplates': activeTemplates,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_patientRecords.isNotEmpty) return;

    // Add demo patient records
    final demoRecords = [
      PatientRecord(
        id: 'record_001',
        patientId: '1',
        secretaryId: 'secretary_001',
        type: RecordType.personal,
        title: 'Kişisel Bilgiler',
        content: 'Hasta kişisel bilgileri güncellendi. Adres değişikliği kaydedildi.',
        priority: PriorityLevel.normal,
        isConfidential: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'secretary_001',
      ),
      PatientRecord(
        id: 'record_002',
        patientId: '2',
        secretaryId: 'secretary_001',
        type: RecordType.medical,
        title: 'Tıbbi Geçmiş',
        content: 'Hasta tıbbi geçmişi kaydedildi. Önceki tedaviler ve ilaçlar listelendi.',
        priority: PriorityLevel.high,
        isConfidential: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'secretary_001',
      ),
      PatientRecord(
        id: 'record_003',
        patientId: '3',
        secretaryId: 'secretary_001',
        type: RecordType.insurance,
        title: 'Sigorta Bilgileri',
        content: 'SGK bilgileri güncellendi. Poliçe numarası değişti.',
        priority: PriorityLevel.normal,
        isConfidential: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        createdBy: 'secretary_001',
      ),
    ];

    for (final record in demoRecords) {
      _patientRecords.add(record);
    }

    await _savePatientRecords();

    // Add demo record templates
    final demoTemplates = [
      RecordTemplate(
        id: 'template_001',
        name: 'Kişisel Bilgi Şablonu',
        type: RecordType.personal,
        description: 'Hasta kişisel bilgileri için standart şablon',
        fields: {
          'name': 'Ad Soyad',
          'idNumber': 'TC Kimlik No',
          'phone': 'Telefon',
          'address': 'Adres',
          'emergencyContact': 'Acil Durum İletişim',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'admin',
        usageCount: 15,
      ),
      RecordTemplate(
        id: 'template_002',
        name: 'Tıbbi Geçmiş Şablonu',
        type: RecordType.medical,
        description: 'Hasta tıbbi geçmişi için detaylı şablon',
        fields: {
          'previousDiagnoses': 'Önceki Tanılar',
          'medications': 'Kullandığı İlaçlar',
          'allergies': 'Alerjiler',
          'surgeries': 'Geçirilen Ameliyatlar',
          'familyHistory': 'Aile Geçmişi',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        createdBy: 'admin',
        usageCount: 8,
      ),
      RecordTemplate(
        id: 'template_003',
        name: 'Sigorta Bilgi Şablonu',
        type: RecordType.insurance,
        description: 'Sigorta bilgileri için şablon',
        fields: {
          'insuranceType': 'Sigorta Türü',
          'policyNumber': 'Poliçe Numarası',
          'validUntil': 'Geçerlilik Tarihi',
          'coverage': 'Kapsam',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        createdBy: 'admin',
        usageCount: 12,
      ),
    ];

    for (final template in demoTemplates) {
      _recordTemplates.add(template);
    }

    await _saveRecordTemplates();

    // Add demo patient documents
    final demoDocuments = [
      PatientDocument(
        id: 'doc_001',
        patientId: '1',
        recordId: 'record_001',
        type: DocumentType.id,
        fileName: 'kimlik_kopyasi.pdf',
        filePath: '/documents/patient_1/kimlik_kopyasi.pdf',
        fileSize: 1024000,
        mimeType: 'application/pdf',
        description: 'TC Kimlik kartı fotokopisi',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        uploadedBy: 'secretary_001',
      ),
      PatientDocument(
        id: 'doc_002',
        patientId: '2',
        recordId: 'record_002',
        type: DocumentType.medicalReport,
        fileName: 'lab_sonuclari.pdf',
        filePath: '/documents/patient_2/lab_sonuclari.pdf',
        fileSize: 2048000,
        mimeType: 'application/pdf',
        description: 'Laboratuvar sonuçları',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        uploadedBy: 'secretary_001',
      ),
    ];

    for (final document in demoDocuments) {
      _patientDocuments.add(document);
    }

    await _savePatientDocuments();

    print('✅ Demo secretary patient data created:');
    print('   - Patient records: ${demoRecords.length}');
    print('   - Record templates: ${demoTemplates.length}');
    print('   - Patient documents: ${demoDocuments.length}');
  }
}
