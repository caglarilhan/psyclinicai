import 'package:flutter/material.dart';
import '../../models/consultation_models.dart';
import '../../services/consultation_service.dart';
import '../../services/patient_service.dart';
import '../../services/role_service.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> with TickerProviderStateMixin {
  final ConsultationService _consultationService = ConsultationService();
  final PatientService _patientService = PatientService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<ConsultationRequest> _requests = [];
  List<ConsultationResponse> _responses = [];
  List<ConsultationTemplate> _templates = [];
  List<ConsultationSchedule> _schedules = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedUrgency = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await _consultationService.initialize();
      await _consultationService.generateDemoData();
      
      final currentUser = _roleService.getCurrentUser();
      final userId = currentUser['id'] as String;
      final userRole = currentUser['role'] as String;
      
      if (userRole == 'Psikiyatrist') {
        _requests = _consultationService.getRequestsForPsychiatrist(userId);
        _responses = _consultationService.getResponsesForPsychiatrist(userId);
        _schedules = _consultationService.getSchedulesForPsychiatrist(userId);
      } else if (userRole == 'Doktor') {
        _requests = _consultationService.getRequestsForPhysician(userId);
      }
      
      _templates = _consultationService.getTemplatesForUser(userId);
    } catch (e) {
      print('Error loading consultation data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        title: const Text(
          'Konsültasyon Yönetimi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'İstekler'),
            Tab(text: 'Yanıtlar'),
            Tab(text: 'Şablonlar'),
            Tab(text: 'Takvim'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsTab(),
                _buildResponsesTab(),
                _buildTemplatesTab(),
                _buildScheduleTab(),
              ],
            ),
    );
  }

  Widget _buildRequestsTab() {
    final filteredRequests = _getFilteredRequests();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredRequests.isEmpty
              ? const Center(
                  child: Text(
                    'Konsültasyon isteği bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return _buildRequestCard(request);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filtre',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Colors.purple[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tümü')),
                    DropdownMenuItem(value: 'urgent', child: Text('Acil')),
                    DropdownMenuItem(value: 'overdue', child: Text('Geciken')),
                    DropdownMenuItem(value: 'pending', child: Text('Bekleyen')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUrgency,
                  decoration: const InputDecoration(
                    labelText: 'Öncelik',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Colors.purple[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tümü')),
                    DropdownMenuItem(value: 'routine', child: Text('Rutin')),
                    DropdownMenuItem(value: 'urgent', child: Text('Acil')),
                    DropdownMenuItem(value: 'emergency', child: Text('Acil Durum')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedUrgency = value!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<ConsultationRequest> _getFilteredRequests() {
    var filtered = _requests;
    
    if (_selectedFilter == 'urgent') {
      filtered = filtered.where((r) => r.isUrgent).toList();
    } else if (_selectedFilter == 'overdue') {
      filtered = filtered.where((r) => r.isOverdue).toList();
    } else if (_selectedFilter == 'pending') {
      filtered = filtered.where((r) => r.status == ConsultationStatus.pending).toList();
    }
    
    if (_selectedUrgency != 'all') {
      filtered = filtered.where((r) => r.urgency.toString().split('.').last == _selectedUrgency).toList();
    }
    
    return filtered;
  }

  Widget _buildRequestCard(ConsultationRequest request) {
    final patient = _patientService.getPatientById(request.patientId);
    final urgencyColor = _getUrgencyColor(request.urgency);
    final statusColor = _getStatusColor(request.status);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    patient?.name ?? 'Bilinmeyen Hasta',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.urgency.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tür: ${request.type.toString().split('.').last}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Sebep: ${request.reason}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Soru: ${request.question}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(request.requestedAt),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (request.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${request.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRequestDetails(request),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (request.status == ConsultationStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respondToRequest(request),
                      icon: const Icon(Icons.reply),
                      label: const Text('Yanıtla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesTab() {
    return _responses.isEmpty
        ? const Center(
            child: Text(
              'Henüz yanıt bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _responses.length,
            itemBuilder: (context, index) {
              final response = _responses[index];
              return _buildResponseCard(response);
            },
          );
  }

  Widget _buildResponseCard(ConsultationResponse response) {
    final request = _requests.firstWhere(
      (r) => r.id == response.consultationRequestId,
      orElse: () => ConsultationRequest(
        id: '',
        patientId: '',
        requestingPhysicianId: '',
        consultingPsychiatristId: '',
        type: ConsultationType.assessment,
        reason: '',
        question: '',
        urgency: ConsultationUrgency.routine,
        requestedAt: DateTime.now(),
      ),
    );
    final patient = _patientService.getPatientById(request.patientId);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient?.name ?? 'Bilinmeyen Hasta',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Değerlendirme: ${response.assessment}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Öneriler: ${response.recommendations}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (response.followUp != null) ...[
              const SizedBox(height: 4),
              Text(
                'Takip: ${response.followUp}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Yanıtlanma Tarihi: ${_formatDateTime(response.respondedAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showResponseDetails(response),
              icon: const Icon(Icons.visibility),
              label: const Text('Detayları Görüntüle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return _templates.isEmpty
        ? const Center(
            child: Text(
              'Henüz şablon bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              return _buildTemplateCard(template);
            },
          );
  }

  Widget _buildTemplateCard(ConsultationTemplate template) {
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (template.isPublic)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PUBLIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Tür: ${template.type.toString().split('.').last}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Oluşturulma: ${_formatDateTime(template.createdAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTemplateDetails(template),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _useTemplate(template),
                    icon: const Icon(Icons.edit),
                    label: const Text('Kullan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return _schedules.isEmpty
        ? const Center(
            child: Text(
              'Henüz takvim bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              final schedule = _schedules[index];
              return _buildScheduleCard(schedule);
            },
          );
  }

  Widget _buildScheduleCard(ConsultationSchedule schedule) {
    final patient = schedule.patientId != null 
        ? _patientService.getPatientById(schedule.patientId!)
        : null;
    final statusColor = _getScheduleStatusColor(schedule.status);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    patient?.name ?? 'Boş Slot',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Başlangıç: ${_formatDateTime(schedule.startTime)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Bitiş: ${_formatDateTime(schedule.endTime)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (schedule.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${schedule.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showScheduleDetails(schedule),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                if (schedule.isAvailable)
                  const SizedBox(width: 8),
                if (schedule.isAvailable)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _bookSchedule(schedule),
                      icon: const Icon(Icons.book),
                      label: const Text('Rezerve Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(ConsultationUrgency urgency) {
    switch (urgency) {
      case ConsultationUrgency.routine:
        return Colors.blue;
      case ConsultationUrgency.urgent:
        return Colors.orange;
      case ConsultationUrgency.emergency:
        return Colors.red;
      case ConsultationUrgency.emergent: // Eksik case eklendi
        return Colors.deepPurple;
    }
  }

  Color _getStatusColor(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.pending:
        return Colors.orange;
      case ConsultationStatus.scheduled:
        return Colors.blue;
      case ConsultationStatus.completed:
        return Colors.green;
      case ConsultationStatus.cancelled:
        return Colors.red;
      case ConsultationStatus.inProgress: // Eksik case eklendi
        return Colors.purple;
    }
  }

  Color _getScheduleStatusColor(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.available:
        return Colors.green;
      case ScheduleStatus.booked:
        return Colors.blue;
      case ScheduleStatus.cancelled:
        return Colors.red;
      case ScheduleStatus.blocked: // Eksik case eklendi
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showRequestDetails(ConsultationRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Konsültasyon Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(request.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${request.type.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Sebep: ${request.reason}', style: const TextStyle(color: Colors.white70)),
              Text('Soru: ${request.question}', style: const TextStyle(color: Colors.white70)),
              Text('Öncelik: ${request.urgency.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${request.status.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('İstek Tarihi: ${_formatDateTime(request.requestedAt)}', style: const TextStyle(color: Colors.white70)),
              if (request.scheduledAt != null)
                Text('Planlanan Tarih: ${_formatDateTime(request.scheduledAt!)}', style: const TextStyle(color: Colors.white70)),
              if (request.notes != null)
                Text('Notlar: ${request.notes}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _respondToRequest(ConsultationRequest request) {
    // TODO: Implement response form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yanıt formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showResponseDetails(ConsultationResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Yanıt Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Değerlendirme: ${response.assessment}', style: const TextStyle(color: Colors.white70)),
              Text('Öneriler: ${response.recommendations}', style: const TextStyle(color: Colors.white70)),
              if (response.followUp != null)
                Text('Takip: ${response.followUp}', style: const TextStyle(color: Colors.white70)),
              if (response.notes != null)
                Text('Notlar: ${response.notes}', style: const TextStyle(color: Colors.white70)),
              Text('Yanıtlanma Tarihi: ${_formatDateTime(response.respondedAt)}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetails(ConsultationTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          template.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklama: ${template.description}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${template.type.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(template.createdAt)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              const Text('Şablon:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  template.template,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _useTemplate(ConsultationTemplate template) {
    // TODO: Implement template usage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şablon kullanımı yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showScheduleDetails(ConsultationSchedule schedule) {
    final patient = schedule.patientId != null 
        ? _patientService.getPatientById(schedule.patientId!)
        : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Takvim Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${patient?.name ?? 'Boş Slot'}', style: const TextStyle(color: Colors.white70)),
              Text('Başlangıç: ${_formatDateTime(schedule.startTime)}', style: const TextStyle(color: Colors.white70)),
              Text('Bitiş: ${_formatDateTime(schedule.endTime)}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${schedule.status.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              if (schedule.notes != null)
                Text('Notlar: ${schedule.notes}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _bookSchedule(ConsultationSchedule schedule) {
    // TODO: Implement schedule booking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Takvim rezervasyonu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
