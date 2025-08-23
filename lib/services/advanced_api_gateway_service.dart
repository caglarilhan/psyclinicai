import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced API Gateway Service for PsyClinicAI
/// Provides enterprise-grade API management, rate limiting, and monitoring
class AdvancedAPIGatewayService {
  static final AdvancedAPIGatewayService _instance = AdvancedAPIGatewayService._internal();
  factory AdvancedAPIGatewayService() => _instance;
  AdvancedAPIGatewayService._internal();

  final Map<String, APIEndpoint> _endpoints = {};
  final Map<String, RateLimitRule> _rateLimitRules = {};
  final Map<String, List<APIRequest>> _requestHistory = {};
  final Map<String, APIKey> _apiKeys = {};
  final Map<String, ServiceHealth> _serviceHealth = {};

  // Stream controllers for real-time monitoring
  final StreamController<APIRequest> _requestController = StreamController<APIRequest>.broadcast();
  final StreamController<APIMetrics> _metricsController = StreamController<APIMetrics>.broadcast();
  final StreamController<ServiceAlert> _alertController = StreamController<ServiceAlert>.broadcast();

  Stream<APIRequest> get requestStream => _requestController.stream;
  Stream<APIMetrics> get metricsStream => _metricsController.stream;
  Stream<ServiceAlert> get alertStream => _alertController.stream;

