import 'package:flutter/material.dart';
import '../../models/ai_appointment_models.dart';
import '../../services/ai_appointment_service.dart';
import '../../utils/theme.dart';

class AIAppointmentDashboardWidget extends StatefulWidget {
  final String therapistId;

  const AIAppointmentDashboardWidget({
    super.key,
    required this.therapistId,
  });

  @override
  State<AIAppointmentDashboardWidget> createState() => _AIAppointmentDashboardWidgetState();
}

class _AIAppointmentDashboardWidgetState extends State<AIAppointmentDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final AIAppointmentService _aiService = AIAppointmentService();

  List<AIAppointmentPrediction> _predictions = [];
  List<AIAppointmentReminder> _reminders = [];
  List<SmartAppointmentSuggestion> _suggestions = [];
  AppointmentAnalytics? _analytics;
  List<InstitutionalMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      await _aiService.initialize();

      // Tüm verileri paralel olarak yükle
      await Future.wait([
        _loadPredictions(),
        _loadReminders(),
        _loadSuggestions(),
        _loadAnalytics(),
        _loadMessages(),
      ]);

      _animationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPredictions() async {
    _predictions = await _aiService.getPredictions(therapistId: widget.therapistId);
  }

  Future<void> _loadReminders() async {
    _reminders = await _aiService.getReminders(therapistId: widget.therapistId);
  }

  Future<void> _loadSuggestions() async {
    _suggestions = await _aiService.getSuggestions(therapistId: widget.therapistId);
  }

  Future<void> _loadAnalytics() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    
    _analytics = await _aiService.generateAnalytics(
      therapistId: widget.therapistId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _loadMessages() async {
    _messages = await _aiService.getMessages(userId: widget.therapistId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Destekli Randevu Sistemi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Yapay zeka ile optimize edilmiş randevu yönetimi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricCard(
                'Tahminler',
                _predictions.length.toString(),
                Icons.analytics,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Hatırlatıcılar',
                _reminders.length.toString(),
                Icons.notifications,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Öneriler',
                _suggestions.length.toString(),
                Icons.lightbulb,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Mesajlar',
                _messages.length.toString(),
                Icons.message,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Tahminler'),
          Tab(text: 'Hatırlatıcılar'),
          Tab(text: 'Öneriler'),
          Tab(text: 'Analitik'),
          Tab(text: 'Mesajlaşma'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPredictionsTab(),
        _buildRemindersTab(),
        _buildSuggestionsTab(),
        _buildAnalyticsTab(),
        _buildMessagingTab(),
      ],
    );
  }

  Widget _buildPredictionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        return _buildPredictionCard(prediction);
      },
    );
  }

  Widget _buildPredictionCard(AIAppointmentPrediction prediction) {
    final color = _getPredictionColor(prediction.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            _getPredictionIcon(prediction.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          prediction.prediction,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Güven: ${(prediction.confidence * 100).toStringAsFixed(1)}%'),
            Text('Faktörler: ${prediction.factors.length}'),
            if (prediction.notes != null) Text(prediction.notes!),
          ],
        ),
        trailing: Chip(
          label: Text(
            _getPredictionTypeText(prediction.type),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: color,
        ),
      ),
    );
  }

  Color _getPredictionColor(AppointmentPredictionType type) {
    switch (type) {
      case AppointmentPredictionType.noShow:
        return Colors.red;
      case AppointmentPredictionType.cancellation:
        return Colors.orange;
      case AppointmentPredictionType.lateArrival:
        return Colors.yellow[700]!;
      case AppointmentPredictionType.emergency:
        return Colors.red[800]!;
      default:
        return Colors.green;
    }
  }

  IconData _getPredictionIcon(AppointmentPredictionType type) {
    switch (type) {
      case AppointmentPredictionType.noShow:
        return Icons.cancel;
      case AppointmentPredictionType.cancellation:
        return Icons.schedule;
      case AppointmentPredictionType.lateArrival:
        return Icons.access_time;
      case AppointmentPredictionType.emergency:
        return Icons.emergency;
      default:
        return Icons.check_circle;
    }
  }

  String _getPredictionTypeText(AppointmentPredictionType type) {
    switch (type) {
      case AppointmentPredictionType.noShow:
        return 'No-Show';
      case AppointmentPredictionType.cancellation:
        return 'İptal';
      case AppointmentPredictionType.lateArrival:
        return 'Geç Gelme';
      case AppointmentPredictionType.emergency:
        return 'Acil';
      default:
        return 'Normal';
    }
  }

  Widget _buildRemindersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(AIAppointmentReminder reminder) {
    final color = _getReminderColor(reminder.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            _getReminderIcon(reminder.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          reminder.message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kanal: ${_getChannelText(reminder.channel)}'),
            Text('Zaman: ${_formatDateTime(reminder.scheduledTime)}'),
            Text('Durum: ${_getStatusText(reminder.status)}'),
          ],
        ),
        trailing: reminder.isAIOptimized
            ? Icon(Icons.psychology, color: AppColors.primaryColor)
            : null,
      ),
    );
  }

  Color _getReminderColor(ReminderType type) {
    switch (type) {
      case ReminderType.emergencyAlert:
        return Colors.red;
      case ReminderType.appointmentReminder:
        return Colors.blue;
      case ReminderType.preparationInstructions:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.emergencyAlert:
        return Icons.emergency;
      case ReminderType.appointmentReminder:
        return Icons.notifications;
      case ReminderType.preparationInstructions:
        return Icons.info;
      default:
        return Icons.message;
    }
  }

  String _getChannelText(ReminderChannel channel) {
    switch (channel) {
      case ReminderChannel.sms:
        return 'SMS';
      case ReminderChannel.email:
        return 'E-posta';
      case ReminderChannel.pushNotification:
        return 'Push Bildirim';
      case ReminderChannel.whatsapp:
        return 'WhatsApp';
      case ReminderChannel.phoneCall:
        return 'Telefon';
      default:
        return 'Uygulama';
    }
  }

  String _getStatusText(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.scheduled:
        return 'Planlandı';
      case ReminderStatus.sent:
        return 'Gönderildi';
      case ReminderStatus.delivered:
        return 'Teslim Edildi';
      case ReminderStatus.read:
        return 'Okundu';
      case ReminderStatus.failed:
        return 'Başarısız';
      default:
        return 'İptal Edildi';
    }
  }

  Widget _buildSuggestionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return _buildSuggestionCard(suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(SmartAppointmentSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Icon(
            Icons.lightbulb,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Önerilen Zaman: ${_formatDateTime(suggestion.suggestedTime)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Öncelik: ${(suggestion.priority * 100).toStringAsFixed(0)}%'),
            Text('Sebep: ${_getSuggestionReasonText(suggestion.reason)}'),
            Text('Alternatif: ${suggestion.alternativeTimes.length} zaman'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!suggestion.isAccepted)
              ElevatedButton(
                onPressed: () => _acceptSuggestion(suggestion),
                child: const Text('Kabul Et'),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showSuggestionDetails(suggestion),
              icon: const Icon(Icons.info),
            ),
          ],
        ),
      ),
    );
  }

  String _getSuggestionReasonText(SuggestionReason reason) {
    switch (reason) {
      case SuggestionReason.clientPreference:
        return 'Danışan Tercihi';
      case SuggestionReason.therapistAvailability:
        return 'Terapist Müsaitliği';
      case SuggestionReason.optimalTiming:
        return 'Optimal Zaman';
      case SuggestionReason.followUpSchedule:
        return 'Takip Randevusu';
      case SuggestionReason.emergencySlot:
        return 'Acil Durum';
      default:
        return 'Diğer';
    }
  }

  void _acceptSuggestion(SmartAppointmentSuggestion suggestion) {
    // TODO: Implement suggestion acceptance
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Öneri kabul edildi: ${suggestion.suggestedTime}')),
    );
  }

  void _showSuggestionDetails(SmartAppointmentSuggestion suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öneri Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Önerilen Zaman: ${_formatDateTime(suggestion.suggestedTime)}'),
            Text('Öncelik: ${(suggestion.priority * 100).toStringAsFixed(0)}%'),
            Text('Sebep: ${_getSuggestionReasonText(suggestion.reason)}'),
            const SizedBox(height: 16),
            const Text('Alternatif Zamanlar:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...suggestion.alternativeTimes.map((time) => Text('• ${_formatDateTime(time)}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) {
      return const Center(child: Text('Analitik verisi bulunamadı'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildAnalyticsOverview(),
        const SizedBox(height: 20),
        _buildAnalyticsCharts(),
        const SizedBox(height: 20),
        _buildInsightsList(),
      ],
    );
  }

  Widget _buildAnalyticsOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Genel Performans',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsMetric(
                    'Toplam Randevu',
                    _analytics!.totalAppointments.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsMetric(
                    'Tamamlanan',
                    _analytics!.completedAppointments.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsMetric(
                    'İptal Edilen',
                    _analytics!.cancelledAppointments.toString(),
                    Icons.cancel,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticsMetric(
                    'No-Show',
                    _analytics!.noShowAppointments.toString(),
                    Icons.person_off,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCharts() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saatlik Dağılım',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildHourlyChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart() {
    // Mock chart - gerçek uygulamada fl_chart gibi bir kütüphane kullanılır
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          '📊 Saatlik Dağılım Grafiği\n\nBu alanda gerçek grafik gösterilecek',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInsightsList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Öngörüleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ..._analytics!.insights.map((insight) => _buildInsightCard(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(AppointmentInsight insight) {
    final color = _getInsightColor(insight.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.left(color: color, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInsightIcon(insight.type),
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  _getInsightSeverityText(insight.severity),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.description),
          if (insight.recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Öneriler:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...insight.recommendations.map((rec) => Text('• $rec')),
          ],
        ],
      ),
    );
  }

  Color _getInsightColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.low:
        return Colors.green;
      case InsightSeverity.medium:
        return Colors.orange;
      case InsightSeverity.high:
        return Colors.red;
      case InsightSeverity.critical:
        return Colors.red[800]!;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.performance:
        return Icons.speed;
      case InsightType.efficiency:
        return Icons.trending_up;
      case InsightType.clientSatisfaction:
        return Icons.sentiment_satisfied;
      case InsightType.revenue:
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }

  String _getInsightSeverityText(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.low:
        return 'Düşük';
      case InsightSeverity.medium:
        return 'Orta';
      case InsightSeverity.high:
        return 'Yüksek';
      case InsightSeverity.critical:
        return 'Kritik';
    }
  }

  Widget _buildMessagingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(InstitutionalMessage message) {
    final color = _getMessageColor(message.priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            _getMessageIcon(message.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          message.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gönderen: ${message.senderName}'),
            Text('Alıcılar: ${message.recipientNames.join(', ')}'),
            Text('Zaman: ${_formatDateTime(message.createdAt)}'),
            Text('Öncelik: ${_getPriorityText(message.priority)}'),
          ],
        ),
        trailing: message.isAIProcessed
            ? Icon(Icons.psychology, color: AppColors.primaryColor)
            : null,
        onTap: () => _showMessageDetails(message),
      ),
    );
  }

  Color _getMessageColor(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.urgent:
        return Colors.red;
      case MessagePriority.high:
        return Colors.orange;
      case MessagePriority.normal:
        return Colors.blue;
      case MessagePriority.low:
        return Colors.grey;
    }
  }

  IconData _getMessageIcon(MessageType type) {
    switch (type) {
      case MessageType.announcement:
        return Icons.announcement;
      case MessageType.meeting:
        return Icons.meeting_room;
      case MessageType.task:
        return Icons.task;
      case MessageType.question:
        return Icons.question_answer;
      case MessageType.emergency:
        return Icons.emergency;
      default:
        return Icons.message;
    }
  }

  String _getPriorityText(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.urgent:
        return 'Acil';
      case MessagePriority.high:
        return 'Yüksek';
      case MessagePriority.normal:
        return 'Normal';
      case MessagePriority.low:
        return 'Düşük';
    }
  }

  void _showMessageDetails(InstitutionalMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.subject),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gönderen: ${message.senderName}'),
              Text('Rol: ${message.senderRole}'),
              Text('Alıcılar: ${message.recipientNames.join(', ')}'),
              Text('Zaman: ${_formatDateTime(message.createdAt)}'),
              Text('Öncelik: ${_getPriorityText(message.priority)}'),
              const SizedBox(height: 16),
              const Text('İçerik:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(message.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
