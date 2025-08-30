import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // API configuration
  String _baseUrl = 'https://api.psycliniciai.com';
  String? _authToken;
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // API endpoints
  static const String _endpoints = {
    'auth': '/auth',
    'clients': '/clients',
    'sessions': '/sessions',
    'appointments': '/appointments',
    'diagnoses': '/diagnoses',
    'medications': '/medications',
    'notes': '/notes',
    'analytics': '/analytics',
    'export': '/export',
    'webhooks': '/webhooks',
  };

  // Stream controllers
  final StreamController<Map<String, dynamic>> _apiStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _webhookController = StreamController<String>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get apiStatusStream => _apiStatusController.stream;
  Stream<String> get webhookStream => _webhookController.stream;

  // Getter'lar
  String get baseUrl => _baseUrl;
  String? get authToken => _authToken;
  Map<String, String> get headers => Map.unmodifiable(_headers);

  // Servisi başlat
  Future<void> initialize() async {
    await _loadAuthToken();
    await _checkApiStatus();
  }

  // Auth token yükle
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    
    if (_authToken != null) {
      _headers['Authorization'] = 'Bearer $_authToken';
    }
  }

  // Auth token kaydet
  Future<void> _saveAuthToken(String token) async {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // API status kontrol et
  Future<void> _checkApiStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      final status = {
        'isOnline': response.statusCode == 200,
        'statusCode': response.statusCode,
        'responseTime': DateTime.now().millisecondsSinceEpoch,
      };

      _apiStatusController.add(status);
    } catch (e) {
      _apiStatusController.add({
        'isOnline': false,
        'error': e.toString(),
        'responseTime': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${_endpoints['auth']}/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveAuthToken(data['token']);
        return data;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl${_endpoints['auth']}/logout'),
        headers: _headers,
      );
    } catch (e) {
      // Ignore logout errors
    } finally {
      _authToken = null;
      _headers.remove('Authorization');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }

  // CRUD Operations
  Future<List<Map<String, dynamic>>> getClients({Map<String, dynamic>? filters}) async {
    return await _getData(_endpoints['clients']!, filters);
  }

  Future<Map<String, dynamic>> getClient(String id) async {
    return await _getData('${_endpoints['clients']}/$id');
  }

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> data) async {
    return await _postData(_endpoints['clients']!, data);
  }

  Future<Map<String, dynamic>> updateClient(String id, Map<String, dynamic> data) async {
    return await _putData('${_endpoints['clients']}/$id', data);
  }

  Future<void> deleteClient(String id) async {
    await _deleteData('${_endpoints['clients']}/$id');
  }

  // Sessions
  Future<List<Map<String, dynamic>>> getSessions({Map<String, dynamic>? filters}) async {
    return await _getData(_endpoints['sessions']!, filters);
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    return await _postData(_endpoints['sessions']!, data);
  }

  Future<Map<String, dynamic>> updateSession(String id, Map<String, dynamic> data) async {
    return await _putData('${_endpoints['sessions']}/$id', data);
  }

  // Appointments
  Future<List<Map<String, dynamic>>> getAppointments({Map<String, dynamic>? filters}) async {
    return await _getData(_endpoints['appointments']!, filters);
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    return await _postData(_endpoints['appointments']!, data);
  }

  Future<Map<String, dynamic>> updateAppointment(String id, Map<String, dynamic> data) async {
    return await _putData('${_endpoints['appointments']}/$id', data);
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics({Map<String, dynamic>? filters}) async {
    return await _getData(_endpoints['analytics']!, filters);
  }

  // Export
  Future<String> exportData(String format, {Map<String, dynamic>? filters}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${_endpoints['export']}'),
        headers: _headers,
        body: json.encode({
          'format': format,
          'filters': filters,
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Export failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Export error: $e');
    }
  }

  // Webhooks
  Future<List<Map<String, dynamic>>> getWebhooks() async {
    return await _getData(_endpoints['webhooks']!);
  }

  Future<Map<String, dynamic>> createWebhook(Map<String, dynamic> data) async {
    return await _postData(_endpoints['webhooks']!, data);
  }

  Future<void> deleteWebhook(String id) async {
    await _deleteData('${_endpoints['webhooks']}/$id');
  }

  // Generic HTTP methods
  Future<List<Map<String, dynamic>>> _getData(String endpoint, [Map<String, dynamic>? filters]) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final queryParams = filters?.map((key, value) => MapEntry(key, value.toString())) ?? {};
      
      final response = await http.get(
        uri.replace(queryParameters: queryParams),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('GET failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('GET error: $e');
    }
  }

  Future<Map<String, dynamic>> _postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('POST failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('POST error: $e');
    }
  }

  Future<Map<String, dynamic>> _putData(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('PUT failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('PUT error: $e');
    }
  }

  Future<void> _deleteData(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('DELETE failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('DELETE error: $e');
    }
  }

  // Webhook handler
  void handleWebhook(String webhookData) {
    _webhookController.add(webhookData);
  }

  // API status monitoring
  void startStatusMonitoring() {
    Timer.periodic(const Duration(minutes: 1), (_) {
      _checkApiStatus();
    });
  }

  // API configuration
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  void setCustomHeaders(Map<String, String> headers) {
    _headers.addAll(headers);
  }

  // API statistics
  Map<String, dynamic> getApiStats() {
    return {
      'baseUrl': _baseUrl,
      'isAuthenticated': _authToken != null,
      'endpoints': _endpoints.length,
      'customHeaders': _headers.length,
    };
  }

  // Dispose
  void dispose() {
    _apiStatusController.close();
    _webhookController.close();
  }
}
