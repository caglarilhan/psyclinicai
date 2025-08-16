import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClientFiltersWidget extends StatelessWidget {
  final String selectedStatus;
  final String selectedRiskLevel;
  final Function(String, String) onFilterChanged;

  const ClientFiltersWidget({
    super.key,
    required this.selectedStatus,
    required this.selectedRiskLevel,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status Filter
        Expanded(
          child: _buildFilterChip(
            context: context,
            label: 'Durum',
            selectedValue: selectedStatus,
            options: [
              {'value': 'all', 'label': 'Tümü', 'color': Colors.grey},
              {'value': 'active', 'label': 'Aktif', 'color': Colors.green},
              {'value': 'inactive', 'label': 'Pasif', 'color': Colors.orange},
              {'value': 'discharged', 'label': 'Taburcu', 'color': Colors.blue},
              {'value': 'onHold', 'label': 'Beklemede', 'color': Colors.purple},
              {'value': 'emergency', 'label': 'Acil', 'color': Colors.red},
            ],
            onChanged: (value) => onFilterChanged('status', value),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Risk Level Filter
        Expanded(
          child: _buildFilterChip(
            context: context,
            label: 'Risk Seviyesi',
            selectedValue: selectedRiskLevel,
            options: [
              {'value': 'all', 'label': 'Tümü', 'color': Colors.grey},
              {'value': 'low', 'label': 'Düşük', 'color': Colors.green},
              {'value': 'medium', 'label': 'Orta', 'color': Colors.orange},
              {'value': 'high', 'label': 'Yüksek', 'color': Colors.red},
              {'value': 'critical', 'label': 'Kritik', 'color': Colors.purple},
            ],
            onChanged: (value) => onFilterChanged('riskLevel', value),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Quick Actions
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement advanced filters
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gelişmiş filtreler yakında!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: Icon(
              Icons.tune,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Gelişmiş Filtreler',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String selectedValue,
    required List<Map<String, dynamic>> options,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedValue == option['value'];
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    option['label'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : option['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.lightImpact();
                    onChanged(option['value']);
                  },
                  backgroundColor: Colors.transparent,
                  selectedColor: option['color'],
                  side: BorderSide(
                    color: isSelected ? option['color'] : Colors.grey[300]!,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                  pressElevation: 2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
