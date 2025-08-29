import '../models/prescription_models.dart';

class PrescriptionService {
  static final PrescriptionService _instance = PrescriptionService._internal();
  factory PrescriptionService() => _instance;
  PrescriptionService._internal();

  // Demo veriler
  final List<Prescription> _prescriptions = [];
  final List<Medication> _medications = [];
  final List<AIPrescriptionSuggestion> _aiSuggestions = [];

  // Initialize demo data
  Future<void> initialize() async {
    // Demo ilaçlar
    _medications.addAll([
      Medication(
        id: 'med_001',
        name: 'Sertralin',
        genericName: 'Sertraline',
        category: MedicationCategory.antidepressant,
        dosageForm: DosageForm.tablet,
        availableDosages: ['25mg', '50mg', '100mg'],
        description: 'Selektif serotonin geri alım inhibitörü (SSRI) antidepresan. Depresyon, obsesif-kompulsif bozukluk, panik bozukluğu ve sosyal anksiyete bozukluğu tedavisinde kullanılır.',
        indications: [
          'Major Depresif Bozukluk',
          'Obsesif-Kompulsif Bozukluk',
          'Panik Bozukluğu',
          'Sosyal Anksiyete Bozukluğu',
          'Travma Sonrası Stres Bozukluğu'
        ],
        contraindications: [
          'MAO inhibitörleri ile eş zamanlı kullanım',
          'Sertraline\'e aşırı duyarlılık',
          'Ciddi karaciğer yetmezliği'
        ],
        sideEffects: [
          'Mide bulantısı',
          'İshal',
          'Uykusuzluk',
          'Baş ağrısı',
          'Cinsel işlev bozukluğu',
          'Terleme'
        ],
        interactions: [
          'Warfarin - Kanama riski artışı',
          'Aspirin - Kanama riski artışı',
          'St. John\'s Wort - Serotonin sendromu riski'
        ],
        warnings: [
          'İntihar düşünceleri riski (özellikle 24 yaş altı)',
          'Serotonin sendromu riski',
          'Kanama riski artışı'
        ],
        pregnancyCategory: 'C',
        breastfeedingInfo: 'Sütte düşük konsantrasyonda bulunur, genellikle güvenli',
        pediatricInfo: '6 yaş ve üzeri çocuklarda kullanılabilir',
        geriatricInfo: 'Yaşlılarda doz ayarlaması gerekebilir',
        renalInfo: 'Böbrek yetmezliğinde doz ayarlaması gerekebilir',
        hepaticInfo: 'Karaciğer yetmezliğinde doz ayarlaması gerekebilir',
        manufacturer: 'Pfizer',
        brandNames: 'Zoloft, Lustral',
        isGeneric: false,
        isControlled: false,
      ),
      Medication(
        id: 'med_002',
        name: 'Alprazolam',
        genericName: 'Alprazolam',
        category: MedicationCategory.anxiolytic,
        dosageForm: DosageForm.tablet,
        availableDosages: ['0.25mg', '0.5mg', '1mg', '2mg'],
        description: 'Benzodiazepin sınıfı anksiyolitik. Anksiyete bozuklukları ve panik bozukluğu tedavisinde kullanılır. Hızlı etki başlangıcı vardır.',
        indications: [
          'Anksiyete Bozuklukları',
          'Panik Bozukluğu',
          'Agorafobi',
          'Uykusuzluk'
        ],
        contraindications: [
          'Benzodiazepinlere aşırı duyarlılık',
          'Myasthenia gravis',
          'Ciddi solunum yetmezliği',
          'Uyku apnesi'
        ],
        sideEffects: [
          'Uyku hali',
          'Baş dönmesi',
          'Koordinasyon bozukluğu',
          'Hafıza problemleri',
          'Bağımlılık riski',
          'Tolerans gelişimi'
        ],
        interactions: [
          'Alkol - Merkezi sinir sistemi baskılanması',
          'Opioidler - Solunum baskılanması',
          'Antidepresanlar - Sedasyon artışı'
        ],
        warnings: [
          'Bağımlılık ve tolerans gelişimi riski',
          'Ani kesimde yoksunluk belirtileri',
          'Yaşlılarda düşme riski artışı',
          'Araç kullanımında dikkat'
        ],
        pregnancyCategory: 'D',
        breastfeedingInfo: 'Sütte bulunur, emzirme sırasında kullanılmamalı',
        pediatricInfo: '18 yaş altında güvenlik belirlenmemiş',
        geriatricInfo: 'Yaşlılarda doz azaltılmalı',
        renalInfo: 'Böbrek yetmezliğinde doz ayarlaması gerekebilir',
        hepaticInfo: 'Karaciğer yetmezliğinde doz ayarlaması gerekebilir',
        manufacturer: 'Pfizer',
        brandNames: 'Xanax, Alprazolam',
        isGeneric: true,
        isControlled: true,
      ),
      Medication(
        id: 'med_003',
        name: 'Fluoksetin',
        genericName: 'Fluoxetine',
        category: MedicationCategory.antidepressant,
        dosageForm: DosageForm.capsule,
        availableDosages: ['10mg', '20mg', '40mg'],
        description: 'Selektif serotonin geri alım inhibitörü (SSRI) antidepresan. Depresyon, obsesif-kompulsif bozukluk, bulimia nervoza ve panik bozukluğu tedavisinde kullanılır.',
        indications: [
          'Major Depresif Bozukluk',
          'Obsesif-Kompulsif Bozukluk',
          'Bulimia Nervoza',
          'Panik Bozukluğu',
          'Premenstrüel Disforik Bozukluk'
        ],
        contraindications: [
          'MAO inhibitörleri ile eş zamanlı kullanım',
          'Fluoxetine\'e aşırı duyarlılık',
          'Ciddi karaciğer yetmezliği'
        ],
        sideEffects: [
          'Mide bulantısı',
          'İştahsızlık',
          'Uykusuzluk',
          'Baş ağrısı',
          'Cinsel işlev bozukluğu',
          'Titreme'
        ],
        interactions: [
          'Warfarin - Kanama riski artışı',
          'Aspirin - Kanama riski artışı',
          'St. John\'s Wort - Serotonin sendromu riski'
        ],
        warnings: [
          'İntihar düşünceleri riski (özellikle 24 yaş altı)',
          'Serotonin sendromu riski',
          'Kanama riski artışı',
          'Uzun yarılanma ömrü'
        ],
        pregnancyCategory: 'C',
        breastfeedingInfo: 'Sütte düşük konsantrasyonda bulunur, genellikle güvenli',
        pediatricInfo: '8 yaş ve üzeri çocuklarda kullanılabilir',
        geriatricInfo: 'Yaşlılarda doz ayarlaması gerekebilir',
        renalInfo: 'Böbrek yetmezliğinde doz ayarlaması gerekebilir',
        hepaticInfo: 'Karaciğer yetmezliğinde doz ayarlaması gerekebilir',
        manufacturer: 'Eli Lilly',
        brandNames: 'Prozac, Fluoxetine',
        isGeneric: true,
        isControlled: false,
      ),
    ]);

    // Demo reçeteler
    _prescriptions.addAll([
      Prescription(
        id: 'prescription_001',
        clientId: 'client_001',
        therapistId: 'therapist_001',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        status: PrescriptionStatus.active,
        type: PrescriptionType.initial,
        diagnosis: 'Major Depresif Bozukluk',
        notes: 'İlk kez antidepresan başlanıyor. Haftalık takip gerekli.',
        medications: [
          PrescribedMedication(
            id: 'pm_001',
            medicationId: 'med_001',
            medicationName: 'Sertralin',
            genericName: 'Sertraline',
            dosage: '50mg',
            dosageForm: DosageForm.tablet,
            frequency: Frequency.onceDaily,
            quantity: 30,
            refills: 2,
            instructions: 'Sabah kahvaltıdan sonra alın',
            specialInstructions: 'İlk hafta 25mg ile başla, sonra 50mg\'a çıkar',
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now().add(const Duration(days: 60)),
            isPRN: false,
            reason: 'Depresyon tedavisi',
            sideEffects: ['Mide bulantısı', 'Uykusuzluk'],
            interactions: ['Warfarin kullanımında dikkat'],
          ),
        ],
        warnings: [
          'İntihar düşünceleri riski',
          'Serotonin sendromu riski'
        ],
        contraindications: [
          'MAO inhibitörleri ile eş zamanlı kullanım'
        ],
        pharmacyNotes: 'İlk hafta 25mg ile başlanacak',
        requiresFollowUp: true,
        followUpDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Prescription(
        id: 'prescription_002',
        clientId: 'client_001',
        therapistId: 'therapist_001',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 15)),
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        status: PrescriptionStatus.active,
        type: PrescriptionType.modification,
        diagnosis: 'Major Depresif Bozukluk + Anksiyete',
        notes: 'Anksiyete belirtileri için alprazolam eklendi.',
        medications: [
          PrescribedMedication(
            id: 'pm_002',
            medicationId: 'med_001',
            medicationName: 'Sertralin',
            genericName: 'Sertraline',
            dosage: '100mg',
            dosageForm: DosageForm.tablet,
            frequency: Frequency.onceDaily,
            quantity: 30,
            refills: 2,
            instructions: 'Sabah kahvaltıdan sonra alın',
            specialInstructions: 'Doz 100mg\'a çıkarıldı',
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 45)),
            isPRN: false,
            reason: 'Depresyon tedavisi - doz artırımı',
            sideEffects: ['Mide bulantısı azaldı'],
            interactions: ['Warfarin kullanımında dikkat'],
          ),
          PrescribedMedication(
            id: 'pm_003',
            medicationId: 'med_002',
            medicationName: 'Alprazolam',
            genericName: 'Alprazolam',
            dosage: '0.5mg',
            dosageForm: DosageForm.tablet,
            frequency: Frequency.asNeeded,
            quantity: 20,
            refills: 1,
            instructions: 'Gerektiğinde günde maksimum 3 kez',
            specialInstructions: 'Sadece anksiyete krizi durumunda kullan',
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 15)),
            isPRN: true,
            reason: 'Anksiyete krizi tedavisi',
            sideEffects: ['Uyku hali', 'Baş dönmesi'],
            interactions: ['Alkol ile kullanmayın'],
          ),
        ],
        warnings: [
          'İntihar düşünceleri riski',
          'Serotonin sendromu riski',
          'Alprazolam bağımlılık riski'
        ],
        contraindications: [
          'MAO inhibitörleri ile eş zamanlı kullanım',
          'Alkol kullanımı'
        ],
        pharmacyNotes: 'Alprazolam sadece gerektiğinde kullanılacak',
        requiresFollowUp: true,
        followUpDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ]);

    // Demo AI önerileri
    _aiSuggestions.addAll([
      AIPrescriptionSuggestion(
        id: 'suggestion_001',
        medicationId: 'med_001',
        medicationName: 'Sertralin',
        reason: 'Major depresif bozukluk için birinci basamak tedavi',
        dosage: '50mg',
        frequency: Frequency.onceDaily,
        duration: 8,
        confidence: 0.92,
        evidence: [
          'SSRI sınıfı antidepresanlar depresyon için etkili',
          'Sertralin güvenlik profili iyi',
          'Yan etki profili kabul edilebilir'
        ],
        alternatives: [
          'Escitalopram 10mg',
          'Paroxetine 20mg',
          'Citalopram 20mg'
        ],
        warnings: [
          'İlk 2-4 hafta intihar düşünceleri riski',
          'Serotonin sendromu riski',
          'Kanama riski artışı'
        ],
        notes: 'Haftalık takip ile başlanmalı, doz kademeli artırılmalı',
        generatedAt: DateTime.now().subtract(const Duration(days: 30)),
        modelVersion: 'GPT-4 v1.0',
      ),
      AIPrescriptionSuggestion(
        id: 'suggestion_002',
        medicationId: 'med_002',
        medicationName: 'Alprazolam',
        reason: 'Anksiyete krizi için kısa süreli tedavi',
        dosage: '0.5mg',
        frequency: Frequency.asNeeded,
        duration: 2,
        confidence: 0.85,
        evidence: [
          'Benzodiazepinler anksiyete için hızlı etkili',
          'Kısa süreli kullanımda güvenli',
          'PRN kullanımda bağımlılık riski düşük'
        ],
        alternatives: [
          'Lorazepam 1mg',
          'Diazepam 5mg',
          'Clonazepam 0.5mg'
        ],
        warnings: [
          'Bağımlılık riski',
          'Tolerans gelişimi',
          'Ani kesimde yoksunluk belirtileri'
        ],
        notes: 'Sadece gerektiğinde kullanılmalı, uzun süreli kullanımdan kaçınılmalı',
        generatedAt: DateTime.now().subtract(const Duration(days: 15)),
        modelVersion: 'GPT-4 v1.0',
      ),
    ]);
  }

  // Prescription methods
  Future<List<Prescription>> getAllPrescriptions() async {
    await initialize();
    return List.unmodifiable(_prescriptions);
  }

  Future<Prescription?> getPrescription(String prescriptionId) async {
    await initialize();
    try {
      return _prescriptions.firstWhere((prescription) => prescription.id == prescriptionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Prescription>> getClientPrescriptions(String clientId) async {
    await initialize();
    return _prescriptions
        .where((prescription) => prescription.clientId == clientId)
        .toList()
      ..sort((a, b) => b.prescriptionDate.compareTo(a.prescriptionDate));
  }

  Future<Prescription> createPrescription(Prescription prescription) async {
    await initialize();
    _prescriptions.add(prescription);
    return prescription;
  }

  Future<Prescription> updatePrescription(Prescription prescription) async {
    await initialize();
    final index = _prescriptions.indexWhere((p) => p.id == prescription.id);
    if (index != -1) {
      _prescriptions[index] = prescription;
    }
    return prescription;
  }

  Future<void> deletePrescription(String prescriptionId) async {
    await initialize();
    _prescriptions.removeWhere((prescription) => prescription.id == prescriptionId);
  }

  // Medication methods
  Future<List<Medication>> getAllMedications() async {
    await initialize();
    return List.unmodifiable(_medications);
  }

  Future<Medication?> getMedication(String medicationId) async {
    await initialize();
    try {
      return _medications.firstWhere((medication) => medication.id == medicationId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Medication>> searchMedications(String query) async {
    await initialize();
    final lowercaseQuery = query.toLowerCase();
    return _medications.where((medication) {
      return medication.name.toLowerCase().contains(lowercaseQuery) ||
          medication.genericName.toLowerCase().contains(lowercaseQuery) ||
          medication.categoryText.toLowerCase().contains(lowercaseQuery) ||
          medication.indications.any((indication) => indication.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<Medication>> getMedicationsByCategory(MedicationCategory category) async {
    await initialize();
    return _medications.where((medication) => medication.category == category).toList();
  }

  // AI Suggestion methods
  Future<List<AIPrescriptionSuggestion>> getAISuggestions(String clientId) async {
    await initialize();
    return _aiSuggestions.where((suggestion) => 
      _prescriptions.any((p) => p.clientId == clientId && 
        p.medications.any((m) => m.medicationId == suggestion.medicationId))
    ).toList();
  }

  Future<AIPrescriptionSuggestion> createAISuggestion(AIPrescriptionSuggestion suggestion) async {
    await initialize();
    _aiSuggestions.add(suggestion);
    return suggestion;
  }

  // Utility methods
  Future<List<Prescription>> getExpiringPrescriptions() async {
    await initialize();
    final now = DateTime.now();
    return _prescriptions.where((prescription) {
      if (prescription.expiryDate == null) return false;
      final daysUntilExpiry = prescription.expiryDate!.difference(now).inDays;
      return daysUntilExpiry <= 7 && prescription.status == PrescriptionStatus.active;
    }).toList();
  }

  Future<List<Prescription>> getActivePrescriptions(String clientId) async {
    await initialize();
    return _prescriptions.where((prescription) => 
      prescription.clientId == clientId && prescription.status == PrescriptionStatus.active
    ).toList();
  }

  Future<Map<String, dynamic>> getPrescriptionStatistics() async {
    await initialize();
    final totalPrescriptions = _prescriptions.length;
    final activePrescriptions = _prescriptions.where((p) => p.status == PrescriptionStatus.active).length;
    final expiredPrescriptions = _prescriptions.where((p) => p.status == PrescriptionStatus.expired).length;
    final cancelledPrescriptions = _prescriptions.where((p) => p.status == PrescriptionStatus.cancelled).length;

    final totalMedications = _medications.length;
    final controlledMedications = _medications.where((m) => m.isControlled).length;

    return {
      'totalPrescriptions': totalPrescriptions,
      'activePrescriptions': activePrescriptions,
      'expiredPrescriptions': expiredPrescriptions,
      'cancelledPrescriptions': cancelledPrescriptions,
      'totalMedications': totalMedications,
      'controlledMedications': controlledMedications,
      'expiringSoon': (await getExpiringPrescriptions()).length,
    };
  }

  Future<void> clearAllData() async {
    _prescriptions.clear();
    _medications.clear();
    _aiSuggestions.clear();
  }

  Future<void> exportData() async {
    // TODO: Implement data export functionality
  }

  Future<void> importData() async {
    // TODO: Implement data import functionality
  }
}
