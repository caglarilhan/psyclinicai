import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class APIGatewayService {
  static const String _requestsKey = 'api_requests';
  static const String _rateLimitsKey = 'api_rate_limits';
  static const String _endpointsKey = 'api_endpoints';
  
  // Singleton pattern
  static final APIGatewayService _instance = APIGatewayService._internal();
  factory APIGatewayService() => _instance;
  APIGatewayService._internal();

  // Stream controllers for real-time updates
  final StreamController<APIRequest> _requestStreamController = 
      StreamController<APIRequest>.broadcast();
  
  final StreamController<RateLimitEvent> _rateLimitStreamController = 
      StreamController<RateLimitEvent>.broadcast();

  // Get streams
  Stream<APIRequest> get requestStream => _requestStreamController.stream;
  Stream<RateLimitEvent> get rateLimitStream => _rateLimitStreamController.stream;

  // API configuration
  final Map<String, APIEndpoint> _endpoints = {
    '/api/v1/patients': APIEndpoint(
      path: '/api/v1/patients',
      method: HTTPMethod.get,
      rateLimit: 100,
      rateLimitWindow: 3600, // 1 hour
      requiresAuth: true,
      roles: ['clinician', 'admin'],
      description: 'Get list of patients',
    ),
    '/api/v1/patients/{id}': APIEndpoint(
      path: '/api/v1/patients/{id}',
      method: HTTPMethod.get,
      rateLimit: 200,
      rateLimitWindow: 3600,
      requiresAuth: true,
      roles: ['clinician', 'admin'],
      description: 'Get patient by ID',
    ),
    '/api/v1/patients': APIEndpoint(
      path: '/api/v1/patients',
      method: HTTPMethod.post,
      rateLimit: 50,
      rateLimitWindow: 3600,
      requiresAuth: true,
      roles: ['clinician', 'admin'],
      description: 'Create new patient',
    ),
    '/api/v1/ai/analyze': APIEndpoint(
      path: '/api/v1/ai/analyze',
      method: HTTPMethod.post,
      rateLimit: 20,
      rateLimitWindow: 3600,
      requiresAuth: true,
      roles: ['clinician', 'admin'],
      description: 'AI analysis endpoint',
    ),
    '/api/v1/fhir/sync': APIEndpoint(
      path: '/api/v1/fhir/sync',
      method: HTTPMethod.post,
      rateLimit: 10,
      rateLimitWindow: 3600,
      requiresAuth: true,
      roles: ['admin'],
      description: 'FHIR synchronization',
    ),
    '/api/v1/billing/process': APIEndpoint(
      path: '/api/v1/billing/process',
      method: HTTPMethod.post,
      rateLimit: 30,
      rateLimitWindow: 3600,
      requiresAuth: true,
      roles: ['admin', 'billing'],
      description: 'Process billing',
    ),
  };

  // Rate limiting storage
  final Map<String, List<RateLimitRecord>> _rateLimitRecords = {};
  final Map<String, int> _requestCounts = {};

  // Initialize API Gateway service
  Future<void> initialize() async {
    try {
      // Load rate limit records
      await _loadRateLimitRecords();
      
      print('✅ API Gateway service initialized');
    } catch (e) {
      print('Error initializing API Gateway service: $e');
    }
  }

  // Get API endpoints
  Map<String, APIEndpoint> get endpoints => _endpoints;

  // Process API request
  Future<APIResponse> processRequest({
    required String path,
    required HTTPMethod method,
    required String userId,
    required String userRole,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final startTime = DateTime.now();
      
      // Find matching endpoint
      final endpoint = _findMatchingEndpoint(path, method);
      if (endpoint == null) {
        return APIResponse(
          success: false,
          statusCode: 404,
          message: 'Endpoint not found',
          data: null,
          timestamp: DateTime.now(),
          requestId: _generateSecureId(),
        );
      }

      // Check authentication
      if (endpoint.requiresAuth && userId.isEmpty) {
        return APIResponse(
          success: false,
          statusCode: 401,
          message: 'Authentication required',
          data: null,
          timestamp: DateTime.now(),
          requestId: _generateSecureId(),
        );
      }

      // Check authorization
      if (!endpoint.roles.contains(userRole)) {
        return APIResponse(
          success: false,
          statusCode: 403,
          message: 'Insufficient permissions',
          data: null,
          timestamp: DateTime.now(),
          requestId: _generateSecureId(),
        );
      }

      // Check rate limiting
      final rateLimitCheck = await _checkRateLimit(endpoint, userId);
      if (!rateLimitCheck.allowed) {
        _rateLimitStreamController.add(RateLimitEvent(
          id: _generateSecureId(),
          userId: userId,
          endpoint: endpoint.path,
          timestamp: DateTime.now(),
          reason: 'Rate limit exceeded',
          retryAfter: rateLimitCheck.retryAfter,
        ));

        return APIResponse(
          success: false,
          statusCode: 429,
          message: 'Rate limit exceeded. Try again in ${rateLimitCheck.retryAfter} seconds',
          data: null,
          timestamp: DateTime.now(),
          requestId: _generateSecureId(),
        );
      }

      // Create API request record
      final request = APIRequest(
        id: _generateSecureId(),
        path: path,
        method: method,
        userId: userId,
        userRole: userRole,
        headers: headers ?? {},
        body: body,
        queryParams: queryParams ?? {},
        timestamp: startTime,
        status: RequestStatus.processing,
      );

      // Add to request stream
      _requestStreamController.add(request);

      // Simulate API processing
      await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 100));

      // Update request status
      request.status = RequestStatus.completed;
      request.completedAt = DateTime.now();
      request.processingTime = DateTime.now().difference(startTime).inMilliseconds;

      // Save request record
      await _saveRequest(request);

      // Generate mock response based on endpoint
      final response = await _generateMockResponse(endpoint, request);

      print('✅ API request processed: ${request.id}');
      return response;

    } catch (e) {
      print('Error processing API request: $e');
      return APIResponse(
        success: false,
        statusCode: 500,
        message: 'Internal server error: $e',
        data: null,
        timestamp: DateTime.now(),
        requestId: _generateSecureId(),
      );
    }
  }

  // Find matching endpoint
  APIEndpoint? _findMatchingEndpoint(String path, HTTPMethod method) {
    for (final endpoint in _endpoints.values) {
      if (endpoint.method == method && _pathMatches(endpoint.path, path)) {
        return endpoint;
      }
    }
    return null;
  }

  // Check if path matches endpoint pattern
  bool _pathMatches(String endpointPath, String requestPath) {
    if (endpointPath == requestPath) return true;
    
    // Handle path parameters (e.g., /api/v1/patients/{id})
    final endpointParts = endpointPath.split('/');
    final requestParts = requestPath.split('/');
    
    if (endpointParts.length != requestParts.length) return false;
    
    for (int i = 0; i < endpointParts.length; i++) {
      if (endpointParts[i].startsWith('{') && endpointParts[i].endsWith('}')) {
        // This is a path parameter, so it matches any value
        continue;
      }
      if (endpointParts[i] != requestParts[i]) {
        return false;
      }
    }
    
    return true;
  }

  // Check rate limiting
  Future<RateLimitCheck> _checkRateLimit(APIEndpoint endpoint, String userId) async {
    final key = '${userId}_${endpoint.path}';
    final now = DateTime.now();
    
    // Get existing records
    final records = _rateLimitRecords[key] ?? [];
    
    // Remove expired records
    final validRecords = records.where((record) => 
      now.difference(record.timestamp).inSeconds < endpoint.rateLimitWindow
    ).toList();
    
    // Check if limit exceeded
    if (validRecords.length >= endpoint.rateLimit) {
      // Find oldest record to calculate retry time
      final oldestRecord = validRecords.reduce((a, b) => 
        a.timestamp.isBefore(b.timestamp) ? a : b
      );
      
      final retryAfter = endpoint.rateLimitWindow - 
          now.difference(oldestRecord.timestamp).inSeconds;
      
      return RateLimitCheck(
        allowed: false,
        retryAfter: retryAfter > 0 ? retryAfter : 1,
        remainingRequests: 0,
        resetTime: oldestRecord.timestamp.add(Duration(seconds: endpoint.rateLimitWindow)),
      );
    }
    
    // Add new record
    final newRecord = RateLimitRecord(
      id: _generateSecureId(),
      userId: userId,
      endpoint: endpoint.path,
      timestamp: now,
    );
    
    validRecords.add(newRecord);
    _rateLimitRecords[key] = validRecords;
    
    // Save rate limit records
    await _saveRateLimitRecords();
    
    final remainingRequests = endpoint.rateLimit - validRecords.length;
    final resetTime = now.add(Duration(seconds: endpoint.rateLimitWindow));
    
    return RateLimitCheck(
      allowed: true,
      retryAfter: 0,
      remainingRequests: remainingRequests,
      resetTime: resetTime,
    );
  }

  // Generate mock response
  Future<APIResponse> _generateMockResponse(APIEndpoint endpoint, APIRequest request) async {
    switch (endpoint.path) {
      case '/api/v1/patients':
        if (request.method == HTTPMethod.get) {
          return APIResponse(
            success: true,
            statusCode: 200,
            message: 'Patients retrieved successfully',
            data: {
              'patients': [
                {
                  'id': 'patient_001',
                  'name': 'John Doe',
                  'age': 35,
                  'diagnosis': 'Depression',
                  'lastVisit': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
                },
                {
                  'id': 'patient_002',
                  'name': 'Jane Smith',
                  'age': 28,
                  'diagnosis': 'Anxiety',
                  'lastVisit': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
                },
              ],
              'total': 2,
              'page': 1,
              'limit': 10,
            },
            timestamp: DateTime.now(),
            requestId: request.id,
          );
        } else if (request.method == HTTPMethod.post) {
          return APIResponse(
            success: true,
            statusCode: 201,
            message: 'Patient created successfully',
            data: {
              'id': 'patient_003',
              'name': request.body?['name'] ?? 'New Patient',
              'age': request.body?['age'] ?? 0,
              'diagnosis': request.body?['diagnosis'] ?? 'Pending',
              'createdAt': DateTime.now().toIso8601String(),
            },
            timestamp: DateTime.now(),
            requestId: request.id,
          );
        }
        break;
        
      case '/api/v1/ai/analyze':
        return APIResponse(
          success: true,
          statusCode: 200,
          message: 'AI analysis completed',
          data: {
            'analysisId': 'analysis_${_generateSecureId()}',
            'type': request.body?['type'] ?? 'general',
            'confidence': 0.85,
            'results': {
              'sentiment': 'positive',
              'risk_level': 'low',
              'recommendations': [
                'Continue current treatment plan',
                'Schedule follow-up in 2 weeks',
                'Monitor mood changes',
              ],
            },
            'processingTime': 1500,
            'timestamp': DateTime.now().toIso8601String(),
          },
          timestamp: DateTime.now(),
          requestId: request.id,
        );
        
      case '/api/v1/fhir/sync':
        return APIResponse(
          success: true,
          statusCode: 200,
          message: 'FHIR synchronization completed',
          data: {
            'syncId': 'sync_${_generateSecureId()}',
            'status': 'completed',
            'recordsProcessed': 150,
            'recordsCreated': 45,
            'recordsUpdated': 105,
            'errors': 0,
            'duration': 2500,
            'timestamp': DateTime.now().toIso8601String(),
          },
          timestamp: DateTime.now(),
          requestId: request.id,
        );
        
      case '/api/v1/billing/process':
        return APIResponse(
          success: true,
          statusCode: 200,
          message: 'Billing processed successfully',
          data: {
            'billingId': 'billing_${_generateSecureId()}',
            'status': 'completed',
            'amount': request.body?['amount'] ?? 0.0,
            'currency': 'USD',
            'transactionId': 'txn_${_generateSecureId()}',
            'timestamp': DateTime.now().toIso8601String(),
          },
          timestamp: DateTime.now(),
          requestId: request.id,
        );
    }
    
    // Default response
    return APIResponse(
      success: true,
      statusCode: 200,
      message: 'Request processed successfully',
      data: {
        'endpoint': endpoint.path,
        'method': request.method.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
      requestId: request.id,
    );
  }

  // Get API statistics
  Future<APIStatistics> getAPIStatistics() async {
    try {
      final requests = await _getRequests();
      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));
      
      final recentRequests = requests.where((r) => 
        r.timestamp.isAfter(last24Hours)
      ).toList();
      
      final successfulRequests = recentRequests.where((r) => 
        r.status == RequestStatus.completed
      ).length;
      
      final failedRequests = recentRequests.where((r) => 
        r.status == RequestStatus.failed
      ).length;
      
      final totalRequests = recentRequests.length;
      final successRate = totalRequests > 0 ? (successfulRequests / totalRequests) : 0.0;
      
      // Calculate average processing time
      final completedRequests = recentRequests.where((r) => 
        r.processingTime != null
      ).toList();
      
      final avgProcessingTime = completedRequests.isNotEmpty
          ? completedRequests.map((r) => r.processingTime!).reduce((a, b) => a + b) / completedRequests.length
          : 0.0;
      
      // Get top endpoints
      final endpointCounts = <String, int>{};
      for (final request in recentRequests) {
        endpointCounts[request.path] = (endpointCounts[request.path] ?? 0) + 1;
      }
      
      final topEndpoints = endpointCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      return APIStatistics(
        totalRequests24h: totalRequests,
        successfulRequests24h: successfulRequests,
        failedRequests24h: failedRequests,
        successRate: successRate,
        averageProcessingTime: avgProcessingTime,
        topEndpoints: topEndpoints.take(5).map((e) => e.key).toList(),
        lastUpdated: now,
      );
      
    } catch (e) {
      print('Error getting API statistics: $e');
      return APIStatistics(
        totalRequests24h: 0,
        successfulRequests24h: 0,
        failedRequests24h: 0,
        successRate: 0.0,
        averageProcessingTime: 0.0,
        topEndpoints: [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Get rate limit info for user
  Future<Map<String, RateLimitInfo>> getRateLimitInfo(String userId) async {
    try {
      final result = <String, RateLimitInfo>{};
      
      for (final endpoint in _endpoints.values) {
        final key = '${userId}_${endpoint.path}';
        final records = _rateLimitRecords[key] ?? [];
        final now = DateTime.now();
        
        // Remove expired records
        final validRecords = records.where((record) => 
          now.difference(record.timestamp).inSeconds < endpoint.rateLimitWindow
        ).toList();
        
        final remainingRequests = endpoint.rateLimit - validRecords.length;
        final resetTime = validRecords.isNotEmpty
            ? validRecords.first.timestamp.add(Duration(seconds: endpoint.rateLimitWindow))
            : now;
        
        result[endpoint.path] = RateLimitInfo(
          endpoint: endpoint.path,
          method: endpoint.method,
          limit: endpoint.rateLimit,
          remaining: remainingRequests > 0 ? remainingRequests : 0,
          resetTime: resetTime,
          window: endpoint.rateLimitWindow,
        );
      }
      
      return result;
      
    } catch (e) {
      print('Error getting rate limit info: $e');
      return {};
    }
  }

  // Save API request
  Future<void> _saveRequest(APIRequest request) async {
    try {
      final requests = await _getRequests();
      
      final index = requests.indexWhere((r) => r.id == request.id);
      if (index >= 0) {
        requests[index] = request;
      } else {
        requests.add(request);
      }
      
      await _saveRequests(requests);
    } catch (e) {
      print('Error saving API request: $e');
    }
  }

  // Save API requests
  Future<void> _saveRequests(List<APIRequest> requests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_requestsKey, json.encode(
        requests.map((r) => r.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving API requests: $e');
    }
  }

  // Get API requests
  Future<List<APIRequest>> _getRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey);
      
      if (requestsJson != null) {
        final requests = json.decode(requestsJson) as List<dynamic>;
        return requests.map((json) => APIRequest.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting API requests: $e');
      return [];
    }
  }

  // Save rate limit records
  Future<void> _saveRateLimitRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allRecords = <RateLimitRecord>[];
      
      for (final records in _rateLimitRecords.values) {
        allRecords.addAll(records);
      }
      
      await prefs.setString(_rateLimitsKey, json.encode(
        allRecords.map((r) => r.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving rate limit records: $e');
    }
  }

  // Load rate limit records
  Future<void> _loadRateLimitRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString(_rateLimitsKey);
      
      if (recordsJson != null) {
        final allRecords = json.decode(recordsJson) as List<dynamic>;
        
        for (final recordJson in allRecords) {
          final record = RateLimitRecord.fromJson(recordJson);
          final key = '${record.userId}_${record.endpoint}';
          
          if (!_rateLimitRecords.containsKey(key)) {
            _rateLimitRecords[key] = [];
          }
          _rateLimitRecords[key]!.add(record);
        }
      }
    } catch (e) {
      print('Error loading rate limit records: $e');
    }
  }

  // Generate secure ID
  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Dispose resources
  void dispose() {
    _requestStreamController.close();
    _rateLimitStreamController.close();
  }
}

// Data classes
class APIEndpoint {
  final String path;
  final HTTPMethod method;
  final int rateLimit;
  final int rateLimitWindow;
  final bool requiresAuth;
  final List<String> roles;
  final String description;

  const APIEndpoint({
    required this.path,
    required this.method,
    required this.rateLimit,
    required this.rateLimitWindow,
    required this.requiresAuth,
    required this.roles,
    required this.description,
  });
}

enum HTTPMethod {
  get,
  post,
  put,
  delete,
  patch,
}

class APIRequest {
  final String id;
  final String path;
  final HTTPMethod method;
  final String userId;
  final String userRole;
  final Map<String, dynamic> headers;
  final Map<String, dynamic>? body;
  final Map<String, dynamic> queryParams;
  final DateTime timestamp;
  RequestStatus status;
  DateTime? completedAt;
  int? processingTime;

  APIRequest({
    required this.id,
    required this.path,
    required this.method,
    required this.userId,
    required this.userRole,
    required this.headers,
    this.body,
    required this.queryParams,
    required this.timestamp,
    required this.status,
    this.completedAt,
    this.processingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'method': method.name,
      'userId': userId,
      'userRole': userRole,
      'headers': headers,
      'body': body,
      'queryParams': queryParams,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'completedAt': completedAt?.toIso8601String(),
      'processingTime': processingTime,
    };
  }

  factory APIRequest.fromJson(Map<String, dynamic> json) {
    return APIRequest(
      id: json['id'],
      path: json['path'],
      method: HTTPMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => HTTPMethod.get,
      ),
      userId: json['userId'],
      userRole: json['userRole'],
      headers: json['headers'] ?? {},
      body: json['body'],
      queryParams: json['queryParams'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      processingTime: json['processingTime'],
    );
  }
}

enum RequestStatus {
  pending,
  processing,
  completed,
  failed,
}

class APIResponse {
  final bool success;
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final String requestId;

  const APIResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    required this.timestamp,
    required this.requestId,
  });
}

