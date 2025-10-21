import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Welcome message
    _addMessage(
      'AI Asistan',
      'Merhaba! Ben PsyClinic AI asistanınızım. Size nasıl yardımcı olabilirim?',
      false,
      DateTime.now(),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _addMessage(String sender, String text, bool isUser, DateTime timestamp) {
    setState(() {
      _messages.add(ChatMessage(
        sender: sender,
        text: text,
        isUser: isUser,
        timestamp: timestamp,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage('Siz', text, true, DateTime.now());
    _messageController.clear();

    setState(() {
      _isTyping = true;
    });
    _typingAnimationController.repeat();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      _typingAnimationController.stop();
      setState(() {
        _isTyping = false;
      });
      _generateAIResponse(text);
    });
  }

  void _generateAIResponse(String userMessage) {
    String response = '';
    
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hasta') || lowerMessage.contains('patient')) {
      response = 'Hasta yönetimi konusunda size yardımcı olabilirim. Hangi hastayla ilgili bilgi istiyorsunuz?';
    } else if (lowerMessage.contains('randevu') || lowerMessage.contains('appointment')) {
      response = 'Randevu sistemi hakkında bilgi verebilirim. Yeni randevu oluşturmak mı istiyorsunuz?';
    } else if (lowerMessage.contains('reçete') || lowerMessage.contains('prescription')) {
      response = 'E-reçete sistemi ile ilgili sorularınızı yanıtlayabilirim. Hangi ilaç hakkında bilgi istiyorsunuz?';
    } else if (lowerMessage.contains('fatura') || lowerMessage.contains('billing')) {
      response = 'Faturalandırma sistemi hakkında yardımcı olabilirim. Hangi fatura ile ilgili sorunuz var?';
    } else if (lowerMessage.contains('sigorta') || lowerMessage.contains('insurance')) {
      response = 'Sigorta entegrasyonu konusunda bilgi verebilirim. Hangi sigorta şirketi ile ilgili sorunuz var?';
    } else if (lowerMessage.contains('mood') || lowerMessage.contains('ruh hali')) {
      response = 'Mood tracking sistemi hakkında bilgi verebilirim. Hangi hastanın mood verilerini incelemek istiyorsunuz?';
    } else if (lowerMessage.contains('sesli not') || lowerMessage.contains('voice note')) {
      response = 'Sesli notlar sistemi ile ilgili yardımcı olabilirim. Yeni sesli not kaydetmek mi istiyorsunuz?';
    } else if (lowerMessage.contains('telemedicine') || lowerMessage.contains('video call')) {
      response = 'Telemedicine sistemi hakkında bilgi verebilirim. Video görüşme başlatmak mı istiyorsunuz?';
    } else if (lowerMessage.contains('güvenlik') || lowerMessage.contains('security')) {
      response = 'Güvenlik ayarları hakkında yardımcı olabilirim. Hangi güvenlik özelliği ile ilgili sorunuz var?';
    } else if (lowerMessage.contains('analitik') || lowerMessage.contains('analytics')) {
      response = 'Analitik ve raporlama sistemi hakkında bilgi verebilirim. Hangi raporu oluşturmak istiyorsunuz?';
    } else if (lowerMessage.contains('merhaba') || lowerMessage.contains('hello')) {
      response = 'Merhaba! Size nasıl yardımcı olabilirim? Hasta yönetimi, randevular, reçeteler veya diğer konularda sorularınızı yanıtlayabilirim.';
    } else if (lowerMessage.contains('yardım') || lowerMessage.contains('help')) {
      response = 'PsyClinic AI sisteminde size yardımcı olabileceğim konular:\n\n'
          '• Hasta yönetimi ve takibi\n'
          '• Randevu planlama ve yönetimi\n'
          '• E-reçete sistemi\n'
          '• Faturalandırma\n'
          '• Sigorta entegrasyonu\n'
          '• Mood tracking\n'
          '• Sesli notlar\n'
          '• Telemedicine\n'
          '• Güvenlik ayarları\n'
          '• Analitik ve raporlama\n\n'
          'Hangi konuda daha detaylı bilgi istiyorsunuz?';
    } else {
      response = 'Anladım. Bu konuda size daha iyi yardımcı olabilmem için daha spesifik bir soru sorabilir misiniz? '
          'Hasta yönetimi, randevular, reçeteler, faturalar veya diğer sistem özellikleri hakkında sorularınızı yanıtlayabilirim.';
    }

    _addMessage('AI Asistan', response, false, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Asistan'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearChat,
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? colorScheme.primary 
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser 
                          ? colorScheme.onPrimary 
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? colorScheme.onPrimary.withOpacity(0.7)
                          : colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.secondary,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    final delay = index * 0.2;
    final animationValue = (_typingAnimation.value - delay).clamp(0.0, 1.0);
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(animationValue),
        shape: BoxShape.circle,
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbeti Temizle'),
        content: const Text('Tüm mesajları silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _addMessage(
                'AI Asistan',
                'Merhaba! Ben PsyClinic AI asistanınızım. Size nasıl yardımcı olabilirim?',
                false,
                DateTime.now(),
              );
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Asistan Yardım'),
        content: const Text(
          'AI Asistan size şu konularda yardımcı olabilir:\n\n'
          '• Hasta yönetimi ve takibi\n'
          '• Randevu planlama ve yönetimi\n'
          '• E-reçete sistemi\n'
          '• Faturalandırma\n'
          '• Sigorta entegrasyonu\n'
          '• Mood tracking\n'
          '• Sesli notlar\n'
          '• Telemedicine\n'
          '• Güvenlik ayarları\n'
          '• Analitik ve raporlama\n\n'
          'Sorularınızı doğal dilde sorabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
