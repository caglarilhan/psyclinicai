import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manager_staff_models.dart';

class ManagerStaffService {
  static final ManagerStaffService _instance = ManagerStaffService._internal();
  factory ManagerStaffService() => _instance;
  ManagerStaffService._internal();

  final List<Employee> _employees = [];
  final List<LeaveRequest> _leaveRequests = [];
  final List<PerformanceReview> _performanceReviews = [];
  final List<TrainingProgram> _trainingPrograms = [];
  final List<EmployeeTraining> _employeeTrainings = [];

  // Initialize service
  Future<void> initialize() async {
    await _loadEmployees();
    await _loadLeaveRequests();
    await _loadPerformanceReviews();
    await _loadTrainingPrograms();
    await _loadEmployeeTrainings();
  }

  // Load employees from storage
  Future<void> _loadEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeesJson = prefs.getStringList('manager_staff_employees') ?? [];
      _employees.clear();
      
      for (final employeeJson in employeesJson) {
        final employee = Employee.fromJson(jsonDecode(employeeJson));
        _employees.add(employee);
      }
    } catch (e) {
      print('Error loading employees: $e');
      _employees.clear();
    }
  }

  // Save employees to storage
  Future<void> _saveEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeesJson = _employees
          .map((employee) => jsonEncode(employee.toJson()))
          .toList();
      await prefs.setStringList('manager_staff_employees', employeesJson);
    } catch (e) {
      print('Error saving employees: $e');
    }
  }

  // Load leave requests from storage
  Future<void> _loadLeaveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leaveRequestsJson = prefs.getStringList('manager_staff_leave_requests') ?? [];
      _leaveRequests.clear();
      
      for (final leaveRequestJson in leaveRequestsJson) {
        final leaveRequest = LeaveRequest.fromJson(jsonDecode(leaveRequestJson));
        _leaveRequests.add(leaveRequest);
      }
    } catch (e) {
      print('Error loading leave requests: $e');
      _leaveRequests.clear();
    }
  }

  // Save leave requests to storage
  Future<void> _saveLeaveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leaveRequestsJson = _leaveRequests
          .map((leaveRequest) => jsonEncode(leaveRequest.toJson()))
          .toList();
      await prefs.setStringList('manager_staff_leave_requests', leaveRequestsJson);
    } catch (e) {
      print('Error saving leave requests: $e');
    }
  }

  // Load performance reviews from storage
  Future<void> _loadPerformanceReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final performanceReviewsJson = prefs.getStringList('manager_staff_performance_reviews') ?? [];
      _performanceReviews.clear();
      
      for (final performanceReviewJson in performanceReviewsJson) {
        final performanceReview = PerformanceReview.fromJson(jsonDecode(performanceReviewJson));
        _performanceReviews.add(performanceReview);
      }
    } catch (e) {
      print('Error loading performance reviews: $e');
      _performanceReviews.clear();
    }
  }

  // Save performance reviews to storage
  Future<void> _savePerformanceReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final performanceReviewsJson = _performanceReviews
          .map((performanceReview) => jsonEncode(performanceReview.toJson()))
          .toList();
      await prefs.setStringList('manager_staff_performance_reviews', performanceReviewsJson);
    } catch (e) {
      print('Error saving performance reviews: $e');
    }
  }

  // Load training programs from storage
  Future<void> _loadTrainingPrograms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trainingProgramsJson = prefs.getStringList('manager_staff_training_programs') ?? [];
      _trainingPrograms.clear();
      
      for (final trainingProgramJson in trainingProgramsJson) {
        final trainingProgram = TrainingProgram.fromJson(jsonDecode(trainingProgramJson));
        _trainingPrograms.add(trainingProgram);
      }
    } catch (e) {
      print('Error loading training programs: $e');
      _trainingPrograms.clear();
    }
  }

  // Save training programs to storage
  Future<void> _saveTrainingPrograms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trainingProgramsJson = _trainingPrograms
          .map((trainingProgram) => jsonEncode(trainingProgram.toJson()))
          .toList();
      await prefs.setStringList('manager_staff_training_programs', trainingProgramsJson);
    } catch (e) {
      print('Error saving training programs: $e');
    }
  }

  // Load employee trainings from storage
  Future<void> _loadEmployeeTrainings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeTrainingsJson = prefs.getStringList('manager_staff_employee_trainings') ?? [];
      _employeeTrainings.clear();
      
      for (final employeeTrainingJson in employeeTrainingsJson) {
        final employeeTraining = EmployeeTraining.fromJson(jsonDecode(employeeTrainingJson));
        _employeeTrainings.add(employeeTraining);
      }
    } catch (e) {
      print('Error loading employee trainings: $e');
      _employeeTrainings.clear();
    }
  }

  // Save employee trainings to storage
  Future<void> _saveEmployeeTrainings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeTrainingsJson = _employeeTrainings
          .map((employeeTraining) => jsonEncode(employeeTraining.toJson()))
          .toList();
      await prefs.setStringList('manager_staff_employee_trainings', employeeTrainingsJson);
    } catch (e) {
      print('Error saving employee trainings: $e');
    }
  }

  // Add employee
  Future<Employee> addEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required DateTime birthDate,
    required DateTime hireDate,
    required EmployeeRole role,
    EmployeeStatus status = EmployeeStatus.active,
    String? department,
    String? position,
    double? salary,
    String? emergencyContact,
    String? emergencyPhone,
    String? notes,
    Map<String, dynamic>? documents,
    required String createdBy,
  }) async {
    final employee = Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      birthDate: birthDate,
      hireDate: hireDate,
      role: role,
      status: status,
      department: department,
      position: position,
      salary: salary,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      notes: notes,
      documents: documents,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _employees.add(employee);
    await _saveEmployees();

    return employee;
  }

  // Update employee
  Future<bool> updateEmployee(Employee updatedEmployee, String updatedBy) async {
    try {
      final index = _employees.indexWhere((employee) => employee.id == updatedEmployee.id);
      if (index == -1) return false;

      _employees[index] = updatedEmployee.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: updatedBy,
      );
      
      await _saveEmployees();
      return true;
    } catch (e) {
      print('Error updating employee: $e');
      return false;
    }
  }

  // Delete employee
  Future<bool> deleteEmployee(String employeeId) async {
    try {
      final index = _employees.indexWhere((employee) => employee.id == employeeId);
      if (index == -1) return false;

      _employees.removeAt(index);
      await _saveEmployees();

      return true;
    } catch (e) {
      print('Error deleting employee: $e');
      return false;
    }
  }

  // Add leave request
  Future<LeaveRequest> addLeaveRequest({
    required String employeeId,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? notes,
    required String createdBy,
  }) async {
    final totalDays = endDate.difference(startDate).inDays + 1;

    final leaveRequest = LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      notes: notes,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _leaveRequests.add(leaveRequest);
    await _saveLeaveRequests();

    return leaveRequest;
  }

  // Approve leave request
  Future<bool> approveLeaveRequest(String leaveRequestId, String approvedBy) async {
    try {
      final index = _leaveRequests.indexWhere((request) => request.id == leaveRequestId);
      if (index == -1) return false;

      _leaveRequests[index] = _leaveRequests[index].copyWith(
        status: LeaveStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );

      await _saveLeaveRequests();
      return true;
    } catch (e) {
      print('Error approving leave request: $e');
      return false;
    }
  }

  // Reject leave request
  Future<bool> rejectLeaveRequest(String leaveRequestId, String rejectedBy, String rejectionReason) async {
    try {
      final index = _leaveRequests.indexWhere((request) => request.id == leaveRequestId);
      if (index == -1) return false;

      _leaveRequests[index] = _leaveRequests[index].copyWith(
        status: LeaveStatus.rejected,
        approvedBy: rejectedBy,
        approvedAt: DateTime.now(),
        rejectionReason: rejectionReason,
      );

      await _saveLeaveRequests();
      return true;
    } catch (e) {
      print('Error rejecting leave request: $e');
      return false;
    }
  }

  // Add performance review
  Future<PerformanceReview> addPerformanceReview({
    required String employeeId,
    required DateTime reviewDate,
    required DateTime reviewPeriodStart,
    required DateTime reviewPeriodEnd,
    required PerformanceLevel overallRating,
    required Map<String, PerformanceLevel> categoryRatings,
    required String strengths,
    required String areasForImprovement,
    required String goals,
    required String comments,
    required String reviewedBy,
  }) async {
    final performanceReview = PerformanceReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      reviewDate: reviewDate,
      reviewPeriodStart: reviewPeriodStart,
      reviewPeriodEnd: reviewPeriodEnd,
      overallRating: overallRating,
      categoryRatings: categoryRatings,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      goals: goals,
      comments: comments,
      reviewedBy: reviewedBy,
      createdAt: DateTime.now(),
    );

    _performanceReviews.add(performanceReview);
    await _savePerformanceReviews();

    return performanceReview;
  }

  // Add training program
  Future<TrainingProgram> addTrainingProgram({
    required String title,
    required String description,
    required String category,
    required int duration,
    required DateTime startDate,
    required DateTime endDate,
    String? instructor,
    String? location,
    List<String>? requiredRoles,
    bool isMandatory = false,
    String? certificate,
    required String createdBy,
  }) async {
    final trainingProgram = TrainingProgram(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
      instructor: instructor,
      location: location,
      requiredRoles: requiredRoles ?? [],
      isMandatory: isMandatory,
      certificate: certificate,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _trainingPrograms.add(trainingProgram);
    await _saveTrainingPrograms();

    return trainingProgram;
  }

  // Assign training to employee
  Future<EmployeeTraining> assignTrainingToEmployee({
    required String employeeId,
    required String trainingProgramId,
    required String assignedBy,
  }) async {
    final employeeTraining = EmployeeTraining(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      trainingProgramId: trainingProgramId,
      createdAt: DateTime.now(),
      assignedBy: assignedBy,
    );

    _employeeTrainings.add(employeeTraining);
    await _saveEmployeeTrainings();

    return employeeTraining;
  }

  // Update training status
  Future<bool> updateTrainingStatus(String employeeTrainingId, TrainingStatus status, {double? score, String? certificate}) async {
    try {
      final index = _employeeTrainings.indexWhere((training) => training.id == employeeTrainingId);
      if (index == -1) return false;

      _employeeTrainings[index] = _employeeTrainings[index].copyWith(
        status: status,
        score: score,
        certificate: certificate,
        completionDate: status == TrainingStatus.completed ? DateTime.now() : null,
      );

      await _saveEmployeeTrainings();
      return true;
    } catch (e) {
      print('Error updating training status: $e');
      return false;
    }
  }

  // Get employees by role
  List<Employee> getEmployeesByRole(EmployeeRole role) {
    return _employees
        .where((employee) => employee.role == role)
        .toList()
        ..sort((a, b) => a.lastName.compareTo(b.lastName));
  }

  // Get employees by status
  List<Employee> getEmployeesByStatus(EmployeeStatus status) {
    return _employees
        .where((employee) => employee.status == status)
        .toList()
        ..sort((a, b) => a.lastName.compareTo(b.lastName));
  }

  // Get active employees
  List<Employee> getActiveEmployees() {
    return _employees
        .where((employee) => employee.status == EmployeeStatus.active)
        .toList()
        ..sort((a, b) => a.lastName.compareTo(b.lastName));
  }

  // Get leave requests by status
  List<LeaveRequest> getLeaveRequestsByStatus(LeaveStatus status) {
    return _leaveRequests
        .where((request) => request.status == status)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get pending leave requests
  List<LeaveRequest> getPendingLeaveRequests() {
    return _leaveRequests
        .where((request) => request.status == LeaveStatus.pending)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get performance reviews for employee
  List<PerformanceReview> getPerformanceReviewsForEmployee(String employeeId) {
    return _performanceReviews
        .where((review) => review.employeeId == employeeId)
        .toList()
        ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
  }

  // Get training programs by category
  List<TrainingProgram> getTrainingProgramsByCategory(String category) {
    return _trainingPrograms
        .where((program) => program.category == category)
        .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  // Get employee trainings by status
  List<EmployeeTraining> getEmployeeTrainingsByStatus(TrainingStatus status) {
    return _employeeTrainings
        .where((training) => training.status == status)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get employee statistics
  Map<String, dynamic> getEmployeeStatistics() {
    final totalEmployees = _employees.length;
    final activeEmployees = _employees.where((e) => e.status == EmployeeStatus.active).length;
    final inactiveEmployees = _employees.where((e) => e.status == EmployeeStatus.inactive).length;
    final terminatedEmployees = _employees.where((e) => e.status == EmployeeStatus.terminated).length;
    final onLeaveEmployees = _employees.where((e) => e.status == EmployeeStatus.onLeave).length;

    final employeesByRole = <String, int>{};
    for (final employee in _employees) {
      final roleName = employee.role.toString().split('.').last;
      employeesByRole[roleName] = (employeesByRole[roleName] ?? 0) + 1;
    }

    final pendingLeaveRequests = _leaveRequests.where((r) => r.status == LeaveStatus.pending).length;
    final approvedLeaveRequests = _leaveRequests.where((r) => r.status == LeaveStatus.approved).length;
    final rejectedLeaveRequests = _leaveRequests.where((r) => r.status == LeaveStatus.rejected).length;

    final totalPerformanceReviews = _performanceReviews.length;
    final excellentReviews = _performanceReviews.where((r) => r.overallRating == PerformanceLevel.excellent).length;
    final goodReviews = _performanceReviews.where((r) => r.overallRating == PerformanceLevel.good).length;
    final satisfactoryReviews = _performanceReviews.where((r) => r.overallRating == PerformanceLevel.satisfactory).length;

    final totalTrainingPrograms = _trainingPrograms.length;
    final mandatoryPrograms = _trainingPrograms.where((p) => p.isMandatory).length;
    final totalEmployeeTrainings = _employeeTrainings.length;
    final completedTrainings = _employeeTrainings.where((t) => t.status == TrainingStatus.completed).length;
    final inProgressTrainings = _employeeTrainings.where((t) => t.status == TrainingStatus.inProgress).length;

    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'inactiveEmployees': inactiveEmployees,
      'terminatedEmployees': terminatedEmployees,
      'onLeaveEmployees': onLeaveEmployees,
      'employeesByRole': employeesByRole,
      'pendingLeaveRequests': pendingLeaveRequests,
      'approvedLeaveRequests': approvedLeaveRequests,
      'rejectedLeaveRequests': rejectedLeaveRequests,
      'totalPerformanceReviews': totalPerformanceReviews,
      'excellentReviews': excellentReviews,
      'goodReviews': goodReviews,
      'satisfactoryReviews': satisfactoryReviews,
      'totalTrainingPrograms': totalTrainingPrograms,
      'mandatoryPrograms': mandatoryPrograms,
      'totalEmployeeTrainings': totalEmployeeTrainings,
      'completedTrainings': completedTrainings,
      'inProgressTrainings': inProgressTrainings,
    };
  }

  // Generate demo data
  Future<void> generateDemoData() async {
    if (_employees.isNotEmpty) return;

    // Add demo employees
    final demoEmployees = [
      Employee(
        id: 'emp_001',
        firstName: 'Dr. Ahmet',
        lastName: 'Yılmaz',
        email: 'ahmet.yilmaz@psyclinic.com',
        phone: '+90 532 123 4567',
        address: 'İstanbul, Türkiye',
        birthDate: DateTime(1980, 5, 15),
        hireDate: DateTime(2020, 1, 15),
        role: EmployeeRole.doctor,
        status: EmployeeStatus.active,
        department: 'Psikiyatri',
        position: 'Başhekim',
        salary: 25000.0,
        emergencyContact: 'Ayşe Yılmaz',
        emergencyPhone: '+90 532 987 6543',
        notes: 'Deneyimli psikiyatrist',
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Employee(
        id: 'emp_002',
        firstName: 'Psikolog',
        lastName: 'Fatma Demir',
        email: 'fatma.demir@psyclinic.com',
        phone: '+90 532 234 5678',
        address: 'Ankara, Türkiye',
        birthDate: DateTime(1985, 8, 22),
        hireDate: DateTime(2021, 3, 10),
        role: EmployeeRole.psychologist,
        status: EmployeeStatus.active,
        department: 'Psikoloji',
        position: 'Klinik Psikolog',
        salary: 18000.0,
        emergencyContact: 'Mehmet Demir',
        emergencyPhone: '+90 532 876 5432',
        notes: 'Bilişsel davranışçı terapi uzmanı',
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Employee(
        id: 'emp_003',
        firstName: 'Hemşire',
        lastName: 'Zeynep Kaya',
        email: 'zeynep.kaya@psyclinic.com',
        phone: '+90 532 345 6789',
        address: 'İzmir, Türkiye',
        birthDate: DateTime(1990, 12, 5),
        hireDate: DateTime(2022, 6, 1),
        role: EmployeeRole.nurse,
        status: EmployeeStatus.active,
        department: 'Hemşirelik',
        position: 'Başhemşire',
        salary: 12000.0,
        emergencyContact: 'Ali Kaya',
        emergencyPhone: '+90 532 765 4321',
        notes: 'Psikiyatri hemşiresi',
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    for (final employee in demoEmployees) {
      _employees.add(employee);
    }

    await _saveEmployees();

    // Add demo leave requests
    final demoLeaveRequests = [
      LeaveRequest(
        id: 'leave_001',
        employeeId: 'emp_001',
        type: LeaveType.annual,
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 17)),
        totalDays: 8,
        reason: 'Yıllık izin',
        status: LeaveStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'emp_001',
      ),
      LeaveRequest(
        id: 'leave_002',
        employeeId: 'emp_002',
        type: LeaveType.sick,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        totalDays: 4,
        reason: 'Hastalık izni',
        status: LeaveStatus.approved,
        approvedBy: 'manager_001',
        approvedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        createdBy: 'emp_002',
      ),
    ];

    for (final leaveRequest in demoLeaveRequests) {
      _leaveRequests.add(leaveRequest);
    }

    await _saveLeaveRequests();

    // Add demo performance reviews
    final demoPerformanceReviews = [
      PerformanceReview(
        id: 'review_001',
        employeeId: 'emp_001',
        reviewDate: DateTime.now().subtract(const Duration(days: 30)),
        reviewPeriodStart: DateTime(2023, 1, 1),
        reviewPeriodEnd: DateTime(2023, 12, 31),
        overallRating: PerformanceLevel.excellent,
        categoryRatings: {
          'Clinical Skills': PerformanceLevel.excellent,
          'Communication': PerformanceLevel.good,
          'Leadership': PerformanceLevel.excellent,
          'Teamwork': PerformanceLevel.good,
        },
        strengths: 'Mükemmel klinik beceriler, güçlü liderlik',
        areasForImprovement: 'İletişim becerilerini geliştirebilir',
        goals: 'Ekip yönetimi ve hasta memnuniyetini artırma',
        comments: 'Çok başarılı bir yıl geçirdi',
        reviewedBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    for (final performanceReview in demoPerformanceReviews) {
      _performanceReviews.add(performanceReview);
    }

    await _savePerformanceReviews();

    // Add demo training programs
    final demoTrainingPrograms = [
      TrainingProgram(
        id: 'training_001',
        title: 'Psikiyatri Temel Eğitimi',
        description: 'Psikiyatri temel kavramları ve uygulamaları',
        category: 'Klinik',
        duration: 40,
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 37)),
        instructor: 'Dr. Ahmet Yılmaz',
        location: 'Eğitim Salonu',
        requiredRoles: ['doctor', 'psychologist', 'nurse'],
        isMandatory: true,
        certificate: 'Psikiyatri Temel Sertifikası',
        createdBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    for (final trainingProgram in demoTrainingPrograms) {
      _trainingPrograms.add(trainingProgram);
    }

    await _saveTrainingPrograms();

    // Add demo employee trainings
    final demoEmployeeTrainings = [
      EmployeeTraining(
        id: 'emp_training_001',
        employeeId: 'emp_002',
        trainingProgramId: 'training_001',
        status: TrainingStatus.inProgress,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        assignedBy: 'manager_001',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    for (final employeeTraining in demoEmployeeTrainings) {
      _employeeTrainings.add(employeeTraining);
    }

    await _saveEmployeeTrainings();

    print('✅ Demo manager staff data created:');
    print('   - Employees: ${demoEmployees.length}');
    print('   - Leave requests: ${demoLeaveRequests.length}');
    print('   - Performance reviews: ${demoPerformanceReviews.length}');
    print('   - Training programs: ${demoTrainingPrograms.length}');
    print('   - Employee trainings: ${demoEmployeeTrainings.length}');
  }
}
