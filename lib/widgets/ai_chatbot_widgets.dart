import 'package:flutter/material.dart';
import '../services/ai_chatbot_service.dart';
import '../utils/theme.dart';

// AI Chatbot Widget
class AIChatbotWidget extends StatefulWidget {
  const AIChatbotWidget({super.key});

  @override
  State<AIChatbotWidget> createState() => _AIChatbotWidgetState();
}

class _AIChatbotWidgetState extends State<AIChatbotWidget> {
  final AIChatbotService _chatbotService = AIChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _chatbotService.initialize();
    
    // Listen to messages
    _chatbotService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    });
    
    // Listen to typing indicator
    _chatbotService.typingStream.listen((typing) {
      setState(() {
        _isTyping = typing;
      });
      if (typing) {
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.psychology, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatbotService.botPersonality['name'],
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _chatbotService.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                  style: TextStyle(
                    fontSize: 12,
                    color: _chatbotService.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showChatbotSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : _buildMessagesList(),
          ),
          
          // Typing indicator
          if (_isTyping) _buildTypingIndicator(),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Merhaba! Ben ${_chatbotService.botPersonality['name']}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Size nasıl yardımcı olabilirim?',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {'icon': Icons.calendar_today, 'text': 'Randevu Al', 'action': 'Randevu almak istiyorum'},
      {'icon': Icons.psychology, 'text': 'Terapi Bilgisi', 'action': 'Terapi hakkında bilgi almak istiyorum'},
      {'icon': Icons.emergency, 'text': 'Acil Durum', 'action': 'Acil durum desteği arıyorum'},
      {'icon': Icons.question_answer, 'text': 'SSS', 'action': 'Sık sorulan sorular'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickActions.map((action) => 
        ActionChip(
          avatar: Icon(action['icon'], size: 16),
          label: Text(action['text']),
          onPressed: () => _sendMessage(action['action']),
        ),
      ).toList(),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    final content = message['content'] as String? ?? '';
    final timestamp = message['timestamp'] as String? ?? '';
    final suggestions = message['suggestions'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 16,
                child: const Icon(Icons.psychology, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser 
                      ? AppTheme.primaryColor 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  content,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 16,
                child: const Icon(Icons.person, color: Colors.grey, size: 16),
              ),
            ],
          ],
        ),
        
        // Suggestions for bot messages
        if (!isUser && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: suggestions.map((suggestion) => 
              ActionChip(
                label: Text(suggestion),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: AppTheme.primaryColor),
              ),
            ).toList(),
          ),
        ],
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            radius: 16,
            child: const Icon(Icons.psychology, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Yazıyor...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () => _sendMessage(_messageController.text),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.send, color: Colors.white),
            mini: true,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    _chatbotService.sendUserMessage(message);
    _messageController.clear();
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

  void _showChatbotSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chatbot Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Bot Kişiliği'),
              subtitle: Text(_chatbotService.botPersonality['name']),
              onTap: _editBotPersonality,
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Sohbet Geçmişi'),
              subtitle: Text('${_messages.length} mesaj'),
              onTap: _showChatHistory,
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Geçmişi Temizle'),
              onTap: _clearHistory,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _editBotPersonality() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bot Kişiliği Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bot Adı',
                hintText: 'PsyClinic AI',
              ),
              controller: TextEditingController(
                text: _chatbotService.botPersonality['name'],
              ),
              onChanged: (value) {
                _chatbotService.updateBotPersonality({'name': value});
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Bot Rolü',
                hintText: 'Mental Health Assistant',
              ),
              controller: TextEditingController(
                text: _chatbotService.botPersonality['role'],
              ),
              onChanged: (value) {
                _chatbotService.updateBotPersonality({'role': value});
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showChatHistory() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbet Geçmişi'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ListTile(
                leading: Icon(
                  message['type'] == 'user' ? Icons.person : Icons.psychology,
                  color: message['type'] == 'user' ? Colors.grey : AppTheme.primaryColor,
                ),
                title: Text(
                  message['content'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _formatTimestamp(message['timestamp'] ?? ''),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geçmişi Temizle'),
        content: const Text('Tüm sohbet geçmişini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _chatbotService.clearChatHistory();
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

// Chatbot Stats Widget
class ChatbotStatsWidget extends StatefulWidget {
  const ChatbotStatsWidget({super.key});

  @override
  State<ChatbotStatsWidget> createState() => _ChatbotStatsWidgetState();
}

class _ChatbotStatsWidgetState extends State<ChatbotStatsWidget> {
  final AIChatbotService _chatbotService = AIChatbotService();
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _stats = _chatbotService.getChatbotStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Chatbot İstatistikleri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(
              'Toplam Mesaj',
              '${_stats['totalMessages'] ?? 0}',
              Icons.message,
              Colors.blue,
            ),
            
            _buildStatItem(
              'Toplam Konuşma',
              '${_stats['totalConversations'] ?? 0}',
              Icons.chat,
              Colors.green,
            ),
            
            _buildStatItem(
              'Aktif Konuşma',
              '${_stats['activeConversations'] ?? 0}',
              Icons.chat_bubble,
              Colors.orange,
            ),
            
            _buildStatItem(
              'Durum',
              _stats['isOnline'] == true ? 'Çevrimiçi' : 'Çevrimdışı',
              Icons.circle,
              _stats['isOnline'] == true ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
