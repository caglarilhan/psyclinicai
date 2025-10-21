import 'package:flutter/material.dart';
import '../../models/medication_tracking_models.dart';
import '../../services/medication_tracking_service.dart';
import '../../services/patient_service.dart';
import '../../services/role_service.dart';

class MedicationTrackingScreen extends StatefulWidget {
  const MedicationTrackingScreen({super.key});

  @override
  State<MedicationTrackingScreen> createState() => _MedicationTrackingScreenState();
}

class _MedicationTrackingScreenState extends State<MedicationTrackingScreen> with TickerProviderStateMixin {
  final MedicationTrackingService _medicationService = MedicationTrackingService();
  final PatientService _patientService = PatientService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<MedicationRecord> _medications = [];
  List<SideEffectRecord> _sideEffects = [];
  List<MedicationInteraction> _interactions = [];
  List<MedicationEducation> _educations = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';
  String _selectedAdherence = 'all';

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
      await _medicationService.initialize();
      await _medicationService.generateDemoData();
      
      final currentUser = _roleService.getCurrentUser();
      if (currentUser != null) {
        _medications = _medicationService.getMedicationsForPatient('1'); // Demo için
        _sideEffects = _medicationService.getSideEffectsForMedication('med_001');
        _interactions = _medicationService.getInteractionsForMedication('med_001');
        _educations = _medicationService.getEducationsForPatient('1');
      }
    } catch (e) {
      print('Error loading medication tracking data: $e');
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
          'İlaç Takibi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'İlaçlar'),
            Tab(text: 'Yan Etkiler'),
            Tab(text: 'Etkileşimler'),
            Tab(text: 'Eğitimler'),
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
                _buildMedicationsTab(),
                _buildSideEffectsTab(),
                _buildInteractionsTab(),
                _buildEducationsTab(),
              ],
            ),
    );
  }

  Widget _buildMedicationsTab() {
    final filteredMedications = _getFilteredMedications();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredMedications.isEmpty
              ? const Center(
                  child: Text(
                    'İlaç kaydı bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = filteredMedications[index];
                    return _buildMedicationCard(medication);
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
                DropdownMenuItem(value: 'poor_adherence', child: Text('Düşük Uyum')),
                DropdownMenuItem(value: 'side_effects', child: Text('Yan Etkili')),
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
                DropdownMenuItem(value: 'active', child: Text('Aktif')),
                DropdownMenuItem(value: 'paused', child: Text('Duraklatıldı')),
                DropdownMenuItem(value: 'discontinued', child: Text('Kesildi')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<MedicationRecord> _getFilteredMedications() {
    var filtered = _medications;
    
    if (_selectedFilter == 'active') {
      filtered = filtered.where((med) => med.status == MedicationStatus.active).toList();
    } else if (_selectedFilter == 'poor_adherence') {
      filtered = filtered.where((med) => 
          med.adherenceLevel == AdherenceLevel.poor || 
          med.adherenceLevel == AdherenceLevel.critical).toList();
    } else if (_selectedFilter == 'side_effects') {
      filtered = filtered.where((med) => med.sideEffects.isNotEmpty).toList();
    }
    
    if (_selectedStatus != 'all') {
      filtered = filtered.where((med) => med.status.toString().split('.').last == _selectedStatus).toList();
    }
    
    return filtered;
  }

  Widget _buildMedicationCard(MedicationRecord medication) {
    final patient = _patientService.getPatientById(medication.patientId);
    final statusColor = _getStatusColor(medication.status);
    final adherenceColor = _getAdherenceColor(medication.adherenceLevel);
    
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
                    medication.medicationName,
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
                    medication.status.toString().split('.').last.toUpperCase(),
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
              'Doz: ${medication.dosage} - ${medication.frequency}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Tür: ${_getMedicationTypeName(medication.type)}',
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
                    'Uyum: %${medication.adherencePercentage.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Reçete: ${_formatDateTime(medication.prescribedDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (medication.indication != null) ...[
              const SizedBox(height: 8),
              Text(
                'Endikasyon: ${medication.indication}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (medication.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Yan Etkiler: ${medication.sideEffects.length}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showMedicationDetails(medication),
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
                    onPressed: () => _recordDose(medication),
                    icon: const Icon(Icons.add),
                    label: const Text('Doz Kaydet'),
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

  Widget _buildSideEffectsTab() {
    return _sideEffects.isEmpty
        ? const Center(
            child: Text(
              'Henüz yan etki kaydı bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _sideEffects.length,
            itemBuilder: (context, index) {
              final sideEffect = _sideEffects[index];
              return _buildSideEffectCard(sideEffect);
            },
          );
  }

  Widget _buildSideEffectCard(SideEffectRecord sideEffect) {
    final severityColor = _getSeverityColor(sideEffect.severity);
    
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
                    sideEffect.sideEffect,
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
                    color: severityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sideEffect.severity.toString().split('.').last.toUpperCase(),
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
              'Başlangıç: ${_formatDateTime(sideEffect.onsetDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (sideEffect.resolutionDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Çözüm: ${_formatDateTime(sideEffect.resolutionDate!)}',
                style: const TextStyle(color: Colors.green),
              ),
            ],
            if (sideEffect.description != null) ...[
              const SizedBox(height: 8),
              Text(
                'Açıklama: ${sideEffect.description}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (sideEffect.actionTaken != null) ...[
              const SizedBox(height: 8),
              Text(
                'Alınan Aksiyon: ${sideEffect.actionTaken}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (sideEffect.requiresMedicalAttention) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TIBBİ MÜDAHALE GEREKLİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showSideEffectDetails(sideEffect),
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

  Widget _buildInteractionsTab() {
    return _interactions.isEmpty
        ? const Center(
            child: Text(
              'Henüz etkileşim kaydı bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _interactions.length,
            itemBuilder: (context, index) {
              final interaction = _interactions[index];
              return _buildInteractionCard(interaction);
            },
          );
  }

  Widget _buildInteractionCard(MedicationInteraction interaction) {
    final severityColor = _getInteractionSeverityColor(interaction.severity);
    
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
                    interaction.interactionType,
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
                    color: severityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interaction.severity.toUpperCase(),
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
              'Tespit: ${_formatDateTime(interaction.detectedAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              interaction.description,
              style: const TextStyle(color: Colors.white70),
            ),
            if (interaction.clinicalSignificance != null) ...[
              const SizedBox(height: 8),
              Text(
                'Klinik Önem: ${interaction.clinicalSignificance}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (interaction.management != null) ...[
              const SizedBox(height: 8),
              Text(
                'Yönetim: ${interaction.management}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showInteractionDetails(interaction),
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

  Widget _buildEducationsTab() {
    return _educations.isEmpty
        ? const Center(
            child: Text(
              'Henüz eğitim kaydı bulunmuyor',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _educations.length,
            itemBuilder: (context, index) {
              final education = _educations[index];
              return _buildEducationCard(education);
            },
          );
  }

  Widget _buildEducationCard(MedicationEducation education) {
    final statusColor = education.isCompleted ? Colors.green : Colors.orange;
    
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
                    education.title,
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
                    education.isCompleted ? 'TAMAMLANDI' : 'BEKLİYOR',
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
              'Atama: ${_formatDateTime(education.assignedDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (education.completedDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Tamamlanma: ${_formatDateTime(education.completedDate!)}',
                style: const TextStyle(color: Colors.green),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              education.content,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: education.topics.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (education.quizResults != null) ...[
              const SizedBox(height: 8),
              Text(
                'Quiz Sonucu: ${education.quizResults}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEducationDetails(education),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                if (!education.isCompleted) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeEducation(education),
                      icon: const Icon(Icons.check),
                      label: const Text('Tamamla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.active:
        return Colors.green;
      case MedicationStatus.paused:
        return Colors.orange;
      case MedicationStatus.discontinued:
        return Colors.red;
      case MedicationStatus.completed:
        return Colors.blue;
    }
  }

  Color _getAdherenceColor(AdherenceLevel level) {
    switch (level) {
      case AdherenceLevel.excellent:
        return Colors.green;
      case AdherenceLevel.good:
        return Colors.blue;
      case AdherenceLevel.fair:
        return Colors.orange;
      case AdherenceLevel.poor:
        return Colors.red;
      case AdherenceLevel.critical:
        return Colors.purple;
    }
  }

  Color _getSeverityColor(SideEffectSeverity severity) {
    switch (severity) {
      case SideEffectSeverity.mild:
        return Colors.green;
      case SideEffectSeverity.moderate:
        return Colors.orange;
      case SideEffectSeverity.severe:
        return Colors.red;
      case SideEffectSeverity.lifeThreatening:
        return Colors.purple;
    }
  }

  Color _getInteractionSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      case 'major':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMedicationTypeName(MedicationType type) {
    switch (type) {
      case MedicationType.tablet:
        return 'Tablet';
      case MedicationType.capsule:
        return 'Kapsül';
      case MedicationType.liquid:
        return 'Sıvı';
      case MedicationType.injection:
        return 'Enjeksiyon';
      case MedicationType.patch:
        return 'Yama';
      case MedicationType.inhaler:
        return 'İnhaler';
      case MedicationType.other:
        return 'Diğer';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showMedicationDetails(MedicationRecord medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          medication.medicationName,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hasta: ${_patientService.getPatientById(medication.patientId)?.name ?? 'Bilinmeyen'}', style: const TextStyle(color: Colors.white70)),
              Text('Doz: ${medication.dosage}', style: const TextStyle(color: Colors.white70)),
              Text('Sıklık: ${medication.frequency}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getMedicationTypeName(medication.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${medication.status.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Uyum: %${medication.adherencePercentage.round()}', style: const TextStyle(color: Colors.white70)),
              Text('Reçete: ${_formatDateTime(medication.prescribedDate)}', style: const TextStyle(color: Colors.white70)),
              if (medication.indication != null)
                Text('Endikasyon: ${medication.indication}', style: const TextStyle(color: Colors.white70)),
              if (medication.instructions != null)
                Text('Talimatlar: ${medication.instructions}', style: const TextStyle(color: Colors.white70)),
              Text('Dozlar: ${medication.doses.length}', style: const TextStyle(color: Colors.white70)),
              Text('Yan Etkiler: ${medication.sideEffects.length}', style: const TextStyle(color: Colors.white70)),
              if (medication.notes != null)
                Text('Notlar: ${medication.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _recordDose(MedicationRecord medication) {
    // TODO: Implement dose recording form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doz kayıt formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSideEffectDetails(SideEffectRecord sideEffect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          sideEffect.sideEffect,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Şiddet: ${sideEffect.severity.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Başlangıç: ${_formatDateTime(sideEffect.onsetDate)}', style: const TextStyle(color: Colors.white70)),
              if (sideEffect.resolutionDate != null)
                Text('Çözüm: ${_formatDateTime(sideEffect.resolutionDate!)}', style: const TextStyle(color: Colors.white70)),
              if (sideEffect.description != null)
                Text('Açıklama: ${sideEffect.description}', style: const TextStyle(color: Colors.white70)),
              if (sideEffect.actionTaken != null)
                Text('Alınan Aksiyon: ${sideEffect.actionTaken}', style: const TextStyle(color: Colors.white70)),
              Text('Tıbbi Müdahale: ${sideEffect.requiresMedicalAttention ? 'Gerekli' : 'Gerekli Değil'}', style: const TextStyle(color: Colors.white70)),
              if (sideEffect.notes != null)
                Text('Notlar: ${sideEffect.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _showInteractionDetails(MedicationInteraction interaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          interaction.interactionType,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Şiddet: ${interaction.severity}', style: const TextStyle(color: Colors.white70)),
              Text('Tespit: ${_formatDateTime(interaction.detectedAt)}', style: const TextStyle(color: Colors.white70)),
              Text('Açıklama: ${interaction.description}', style: const TextStyle(color: Colors.white70)),
              if (interaction.clinicalSignificance != null)
                Text('Klinik Önem: ${interaction.clinicalSignificance}', style: const TextStyle(color: Colors.white70)),
              if (interaction.management != null)
                Text('Yönetim: ${interaction.management}', style: const TextStyle(color: Colors.white70)),
              if (interaction.detectedBy != null)
                Text('Tespit Eden: ${interaction.detectedBy}', style: const TextStyle(color: Colors.white70)),
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

  void _showEducationDetails(MedicationEducation education) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: Text(
          education.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Atama: ${_formatDateTime(education.assignedDate)}', style: const TextStyle(color: Colors.white70)),
              if (education.completedDate != null)
                Text('Tamamlanma: ${_formatDateTime(education.completedDate!)}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${education.isCompleted ? 'Tamamlandı' : 'Bekliyor'}', style: const TextStyle(color: Colors.white70)),
              Text('İçerik: ${education.content}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Konular:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...education.topics.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $topic', style: const TextStyle(color: Colors.white70)),
                );
              }),
              if (education.quizResults != null)
                Text('Quiz Sonucu: ${education.quizResults}', style: const TextStyle(color: Colors.white70)),
              if (education.notes != null)
                Text('Notlar: ${education.notes}', style: const TextStyle(color: Colors.white70)),
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

  void _completeEducation(MedicationEducation education) {
    // TODO: Implement education completion form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eğitim tamamlama formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
