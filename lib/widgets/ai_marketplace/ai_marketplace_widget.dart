import 'package:flutter/material.dart';
import 'package:psyclinicai/services/ai_model_marketplace_service.dart';

/// AI Model Marketplace Widget for PsyClinicAI
class AIMarketplaceWidget extends StatefulWidget {
  const AIMarketplaceWidget({Key? key}) : super(key: key);

  @override
  State<AIMarketplaceWidget> createState() => _AIMarketplaceWidgetState();
}

class _AIMarketplaceWidgetState extends State<AIMarketplaceWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Service
  final AIModelMarketplaceService _marketplaceService = AIModelMarketplaceService();
  
  // State variables
  bool _isLoading = false;
  List<MarketplaceModel> _availableModels = [];
  List<InstalledModel> _installedModels = [];
  List<ModelProvider> _providers = [];
  List<MarketplaceModel> _filteredModels = [];
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  ModelCategory? _selectedCategory;
  String? _selectedProvider;
  String? _selectedSpecialty;
  double? _maxPrice;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeMarketplace();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize marketplace
  Future<void> _initializeMarketplace() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _marketplaceService.initialize();
      
      _availableModels = _marketplaceService.getAvailableModels();
      _installedModels = _marketplaceService.getInstalledModels();
      _providers = _marketplaceService.getProviders();
      _filteredModels = List.from(_availableModels);
      
      print('✅ AI Marketplace initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize AI Marketplace: $e');
      _showErrorSnackBar('Failed to initialize marketplace: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏪 AI Model Marketplace'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'Browse'),
            Tab(icon: Icon(Icons.download), text: 'Installed'),
            Tab(icon: Icon(Icons.business), text: 'Providers'),
            Tab(icon: Icon(Icons.analytics), text: 'Compare'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(),
                _buildInstalledTab(),
                _buildProvidersTab(),
                _buildCompareTab(),
              ],
            ),
    );
  }

  /// Browse Tab
  Widget _buildBrowseTab() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _filteredModels.isEmpty
              ? _buildNoModelsView()
              : _buildModelsList(),
        ),
      ],
    );
  }

  /// Search and Filters
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search AI models...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 16),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Category',
                  value: _selectedCategory?.name.replaceAll('_', ' ').toUpperCase(),
                  onTap: _showCategoryFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Provider',
                  value: _selectedProvider,
                  onTap: _showProviderFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Specialty',
                  value: _selectedSpecialty?.replaceAll('_', ' ').toUpperCase(),
                  onTap: _showSpecialtyFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Price',
                  value: _maxPrice != null ? '\$${_maxPrice!.toStringAsFixed(2)}' : null,
                  onTap: _showPriceFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Rating',
                  value: _minRating != null ? '${_minRating!.toStringAsFixed(1)}+' : null,
                  onTap: _showRatingFilter,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Filter Chip
  Widget _buildFilterChip({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: value != null ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: value != null ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Models List
  Widget _buildModelsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredModels.length,
      itemBuilder: (context, index) {
        final model = _filteredModels[index];
        return _buildModelCard(model);
      },
    );
  }

  /// Model Card
  Widget _buildModelCard(MarketplaceModel model) {
    final isInstalled = _installedModels.any((m) => m.id == model.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(model.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(model.category),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'by ${model.provider}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          model.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${model.price.toStringAsFixed(2)}/${model.priceUnit}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              model.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Specialties
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: model.specialties.map((specialty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    specialty.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Performance metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Accuracy', '${(model.performance.accuracy * 100).toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildMetricItem('Latency', '${model.performance.latency}s'),
                ),
                Expanded(
                  child: _buildMetricItem('Throughput', '${model.performance.throughput}/min'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                if (!isInstalled) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _installModel(model),
                      icon: const Icon(Icons.download),
                      label: const Text('Install'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _uninstallModel(model.id),
                      icon: const Icon(Icons.delete),
                      label: const Text('Uninstall'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewModelDetails(model),
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _testModel(model),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Metric Item
  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Installed Tab
  Widget _buildInstalledTab() {
    if (_installedModels.isEmpty) {
      return _buildNoInstalledModelsView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _installedModels.length,
      itemBuilder: (context, index) {
        final model = _installedModels[index];
        return _buildInstalledModelCard(model);
      },
    );
  }

  /// Installed Model Card
  Widget _buildInstalledModelCard(InstalledModel model) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${model.version}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(model.status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInstalledMetric('Provider', model.provider),
                ),
                Expanded(
                  child: _buildInstalledMetric('Installed', _formatDate(model.installedAt)),
                ),
                Expanded(
                  child: _buildInstalledMetric('Updated', _formatDate(model.lastUpdated)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateModel(model.id),
                    icon: const Icon(Icons.update),
                    label: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _configureModel(model),
                    icon: const Icon(Icons.settings),
                    label: const Text('Configure'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _uninstallModel(model.id),
                    icon: const Icon(Icons.delete),
                    label: const Text('Uninstall'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
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

  /// Installed Metric
  Widget _buildInstalledMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Providers Tab
  Widget _buildProvidersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final provider = _providers[index];
        return _buildProviderCard(provider);
      },
    );
  }

  /// Provider Card
  Widget _buildProviderCard(ModelProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.blue[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (provider.verified) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        provider.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          provider.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.modelsCount} models',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Specialties
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.specialties.map((specialty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    specialty.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () => _viewProviderModels(provider),
              child: Text('View ${provider.name} Models'),
            ),
          ],
        ),
      ),
    );
  }

  /// Compare Tab
  Widget _buildCompareTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Model Comparison',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select up to 3 models to compare their performance, features, and pricing.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Model selection
          _buildModelSelection(),
          const SizedBox(height: 24),
          
          // Comparison button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _selectedModelsForComparison.length >= 2 ? _compareModels : null,
              icon: const Icon(Icons.compare_arrows),
              label: Text('Compare ${_selectedModelsForComparison.length} Models'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Comparison results
          if (_comparisonResult != null) _buildComparisonResults(),
        ],
      ),
    );
  }

  // Comparison state
  final Set<String> _selectedModelsForComparison = {};
  ModelPerformanceComparison? _comparisonResult;

  /// Model Selection
  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Models:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableModels.map((model) {
            final isSelected = _selectedModelsForComparison.contains(model.id);
            return FilterChip(
              label: Text(model.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected && _selectedModelsForComparison.length < 3) {
                    _selectedModelsForComparison.add(model.id);
                  } else if (!selected) {
                    _selectedModelsForComparison.remove(model.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Comparison Results
  Widget _buildComparisonResults() {
    if (_comparisonResult == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Comparison Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Winner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Winner',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          _getModelName(_comparisonResult!.winner),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Insights
            const Text(
              'Key Insights:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._comparisonResult!.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(insight)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Helper Methods
  Color _getCategoryColor(ModelCategory category) {
    switch (category) {
      case ModelCategory.diagnosis:
        return Colors.blue;
      case ModelCategory.treatment:
        return Colors.green;
      case ModelCategory.riskAssessment:
        return Colors.orange;
      case ModelCategory.prognosis:
        return Colors.purple;
      case ModelCategory.screening:
        return Colors.teal;
      case ModelCategory.monitoring:
        return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(ModelCategory category) {
    switch (category) {
      case ModelCategory.diagnosis:
        return Icons.medical_services;
      case ModelCategory.treatment:
        return Icons.healing;
      case ModelCategory.riskAssessment:
        return Icons.warning;
      case ModelCategory.prognosis:
        return Icons.timeline;
      case ModelCategory.screening:
        return Icons.filter_list;
      case ModelCategory.monitoring:
        return Icons.monitor_heart;
    }
  }

  Widget _buildStatusChip(ModelInstallStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case ModelInstallStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case ModelInstallStatus.inactive:
        color = Colors.grey;
        text = 'Inactive';
        break;
      case ModelInstallStatus.updating:
        color = Colors.blue;
        text = 'Updating';
        break;
      case ModelInstallStatus.error:
        color = Colors.red;
        text = 'Error';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getModelName(String modelId) {
    try {
      return _availableModels.firstWhere((m) => m.id == modelId).name;
    } catch (e) {
      return modelId;
    }
  }

  /// Search and Filter Methods
  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _clearSearch() {
    _searchController.clear();
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedProvider = null;
      _selectedSpecialty = null;
      _maxPrice = null;
      _minRating = null;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredModels = _marketplaceService.searchModels(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        category: _selectedCategory,
        specialty: _selectedSpecialty,
        provider: _selectedProvider,
        minRating: _minRating,
        maxPrice: _maxPrice,
      );
    });
  }

  /// Filter Dialogs
  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ModelCategory.values.map((category) {
            return ListTile(
              title: Text(category.name.replaceAll('_', ' ').toUpperCase()),
              trailing: _selectedCategory == category ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _selectedCategory = _selectedCategory == category ? null : category;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showProviderFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _providers.map((provider) {
            return ListTile(
              title: Text(provider.name),
              trailing: _selectedProvider == provider.id ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _selectedProvider = _selectedProvider == provider.id ? null : provider.id;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSpecialtyFilter() {
    final allSpecialties = <String>{};
    for (final model in _availableModels) {
      allSpecialties.addAll(model.specialties);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Specialty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: allSpecialties.map((specialty) {
            return ListTile(
              title: Text(specialty.replaceAll('_', ' ').toUpperCase()),
              trailing: _selectedSpecialty == specialty ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _selectedSpecialty = _selectedSpecialty == specialty ? null : specialty;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPriceFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Maximum Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Maximum Price',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _maxPrice = double.tryParse(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showRatingFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Minimum Rating'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Minimum Rating',
                suffixText: '+',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _minRating = double.tryParse(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  /// Action Methods
  Future<void> _installModel(MarketplaceModel model) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _marketplaceService.installModel(model.id);
      
      // Refresh installed models
      _installedModels = _marketplaceService.getInstalledModels();
      
      _showSuccessSnackBar('${model.name} installed successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to install model: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uninstallModel(String modelId) async {
    try {
      await _marketplaceService.uninstallModel(modelId);
      
      // Refresh installed models
      _installedModels = _marketplaceService.getInstalledModels();
      
      _showSuccessSnackBar('Model uninstalled successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to uninstall model: $e');
    }
  }

  Future<void> _updateModel(String modelId) async {
    try {
      await _marketplaceService.updateModel(modelId);
      
      // Refresh installed models
      _installedModels = _marketplaceService.getInstalledModels();
      
      _showSuccessSnackBar('Model updated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to update model: $e');
    }
  }

  void _viewModelDetails(MarketplaceModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Provider: ${model.provider}'),
              Text('Version: ${model.version}'),
              Text('Category: ${model.category.name.replaceAll('_', ' ').toUpperCase()}'),
              Text('Price: \$${model.price.toStringAsFixed(2)}/${model.priceUnit}'),
              Text('Rating: ${model.rating}/5.0'),
              const SizedBox(height: 16),
              const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...model.features.map((f) => Text('• $f')),
              const SizedBox(height: 16),
              const Text('Documentation:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(model.documentation),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _testModel(MarketplaceModel model) async {
    try {
      final result = await _marketplaceService.testModel(model.id, {
        'test_type': 'sample',
        'data_size': 'small',
      });
      
      _showSuccessSnackBar('Model test completed successfully!');
    } catch (e) {
      _showErrorSnackBar('Model test failed: $e');
    }
  }

  void _configureModel(InstalledModel model) {
    _showInfoSnackBar('Configuration feature coming soon!');
  }

  void _viewProviderModels(ModelProvider provider) {
    setState(() {
      _selectedProvider = provider.id;
    });
    _applyFilters();
    _tabController.animateTo(0); // Switch to browse tab
  }

  Future<void> _compareModels() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final comparison = await _marketplaceService.compareModels(
        _selectedModelsForComparison.toList(),
      );
      
      setState(() {
        _comparisonResult = comparison;
      });
      
      _showSuccessSnackBar('Model comparison completed!');
    } catch (e) {
      _showErrorSnackBar('Model comparison failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// No Data Views
  Widget _buildNoModelsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No models found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search criteria or filters',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoInstalledModelsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No models installed',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse the marketplace to find and install AI models',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Snackbar Methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
