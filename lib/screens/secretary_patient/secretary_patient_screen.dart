import 'package:flutter/material.dart';
import '../../models/secretary_patient_models.dart';
import '../../services/secretary_patient_service.dart';
import '../../services/patient_service.dart';
import '../../services/role_service.dart';

class SecretaryPatientScreen extends StatefulWidget {
  const SecretaryPatientScreen({super.key});

  @override
  State<SecretaryPatientScreen> createState() => _SecretaryPatientScreenState();
}

class _SecretaryPatientScreenState extends State<SecretaryPatientScreen> with TickerProviderStateMixin {
  final SecretaryPatientService _patientService = SecretaryPatientService();
  final PatientService _patientService2 = PatientService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<PatientRecord> _patientRecords = [];
  List<RecordTemplate> _recordTemplates = [];
  List<PatientDocument> _patientDocuments = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedType = 'all';
  String _selectedPriority = 'all';
  String _searchQuery = '';

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
      await _patientService.initialize();
      await _patientService.generateDemoData();
      
      final currentUser = _roleService.getCurrentUser();
      _patientRecords = _patientService.getRecordsForSecretary(currentUser['id'] as String);
      _recordTemplates = _patientService.getActiveTemplates();
      _patientDocuments = _patientService.getDocumentsForPatient('1');
    } catch (e) {
      print('Error loading secretary patient data: $e');
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
          'Hasta Kayıt Yönetimi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Kayıtlar'),
            Tab(text: 'Şablonlar'),
            Tab(text: 'Dokümanlar'),
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
                _buildRecordsTab(),
                _buildTemplatesTab(),
                _buildDocumentsTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildRecordsTab() {
    final filteredRecords = _getFilteredRecords();
    
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(
                  child: Text(
                    'Kayıt bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildRecordCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Arama',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Başlık veya içerik ara...',
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tür',
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
                    DropdownMenuItem(value: 'personal', child: Text('Kişisel')),
                    DropdownMenuItem(value: 'medical', child: Text('Tıbbi')),
                    DropdownMenuItem(value: 'insurance', child: Text('Sigorta')),
                    DropdownMenuItem(value: 'emergency', child: Text('Acil')),
                    DropdownMenuItem(value: 'family', child: Text('Aile')),
                    DropdownMenuItem(value: 'legal', child: Text('Yasal')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
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
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'high', child: Text('Yüksek')),
                    DropdownMenuItem(value: 'urgent', child: Text('Acil')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPriority = value!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PatientRecord> _getFilteredRecords() {
    var filtered = _patientRecords;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((record) => 
          record.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          record.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    if (_selectedType != 'all') {
      filtered = filtered.where((record) => record.type.toString().split('.').last == _selectedType).toList();
    }
    
    if (_selectedPriority != 'all') {
      filtered = filtered.where((record) => record.priority.toString().split('.').last == _selectedPriority).toList();
    }
    
    return filtered;
  }

  Widget _buildRecordCard(PatientRecord record) {
    final patient = _patientService2.getPatientById(record.patientId);
    final typeColor = _getRecordTypeColor(record.type);
    final priorityColor = _getPriorityColor(record.priority);
    
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
                    record.title,
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
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRecordTypeName(record.type),
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
              'Oluşturulma: ${_formatDateTime(record.createdAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              record.content,
              style: const TextStyle(color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
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
                    record.priority.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (record.isConfidential)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'GİZLİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordDetails(record),
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
                    onPressed: () => _editRecord(record),
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
                    onPressed: () => _deleteRecord(record),
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
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

  Widget _buildTemplatesTab() {
    return _recordTemplates.isEmpty
        ? const Center(
            child: Text(
              'Şablon bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recordTemplates.length,
            itemBuilder: (context, index) {
              final template = _recordTemplates[index];
              return _buildTemplateCard(template);
            },
          );
  }

  Widget _buildTemplateCard(RecordTemplate template) {
    final typeColor = _getRecordTypeColor(template.type);
    
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRecordTypeName(template.type),
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
              template.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Kullanım Sayısı: ${template.usageCount}',
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
                    icon: const Icon(Icons.add),
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

  Widget _buildDocumentsTab() {
    return _patientDocuments.isEmpty
        ? const Center(
            child: Text(
              'Doküman bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _patientDocuments.length,
            itemBuilder: (context, index) {
              final document = _patientDocuments[index];
              return _buildDocumentCard(document);
            },
          );
  }

  Widget _buildDocumentCard(PatientDocument document) {
    final typeColor = _getDocumentTypeColor(document.type);
    
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
                    document.fileName,
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
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDocumentTypeName(document.type),
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
              'Boyut: ${_formatFileSize(document.fileSize)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Tür: ${document.mimeType}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Yüklenme: ${_formatDateTime(document.uploadedAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (document.description != null) ...[
              const SizedBox(height: 8),
              Text(
                'Açıklama: ${document.description}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDocumentDetails(document),
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
                    onPressed: () => _downloadDocument(document),
                    icon: const Icon(Icons.download),
                    label: const Text('İndir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteDocument(document),
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
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

  Widget _buildStatisticsTab() {
    final statistics = _patientService.getStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasta Kayıt İstatistikleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Kayıt', statistics['totalRecords'].toString(), Colors.blue),
          _buildStatCard('Kişisel Kayıt', statistics['personalRecords'].toString(), Colors.green),
          _buildStatCard('Tıbbi Kayıt', statistics['medicalRecords'].toString(), Colors.red),
          _buildStatCard('Sigorta Kayıt', statistics['insuranceRecords'].toString(), Colors.orange),
          _buildStatCard('Acil Kayıt', statistics['emergencyRecords'].toString(), Colors.red),
          _buildStatCard('Aile Kayıt', statistics['familyRecords'].toString(), Colors.purple),
          _buildStatCard('Yasal Kayıt', statistics['legalRecords'].toString(), Colors.indigo),
          const SizedBox(height: 24),
          const Text(
            'Özel Durumlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Acil Kayıt', statistics['urgentRecords'].toString(), Colors.red),
          _buildStatCard('Gizli Kayıt', statistics['confidentialRecords'].toString(), Colors.purple),
          const SizedBox(height: 24),
          const Text(
            'Dokümanlar ve Şablonlar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Doküman', statistics['totalDocuments'].toString(), Colors.blue),
          _buildStatCard('Toplam Şablon', statistics['totalTemplates'].toString(), Colors.green),
          _buildStatCard('Aktif Şablon', statistics['activeTemplates'].toString(), Colors.orange),
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

  Color _getRecordTypeColor(RecordType type) {
    switch (type) {
      case RecordType.personal:
        return Colors.blue;
      case RecordType.medical:
        return Colors.red;
      case RecordType.insurance:
        return Colors.orange;
      case RecordType.emergency:
        return Colors.red;
      case RecordType.family:
        return Colors.purple;
      case RecordType.legal:
        return Colors.indigo;
    }
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.id:
        return Colors.blue;
      case DocumentType.insurance:
        return Colors.orange;
      case DocumentType.medicalReport:
        return Colors.red;
      case DocumentType.prescription:
        return Colors.green;
      case DocumentType.labResult:
        return Colors.purple;
      case DocumentType.image:
        return Colors.pink;
      case DocumentType.other:
        return Colors.grey;
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

  String _getRecordTypeName(RecordType type) {
    switch (type) {
      case RecordType.personal:
        return 'KİŞİSEL';
      case RecordType.medical:
        return 'TIBBİ';
      case RecordType.insurance:
        return 'SİGORTA';
      case RecordType.emergency:
        return 'ACİL';
      case RecordType.family:
        return 'AİLE';
      case RecordType.legal:
        return 'YASAL';
    }
  }

  String _getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.id:
        return 'KİMLİK';
      case DocumentType.insurance:
        return 'SİGORTA';
      case DocumentType.medicalReport:
        return 'RAPOR';
      case DocumentType.prescription:
        return 'REÇETE';
      case DocumentType.labResult:
        return 'LAB';
      case DocumentType.image:
        return 'GÖRSEL';
      case DocumentType.other:
        return 'DİĞER';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showRecordDetails(PatientRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Kayıt Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Başlık: ${record.title}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getRecordTypeName(record.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Öncelik: ${record.priority.toString().split('.').last}', style: const TextStyle(color: Colors.white70)),
              Text('Gizli: ${record.isConfidential ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(record.createdAt)}', style: const TextStyle(color: Colors.white70)),
              if (record.updatedAt != null)
                Text('Güncellenme: ${_formatDateTime(record.updatedAt!)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${record.createdBy ?? 'Bilinmiyor'}', style: const TextStyle(color: Colors.white70)),
              if (record.updatedBy != null)
                Text('Güncelleyen: ${record.updatedBy}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('İçerik:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(record.content, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Dokümanlar: ${record.documents.length}', style: const TextStyle(color: Colors.white70)),
              Text('Geçmiş: ${record.history.length}', style: const TextStyle(color: Colors.white70)),
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

  void _editRecord(PatientRecord record) {
    // TODO: Implement record editing form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteRecord(PatientRecord record) {
    // TODO: Implement record deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt silme formu yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showTemplateDetails(RecordTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Şablon Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ad: ${template.name}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getRecordTypeName(template.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Açıklama: ${template.description}', style: const TextStyle(color: Colors.white70)),
              Text('Kullanım Sayısı: ${template.usageCount}', style: const TextStyle(color: Colors.white70)),
              Text('Aktif: ${template.isActive ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(template.createdAt)}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${template.createdBy}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Alanlar:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...template.fields.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• ${entry.key}: ${entry.value}', style: const TextStyle(color: Colors.white70)),
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

  void _useTemplate(RecordTemplate template) {
    // TODO: Implement template usage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şablon kullanma formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDocumentDetails(PatientDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Doküman Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dosya Adı: ${document.fileName}', style: const TextStyle(color: Colors.white70)),
              Text('Tür: ${_getDocumentTypeName(document.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Boyut: ${_formatFileSize(document.fileSize)}', style: const TextStyle(color: Colors.white70)),
              Text('MIME Türü: ${document.mimeType}', style: const TextStyle(color: Colors.white70)),
              Text('Şifreli: ${document.isEncrypted ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              Text('Yüklenme: ${_formatDateTime(document.uploadedAt)}', style: const TextStyle(color: Colors.white70)),
              Text('Yükleyen: ${document.uploadedBy}', style: const TextStyle(color: Colors.white70)),
              if (document.description != null)
                Text('Açıklama: ${document.description}', style: const TextStyle(color: Colors.white70)),
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

  void _downloadDocument(PatientDocument document) {
    // TODO: Implement document download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doküman indirme özelliği yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteDocument(PatientDocument document) {
    // TODO: Implement document deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doküman silme formu yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
