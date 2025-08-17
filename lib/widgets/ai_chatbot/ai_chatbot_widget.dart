import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../services/ai_service.dart';

class AIChatbotWidget extends StatefulWidget {
  const AIChatbotWidget({super.key});

  @override
  State<AIChatbotWidget> createState() => _AIChatbotWidgetState();
}

class _AIChatbotWidgetState extends State<AIChatbotWidget>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isEmergencyMode = false;
  bool _is24HourMode = true;
  
  // AI Chatbot için yeni özellikler
  late AnimationController _emergencyAnimationController;
  late AnimationController _typingAnimationController;
  
  // Acil durum tespiti
  bool _hasEmergencyKeywords = false;
  List<String> _emergencyKeywords = [
    'intihar', 'ölüm', 'kendimi öldürmek', 'artık yaşamak istemiyorum',
    'acil', 'kriz', 'panik', 'kontrolümü kaybettim', 'yardım',
    'bıçak', 'ilaç', 'zehir', 'asılma', 'kendine zarar'
  ];

  @override
  void initState() {
    super.initState();
    _emergencyAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _initializeChatbot();
  }

  @override
  void dispose() {
    _emergencyAnimationController.dispose();
    _typingAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChatbot() {
    // Hoş geldin mesajı
    _addMessage(
      ChatMessage(
        text: 'Merhaba! Ben PsyClinic AI Asistan. Size nasıl yardımcı olabilirim?\n\n'
              '🆘 Acil durumlar için "ACİL" yazabilirsiniz\n'
              '💊 İlaç bilgileri için "İLAÇ" yazabilirsiniz\n'
              '📅 Randevu bilgileri için "RANDEVU" yazabilirsiniz\n'
              '❓ Genel sorular için istediğinizi yazabilirsiniz',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.welcome,
      ),
    );
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    
    // Acil durum tespiti
    if (message.isUser) {
      _checkEmergencyKeywords(message.text);
    }
    
    _scrollToBottom();
  }

  void _checkEmergencyKeywords(String text) {
    final lowerText = text.toLowerCase();
    _hasEmergencyKeywords = _emergencyKeywords.any(
      (keyword) => lowerText.contains(keyword.toLowerCase()),
    );
    
    if (_hasEmergencyKeywords) {
      _activateEmergencyMode();
    }
  }

  void _activateEmergencyMode() {
    setState(() {
      _isEmergencyMode = true;
    });
    
    _emergencyAnimationController.repeat();
    
    // Acil durum mesajı
    _addMessage(
      ChatMessage(
        text: '🚨 ACİL DURUM TESPİT EDİLDİ!\n\n'
              'Lütfen hemen aşağıdaki numaralardan birini arayın:\n'
              '📞 Acil Psikiyatri: 112\n'
              '📞 İntihar Önleme: 184\n'
              '📞 Psikolojik Destek: 0850 XXX XX XX\n\n'
              'Size yardımcı olmak için buradayım. Lütfen güvende olduğunuzdan emin olun.',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.emergency,
      ),
    );
    
    // 30 saniye sonra acil durum modunu kapat
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isEmergencyMode = false;
        });
        _emergencyAnimationController.stop();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Kullanıcı mesajını ekle
    _addMessage(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
      ),
    );

    _messageController.clear();
    setState(() {
      _isTyping = true;
    });

    // AI yanıtını simüle et
    await Future.delayed(const Duration(seconds: 1));
    
    final aiResponse = await _generateAIResponse(text);
    
    setState(() {
      _isTyping = false;
    });

    _addMessage(
      ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: _getMessageType(aiResponse),
      ),
    );
  }

  MessageType _getMessageType(String response) {
    if (response.contains('🚨') || response.contains('ACİL')) {
      return MessageType.emergency;
    } else if (response.contains('💊') || response.contains('İLAÇ')) {
      return MessageType.medication;
    } else if (response.contains('📅') || response.contains('RANDEVU')) {
      return MessageType.appointment;
    } else if (response.contains('✅') || response.contains('YARDIM')) {
      return MessageType.help;
    }
    return MessageType.normal;
  }

  Future<String> _generateAIResponse(String userMessage) async {
    final lowerMessage = userMessage.toLowerCase();
    
    // Acil durum tespiti
    if (_emergencyKeywords.any((keyword) => lowerMessage.contains(keyword))) {
      return '🚨 ACİL DURUM TESPİT EDİLDİ!\n\n'
             'Lütfen hemen aşağıdaki numaralardan birini arayın:\n'
             '📞 Acil Psikiyatri: 112\n'
             '📞 İntihar Önleme: 184\n'
             '📞 Psikolojik Destek: 0850 XXX XX XX\n\n'
             'Size yardımcı olmak için buradayım. Lütfen güvende olduğunuzdan emin olun.';
    }
    
    // İlaç bilgileri
    if (lowerMessage.contains('ilaç') || lowerMessage.contains('medikasyon')) {
      return '💊 İLAÇ BİLGİLERİ\n\n'
             'Hangi ilaç hakkında bilgi almak istiyorsunuz?\n\n'
             '• Yan etkiler\n'
             '• Dozaj bilgileri\n'
             '• Etkileşimler\n'
             '• Kullanım talimatları\n\n'
             'Lütfen ilaç adını yazın.';
    }
    
    // Randevu bilgileri
    if (lowerMessage.contains('randevu') || lowerMessage.contains('appointment')) {
      return '📅 RANDEVU BİLGİLERİ\n\n'
             'Size nasıl yardımcı olabilirim?\n\n'
             '• Yeni randevu alma\n'
             '• Mevcut randevu değiştirme\n'
             '• Randevu iptal etme\n'
             '• Randevu hatırlatıcıları\n\n'
             'Lütfen ne yapmak istediğinizi belirtin.';
    }
    
    // Genel yardım
    if (lowerMessage.contains('yardım') || lowerMessage.contains('help')) {
      return '✅ YARDIM MENÜSÜ\n\n'
             'Size nasıl yardımcı olabilirim?\n\n'
             '🚨 Acil durumlar\n'
             '💊 İlaç bilgileri\n'
             '📅 Randevu işlemleri\n'
             '🧠 Psikolojik destek\n'
             '📚 Eğitim materyalleri\n'
             '🔒 Gizlilik ve güvenlik\n\n'
             'Hangi konuda yardım istiyorsunuz?';
    }
    
    // AI destekli yanıt
    return _generateContextualResponse(userMessage);
  }

  String _generateContextualResponse(String userMessage) {
    // Basit AI yanıt sistemi
    if (userMessage.contains('merhaba') || userMessage.contains('selam')) {
      return 'Merhaba! Size nasıl yardımcı olabilirim? Bugün kendinizi nasıl hissediyorsunuz?';
    }
    
    if (userMessage.contains('kötü') || userMessage.contains('üzgün') || userMessage.contains('depresif')) {
      return 'Üzgün olduğunuzu duyuyorum. Bu duygular normal ve geçici olabilir. '
             'Size yardımcı olmak için buradayım. '
             'Eğer bu duygular yoğunsa, bir uzmanla görüşmenizi öneririm.';
    }
    
    if (userMessage.contains('anksiyete') || userMessage.contains('kaygı') || userMessage.contains('panik')) {
      return 'Anksiyete yaşadığınızı anlıyorum. Bu durumda nefes egzersizleri yardımcı olabilir: '
             '4 saniye nefes alın, 4 saniye tutun, 6 saniye verin. '
             'Eğer çok yoğunsa, acil durum numaralarını arayabilirsiniz.';
    }
    
    if (userMessage.contains('uyku') || userMessage.contains('uyuyamıyorum')) {
      return 'Uyku problemi yaşadığınızı duyuyorum. Bu yaygın bir sorundur. '
             'Uyku hijyeni için öneriler:\n'
             '• Düzenli uyku saatleri\n'
             '• Yatak odasını serin ve karanlık tutun\n'
             '• Yatmadan önce ekran kullanımını azaltın\n'
             '• Rahatlatıcı aktiviteler yapın';
    }
    
    // Varsayılan yanıt
    return 'Mesajınızı aldım. Size daha iyi yardımcı olabilmem için '
           'lütfen sorununuzu biraz daha detaylandırabilir misiniz? '
           'Ayrıca acil durumlar için "ACİL" yazabilirsiniz.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with animated icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.purple.shade600,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Asistan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Size nasıl yardımcı olabilirim?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: Colors.blue.shade400,
                          ),
                          onPressed: () {
                            // Voice input functionality
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade500,
                        Colors.purple.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade300.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser ? Colors.blue.shade500 : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: message.isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(5),
                      bottomRight: message.isUser
                          ? const Radius.circular(5)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: message.isUser ? Colors.white : Colors.black87,
                        ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person,
                color: Colors.blue.shade600,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue.shade400,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.normal,
  });
}

enum MessageType {
  normal,
  emergency,
  medication,
  appointment,
  help,
  welcome,
}
