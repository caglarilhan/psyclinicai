import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nurse_care_models.dart';

class NurseCareService {
  static final NurseCareService _instance = NurseCareService._internal();
  factory NurseCareService() => _instance;
  NurseCareService._internal();

  final List<CarePlan> _carePlans = [];
  final List<VitalSignsRecord> _vitalSignsRecords = [];
  final List<MedicationAdherence> _medicationAdherence = [];
  final List<CareNote> _careNotes = [];
  final List<EmergencyProtocol> _emergencyProtocols = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadCarePlans();
    await _loadVitalSignsRecords();
    await _loadMedicationAdherence();
    await _loadCareNotes();
    await _loadEmergencyProtocols();
  }

  // Load care plans from storage
  Future<void> _loadCarePlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carePlansJson = prefs.getStringList('nurse_care_plans') ?? [];
      _carePlans.clear();
      
      for (final carePlanJson in carePlansJson) {
        final carePlan = CarePlan.fromJson(jsonDecode(carePlanJson));
        _carePlans.add(carePlan);
      }
    } catch (e) {
      print('Error loading care plans: $e');
      _carePlans.clear();
    }
  }

  // Save care plans to storage
  Future<void> _saveCarePlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final carePlansJson = _carePlans
          .map((carePlan) => jsonEncode(carePlan.toJson()))
          .toList();
      await prefs.setStringList('nurse_care_plans', carePlansJson);
    } catch (e) {
      print('Error saving care plans: $e');
    }
  }

  // Load vital signs records from storage
  Future<void> _loadVitalSignsRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vitalSignsJson = prefs.getStringList('nurse_vital_signs') ?? [];
      _vitalSignsRecords.clear();
      
      for (final vitalSignsJson in vitalSignsJson) {
        final vitalSigns = VitalSignsRecord.fromJson(jsonDecode(vitalSignsJson));
        _vitalSignsRecords.add(vitalSigns);
      }
    } catch (e) {
      print('Error loading vital signs records: $e');
      _vitalSignsRecords.clear();
    }
  }

  // Save vital signs records to storage
  Future<void> _saveVitalSignsRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vitalSignsJson = _vitalSignsRecords
          .map((vitalSigns) => jsonEncode(vitalSigns.toJson()))
          .toList();
      await prefs.setStringList('nurse_vital_signs', vitalSignsJson);
    } catch (e) {
      print('Error saving vital signs records: $e');
    }
  }

  // Load medication adherence from storage
  Future<void> _loadMedicationAdherence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationJson = prefs.getStringList('nurse_medication_adherence') ?? [];
      _medicationAdherence.clear();
      
      for (final medicationJson in medicationJson) {
        final medication = MedicationAdherence.fromJson(jsonDecode(medicationJson));
        _medicationAdherence.add(medication);
      }
    } catch (e) {
      print('Error loading medication adherence: $e');
      _medicationAdherence.clear();
    }
  }

  // Save medication adherence to storage
  Future<void> _saveMedicationAdherence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationJson = _medicationAdherence
          .map((medication) => jsonEncode(medication.toJson()))
          .toList();
      await prefs.setStringList('nurse_medication_adherence', medicationJson);
    } catch (e) {
      print('Error saving medication adherence: $e');
    }
  }

  // Load care notes from storage
  Future<void> _loadCareNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final careNotesJson = prefs.getStringList('nurse_care_notes') ?? [];
      _careNotes.clear();
      
      for (final careNoteJson in careNotesJson) {
        final careNote = CareNote.fromJson(jsonDecode(careNoteJson));
        _careNotes.add(careNote);
      }
    } catch (e) {
      print('Error loading care notes: $e');
      _careNotes.clear();
    }
  }

  // Save care notes to storage
  Future<void> _saveCareNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final careNotesJson = _careNotes
          .map((careNote) => jsonEncode(careNote.toJson()))
          .toList();
      await prefs.setStringList('nurse_care_notes', careNotesJson);
    } catch (e) {
      print('Error saving care notes: $e');
    }
  }

  // Load emergency protocols from storage
  Future<void> _loadEmergencyProtocols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final protocolsJson = prefs.getStringList('nurse_emergency_protocols') ?? [];
      _emergencyProtocols.clear();
      
      for (final protocolJson in protocolsJson) {
        final protocol = EmergencyProtocol.fromJson(jsonDecode(protocolJson));
        _emergencyProtocols.add(protocol);
      }
    } catch (e) {
      print('Error loading emergency protocols: $e');
      _emergencyProtocols.clear();
    }
  }

  // Save emergency protocols to storage
  Future<void> _saveEmergencyProtocols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final protocolsJson = _emergencyProtocols
          .map((protocol) => jsonEncode(protocol.toJson()))
          .toList();
      await prefs.setStringList('nurse_emergency_protocols', protocolsJson);
    } catch (e) {
      print('Error saving emergency protocols: $e');
    }
  }

  // Create care plan
  Future<CarePlan> createCarePlan({
    required String patientId,
    required String nurseId,
    required String title,
    required String description,
    required CarePriority priority,
    required DateTime startDate,
    DateTime? endDate,
    List<CareTask>? tasks,
    String? notes,
  }) async {
    final carePlan = CarePlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      nurseId: nurseId,
      title: title,
      description: description,
      priority: priority,
      startDate: startDate,
      endDate: endDate,
      tasks: tasks ?? [],
      notes: notes,
      createdAt: DateTime.now(),
    );

    _carePlans.add(carePlan);
    await _saveCarePlans();

    return carePlan;
  }

  // Update care plan
  Future<bool> updateCarePlan(CarePlan updatedCarePlan) async {
    try {
      final index = _carePlans.indexWhere((plan) => plan.id == updatedCarePlan.id);
      if (index == -1) return false;

      _carePlans[index] = updatedCarePlan.copyWith(lastUpdatedAt: DateTime.now());
      await _saveCarePlans();
      return true;
    } catch (e) {
      print('Error updating care plan: $e');
      return false;
    }
  }

  // Add care task
  Future<bool> addCareTask(String carePlanId, CareTask task) async {
    try {
      final index = _carePlans.indexWhere((plan) => plan.id == carePlanId);
      if (index == -1) return false;

      final carePlan = _carePlans[index];
      final updatedTasks = List<CareTask>.from(carePlan.tasks)..add(task);
      
      _carePlans[index] = carePlan.copyWith(
        tasks: updatedTasks,
        lastUpdatedAt: DateTime.now(),
      );
      
      await _saveCarePlans();
      return true;
    } catch (e) {
      print('Error adding care task: $e');
      return false;
    }
  }

  // Complete care task
  Future<bool> completeCareTask(String carePlanId, String taskId, String completedBy) async {
    try {
      final index = _carePlans.indexWhere((plan) => plan.id == carePlanId);
      if (index == -1) return false;

      final carePlan = _carePlans[index];
      final updatedTasks = carePlan.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(
            status: CareStatus.completed,
            completedTime: DateTime.now(),
            completedBy: completedBy,
          );
        }
        return task;
      }).toList();

      _carePlans[index] = carePlan.copyWith(
        tasks: updatedTasks,
        lastUpdatedAt: DateTime.now(),
      );

      await _saveCarePlans();
      return true;
    } catch (e) {
      print('Error completing care task: $e');
      return false;
    }
  }

  // Record vital signs
  Future<VitalSignsRecord> recordVitalSigns({
    required String patientId,
    required String nurseId,
    required Map<VitalSignType, String> values,
    String? notes,
  }) async {
    final record = VitalSignsRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      nurseId: nurseId,
      recordedAt: DateTime.now(),
      values: values,
      notes: notes,
      isAbnormal: _checkAbnormalValues(values),
    );

    _vitalSignsRecords.add(record);
    await _saveVitalSignsRecords();

    return record;
  }

  // Check if vital signs are abnormal
  bool _checkAbnormalValues(Map<VitalSignType, String> values) {
    // Simple abnormal value checking logic
    for (final entry in values.entries) {
      final value = double.tryParse(entry.value);
      if (value != null) {
        switch (entry.key) {
          case VitalSignType.heartRate:
            if (value < 60 || value > 100) return true;
            break;
          case VitalSignType.temperature:
            if (value < 36.0 || value > 37.5) return true;
            break;
          case VitalSignType.respiratoryRate:
            if (value < 12 || value > 20) return true;
            break;
          case VitalSignType.oxygenSaturation:
            if (value < 95) return true;
            break;
          default:
            break;
        }
      }
    }
    return false;
  }

  // Track medication adherence
  Future<MedicationAdherence> trackMedicationAdherence({
    required String patientId,
    required String nurseId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required DateTime prescribedDate,
    DateTime? lastTakenDate,
    int adherencePercentage = 100,
    List<MedicationEvent>? events,
    String? notes,
  }) async {
    final adherence = MedicationAdherence(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      nurseId: nurseId,
      medicationName: medicationName,
      dosage: dosage,
      frequency: frequency,
      prescribedDate: prescribedDate,
      lastTakenDate: lastTakenDate,
      adherencePercentage: adherencePercentage,
      events: events ?? [],
      notes: notes,
    );

    _medicationAdherence.add(adherence);
    await _saveMedicationAdherence();

    return adherence;
  }

  // Record medication event
  Future<bool> recordMedicationEvent(String adherenceId, MedicationEvent event) async {
    try {
      final index = _medicationAdherence.indexWhere((adherence) => adherence.id == adherenceId);
      if (index == -1) return false;

      final adherence = _medicationAdherence[index];
      final updatedEvents = List<MedicationEvent>.from(adherence.events)..add(event);
      
      // Recalculate adherence percentage
      final totalEvents = updatedEvents.length;
      final takenEvents = updatedEvents.where((e) => e.wasTaken).length;
      final newPercentage = totalEvents > 0 ? (takenEvents / totalEvents * 100).round() : 100;

      _medicationAdherence[index] = adherence.copyWith(
        events: updatedEvents,
        adherencePercentage: newPercentage,
        lastTakenDate: event.wasTaken ? event.eventDate : adherence.lastTakenDate,
      );

      await _saveMedicationAdherence();
      return true;
    } catch (e) {
      print('Error recording medication event: $e');
      return false;
    }
  }

  // Add care note
  Future<CareNote> addCareNote({
    required String patientId,
    required String nurseId,
    required String content,
    required CarePriority priority,
    String? category,
    bool isUrgent = false,
  }) async {
    final careNote = CareNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      nurseId: nurseId,
      noteDate: DateTime.now(),
      content: content,
      priority: priority,
      category: category,
      isUrgent: isUrgent,
    );

    _careNotes.add(careNote);
    await _saveCareNotes();

    return careNote;
  }

  // Create emergency protocol
  Future<EmergencyProtocol> createEmergencyProtocol({
    required String title,
    required String description,
    required List<String> steps,
    required CarePriority priority,
    String? category,
    required String createdBy,
  }) async {
    final protocol = EmergencyProtocol(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      steps: steps,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _emergencyProtocols.add(protocol);
    await _saveEmergencyProtocols();

    return protocol;
  }

  // Get care plans for patient
  List<CarePlan> getCarePlansForPatient(String patientId) {
    return _carePlans
        .where((plan) => plan.patientId == patientId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get care plans for nurse
  List<CarePlan> getCarePlansForNurse(String nurseId) {
    return _carePlans
        .where((plan) => plan.nurseId == nurseId)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get vital signs records for patient
  List<VitalSignsRecord> getVitalSignsForPatient(String patientId) {
    return _vitalSignsRecords
        .where((record) => record.patientId == patientId)
        .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // Get medication adherence for patient
  List<MedicationAdherence> getMedicationAdherenceForPatient(String patientId) {
    return _medicationAdherence
        .where((adherence) => adherence.patientId == patientId)
        .toList()
        ..sort((a, b) => b.prescribedDate.compareTo(a.prescribedDate));
  }

  // Get care notes for patient
  List<CareNote> getCareNotesForPatient(String patientId) {
    return _careNotes
        .where((note) => note.patientId == patientId)
        .toList()
        ..sort((a, b) => b.noteDate.compareTo(a.noteDate));
  }

  // Get urgent care notes
  List<CareNote> getUrgentCareNotes() {
    return _careNotes
        .where((note) => note.isUrgent)
        .toList()
        ..sort((a, b) => b.noteDate.compareTo(a.noteDate));
  }

  // Get emergency protocols
  List<EmergencyProtocol> getEmergencyProtocols() {
    return _emergencyProtocols
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalCarePlans = _carePlans.length;
    final activeCarePlans = _carePlans
        .where((plan) => plan.status == CareStatus.inProgress)
        .length;
    final completedCarePlans = _carePlans
        .where((plan) => plan.status == CareStatus.completed)
        .length;
    final overdueCarePlans = _carePlans
        .where((plan) => plan.status == CareStatus.overdue)
        .length;

    final totalVitalSigns = _vitalSignsRecords.length;
    final abnormalVitalSigns = _vitalSignsRecords
        .where((record) => record.isAbnormal)
        .length;

    final totalMedicationAdherence = _medicationAdherence.length;
    final lowAdherence = _medicationAdherence
        .where((adherence) => adherence.adherencePercentage < 80)
        .length;

    final totalCareNotes = _careNotes.length;
    final urgentCareNotes = _careNotes
        .where((note) => note.isUrgent)
        .length;

    final totalEmergencyProtocols = _emergencyProtocols.length;

    return {
      'totalCarePlans': totalCarePlans,
      'activeCarePlans': activeCarePlans,
      'completedCarePlans': completedCarePlans,
      'overdueCarePlans': overdueCarePlans,
      'totalVitalSigns': totalVitalSigns,
      'abnormalVitalSigns': abnormalVitalSigns,
      'totalMedicationAdherence': totalMedicationAdherence,
      'lowAdherence': lowAdherence,
      'totalCareNotes': totalCareNotes,
      'urgentCareNotes': urgentCareNotes,
      'totalEmergencyProtocols': totalEmergencyProtocols,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_carePlans.isNotEmpty) return;

    // Add demo care plans
    final demoCarePlans = [
      CarePlan(
        id: 'care_plan_001',
        patientId: '1',
        nurseId: 'nurse_001',
        title: 'Depresyon Hasta Bakım Planı',
        description: 'Depresyon tanılı hasta için günlük bakım planı',
        priority: CarePriority.high,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        status: CareStatus.inProgress,
        tasks: [
          CareTask(
            id: 'task_001',
            title: 'Günlük vital bulgular',
            description: 'Nabız, tansiyon, ateş ölçümü',
            scheduledTime: DateTime.now().add(const Duration(hours: 2)),
            status: CareStatus.planned,
          ),
          CareTask(
            id: 'task_002',
            title: 'İlaç uyumu kontrolü',
            description: 'Hastanın ilaçlarını düzenli aldığını kontrol et',
            scheduledTime: DateTime.now().add(const Duration(hours: 4)),
            status: CareStatus.planned,
          ),
        ],
        notes: 'Hasta kooperatif',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    for (final carePlan in demoCarePlans) {
      _carePlans.add(carePlan);
    }

    await _saveCarePlans();

    // Add demo vital signs records
    final demoVitalSigns = [
      VitalSignsRecord(
        id: 'vital_001',
        patientId: '1',
        nurseId: 'nurse_001',
        recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
        values: {
          VitalSignType.heartRate: '75',
          VitalSignType.temperature: '36.5',
          VitalSignType.respiratoryRate: '16',
          VitalSignType.oxygenSaturation: '98',
        },
        notes: 'Normal değerler',
        isAbnormal: false,
      ),
    ];

    for (final vitalSigns in demoVitalSigns) {
      _vitalSignsRecords.add(vitalSigns);
    }

    await _saveVitalSignsRecords();

    // Add demo medication adherence
    final demoMedicationAdherence = [
      MedicationAdherence(
        id: 'med_001',
        patientId: '1',
        nurseId: 'nurse_001',
        medicationName: 'Sertraline',
        dosage: '50mg',
        frequency: 'Günde 1 kez',
        prescribedDate: DateTime.now().subtract(const Duration(days: 10)),
        lastTakenDate: DateTime.now().subtract(const Duration(hours: 12)),
        adherencePercentage: 95,
        events: [
          MedicationEvent(
            id: 'event_001',
            eventDate: DateTime.now().subtract(const Duration(hours: 12)),
            wasTaken: true,
            notes: 'Hasta ilacını aldı',
            recordedBy: 'nurse_001',
          ),
        ],
        notes: 'Hasta ilaç uyumu iyi',
      ),
    ];

    for (final medication in demoMedicationAdherence) {
      _medicationAdherence.add(medication);
    }

    await _saveMedicationAdherence();

    // Add demo care notes
    final demoCareNotes = [
      CareNote(
        id: 'note_001',
        patientId: '1',
        nurseId: 'nurse_001',
        noteDate: DateTime.now().subtract(const Duration(hours: 1)),
        content: 'Hasta bugün daha iyi görünüyor. İlaçlarını düzenli alıyor.',
        priority: CarePriority.medium,
        category: 'Genel Gözlem',
        isUrgent: false,
      ),
    ];

    for (final careNote in demoCareNotes) {
      _careNotes.add(careNote);
    }

    await _saveCareNotes();

    // Add demo emergency protocols
    final demoEmergencyProtocols = [
      EmergencyProtocol(
        id: 'protocol_001',
        title: 'Suicidal Ideation Protocol',
        description: 'Hasta intihar düşünceleri belirttiğinde uygulanacak protokol',
        steps: [
          'Hastayı güvenli bir ortama al',
          'Hastanın yanında kal',
          'Psikiyatristi derhal bilgilendir',
          'Aile üyelerini bilgilendir',
          'Güvenlik planı oluştur',
        ],
        priority: CarePriority.critical,
        category: 'Psikiyatrik Acil',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'nurse_001',
      ),
    ];

    for (final protocol in demoEmergencyProtocols) {
      _emergencyProtocols.add(protocol);
    }

    await _saveEmergencyProtocols();

    print('✅ Demo nurse care data created:');
    print('   - Care plans: ${demoCarePlans.length}');
    print('   - Vital signs records: ${demoVitalSigns.length}');
    print('   - Medication adherence: ${demoMedicationAdherence.length}');
    print('   - Care notes: ${demoCareNotes.length}');
    print('   - Emergency protocols: ${demoEmergencyProtocols.length}');
  }
}
