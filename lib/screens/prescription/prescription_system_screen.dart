import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/prescription_models.dart';
import '../../services/prescription_service.dart';
import '../../widgets/prescription/prescription_list_widget.dart';
import '../../widgets/prescription/medication_search_widget.dart';
import '../../widgets/prescription/ai_prescription_widget.dart';
import '../../widgets/prescription/prescription_statistics_widget.dart';

class PrescriptionSystemScreen extends StatefulWidget {
  const PrescriptionSystemScreen({super.key});

  @override
  State<PrescriptionSystemScreen> createState() => _PrescriptionSystemScreenState();
}

class _PrescriptionSystemScreenState extends State<PrescriptionSystemScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PrescriptionService _prescriptionService = PrescriptionService();
  
  bool _isLoading = true;
  List<Prescription> _prescriptions = [];
  List<Medication> _medications = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _prescriptions = await _prescriptionService.getAllPrescriptions();
      _medications = await _prescriptionService.getAllMedications();
      _statistics = await _prescriptionService.getPrescriptionStatistics();
      setState(() => _isLoading = false);
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
        title: const Text('Reçete & İlaç Sistemi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.medication), text: 'Reçeteler'),
            Tab(icon: Icon(Icons.search), text: 'İlaç Arama'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Öneriler'),
            Tab(icon: Icon(Icons.analytics), text: 'İstatistikler'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPrescriptionDialog,
            tooltip: 'Yeni Reçete',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Reçete verileri yükleniyor...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Reçeteler Tab'ı
                PrescriptionListWidget(
                  prescriptions: _prescriptions,
                  onPrescriptionUpdated: _loadData,
                ),
                
                // İlaç Arama Tab'ı
                MedicationSearchWidget(
                  medications: _medications,
                  onMedicationSelected: _showMedicationDetails,
                ),
                
                // AI Öneriler Tab'ı
                AIPrescriptionWidget(
                  onSuggestionGenerated: _loadData,
                ),
                
                // İstatistikler Tab'ı
                PrescriptionStatisticsWidget(
                  statistics: _statistics,
                  prescriptions: _prescriptions,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPrescriptionDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Reçete'),
      ),
    );
  }

  void _showAddPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Reçete'),
        content: const Text('Bu özellik yakında gelecek. Şimdilik demo veriler kullanılıyor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showMedicationDetails(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medication.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kategori: ${medication.categoryText}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Form: ${medication.dosageForm.name}'),
              const SizedBox(height: 8),
              Text('Mevcut Dozlar: ${medication.availableDosages.join(', ')}'),
              const SizedBox(height: 16),
              Text(
                'Açıklama:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(medication.description),
              const SizedBox(height: 16),
              Text(
                'Endikasyonlar:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...medication.indications.map((indication) => 
                Text('• $indication')
              ),
              const SizedBox(height: 16),
              Text(
                'Yan Etkiler:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...medication.sideEffects.map((effect) => 
                Text('• $effect')
              ),
              const SizedBox(height: 16),
              Text(
                'Uyarılar:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...medication.warnings.map((warning) => 
                Text('• $warning')
              ),
            ],
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
}
