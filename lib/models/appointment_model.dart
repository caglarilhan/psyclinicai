class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String status;
  final String notes;
  final String location;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    required this.notes,
    required this.location,
    this.isRecurring = false,
    this.recurringPattern,
    required this.createdAt,
    required this.updatedAt,
  });

  Duration get duration => endTime.difference(startTime);

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
           startTime.month == now.month &&
           startTime.day == now.day;
  }

  bool get isUpcoming {
    return startTime.isAfter(DateTime.now());
  }

  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'status': status,
      'notes': notes,
      'location': location,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: json['type'],
      status: json['status'],
      notes: json['notes'],
      location: json['location'],
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Appointment copyWith({
    String? id,
    String? clientId,
    String? clientName,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    String? status,
    String? notes,
    String? location,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
