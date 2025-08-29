import 'package:flutter/material.dart';
import '../../models/case_models.dart';
import '../../services/case_service.dart';
import '../../widgets/case/case_list_widget.dart';
import '../../widgets/case/case_details_widget.dart';
import '../../widgets/case/case_progress_widget.dart';
import '../../widgets/case/case_goals_widget.dart';
import '../../widgets/case/case_interventions_widget.dart';
import '../../widgets/case/add_case_dialog.dart';
import '../../widgets/case/add_progress_dialog.dart';
import '../../widgets/case/add_goal_dialog.dart';
import '../../widgets/case/add_intervention_dialog.dart';
import '../../utils/app_theme.dart';

class CaseManagementScreen extends StatefulWidget {
  const CaseManagementScreen({super.key});

  @override
  State<CaseManagementScreen> createState() => _CaseManagementScreenState();
}

class _CaseManagementScreenState extends State<CaseManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CaseService _caseService = CaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Case> _allCases = [];
  List<Case> _filteredCases = [];
  Case? _selectedCase;
  String _searchQuery = '';
  CaseStatus? _selectedStatus;
  CasePriority? _selectedPriority;
  CaseType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _caseService.initialize();
    _loadCases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadCases() {
    setState(() {
      _allCases = _caseService.getAllCases();
      _filteredCases = _allCases;
    });
  }

  void _filterCases() {
    setState(() {
      _filteredCases = _caseService.filterCases(
        status: _selectedStatus,
        priority: _selectedPriority,
        type: _selectedType,
      );

      if (_searchQuery.isNotEmpty) {
        _filteredCases = _filteredCases.where((case_) {
          return case_.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 case_.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 case_.diagnosis?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
        }).toList();
      }
    });
  }

  void _onCaseSelected(Case selectedCase) {
    setState(() {
      _selectedCase = selectedCase;
    });
  }

  void _refreshData() {
    _loadCases();
    _filterCases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaka Yönetimi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vakalar', icon: Icon(Icons.folder)),
            Tab(text: 'Detaylar', icon: Icon(Icons.info)),
            Tab(text: 'İlerleme', icon: Icon(Icons.trending_up)),
            Tab(text: 'Hedefler', icon: Icon(Icons.flag)),
            Tab(text: 'Müdahaleler', icon: Icon(Icons.medical_services)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // Arama ve filtre çubuğu
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Arama çubuğu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Vaka ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _filterCases();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterCases();
                  },
                ),
                const SizedBox(height: 12),
                // Aktif filtreler
                if (_selectedStatus != null || _selectedPriority != null || _selectedType != null)
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_selectedStatus != null)
                        _buildFilterChip(
                          '${_selectedStatus!.name}',
                          () {
                            setState(() {
                              _selectedStatus = null;
                            });
                            _filterCases();
                          },
                        ),
                      if (_selectedPriority != null)
                        _buildFilterChip(
                          '${_selectedPriority!.name}',
                          () {
                            setState(() {
                              _selectedPriority = null;
                            });
                            _filterCases();
                          },
                        ),
                      if (_selectedType != null)
                        _buildFilterChip(
                          '${_selectedType!.name}',
                          () {
                            setState(() {
                              _selectedType = null;
                            });
                            _filterCases();
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
          // Tab içerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Vakalar tab'ı
                CaseListWidget(
                  cases: _filteredCases,
                  onCaseSelected: _onCaseSelected,
                  selectedCase: _selectedCase,
                  onRefresh: _refreshData,
                ),
                // Detaylar tab'ı
                _selectedCase != null
                    ? CaseDetailsWidget(
                        case_: _selectedCase!,
                        onCaseUpdated: _refreshData,
                      )
                    : const Center(
                        child: Text('Detayları görüntülemek için bir vaka seçin'),
                      ),
                // İlerleme tab'ı
                _selectedCase != null
                    ? CaseProgressWidget(
                        case_: _selectedCase!,
                        onProgressAdded: _refreshData,
                      )
                    : const Center(
                        child: Text('İlerleme kayıtlarını görüntülemek için bir vaka seçin'),
                      ),
                // Hedefler tab'ı
                _selectedCase != null
                    ? CaseGoalsWidget(
                        case_: _selectedCase!,
                        onGoalAdded: _refreshData,
                        onGoalUpdated: _refreshData,
                      )
                    : const Center(
                        child: Text('Hedefleri görüntülemek için bir vaka seçin'),
                      ),
                // Müdahaleler tab'ı
                _selectedCase != null
                    ? CaseInterventionsWidget(
                        case_: _selectedCase!,
                        onInterventionAdded: _refreshData,
                      )
                    : const Center(
                        child: Text('Müdahaleleri görüntülemek için bir vaka seçin'),
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCaseDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Vaka'),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemoved) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemoved,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: AppTheme.primaryColor),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaka Filtreleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Durum filtresi
            DropdownButtonFormField<CaseStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Durum',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...CaseStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Öncelik filtresi
            DropdownButtonFormField<CasePriority?>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Öncelik',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...CasePriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Tip filtresi
            DropdownButtonFormField<CaseType?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tip',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...CaseType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedPriority = null;
                _selectedType = null;
              });
              _filterCases();
              Navigator.of(context).pop();
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _filterCases();
              Navigator.of(context).pop();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _showAddCaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCaseDialog(
        onCaseAdded: (newCase) {
          _refreshData();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
