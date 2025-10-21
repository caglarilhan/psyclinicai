import 'package:flutter/material.dart';
import '../../models/nurse_care_models.dart';
import '../../services/nurse_care_service.dart';
import '../../services/patient_service.dart';
import '../../services/role_service.dart';

class NurseCareScreen extends StatefulWidget {
  const NurseCareScreen({super.key});

  @override
  State<NurseCareScreen> createState() => _NurseCareScreenState();
}

class _NurseCareScreenState extends State<NurseCareScreen> with TickerProviderStateMixin {
  final NurseCareService _nurseCareService = NurseCareService();
  final PatientService _patientService = PatientService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<CarePlan> _carePlans = [];
  List<VitalSignsRecord> _vitalSignsRecords = [];
  List<MedicationAdherence> _medicationAdherence = [];
  List<CareNote> _careNotes = [];
  List<EmergencyProtocol> _emergencyProtocols = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedPriority = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
      await _nurseCareService.initialize();
      await _nurseCareService.generateDemoData();
      
      final currentUser = _roleService.getCurrentUser();
      final userId = currentUser['id'] as String;
      
      _carePlans = _nurseCareService.getCarePlansForNurse(userId);
      _vitalSignsRecords = _nurseCareService.getVitalSignsForPatient('1'); // Demo için
      _medicationAdherence = _nurseCareService.getMedicationAdherenceForPatient('1');
      _careNotes = _nurseCareService.getCareNotesForPatient('1');
      
