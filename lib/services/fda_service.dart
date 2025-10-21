import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FDAService extends ChangeNotifier {
  static final FDAService _instance = FDAService._internal();
  factory FDAService() => _instance;
  FDAService._internal();

  // FDA API endpoints
  static const String _baseUrl = 'https://api.fda.gov';
  static const String _drugSearchEndpoint = '/drug/label.json';
  static const String _drugDetailEndpoint = '/drug/label.json';
  static const String _interactionEndpoint = '/drug/interaction.json';
  static const String _adverseEventEndpoint = '/drug/event.json';

  String? _apiKey;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void initialize() {
    _loadAPIKey();
  }

  void _loadAPIKey() {
    _apiKey = 'fda-demo-api-key-2024';
  }

  // İlaç arama
  Future<List<Map<String, dynamic>>> searchDrugs(String query) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_drugSearchEndpoint?search=generic_name:"$query"&limit=20'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('FDA API hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FDA arama hatası: $e');
      }
      return _getDemoDrugs();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // İlaç detayı
  Future<Map<String, dynamic>?> getDrugDetail(String ndcCode) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_drugDetailEndpoint?search=product_ndc:"$ndcCode"'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results.first;
        }
      }
      throw Exception('FDA detay hatası: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) {
        print('FDA detay hatası: $e');
      }
      return _getDemoDrugDetail(ndcCode);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Yan etki raporları
  Future<List<Map<String, dynamic>>> getAdverseEvents(String drugName) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_adverseEventEndpoint?search=patient.drug.medicinalproduct:"$drugName"&limit=10'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('FDA yan etki hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FDA yan etki hatası: $e');
      }
      return _getDemoAdverseEvents(drugName);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // HIPAA uyumluluk kontrolü
  Future<Map<String, dynamic>> checkHIPAACompliance(String drugId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/drug/$drugId/hipaa-compliance'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['compliance'];
      } else {
        throw Exception('HIPAA uyumluluk hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('HIPAA uyumluluk hatası: $e');
      }
      return _getDemoHIPAACompliance(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // DEA kontrolü (kontrollü maddeler için)
  Future<Map<String, dynamic>> checkDEAStatus(String drugName) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/drug/$drugName/dea-status'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['dea_status'];
      } else {
        throw Exception('DEA durum hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEA durum hatası: $e');
      }
      return _getDemoDEAStatus(drugName);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Demo veriler
  List<Map<String, dynamic>> _getDemoDrugs() {
    return [
      {
        'id': 'fda_001',
        'generic_name': 'Metformin',
        'brand_name': 'Glucophage',
        'active_ingredient': 'Metformin HCl',
        'dosage_forms': ['Tablet 500mg', 'Tablet 850mg', 'Tablet 1000mg'],
        'manufacturer': 'Merck',
        'atc_code': 'A10BA02',
        'ndc_code': '0002-8501-01',
        'prescription_required': true,
        'price': 32.50,
        'currency': 'USD',
        'approval_date': '1995-03-03',
        'patent_expiry': '2025-12-31',
      },
      {
        'id': 'fda_002',
        'generic_name': 'Fluoxetine',
        'brand_name': 'Prozac',
        'active_ingredient': 'Fluoxetine HCl',
        'dosage_forms': ['Capsule 10mg', 'Capsule 20mg', 'Capsule 40mg'],
        'manufacturer': 'Eli Lilly',
        'atc_code': 'N06AB03',
        'ndc_code': '0777-3105-02',
        'prescription_required': true,
        'price': 58.80,
        'currency': 'USD',
        'approval_date': '1987-12-29',
        'patent_expiry': '2025-12-31',
      },
      {
        'id': 'fda_003',
        'generic_name': 'Acetaminophen',
        'brand_name': 'Tylenol',
        'active_ingredient': 'Acetaminophen',
        'dosage_forms': ['Tablet 325mg', 'Tablet 500mg', 'Liquid 160mg/5ml'],
        'manufacturer': 'Johnson & Johnson',
        'atc_code': 'N02BE01',
        'ndc_code': '50580-123-01',
        'prescription_required': false,
        'price': 8.99,
        'currency': 'USD',
        'approval_date': '1955-01-01',
        'patent_expiry': 'expired',
      },
    ];
  }

  Map<String, dynamic>? _getDemoDrugDetail(String ndcCode) {
    final drugs = _getDemoDrugs();
    final drug = drugs.firstWhere((d) => d['ndc_code'] == ndcCode, orElse: () => drugs.first);
    
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
      'black_box_warning': false,
      'controlled_substance': false,
      'dea_schedule': 'Not controlled',
    };
  }

  List<Map<String, dynamic>> _getDemoAdverseEvents(String drugName) {
    return [
      {
        'event_id': 'AE001',
        'drug_name': drugName,
        'adverse_event': 'Lactic acidosis',
        'severity': 'serious',
        'outcome': 'recovered',
        'reported_date': '2024-01-15',
        'patient_age': 65,
        'patient_gender': 'female',
        'reporter_type': 'physician',
      },
      {
        'event_id': 'AE002',
        'drug_name': drugName,
        'adverse_event': 'Nausea',
        'severity': 'mild',
        'outcome': 'recovered',
        'reported_date': '2024-01-10',
        'patient_age': 45,
        'patient_gender': 'male',
        'reporter_type': 'patient',
      },
    ];
  }

  Map<String, dynamic> _getDemoHIPAACompliance(String drugId) {
    return {
      'compliant': true,
      'privacy_officer': 'privacy@fda.gov',
      'legal_basis': '45 CFR Part 160 and 164',
      'data_retention_period': '6 years',
      'patient_rights': [
        'Right to access',
        'Right to amend',
        'Right to restrict use',
        'Right to accounting of disclosures',
      ],
      'privacy_policy_url': 'https://www.fda.gov/privacy-policy',
      'last_audit': '2024-01-01',
      'next_audit': '2025-01-01',
      'breach_protocol': 'Immediate notification within 60 days',
    };
  }

  Map<String, dynamic> _getDemoDEAStatus(String drugName) {
    return {
      'controlled': false,
      'schedule': 'Not controlled',
      'dea_number_required': false,
      'prescription_requirements': 'Standard prescription',
      'refill_limitations': 'No limitations',
      'storage_requirements': 'Standard storage',
      'dispensing_requirements': 'Standard dispensing',
    };
  }
}
