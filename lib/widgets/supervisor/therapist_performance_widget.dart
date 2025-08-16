import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/supervision_models.dart';

class TherapistPerformanceWidget extends StatefulWidget {
  final List<TherapistPerformance> performances;
  final Function(TherapistPerformance) onTherapistTap;

  const TherapistPerformanceWidget({
    super.key,
    required this.performances,
    required this.onTherapistTap,
  });

  @override
  State<TherapistPerformanceWidget> createState() => _TherapistPerformanceWidgetState();
}

class _TherapistPerformanceWidgetState extends State<TherapistPerformanceWidget> {
  String _searchQuery = '';
  String _selectedSortBy = 'Başarı Oranı';
  bool _sortDescending = true;

  List<TherapistPerformance> get _filteredAndSortedPerformances {
    var filtered = widget.performances.where((performance) {
      return performance.therapistName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          performance.specialization.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort by selected criteria
    switch (_selectedSortBy) {
      case 'Başarı Oranı':
        filtered.sort((a, b) => _sortDescending 
            ? b.successRate.compareTo(a.successRate)
            : a.successRate.compareTo(b.successRate));
        break;
      case 'Vaka Sayısı':
        filtered.sort((a, b) => _sortDescending 
            ? b.caseCount.compareTo(a.caseCount)
            : a.caseCount.compareTo(b.caseCount));
        break;
      case 'Ortalama Puan':
        filtered.sort((a, b) => _sortDescending 
            ? b.averageRating.compareTo(a.averageRating)
            : a.averageRating.compareTo(b.averageRating));
        break;
      case 'İsim':
        filtered.sort((a, b) => _sortDescending 
            ? b.therapistName.compareTo(a.therapistName)
            : a.therapistName.compareTo(b.therapistName));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Sort Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Terapist ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sort Controls
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSortBy,
                      decoration: InputDecoration(
                        labelText: 'Sırala',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Başarı Oranı', 'Vaka Sayısı', 'Ortalama Puan', 'İsim']
                          .map((sortBy) => DropdownMenuItem(
                                value: sortBy,
                                child: Text(sortBy),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedSortBy = value!),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Sort Direction Toggle
                  IconButton(
                    onPressed: () => setState(() => _sortDescending = !_sortDescending),
                    icon: Icon(
                      _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    ),
                    tooltip: _sortDescending ? 'Azalan' : 'Artan',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Performance List
        Expanded(
          child: _filteredAndSortedPerformances.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredAndSortedPerformances.length,
                  itemBuilder: (context, index) {
                    final performance = _filteredAndSortedPerformances[index];
                    return _buildPerformanceCard(performance);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Terapist performans verisi bulunamadı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terapistlerin performans verileri henüz eklenmemiş',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(TherapistPerformance performance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTherapistTap(performance);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      performance.therapistName[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          performance.therapistName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          performance.specialization,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(performance.successRate).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(performance.successRate * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getPerformanceColor(performance.successRate),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Performance Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.cases,
                      label: 'Vaka Sayısı',
                      value: performance.caseCount.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.star,
                      label: 'Ortalama Puan',
                      value: performance.averageRating.toStringAsFixed(1),
                      color: Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.trending_up,
                      label: 'Gelişim',
                      value: '${(performance.improvementRate * 100).toStringAsFixed(1)}%',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Başarı Oranı',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(performance.successRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: performance.successRate,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPerformanceColor(performance.successRate),
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
              
              if (performance.notes != null && performance.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    performance.notes!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPerformanceColor(double successRate) {
    if (successRate >= 0.8) return Colors.green;
    if (successRate >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
