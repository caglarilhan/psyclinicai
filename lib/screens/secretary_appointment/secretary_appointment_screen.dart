import 'package:flutter/material.dart';
import '../../models/secretary_appointment_models.dart';
import '../../services/secretary_appointment_service.dart';
import '../../services/patient_service.dart';
import '../../services/role_service.dart';

class SecretaryAppointmentScreen extends StatefulWidget {
  const SecretaryAppointmentScreen({super.key});

  @override
  State<SecretaryAppointmentScreen> createState() => _SecretaryAppointmentScreenState();
}

class _SecretaryAppointmentScreenState extends State<SecretaryAppointmentScreen> with TickerProviderStateMixin {
  final SecretaryAppointmentService _appointmentService = SecretaryAppointmentService();
  final PatientService _patientService = PatientService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<Appointment> _appointments = [];
  List<WaitingList> _waitingList = [];
  List<DoctorSchedule> _doctorSchedules = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';
  String _selectedDoctor = 'all';

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
      await _appointmentService.initialize();
      await _appointmentService.generateDemoData();
      
      final currentUser = _roleService.getCurrentUser();
      _appointments = _appointmentService.getAppointmentsForSecretary(currentUser['id'] as String);
      _waitingList = _appointmentService.getActiveWaitingList();
      _doctorSchedules = _appointmentService.getDoctorSchedules('doctor_001');
    } catch (e) {
      print('Error loading secretary appointment data: $e');
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
          'Randevu Yönetimi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Randevular'),
            Tab(text: 'Bekleme Listesi'),
            Tab(text: 'Doktor Takvimleri'),
            Tab(text: 'İstatistikler'),
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
                _buildAppointmentsTab(),
                _buildWaitingListTab(),
                _buildDoctorSchedulesTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildAppointmentsTab() {
    final filteredAppointments = _getFilteredAppointments();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredAppointments.isEmpty
              ? const Center(
                  child: Text(
                    'Randevu bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return _buildAppointmentCard(appointment);
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
                    DropdownMenuItem(value: 'today', child: Text('Bugün')),
                    DropdownMenuItem(value: 'tomorrow', child: Text('Yarın')),
                    DropdownMenuItem(value: 'this_week', child: Text('Bu Hafta')),
                    DropdownMenuItem(value: 'urgent', child: Text('Acil')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Durum',
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
                    DropdownMenuItem(value: 'scheduled', child: Text('Planlandı')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Onaylandı')),
                    DropdownMenuItem(value: 'completed', child: Text('Tamamlandı')),
                    DropdownMenuItem(value: 'cancelled', child: Text('İptal')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Appointment> _getFilteredAppointments() {
    var filtered = _appointments;
    
    if (_selectedFilter == 'today') {
      final today = DateTime.now();
      filtered = filtered.where((apt) => 
          apt.scheduledTime.day == today.day &&
          apt.scheduledTime.month == today.month &&
          apt.scheduledTime.year == today.year).toList();
    } else if (_selectedFilter == 'tomorrow') {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      filtered = filtered.where((apt) => 
          apt.scheduledTime.day == tomorrow.day &&
          apt.scheduledTime.month == tomorrow.month &&
          apt.scheduledTime.year == tomorrow.year).toList();
    } else if (_selectedFilter == 'this_week') {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      filtered = filtered.where((apt) => 
          apt.scheduledTime.isAfter(weekStart) &&
          apt.scheduledTime.isBefore(weekEnd)).toList();
    } else if (_selectedFilter == 'urgent') {
      filtered = filtered.where((apt) => apt.priority == PriorityLevel.urgent).toList();
    }
    
    if (_selectedStatus != 'all') {
      filtered = filtered.where((apt) => apt.status.toString().split('.').last == _selectedStatus).toList();
    }
    
    return filtered;
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final patient = _patientService.getPatientById(appointment.patientId);
    final statusColor = _getStatusColor(appointment.status);
    final priorityColor = _getPriorityColor(appointment.priority);
    
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
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toString().split('.').last.toUpperCase(),
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
              'Tarih: ${_formatDateTime(appointment.scheduledTime)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Süre: ${appointment.duration.inMinutes} dakika',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Tür: ${_getAppointmentTypeName(appointment.type)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (appointment.location != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lokasyon: ${appointment.location}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.priority.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (appointment.isTelemedicine)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'TELEMEDICINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (appointment.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Sebep: ${appointment.reason}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (appointment.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${appointment.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAppointmentDetails(appointment),
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
                    onPressed: () => _editAppointment(appointment),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cancelAppointment(appointment),
                    icon: const Icon(Icons.cancel),
                    label: const Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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

  Widget _buildWaitingListTab() {
    return _waitingList.isEmpty
        ? const Center(
            child: Text(
              'Bekleme listesi boş',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _waitingList.length,
            itemBuilder: (context, index) {
              final waiting = _waitingList[index];
              return _buildWaitingListCard(waiting);
            },
          );
  }

  Widget _buildWaitingListCard(WaitingList waiting) {
    final patient = _patientService.getPatientById(waiting.patientId);
    final priorityColor = _getPriorityColor(waiting.priority);
    
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
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    waiting.priority.toString().split('.').last.toUpperCase(),
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
              'Tercih Edilen Tarih: ${_formatDate(waiting.requestedDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Tür: ${_getAppointmentTypeName(waiting.preferredType)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (waiting.preferredTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Tercih Edilen Saat: ${waiting.preferredTime}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (waiting.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Sebep: ${waiting.reason}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (waiting.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${waiting.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWaitingListDetails(waiting),
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
                    onPressed: () => _assignAppointment(waiting),
                    icon: const Icon(Icons.add),
                    label: const Text('Randevu Ver'),
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

  Widget _buildDoctorSchedulesTab() {
    return _doctorSchedules.isEmpty
        ? const Center(
            child: Text(
              'Doktor takvimi bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _doctorSchedules.length,
            itemBuilder: (context, index) {
              final schedule = _doctorSchedules[index];
              return _buildDoctorScheduleCard(schedule);
            },
          );
  }

  Widget _buildDoctorScheduleCard(DoctorSchedule schedule) {
    final statusColor = schedule.isAvailable ? Colors.green : Colors.red;
    
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
                    'Doktor ${schedule.doctorId}',
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
                    schedule.isAvailable ? 'MÜSAİT' : 'MEŞGUL',
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
            if (schedule.location != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lokasyon: ${schedule.location}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Varsayılan Süre: ${schedule.defaultDuration.inMinutes} dakika',
              style: const TextStyle(color: Colors.white70),
            ),
            if (schedule.availableTypes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: schedule.availableTypes.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editSchedule(schedule),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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

  Widget _buildStatisticsTab() {
    final statistics = _appointmentService.getStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Randevu İstatistikleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Randevu', statistics['totalAppointments'].toString(), Colors.blue),
          _buildStatCard('Planlanan', statistics['scheduledAppointments'].toString(), Colors.orange),
          _buildStatCard('Tamamlanan', statistics['completedAppointments'].toString(), Colors.green),
          _buildStatCard('İptal Edilen', statistics['cancelledAppointments'].toString(), Colors.red),
          _buildStatCard('Gelmeyen', statistics['noShowAppointments'].toString(), Colors.purple),
          _buildStatCard('Acil', statistics['urgentAppointments'].toString(), Colors.red),
          _buildStatCard('Telemedicine', statistics['telemedicineAppointments'].toString(), Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Bekleme Listesi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam', statistics['totalWaitingList'].toString(), Colors.blue),
          _buildStatCard('Aktif', statistics['activeWaitingList'].toString(), Colors.orange),
          _buildStatCard('Acil', statistics['urgentWaitingList'].toString(), Colors.red),
          const SizedBox(height: 24),
          const Text(
            'Doktor Takvimleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam', statistics['totalSchedules'].toString(), Colors.blue),
          _buildStatCard('Müsait', statistics['availableSchedules'].toString(), Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.purple;
      case AppointmentStatus.rescheduled:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return Colors.green;
      case PriorityLevel.normal:
        return Colors.blue;
      case PriorityLevel.high:
        return Colors.orange;
      case PriorityLevel.urgent:
        return Colors.red;
    }
  }

  String _getAppointmentTypeName(AppointmentType type) {
    switch (type) {
      case AppointmentType.consultation:
        return 'Konsültasyon';
      case AppointmentType.followUp:
        return 'Takip';
      case AppointmentType.emergency:
        return 'Acil';
      case AppointmentType.group:
        return 'Grup';
      case AppointmentType.assessment:
        return 'Değerlendirme';
      case AppointmentType.therapy:
        return 'Terapi';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Randevu Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(appointment.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Tarih: ${_formatDateTime(appointment.scheduledTime)}', style: const TextStyle(color: Colors.white70)),
              Text('Süre: ${appointment.duration.inMinutes} dakika', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getAppointmentTypeName(appointment.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${appointment.status.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Öncelik: ${appointment.priority.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              if (appointment.location != null)
                Text('Lokasyon: ${appointment.location}', style: const TextStyle(color: Colors.white70)),
              Text('Telemedicine: ${appointment.isTelemedicine ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              if (appointment.reason != null)
                Text('Sebep: ${appointment.reason}', style: const TextStyle(color: Colors.white70)),
              if (appointment.notes != null)
                Text('Notlar: ${appointment.notes}', style: const TextStyle(color: Colors.white70)),
              Text('Hatırlatıcılar: ${appointment.reminders.length}', style: const TextStyle(color: Colors.white70)),
              Text('Geçmiş: ${appointment.history.length}', style: const TextStyle(color: Colors.white70)),
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

  void _editAppointment(Appointment appointment) {
    // TODO: Implement appointment editing form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _cancelAppointment(Appointment appointment) {
    // TODO: Implement appointment cancellation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu iptal etme formu yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showWaitingListDetails(WaitingList waiting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Bekleme Listesi Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(waiting.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Tercih Edilen Tarih: ${_formatDate(waiting.requestedDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getAppointmentTypeName(waiting.preferredType)}', style: const TextStyle(color: Colors.white70)),
              Text('Öncelik: ${waiting.priority.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              if (waiting.preferredTime != null)
                Text('Tercih Edilen Saat: ${waiting.preferredTime}', style: const TextStyle(color: Colors.white70)),
              if (waiting.reason != null)
                Text('Sebep: ${waiting.reason}', style: const TextStyle(color: Colors.white70)),
              if (waiting.notes != null)
                Text('Notlar: ${waiting.notes}', style: const TextStyle(color: Colors.white70)),
              Text('Aktif: ${waiting.isActive ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(waiting.createdAt)}', style: const TextStyle(color: Colors.white70)),
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

  void _assignAppointment(WaitingList waiting) {
    // TODO: Implement appointment assignment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Randevu atama formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showScheduleDetails(DoctorSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Doktor Takvimi Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Doktor: ${schedule.doctorId}', style: const TextStyle(color: Colors.white70)),
              Text('Başlangıç: ${_formatDateTime(schedule.startTime)}', style: const TextStyle(color: Colors.white70)),
              Text('Bitiş: ${_formatDateTime(schedule.endTime)}', style: const TextStyle(color: Colors.white70)),
              if (schedule.location != null)
                Text('Lokasyon: ${schedule.location}', style: const TextStyle(color: Colors.white70)),
              Text('Müsait: ${schedule.isAvailable ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Varsayılan Süre: ${schedule.defaultDuration.inMinutes} dakika', style: const TextStyle(color: Colors.white70)),
              if (schedule.availableTypes.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Müsait Türler:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ...schedule.availableTypes.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $type', style: const TextStyle(color: Colors.white70)),
                  );
                }),
              ],
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

  void _editSchedule(DoctorSchedule schedule) {
    // TODO: Implement schedule editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Takvim düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
