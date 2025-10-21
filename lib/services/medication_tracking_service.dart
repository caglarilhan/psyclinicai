import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_tracking_models.dart';

class MedicationTrackingService {
  static final MedicationTrackingService _instance = MedicationTrackingService._internal();
  factory MedicationTrackingService() => _instance;
  MedicationTrackingService._internal();

  final List<MedicationRecord> _medications = [];
  final List<SideEffectRecord> _sideEffects = [];
  final List<MedicationInteraction> _interactions = [];
  final List<MedicationEducation> _educations = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadMedications();
    await _loadSideEffects();
    await _loadInteractions();
    await _loadEducations();
  }

  // Load medications from storage
  Future<void> _loadMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = prefs.getStringList('medication_tracking_medications') ?? [];
      _medications.clear();
      
      for (final medicationJson in medicationsJson) {
        final medication = MedicationRecord.fromJson(jsonDecode(medicationJson));
        _medications.add(medication);
      }
    } catch (e) {
      print('Error loading medications: $e');
      _medications.clear();
    }
  }

  // Save medications to storage
  Future<void> _saveMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = _medications
          .map((medication) => jsonEncode(medication.toJson()))
          .toList();
      await prefs.setStringList('medication_tracking_medications', medicationsJson);
    } catch (e) {
      print('Error saving medications: $e');
    }
  }

  // Load side effects from storage
  Future<void> _loadSideEffects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sideEffectsJson = prefs.getStringList('medication_tracking_side_effects') ?? [];
      _sideEffects.clear();
      
      for (final sideEffectJson in sideEffectsJson) {
        final sideEffect = SideEffectRecord.fromJson(jsonDecode(sideEffectJson));
        _sideEffects.add(sideEffect);
      }
    } catch (e) {
      print('Error loading side effects: $e');
      _sideEffects.clear();
    }
  }

  // Save side effects to storage
  Future<void> _saveSideEffects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sideEffectsJson = _sideEffects
          .map((sideEffect) => jsonEncode(sideEffect.toJson()))
          .toList();
      await prefs.setStringList('medication_tracking_side_effects', sideEffectsJson);
    } catch (e) {
      print('Error saving side effects: $e');
    }
  }

  // Load interactions from storage
  Future<void> _loadInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getStringList('medication_tracking_interactions') ?? [];
      _interactions.clear();
      
      for (final interactionJson in interactionsJson) {
        final interaction = MedicationInteraction.fromJson(jsonDecode(interactionJson));
        _interactions.add(interaction);
      }
    } catch (e) {
      print('Error loading interactions: $e');
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
      await prefs.setStringList('medication_tracking_interactions', interactionsJson);
    } catch (e) {
      print('Error saving interactions: $e');
    }
  }

  // Load educations from storage
  Future<void> _loadEducations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final educationsJson = prefs.getStringList('medication_tracking_educations') ?? [];
      _educations.clear();
      
      for (final educationJson in educationsJson) {
        final education = MedicationEducation.fromJson(jsonDecode(educationJson));
        _educations.add(education);
      }
    } catch (e) {
      print('Error loading educations: $e');
      _educations.clear();
    }
  }

  // Save educations to storage
  Future<void> _saveEducations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final educationsJson = _educations
          .map((education) => jsonEncode(education.toJson()))
          .toList();
      await prefs.setStringList('medication_tracking_educations', educationsJson);
    } catch (e) {
      print('Error saving educations: $e');
    }
  }

  // Add medication record
  Future<MedicationRecord> addMedication({
    required String patientId,
    required String nurseId,
    required String medicationName,
    required String genericName,
    required String dosage,
    required String frequency,
    required MedicationType type,
    required String prescribedBy,
    String? indication,
    String? instructions,
    DateTime? endDate,
    String? notes,
  }) async {
    final medication = MedicationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      nurseId: nurseId,
      medicationName: medicationName,
      genericName: genericName,
      dosage: dosage,
      frequency: frequency,
      type: type,
      prescribedDate: DateTime.now(),
      endDate: endDate,
      prescribedBy: prescribedBy,
      indication: indication,
      instructions: instructions,
      notes: notes,
    );

    _medications.add(medication);
    await _saveMedications();

    // Generate initial doses
    await _generateInitialDoses(medication.id);

    return medication;
  }

  // Generate initial doses for medication
  Future<void> _generateInitialDoses(String medicationId) async {
    final medication = _medications.firstWhere((m) => m.id == medicationId);
    final doses = <MedicationDose>[];
    
    // Generate doses for the next 7 days
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      
      // Parse frequency to determine dose times
      final frequency = medication.frequency.toLowerCase();
      List<DateTime> doseTimes = [];
      
      if (frequency.contains('günde 1') || frequency.contains('once daily')) {
        doseTimes = [DateTime(date.year, date.month, date.day, 9, 0)];
      } else if (frequency.contains('günde 2') || frequency.contains('twice daily')) {
        doseTimes = [
          DateTime(date.year, date.month, date.day, 9, 0),
          DateTime(date.year, date.month, date.day, 21, 0),
        ];
      } else if (frequency.contains('günde 3') || frequency.contains('three times daily')) {
        doseTimes = [
          DateTime(date.year, date.month, date.day, 8, 0),
          DateTime(date.year, date.month, date.day, 14, 0),
          DateTime(date.year, date.month, date.day, 20, 0),
        ];
      } else {
        // Default to once daily
        doseTimes = [DateTime(date.year, date.month, date.day, 9, 0)];
      }
      
      for (final doseTime in doseTimes) {
        final dose = MedicationDose(
          id: '${medicationId}_${doseTime.millisecondsSinceEpoch}',
          scheduledTime: doseTime,
        );
        doses.add(dose);
      }
    }
    
    // Update medication with doses
    final index = _medications.indexWhere((m) => m.id == medicationId);
    if (index != -1) {
      _medications[index] = medication.copyWith(doses: doses);
      await _saveMedications();
    }
  }

  // Record medication dose
  Future<bool> recordMedicationDose(String medicationId, String doseId, {
    required bool wasTaken,
    String? actualDosage,
    String? notes,
    String? recordedBy,
  }) async {
    try {
      final medicationIndex = _medications.indexWhere((m) => m.id == medicationId);
      if (medicationIndex == -1) return false;

      final medication = _medications[medicationIndex];
      final updatedDoses = medication.doses.map((dose) {
        if (dose.id == doseId) {
          return dose.copyWith(
            wasTaken: wasTaken,
            takenTime: wasTaken ? DateTime.now() : null,
            actualDosage: actualDosage,
            notes: notes,
            recordedBy: recordedBy,
          );
        }
        return dose;
      }).toList();

      // Calculate adherence percentage
      final totalDoses = updatedDoses.length;
      final takenDoses = updatedDoses.where((dose) => dose.wasTaken).length;
      final adherencePercentage = totalDoses > 0 ? (takenDoses / totalDoses * 100) : 100.0;
      
      // Determine adherence level
      AdherenceLevel adherenceLevel;
      if (adherencePercentage >= 95) {
        adherenceLevel = AdherenceLevel.excellent;
      } else if (adherencePercentage >= 80) {
        adherenceLevel = AdherenceLevel.good;
      } else if (adherencePercentage >= 60) {
        adherenceLevel = AdherenceLevel.fair;
      } else if (adherencePercentage >= 40) {
        adherenceLevel = AdherenceLevel.poor;
      } else {
        adherenceLevel = AdherenceLevel.critical;
      }

      _medications[medicationIndex] = medication.copyWith(
        doses: updatedDoses,
        adherencePercentage: adherencePercentage,
        adherenceLevel: adherenceLevel,
      );

      await _saveMedications();
      return true;
    } catch (e) {
      print('Error recording medication dose: $e');
      return false;
    }
  }

  // Record side effect
  Future<SideEffectRecord> recordSideEffect({
    required String medicationId,
    required String patientId,
    required String nurseId,
    required String sideEffect,
    required SideEffectSeverity severity,
    required DateTime onsetDate,
    String? description,
    String? actionTaken,
    bool requiresMedicalAttention = false,
    String? notes,
  }) async {
    final sideEffectRecord = SideEffectRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medicationId,
      patientId: patientId,
      nurseId: nurseId,
      sideEffect: sideEffect,
      severity: severity,
      onsetDate: onsetDate,
      description: description,
      actionTaken: actionTaken,
      requiresMedicalAttention: requiresMedicalAttention,
      notes: notes,
    );

    _sideEffects.add(sideEffectRecord);
    await _saveSideEffects();

    return sideEffectRecord;
  }

  // Detect medication interaction
  Future<MedicationInteraction> detectInteraction({
    required String medication1Id,
    required String medication2Id,
    required String interactionType,
    required String severity,
    required String description,
    String? clinicalSignificance,
    String? management,
    String? detectedBy,
  }) async {
    final interaction = MedicationInteraction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medication1Id: medication1Id,
      medication2Id: medication2Id,
      interactionType: interactionType,
      severity: severity,
      description: description,
      clinicalSignificance: clinicalSignificance,
      management: management,
      detectedAt: DateTime.now(),
      detectedBy: detectedBy,
    );

    _interactions.add(interaction);
    await _saveInteractions();

    return interaction;
  }

  // Assign medication education
  Future<MedicationEducation> assignEducation({
    required String medicationId,
    required String patientId,
    required String nurseId,
    required String title,
    required String content,
    required List<String> topics,
    String? notes,
  }) async {
    final education = MedicationEducation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medicationId,
      patientId: patientId,
      nurseId: nurseId,
      title: title,
      content: content,
      topics: topics,
      assignedDate: DateTime.now(),
      notes: notes,
    );

    _educations.add(education);
    await _saveEducations();

    return education;
  }

  // Complete medication education
  Future<bool> completeEducation(String educationId, String quizResults) async {
    try {
      final index = _educations.indexWhere((e) => e.id == educationId);
      if (index == -1) return false;

      _educations[index] = _educations[index].copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
        quizResults: quizResults,
      );

      await _saveEducations();
      return true;
    } catch (e) {
      print('Error completing education: $e');
      return false;
    }
  }

  // Get medications for patient
  List<MedicationRecord> getMedicationsForPatient(String patientId) {
    return _medications
        .where((medication) => medication.patientId == patientId)
        .toList()
        ..sort((a, b) => b.prescribedDate.compareTo(a.prescribedDate));
  }

  // Get active medications for patient
  List<MedicationRecord> getActiveMedicationsForPatient(String patientId) {
    return _medications
        .where((medication) => 
            medication.patientId == patientId && 
            medication.status == MedicationStatus.active)
        .toList()
        ..sort((a, b) => b.prescribedDate.compareTo(a.prescribedDate));
  }

  // Get medications with poor adherence
  List<MedicationRecord> getMedicationsWithPoorAdherence(String patientId) {
    return _medications
        .where((medication) => 
            medication.patientId == patientId && 
            (medication.adherenceLevel == AdherenceLevel.poor || 
             medication.adherenceLevel == AdherenceLevel.critical))
        .toList()
        ..sort((a, b) => a.adherencePercentage.compareTo(b.adherencePercentage));
  }

  // Get side effects for medication
  List<SideEffectRecord> getSideEffectsForMedication(String medicationId) {
    return _sideEffects
        .where((effect) => effect.medicationId == medicationId)
        .toList()
        ..sort((a, b) => b.onsetDate.compareTo(a.onsetDate));
  }

  // Get severe side effects
  List<SideEffectRecord> getSevereSideEffects() {
    return _sideEffects
        .where((effect) => 
            effect.severity == SideEffectSeverity.severe || 
            effect.severity == SideEffectSeverity.lifeThreatening)
        .toList()
        ..sort((a, b) => b.onsetDate.compareTo(a.onsetDate));
  }

  // Get interactions for medication
  List<MedicationInteraction> getInteractionsForMedication(String medicationId) {
    return _interactions
        .where((interaction) => 
            interaction.medication1Id == medicationId || 
            interaction.medication2Id == medicationId)
        .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  // Get educations for patient
  List<MedicationEducation> getEducationsForPatient(String patientId) {
    return _educations
        .where((education) => education.patientId == patientId)
        .toList()
        ..sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
  }

  // Get pending educations for patient
  List<MedicationEducation> getPendingEducationsForPatient(String patientId) {
    return _educations
        .where((education) => 
            education.patientId == patientId && 
            !education.isCompleted)
        .toList()
        ..sort((a, b) => a.assignedDate.compareTo(b.assignedDate));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalMedications = _medications.length;
    final activeMedications = _medications
        .where((medication) => medication.status == MedicationStatus.active)
        .length;
    final poorAdherence = _medications
        .where((medication) => 
            medication.adherenceLevel == AdherenceLevel.poor || 
            medication.adherenceLevel == AdherenceLevel.critical)
        .length;
    final averageAdherence = _medications.isNotEmpty
        ? _medications.fold(0.0, (sum, medication) => sum + medication.adherencePercentage) / _medications.length
        : 0.0;

    final totalSideEffects = _sideEffects.length;
    final severeSideEffects = _sideEffects
        .where((effect) => 
            effect.severity == SideEffectSeverity.severe || 
            effect.severity == SideEffectSeverity.lifeThreatening)
        .length;
    final unresolvedSideEffects = _sideEffects
        .where((effect) => effect.resolutionDate == null)
        .length;

    final totalInteractions = _interactions.length;
    final severeInteractions = _interactions
        .where((interaction) => interaction.severity.toLowerCase().contains('severe'))
        .length;

    final totalEducations = _educations.length;
    final completedEducations = _educations
        .where((education) => education.isCompleted)
        .length;
    final pendingEducations = _educations
        .where((education) => !education.isCompleted)
        .length;

    return {
      'totalMedications': totalMedications,
      'activeMedications': activeMedications,
      'poorAdherence': poorAdherence,
      'averageAdherence': averageAdherence.round(),
      'totalSideEffects': totalSideEffects,
      'severeSideEffects': severeSideEffects,
      'unresolvedSideEffects': unresolvedSideEffects,
      'totalInteractions': totalInteractions,
      'severeInteractions': severeInteractions,
      'totalEducations': totalEducations,
      'completedEducations': completedEducations,
      'pendingEducations': pendingEducations,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_medications.isNotEmpty) return;

    // Add demo medications
    final demoMedications = [
      MedicationRecord(
        id: 'med_001',
        patientId: '1',
        nurseId: 'nurse_001',
        medicationName: 'Sertraline',
        genericName: 'Sertraline HCl',
        dosage: '50mg',
        frequency: 'Günde 1 kez',
        type: MedicationType.tablet,
        prescribedDate: DateTime.now().subtract(const Duration(days: 10)),
        prescribedBy: 'Dr. Smith',
        indication: 'Major Depressive Disorder',
        instructions: 'Sabah yemekle birlikte alın',
        doses: [
          MedicationDose(
            id: 'dose_001',
            scheduledTime: DateTime.now().subtract(const Duration(days: 1, hours: 15)),
            takenTime: DateTime.now().subtract(const Duration(days: 1, hours: 15)),
            wasTaken: true,
            recordedBy: 'nurse_001',
          ),
          MedicationDose(
            id: 'dose_002',
            scheduledTime: DateTime.now().subtract(const Duration(hours: 15)),
            takenTime: DateTime.now().subtract(const Duration(hours: 15)),
            wasTaken: true,
            recordedBy: 'nurse_001',
          ),
          MedicationDose(
            id: 'dose_003',
            scheduledTime: DateTime.now().add(const Duration(hours: 9)),
            wasTaken: false,
          ),
        ],
        adherenceLevel: AdherenceLevel.good,
        adherencePercentage: 85.0,
        notes: 'Hasta ilaç uyumu iyi',
      ),
      MedicationRecord(
        id: 'med_002',
        patientId: '1',
        nurseId: 'nurse_001',
        medicationName: 'Lorazepam',
        genericName: 'Lorazepam',
        dosage: '1mg',
        frequency: 'Günde 2 kez',
        type: MedicationType.tablet,
        prescribedDate: DateTime.now().subtract(const Duration(days: 5)),
        prescribedBy: 'Dr. Smith',
        indication: 'Anxiety',
        instructions: 'Sabah ve akşam yemekle birlikte alın',
        doses: [
          MedicationDose(
            id: 'dose_004',
            scheduledTime: DateTime.now().subtract(const Duration(days: 1, hours: 15)),
            takenTime: DateTime.now().subtract(const Duration(days: 1, hours: 15)),
            wasTaken: true,
            recordedBy: 'nurse_001',
          ),
          MedicationDose(
            id: 'dose_005',
            scheduledTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
            takenTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
            wasTaken: true,
            recordedBy: 'nurse_001',
          ),
        ],
        adherenceLevel: AdherenceLevel.excellent,
        adherencePercentage: 100.0,
        notes: 'Hasta ilaç uyumu mükemmel',
      ),
    ];

    for (final medication in demoMedications) {
      _medications.add(medication);
    }

    await _saveMedications();

    // Add demo side effects
    final demoSideEffects = [
      SideEffectRecord(
        id: 'side_001',
        medicationId: 'med_001',
        patientId: '1',
        nurseId: 'nurse_001',
        sideEffect: 'Mide bulantısı',
        severity: SideEffectSeverity.mild,
        onsetDate: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Hasta sabah ilaç aldıktan sonra hafif mide bulantısı yaşıyor',
        actionTaken: 'Yemekle birlikte alması önerildi',
        requiresMedicalAttention: false,
        notes: 'Geçici bir yan etki olabilir',
      ),
    ];

    for (final sideEffect in demoSideEffects) {
      _sideEffects.add(sideEffect);
    }

    await _saveSideEffects();

    // Add demo interactions
    final demoInteractions = [
      MedicationInteraction(
        id: 'interaction_001',
        medication1Id: 'med_001',
        medication2Id: 'med_002',
        interactionType: 'Pharmacodynamic',
        severity: 'Moderate',
        description: 'Sertraline ve Lorazepam birlikte alındığında sedasyon etkisi artabilir',
        clinicalSignificance: 'Hasta sedasyon etkisini takip etmeli',
        management: 'Dozaj ayarlaması gerekebilir',
        detectedAt: DateTime.now().subtract(const Duration(days: 2)),
        detectedBy: 'AI System',
      ),
    ];

    for (final interaction in demoInteractions) {
      _interactions.add(interaction);
    }

    await _saveInteractions();

    // Add demo educations
    final demoEducations = [
      MedicationEducation(
        id: 'edu_001',
        medicationId: 'med_001',
        patientId: '1',
        nurseId: 'nurse_001',
        title: 'Sertraline Kullanım Eğitimi',
        content: 'Sertraline ilacının doğru kullanımı hakkında bilgilendirme',
        topics: [
          'İlaç dozajı',
          'Yan etkiler',
          'Etkileşimler',
          'Saklama koşulları',
          'Unutma durumunda ne yapılmalı',
        ],
        assignedDate: DateTime.now().subtract(const Duration(days: 5)),
        completedDate: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
        quizResults: '8/10 doğru cevap',
        notes: 'Hasta eğitimi başarıyla tamamlandı',
      ),
    ];

    for (final education in demoEducations) {
      _educations.add(education);
    }

    await _saveEducations();

    print('✅ Demo medication tracking data created:');
    print('   - Medications: ${demoMedications.length}');
    print('   - Side effects: ${demoSideEffects.length}');
    print('   - Interactions: ${demoInteractions.length}');
    print('   - Educations: ${demoEducations.length}');
  }
}