class RateLimitRecord {
  final String id;
  final String userId;
  final String endpoint;
  final DateTime timestamp;

  const RateLimitRecord({
    required this.id,
    required this.userId,
    required this.endpoint,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'endpoint': endpoint,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RateLimitRecord.fromJson(Map<String, dynamic> json) {
    return RateLimitRecord(
      id: json['id'],
      userId: json['userId'],
      endpoint: json['endpoint'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class RateLimitCheck {
  final bool allowed;
  final int retryAfter;
  final int remainingRequests;
  final DateTime resetTime;

  const RateLimitCheck({
    required this.allowed,
    required this.retryAfter,
    required this.remainingRequests,
    required this.resetTime,
  });
}

class RateLimitInfo {
  final String endpoint;
  final HTTPMethod method;
  final int limit;
  final int remaining;
  final DateTime resetTime;
  final int window;

  const RateLimitInfo({
    required this.endpoint,
    required this.method,
    required this.limit,
    required this.remaining,
    required this.resetTime,
    required this.window,
  });
}

class RateLimitEvent {
  final String id;
  final String userId;
  final String endpoint;
  final DateTime timestamp;
  final String reason;
  final int retryAfter;

  const RateLimitEvent({
    required this.id,
    required this.userId,
    required this.endpoint,
    required this.timestamp,
    required this.reason,
    required this.retryAfter,
  });
}

class APIStatistics {
  final int totalRequests24h;
  final int successfulRequests24h;
  final int failedRequests24h;
  final double successRate;
  final double averageProcessingTime;
  final List<String> topEndpoints;
  final DateTime lastUpdated;

  const APIStatistics({
    required this.totalRequests24h,
    required this.successfulRequests24h,
    required this.failedRequests24h,
    required this.successRate,
    required this.averageProcessingTime,
    required this.topEndpoints,
    required this.lastUpdated,
  });
}
