import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/diagnosis_models.dart';
import '../../services/diagnosis_service.dart';
import '../../widgets/diagnosis/diagnosis_search_widget.dart';
import '../../widgets/diagnosis/ai_diagnosis_widget.dart';
import '../../widgets/diagnosis/diagnosis_history_widget.dart';

class DiagnosisSystemScreen extends StatefulWidget {
  const DiagnosisSystemScreen({super.key});

  @override
  State<DiagnosisSystemScreen> createState() => _DiagnosisSystemScreenState();
}

class _DiagnosisSystemScreenState extends State<DiagnosisSystemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DiagnosisService _diagnosisService = DiagnosisService();
  
  bool _isLoading = false;
  List<Diagnosis> _recentDiagnoses = [];
  List<DiagnosisCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final recent = await _diagnosisService.getRecentDiagnoses();
      final categories = await _diagnosisService.getDiagnosisCategories();
      
      setState(() {
        _recentDiagnoses = recent;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Destekli Tanı Sistemi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Tanı Arama'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Tanı'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
            Tab(icon: Icon(Icons.category), text: 'Kategoriler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDiagnosisDialog,
            tooltip: 'Yeni Tanı',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tanı Arama Tab'ı
                const DiagnosisSearchWidget(),
                
                // AI Tanı Tab'ı
                const AIDiagnosisWidget(),
                
                // Geçmiş Tab'ı
                DiagnosisHistoryWidget(diagnoses: _recentDiagnoses),
                
                // Kategoriler Tab'ı
                _buildCategoriesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDiagnosisDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Tanı'),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanı Kategorileri',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(DiagnosisCategory category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showCategoryDetails(category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withOpacity(0.1),
                category.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  size: 32,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${category.diagnosisCount} tanı',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(DiagnosisCategory category) {
    showDialog(
      context: context,
      builder: (context) => CategoryDetailsDialog(category: category),
    );
  }

  void _showAddDiagnosisDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddDiagnosisDialog(),
    ).then((_) => _loadInitialData());
  }
}

// Kategori detayları dialog'u
class CategoryDetailsDialog extends StatelessWidget {
  final DiagnosisCategory category;

  const CategoryDetailsDialog({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    size: 24,
                    color: category.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Açıklama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Toplam Tanı',
                    '${category.diagnosisCount}',
                    Icons.medical_services,
                    category.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Alt Kategoriler',
                    '${category.subCategories.length}',
                    Icons.folder,
                    category.color,
                  ),
                ),
              ],
            ),
            
            if (category.subCategories.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Alt Kategoriler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              ...category.subCategories.map((subCategory) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right,
                        size: 16,
                        color: category.color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subCategory.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Text(
                        '${subCategory.diagnosisCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: category.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Yeni tanı ekleme dialog'u
class AddDiagnosisDialog extends StatefulWidget {
  const AddDiagnosisDialog({super.key});

  @override
  State<AddDiagnosisDialog> createState() => _AddDiagnosisDialogState();
}

class _AddDiagnosisDialogState extends State<AddDiagnosisDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _criteriaController = TextEditingController();
  DiagnosisCategory? _selectedCategory;
  DiagnosisSeverity _selectedSeverity = DiagnosisSeverity.mild;
  List<String> _symptoms = [];
  final _symptomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Tanı Ekle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'ICD/DSM Kodu',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: F32.1, 296.22',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kod gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tanı Adı',
                  border: OutlineInputBorder(),
                  hintText: 'Örn: Orta Depresif Bozukluk',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanı adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                  hintText: 'Tanının detaylı açıklaması',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _criteriaController,
                decoration: const InputDecoration(
                  labelText: 'Tanı Kriterleri',
                  border: OutlineInputBorder(),
                  hintText: 'DSM-5 veya ICD-11 kriterleri',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DiagnosisCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: DiagnosisService().getDiagnosisCategories().then((categories) => 
                  categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  )).toList()
                ).then((items) => items),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kategori seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DiagnosisSeverity>(
                value: _selectedSeverity,
                decoration: const InputDecoration(
                  labelText: 'Şiddet',
                  border: OutlineInputBorder(),
                ),
                items: DiagnosisSeverity.values.map((severity) => 
                  DropdownMenuItem(
                    value: severity,
                    child: Text(_getSeverityText(severity)),
                  )
                ).toList(),
                onChanged: (value) {
                  setState(() => _selectedSeverity = value!);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Belirtiler',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _symptomController,
                      decoration: const InputDecoration(
                        hintText: 'Belirti ekle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSymptom,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_symptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _symptoms.map((symptom) => Chip(
                    label: Text(symptom),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSymptom(symptom),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppTheme.primaryColor),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveDiagnosis,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  void _addSymptom() {
    if (_symptomController.text.isNotEmpty) {
      setState(() {
        _symptoms.add(_symptomController.text);
        _symptomController.clear();
      });
    }
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _symptoms.remove(symptom);
    });
  }

  void _saveDiagnosis() async {
    if (_formKey.currentState!.validate()) {
      final diagnosis = Diagnosis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: _codeController.text,
        name: _nameController.text,
        description: _descriptionController.text,
        criteria: _criteriaController.text,
        category: _selectedCategory!,
        severity: _selectedSeverity,
        symptoms: _symptoms,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await DiagnosisService().addDiagnosis(diagnosis);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tanı başarıyla eklendi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tanı eklenirken hata: $e')),
          );
        }
      }
    }
  }

  String _getSeverityText(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.mild:
        return 'Hafif';
      case DiagnosisSeverity.moderate:
        return 'Orta';
      case DiagnosisSeverity.severe:
        return 'Şiddetli';
      case DiagnosisSeverity.critical:
        return 'Kritik';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _criteriaController.dispose();
    _symptomController.dispose();
    super.dispose();
  }
}
