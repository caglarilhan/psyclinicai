import 'package:flutter/material.dart';
import '../../models/crm_models.dart';
import '../../utils/theme.dart';

class SalesPipelineWidget extends StatefulWidget {
  final List<SalesOpportunity> opportunities;
  final VoidCallback onOpportunityUpdated;

  const SalesPipelineWidget({
    super.key,
    required this.opportunities,
    required this.onOpportunityUpdated,
  });

  @override
  State<SalesPipelineWidget> createState() => _SalesPipelineWidgetState();
}

class _SalesPipelineWidgetState extends State<SalesPipelineWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedAssignee = 'all';

  List<String> get _assignees {
    final assignees = widget.opportunities.map((o) => o.assignedTo).toSet().toList();
    assignees.sort();
    return ['all', ...assignees];
  }

  List<SalesOpportunity> get _filteredOpportunities {
    List<SalesOpportunity> filtered = List.from(widget.opportunities);

    // Arama filtreleme
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((o) =>
        o.title.toLowerCase().contains(query) ||
        o.customerName.toLowerCase().contains(query) ||
        o.description.toLowerCase().contains(query) ||
        o.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    // Atanan kişi filtreleme
    if (_selectedAssignee != 'all') {
      filtered = filtered.where((o) => o.assignedTo == _selectedAssignee).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header ve Kontroller
          _buildHeader(),
          
          const SizedBox(height: 16),
          
          // Filtreler
          _buildFilters(),
          
          const SizedBox(height: 16),
          
          // Pipeline Board
          Expanded(
            child: _buildPipelineBoard(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Satış Pipeline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: _showAddOpportunityDialog,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white),
          tooltip: 'Yeni Fırsat Ekle',
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Arama
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Fırsat ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Atanan Kişi Filtresi
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedAssignee,
              decoration: const InputDecoration(
                labelText: 'Atanan Kişi',
                border: OutlineInputBorder(),
              ),
              items: _assignees.map((assignee) => DropdownMenuItem(
                value: assignee,
                child: Text(assignee == 'all' ? 'Tümü' : assignee),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAssignee = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineBoard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lead Aşaması
        Expanded(
          child: _buildPipelineColumn(
            'Lead',
            SalesStatus.lead,
            Colors.grey,
            Icons.person_add,
          ),
        ),
        
        // Qualified Aşaması
        Expanded(
          child: _buildPipelineColumn(
            'Qualified',
            SalesStatus.qualified,
            Colors.blue,
            Icons.check_circle,
          ),
        ),
        
        // Proposal Aşaması
        Expanded(
          child: _buildPipelineColumn(
            'Proposal',
            SalesStatus.proposal,
            Colors.orange,
            Icons.description,
          ),
        ),
        
        // Negotiation Aşaması
        Expanded(
          child: _buildPipelineColumn(
            'Negotiation',
            SalesStatus.negotiation,
            Colors.purple,
            Icons.handshake,
          ),
        ),
        
        // Closed Aşaması
        Expanded(
          child: _buildPipelineColumn(
            'Closed',
            SalesStatus.closed,
            Colors.green,
            Icons.check,
          ),
        ),
        
        // Lost Aşaması
        Expanded(
          child: _buildPipelineColumn(
            'Lost',
            SalesStatus.lost,
            Colors.red,
            Icons.close,
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineColumn(
    String title,
    SalesStatus status,
    Color color,
    IconData icon,
  ) {
    final opportunitiesInStage = _filteredOpportunities
        .where((o) => o.status == status)
        .toList();
    
    final totalValue = opportunitiesInStage.fold<double>(
      0.0, (sum, o) => sum + o.value);
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${opportunitiesInStage.length}',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Total Value
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '₺${totalValue.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Opportunities
          Expanded(
            child: opportunitiesInStage.isEmpty
                ? _buildEmptyColumn()
                : ListView.builder(
                    itemCount: opportunitiesInStage.length,
                    itemBuilder: (context, index) {
                      final opportunity = opportunitiesInStage[index];
                      return _buildOpportunityCard(opportunity);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumn() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          'Fırsat yok',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(SalesOpportunity opportunity) {
    final daysUntilClose = opportunity.expectedCloseDate
        .difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title ve Value
          Row(
            children: [
              Expanded(
                child: Text(
                  opportunity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₺${opportunity.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Customer Name
          Text(
            opportunity.customerName,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Probability ve Close Date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(opportunity.probability * 100).toInt()}%',
                  style: TextStyle(
                    color: AppTheme.infoColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: daysUntilClose < 7 
                      ? Colors.red.withOpacity(0.1)
                      : daysUntilClose < 30 
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  daysUntilClose < 0 
                      ? 'Gecikmiş'
                      : '$daysUntilClose gün',
                  style: TextStyle(
                    color: daysUntilClose < 7 
                        ? Colors.red
                        : daysUntilClose < 30 
                            ? Colors.orange
                            : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Tags
          if (opportunity.tags.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: opportunity.tags.take(2).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              )).toList(),
            ),
          
          const SizedBox(height: 8),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _showOpportunityDetails(opportunity),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Detaylar',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showEditOpportunityDialog(opportunity),
                icon: const Icon(Icons.edit, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Düzenle',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddOpportunityDialog() {
    // TODO: Fırsat ekleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fırsat ekleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showEditOpportunityDialog(SalesOpportunity opportunity) {
    // TODO: Fırsat düzenleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fırsat düzenleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showOpportunityDetails(SalesOpportunity opportunity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fırsat Detayları: ${opportunity.title}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Başlık', opportunity.title),
              _buildDetailRow('Müşteri', opportunity.customerName),
              _buildDetailRow('Açıklama', opportunity.description),
              _buildDetailRow('Durum', _getStatusText(opportunity.status)),
              _buildDetailRow('Değer', '₺${opportunity.value.toStringAsFixed(0)}'),
              _buildDetailRow('Olasılık', '${(opportunity.probability * 100).toInt()}%'),
              _buildDetailRow('Beklenen Kapanış', _formatDate(opportunity.expectedCloseDate)),
              _buildDetailRow('Oluşturulma', _formatDate(opportunity.createdAt)),
              _buildDetailRow('Son Güncelleme', _formatDate(opportunity.lastUpdated)),
              _buildDetailRow('Atanan', opportunity.assignedTo),
              if (opportunity.tags.isNotEmpty)
                _buildDetailRow('Etiketler', opportunity.tags.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditOpportunityDialog(opportunity);
            },
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(SalesStatus status) {
    switch (status) {
      case SalesStatus.lead:
        return 'Lead';
      case SalesStatus.qualified:
        return 'Qualified';
      case SalesStatus.proposal:
        return 'Proposal';
      case SalesStatus.negotiation:
        return 'Negotiation';
      case SalesStatus.closed:
        return 'Closed';
      case SalesStatus.lost:
        return 'Lost';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