  /// Initialize the API Gateway service
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadAPIConfiguration();
    await _startHealthChecks();
    print('✅ Advanced API Gateway Service initialized');
  }

  /// Load API configuration
  Future<void> _loadAPIConfiguration() async {
    // Load API endpoints
    _endpoints['patient_api'] = APIEndpoint(
      id: 'patient_api',
      path: '/api/v1/patients',
      method: 'GET',
      serviceName: 'patient_service',
      serviceUrl: 'https://api.psyclinicai.com/patients',
      rateLimit: RateLimit(
        requestsPerMinute: 1000,
        requestsPerHour: 10000,
        requestsPerDay: 100000,
      ),
      authentication: AuthenticationConfig(
        required: true,
        type: AuthenticationType.bearer,
        scopes: ['read:patients'],
      ),
      caching: CachingConfig(
        enabled: true,
        ttlSeconds: 300,
        strategy: CacheStrategy.lru,
      ),
      monitoring: MonitoringConfig(
        enabled: true,
        alertThresholds: {
          'response_time_ms': 5000,
          'error_rate_percent': 5.0,
          'requests_per_minute': 1200,
        },
      ),
      transformations: [
        RequestTransformation(
          type: TransformationType.headerMapping,
          config: {'X-Tenant-ID': 'tenant_id'},
        ),
      ],
    );

    _endpoints['session_api'] = APIEndpoint(
      id: 'session_api',
      path: '/api/v1/sessions',
      method: 'POST',
      serviceName: 'session_service',
      serviceUrl: 'https://api.psyclinicai.com/sessions',
      rateLimit: RateLimit(
        requestsPerMinute: 500,
        requestsPerHour: 5000,
        requestsPerDay: 50000,
      ),
      authentication: AuthenticationConfig(
        required: true,
        type: AuthenticationType.bearer,
        scopes: ['write:sessions'],
      ),
      caching: CachingConfig(
        enabled: false,
        ttlSeconds: 0,
        strategy: CacheStrategy.none,
      ),
      monitoring: MonitoringConfig(
        enabled: true,
        alertThresholds: {
          'response_time_ms': 3000,
          'error_rate_percent': 2.0,
          'requests_per_minute': 600,
        },
      ),
      transformations: [],
    );

    // Load rate limit rules
    _rateLimitRules['tenant_basic'] = RateLimitRule(
      id: 'tenant_basic',
      name: 'Basic Tier Rate Limit',
      requestsPerMinute: 100,
      requestsPerHour: 1000,
      requestsPerDay: 10000,
      applicableTenants: ['basic'],
      burst: BurstConfig(
        enabled: true,
        maxBurstSize: 150,
        refillRate: 10,
      ),
    );

    _rateLimitRules['tenant_enterprise'] = RateLimitRule(
      id: 'tenant_enterprise',
      name: 'Enterprise Tier Rate Limit',
      requestsPerMinute: 2000,
      requestsPerHour: 50000,
      requestsPerDay: 1000000,
      applicableTenants: ['enterprise'],
      burst: BurstConfig(
        enabled: true,
        maxBurstSize: 3000,
        refillRate: 100,
      ),
    );

    // Load API keys
    _apiKeys['key_enterprise_001'] = APIKey(
      id: 'key_enterprise_001',
      tenantId: 'tenant_001',
      name: 'Enterprise API Key',
      key: 'ak_enterprise_001_${_generateSecureId()}',
      status: APIKeyStatus.active,
      permissions: ['read:patients', 'write:sessions', 'read:analytics'],
      rateLimit: _rateLimitRules['tenant_enterprise']!,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      expiresAt: DateTime.now().add(const Duration(days: 365)),
      lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      usage: APIKeyUsage(
        requestsToday: 15420,
        requestsThisMonth: 456789,
        totalRequests: 2345678,
      ),
    );
  }

  /// Start health checks for services
  Future<void> _startHealthChecks() async {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _performHealthChecks();
    });

    // Initialize service health
    _serviceHealth['patient_service'] = ServiceHealth(
      serviceName: 'patient_service',
      status: ServiceStatus.healthy,
      responseTime: 145,
      uptime: 99.98,
      lastCheck: DateTime.now(),
      endpoints: ['GET /patients', 'POST /patients', 'PUT /patients/{id}'],
    );

    _serviceHealth['session_service'] = ServiceHealth(
      serviceName: 'session_service',
      status: ServiceStatus.healthy,
      responseTime: 234,
      uptime: 99.95,
      lastCheck: DateTime.now(),
      endpoints: ['POST /sessions', 'GET /sessions/{id}', 'PUT /sessions/{id}'],
    );
  }

  /// Process API request through gateway
  Future<APIResponse> processRequest({
    required String path,
    required String method,
    required String apiKey,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    required String clientIP,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // 1. Validate API key
      final keyValidation = await _validateAPIKey(apiKey);
      if (!keyValidation.valid) {
        return APIResponse(
          statusCode: 401,
          body: {'error': 'Invalid API key'},
          headers: {},
          responseTime: _calculateResponseTime(startTime),
        );
      }

      final apiKeyData = keyValidation.apiKey!;

      // 2. Check rate limits
      final rateLimitCheck = await _checkRateLimit(apiKeyData, clientIP);
      if (!rateLimitCheck.allowed) {
        return APIResponse(
          statusCode: 429,
          body: {'error': 'Rate limit exceeded', 'retry_after': rateLimitCheck.retryAfter},
          headers: {'X-RateLimit-Remaining': rateLimitCheck.remaining.toString()},
          responseTime: _calculateResponseTime(startTime),
        );
      }

      // 3. Find matching endpoint
      final endpoint = _findEndpoint(path, method);
      if (endpoint == null) {
        return APIResponse(
          statusCode: 404,
          body: {'error': 'Endpoint not found'},
          headers: {},
          responseTime: _calculateResponseTime(startTime),
        );
      }

      // 4. Validate permissions
      final permissionCheck = _validatePermissions(apiKeyData, endpoint);
      if (!permissionCheck) {
        return APIResponse(
          statusCode: 403,
          body: {'error': 'Insufficient permissions'},
          headers: {},
          responseTime: _calculateResponseTime(startTime),
        );
      }

      // 5. Apply transformations
      final transformedRequest = await _applyRequestTransformations(
        endpoint, headers, body);

      // 6. Check cache
      if (endpoint.caching.enabled && method == 'GET') {
        final cachedResponse = await _getCachedResponse(endpoint, transformedRequest);
        if (cachedResponse != null) {
          return cachedResponse.copyWith(
            headers: {...cachedResponse.headers, 'X-Cache': 'HIT'},
            responseTime: _calculateResponseTime(startTime),
          );
        }
      }

      // 7. Forward request to backend service
      final backendResponse = await _forwardRequest(
        endpoint, transformedRequest['headers'], transformedRequest['body']);

      // 8. Cache response if applicable
      if (endpoint.caching.enabled && backendResponse.statusCode == 200) {
        await _cacheResponse(endpoint, transformedRequest, backendResponse);
      }

      // 9. Log request
      await _logRequest(APIRequest(
        id: _generateSecureId(),
        timestamp: startTime,
        method: method,
        path: path,
        apiKey: apiKey,
        tenantId: apiKeyData.tenantId,
        clientIP: clientIP,
        statusCode: backendResponse.statusCode,
        responseTime: _calculateResponseTime(startTime),
        requestSize: _calculateRequestSize(headers, body),
        responseSize: _calculateResponseSize(backendResponse.body),
        userAgent: headers['user-agent'] ?? '',
        endpoint: endpoint.id,
      ));

      return backendResponse.copyWith(
        headers: {...backendResponse.headers, 'X-Gateway': 'PsyClinicAI'},
        responseTime: _calculateResponseTime(startTime),
      );

    } catch (e) {
      // Handle errors
      await _logRequest(APIRequest(
        id: _generateSecureId(),
        timestamp: startTime,
        method: method,
        path: path,
        apiKey: apiKey,
        tenantId: '',
        clientIP: clientIP,
        statusCode: 500,
        responseTime: _calculateResponseTime(startTime),
        requestSize: _calculateRequestSize(headers, body),
        responseSize: 0,
        userAgent: headers['user-agent'] ?? '',
        endpoint: '',
        error: e.toString(),
      ));

      return APIResponse(
        statusCode: 500,
        body: {'error': 'Internal server error'},
        headers: {},
        responseTime: _calculateResponseTime(startTime),
      );
    }
  }

  /// Validate API key
  Future<APIKeyValidation> _validateAPIKey(String apiKey) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final key = _apiKeys.values.where((k) => k.key == apiKey).firstOrNull;
    if (key == null) {
      return APIKeyValidation(valid: false, reason: 'Key not found');
    }

    if (key.status != APIKeyStatus.active) {
      return APIKeyValidation(valid: false, reason: 'Key inactive');
    }

    if (key.expiresAt != null && DateTime.now().isAfter(key.expiresAt!)) {
      return APIKeyValidation(valid: false, reason: 'Key expired');
    }

    return APIKeyValidation(valid: true, apiKey: key);
  }

  /// Check rate limits
  Future<RateLimitResult> _checkRateLimit(APIKey apiKey, String clientIP) async {
    await Future.delayed(const Duration(milliseconds: 30));

    // Simulate rate limit checking
    final random = Random();
    final allowed = random.nextDouble() > 0.05; // 95% success rate

    return RateLimitResult(
      allowed: allowed,
      remaining: allowed ? 150 : 0,
      resetTime: DateTime.now().add(const Duration(minutes: 1)),
      retryAfter: allowed ? 0 : 60,
    );
  }

  /// Find matching endpoint
  APIEndpoint? _findEndpoint(String path, String method) {
    for (final endpoint in _endpoints.values) {
      if (_matchesPath(endpoint.path, path) && endpoint.method == method) {
        return endpoint;
      }
    }
    return null;
  }

  /// Validate permissions
  bool _validatePermissions(APIKey apiKey, APIEndpoint endpoint) {
    if (!endpoint.authentication.required) return true;
    
    return endpoint.authentication.scopes.every(
      (scope) => apiKey.permissions.contains(scope));
  }

  /// Apply request transformations
  Future<Map<String, dynamic>> _applyRequestTransformations(
    APIEndpoint endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(const Duration(milliseconds: 20));

    final transformedHeaders = Map<String, String>.from(headers);
    final transformedBody = Map<String, dynamic>.from(body);

    for (final transformation in endpoint.transformations) {
      switch (transformation.type) {
        case TransformationType.headerMapping:
          final config = transformation.config;
          config.forEach((key, value) {
            if (headers.containsKey(value)) {
              transformedHeaders[key] = headers[value]!;
            }
          });
          break;
        case TransformationType.bodyTransformation:
          // Apply body transformations
          break;
        case TransformationType.queryParameterMapping:
          // Apply query parameter transformations
          break;
      }
    }

    return {
      'headers': transformedHeaders,
      'body': transformedBody,
    };
  }

  /// Get cached response
  Future<APIResponse?> _getCachedResponse(
    APIEndpoint endpoint,
    Map<String, dynamic> request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));
    
    // Simulate cache lookup
    final random = Random();
    if (random.nextDouble() < 0.3) { // 30% cache hit rate
      return APIResponse(
        statusCode: 200,
        body: {'cached': true, 'data': 'cached_response'},
        headers: {'Content-Type': 'application/json'},
        responseTime: 5,
      );
    }
    
    return null;
  }

  /// Forward request to backend service
  Future<APIResponse> _forwardRequest(
    APIEndpoint endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    // Simulate network delay based on service health
    final serviceHealth = _serviceHealth[endpoint.serviceName];
    final delay = serviceHealth?.responseTime ?? 200;
    await Future.delayed(Duration(milliseconds: delay));

    // Simulate service response
    final random = Random();
    final success = random.nextDouble() > 0.02; // 98% success rate

    if (success) {
      return APIResponse(
        statusCode: 200,
        body: {
          'success': true,
          'data': 'service_response_data',
          'timestamp': DateTime.now().toIso8601String(),
        },
        headers: {'Content-Type': 'application/json'},
        responseTime: delay,
      );
    } else {
      return APIResponse(
        statusCode: 500,
        body: {'error': 'Service unavailable'},
        headers: {'Content-Type': 'application/json'},
        responseTime: delay,
      );
    }
  }

  /// Cache response
  Future<void> _cacheResponse(
    APIEndpoint endpoint,
    Map<String, dynamic> request,
    APIResponse response,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));
    // Implement response caching logic
  }

  /// Log API request
  Future<void> _logRequest(APIRequest request) async {
    _requestHistory.putIfAbsent(request.tenantId, () => []).add(request);
    _requestController.add(request);

    // Update API key usage
    final apiKey = _apiKeys.values.where((k) => k.key == request.apiKey).firstOrNull;
    if (apiKey != null) {
      // Update usage statistics
      apiKey.usage.requestsToday++;
      apiKey.usage.totalRequests++;
    }
  }

  /// Perform health checks
  Future<void> _performHealthChecks() async {
    for (final serviceName in _serviceHealth.keys) {
      try {
        final startTime = DateTime.now();
        
        // Simulate health check
        await Future.delayed(const Duration(milliseconds: 100));
        
        final responseTime = DateTime.now().difference(startTime).inMilliseconds;
        final random = Random();
        final isHealthy = random.nextDouble() > 0.05; // 95% uptime

        _serviceHealth[serviceName] = _serviceHealth[serviceName]!.copyWith(
          status: isHealthy ? ServiceStatus.healthy : ServiceStatus.unhealthy,
          responseTime: responseTime,
          lastCheck: DateTime.now(),
        );

        // Send alert if service becomes unhealthy
        if (!isHealthy) {
          _alertController.add(ServiceAlert(
            id: _generateSecureId(),
            type: AlertType.serviceDown,
            severity: AlertSeverity.high,
            serviceName: serviceName,
            message: 'Service $serviceName is unhealthy',
            timestamp: DateTime.now(),
            details: {'response_time': responseTime},
          ));
        }

      } catch (e) {
        _serviceHealth[serviceName] = _serviceHealth[serviceName]!.copyWith(
          status: ServiceStatus.error,
          lastCheck: DateTime.now(),
        );
      }
    }
  }

  /// Get API analytics
  Future<APIAnalytics> getAPIAnalytics({
    String? tenantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    final allRequests = tenantId != null
        ? _requestHistory[tenantId] ?? []
        : _requestHistory.values.expand((requests) => requests).toList();

    final filteredRequests = allRequests.where((request) =>
        request.timestamp.isAfter(start) && request.timestamp.isBefore(end)).toList();

    // Calculate metrics
    final totalRequests = filteredRequests.length;
    final successfulRequests = filteredRequests.where((r) => r.statusCode < 400).length;
    final errorRequests = totalRequests - successfulRequests;
    final avgResponseTime = filteredRequests.isNotEmpty
        ? filteredRequests.map((r) => r.responseTime).reduce((a, b) => a + b) / totalRequests
        : 0.0;

    // Top endpoints
    final endpointCounts = <String, int>{};
    for (final request in filteredRequests) {
      endpointCounts[request.endpoint] = (endpointCounts[request.endpoint] ?? 0) + 1;
    }

    final topEndpoints = endpointCounts.entries
        .map((e) => EndpointUsage(endpoint: e.key, requests: e.value))
        .toList()
      ..sort((a, b) => b.requests.compareTo(a.requests));

    return APIAnalytics(
      tenantId: tenantId,
      startDate: start,
      endDate: end,
      totalRequests: totalRequests,
      successfulRequests: successfulRequests,
      errorRequests: errorRequests,
      errorRate: totalRequests > 0 ? (errorRequests / totalRequests) * 100 : 0.0,
      averageResponseTime: avgResponseTime,
      topEndpoints: topEndpoints.take(10).toList(),
      requestsOverTime: _generateTimeSeriesData(filteredRequests),
      statusCodeDistribution: _calculateStatusCodeDistribution(filteredRequests),
    );
  }

  /// Get service health status
  Future<List<ServiceHealth>> getServiceHealth() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _serviceHealth.values.toList();
  }

  /// Create new API key
  Future<APIKey> createAPIKey({
    required String tenantId,
    required String name,
    required List<String> permissions,
    required RateLimitRule rateLimit,
    DateTime? expiresAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final apiKey = APIKey(
      id: _generateSecureId(),
      tenantId: tenantId,
      name: name,
      key: 'ak_${tenantId}_${_generateSecureId()}',
      status: APIKeyStatus.active,
      permissions: permissions,
      rateLimit: rateLimit,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      usage: APIKeyUsage(
        requestsToday: 0,
        requestsThisMonth: 0,
        totalRequests: 0,
      ),
    );

    _apiKeys[apiKey.id] = apiKey;
    return apiKey;
  }

  /// Revoke API key
  Future<void> revokeAPIKey(String apiKeyId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final apiKey = _apiKeys[apiKeyId];
    if (apiKey != null) {
      _apiKeys[apiKeyId] = apiKey.copyWith(status: APIKeyStatus.revoked);
    }
  }

  // Helper methods
  bool _matchesPath(String pattern, String path) {
    // Simple path matching - in production, use proper regex/pattern matching
    return pattern == path || pattern.replaceAll(RegExp(r'\{[^}]+\}'), '*').contains('*');
  }

  int _calculateResponseTime(DateTime startTime) {
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  int _calculateRequestSize(Map<String, String> headers, Map<String, dynamic> body) {
    return json.encode({'headers': headers, 'body': body}).length;
  }

  int _calculateResponseSize(Map<String, dynamic> body) {
    return json.encode(body).length;
  }

  List<TimeSeriesPoint> _generateTimeSeriesData(List<APIRequest> requests) {
    final dataPoints = <DateTime, int>{};
    
    for (final request in requests) {
      final hour = DateTime(
        request.timestamp.year,
        request.timestamp.month,
        request.timestamp.day,
        request.timestamp.hour,
      );
      dataPoints[hour] = (dataPoints[hour] ?? 0) + 1;
    }

    return dataPoints.entries
        .map((e) => TimeSeriesPoint(timestamp: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Map<int, int> _calculateStatusCodeDistribution(List<APIRequest> requests) {
    final distribution = <int, int>{};
    
    for (final request in requests) {
      distribution[request.statusCode] = (distribution[request.statusCode] ?? 0) + 1;
    }

    return distribution;
  }

  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes).replaceAll('/', '_').replaceAll('+', '-').substring(0, 22);
  }

  /// Dispose resources
  void dispose() {
    _requestController.close();
    _metricsController.close();
    _alertController.close();
  }
}

// Data Models for API Gateway
class APIEndpoint {
  final String id;
  final String path;
  final String method;
  final String serviceName;
  final String serviceUrl;
  final RateLimit rateLimit;
  final AuthenticationConfig authentication;
  final CachingConfig caching;
  final MonitoringConfig monitoring;
  final List<RequestTransformation> transformations;

  const APIEndpoint({
    required this.id,
    required this.path,
    required this.method,
    required this.serviceName,
    required this.serviceUrl,
    required this.rateLimit,
    required this.authentication,
    required this.caching,
    required this.monitoring,
    required this.transformations,
  });
}

class RateLimit {
  final int requestsPerMinute;
  final int requestsPerHour;
  final int requestsPerDay;

  const RateLimit({
    required this.requestsPerMinute,
    required this.requestsPerHour,
    required this.requestsPerDay,
  });
}

class AuthenticationConfig {
  final bool required;
  final AuthenticationType type;
  final List<String> scopes;

  const AuthenticationConfig({
    required this.required,
    required this.type,
    required this.scopes,
  });
}

class CachingConfig {
  final bool enabled;
  final int ttlSeconds;
  final CacheStrategy strategy;

  const CachingConfig({
    required this.enabled,
    required this.ttlSeconds,
    required this.strategy,
  });
}

class MonitoringConfig {
  final bool enabled;
  final Map<String, dynamic> alertThresholds;

  const MonitoringConfig({
    required this.enabled,
    required this.alertThresholds,
  });
}

class RequestTransformation {
  final TransformationType type;
  final Map<String, dynamic> config;

  const RequestTransformation({
    required this.type,
    required this.config,
  });
}

class APIKey {
  final String id;
  final String tenantId;
  final String name;
  final String key;
  final APIKeyStatus status;
  final List<String> permissions;
  final RateLimitRule rateLimit;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? lastUsed;
  final APIKeyUsage usage;

  const APIKey({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.key,
    required this.status,
    required this.permissions,
    required this.rateLimit,
    required this.createdAt,
    this.expiresAt,
    this.lastUsed,
    required this.usage,
  });

  APIKey copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? key,
    APIKeyStatus? status,
    List<String>? permissions,
    RateLimitRule? rateLimit,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? lastUsed,
    APIKeyUsage? usage,
  }) {
    return APIKey(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      key: key ?? this.key,
      status: status ?? this.status,
      permissions: permissions ?? this.permissions,
      rateLimit: rateLimit ?? this.rateLimit,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usage: usage ?? this.usage,
    );
  }
}

