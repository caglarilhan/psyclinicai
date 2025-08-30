import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceToTextService {
  static final VoiceToTextService _instance = VoiceToTextService._internal();
  factory VoiceToTextService() => _instance;
  VoiceToTextService._internal();

  // Voice recording durumu
  bool _isRecording = false;
  bool _isProcessing = false;
  String _currentText = '';
  List<String> _recordedSessions = [];
  
  // Stream controllers
  final StreamController<bool> _recordingController = StreamController<bool>.broadcast();
  final StreamController<String> _textController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _insightsController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<bool> get recordingStream => _recordingController.stream;
  Stream<String> get textStream => _textController.stream;
  Stream<Map<String, dynamic>> get insightsStream => _insightsController.stream;

  // Getter'lar
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get currentText => _currentText;
  List<String> get recordedSessions => List.unmodifiable(_recordedSessions);

  // Voice recording başlat
  Future<void> startRecording() async {
    if (_isRecording) return;
    
    setState(() {
      _isRecording = true;
      _currentText = '';
    });
    
    _recordingController.add(true);
    
    // Simulate voice recording
    _simulateVoiceRecording();
  }

  // Voice recording durdur
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });
    
    _recordingController.add(false);
    
    // Process recorded audio
    await _processVoiceRecording();
  }

  // Voice recording simülasyonu
  void _simulateVoiceRecording() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Simulate real-time text generation
      final demoTexts = [
        'Danışan bugün depresif belirtiler gösteriyor...',
        'Seans sırasında anksiyete belirtileri gözlemlendi...',
        'Hastanın uyku düzeni bozulmuş durumda...',
        'İlaç kullanımında düzenlilik sağlanmaya çalışılıyor...',
        'Aile desteği konusunda iyileşme görülüyor...',
      ];
      
      final randomText = demoTexts[DateTime.now().millisecondsSinceEpoch % demoTexts.length];
      _currentText += randomText + ' ';
      
      _textController.add(_currentText);
    });
  }

  // Voice recording işleme
  Future<void> _processVoiceRecording() async {
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate AI insights
    final insights = await _generateAIInsights(_currentText);
    
    setState(() {
      _isProcessing = false;
    });
    
    // Save session
    _saveRecordingSession(_currentText, insights);
    
    // Send insights
    _insightsController.add(insights);
  }

  // AI insights oluştur
  Future<Map<String, dynamic>> _generateAIInsights(String text) async {
    // Simulate AI analysis
    await Future.delayed(const Duration(milliseconds: 500));
    
    final insights = <String, dynamic>{
      'text': text,
      'sentiment': _analyzeSentiment(text),
      'keywords': _extractKeywords(text),
      'topics': _identifyTopics(text),
      'emotions': _detectEmotions(text),
      'suggestions': _generateSuggestions(text),
      'riskLevel': _assessRiskLevel(text),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return insights;
  }

  // Sentiment analysis
  String _analyzeSentiment(String text) {
    final positiveWords = ['iyi', 'güzel', 'başarılı', 'olumlu', 'iyileşme', 'düzelme'];
    final negativeWords = ['kötü', 'kötüleşme', 'sorun', 'problem', 'endişe', 'kaygı'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in positiveWords) {
      if (text.toLowerCase().contains(word)) positiveCount++;
    }
    
    for (final word in negativeWords) {
      if (text.toLowerCase().contains(word)) negativeCount++;
    }
    
    if (positiveCount > negativeCount) return 'Pozitif';
    if (negativeCount > positiveCount) return 'Negatif';
    return 'Nötr';
  }

  // Keyword extraction
  List<String> _extractKeywords(String text) {
    final keywords = <String>[];
    final commonKeywords = [
      'depresyon', 'anksiyete', 'uyku', 'ilaç', 'aile', 'iş', 'ilişki',
      'stres', 'kaygı', 'panik', 'obsesyon', 'travma', 'bağımlılık',
    ];
    
    for (final keyword in commonKeywords) {
      if (text.toLowerCase().contains(keyword)) {
        keywords.add(keyword);
      }
    }
    
    return keywords;
  }

  // Topic identification
  List<String> _identifyTopics(String text) {
    final topics = <String>[];
    
    if (text.toLowerCase().contains('depresyon') || text.toLowerCase().contains('depresif')) {
      topics.add('Mood Disorders');
    }
    
    if (text.toLowerCase().contains('anksiyete') || text.toLowerCase().contains('kaygı')) {
      topics.add('Anxiety Disorders');
    }
    
    if (text.toLowerCase().contains('uyku') || text.toLowerCase().contains('insomnia')) {
      topics.add('Sleep Disorders');
    }
    
    if (text.toLowerCase().contains('ilaç') || text.toLowerCase().contains('medication')) {
      topics.add('Medication Management');
    }
    
    if (text.toLowerCase().contains('aile') || text.toLowerCase().contains('family')) {
      topics.add('Family Therapy');
    }
    
    return topics;
  }

  // Emotion detection
  Map<String, double> _detectEmotions(String text) {
    final emotions = <String, double>{
      'Mutluluk': 0.0,
      'Üzüntü': 0.0,
      'Korku': 0.0,
      'Öfke': 0.0,
      'Sakinlik': 0.0,
      'Endişe': 0.0,
    };
    
    // Simple emotion detection based on keywords
    if (text.toLowerCase().contains('mutlu') || text.toLowerCase().contains('iyi')) {
      emotions['Mutluluk'] = 0.8;
    }
    
    if (text.toLowerCase().contains('üzgün') || text.toLowerCase().contains('kötü')) {
      emotions['Üzüntü'] = 0.7;
    }
    
    if (text.toLowerCase().contains('korku') || text.toLowerCase().contains('panik')) {
      emotions['Korku'] = 0.9;
    }
    
    if (text.toLowerCase().contains('öfke') || text.toLowerCase().contains('sinir')) {
      emotions['Öfke'] = 0.6;
    }
    
    if (text.toLowerCase().contains('sakin') || text.toLowerCase().contains('rahat')) {
      emotions['Sakinlik'] = 0.8;
    }
    
    if (text.toLowerCase().contains('endişe') || text.toLowerCase().contains('kaygı')) {
      emotions['Endişe'] = 0.7;
    }
    
    return emotions;
  }

  // Suggestions generation
  List<String> _generateSuggestions(String text) {
    final suggestions = <String>[];
    
    if (text.toLowerCase().contains('depresyon')) {
      suggestions.add('CBT teknikleri uygulanabilir');
      suggestions.add('Egzersiz programı önerilebilir');
      suggestions.add('Sosyal aktivite artırılabilir');
    }
    
    if (text.toLowerCase().contains('anksiyete')) {
      suggestions.add('Nefes egzersizleri öğretilebilir');
      suggestions.add('Progressive muscle relaxation uygulanabilir');
      suggestions.add('Mindfulness teknikleri önerilebilir');
    }
    
    if (text.toLowerCase().contains('uyku')) {
      suggestions.add('Uyku hijyeni eğitimi verilebilir');
      suggestions.add('Uyku günlüğü tutulabilir');
      suggestions.add('Yatak odası optimizasyonu önerilebilir');
    }
    
    if (text.toLowerCase().contains('ilaç')) {
      suggestions.add('İlaç uyumluluğu değerlendirilebilir');
      suggestions.add('Yan etki takibi yapılabilir');
      suggestions.add('Dozaj ayarlaması gerekebilir');
    }
    
    return suggestions;
  }

  // Risk level assessment
  String _assessRiskLevel(String text) {
    final highRiskKeywords = ['intihar', 'ölüm', 'zarar', 'kendine zarar', 'umutsuz'];
    final mediumRiskKeywords = ['kaygı', 'panik', 'endişe', 'stres', 'uykusuzluk'];
    
    for (final keyword in highRiskKeywords) {
      if (text.toLowerCase().contains(keyword)) {
        return 'Yüksek';
      }
    }
    
    for (final keyword in mediumRiskKeywords) {
      if (text.toLowerCase().contains(keyword)) {
        return 'Orta';
      }
    }
    
    return 'Düşük';
  }

  // Recording session kaydet
  Future<void> _saveRecordingSession(String text, Map<String, dynamic> insights) async {
    final session = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'insights': insights,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _recordedSessions.add(json.encode(session));
    
    // SharedPreferences'a kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('voice_sessions', _recordedSessions);
  }

  // Recording sessions yükle
  Future<void> loadRecordingSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('voice_sessions') ?? [];
    _recordedSessions = sessions;
  }

  // Session sil
  Future<void> deleteSession(String sessionId) async {
    _recordedSessions.removeWhere((session) {
      final data = json.decode(session);
      return data['id'] == sessionId;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('voice_sessions', _recordedSessions);
  }

  // Tüm sessions temizle
  Future<void> clearAllSessions() async {
    _recordedSessions.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('voice_sessions');
  }

  // Voice-to-text istatistikleri
  Map<String, dynamic> getVoiceStats() {
    return {
      'totalSessions': _recordedSessions.length,
      'totalDuration': _recordedSessions.length * 5, // Simulated duration
      'averageSentiment': _calculateAverageSentiment(),
      'mostCommonTopics': _getMostCommonTopics(),
      'lastRecording': _recordedSessions.isNotEmpty ? _recordedSessions.last : null,
    };
  }

  // Average sentiment hesapla
  String _calculateAverageSentiment() {
    if (_recordedSessions.isEmpty) return 'N/A';
    
    int positiveCount = 0;
    int negativeCount = 0;
    int neutralCount = 0;
    
    for (final session in _recordedSessions) {
      final data = json.decode(session);
      final sentiment = data['insights']['sentiment'];
      
      switch (sentiment) {
        case 'Pozitif':
          positiveCount++;
          break;
        case 'Negatif':
          negativeCount++;
          break;
        default:
          neutralCount++;
      }
    }
    
    if (positiveCount > negativeCount && positiveCount > neutralCount) {
      return 'Pozitif';
    } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
      return 'Negatif';
    } else {
      return 'Nötr';
    }
  }

  // Most common topics
  List<String> _getMostCommonTopics() {
    if (_recordedSessions.isEmpty) return [];
    
    final topicCounts = <String, int>{};
    
    for (final session in _recordedSessions) {
      final data = json.decode(session);
      final topics = data['insights']['topics'] as List;
      
      for (final topic in topics) {
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }
    }
    
    final sortedTopics = topicCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTopics.take(3).map((e) => e.key).toList();
  }

  // Dispose
  void dispose() {
    _recordingController.close();
    _textController.close();
    _insightsController.close();
  }

  // State management için helper
  void setState(VoidCallback fn) {
    fn();
  }
}
