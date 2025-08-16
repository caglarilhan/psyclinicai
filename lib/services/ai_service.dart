class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<Map<String, dynamic>> generateSessionSummary(
      String sessionNotes) async {
    // TODO: OpenAI/Claude API entegrasyonu
    await Future.delayed(const Duration(seconds: 3)); // Simülasyon

    // Demo AI özeti
    return {
      'affect': 'Üzgün ve umutsuz',
      'theme': 'Değersizlik hissi ve sosyal izolasyon',
      'icdSuggestion': '6B00.0',
      'riskLevel': 'Orta',
      'recommendedIntervention': 'CBT + Sosyal destek grupları',
      'confidence': 0.85,
    };
  }

  Future<List<String>> suggestMedications(
      String diagnosis, List<String> currentMeds) async {
    // TODO: AI ilaç önerisi
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon

    return [
      'Escitalopram 10mg',
      'Bupropion 150mg',
      'Mirtazapine 15mg',
    ];
  }

  Future<List<String>> suggestEducationalContent(
      String specialty, int experienceYears) async {
    // TODO: AI eğitim içerik önerisi
    await Future.delayed(const Duration(seconds: 1)); // Simülasyon

    return [
      'Depresyon için CBT Protokolleri',
      'Anksiyete Bozuklukları Eğitimi',
      'Kriz Müdahale Teknikleri',
    ];
  }

  Future<String> simulateTherapySession(
      String clientGoal, String therapistMessage) async {
    // TODO: AI terapi simülasyonu
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon

    return 'Danışan: "Evet, haklısınız. Bu yaklaşımı denemek istiyorum."';
  }
}
