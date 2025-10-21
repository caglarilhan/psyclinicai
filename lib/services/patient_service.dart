import 'package:flutter/foundation.dart';

class PatientItem {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? gender;
  final String? notes;
  final bool kvkkConsent;
  final List<String> allergies;
  final List<String> currentMedications;
  final List<String> diagnosis;
  
  const PatientItem({
    required this.id, 
    required this.name, 
    this.email, 
    this.phone,
    this.birthDate,
    this.gender,
    this.notes,
    this.kvkkConsent = false,
    this.allergies = const [],
    this.currentMedications = const [],
    this.diagnosis = const [],
  });
}

class PatientDoc {
  final String id;
  final String patientId;
  final String name;
  final String mimeType; // e.g. application/pdf
  final DateTime createdAt;
  final List<int> data; // demo: memory
  const PatientDoc({
    required this.id,
    required this.patientId,
    required this.name,
    required this.mimeType,
    required this.createdAt,
    required this.data,
  });
}

class PatientService extends ChangeNotifier {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  final List<PatientItem> _patients = [
    const PatientItem(
      id: '1', 
      name: 'Ahmet Yılmaz', 
      email: 'ahmet@example.com',
      birthDate: null,
      gender: 'Erkek',
      notes: 'Tip 2 Diabetes Mellitus',
      kvkkConsent: true,
      allergies: ['Penisilin'],
      currentMedications: ['Metformin'],
      diagnosis: ['Tip 2 Diabetes Mellitus'],
    ),
    const PatientItem(
      id: '2', 
      name: 'Ayşe Demir', 
      email: 'ayse@example.com',
      birthDate: null,
      gender: 'Kadın',
      notes: 'Hipertansiyon',
      kvkkConsent: true,
      allergies: [],
      currentMedications: ['Lisinopril'],
      diagnosis: ['Esansiyel Hipertansiyon'],
    ),
    const PatientItem(
      id: '3', 
      name: 'Mehmet Kaya',
      birthDate: null,
      gender: 'Erkek',
      notes: 'Hipotiroidizm',
      kvkkConsent: true,
      allergies: [],
      currentMedications: ['Levotiroksin'],
      diagnosis: ['Subklinik Hipotiroidizm'],
    ),
    const PatientItem(
      id: '4', 
      name: 'Zeynep Can',
      birthDate: null,
      gender: 'Kadın',
      notes: 'Depresyon',
      kvkkConsent: true,
      allergies: [],
      currentMedications: ['Sertralin'],
      diagnosis: ['Major Depresif Bozukluk'],
    ),
    const PatientItem(
      id: '5', 
      name: 'Deniz Ak',
      birthDate: null,
      gender: 'Erkek',
      notes: 'Anksiyete',
      kvkkConsent: true,
      allergies: [],
      currentMedications: ['Alprazolam'],
      diagnosis: ['Yaygın Anksiyete Bozukluğu'],
    ),
    const PatientItem(
      id: '6', 
      name: 'Efe Kara',
      birthDate: null,
      gender: 'Erkek',
      notes: 'Uyku bozukluğu',
      kvkkConsent: true,
      allergies: [],
      currentMedications: ['Zolpidem'],
      diagnosis: ['İnsomnia'],
    ),
  ];

  final Map<String, List<PatientDoc>> _docsByPatient = {};

  List<PatientItem> get patients => List.unmodifiable(_patients);

  Future<void> initialize() async {}

  Future<void> addPatient(PatientItem p) async {
    _patients.add(p);
    notifyListeners();
  }

  PatientItem? getById(String id) {
    try { return _patients.firstWhere((e) => e.id == id); } catch (_) { return null; }
  }

  // Eksik metod - getPatientById
  PatientItem? getPatientById(String patientId) {
    return getById(patientId);
  }

  List<PatientDoc> getDocs(String patientId) {
    return List.unmodifiable(_docsByPatient[patientId] ?? const []);
  }

  Future<void> addDoc(PatientDoc doc) async {
    final list = _docsByPatient.putIfAbsent(doc.patientId, () => []);
    list.insert(0, doc);
    notifyListeners();
  }

  Future<void> deleteDoc(String patientId, String docId) async {
    final list = _docsByPatient[patientId];
    if (list == null) return;
    list.removeWhere((d) => d.id == docId);
    notifyListeners();
  }

  // Demo: seed birkaç PDF/PNG/TXT belge
  Future<void> seedDemoDocs() async {
    if (_docsByPatient.isNotEmpty) return;
    final now = DateTime.now();
    _docsByPatient['1'] = [
      PatientDoc(id: 'd1', patientId: '1', name: 'Onam_Formu.pdf', mimeType: 'application/pdf', createdAt: now.subtract(const Duration(days: 2)), data: <int>[]),
      PatientDoc(id: 'd2', patientId: '1', name: 'EKG.png', mimeType: 'image/png', createdAt: now.subtract(const Duration(days: 1)), data: <int>[]),
    ];
    _docsByPatient['2'] = [
      PatientDoc(id: 'd3', patientId: '2', name: 'Değerlendirme_Notu.txt', mimeType: 'text/plain', createdAt: now, data: <int>[]),
    ];
  }
}


