import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/medication_guide_model.dart';
import '../../widgets/medication_guide/medication_search_panel.dart';
import '../../widgets/medication_guide/medication_details_panel.dart';
import '../../widgets/medication_guide/interaction_checker_panel.dart';
import '../../widgets/medication_guide/patient_guide_panel.dart';
import '../../widgets/medication_guide/treatment_protocol_panel.dart';

class MedicationGuideScreen extends StatefulWidget {
  const MedicationGuideScreen({super.key});

  @override
  State<MedicationGuideScreen> createState() => _MedicationGuideScreenState();
}

class _MedicationGuideScreenState extends State<MedicationGuideScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<MedicationModel> _allMedications = [];
  MedicationModel? _selectedMedication;
  List<MedicationModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDemoMedications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoMedications() {
    setState(() {
      _allMedications = [
        // Antidepresanlar
        MedicationModel(
          id: '1',
          name: 'Escitalopram',
          genericName: 'Escitalopram oxalate',
          brandNames: ['Lexapro', 'Cipralex', 'Esertia'],
          internationalNames: ['Escitalopram', 'Escitalopramum'],
          category: MedicationCategory.antidepressant,
          subcategory: 'SSRI',
          indications: [
            'Major Depressive Disorder',
            'Generalized Anxiety Disorder',
            'Panic Disorder'
          ],
          offLabelIndications: [
            'Premenstrual Dysphoric Disorder',
            'Social Anxiety Disorder'
          ],
          dosage: '10-20mg daily',
          administration: 'Oral, with or without food',
          mechanism: 'Selective serotonin reuptake inhibitor (SSRI)',
          sideEffects: [
            'Mide bulantısı',
            'Uyku bozukluğu',
            'Cinsel işlev bozukluğu',
            'Baş ağrısı',
            'Terleme'
          ],
          seriousSideEffects: [
            'Serotonin sendromu',
            'Suicidal thoughts',
            'Bleeding risk',
            'Hyponatremia'
          ],
          contraindications: [
            'MAOI kullanımı (14 gün ara)',
            'Serotonin sendromu riski',
            'Gebelik (C kategorisi)',
            'Emzirme dönemi'
          ],
          interactions: [
            'MAOI: Serotonin sendromu riski',
            'NSAID: Kanama riski artışı',
            'Warfarin: INR artışı',
            'St. John\'s Wort: Etki azalması'
          ],
          warnings: [
            '18 yaş altında intihar düşüncesi artabilir',
            'Aniden kesmeyin, dozu kademeli azaltın',
            'Serotonin sendromu belirtilerini izleyin'
          ],
          precautions: [
            'Liver function monitoring',
            'Renal function monitoring',
            'Bleeding risk assessment'
          ],
          pregnancyCategory: 'C',
          lactationCategory: 'L3',
          pediatricUse: 'Limited data, monitor closely',
          geriatricUse: 'Start with lower dose',
          hepaticImpairment: 'Use with caution',
          renalImpairment: 'No dose adjustment needed',
          halfLife: '27-32 saat',
          metabolism: 'CYP2C19, CYP3A4',
          excretion: 'Renal (8-10%)',
          approvalStatus: {
            'FDA': 'Approved',
            'EMA': 'Approved',
            'TİTCK': 'Approved',
          },
          approvalDates: {
            'FDA': DateTime(2002, 8, 14),
            'EMA': DateTime(2001, 3, 15),
            'TİTCK': DateTime(2003, 1, 20),
          },
          regulatoryStatus: {
            'FDA': 'Active',
            'EMA': 'Active',
            'TİTCK': 'Active',
          },
          cost: 'Orta',
          availability: 'Yaygın',
          alternatives: ['Sertraline', 'Fluoxetine', 'Paroxetine'],
          combinationProducts: ['Escitalopram + Bupropion'],
          clinicalData: {
            'efficacy': 'High',
            'safety': 'Good',
            'tolerability': 'Moderate'
          },
          clinicalTrials: [],
          publications: [],
          guidelines: {
            'APA': 'First-line treatment for MDD',
            'NICE': 'Recommended for GAD'
          },
          notes: 'Well-tolerated SSRI with good efficacy',
          dataSource: 'FDA, EMA, TİTCK databases',
          evidenceQuality: 'A',
        ),
      ];
    });
  }

  void _onMedicationSelected(MedicationModel medication) {
    setState(() {
      _selectedMedication = medication;
    });
    _tabController.animateTo(1); // Details tab'ına geç
  }

  void _onSearchPerformed(String query, List<MedicationModel> results) {
    setState(() {
      _searchResults = results;
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlaç Rehberi'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'İlaç Arama'),
            Tab(icon: Icon(Icons.medication), text: 'İlaç Detayları'),
            Tab(icon: Icon(Icons.warning), text: 'Etkileşim Kontrolü'),
            Tab(icon: Icon(Icons.description), text: 'Danışan Rehberi'),
            Tab(
                icon: Icon(Icons.medical_services),
                text: 'Tedavi Protokolleri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: İlaç Arama
          MedicationSearchPanel(
            allMedications: _allMedications,
            searchResults: _searchResults,
            isSearching: _isSearching,
            onMedicationSelected: _onMedicationSelected,
            onSearchPerformed: _onSearchPerformed,
          ),

          // Tab 2: İlaç Detayları
          if (_selectedMedication != null)
            MedicationDetailsPanel(
              medication: _selectedMedication!,
            )
          else
            const Center(
              child: Text('Lütfen bir ilaç seçin'),
            ),

          // Tab 3: Etkileşim Kontrolü
          InteractionCheckerPanel(
            allMedications: _allMedications,
          ),

          // Tab 4: Danışan Rehberi
          PatientGuidePanel(
            selectedMedication: _selectedMedication,
          ),

          // Tab 5: Tedavi Protokolleri
          TreatmentProtocolPanel(
            selectedMedication: _selectedMedication,
          ),
        ],
      ),
    );
  }
}