class APIKeyUsage {
  int requestsToday;
  int requestsThisMonth;
  int totalRequests;

  APIKeyUsage({
    required this.requestsToday,
    required this.requestsThisMonth,
    required this.totalRequests,
  });
}

class RateLimitRule {
  final String id;
  final String name;
  final int requestsPerMinute;
  final int requestsPerHour;
  final int requestsPerDay;
  final List<String> applicableTenants;
  final BurstConfig burst;

  const RateLimitRule({
    required this.id,
    required this.name,
    required this.requestsPerMinute,
    required this.requestsPerHour,
    required this.requestsPerDay,
    required this.applicableTenants,
    required this.burst,
  });
}

class BurstConfig {
  final bool enabled;
  final int maxBurstSize;
  final int refillRate;

  const BurstConfig({
    required this.enabled,
    required this.maxBurstSize,
    required this.refillRate,
  });
}

class APIRequest {
  final String id;
  final DateTime timestamp;
  final String method;
  final String path;
  final String apiKey;
  final String tenantId;
  final String clientIP;
  final int statusCode;
  final int responseTime;
  final int requestSize;
  final int responseSize;
  final String userAgent;
  final String endpoint;
  final String? error;

  const APIRequest({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.path,
    required this.apiKey,
    required this.tenantId,
    required this.clientIP,
    required this.statusCode,
    required this.responseTime,
    required this.requestSize,
    required this.responseSize,
    required this.userAgent,
    required this.endpoint,
    this.error,
  });
}

class APIResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final Map<String, String> headers;
  final int responseTime;

  const APIResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.responseTime,
  });

  APIResponse copyWith({
    int? statusCode,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int? responseTime,
  }) {
    return APIResponse(
      statusCode: statusCode ?? this.statusCode,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      responseTime: responseTime ?? this.responseTime,
    );
  }
}

class ServiceHealth {
  final String serviceName;
  final ServiceStatus status;
  final int responseTime;
  final double uptime;
  final DateTime lastCheck;
  final List<String> endpoints;

  const ServiceHealth({
    required this.serviceName,
    required this.status,
    required this.responseTime,
    required this.uptime,
    required this.lastCheck,
    required this.endpoints,
  });

  ServiceHealth copyWith({
    String? serviceName,
    ServiceStatus? status,
    int? responseTime,
    double? uptime,
    DateTime? lastCheck,
    List<String>? endpoints,
  }) {
    return ServiceHealth(
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      responseTime: responseTime ?? this.responseTime,
      uptime: uptime ?? this.uptime,
      lastCheck: lastCheck ?? this.lastCheck,
      endpoints: endpoints ?? this.endpoints,
    );
  }
}

class APIKeyValidation {
  final bool valid;
  final String? reason;
  final APIKey? apiKey;

  const APIKeyValidation({
    required this.valid,
    this.reason,
    this.apiKey,
  });
}

