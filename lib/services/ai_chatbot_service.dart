import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AIChatbotService {
  static final AIChatbotService _instance = AIChatbotService._internal();
  factory AIChatbotService() => _instance;
  AIChatbotService._internal();

  // Chatbot durumu
  bool _isOnline = true;
  bool _isTyping = false;
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _chatHistory = [];
  
  // Bot personality
  Map<String, dynamic> _botPersonality = {
    'name': 'PsyClinic AI',
    'role': 'Mental Health Assistant',
    'tone': 'professional',
    'language': 'turkish',
    'expertise': ['psychology', 'therapy', 'mental_health'],
  };
  
  // Stream controllers
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _typingController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _suggestionController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get suggestionStream => _suggestionController.stream;

  // Getter'lar
  bool get isOnline => _isOnline;
  bool get isTyping => _isTyping;
  List<Map<String, dynamic>> get conversations => List.unmodifiable(_conversations);
  List<Map<String, dynamic>> get chatHistory => List.unmodifiable(_chatHistory);
  Map<String, dynamic> get botPersonality => Map.unmodifiable(_botPersonality);

  // Servisi başlat
  Future<void> initialize() async {
    await _loadChatHistory();
    await _loadConversations();
    await _setupBotPersonality();
    
    // Welcome message
    await _sendWelcomeMessage();
  }

  // Bot personality ayarla
  Future<void> _setupBotPersonality() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPersonality = prefs.getString('bot_personality');
    
    if (savedPersonality != null) {
      _botPersonality = Map<String, dynamic>.from(json.decode(savedPersonality));
    }
  }

  // Welcome message gönder
  Future<void> _sendWelcomeMessage() async {
    final welcomeMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'bot',
      'content': 'Merhaba! Ben ${_botPersonality['name']}. Size nasıl yardımcı olabilirim?',
      'timestamp': DateTime.now().toIso8601String(),
      'suggestions': _getWelcomeSuggestions(),
    };
    
    _chatHistory.add(welcomeMessage);
    _messageController.add(welcomeMessage);
    _saveChatHistory();
  }

  // Welcome suggestions
  List<String> _getWelcomeSuggestions() {
    return [
      'Randevu almak istiyorum',
      'Terapi hakkında bilgi almak istiyorum',
      'Acil durum desteği arıyorum',
      'Sık sorulan sorular',
    ];
  }

  // Kullanıcı mesajı gönder
  Future<void> sendUserMessage(String message) async {
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'user',
      'content': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _chatHistory.add(userMessage);
    _messageController.add(userMessage);
    _saveChatHistory();
    
    // Bot yanıtı oluştur
    await _generateBotResponse(message);
  }

  // Bot yanıtı oluştur
  Future<void> _generateBotResponse(String userMessage) async {
    setTyping(true);
    
    // Simulate AI processing time
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
    
    final response = await _processUserMessage(userMessage);
    
    setTyping(false);
    
    final botMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'bot',
      'content': response['content'],
      'timestamp': DateTime.now().toIso8601String(),
      'suggestions': response['suggestions'],
      'confidence': response['confidence'],
    };
    
    _chatHistory.add(botMessage);
    _messageController.add(botMessage);
    _saveChatHistory();
  }

  // Kullanıcı mesajını işle
  Future<Map<String, dynamic>> _processUserMessage(String message) async {
    final lowerMessage = message.toLowerCase();
    
    // Intent recognition
    final intent = _recognizeIntent(lowerMessage);
    
    // Response generation
    final response = await _generateResponse(intent, message);
    
    return response;
  }

  // Intent recognition
  String _recognizeIntent(String message) {
    if (message.contains('randevu') || message.contains('appointment')) {
      return 'appointment';
    } else if (message.contains('terapi') || message.contains('therapy')) {
      return 'therapy_info';
    } else if (message.contains('acil') || message.contains('emergency')) {
      return 'emergency';
    } else if (message.contains('depresyon') || message.contains('depression')) {
      return 'depression';
    } else if (message.contains('anksiyete') || message.contains('anxiety')) {
      return 'anxiety';
    } else if (message.contains('uyku') || message.contains('sleep')) {
      return 'sleep';
    } else if (message.contains('ilaç') || message.contains('medication')) {
      return 'medication';
    } else if (message.contains('merhaba') || message.contains('hello')) {
      return 'greeting';
    } else if (message.contains('teşekkür') || message.contains('thank')) {
      return 'thanks';
    } else {
      return 'general';
    }
  }

  // Response generation
  Future<Map<String, dynamic>> _generateResponse(String intent, String originalMessage) async {
    switch (intent) {
      case 'appointment':
        return _getAppointmentResponse();
      case 'therapy_info':
        return _getTherapyInfoResponse();
      case 'emergency':
        return _getEmergencyResponse();
      case 'depression':
        return _getDepressionResponse();
      case 'anxiety':
        return _getAnxietyResponse();
      case 'sleep':
        return _getSleepResponse();
      case 'medication':
        return _getMedicationResponse();
      case 'greeting':
        return _getGreetingResponse();
      case 'thanks':
        return _getThanksResponse();
      default:
        return _getGeneralResponse();
    }
  }

  // Appointment response
  Map<String, dynamic> _getAppointmentResponse() {
    return {
      'content': 'Randevu almak için size yardımcı olabilirim. Hangi tarih ve saatte uygun olursunuz? Ayrıca hangi tür terapi hizmeti almak istiyorsunuz?',
      'suggestions': [
        'Bugün müsait',
        'Yarın müsait',
        'Bu hafta müsait',
        'Bireysel terapi',
        'Çift terapisi',
      ],
      'confidence': 0.95,
    };
  }

  // Therapy info response
  Map<String, dynamic> _getTherapyInfoResponse() {
    return {
      'content': 'Terapi hakkında bilgi vermekten memnuniyet duyarım. Hangi konuda daha detaylı bilgi almak istiyorsunuz? Bireysel terapi, çift terapisi, aile terapisi veya grup terapisi hakkında bilgi verebilirim.',
      'suggestions': [
        'Bireysel terapi',
        'Çift terapisi',
        'Aile terapisi',
        'Grup terapisi',
        'Online terapi',
      ],
      'confidence': 0.92,
    };
  }

  // Emergency response
  Map<String, dynamic> _getEmergencyResponse() {
    return {
      'content': 'Acil durumlar için lütfen hemen 112\'yi arayın veya en yakın acil servise gidin. Eğer intihar düşünceleriniz varsa, Türkiye İntiharı Önleme Merkezi\'ni (0212 444 0 183) arayabilirsiniz. Size yardımcı olmaya hazırım.',
      'suggestions': [
        '112\'yi ara',
        'Acil servise git',
        'Kriz hattını ara',
        'Yardım al',
      ],
      'confidence': 0.98,
    };
  }

  // Depression response
  Map<String, dynamic> _getDepressionResponse() {
    return {
      'content': 'Depresyon hakkında endişelerinizi anlıyorum. Bu ciddi bir durumdur ve profesyonel yardım almanız önemlidir. Size uygun bir terapist bulmanıza yardımcı olabilirim. Depresyon belirtileri neler yaşadığınızı paylaşmak ister misiniz?',
      'suggestions': [
        'Belirtilerimi anlat',
        'Terapist bul',
        'İlaç hakkında bilgi',
        'Kendime yardım et',
      ],
      'confidence': 0.94,
    };
  }

  // Anxiety response
  Map<String, dynamic> _getAnxietyResponse() {
    return {
      'content': 'Anksiyete hakkında konuşmak istediğinizi görüyorum. Anksiyete bozuklukları yaygındır ve tedavi edilebilir. Size nefes egzersizleri ve rahatlama teknikleri önerebilirim. Hangi tür anksiyete yaşadığınızı paylaşmak ister misiniz?',
      'suggestions': [
        'Nefes egzersizleri',
        'Rahatlama teknikleri',
        'Terapist bul',
        'Belirtilerimi anlat',
      ],
      'confidence': 0.93,
    };
  }

  // Sleep response
  Map<String, dynamic> _getSleepResponse() {
    return {
      'content': 'Uyku sorunları yaşadığınızı anlıyorum. Uyku hijyeni ve uyku düzeninizi iyileştirmek için size öneriler sunabilirim. Uyku sorunlarınız ne kadar süredir devam ediyor?',
      'suggestions': [
        'Uyku hijyeni',
        'Uyku düzeni',
        'Uyku günlüğü',
        'Terapist bul',
      ],
      'confidence': 0.91,
    };
  }

  // Medication response
  Map<String, dynamic> _getMedicationResponse() {
    return {
      'content': 'İlaç hakkında sorularınızı yanıtlamak için buradayım. Ancak ilaç önerileri sadece lisanslı bir psikiyatrist tarafından yapılabilir. Size uygun bir psikiyatrist bulmanıza yardımcı olabilirim.',
      'suggestions': [
        'Psikiyatrist bul',
        'İlaç yan etkileri',
        'İlaç uyumluluğu',
        'Randevu al',
      ],
      'confidence': 0.89,
    };
  }

  // Greeting response
  Map<String, dynamic> _getGreetingResponse() {
    return {
      'content': 'Merhaba! Size nasıl yardımcı olabilirim? Terapi hakkında bilgi almak, randevu almak veya başka bir konuda destek almak ister misiniz?',
      'suggestions': [
        'Terapi hakkında bilgi',
        'Randevu al',
        'Sık sorulan sorular',
        'Acil durum desteği',
      ],
      'confidence': 0.96,
    };
  }

  // Thanks response
  Map<String, dynamic> _getThanksResponse() {
    return {
      'content': 'Rica ederim! Size yardımcı olabildiğim için mutluyum. Başka bir konuda destek almak isterseniz, her zaman buradayım.',
      'suggestions': [
        'Başka soru',
        'Randevu al',
        'Terapist bul',
        'Görüşürüz',
      ],
      'confidence': 0.97,
    };
  }

  // General response
  Map<String, dynamic> _getGeneralResponse() {
    return {
      'content': 'Anladığımı düşünüyorum. Size daha iyi yardımcı olabilmem için sorunuzu biraz daha açabilir misiniz? Terapi, randevu, acil durum veya başka bir konuda destek almak ister misiniz?',
      'suggestions': [
        'Terapi hakkında bilgi',
        'Randevu al',
        'Acil durum desteği',
        'Sık sorulan sorular',
      ],
      'confidence': 0.75,
    };
  }

  // Typing indicator
  void setTyping(bool typing) {
    _isTyping = typing;
    _typingController.add(typing);
  }

  // Conversation başlat
  Future<void> startConversation(String title) async {
    final conversation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'startedAt': DateTime.now().toIso8601String(),
      'lastMessageAt': DateTime.now().toIso8601String(),
      'messageCount': 0,
      'status': 'active',
    };
    
    _conversations.add(conversation);
    _saveConversations();
  }

  // Conversation kapat
  Future<void> endConversation(String conversationId) async {
    final index = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (index != -1) {
      _conversations[index]['status'] = 'ended';
      _conversations[index]['endedAt'] = DateTime.now().toIso8601String();
      _saveConversations();
    }
  }

  // Chat history kaydet
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', json.encode(_chatHistory));
  }

  // Chat history yükle
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_history');
    if (data != null) {
      _chatHistory = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Conversations kaydet
  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('conversations', json.encode(_conversations));
  }

  // Conversations yükle
  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('conversations');
    if (data != null) {
      _conversations = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Chat history temizle
  Future<void> clearChatHistory() async {
    _chatHistory.clear();
    _saveChatHistory();
  }

  // Conversations temizle
  Future<void> clearConversations() async {
    _conversations.clear();
    _saveConversations();
  }

  // Bot personality güncelle
  Future<void> updateBotPersonality(Map<String, dynamic> personality) async {
    _botPersonality.addAll(personality);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bot_personality', json.encode(_botPersonality));
  }

  // Chatbot istatistikleri
  Map<String, dynamic> getChatbotStats() {
    return {
      'totalMessages': _chatHistory.length,
      'totalConversations': _conversations.length,
      'activeConversations': _conversations.where((conv) => conv['status'] == 'active').length,
      'botPersonality': _botPersonality,
      'isOnline': _isOnline,
    };
  }

  // Online/offline durumu
  void setOnlineStatus(bool online) {
    _isOnline = online;
  }

  // Dispose
  void dispose() {
    _messageController.close();
    _typingController.close();
    _suggestionController.close();
  }
}
