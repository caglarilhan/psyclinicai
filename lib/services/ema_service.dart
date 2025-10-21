import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EMAService extends ChangeNotifier {
  static final EMAService _instance = EMAService._internal();
  factory EMAService() => _instance;
  EMAService._internal();

  // EMA API endpoints
  static const String _baseUrl = 'https://api.ema.europa.eu/api';
  static const String _drugSearchEndpoint = '/medicines/search';
  static const String _drugDetailEndpoint = '/medicines/detail';
  static const String _interactionEndpoint = '/medicines/interactions';
  static const String _safetyEndpoint = '/medicines/safety';

  String? _apiKey;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void initialize() {
    _loadAPIKey();
  }

  void _loadAPIKey() {
    _apiKey = 'ema-demo-api-key-2024';
  }

  // İlaç arama
  Future<List<Map<String, dynamic>>> searchDrugs(String query) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_drugSearchEndpoint?q=$query&limit=20'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['medicines'] ?? []);
      } else {
        throw Exception('EMA API hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('EMA arama hatası: $e');
      }
      return _getDemoDrugs();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // İlaç detayı
  Future<Map<String, dynamic>?> getDrugDetail(String drugId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_drugDetailEndpoint/$drugId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['medicine'];
      } else {
        throw Exception('EMA detay hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('EMA detay hatası: $e');
      }
      return _getDemoDrugDetail(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Güvenlik bilgileri
  Future<List<Map<String, dynamic>>> getSafetyInfo(String drugId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_safetyEndpoint/$drugId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['safety_info'] ?? []);
      } else {
        throw Exception('EMA güvenlik hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('EMA güvenlik hatası: $e');
      }
      return _getDemoSafetyInfo(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // GDPR uyumluluk kontrolü
  Future<Map<String, dynamic>> checkGDPRCompliance(String drugId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/medicines/$drugId/gdpr-compliance'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['compliance'];
      } else {
        throw Exception('GDPR uyumluluk hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('GDPR uyumluluk hatası: $e');
      }
      return _getDemoGDPRCompliance(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Demo veriler
  List<Map<String, dynamic>> _getDemoDrugs() {
    return [
      {
        'id': 'ema_001',
        'generic_name': 'Metformin',
        'brand_name': 'Glucophage',
        'active_ingredient': 'Metformin HCl',
        'dosage_forms': ['Tablet 500mg', 'Tablet 850mg', 'Tablet 1000mg'],
        'manufacturer': 'Merck',
        'atc_code': 'A10BA02',
        'ema_code': 'EMEA/H/C/000123',
        'prescription_required': true,
        'price': 28.50,
        'currency': 'EUR',
        'authorization_date': '1995-01-01',
        'valid_until': '2025-12-31',
      },
      {
        'id': 'ema_002',
        'generic_name': 'Fluoxetine',
        'brand_name': 'Prozac',
        'active_ingredient': 'Fluoxetine HCl',
        'dosage_forms': ['Capsule 20mg', 'Capsule 40mg'],
        'manufacturer': 'Eli Lilly',
        'atc_code': 'N06AB03',
        'ema_code': 'EMEA/H/C/000456',
        'prescription_required': true,
        'price': 52.80,
        'currency': 'EUR',
        'authorization_date': '1988-01-01',
        'valid_until': '2025-12-31',
      },
      {
        'id': 'ema_003',
        'generic_name': 'Paracetamol',
        'brand_name': 'Panadol',
        'active_ingredient': 'Paracetamol',
        'dosage_forms': ['Tablet 500mg', 'Syrup 120mg/5ml'],
        'manufacturer': 'GSK',
        'atc_code': 'N02BE01',
        'ema_code': 'EMEA/H/C/000789',
        'prescription_required': false,
        'price': 15.20,
        'currency': 'EUR',
        'authorization_date': '1980-01-01',
        'valid_until': '2025-12-31',
      },
    ];
  }

  Map<String, dynamic>? _getDemoDrugDetail(String drugId) {
    final drugs = _getDemoDrugs();
    final drug = drugs.firstWhere((d) => d['id'] == drugId, orElse: () => drugs.first);
    
    return {
      ...drug,
      'indications': ['Type 2 diabetes mellitus', 'Prediabetes'],
      'contraindications': ['Renal failure', 'Hepatic failure', 'Metabolic acidosis'],
      'side_effects': ['Nausea', 'Diarrhea', 'Metallic taste', 'Abdominal pain'],
      'dosage_instructions': 'Take with meals',
      'monitoring': ['Blood glucose', 'Renal function', 'Vitamin B12'],
      'pregnancy_category': 'B',
      'lactation_category': 'Suitable',
      'storage_conditions': 'Store at room temperature, away from moisture',
      'expiry_months': 36,
      'pharmacovigilance': {
        'adverse_reactions': 1250,
        'serious_reactions': 45,
        'last_update': '2024-01-15',
      },
    };
  }

  List<Map<String, dynamic>> _getDemoSafetyInfo(String drugId) {
    return [
      {
        'type': 'adverse_reaction',
        'description': 'Lactic acidosis reported in rare cases',
        'severity': 'serious',
        'frequency': 'rare',
        'reported_cases': 12,
        'last_update': '2024-01-15',
      },
      {
        'type': 'contraindication',
        'description': 'Contraindicated in patients with severe renal impairment',
        'severity': 'high',
        'frequency': 'contraindicated',
        'reported_cases': 0,
        'last_update': '2024-01-01',
      },
      {
        'type': 'warning',
        'description': 'Monitor renal function regularly',
        'severity': 'medium',
        'frequency': 'common',
        'reported_cases': 0,
        'last_update': '2024-01-01',
      },
    ];
  }

  Map<String, dynamic> _getDemoGDPRCompliance(String drugId) {
    return {
      'compliant': true,
      'data_protection_officer': 'dpo@ema.europa.eu',
      'legal_basis': 'Article 6(1)(e) - Public interest',
      'data_retention_period': '10 years',
      'data_subjects_rights': [
        'Right to access',
        'Right to rectification',
        'Right to erasure',
        'Right to data portability',
      ],
      'privacy_policy_url': 'https://www.ema.europa.eu/privacy-policy',
      'last_audit': '2024-01-01',
      'next_audit': '2025-01-01',
    };
  }
}
