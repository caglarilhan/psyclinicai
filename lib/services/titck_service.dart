import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TITCKService extends ChangeNotifier {
  static final TITCKService _instance = TITCKService._internal();
  factory TITCKService() => _instance;
  TITCKService._internal();

  // TITCK API endpoints
  static const String _baseUrl = 'https://api.titck.gov.tr/api';
  static const String _drugSearchEndpoint = '/drugs/search';
  static const String _drugDetailEndpoint = '/drugs/detail';
  static const String _interactionEndpoint = '/drugs/interactions';
  static const String _reimbursementEndpoint = '/reimbursement/check';

  String? _apiKey;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void initialize() {
    // API anahtarını yükle (gerçek uygulamada secure storage'dan)
    _loadAPIKey();
  }

  void _loadAPIKey() {
    // Demo API anahtarı (gerçek uygulamada flutter_secure_storage kullanılır)
    _apiKey = 'titck-demo-api-key-2024';
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
        return List<Map<String, dynamic>>.from(data['drugs'] ?? []);
      } else {
        throw Exception('TITCK API hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('TITCK arama hatası: $e');
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
        return data['drug'];
      } else {
        throw Exception('TITCK detay hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('TITCK detay hatası: $e');
      }
      return _getDemoDrugDetail(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // İlaç etkileşimleri
  Future<List<Map<String, dynamic>>> getDrugInteractions(String drugId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_interactionEndpoint/$drugId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['interactions'] ?? []);
      } else {
        throw Exception('TITCK etkileşim hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('TITCK etkileşim hatası: $e');
      }
      return _getDemoInteractions(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Geri ödeme kontrolü
  Future<Map<String, dynamic>> checkReimbursement(String drugId, String patientId) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_reimbursementEndpoint'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'drug_id': drugId,
          'patient_id': patientId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reimbursement'];
      } else {
        throw Exception('TITCK geri ödeme hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('TITCK geri ödeme hatası: $e');
      }
      return _getDemoReimbursement(drugId);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // E-reçete entegrasyonu
  Future<Map<String, dynamic>> createERecipe(Map<String, dynamic> prescriptionData) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/erecipe/create'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(prescriptionData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['erecipe'];
      } else {
        throw Exception('E-reçete oluşturma hatası: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('E-reçete oluşturma hatası: $e');
      }
      return _getDemoERecipe(prescriptionData);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Demo veriler
  List<Map<String, dynamic>> _getDemoDrugs() {
    return [
      {
        'id': 'titck_001',
        'generic_name': 'Metformin',
        'brand_name': 'Glucophage',
        'active_ingredient': 'Metformin HCl',
        'dosage_forms': ['Tablet 500mg', 'Tablet 850mg', 'Tablet 1000mg'],
        'manufacturer': 'Merck',
        'atc_code': 'A10BA02',
        'sgk_code': 'A10BA02',
        'prescription_required': true,
        'reimbursement_rate': 80,
        'price': 25.50,
        'currency': 'TRY',
      },
      {
        'id': 'titck_002',
        'generic_name': 'Fluoksetin',
        'brand_name': 'Prozac',
        'active_ingredient': 'Fluoxetine HCl',
        'dosage_forms': ['Kapsül 20mg', 'Kapsül 40mg'],
        'manufacturer': 'Eli Lilly',
        'atc_code': 'N06AB03',
        'sgk_code': 'N06AB03',
        'prescription_required': true,
        'reimbursement_rate': 80,
        'price': 45.80,
        'currency': 'TRY',
      },
      {
        'id': 'titck_003',
        'generic_name': 'Parasetamol',
        'brand_name': 'Parol',
        'active_ingredient': 'Paracetamol',
        'dosage_forms': ['Tablet 500mg', 'Şurup 120mg/5ml'],
        'manufacturer': 'Bilim İlaç',
        'atc_code': 'N02BE01',
        'sgk_code': 'N02BE01',
        'prescription_required': false,
        'reimbursement_rate': 0,
        'price': 12.50,
        'currency': 'TRY',
      },
    ];
  }

  Map<String, dynamic>? _getDemoDrugDetail(String drugId) {
    final drugs = _getDemoDrugs();
    final drug = drugs.firstWhere((d) => d['id'] == drugId, orElse: () => drugs.first);
    
    return {
      ...drug,
      'indications': ['Tip 2 Diabetes Mellitus', 'Prediabetes'],
      'contraindications': ['Böbrek yetmezliği', 'Karaciğer yetmezliği', 'Metabolik asidoz'],
      'side_effects': ['Mide bulantısı', 'İshal', 'Metalik tat', 'Karın ağrısı'],
      'dosage_instructions': 'Yemeklerle birlikte alın',
      'monitoring': ['Kan şekeri', 'Böbrek fonksiyonları', 'B12 vitamini'],
      'pregnancy_category': 'B',
      'lactation_category': 'Uygun',
      'storage_conditions': 'Oda sıcaklığında, nemden uzak',
      'expiry_months': 36,
    };
  }

  List<Map<String, dynamic>> _getDemoInteractions(String drugId) {
    return [
      {
        'interacting_drug': 'Warfarin',
        'interaction_type': 'moderate',
        'mechanism': 'Metformin warfarinin etkisini artırabilir',
        'clinical_effect': 'Kanama riski artışı',
        'recommendation': 'INR değerleri yakın takip edilmeli',
        'severity': 'medium',
      },
      {
        'interacting_drug': 'Digoksin',
        'interaction_type': 'minor',
        'mechanism': 'Renal clearance etkileşimi',
        'clinical_effect': 'Digoksin seviyelerinde artış',
        'recommendation': 'Digoksin seviyeleri kontrol edilmeli',
        'severity': 'low',
      },
    ];
  }

  Map<String, dynamic> _getDemoReimbursement(String drugId) {
    return {
      'eligible': true,
      'reimbursement_rate': 80,
      'patient_contribution': 5.10,
      'sgk_contribution': 20.40,
      'total_price': 25.50,
      'currency': 'TRY',
      'valid_until': '2024-12-31',
      'conditions': ['Tip 2 diabetes tanısı', 'SGK kapsamında hasta'],
    };
  }

  Map<String, dynamic> _getDemoERecipe(Map<String, dynamic> prescriptionData) {
    return {
      'erecipe_id': 'ER${DateTime.now().millisecondsSinceEpoch}',
      'status': 'created',
      'created_at': DateTime.now().toIso8601String(),
      'valid_until': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'patient_id': prescriptionData['patient_id'],
      'doctor_id': prescriptionData['doctor_id'],
      'drugs': prescriptionData['drugs'],
      'qr_code': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
    };
  }
}
