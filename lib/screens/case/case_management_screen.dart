import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/case_models.dart';
import '../../services/case_service.dart';
import '../../widgets/case/case_list_widget.dart';
// import '../../widgets/case/case_details_widget.dart';
// import '../../widgets/case/case_progress_widget.dart';
// import '../../widgets/case/case_goals_widget.dart';
// import '../../widgets/case/case_interventions_widget.dart';
// import '../../widgets/case/add_case_dialog.dart';
// import '../../widgets/case/add_progress_dialog.dart';
// import '../../widgets/case/add_goal_dialog.dart';
// import '../../widgets/case/add_intervention_dialog.dart';
import '../../utils/theme.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

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
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  
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
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _removeKeyboardShortcuts();
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
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'Vaka Yönetimi',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Yeni Vaka',
          onPressed: _showAddCaseDialog,
          icon: Icons.add,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Yenile',
          onPressed: _refreshData,
          icon: Icons.refresh,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Filtrele',
          onPressed: _showFilterDialog,
          icon: Icons.filter_list,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Rapor',
          onPressed: _generateCaseReport,
          icon: Icons.assessment,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Vaka Listesi',
          icon: Icons.list,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Vaka Detayları',
          icon: Icons.description,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'İlerleme',
          icon: Icons.trending_up,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Hedefler',
          icon: Icons.flag,
          onTap: () => _tabController.animateTo(3),
        ),
        DesktopSidebarItem(
          title: 'Müdahaleler',
          icon: Icons.medical_services,
          onTap: () => _tabController.animateTo(4),
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return Column(
      children: [
        // Arama çubuğu
        DesktopTheme.desktopCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DesktopTheme.desktopInput(
                    label: 'Arama',
                    controller: _searchController,
                    hintText: 'Vaka ara...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterCases();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                if (_searchQuery.isNotEmpty)
                  DesktopTheme.desktopButton(
                    text: 'Temizle',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _filterCases();
                    },
                    icon: Icons.clear,
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDesktopCaseListTab(),
              _buildDesktopCaseDetailsTab(),
              _buildDesktopCaseProgressTab(),
              _buildDesktopCaseGoalsTab(),
              _buildDesktopCaseInterventionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
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

  // Masaüstü kısayol metodları
  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      _showAddCaseDialog,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _refreshData,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      _showFilterDialog,
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyP, LogicalKeyboardKey.control),
      _generateCaseReport,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyP, LogicalKeyboardKey.control),
    );
  }

  // Masaüstü tab metodları
  Widget _buildDesktopCaseListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vaka Listesi',
                style: DesktopTheme.desktopSectionTitleStyle,
              ),
              DesktopTheme.desktopButton(
                text: 'Yeni Vaka',
                onPressed: _showAddCaseDialog,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CaseListWidget(
            cases: _filteredCases,
            onCaseSelected: _onCaseSelected,
            selectedCase: _selectedCase,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCaseDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vaka Detayları',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_selectedCase != null)
            CaseDetailsWidget(
              case_: _selectedCase!,
              onCaseUpdated: _refreshData,
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Detayları görüntülemek için bir vaka seçin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopCaseProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vaka İlerlemesi',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_selectedCase != null)
            CaseProgressWidget(
              case_: _selectedCase!,
              onProgressAdded: _refreshData,
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.trending_up, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'İlerleme kayıtlarını görüntülemek için bir vaka seçin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopCaseGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vaka Hedefleri',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_selectedCase != null)
            CaseGoalsWidget(
              case_: _selectedCase!,
              onGoalAdded: _refreshData,
              onGoalUpdated: _refreshData,
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.flag, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Hedefleri görüntülemek için bir vaka seçin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopCaseInterventionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vaka Müdahaleleri',
            style: DesktopTheme.desktopSectionTitleStyle,
          ),
          const SizedBox(height: 16),
          if (_selectedCase != null)
            CaseInterventionsWidget(
              case_: _selectedCase!,
              onInterventionAdded: _refreshData,
            )
          else
            DesktopTheme.desktopCard(
              child: const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.medical_services, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Müdahaleleri görüntülemek için bir vaka seçin',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _generateCaseReport() {
    // TODO: Vaka raporu oluşturma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vaka raporu oluşturuluyor...')),
    );
  }
}