      _emergencyProtocols = _nurseCareService.getEmergencyProtocols();
    } catch (e) {
      print('Error loading nurse care data: $e');
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
          'Hemşire Bakım Yönetimi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Bakım Planları'),
            Tab(text: 'Vital Bulgular'),
            Tab(text: 'İlaç Takibi'),
            Tab(text: 'Bakım Notları'),
            Tab(text: 'Acil Protokoller'),
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
                _buildCarePlansTab(),
                _buildVitalSignsTab(),
                _buildMedicationTab(),
                _buildCareNotesTab(),
                _buildEmergencyProtocolsTab(),
              ],
            ),
    );
  }

  Widget _buildCarePlansTab() {
    final filteredCarePlans = _getFilteredCarePlans();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredCarePlans.isEmpty
              ? const Center(
                  child: Text(
                    'Bakım planı bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCarePlans.length,
                  itemBuilder: (context, index) {
                    final carePlan = filteredCarePlans[index];
                    return _buildCarePlanCard(carePlan);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
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
                DropdownMenuItem(value: 'active', child: Text('Aktif')),
                DropdownMenuItem(value: 'completed', child: Text('Tamamlanan')),
                DropdownMenuItem(value: 'overdue', child: Text('Geciken')),
              ],
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPriority,
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
                DropdownMenuItem(value: 'low', child: Text('Düşük')),
                DropdownMenuItem(value: 'medium', child: Text('Orta')),
                DropdownMenuItem(value: 'high', child: Text('Yüksek')),
                DropdownMenuItem(value: 'critical', child: Text('Kritik')),
              ],
              onChanged: (value) {
                setState(() => _selectedPriority = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<CarePlan> _getFilteredCarePlans() {
    var filtered = _carePlans;
    
    if (_selectedFilter == 'active') {
      filtered = filtered.where((plan) => plan.status == CareStatus.inProgress).toList();
    } else if (_selectedFilter == 'completed') {
      filtered = filtered.where((plan) => plan.status == CareStatus.completed).toList();
    } else if (_selectedFilter == 'overdue') {
      filtered = filtered.where((plan) => plan.status == CareStatus.overdue).toList();
    }
    
    if (_selectedPriority != 'all') {
      filtered = filtered.where((plan) => plan.priority.toString().split('.').last == _selectedPriority).toList();
    }
    
    return filtered;
  }

  Widget _buildCarePlanCard(CarePlan carePlan) {
    final patient = _patientService.getPatientById(carePlan.patientId);
    final priorityColor = _getPriorityColor(carePlan.priority);
    final statusColor = _getStatusColor(carePlan.status);
    
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
                    carePlan.title,
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
                    carePlan.priority.toString().split('.').last.toUpperCase(),
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
              'Hasta: ${patient?.name ?? 'Bilinmeyen Hasta'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              carePlan.description,
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
                    carePlan.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Görevler: ${carePlan.tasks.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (carePlan.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${carePlan.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCarePlanDetails(carePlan),
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
                    onPressed: () => _addCareTask(carePlan),
                    icon: const Icon(Icons.add),
                    label: const Text('Görev Ekle'),
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

  Widget _buildVitalSignsTab() {
    return _vitalSignsRecords.isEmpty
        ? const Center(
            child: Text(
              'Henüz vital bulgu kaydı bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _vitalSignsRecords.length,
            itemBuilder: (context, index) {
              final record = _vitalSignsRecords[index];
              return _buildVitalSignsCard(record);
            },
          );
  }

  Widget _buildVitalSignsCard(VitalSignsRecord record) {
    final patient = _patientService.getPatientById(record.patientId);
    
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
                if (record.isAbnormal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ANORMAL',
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
              'Kayıt Tarihi: ${_formatDateTime(record.recordedAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: record.values.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getVitalSignName(entry.key)}: ${entry.value}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            if (record.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${record.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showVitalSignsDetails(record),
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

  Widget _buildMedicationTab() {
    return _medicationAdherence.isEmpty
        ? const Center(
            child: Text(
              'Henüz ilaç takibi bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _medicationAdherence.length,
            itemBuilder: (context, index) {
              final adherence = _medicationAdherence[index];
              return _buildMedicationCard(adherence);
            },
          );
  }

  Widget _buildMedicationCard(MedicationAdherence adherence) {
    final patient = _patientService.getPatientById(adherence.patientId);
    final adherenceColor = _getAdherenceColor(adherence.adherencePercentage);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              adherence.medicationName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hasta: ${patient?.name ?? 'Bilinmeyen Hasta'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Doz: ${adherence.dosage} - ${adherence.frequency}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: adherenceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Uyum: %${adherence.adherencePercentage}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Son Alım: ${adherence.lastTakenDate != null ? _formatDateTime(adherence.lastTakenDate!) : 'Bilinmiyor'}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (adherence.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${adherence.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showMedicationDetails(adherence),
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
                    onPressed: () => _recordMedicationEvent(adherence),
                    icon: const Icon(Icons.add),
                    label: const Text('Kayıt Ekle'),
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

  Widget _buildCareNotesTab() {
    return _careNotes.isEmpty
        ? const Center(
            child: Text(
              'Henüz bakım notu bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _careNotes.length,
            itemBuilder: (context, index) {
              final note = _careNotes[index];
              return _buildCareNoteCard(note);
            },
          );
  }

  Widget _buildCareNoteCard(CareNote note) {
    final patient = _patientService.getPatientById(note.patientId);
    final priorityColor = _getPriorityColor(note.priority);
    
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
                    note.priority.toString().split('.').last.toUpperCase(),
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
              'Tarih: ${_formatDateTime(note.noteDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (note.category != null) ...[
              const SizedBox(height: 4),
              Text(
                'Kategori: ${note.category}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              note.content,
              style: const TextStyle(color: Colors.white70),
            ),
            if (note.isUrgent) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ACİL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyProtocolsTab() {
    return _emergencyProtocols.isEmpty
        ? const Center(
            child: Text(
              'Henüz acil protokol bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _emergencyProtocols.length,
            itemBuilder: (context, index) {
              final protocol = _emergencyProtocols[index];
              return _buildEmergencyProtocolCard(protocol);
            },
          );
  }

  Widget _buildEmergencyProtocolCard(EmergencyProtocol protocol) {
    final priorityColor = _getPriorityColor(protocol.priority);
    
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
                    protocol.title,
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
                    protocol.priority.toString().split('.').last.toUpperCase(),
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
              protocol.description,
              style: const TextStyle(color: Colors.white70),
            ),
            if (protocol.category != null) ...[
              const SizedBox(height: 4),
              Text(
                'Kategori: ${protocol.category}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Adımlar:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...protocol.steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  '${entry.key + 1}. ${entry.value}',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showEmergencyProtocolDetails(protocol),
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

  Color _getPriorityColor(CarePriority priority) {
    switch (priority) {
      case CarePriority.low:
        return Colors.green;
      case CarePriority.medium:
        return Colors.orange;
      case CarePriority.high:
        return Colors.red;
      case CarePriority.critical:
        return Colors.purple;
    }
  }

  Color _getStatusColor(CareStatus status) {
    switch (status) {
      case CareStatus.planned:
        return Colors.blue;
      case CareStatus.inProgress:
        return Colors.orange;
      case CareStatus.completed:
        return Colors.green;
      case CareStatus.cancelled:
        return Colors.red;
      case CareStatus.overdue:
        return Colors.purple;
    }
  }

  Color _getAdherenceColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getVitalSignName(VitalSignType type) {
    switch (type) {
      case VitalSignType.bloodPressure:
        return 'Tansiyon';
      case VitalSignType.heartRate:
        return 'Nabız';
      case VitalSignType.temperature:
        return 'Ateş';
      case VitalSignType.respiratoryRate:
        return 'Solunum';
      case VitalSignType.oxygenSaturation:
        return 'Oksijen';
      case VitalSignType.weight:
        return 'Kilo';
      case VitalSignType.height:
        return 'Boy';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showCarePlanDetails(CarePlan carePlan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          carePlan.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(carePlan.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Açıklama: ${carePlan.description}', style: const TextStyle(color: Colors.white70)),
              Text('Öncelik: ${carePlan.priority.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${carePlan.status.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Başlangıç: ${_formatDateTime(carePlan.startDate)}', style: const TextStyle(color: Colors.white70)),
              if (carePlan.endDate != null)
                Text('Bitiş: ${_formatDateTime(carePlan.endDate!)}', style: const TextStyle(color: Colors.white70)),
              Text('Görevler: ${carePlan.tasks.length}', style: const TextStyle(color: Colors.white70)),
              if (carePlan.notes != null)
                Text('Notlar: ${carePlan.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _addCareTask(CarePlan carePlan) {
    // TODO: Implement add care task form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Görev ekleme formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showVitalSignsDetails(VitalSignsRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Vital Bulgular Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(record.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Kayıt Tarihi: ${_formatDateTime(record.recordedAt)}', style: const TextStyle(color: Colors.white70)),
              Text('Anormal: ${record.isAbnormal ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Değerler:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...record.values.entries.map((entry) {
                return Text('${_getVitalSignName(entry.key)}: ${entry.value}', style: const TextStyle(color: Colors.white70));
              }),
              if (record.notes != null)
                Text('Notlar: ${record.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _showMedicationDetails(MedicationAdherence adherence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          adherence.medicationName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(adherence.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Doz: ${adherence.dosage}', style: const TextStyle(color: Colors.white70)),
              Text('Sıklık: ${adherence.frequency}', style: const TextStyle(color: Colors.white70)),
              Text('Uyum: %${adherence.adherencePercentage}', style: const TextStyle(color: Colors.white70)),
              Text('Reçete Tarihi: ${_formatDateTime(adherence.prescribedDate)}', style: const TextStyle(color: Colors.white70)),
              if (adherence.lastTakenDate != null)
                Text('Son Alım: ${_formatDateTime(adherence.lastTakenDate!)}', style: const TextStyle(color: Colors.white70)),
              Text('Olaylar: ${adherence.events.length}', style: const TextStyle(color: Colors.white70)),
              if (adherence.notes != null)
                Text('Notlar: ${adherence.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _recordMedicationEvent(MedicationAdherence adherence) {
    // TODO: Implement medication event recording form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İlaç kayıt formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEmergencyProtocolDetails(EmergencyProtocol protocol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          protocol.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Açıklama: ${protocol.description}', style: const TextStyle(color: Colors.white70)),
              Text('Öncelik: ${protocol.priority.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              if (protocol.category != null)
                Text('Kategori: ${protocol.category}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(protocol.createdAt)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Adımlar:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...protocol.steps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }),
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
}