class RateLimitResult {
  final bool allowed;
  final int remaining;
  final DateTime resetTime;
  final int retryAfter;

  const RateLimitResult({
    required this.allowed,
    required this.remaining,
    required this.resetTime,
    required this.retryAfter,
  });
}

class APIAnalytics {
  final String? tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalRequests;
  final int successfulRequests;
  final int errorRequests;
  final double errorRate;
  final double averageResponseTime;
  final List<EndpointUsage> topEndpoints;
  final List<TimeSeriesPoint> requestsOverTime;
  final Map<int, int> statusCodeDistribution;

  const APIAnalytics({
    this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.totalRequests,
    required this.successfulRequests,
    required this.errorRequests,
    required this.errorRate,
    required this.averageResponseTime,
    required this.topEndpoints,
    required this.requestsOverTime,
    required this.statusCodeDistribution,
  });
}

class EndpointUsage {
  final String endpoint;
  final int requests;

  const EndpointUsage({
    required this.endpoint,
    required this.requests,
  });
}

class TimeSeriesPoint {
  final DateTime timestamp;
  final int value;

  const TimeSeriesPoint({
    required this.timestamp,
    required this.value,
  });
}

class ServiceAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String serviceName;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  const ServiceAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.serviceName,
    required this.message,
    required this.timestamp,
    this.details = const {},
  });
}

class APIMetrics {
  final String tenantId;
  final int requestsPerSecond;
  final double averageResponseTime;
  final double errorRate;
  final int activeConnections;

  const APIMetrics({
    required this.tenantId,
    required this.requestsPerSecond,
    required this.averageResponseTime,
    required this.errorRate,
    required this.activeConnections,
  });
}

// Enums
enum AuthenticationType { none, basic, bearer, apiKey, oauth2 }
enum CacheStrategy { none, lru, lfu, ttl }
enum TransformationType { headerMapping, bodyTransformation, queryParameterMapping }
enum APIKeyStatus { active, inactive, revoked, expired }
enum ServiceStatus { healthy, unhealthy, degraded, error }
enum AlertType { serviceDown, highLatency, errorRate, rateLimitExceeded }
enum AlertSeverity { low, medium, high, critical }

// Extension to add firstOrNull to Iterable
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
