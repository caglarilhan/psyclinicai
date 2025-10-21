import 'package:flutter/foundation.dart';

enum EmployeeStatus { active, inactive, terminated, onLeave, suspended }
enum EmployeeRole { doctor, psychologist, nurse, secretary, manager, technician, other }
enum LeaveType { annual, sick, personal, maternity, paternity, unpaid, other }
enum LeaveStatus { pending, approved, rejected, cancelled }
enum PerformanceLevel { excellent, good, satisfactory, needsImprovement, poor }
enum TrainingStatus { notStarted, inProgress, completed, failed, expired }

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final DateTime birthDate;
  final DateTime hireDate;
  final EmployeeRole role;
  final EmployeeStatus status;
  final String? department;
  final String? position;
  final double? salary;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? notes;
  final Map<String, dynamic>? documents;
  final DateTime createdAt;
  DateTime? updatedAt;
  final String createdBy;
  final String? updatedBy;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.hireDate,
    required this.role,
    this.status = EmployeeStatus.active,
    this.department,
    this.position,
    this.salary,
    this.emergencyContact,
    this.emergencyPhone,
    this.notes,
    this.documents,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    DateTime? birthDate,
    DateTime? hireDate,
    EmployeeRole? role,
    EmployeeStatus? status,
    String? department,
    String? position,
    double? salary,
    String? emergencyContact,
    String? emergencyPhone,
    String? notes,
    Map<String, dynamic>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      hireDate: hireDate ?? this.hireDate,
      role: role ?? this.role,
      status: status ?? this.status,
      department: department ?? this.department,
      position: position ?? this.position,
      salary: salary ?? this.salary,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      notes: notes ?? this.notes,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'birthDate': birthDate.toIso8601String(),
      'hireDate': hireDate.toIso8601String(),
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'department': department,
      'position': position,
      'salary': salary,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'notes': notes,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      hireDate: DateTime.parse(json['hireDate'] as String),
      role: EmployeeRole.values.firstWhere(
          (e) => e.toString().split('.').last == json['role'] as String),
      status: EmployeeStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      department: json['department'] as String?,
      position: json['position'] as String?,
      salary: (json['salary'] as num?)?.toDouble(),
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      notes: json['notes'] as String?,
      documents: json['documents'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final LeaveStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? reason,
    LeaveStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'type': type.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status.toString().split('.').last,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      type: LeaveType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDays: json['totalDays'] as int,
      reason: json['reason'] as String,
      status: LeaveStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }
}

class PerformanceReview {
  final String id;
  final String employeeId;
  final DateTime reviewDate;
  final DateTime reviewPeriodStart;
  final DateTime reviewPeriodEnd;
  final PerformanceLevel overallRating;
  final Map<String, PerformanceLevel> categoryRatings;
  final String strengths;
  final String areasForImprovement;
  final String goals;
  final String comments;
  final String reviewedBy;
  final DateTime createdAt;
  final String? employeeComments;
  final DateTime? employeeCommentsDate;

  PerformanceReview({
    required this.id,
    required this.employeeId,
    required this.reviewDate,
    required this.reviewPeriodStart,
    required this.reviewPeriodEnd,
    required this.overallRating,
    required this.categoryRatings,
    required this.strengths,
    required this.areasForImprovement,
    required this.goals,
    required this.comments,
    required this.reviewedBy,
    required this.createdAt,
    this.employeeComments,
    this.employeeCommentsDate,
  });

