import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_case_management_models.dart';
import 'ai_service.dart';

class AICaseManagementService extends ChangeNotifier {
  static final AICaseManagementService _instance = AICaseManagementService._internal();
  factory AICaseManagementService() => _instance;
  AICaseManagementService._internal();

  AIService? _aiService;
  List<AICase> _cases = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<AICase> get cases => _cases;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _aiService = AIService();
      await _aiService!.initialize();
      await _loadCases();
      _isInitialized = true;
      notifyListeners();
      print('AICaseManagementService initialized successfully');
    } catch (e) {
      print('AICaseManagementService initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadCases() async {
    final prefs = await SharedPreferences.getInstance();
    final casesJson = prefs.getString('ai_cases');
    if (casesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(casesJson);
        _cases = decoded.map((item) => AICase.fromJson(item)).toList();
      } catch (e) {
        print('Error loading cases: $e');
      }
    }
  }

  Future<void> saveCase(AICase caseItem) async {
    _cases.add(caseItem);
    await _saveCases();
    notifyListeners();
  }

  Future<void> _saveCases() async {
    final prefs = await SharedPreferences.getInstance();
    final casesJson = jsonEncode(_cases.map((c) => c.toJson()).toList());
    await prefs.setString('ai_cases', casesJson);
  }
}
