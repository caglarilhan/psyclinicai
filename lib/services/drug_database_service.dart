import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'region_service.dart';

class DrugInfo {
  final String id;
  final String genericName;
  final String brandName;
  final String activeIngredient;
  final List<String> dosages;
  final List<String> forms; // tablet, kapsül, şurup, vb.
  final String category;
  final String indication;
  final List<String> contraindications;
  final List<String> sideEffects;
  final String pregnancyCategory;
  final String imageUrl;
  final Map<String, dynamic> countrySpecific; // ülke-özel bilgiler
  final String atcCode;
  final String reimbursementCode;
  final Map<String, String> warnings; // ülke-özel uyarılar

  DrugInfo({
    required this.id,
    required this.genericName,
    required this.brandName,
    required this.activeIngredient,
    required this.dosages,
    required this.forms,
    required this.category,
    required this.indication,
    required this.contraindications,
    required this.sideEffects,
    required this.pregnancyCategory,
    required this.imageUrl,
    required this.countrySpecific,
    required this.atcCode,
    required this.reimbursementCode,
    required this.warnings,
  });

  factory DrugInfo.fromJson(Map<String, dynamic> json) => DrugInfo(
    id: json['id'],
    genericName: json['genericName'],
    brandName: json['brandName'],
    activeIngredient: json['activeIngredient'],
    dosages: List<String>.from(json['dosages']),
    forms: List<String>.from(json['forms']),
    category: json['category'],
    indication: json['indication'],
    contraindications: List<String>.from(json['contraindications']),
    sideEffects: List<String>.from(json['sideEffects']),
    pregnancyCategory: json['pregnancyCategory'],
    imageUrl: json['imageUrl'],
    countrySpecific: Map<String, dynamic>.from(json['countrySpecific'] ?? {}),
    atcCode: json['atcCode'],
    reimbursementCode: json['reimbursementCode'],
    warnings: Map<String, String>.from(json['warnings'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'genericName': genericName,
    'brandName': brandName,
    'activeIngredient': activeIngredient,
    'dosages': dosages,
    'forms': forms,
    'category': category,
    'indication': indication,
    'contraindications': contraindications,
    'sideEffects': sideEffects,
    'pregnancyCategory': pregnancyCategory,
    'imageUrl': imageUrl,
    'countrySpecific': countrySpecific,
    'atcCode': atcCode,
    'reimbursementCode': reimbursementCode,
    'warnings': warnings,
  };
}

class DrugDatabaseService extends ChangeNotifier {
  static final DrugDatabaseService _instance = DrugDatabaseService._internal();
  factory DrugDatabaseService() => _instance;
  DrugDatabaseService._internal();

  final Map<String, List<DrugInfo>> _drugsByCountry = {};
  final Map<String, DrugInfo> _drugsById = {};
  String _currentCountry = 'TR';

  List<DrugInfo> get currentCountryDrugs => _drugsByCountry[_currentCountry] ?? [];
  String get currentCountry => _currentCountry;

  void initialize() {
    _loadDrugDatabases();
  }

  void setCountry(String countryCode) {
    _currentCountry = countryCode;
    notifyListeners();
  }

  Future<void> _loadDrugDatabases() async {
    try {
      // Türkiye ilaçları
      await _loadCountryDrugs('TR', 'assets/drugs/turkey_drugs.json');
      
      // ABD ilaçları
      await _loadCountryDrugs('US', 'assets/drugs/usa_drugs.json');
      
      // AB ilaçları
      await _loadCountryDrugs('EU', 'assets/drugs/europe_drugs.json');
      
    } catch (e) {
      if (kDebugMode) {
        print('İlaç veritabanı yüklenirken hata: $e');
      }
      // Demo verileri yükle
      _loadDemoDrugs();
    }
  }

  Future<void> _loadCountryDrugs(String country, String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final drugs = jsonList.map((json) => DrugInfo.fromJson(json)).toList();
      _drugsByCountry[country] = drugs;
      
      // ID bazlı erişim için
      for (var drug in drugs) {
        _drugsById['${drug.id}_$country'] = drug;
      }
    } catch (e) {
      if (kDebugMode) {
        print('$country ilaçları yüklenirken hata: $e');
      }
    }
  }

  void _loadDemoDrugs() {
    // Türkiye demo ilaçları
    _drugsByCountry['TR'] = [
      DrugInfo(
        id: 'tr_paracetamol',
        genericName: 'Parasetamol',
        brandName: 'Parol',
        activeIngredient: 'Paracetamol',
        dosages: ['500mg', '1000mg'],
        forms: ['Tablet', 'Şurup'],
        category: 'Analjezik',
        indication: 'Ateş ve ağrı tedavisi',
        contraindications: ['Karaciğer yetmezliği', 'Alkolizm'],
        sideEffects: ['Mide bulantısı', 'Karaciğer hasarı'],
        pregnancyCategory: 'B',
        imageUrl: 'assets/drug_images/paracetamol.jpg',
        countrySpecific: {
          'sgkCode': 'A01AA01',
          'price': '12.50 TL',
          'prescriptionRequired': true,
        },
        atcCode: 'N02BE01',
        reimbursementCode: 'SGK001',
        warnings: {
          'TR': 'Günde 4 gramı aşmayın. Alkol ile birlikte almayın.',
          'EU': 'Do not exceed 4g daily. Avoid with alcohol.',
          'US': 'Do not exceed 4g daily. Avoid with alcohol.',
        },
      ),
      DrugInfo(
        id: 'tr_fluoxetine',
        genericName: 'Fluoksetin',
        brandName: 'Prozac',
        activeIngredient: 'Fluoxetine',
        dosages: ['20mg', '40mg'],
        forms: ['Kapsül'],
        category: 'Antidepresan',
        indication: 'Depresyon, anksiyete bozukluğu',
        contraindications: ['MAO inhibitörü kullanımı'],
        sideEffects: ['Uykusuzluk', 'Baş ağrısı', 'Mide bulantısı'],
        pregnancyCategory: 'C',
        imageUrl: 'assets/drug_images/fluoxetine.jpg',
        countrySpecific: {
          'sgkCode': 'N06AB03',
          'price': '45.80 TL',
          'prescriptionRequired': true,
        },
        atcCode: 'N06AB03',
        reimbursementCode: 'SGK002',
        warnings: {
          'TR': 'İlk 2 hafta intihar düşünceleri artabilir.',
          'EU': 'Suicidal thoughts may increase in first 2 weeks.',
          'US': 'Suicidal thoughts may increase in first 2 weeks.',
        },
      ),
      DrugInfo(
        id: 'tr_omeprazole',
        genericName: 'Omeprazol',
        brandName: 'Losec',
        activeIngredient: 'Omeprazole',
        dosages: ['20mg', '40mg'],
        forms: ['Kapsül'],
        category: 'Proton Pompa İnhibitörü',
        indication: 'Mide ülseri, reflü',
        contraindications: ['Omeprazol alerjisi'],
        sideEffects: ['Baş ağrısı', 'İshal', 'Karın ağrısı'],
        pregnancyCategory: 'B',
        imageUrl: 'assets/drug_images/omeprazole.jpg',
        countrySpecific: {
          'sgkCode': 'A02BC01',
          'price': '28.90 TL',
          'prescriptionRequired': true,
        },
        atcCode: 'A02BC01',
        reimbursementCode: 'SGK003',
        warnings: {
          'TR': 'Yemeklerden 30 dakika önce alın.',
          'EU': 'Take 30 minutes before meals.',
          'US': 'Take 30 minutes before meals.',
        },
      ),
    ];

    // ABD demo ilaçları
    _drugsByCountry['US'] = [
      DrugInfo(
        id: 'us_acetaminophen',
        genericName: 'Acetaminophen',
        brandName: 'Tylenol',
        activeIngredient: 'Acetaminophen',
        dosages: ['325mg', '500mg', '650mg'],
        forms: ['Tablet', 'Liquid'],
        category: 'Analgesic',
        indication: 'Fever and pain relief',
        contraindications: ['Liver disease', 'Alcoholism'],
        sideEffects: ['Nausea', 'Liver damage'],
        pregnancyCategory: 'B',
        imageUrl: 'assets/drug_images/acetaminophen.jpg',
        countrySpecific: {
          'ndcCode': '50580-123-01',
          'price': '\$8.99',
          'prescriptionRequired': false,
        },
        atcCode: 'N02BE01',
        reimbursementCode: 'FDA001',
        warnings: {
          'TR': 'Günde 4 gramı aşmayın. Alkol ile birlikte almayın.',
          'EU': 'Do not exceed 4g daily. Avoid with alcohol.',
          'US': 'Do not exceed 4g daily. Avoid with alcohol.',
        },
      ),
      DrugInfo(
        id: 'us_fluoxetine',
        genericName: 'Fluoxetine',
        brandName: 'Prozac',
        activeIngredient: 'Fluoxetine',
        dosages: ['10mg', '20mg', '40mg'],
        forms: ['Capsule'],
        category: 'Antidepressant',
        indication: 'Depression, anxiety disorder',
        contraindications: ['MAO inhibitor use'],
        sideEffects: ['Insomnia', 'Headache', 'Nausea'],
        pregnancyCategory: 'C',
        imageUrl: 'assets/drug_images/fluoxetine.jpg',
        countrySpecific: {
          'ndcCode': '0777-3105-02',
          'price': '\$45.99',
          'prescriptionRequired': true,
        },
        atcCode: 'N06AB03',
        reimbursementCode: 'FDA002',
        warnings: {
          'TR': 'İlk 2 hafta intihar düşünceleri artabilir.',
          'EU': 'Suicidal thoughts may increase in first 2 weeks.',
          'US': 'Suicidal thoughts may increase in first 2 weeks.',
        },
      ),
    ];

    // AB demo ilaçları
    _drugsByCountry['EU'] = [
      DrugInfo(
        id: 'eu_paracetamol',
        genericName: 'Paracetamol',
        brandName: 'Panadol',
        activeIngredient: 'Paracetamol',
        dosages: ['500mg', '1000mg'],
        forms: ['Tablet', 'Syrup'],
        category: 'Analgesic',
        indication: 'Fever and pain relief',
        contraindications: ['Liver failure', 'Alcoholism'],
        sideEffects: ['Nausea', 'Liver damage'],
        pregnancyCategory: 'B',
        imageUrl: 'assets/drug_images/paracetamol.jpg',
        countrySpecific: {
          'emaCode': 'EMEA/H/C/000123',
          'price': '€12.50',
          'prescriptionRequired': false,
        },
        atcCode: 'N02BE01',
        reimbursementCode: 'EMA001',
        warnings: {
          'TR': 'Günde 4 gramı aşmayın. Alkol ile birlikte almayın.',
          'EU': 'Do not exceed 4g daily. Avoid with alcohol.',
          'US': 'Do not exceed 4g daily. Avoid with alcohol.',
        },
      ),
    ];

    // ID bazlı erişim için
    for (var country in _drugsByCountry.keys) {
      for (var drug in _drugsByCountry[country]!) {
        _drugsById['${drug.id}_$country'] = drug;
      }
    }
  }

  // İlaç arama
  List<DrugInfo> searchDrugs(String query) {
    final currentDrugs = currentCountryDrugs;
    if (query.isEmpty) return currentDrugs;

    final lowerQuery = query.toLowerCase();
    return currentDrugs.where((drug) {
      return drug.genericName.toLowerCase().contains(lowerQuery) ||
             drug.brandName.toLowerCase().contains(lowerQuery) ||
             drug.activeIngredient.toLowerCase().contains(lowerQuery) ||
             drug.category.toLowerCase().contains(lowerQuery) ||
             drug.indication.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Kategoriye göre filtreleme
  List<DrugInfo> getDrugsByCategory(String category) {
    return currentCountryDrugs.where((drug) => drug.category == category).toList();
  }

  // İlaç detayı
  DrugInfo? getDrugById(String id) {
    return _drugsById['${id}_$_currentCountry'];
  }

  // Kategoriler
  List<String> get categories {
    return currentCountryDrugs.map((drug) => drug.category).toSet().toList();
  }

  // Ülke-özel bilgi
  Map<String, dynamic> getCountrySpecificInfo(String drugId) {
    final drug = getDrugById(drugId);
    return drug?.countrySpecific ?? {};
  }

  // Ülke-özel uyarı
  String getCountryWarning(String drugId) {
    final drug = getDrugById(drugId);
    return drug?.warnings[_currentCountry] ?? '';
  }
}
