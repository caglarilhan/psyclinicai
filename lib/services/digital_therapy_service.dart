import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/digital_therapy_models.dart';

class DigitalTherapyService {
  static final DigitalTherapyService _instance = DigitalTherapyService._internal();
  factory DigitalTherapyService() => _instance;
  DigitalTherapyService._internal();

  final List<DigitalTherapyMaterial> _materials = [];
  final List<MaterialAssignment> _assignments = [];
  final List<MaterialProgress> _progresses = [];
  final List<MaterialCollection> _collections = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadMaterials();
    await _loadAssignments();
    await _loadProgresses();
    await _loadCollections();
  }

  // Load materials from storage
  Future<void> _loadMaterials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final materialsJson = prefs.getStringList('digital_therapy_materials') ?? [];
      _materials.clear();
      
      for (final materialJson in materialsJson) {
        final material = DigitalTherapyMaterial.fromJson(jsonDecode(materialJson));
        _materials.add(material);
      }
    } catch (e) {
      print('Error loading digital therapy materials: $e');
      _materials.clear();
    }
  }

  // Save materials to storage
  Future<void> _saveMaterials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final materialsJson = _materials
          .map((material) => jsonEncode(material.toJson()))
          .toList();
      await prefs.setStringList('digital_therapy_materials', materialsJson);
    } catch (e) {
      print('Error saving digital therapy materials: $e');
    }
  }

  // Load assignments from storage
  Future<void> _loadAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignmentsJson = prefs.getStringList('material_assignments') ?? [];
      _assignments.clear();
      
      for (final assignmentJson in assignmentsJson) {
        final assignment = MaterialAssignment.fromJson(jsonDecode(assignmentJson));
        _assignments.add(assignment);
      }
    } catch (e) {
      print('Error loading material assignments: $e');
      _assignments.clear();
    }
  }

  // Save assignments to storage
  Future<void> _saveAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignmentsJson = _assignments
          .map((assignment) => jsonEncode(assignment.toJson()))
          .toList();
      await prefs.setStringList('material_assignments', assignmentsJson);
    } catch (e) {
      print('Error saving material assignments: $e');
    }
  }

  // Load progresses from storage
  Future<void> _loadProgresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressesJson = prefs.getStringList('material_progresses') ?? [];
      _progresses.clear();
      
      for (final progressJson in progressesJson) {
        final progress = MaterialProgress.fromJson(jsonDecode(progressJson));
        _progresses.add(progress);
      }
    } catch (e) {
      print('Error loading material progresses: $e');
      _progresses.clear();
    }
  }

  // Save progresses to storage
  Future<void> _saveProgresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressesJson = _progresses
          .map((progress) => jsonEncode(progress.toJson()))
          .toList();
      await prefs.setStringList('material_progresses', progressesJson);
    } catch (e) {
      print('Error saving material progresses: $e');
    }
  }

  // Load collections from storage
  Future<void> _loadCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collectionsJson = prefs.getStringList('material_collections') ?? [];
      _collections.clear();
      
      for (final collectionJson in collectionsJson) {
        final collection = MaterialCollection.fromJson(jsonDecode(collectionJson));
        _collections.add(collection);
      }
    } catch (e) {
      print('Error loading material collections: $e');
      _collections.clear();
    }
  }

  // Save collections to storage
  Future<void> _saveCollections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collectionsJson = _collections
          .map((collection) => jsonEncode(collection.toJson()))
          .toList();
      await prefs.setStringList('material_collections', collectionsJson);
    } catch (e) {
      print('Error saving material collections: $e');
    }
  }

  // Create material
  Future<DigitalTherapyMaterial> createMaterial({
    required String title,
    required String description,
    required MaterialType type,
    required String content,
    String? filePath,
    String? thumbnailPath,
    List<String>? tags,
    List<String>? targetDisorders,
    List<String>? targetAudience,
    DifficultyLevel difficulty = DifficultyLevel.beginner,
    Duration? estimatedDuration,
    String? instructions,
    String? prerequisites,
    String? learningObjectives,
    required String createdBy,
    bool isPublic = false,
    List<String>? sharedWith,
  }) async {
    final material = DigitalTherapyMaterial(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      content: content,
      filePath: filePath,
      thumbnailPath: thumbnailPath,
      tags: tags ?? [],
      targetDisorders: targetDisorders ?? [],
      targetAudience: targetAudience ?? [],
      difficulty: difficulty,
      estimatedDuration: estimatedDuration,
      instructions: instructions,
      prerequisites: prerequisites,
      learningObjectives: learningObjectives,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      isPublic: isPublic,
      sharedWith: sharedWith ?? [],
    );

    _materials.add(material);
    await _saveMaterials();

    return material;
  }

  // Assign material to patient
  Future<MaterialAssignment> assignMaterial({
    required String materialId,
    required String patientId,
    required String assignedBy,
    DateTime? dueDate,
    String? notes,
  }) async {
    final assignment = MaterialAssignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      materialId: materialId,
      patientId: patientId,
      assignedBy: assignedBy,
      assignedAt: DateTime.now(),
      dueDate: dueDate,
      notes: notes,
    );

    _assignments.add(assignment);
    await _saveAssignments();

    return assignment;
  }

  // Start material
  Future<bool> startMaterial(String assignmentId) async {
    try {
      final index = _assignments.indexWhere((a) => a.id == assignmentId);
      if (index == -1) return false;

      final assignment = _assignments[index];
      final updatedAssignment = MaterialAssignment(
        id: assignment.id,
        materialId: assignment.materialId,
        patientId: assignment.patientId,
        assignedBy: assignment.assignedBy,
        assignedAt: assignment.assignedAt,
        dueDate: assignment.dueDate,
        status: AssignmentStatus.started,
        startedAt: DateTime.now(),
        completedAt: assignment.completedAt,
        progressPercentage: assignment.progressPercentage,
        notes: assignment.notes,
        patientFeedback: assignment.patientFeedback,
        metadata: assignment.metadata,
      );

      _assignments[index] = updatedAssignment;
      await _saveAssignments();
      return true;
    } catch (e) {
      print('Error starting material: $e');
      return false;
    }
  }

  // Update progress
  Future<bool> updateProgress({
    required String assignmentId,
    required double progressPercentage,
    String? notes,
    Map<String, dynamic>? interactionData,
  }) async {
    try {
      final assignmentIndex = _assignments.indexWhere((a) => a.id == assignmentId);
      if (assignmentIndex == -1) return false;

      final assignment = _assignments[assignmentIndex];
      final updatedAssignment = MaterialAssignment(
        id: assignment.id,
        materialId: assignment.materialId,
        patientId: assignment.patientId,
        assignedBy: assignment.assignedBy,
        assignedAt: assignment.assignedAt,
        dueDate: assignment.dueDate,
        status: progressPercentage >= 100 ? AssignmentStatus.completed : AssignmentStatus.inProgress,
        startedAt: assignment.startedAt,
        completedAt: progressPercentage >= 100 ? DateTime.now() : assignment.completedAt,
        progressPercentage: progressPercentage,
        notes: assignment.notes,
        patientFeedback: assignment.patientFeedback,
        metadata: assignment.metadata,
      );

      _assignments[assignmentIndex] = updatedAssignment;

      // Add progress record
      final progress = MaterialProgress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assignmentId: assignmentId,
        patientId: assignment.patientId,
        timestamp: DateTime.now(),
        progressPercentage: progressPercentage,
        notes: notes,
        interactionData: interactionData ?? {},
      );

      _progresses.add(progress);

      await _saveAssignments();
      await _saveProgresses();
      return true;
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  // Complete material
  Future<bool> completeMaterial({
    required String assignmentId,
    String? patientFeedback,
  }) async {
    try {
      final index = _assignments.indexWhere((a) => a.id == assignmentId);
      if (index == -1) return false;

      final assignment = _assignments[index];
      final updatedAssignment = MaterialAssignment(
        id: assignment.id,
        materialId: assignment.materialId,
        patientId: assignment.patientId,
        assignedBy: assignment.assignedBy,
        assignedAt: assignment.assignedAt,
        dueDate: assignment.dueDate,
        status: AssignmentStatus.completed,
        startedAt: assignment.startedAt,
        completedAt: DateTime.now(),
        progressPercentage: 100.0,
        notes: assignment.notes,
        patientFeedback: patientFeedback ?? assignment.patientFeedback,
        metadata: assignment.metadata,
      );

      _assignments[index] = updatedAssignment;
      await _saveAssignments();
      return true;
    } catch (e) {
      print('Error completing material: $e');
      return false;
    }
  }

  // Create collection
  Future<MaterialCollection> createCollection({
    required String name,
    required String description,
    required List<String> materialIds,
    required String createdBy,
    bool isPublic = false,
    List<String>? sharedWith,
  }) async {
    final collection = MaterialCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      materialIds: materialIds,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      isPublic: isPublic,
      sharedWith: sharedWith ?? [],
    );

    _collections.add(collection);
    await _saveCollections();

    return collection;
  }

  // Get materials for user
  List<DigitalTherapyMaterial> getMaterialsForUser(String userId) {
    return _materials
        .where((material) => material.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get materials by type
  List<DigitalTherapyMaterial> getMaterialsByType(MaterialType type, String userId) {
    return _materials
        .where((material) => 
            material.type == type && 
            material.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get materials by disorder
  List<DigitalTherapyMaterial> getMaterialsByDisorder(String disorder, String userId) {
    return _materials
        .where((material) => 
            material.targetDisorders.contains(disorder) && 
            material.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get assignments for patient
  List<MaterialAssignment> getAssignmentsForPatient(String patientId) {
    return _assignments
        .where((assignment) => assignment.patientId == patientId)
        .toList()
        ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
  }

  // Get assignments for clinician
  List<MaterialAssignment> getAssignmentsForClinician(String clinicianId) {
    return _assignments
        .where((assignment) => assignment.assignedBy == clinicianId)
        .toList()
        ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
  }

  // Get overdue assignments
  List<MaterialAssignment> getOverdueAssignments() {
    return _assignments
        .where((assignment) => assignment.isOverdue)
        .toList()
        ..sort((a, b) => a.dueDate?.compareTo(b.dueDate ?? DateTime.now()) ?? 0);
  }

  // Get urgent assignments
  List<MaterialAssignment> getUrgentAssignments() {
    return _assignments
        .where((assignment) => assignment.isUrgent)
        .toList()
        ..sort((a, b) => a.dueDate?.compareTo(b.dueDate ?? DateTime.now()) ?? 0);
  }

  // Get progress for assignment
  List<MaterialProgress> getProgressForAssignment(String assignmentId) {
    return _progresses
        .where((progress) => progress.assignmentId == assignmentId)
        .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Get progress for patient
  List<MaterialProgress> getProgressForPatient(String patientId) {
    return _progresses
        .where((progress) => progress.patientId == patientId)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get collections for user
  List<MaterialCollection> getCollectionsForUser(String userId) {
    return _collections
        .where((collection) => collection.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get materials in collection
  List<DigitalTherapyMaterial> getMaterialsInCollection(String collectionId, String userId) {
    final collection = _collections.firstWhere((c) => c.id == collectionId);
    return _materials
        .where((material) => 
            collection.materialIds.contains(material.id) && 
            material.isAccessibleBy(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Search materials
  List<DigitalTherapyMaterial> searchMaterials(String query, String userId) {
    final lowerQuery = query.toLowerCase();
    return _materials
        .where((material) => 
            material.isAccessibleBy(userId) &&
            (material.title.toLowerCase().contains(lowerQuery) ||
             material.description.toLowerCase().contains(lowerQuery) ||
             material.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
             material.targetDisorders.any((disorder) => disorder.toLowerCase().contains(lowerQuery))))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalMaterials = _materials.length;
    final activeMaterials = _materials
        .where((material) => material.isActive)
        .length;
    final publicMaterials = _materials
        .where((material) => material.isPublic)
        .length;

    final totalAssignments = _assignments.length;
    final completedAssignments = _assignments
        .where((assignment) => assignment.status == AssignmentStatus.completed)
        .length;
    final overdueAssignments = _assignments
        .where((assignment) => assignment.isOverdue)
        .length;
    final urgentAssignments = _assignments
        .where((assignment) => assignment.isUrgent)
        .length;

    final totalCollections = _collections.length;
    final activeCollections = _collections
        .where((collection) => collection.isActive)
        .length;

    return {
      'totalMaterials': totalMaterials,
      'activeMaterials': activeMaterials,
      'publicMaterials': publicMaterials,
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'overdueAssignments': overdueAssignments,
      'urgentAssignments': urgentAssignments,
      'totalCollections': totalCollections,
      'activeCollections': activeCollections,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_materials.isNotEmpty) return;

    // Add demo materials
    final demoMaterials = [
      DigitalTherapyMaterial(
        id: 'material_001',
        title: 'Depresyonla Başa Çıkma Rehberi',
        description: 'Depresyon belirtilerini tanıma ve başa çıkma stratejileri',
        type: MaterialType.pdf,
        content: 'Depresyonla başa çıkma teknikleri...',
        tags: ['depresyon', 'başa çıkma', 'rehber'],
        targetDisorders: ['Depresyon', 'Major Depresif Bozukluk'],
        targetAudience: ['Hasta'],
        difficulty: DifficultyLevel.beginner,
        estimatedDuration: const Duration(minutes: 30),
        instructions: 'Rehberi dikkatli okuyun ve önerilen teknikleri uygulayın.',
        learningObjectives: 'Depresyon belirtilerini tanıma ve başa çıkma stratejileri öğrenme',
        createdBy: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isPublic: true,
      ),
      DigitalTherapyMaterial(
        id: 'material_002',
        title: 'Anksiyete Yönetimi Egzersizleri',
        description: 'Anksiyete belirtilerini azaltmak için nefes egzersizleri ve gevşeme teknikleri',
        type: MaterialType.video,
        content: 'Anksiyete yönetimi egzersizleri...',
        tags: ['anksiyete', 'nefes', 'gevşeme'],
        targetDisorders: ['Anksiyete', 'Yaygın Anksiyete Bozukluğu'],
        targetAudience: ['Hasta'],
        difficulty: DifficultyLevel.beginner,
        estimatedDuration: const Duration(minutes: 20),
        instructions: 'Egzersizleri rahat bir ortamda yapın.',
        learningObjectives: 'Anksiyete yönetimi teknikleri öğrenme',
        createdBy: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        isPublic: true,
      ),
      DigitalTherapyMaterial(
        id: 'material_003',
        title: 'Düşünce Kayıtları Çalışma Sayfası',
        description: 'Olumsuz düşünceleri kaydetme ve analiz etme çalışma sayfası',
        type: MaterialType.worksheet,
        content: 'Düşünce kayıtları çalışma sayfası...',
        tags: ['düşünce', 'kayıt', 'analiz'],
        targetDisorders: ['Depresyon', 'Anksiyete'],
        targetAudience: ['Hasta'],
        difficulty: DifficultyLevel.intermediate,
        estimatedDuration: const Duration(minutes: 15),
        instructions: 'Günlük olarak düşüncelerinizi kaydedin.',
        learningObjectives: 'Düşünce kayıtları tutma becerisi geliştirme',
        createdBy: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isPublic: true,
      ),
    ];

    for (final material in demoMaterials) {
      _materials.add(material);
    }

    await _saveMaterials();

    // Add demo assignments
    final demoAssignments = [
      MaterialAssignment(
        id: 'assignment_001',
        materialId: 'material_001',
        patientId: '1',
        assignedBy: 'clinician_001',
        assignedAt: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: AssignmentStatus.inProgress,
        startedAt: DateTime.now().subtract(const Duration(days: 4)),
        progressPercentage: 60.0,
        notes: 'Hasta materyali beğendi',
      ),
      MaterialAssignment(
        id: 'assignment_002',
        materialId: 'material_002',
        patientId: '1',
        assignedBy: 'clinician_001',
        assignedAt: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 4)),
        status: AssignmentStatus.assigned,
        notes: 'Anksiyete yönetimi için önerildi',
      ),
    ];

    for (final assignment in demoAssignments) {
      _assignments.add(assignment);
    }

    await _saveAssignments();

    // Add demo collections
    final demoCollections = [
      MaterialCollection(
        id: 'collection_001',
        name: 'Depresyon Tedavi Paketi',
        description: 'Depresyon tedavisi için kapsamlı materyal paketi',
        materialIds: ['material_001', 'material_003'],
        createdBy: 'clinician_001',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isPublic: true,
      ),
    ];

    for (final collection in demoCollections) {
      _collections.add(collection);
    }

    await _saveCollections();

    print('✅ Demo digital therapy materials created: ${demoMaterials.length}');
    print('✅ Demo material assignments created: ${demoAssignments.length}');
    print('✅ Demo material collections created: ${demoCollections.length}');
  }
}
