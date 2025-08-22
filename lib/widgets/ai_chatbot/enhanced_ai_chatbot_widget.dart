import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../services/ai_orchestration_service.dart';
import '../../services/ai_prompt_service.dart';
import '../../utils/ai_logger.dart';
import '../../models/ai_performance_metrics.dart';

class EnhancedAIChatbotWidget extends StatefulWidget {
  final String? initialContext;
  final String? clientId;
  final String? therapistId;
  final Function(Map<String, dynamic>)? onAnalysisComplete;

  const EnhancedAIChatbotWidget({
    super.key,
    this.initialContext,
    this.clientId,
    this.therapistId,
    this.onAnalysisComplete,
  });

  @override
  State<EnhancedAIChatbotWidget> createState() => _EnhancedAIChatbotWidgetState();
}

class _EnhancedAIChatbotWidgetState extends State<EnhancedAIChatbotWidget>
    with TickerProviderStateMixin {
  final AIOrchestrationService _aiService = AIOrchestrationService();
  final AIPromptService _promptService = AIPromptService();
  final AILogger _logger = AILogger();
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  late AnimationController _typingController;
  late AnimationController _sendController;
  
  bool _isTyping = false;
  bool _isLoading = false;
  String _selectedPromptType = 'general';
  Map<String, dynamic> _contextData = {};
  
  // Prompt type options
  static const Map<String, String> _promptTypes = {
    'general': 'Genel Sohbet',
    'diagnosis': 'Tanı Yardımı',
    'session_summary': 'Seans Özeti',
    'medication_recommendation': 'İlaç Önerisi',
    'crisis_intervention': 'Kriz Müdahalesi',
    'treatment_planning': 'Tedavi Planlaması',
  };

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sendController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _initializeChat();
  }

  @override
  void dispose() {
    _typingController.dispose();
    _sendController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Merhaba! Ben PsyClinic AI asistanınız. Size nasıl yardımcı olabilirim?',
      isUser: false,
      timestamp: DateTime.now(),
      messageType: MessageType.system,
    ));

    // Add context if available
    if (widget.initialContext != null) {
      _messages.add(ChatMessage(
        text: 'Bağlam: ${widget.initialContext}',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.context,
      ));
    }

    // Initialize context data
    _contextData = {
      'clientId': widget.clientId,
      'therapistId': widget.therapistId,
      'sessionStart': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    _addMessage(message, true, MessageType.user);
    _messageController.clear();

    // Show typing indicator
    setState(() => _isTyping = true);
    _typingController.repeat();

    try {
      // Prepare parameters for AI
      final parameters = {
        ..._contextData,
        'userMessage': message,
        'chatHistory': _getChatHistory(),
        'selectedPromptType': _selectedPromptType,
      };

      // Generate task ID
      final taskId = 'chat_${DateTime.now().millisecondsSinceEpoch}';

      // Process with AI
      final aiResult = await _aiService.processRequest(
        promptType: _selectedPromptType,
        parameters: parameters,
        taskId: taskId,
        useCache: true,
      );

      // Convert AI result to expected format
      final response = aiResult.outputData ?? {};

      // Stop typing animation
      _typingController.stop();
      setState(() => _isTyping = false);

      // Process AI response
      await _processAIResponse(response, message);

    } catch (e) {
      _logger.error('Failed to process AI request', context: 'EnhancedAIChatbot', error: e);
      
      _typingController.stop();
      setState(() => _isTyping = false);
      
      _addMessage(
        'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.',
        false,
        MessageType.error,
      );
    }

    // Scroll to bottom
    _scrollToBottom();
  }

  Future<void> _processAIResponse(Map<String, dynamic> response, String userMessage) async {
    String aiResponse = '';
    MessageType messageType = MessageType.ai;

    // Extract response based on prompt type
    switch (_selectedPromptType) {
      case 'diagnosis':
        aiResponse = _formatDiagnosisResponse(response);
        messageType = MessageType.diagnosis;
        break;
      case 'session_summary':
        aiResponse = _formatSessionSummaryResponse(response);
        messageType = MessageType.sessionSummary;
        break;
      case 'medication_recommendation':
        aiResponse = _formatMedicationResponse(response);
        messageType = MessageType.medication;
        break;
      case 'crisis_intervention':
        aiResponse = _formatCrisisResponse(response);
        messageType = MessageType.crisis;
        break;
      case 'treatment_planning':
        aiResponse = _formatTreatmentResponse(response);
        messageType = MessageType.treatment;
        break;
      default:
        aiResponse = _formatGeneralResponse(response);
    }

    // Add AI response
    _addMessage(aiResponse, false, messageType);

    // Update context data
    _updateContextData(response);

    // Notify parent if analysis is complete
    if (widget.onAnalysisComplete != null) {
      widget.onAnalysisComplete!(response);
    }
  }

  String _formatDiagnosisResponse(Map<String, dynamic> response) {
    final buffer = StringBuffer();
    
    if (response.containsKey('primaryDiagnosis')) {
      final diagnosis = response['primaryDiagnosis'];
      buffer.writeln('🔍 **Ana Tanı:**');
      buffer.writeln('• ICD Kodu: ${diagnosis['icdCode'] ?? 'Belirsiz'}');
      buffer.writeln('• Güven: ${((diagnosis['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%');
      buffer.writeln('• Gerekçe: ${diagnosis['rationale'] ?? 'Belirtilmemiş'}');
      buffer.writeln();
    }

    if (response.containsKey('riskAssessment')) {
      final risk = response['riskAssessment'];
      buffer.writeln('⚠️ **Risk Değerlendirmesi:**');
      buffer.writeln('• Seviye: ${risk['level'] ?? 'Belirsiz'}');
      if (risk['factors'] != null) {
        buffer.writeln('• Faktörler: ${(risk['factors'] as List).join(', ')}');
      }
      buffer.writeln();
    }

    if (response.containsKey('treatmentPlan')) {
      final plan = response['treatmentPlan'];
      buffer.writeln('💡 **Tedavi Önerileri:**');
      buffer.writeln('• Yaklaşım: ${plan['approach'] ?? 'Belirtilmemiş'}');
      if (plan['interventions'] != null) {
        buffer.writeln('• Müdahaleler: ${(plan['interventions'] as List).join(', ')}');
      }
    }

    return buffer.toString();
  }

  String _formatSessionSummaryResponse(Map<String, dynamic> response) {
    final buffer = StringBuffer();
    
    if (response.containsKey('sessionInsights')) {
      final insights = response['sessionInsights'];
      buffer.writeln('📝 **Seans İçgörüleri:**');
      buffer.writeln('• Duygu Durumu: ${insights['emotionalState'] ?? 'Belirsiz'}');
      buffer.writeln('• Ana Temalar: ${(insights['mainThemes'] as List?)?.join(', ') ?? 'Belirtilmemiş'}');
      buffer.writeln('• İlerleme: ${insights['progress'] ?? 'Belirtilmemiş'}');
      buffer.writeln();
    }

    if (response.containsKey('nextSteps')) {
      final steps = response['nextSteps'];
      buffer.writeln('🎯 **Sonraki Adımlar:**');
      if (steps['recommendations'] != null) {
        buffer.writeln('• Öneriler: ${(steps['recommendations'] as List).join(', ')}');
      }
      if (steps['homework'] != null) {
        buffer.writeln('• Ev Ödevi: ${steps['homework']}');
      }
    }

    return buffer.toString();
  }

  String _formatMedicationResponse(Map<String, dynamic> response) {
    final buffer = StringBuffer();
    
    if (response.containsKey('medicationRecommendations')) {
      final meds = response['medicationRecommendations'] as List;
      buffer.writeln('💊 **İlaç Önerileri:**');
      
      for (int i = 0; i < meds.length; i++) {
        final med = meds[i];
        buffer.writeln('${i + 1}. **${med['medication']}**');
        buffer.writeln('   • Doz: ${med['dosage'] ?? 'Belirtilmemiş'}');
        buffer.writeln('   • Gerekçe: ${med['rationale'] ?? 'Belirtilmemiş'}');
        buffer.writeln();
      }
    }

    if (response.containsKey('contraindications')) {
      final contraindications = response['contraindications'] as List?;
      if (contraindications != null && contraindications.isNotEmpty) {
        buffer.writeln('🚫 **Kontrendikasyonlar:**');
        buffer.writeln('• ${contraindications.join(', ')}');
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  String _formatCrisisResponse(Map<String, dynamic> response) {
    final buffer = StringBuffer();
    
    if (response.containsKey('riskAssessment')) {
      final risk = response['riskAssessment'];
      buffer.writeln('🚨 **Acil Risk Değerlendirmesi:**');
      buffer.writeln('• Acil Risk: ${risk['immediateRisk'] ?? 'Belirsiz'}');
      buffer.writeln('• Risk Seviyesi: ${risk['riskLevel'] ?? 'Belirsiz'}');
      buffer.writeln();
    }

    if (response.containsKey('interventionPlan')) {
      final plan = response['interventionPlan'];
      buffer.writeln('⚡ **Acil Müdahale Planı:**');
      if (plan['immediateActions'] != null) {
        buffer.writeln('• Acil Eylemler: ${(plan['immediateActions'] as List).join(', ')}');
      }
      if (plan['safetyMeasures'] != null) {
        buffer.writeln('• Güvenlik Önlemleri: ${(plan['safetyMeasures'] as List).join(', ')}');
      }
    }

    return buffer.toString();
  }

  String _formatTreatmentResponse(Map<String, dynamic> response) {
    final buffer = StringBuffer();
    
    if (response.containsKey('treatmentGoals')) {
      final goals = response['treatmentGoals'] as List;
      buffer.writeln('🎯 **Tedavi Hedefleri:**');
      
      for (int i = 0; i < goals.length; i++) {
        final goal = goals[i];
        buffer.writeln('${i + 1}. **${goal['goal']}**');
        buffer.writeln('   • Öncelik: ${goal['priority'] ?? 'Belirsiz'}');
        buffer.writeln('   • Süre: ${goal['timeline'] ?? 'Belirtilmemiş'}');
        buffer.writeln();
      }
    }

    if (response.containsKey('therapeuticApproaches')) {
      final approaches = response['therapeuticApproaches'] as List;
      buffer.writeln('🧠 **Terapi Yaklaşımları:**');
      
      for (int i = 0; i < approaches.length; i++) {
        final approach = approaches[i];
        buffer.writeln('${i + 1}. **${approach['approach']}**');
        buffer.writeln('   • Gerekçe: ${approach['rationale'] ?? 'Belirtilmemiş'}');
        if (approach['techniques'] != null) {
          buffer.writeln('   • Teknikler: ${(approach['techniques'] as List).join(', ')}');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  String _formatGeneralResponse(Map<String, dynamic> response) {
    if (response.containsKey('content')) {
      return response['content'];
    }
    
    // Try to extract meaningful text from response
    final keys = response.keys.where((key) => 
        key != 'confidence' && key != 'modelId' && key != 'taskId').toList();
    
    if (keys.isNotEmpty) {
      final buffer = StringBuffer();
      for (final key in keys) {
        final value = response[key];
        if (value is String && value.isNotEmpty) {
          buffer.writeln('**${key.toUpperCase()}:** $value');
        } else if (value is List && value.isNotEmpty) {
          buffer.writeln('**${key.toUpperCase()}:** ${value.join(', ')}');
        }
      }
      return buffer.toString();
    }
    
    return 'Üzgünüm, yanıtı işleyemedim. Lütfen tekrar deneyin.';
  }

  void _addMessage(String text, bool isUser, MessageType messageType) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        messageType: messageType,
      ));
    });
  }

  List<String> _getChatHistory() {
    return _messages
        .where((msg) => msg.messageType != MessageType.system && 
                        msg.messageType != MessageType.context)
        .map((msg) => '${msg.isUser ? "Kullanıcı" : "AI"}: ${msg.text}')
        .toList();
  }

  void _updateContextData(Map<String, dynamic> response) {
    // Extract relevant information to update context
    if (response.containsKey('primaryDiagnosis')) {
      _contextData['currentDiagnosis'] = response['primaryDiagnosis'];
    }
    if (response.containsKey('riskLevel')) {
      _contextData['currentRiskLevel'] = response['riskLevel'];
    }
    if (response.containsKey('sessionInsights')) {
      _contextData['sessionInsights'] = response['sessionInsights'];
    }
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

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mesaj kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Asistan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedPromptType = value);
            },
            itemBuilder: (context) => _promptTypes.entries.map((entry) {
              return PopupMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_promptTypes[_selectedPromptType] ?? 'Genel'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = _getMessageColor(message.messageType);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isUser ? color : Colors.grey[100],
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isUser ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _copyMessage(message.text),
                      child: Icon(
                        Icons.copy,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI yazıyor...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
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
                  borderRadius: BorderRadius.circular(24.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _sendController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_sendController.value * 0.1),
                child: FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getMessageColor(MessageType messageType) {
    switch (messageType) {
      case MessageType.diagnosis:
        return Colors.blue;
      case MessageType.sessionSummary:
        return Colors.green;
      case MessageType.medication:
        return Colors.orange;
      case MessageType.crisis:
        return Colors.red;
      case MessageType.treatment:
        return Colors.purple;
      case MessageType.error:
        return Colors.red;
      case MessageType.system:
        return Colors.grey;
      case MessageType.context:
        return Colors.teal;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} sa önce';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
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
    required this.messageType,
  });
}

enum MessageType {
  user,
  ai,
  diagnosis,
  sessionSummary,
  medication,
  crisis,
  treatment,
  error,
  system,
  context,
}
