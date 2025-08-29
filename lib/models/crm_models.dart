import 'package:flutter/material.dart';

enum SalesStatus { lead, qualified, proposal, negotiation, closed, lost }
enum ActivityType { customerAdded, opportunityCreated, dealClosed, followUp }
enum CustomerType { individual, business, healthcare, education, government }

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final CustomerType type;
  final String company;
  final String position;
  final String address;
  final DateTime createdAt;
  final DateTime lastContact;
  final double lifetimeValue;
  final List<String> tags;
  final Map<String, dynamic> customFields;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    this.company = '',
    this.position = '',
    this.address = '',
    required this.createdAt,
    required this.lastContact,
    this.lifetimeValue = 0.0,
    this.tags = const [],
    this.customFields = const {},
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      type: CustomerType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastContact: DateTime.parse(json['lastContact']),
      lifetimeValue: json['lifetimeValue']?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type.toString().split('.').last,
      'company': company,
      'position': position,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastContact': lastContact.toIso8601String(),
      'lifetimeValue': lifetimeValue,
      'tags': tags,
      'customFields': customFields,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    CustomerType? type,
    String? company,
    String? position,
    String? address,
    DateTime? createdAt,
    DateTime? lastContact,
    double? lifetimeValue,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      company: company ?? this.company,
      position: position ?? this.position,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastContact: lastContact ?? this.lastContact,
      lifetimeValue: lifetimeValue ?? this.lifetimeValue,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }
}

class SalesOpportunity {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final String description;
  final SalesStatus status;
  final double value;
  final double probability;
  final DateTime expectedCloseDate;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String assignedTo;
  final List<String> tags;
  final Map<String, dynamic> customFields;

  SalesOpportunity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.description,
    required this.status,
    required this.value,
    required this.probability,
    required this.expectedCloseDate,
    required this.createdAt,
    required this.lastUpdated,
    required this.assignedTo,
    this.tags = const [],
    this.customFields = const {},
  });

  factory SalesOpportunity.fromJson(Map<String, dynamic> json) {
    return SalesOpportunity(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      title: json['title'],
      description: json['description'],
      status: SalesStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      value: json['value']?.toDouble() ?? 0.0,
      probability: json['probability']?.toDouble() ?? 0.0,
      expectedCloseDate: DateTime.parse(json['expectedCloseDate']),
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      assignedTo: json['assignedTo'],
      tags: List<String>.from(json['tags'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'value': value,
      'probability': probability,
      'expectedCloseDate': expectedCloseDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'assignedTo': assignedTo,
      'tags': tags,
      'customFields': customFields,
    };
  }

  double get weightedValue => value * probability;

  bool get isActive => status != SalesStatus.closed && status != SalesStatus.lost;

  SalesOpportunity copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? title,
    String? description,
    SalesStatus? status,
    double? value,
    double? probability,
    DateTime? expectedCloseDate,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? assignedTo,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return SalesOpportunity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      value: value ?? this.value,
      probability: probability ?? this.probability,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }
}

class CRMActivity {
  final String id;
  final ActivityType type;
  final String description;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String? customerId;
  final String? opportunityId;
  final Map<String, dynamic> metadata;

  CRMActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.userId,
    required this.userName,
    this.customerId,
    this.opportunityId,
    this.metadata = const {},
  });

  factory CRMActivity.fromJson(Map<String, dynamic> json) {
    return CRMActivity(
      id: json['id'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userName: json['userName'],
      customerId: json['customerId'],
      opportunityId: json['opportunityId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'customerId': customerId,
      'opportunityId': opportunityId,
      'metadata': metadata,
    };
  }
}

class CustomerSegment {
  final String id;
  final String name;
  final String description;
  final Color color;
  final int customerCount;
  final double averageValue;
  final List<String> criteria;

  CustomerSegment({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.customerCount,
    required this.averageValue,
    required this.criteria,
  });

  factory CustomerSegment.fromJson(Map<String, dynamic> json) {
    return CustomerSegment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: Color(json['color']),
      customerCount: json['customerCount'],
      averageValue: json['averageValue']?.toDouble() ?? 0.0,
      criteria: List<String>.from(json['criteria'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'customerCount': customerCount,
      'averageValue': averageValue,
      'criteria': criteria,
    };
  }
}

class CRMAnalytics {
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomersThisMonth;
  final double monthlyRevenue;
  final double quarterlyRevenue;
  final double yearlyRevenue;
  final double averageDealValue;
  final double conversionRate;
  final int totalOpportunities;
  final int activeOpportunities;
  final Map<String, double> revenueByMonth;
  final Map<String, int> customersByType;
  final Map<String, double> pipelineByStage;

  CRMAnalytics({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomersThisMonth,
    required this.monthlyRevenue,
    required this.quarterlyRevenue,
    required this.yearlyRevenue,
    required this.averageDealValue,
    required this.conversionRate,
    required this.totalOpportunities,
    required this.activeOpportunities,
    required this.revenueByMonth,
    required this.customersByType,
    required this.pipelineByStage,
  });

  factory CRMAnalytics.empty() {
    return CRMAnalytics(
      totalCustomers: 0,
      activeCustomers: 0,
      newCustomersThisMonth: 0,
      monthlyRevenue: 0.0,
      quarterlyRevenue: 0.0,
      yearlyRevenue: 0.0,
      averageDealValue: 0.0,
      conversionRate: 0.0,
      totalOpportunities: 0,
      activeOpportunities: 0,
      revenueByMonth: {},
      customersByType: {},
      pipelineByStage: {},
    );
  }

  factory CRMAnalytics.fromJson(Map<String, dynamic> json) {
    return CRMAnalytics(
      totalCustomers: json['totalCustomers'] ?? 0,
      activeCustomers: json['activeCustomers'] ?? 0,
      newCustomersThisMonth: json['newCustomersThisMonth'] ?? 0,
      monthlyRevenue: json['monthlyRevenue']?.toDouble() ?? 0.0,
      quarterlyRevenue: json['quarterlyRevenue']?.toDouble() ?? 0.0,
      yearlyRevenue: json['yearlyRevenue']?.toDouble() ?? 0.0,
      averageDealValue: json['averageDealValue']?.toDouble() ?? 0.0,
      conversionRate: json['conversionRate']?.toDouble() ?? 0.0,
      totalOpportunities: json['totalOpportunities'] ?? 0,
      activeOpportunities: json['activeOpportunities'] ?? 0,
      revenueByMonth: Map<String, double>.from(json['revenueByMonth'] ?? {}),
      customersByType: Map<String, int>.from(json['customersByType'] ?? {}),
      pipelineByStage: Map<String, double>.from(json['pipelineByStage'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'activeCustomers': activeCustomers,
      'newCustomersThisMonth': newCustomersThisMonth,
      'monthlyRevenue': monthlyRevenue,
      'quarterlyRevenue': quarterlyRevenue,
      'yearlyRevenue': yearlyRevenue,
      'averageDealValue': averageDealValue,
      'conversionRate': conversionRate,
      'totalOpportunities': totalOpportunities,
      'activeOpportunities': activeOpportunities,
      'revenueByMonth': revenueByMonth,
      'customersByType': customersByType,
      'pipelineByStage': pipelineByStage,
    };
  }
}
