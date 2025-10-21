import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_management_models.dart';

class MedicationManagementService {
  static final MedicationManagementService _instance = MedicationManagementService._internal();
  factory MedicationManagementService() => _instance;
  MedicationManagementService._internal();

  final List<MedicationPrescription> _prescriptions = [];
  final List<MedicationInteraction> _interactions = [];
  final List<MedicationMonitoring> _monitoring = [];
  final List<MedicationAdherence> _adherence = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadPrescriptions();
    await _loadInteractions();
    await _loadMonitoring();
    await _loadAdherence();
  }

  // Load prescriptions from storage
  Future<void> _loadPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prescriptionsJson = prefs.getStringList('medication_prescriptions') ?? [];
      _prescriptions.clear();
      
      for (final prescriptionJson in prescriptionsJson) {
        final prescription = MedicationPrescription.fromJson(jsonDecode(prescriptionJson));
        _prescriptions.add(prescription);
      }
    } catch (e) {
      print('Error loading medication prescriptions: $e');
      _prescriptions.clear();
    }
  }

  // Save prescriptions to storage
  Future<void> _savePrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prescriptionsJson = _prescriptions
          .map((prescription) => jsonEncode(prescription.toJson()))
          .toList();
      await prefs.setStringList('medication_prescriptions', prescriptionsJson);
    } catch (e) {
      print('Error saving medication prescriptions: $e');
    }
  }

  // Load interactions from storage
  Future<void> _loadInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getStringList('medication_interactions') ?? [];
      _interactions.clear();
      
      for (final interactionJson in interactionsJson) {
        final interaction = MedicationInteraction.fromJson(jsonDecode(interactionJson));
        _interactions.add(interaction);
      }
    } catch (e) {
      print('Error loading medication interactions: $e');
      _interactions.clear();
    }
  }

  // Save interactions to storage
  Future<void> _saveInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = _interactions
          .map((interaction) => jsonEncode(interaction.toJson()))
          .toList();
      await prefs.setStringList('medication_interactions', interactionsJson);
    } catch (e) {
      print('Error saving medication interactions: $e');
    }
  }

  // Load monitoring from storage
  Future<void> _loadMonitoring() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final monitoringJson = prefs.getStringList('medication_monitoring') ?? [];
      _monitoring.clear();
      
      for (final monitoringRecordJson in monitoringJson) {
        final monitoringRecord = MedicationMonitoring.fromJson(jsonDecode(monitoringRecordJson));
        _monitoring.add(monitoringRecord);
      }
    } catch (e) {
      print('Error loading medication monitoring: $e');
      _monitoring.clear();
    }
  }

  // Save monitoring to storage
  Future<void> _saveMonitoring() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final monitoringJson = _monitoring
          .map((monitoringRecord) => jsonEncode(monitoringRecord.toJson()))
          .toList();
      await prefs.setStringList('medication_monitoring', monitoringJson);
    } catch (e) {
      print('Error saving medication monitoring: $e');
    }
  }

  // Load adherence from storage
  Future<void> _loadAdherence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adherenceJson = prefs.getStringList('medication_adherence') ?? [];
      _adherence.clear();
      
      for (final adherenceRecordJson in adherenceJson) {
        final adherenceRecord = MedicationAdherence.fromJson(jsonDecode(adherenceRecordJson));
        _adherence.add(adherenceRecord);
      }
    } catch (e) {
      print('Error loading medication adherence: $e');
      _adherence.clear();
    }
  }

  // Save adherence to storage
  Future<void> _saveAdherence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adherenceJson = _adherence
          .map((adherenceRecord) => jsonEncode(adherenceRecord.toJson()))
          .toList();
      await prefs.setStringList('medication_adherence', adherenceJson);
    } catch (e) {
      print('Error saving medication adherence: $e');
    }
  }

  // Prescribe medication
  Future<MedicationPrescription> prescribeMedication({
    required String patientId,
    required String psychiatristId,
    required String medicationName,
    required String genericName,
    required String dosage,
    required String frequency,
    required String route,
    required String duration,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    String? sideEffects,
    String? contraindications,
    String? monitoring,
    String? notes,
  }) async {
    final prescription = MedicationPrescription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      psychiatristId: psychiatristId,
      medicationName: medicationName,
      genericName: genericName,
      dosage: dosage,
      frequency: frequency,
      route: route,
      duration: duration,
      prescribedAt: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      instructions: instructions,
      sideEffects: sideEffects,
      contraindications: contraindications,
      monitoring: monitoring,
      notes: notes,
    );

    _prescriptions.add(prescription);
    await _savePrescriptions();

    // Check for interactions
    await _checkMedicationInteractions(prescription);

    return prescription;
  }

  // Check medication interactions
  Future<void> _checkMedicationInteractions(MedicationPrescription prescription) async {
    final patientPrescriptions = _prescriptions
        .where((p) => p.patientId == prescription.patientId && p.isActive)
        .toList();

    for (final existingPrescription in patientPrescriptions) {
      if (existingPrescription.id != prescription.id) {
        final interaction = await _detectInteraction(
          prescription,
          existingPrescription,
        );
        
        if (interaction != null) {
          _interactions.add(interaction);
          await _saveInteractions();
        }
      }
    }
  }

  // Detect interaction between two medications
  Future<MedicationInteraction?> _detectInteraction(
    MedicationPrescription prescription1,
    MedicationPrescription prescription2,
  ) async {
    // This would typically involve checking against a drug interaction database
    // For demo purposes, we'll simulate some common interactions
    
    final interactionMap = {
      'fluoxetine': {
        'tramadol': {
          'severity': InteractionSeverity.major,
          'description': 'Serotonin syndrome risk',
          'mechanism': 'Both increase serotonin levels',
          'clinicalSignificance': 'High risk of serotonin syndrome',
          'management': 'Monitor for serotonin syndrome symptoms',
        },
        'warfarin': {
          'severity': InteractionSeverity.moderate,
          'description': 'Increased bleeding risk',
          'mechanism': 'Fluoxetine inhibits warfarin metabolism',
          'clinicalSignificance': 'Increased INR and bleeding risk',
          'management': 'Monitor INR closely',
        },
      },
      'lithium': {
        'furosemide': {
          'severity': InteractionSeverity.major,
          'description': 'Increased lithium toxicity risk',
          'mechanism': 'Furosemide increases lithium reabsorption',
          'clinicalSignificance': 'High risk of lithium toxicity',
          'management': 'Monitor lithium levels closely',
        },
      },
    };

    final med1 = prescription1.genericName.toLowerCase();
    final med2 = prescription2.genericName.toLowerCase();

    if (interactionMap.containsKey(med1) && interactionMap[med1]!.containsKey(med2)) {
      final interactionData = interactionMap[med1]![med2]!;
      
      return MedicationInteraction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        medication1Id: prescription1.id,
        medication2Id: prescription2.id,
        medication1Name: prescription1.medicationName,
        medication2Name: prescription2.medicationName,
        severity: interactionData['severity'] as InteractionSeverity,
        description: interactionData['description'] as String,
        mechanism: interactionData['mechanism'] as String,
        clinicalSignificance: interactionData['clinicalSignificance'] as String,
        management: interactionData['management'] as String,
        detectedAt: DateTime.now(),
        detectedBy: 'system',
      );
    }

    return null;
  }

  // Record medication monitoring
  Future<MedicationMonitoring> recordMonitoring({
    required String prescriptionId,
    required String patientId,
    required String psychiatristId,
    required MonitoringType type,
    required String parameter,
    required String value,
    required String unit,
    String? notes,
    String? actionTaken,
  }) async {
    final monitoring = MedicationMonitoring(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      prescriptionId: prescriptionId,
      patientId: patientId,
      psychiatristId: psychiatristId,
      type: type,
      parameter: parameter,
      value: value,
      unit: unit,
      measuredAt: DateTime.now(),
      notes: notes,
      actionTaken: actionTaken,
    );

    _monitoring.add(monitoring);
    await _saveMonitoring();

    return monitoring;
  }

  // Record medication adherence
  Future<MedicationAdherence> recordAdherence({
    required String prescriptionId,
    required String patientId,
    required DateTime date,
    required bool taken,
    String? reason,
    String? notes,
  }) async {
    final adherence = MedicationAdherence(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      prescriptionId: prescriptionId,
      patientId: patientId,
      date: date,
      taken: taken,
      reason: reason,
      notes: notes,
    );

    _adherence.add(adherence);
    await _saveAdherence();

    return adherence;
  }

  // Get prescriptions for patient
  List<MedicationPrescription> getPrescriptionsForPatient(String patientId) {
    return _prescriptions
        .where((prescription) => prescription.patientId == patientId)
        .toList()
        ..sort((a, b) => b.prescribedAt.compareTo(a.prescribedAt));
  }

  // Get active prescriptions for patient
  List<MedicationPrescription> getActivePrescriptionsForPatient(String patientId) {
    return _prescriptions
        .where((prescription) => 
            prescription.patientId == patientId && 
            prescription.isActive)
        .toList()
        ..sort((a, b) => b.prescribedAt.compareTo(a.prescribedAt));
  }

  // Get prescriptions for psychiatrist
  List<MedicationPrescription> getPrescriptionsForPsychiatrist(String psychiatristId) {
    return _prescriptions
        .where((prescription) => prescription.psychiatristId == psychiatristId)
        .toList()
        ..sort((a, b) => b.prescribedAt.compareTo(a.prescribedAt));
  }

  // Get prescriptions needing review
  List<MedicationPrescription> getPrescriptionsNeedingReview() {
    return _prescriptions
        .where((prescription) => prescription.needsReview)
        .toList()
        ..sort((a, b) => a.endDate?.compareTo(b.endDate ?? DateTime.now()) ?? 0);
  }

  // Get interactions for patient
  List<MedicationInteraction> getInteractionsForPatient(String patientId) {
    final patientPrescriptions = _prescriptions
        .where((p) => p.patientId == patientId)
        .map((p) => p.id)
        .toSet();

    return _interactions
        .where((interaction) => 
            patientPrescriptions.contains(interaction.medication1Id) ||
            patientPrescriptions.contains(interaction.medication2Id))
        .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  // Get severe interactions for patient
  List<MedicationInteraction> getSevereInteractionsForPatient(String patientId) {
    return getInteractionsForPatient(patientId)
        .where((interaction) => interaction.isSevere)
        .toList();
  }

  // Get monitoring for prescription
  List<MedicationMonitoring> getMonitoringForPrescription(String prescriptionId) {
    return _monitoring
        .where((monitoring) => monitoring.prescriptionId == prescriptionId)
        .toList()
        ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
  }

  // Get adherence for prescription
  List<MedicationAdherence> getAdherenceForPrescription(String prescriptionId) {
    return _adherence
        .where((adherence) => adherence.prescriptionId == prescriptionId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Calculate adherence rate
  double calculateAdherenceRate(String prescriptionId) {
    final adherenceRecords = getAdherenceForPrescription(prescriptionId);
    if (adherenceRecords.isEmpty) return 0.0;

    final takenCount = adherenceRecords.where((record) => record.taken).length;
    return (takenCount / adherenceRecords.length) * 100;
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalPrescriptions = _prescriptions.length;
    final activePrescriptions = _prescriptions
        .where((prescription) => prescription.isActive)
        .length;
    final expiredPrescriptions = _prescriptions
        .where((prescription) => prescription.isExpired)
        .length;
    final prescriptionsNeedingReview = _prescriptions
        .where((prescription) => prescription.needsReview)
        .length;

    final totalInteractions = _interactions.length;
    final severeInteractions = _interactions
        .where((interaction) => interaction.isSevere)
        .length;

    final totalMonitoring = _monitoring.length;
    final totalAdherence = _adherence.length;

    return {
      'totalPrescriptions': totalPrescriptions,
      'activePrescriptions': activePrescriptions,
      'expiredPrescriptions': expiredPrescriptions,
      'prescriptionsNeedingReview': prescriptionsNeedingReview,
      'totalInteractions': totalInteractions,
      'severeInteractions': severeInteractions,
      'totalMonitoring': totalMonitoring,
      'totalAdherence': totalAdherence,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_prescriptions.isNotEmpty) return;

    // Add demo prescriptions
    final demoPrescriptions = [
      MedicationPrescription(
        id: 'prescription_001',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        medicationName: 'Prozac',
        genericName: 'fluoxetine',
        dosage: '20mg',
        frequency: 'Once daily',
        route: 'Oral',
        duration: '30 days',
        prescribedAt: DateTime.now().subtract(const Duration(days: 10)),
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        instructions: 'Take with food',
        sideEffects: 'Nausea, headache, insomnia',
        contraindications: 'MAO inhibitors',
        monitoring: 'Monitor for suicidal ideation',
        notes: 'Patient responding well',
      ),
      MedicationPrescription(
        id: 'prescription_002',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        medicationName: 'Xanax',
        genericName: 'alprazolam',
        dosage: '0.5mg',
        frequency: 'Twice daily',
        route: 'Oral',
        duration: '14 days',
        prescribedAt: DateTime.now().subtract(const Duration(days: 5)),
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        instructions: 'Take as needed for anxiety',
        sideEffects: 'Drowsiness, dizziness',
        contraindications: 'Pregnancy, breastfeeding',
        monitoring: 'Monitor for dependence',
        notes: 'Short-term use only',
      ),
    ];

    for (final prescription in demoPrescriptions) {
      _prescriptions.add(prescription);
    }

    await _savePrescriptions();

    // Add demo interactions
    final demoInteractions = [
      MedicationInteraction(
        id: 'interaction_001',
        medication1Id: 'prescription_001',
        medication2Id: 'prescription_002',
        medication1Name: 'Prozac',
        medication2Name: 'Xanax',
        severity: InteractionSeverity.moderate,
        description: 'Increased sedation risk',
        mechanism: 'Both medications have sedative effects',
        clinicalSignificance: 'Increased risk of excessive sedation',
        management: 'Monitor for excessive sedation',
        detectedAt: DateTime.now().subtract(const Duration(days: 5)),
        detectedBy: 'system',
      ),
    ];

    for (final interaction in demoInteractions) {
      _interactions.add(interaction);
    }

    await _saveInteractions();

    // Add demo monitoring
    final demoMonitoring = [
      MedicationMonitoring(
        id: 'monitoring_001',
        prescriptionId: 'prescription_001',
        patientId: '1',
        psychiatristId: 'psychiatrist_001',
        type: MonitoringType.clinical,
        parameter: 'Mood',
        value: 'Improved',
        unit: 'Subjective',
        measuredAt: DateTime.now().subtract(const Duration(days: 3)),
        notes: 'Patient reports improved mood',
        actionTaken: 'Continue current dose',
      ),
    ];

    for (final monitoring in demoMonitoring) {
      _monitoring.add(monitoring);
    }

    await _saveMonitoring();

    // Add demo adherence
    final demoAdherence = [
      MedicationAdherence(
        id: 'adherence_001',
        prescriptionId: 'prescription_001',
        patientId: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        taken: true,
        notes: 'Taken with breakfast',
      ),
      MedicationAdherence(
        id: 'adherence_002',
        prescriptionId: 'prescription_001',
        patientId: '1',
        date: DateTime.now().subtract(const Duration(days: 2)),
        taken: true,
        notes: 'Taken with breakfast',
      ),
      MedicationAdherence(
        id: 'adherence_003',
        prescriptionId: 'prescription_001',
        patientId: '1',
        date: DateTime.now().subtract(const Duration(days: 3)),
        taken: false,
        reason: 'Forgot to take',
        notes: 'Patient forgot to take medication',
      ),
    ];

    for (final adherence in demoAdherence) {
      _adherence.add(adherence);
    }

    await _saveAdherence();

    print('✅ Demo medication prescriptions created: ${demoPrescriptions.length}');
    print('✅ Demo medication interactions created: ${demoInteractions.length}');
    print('✅ Demo medication monitoring created: ${demoMonitoring.length}');
    print('✅ Demo medication adherence created: ${demoAdherence.length}');
  }
}