  PerformanceReview copyWith({
    String? id,
    String? employeeId,
    DateTime? reviewDate,
    DateTime? reviewPeriodStart,
    DateTime? reviewPeriodEnd,
    PerformanceLevel? overallRating,
    Map<String, PerformanceLevel>? categoryRatings,
    String? strengths,
    String? areasForImprovement,
    String? goals,
    String? comments,
    String? reviewedBy,
    DateTime? createdAt,
    String? employeeComments,
    DateTime? employeeCommentsDate,
  }) {
    return PerformanceReview(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewPeriodStart: reviewPeriodStart ?? this.reviewPeriodStart,
      reviewPeriodEnd: reviewPeriodEnd ?? this.reviewPeriodEnd,
      overallRating: overallRating ?? this.overallRating,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      goals: goals ?? this.goals,
      comments: comments ?? this.comments,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      createdAt: createdAt ?? this.createdAt,
      employeeComments: employeeComments ?? this.employeeComments,
      employeeCommentsDate: employeeCommentsDate ?? this.employeeCommentsDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'reviewDate': reviewDate.toIso8601String(),
      'reviewPeriodStart': reviewPeriodStart.toIso8601String(),
      'reviewPeriodEnd': reviewPeriodEnd.toIso8601String(),
      'overallRating': overallRating.toString().split('.').last,
      'categoryRatings': categoryRatings.map((key, value) => 
          MapEntry(key, value.toString().split('.').last)),
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'goals': goals,
      'comments': comments,
      'reviewedBy': reviewedBy,
      'createdAt': createdAt.toIso8601String(),
      'employeeComments': employeeComments,
      'employeeCommentsDate': employeeCommentsDate?.toIso8601String(),
    };
  }

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      reviewDate: DateTime.parse(json['reviewDate'] as String),
      reviewPeriodStart: DateTime.parse(json['reviewPeriodStart'] as String),
      reviewPeriodEnd: DateTime.parse(json['reviewPeriodEnd'] as String),
      overallRating: PerformanceLevel.values.firstWhere(
          (e) => e.toString().split('.').last == json['overallRating'] as String),
      categoryRatings: (json['categoryRatings'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, PerformanceLevel.values.firstWhere(
              (e) => e.toString().split('.').last == value as String))),
      strengths: json['strengths'] as String,
      areasForImprovement: json['areasForImprovement'] as String,
      goals: json['goals'] as String,
      comments: json['comments'] as String,
      reviewedBy: json['reviewedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      employeeComments: json['employeeComments'] as String?,
      employeeCommentsDate: json['employeeCommentsDate'] != null
          ? DateTime.parse(json['employeeCommentsDate'] as String)
          : null,
    );
  }
}

class TrainingProgram {
  final String id;
  final String title;
  final String description;
  final String category;
  final int duration; // in hours
  final DateTime startDate;
  final DateTime endDate;
  final String? instructor;
  final String? location;
  final List<String> requiredRoles;
  final bool isMandatory;
  final String? certificate;
  final DateTime createdAt;
  final String createdBy;

  TrainingProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.startDate,
    required this.endDate,
    this.instructor,
    this.location,
    this.requiredRoles = const [],
    this.isMandatory = false,
    this.certificate,
    required this.createdAt,
    required this.createdBy,
  });

  TrainingProgram copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    DateTime? startDate,
    DateTime? endDate,
    String? instructor,
    String? location,
    List<String>? requiredRoles,
    bool? isMandatory,
    String? certificate,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructor: instructor ?? this.instructor,
      location: location ?? this.location,
      requiredRoles: requiredRoles ?? this.requiredRoles,
      isMandatory: isMandatory ?? this.isMandatory,
      certificate: certificate ?? this.certificate,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'instructor': instructor,
      'location': location,
      'requiredRoles': requiredRoles,
      'isMandatory': isMandatory,
      'certificate': certificate,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      duration: json['duration'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      instructor: json['instructor'] as String?,
      location: json['location'] as String?,
      requiredRoles: List<String>.from(json['requiredRoles'] as List),
      isMandatory: json['isMandatory'] as bool,
      certificate: json['certificate'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }
}

class EmployeeTraining {
  final String id;
  final String employeeId;
  final String trainingProgramId;
  final TrainingStatus status;
  final DateTime? startDate;
  final DateTime? completionDate;
  final double? score;
  final String? certificate;
  final String? notes;
  final DateTime createdAt;
  final String assignedBy;

  EmployeeTraining({
    required this.id,
    required this.employeeId,
    required this.trainingProgramId,
    this.status = TrainingStatus.notStarted,
    this.startDate,
    this.completionDate,
    this.score,
    this.certificate,
    this.notes,
    required this.createdAt,
    required this.assignedBy,
  });

  EmployeeTraining copyWith({
    String? id,
    String? employeeId,
    String? trainingProgramId,
    TrainingStatus? status,
    DateTime? startDate,
    DateTime? completionDate,
    double? score,
    String? certificate,
    String? notes,
    DateTime? createdAt,
    String? assignedBy,
  }) {
    return EmployeeTraining(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      trainingProgramId: trainingProgramId ?? this.trainingProgramId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      score: score ?? this.score,
      certificate: certificate ?? this.certificate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      assignedBy: assignedBy ?? this.assignedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'trainingProgramId': trainingProgramId,
      'status': status.toString().split('.').last,
      'startDate': startDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'score': score,
      'certificate': certificate,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'assignedBy': assignedBy,
    };
  }

  factory EmployeeTraining.fromJson(Map<String, dynamic> json) {
    return EmployeeTraining(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      trainingProgramId: json['trainingProgramId'] as String,
      status: TrainingStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      score: (json['score'] as num?)?.toDouble(),
      certificate: json['certificate'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedBy: json['assignedBy'] as String,
    );
  }
}
