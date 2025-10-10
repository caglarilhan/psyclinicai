import 'dart:convert';

enum EmploymentStatus { active, inactive, terminated, onLeave, probation }
enum PerformanceRating { excellent, good, satisfactory, needsImprovement, unsatisfactory }
enum RecruitmentStatus { open, screening, interviewing, offer, hired, rejected }
enum TrainingStatus { pending, inProgress, completed, failed, expired }

class Employee {
  final String id;
  final String employeeNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String position;
  final String department;
  final EmploymentStatus status;
  final DateTime hireDate;
  final DateTime? terminationDate;
  final double salary;
  final String managerId;
  final List<String> skills;
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> emergencyContacts;
  final Map<String, dynamic> metadata;

  Employee({
    required this.id,
    required this.employeeNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.status,
    required this.hireDate,
    this.terminationDate,
    required this.salary,
    required this.managerId,
    required this.skills,
    required this.personalInfo,
    required this.emergencyContacts,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeNumber': employeeNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'status': status.name,
      'hireDate': hireDate.toIso8601String(),
      'terminationDate': terminationDate?.toIso8601String(),
      'salary': salary,
      'managerId': managerId,
      'skills': skills,
      'personalInfo': personalInfo,
      'emergencyContacts': emergencyContacts,
      'metadata': metadata,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeNumber: json['employeeNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      department: json['department'],
      status: EmploymentStatus.values.firstWhere((e) => e.name == json['status']),
      hireDate: DateTime.parse(json['hireDate']),
      terminationDate: json['terminationDate'] != null ? DateTime.parse(json['terminationDate']) : null,
      salary: json['salary'].toDouble(),
      managerId: json['managerId'],
      skills: List<String>.from(json['skills']),
      personalInfo: Map<String, dynamic>.from(json['personalInfo']),
      emergencyContacts: Map<String, dynamic>.from(json['emergencyContacts']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class PerformanceReview {
  final String id;
  final String employeeId;
  final String reviewerId;
  final DateTime reviewDate;
  final DateTime reviewPeriodStart;
  final DateTime reviewPeriodEnd;
  final Map<String, PerformanceRating> ratings;
  final Map<String, double> goals;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> developmentGoals;
  final String overallComment;
  final String employeeComment;
  final String reviewerComment;
  final DateTime nextReviewDate;
  final Map<String, dynamic> metadata;

  PerformanceReview({
    required this.id,
    required this.employeeId,
    required this.reviewerId,
    required this.reviewDate,
    required this.reviewPeriodStart,
    required this.reviewPeriodEnd,
    required this.ratings,
    required this.goals,
    required this.strengths,
    required this.areasForImprovement,
    required this.developmentGoals,
    required this.overallComment,
    required this.employeeComment,
    required this.reviewerComment,
    required this.nextReviewDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'reviewerId': reviewerId,
      'reviewDate': reviewDate.toIso8601String(),
      'reviewPeriodStart': reviewPeriodStart.toIso8601String(),
      'reviewPeriodEnd': reviewPeriodEnd.toIso8601String(),
      'ratings': ratings.map((k, v) => MapEntry(k, v.name)),
      'goals': goals,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'developmentGoals': developmentGoals,
      'overallComment': overallComment,
      'employeeComment': employeeComment,
      'reviewerComment': reviewerComment,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: json['id'],
      employeeId: json['employeeId'],
      reviewerId: json['reviewerId'],
      reviewDate: DateTime.parse(json['reviewDate']),
      reviewPeriodStart: DateTime.parse(json['reviewPeriodStart']),
      reviewPeriodEnd: DateTime.parse(json['reviewPeriodEnd']),
      ratings: (json['ratings'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, PerformanceRating.values.firstWhere((e) => e.name == v)),
      ),
      goals: Map<String, double>.from(json['goals']),
      strengths: List<String>.from(json['strengths']),
      areasForImprovement: List<String>.from(json['areasForImprovement']),
      developmentGoals: List<String>.from(json['developmentGoals']),
      overallComment: json['overallComment'],
      employeeComment: json['employeeComment'],
      reviewerComment: json['reviewerComment'],
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class Recruitment {
  final String id;
  final String position;
  final String department;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final double salaryRange;
  final RecruitmentStatus status;
  final DateTime postedDate;
  final DateTime? closingDate;
  final String hiringManagerId;
  final List<String> applicants;
  final Map<String, dynamic> metadata;

  Recruitment({
    required this.id,
    required this.position,
    required this.department,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.salaryRange,
    required this.status,
    required this.postedDate,
    this.closingDate,
    required this.hiringManagerId,
    required this.applicants,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'department': department,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'salaryRange': salaryRange,
      'status': status.name,
      'postedDate': postedDate.toIso8601String(),
      'closingDate': closingDate?.toIso8601String(),
      'hiringManagerId': hiringManagerId,
      'applicants': applicants,
      'metadata': metadata,
    };
  }

  factory Recruitment.fromJson(Map<String, dynamic> json) {
    return Recruitment(
      id: json['id'],
      position: json['position'],
      department: json['department'],
      description: json['description'],
      requirements: List<String>.from(json['requirements']),
      responsibilities: List<String>.from(json['responsibilities']),
      salaryRange: json['salaryRange'].toDouble(),
      status: RecruitmentStatus.values.firstWhere((e) => e.name == json['status']),
      postedDate: DateTime.parse(json['postedDate']),
      closingDate: json['closingDate'] != null ? DateTime.parse(json['closingDate']) : null,
      hiringManagerId: json['hiringManagerId'],
      applicants: List<String>.from(json['applicants']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class JobApplication {
  final String id;
  final String recruitmentId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String resume;
  final String coverLetter;
  final Map<String, dynamic> experience;
  final List<String> skills;
  final List<String> education;
  final RecruitmentStatus status;
  final DateTime applicationDate;
  final DateTime? interviewDate;
  final String notes;
  final Map<String, dynamic> metadata;

  JobApplication({
    required this.id,
    required this.recruitmentId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.resume,
    required this.coverLetter,
    required this.experience,
    required this.skills,
    required this.education,
    required this.status,
    required this.applicationDate,
    this.interviewDate,
    required this.notes,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruitmentId': recruitmentId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'resume': resume,
      'coverLetter': coverLetter,
      'experience': experience,
      'skills': skills,
      'education': education,
      'status': status.name,
      'applicationDate': applicationDate.toIso8601String(),
      'interviewDate': interviewDate?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      recruitmentId: json['recruitmentId'],
      applicantName: json['applicantName'],
      applicantEmail: json['applicantEmail'],
      applicantPhone: json['applicantPhone'],
      resume: json['resume'],
      coverLetter: json['coverLetter'],
      experience: Map<String, dynamic>.from(json['experience']),
      skills: List<String>.from(json['skills']),
      education: List<String>.from(json['education']),
      status: RecruitmentStatus.values.firstWhere((e) => e.name == json['status']),
      applicationDate: DateTime.parse(json['applicationDate']),
      interviewDate: json['interviewDate'] != null ? DateTime.parse(json['interviewDate']) : null,
      notes: json['notes'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class TrainingProgram {
  final String id;
  final String title;
  final String description;
  final String category;
  final String provider;
  final int duration; // hours
  final double cost;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> targetAudience;
  final List<String> objectives;
  final List<String> prerequisites;
  final String format; // online, in-person, hybrid
  final int maxParticipants;
  final List<String> enrolledEmployees;
  final TrainingStatus status;
  final Map<String, dynamic> metadata;

  TrainingProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.provider,
    required this.duration,
    required this.cost,
    required this.startDate,
    required this.endDate,
    required this.targetAudience,
    required this.objectives,
    required this.prerequisites,
    required this.format,
    required this.maxParticipants,
    required this.enrolledEmployees,
    required this.status,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'provider': provider,
      'duration': duration,
      'cost': cost,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetAudience': targetAudience,
      'objectives': objectives,
      'prerequisites': prerequisites,
      'format': format,
      'maxParticipants': maxParticipants,
      'enrolledEmployees': enrolledEmployees,
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      provider: json['provider'],
      duration: json['duration'],
      cost: json['cost'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      targetAudience: List<String>.from(json['targetAudience']),
      objectives: List<String>.from(json['objectives']),
      prerequisites: List<String>.from(json['prerequisites']),
      format: json['format'],
      maxParticipants: json['maxParticipants'],
      enrolledEmployees: List<String>.from(json['enrolledEmployees']),
      status: TrainingStatus.values.firstWhere((e) => e.name == json['status']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class TrainingRecord {
  final String id;
  final String employeeId;
  final String trainingProgramId;
  final DateTime enrollmentDate;
  final DateTime? completionDate;
  final TrainingStatus status;
  final double? score;
  final String? certificate;
  final String? feedback;
  final Map<String, dynamic> progress;
  final Map<String, dynamic> metadata;

  TrainingRecord({
    required this.id,
    required this.employeeId,
    required this.trainingProgramId,
    required this.enrollmentDate,
    this.completionDate,
    required this.status,
    this.score,
    this.certificate,
    this.feedback,
    this.progress = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'trainingProgramId': trainingProgramId,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'status': status.name,
      'score': score,
      'certificate': certificate,
      'feedback': feedback,
      'progress': progress,
      'metadata': metadata,
    };
  }

  factory TrainingRecord.fromJson(Map<String, dynamic> json) {
    return TrainingRecord(
      id: json['id'],
      employeeId: json['employeeId'],
      trainingProgramId: json['trainingProgramId'],
      enrollmentDate: DateTime.parse(json['enrollmentDate']),
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      status: TrainingStatus.values.firstWhere((e) => e.name == json['status']),
      score: json['score']?.toDouble(),
      certificate: json['certificate'],
      feedback: json['feedback'],
      progress: json['progress'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }
}

class CareerDevelopment {
  final String id;
  final String employeeId;
  final String currentPosition;
  final String targetPosition;
  final List<String> careerGoals;
  final List<String> requiredSkills;
  final List<String> currentSkills;
  final List<String> skillGaps;
  final List<String> developmentActions;
  final DateTime targetDate;
  final String mentorId;
  final String status;
  final Map<String, dynamic> progress;
  final Map<String, dynamic> metadata;

  CareerDevelopment({
    required this.id,
    required this.employeeId,
    required this.currentPosition,
    required this.targetPosition,
    required this.careerGoals,
    required this.requiredSkills,
    required this.currentSkills,
    required this.skillGaps,
    required this.developmentActions,
    required this.targetDate,
    required this.mentorId,
    required this.status,
    this.progress = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'currentPosition': currentPosition,
      'targetPosition': targetPosition,
      'careerGoals': careerGoals,
      'requiredSkills': requiredSkills,
      'currentSkills': currentSkills,
      'skillGaps': skillGaps,
      'developmentActions': developmentActions,
      'targetDate': targetDate.toIso8601String(),
      'mentorId': mentorId,
      'status': status,
      'progress': progress,
      'metadata': metadata,
    };
  }

  factory CareerDevelopment.fromJson(Map<String, dynamic> json) {
    return CareerDevelopment(
      id: json['id'],
      employeeId: json['employeeId'],
      currentPosition: json['currentPosition'],
      targetPosition: json['targetPosition'],
      careerGoals: List<String>.from(json['careerGoals']),
      requiredSkills: List<String>.from(json['requiredSkills']),
      currentSkills: List<String>.from(json['currentSkills']),
      skillGaps: List<String>.from(json['skillGaps']),
      developmentActions: List<String>.from(json['developmentActions']),
      targetDate: DateTime.parse(json['targetDate']),
      mentorId: json['mentorId'],
      status: json['status'],
      progress: json['progress'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }
}

class HRMetrics {
  final String id;
  final String organizationId;
  final DateTime reportDate;
  final Map<String, int> headcountByDepartment;
  final Map<String, double> turnoverRate;
  final Map<String, double> retentionRate;
  final Map<String, double> satisfactionScore;
  final Map<String, double> trainingCompletionRate;
  final Map<String, double> averagePerformanceRating;
  final Map<String, double> timeToHire;
  final Map<String, double> costPerHire;
  final Map<String, dynamic> diversityMetrics;
  final Map<String, dynamic> metadata;

  HRMetrics({
    required this.id,
    required this.organizationId,
    required this.reportDate,
    required this.headcountByDepartment,
    required this.turnoverRate,
    required this.retentionRate,
    required this.satisfactionScore,
    required this.trainingCompletionRate,
    required this.averagePerformanceRating,
    required this.timeToHire,
    required this.costPerHire,
    required this.diversityMetrics,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'reportDate': reportDate.toIso8601String(),
      'headcountByDepartment': headcountByDepartment,
      'turnoverRate': turnoverRate,
      'retentionRate': retentionRate,
      'satisfactionScore': satisfactionScore,
      'trainingCompletionRate': trainingCompletionRate,
      'averagePerformanceRating': averagePerformanceRating,
      'timeToHire': timeToHire,
      'costPerHire': costPerHire,
      'diversityMetrics': diversityMetrics,
      'metadata': metadata,
    };
  }

  factory HRMetrics.fromJson(Map<String, dynamic> json) {
    return HRMetrics(
      id: json['id'],
      organizationId: json['organizationId'],
      reportDate: DateTime.parse(json['reportDate']),
      headcountByDepartment: Map<String, int>.from(json['headcountByDepartment']),
      turnoverRate: Map<String, double>.from(json['turnoverRate']),
      retentionRate: Map<String, double>.from(json['retentionRate']),
      satisfactionScore: Map<String, double>.from(json['satisfactionScore']),
      trainingCompletionRate: Map<String, double>.from(json['trainingCompletionRate']),
      averagePerformanceRating: Map<String, double>.from(json['averagePerformanceRating']),
      timeToHire: Map<String, double>.from(json['timeToHire']),
      costPerHire: Map<String, double>.from(json['costPerHire']),
      diversityMetrics: Map<String, dynamic>.from(json['diversityMetrics']),
      metadata: json['metadata'] ?? {},
    );
  }
}
