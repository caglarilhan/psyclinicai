import 'package:flutter/material.dart';
import '../../models/crm_models.dart';
import '../../utils/theme.dart';

class CustomerListWidget extends StatefulWidget {
  final List<Customer> customers;
  final VoidCallback onCustomerUpdated;

  const CustomerListWidget({
    super.key,
    required this.customers,
    required this.onCustomerUpdated,
  });

  @override
  State<CustomerListWidget> createState() => _CustomerListWidgetState();
}

class _CustomerListWidgetState extends State<CustomerListWidget> {
  final TextEditingController _searchController = TextEditingController();
  CustomerType? _selectedType;
  String _sortBy = 'name';
  bool _sortAscending = true;

  List<Customer> get _filteredCustomers {
    List<Customer> filtered = List.from(widget.customers);

    // Tip filtreleme
    if (_selectedType != null) {
      filtered = filtered.where((c) => c.type == _selectedType).toList();
    }

    // Arama filtreleme
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) =>
        c.name.toLowerCase().contains(query) ||
        c.email.toLowerCase().contains(query) ||
        c.company.toLowerCase().contains(query) ||
        c.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.toString().compareTo(b.type.toString());
          break;
        case 'value':
          comparison = a.lifetimeValue.compareTo(b.lifetimeValue);
          break;
        case 'lastContact':
          comparison = a.lastContact.compareTo(b.lastContact);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

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
          
          // Müşteri Listesi
          Expanded(
            child: _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : _buildCustomerList(),
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
            'Müşteri Listesi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: _showAddCustomerDialog,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
          tooltip: 'Yeni Müşteri Ekle',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtreler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Arama
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Müşteri ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Tip Filtresi
              Expanded(
                child: DropdownButtonFormField<CustomerType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Müşteri Tipi',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tümü'),
                    ),
                    ...CustomerType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_getCustomerTypeText(type)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Sıralama
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    labelText: 'Sırala',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('İsim')),
                    DropdownMenuItem(value: 'type', child: Text('Tip')),
                    DropdownMenuItem(value: 'value', child: Text('Değer')),
                    DropdownMenuItem(value: 'lastContact', child: Text('Son İletişim')),
                    DropdownMenuItem(value: 'createdAt', child: Text('Oluşturulma')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Sıralama Yönü
              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                style: IconButton.styleFrom(backgroundColor: AppTheme.infoColor.withOpacity(0.1)),
                tooltip: _sortAscending ? 'Azalan' : 'Artan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getCustomerTypeColor(customer.type),
          child: Text(
            customer.name[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (customer.lifetimeValue > 10000)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (customer.company.isNotEmpty) ...[
              Text(
                '${customer.company} - ${customer.position}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              customer.email,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              customer.phone,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCustomerTypeColor(customer.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCustomerTypeText(customer.type),
                    style: TextStyle(
                      color: _getCustomerTypeColor(customer.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₺${customer.lifetimeValue.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (customer.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: customer.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
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
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Görüntüle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCustomerDialog(customer);
                break;
              case 'view':
                _showCustomerDetails(customer);
                break;
              case 'delete':
                _showDeleteCustomerDialog(customer);
                break;
            }
          },
        ),
        onTap: () => _showCustomerDetails(customer),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Müşteri bulunamadı',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arama kriterlerinizi değiştirin veya yeni müşteri ekleyin',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddCustomerDialog,
            icon: const Icon(Icons.add),
            label: const Text('Yeni Müşteri Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCustomerTypeColor(CustomerType type) {
    switch (type) {
      case CustomerType.individual:
        return AppTheme.primaryColor;
      case CustomerType.business:
        return AppTheme.accentColor;
      case CustomerType.healthcare:
        return AppTheme.successColor;
      case CustomerType.education:
        return AppTheme.infoColor;
      case CustomerType.government:
        return AppTheme.warningColor;
    }
  }

  String _getCustomerTypeText(CustomerType type) {
    switch (type) {
      case CustomerType.individual:
        return 'Bireysel';
      case CustomerType.business:
        return 'İş';
      case CustomerType.healthcare:
        return 'Sağlık';
      case CustomerType.education:
        return 'Eğitim';
      case CustomerType.government:
        return 'Devlet';
    }
  }

  void _showAddCustomerDialog() {
    // TODO: Müşteri ekleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Müşteri ekleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    // TODO: Müşteri düzenleme dialog'u
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Müşteri düzenleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showCustomerDetails(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Müşteri Detayları: ${customer.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('İsim', customer.name),
              _buildDetailRow('E-posta', customer.email),
              _buildDetailRow('Telefon', customer.phone),
              _buildDetailRow('Tip', _getCustomerTypeText(customer.type)),
              if (customer.company.isNotEmpty)
                _buildDetailRow('Şirket', customer.company),
              if (customer.position.isNotEmpty)
                _buildDetailRow('Pozisyon', customer.position),
              if (customer.address.isNotEmpty)
                _buildDetailRow('Adres', customer.address),
              _buildDetailRow('Oluşturulma', _formatDate(customer.createdAt)),
              _buildDetailRow('Son İletişim', _formatDate(customer.lastContact)),
              _buildDetailRow('Lifetime Değer', '₺${customer.lifetimeValue.toStringAsFixed(0)}'),
              if (customer.tags.isNotEmpty)
                _buildDetailRow('Etiketler', customer.tags.join(', ')),
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
              _showEditCustomerDialog(customer);
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
            width: 100,
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

  void _showDeleteCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: Text(
          '${customer.name} müşterisini silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Müşteri silme işlemi
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Müşteri silme özelliği yakında eklenecek'),
                  backgroundColor: AppTheme.infoColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
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
