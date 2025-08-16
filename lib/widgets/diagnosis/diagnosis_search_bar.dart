import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class DiagnosisSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final bool isSearching;
  final String placeholder;

  const DiagnosisSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.isSearching,
    required this.placeholder,
  });

  @override
  State<DiagnosisSearchBar> createState() => _DiagnosisSearchBarState();
}

class _DiagnosisSearchBarState extends State<DiagnosisSearchBar> {
  bool _isExpanded = false;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'ICD', 'DSM', 'Symptoms', 'Treatments'];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? 120 : 60,
      child: Column(
        children: [
          // Ana arama çubuğu
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded
                    ? AppTheme.primaryColor
                    : Theme.of(context).dividerColor,
                width: _isExpanded ? 2 : 1,
              ),
              boxShadow: _isExpanded
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Arama ikonu
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.search,
                    color:
                        _isExpanded ? AppTheme.primaryColor : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Arama metni
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    onChanged: (value) {
                      if (value.isNotEmpty && !_isExpanded) {
                        setState(() => _isExpanded = true);
                      }
                      if (value.isEmpty && _isExpanded) {
                        setState(() => _isExpanded = false);
                      }
                    },
                    onSubmitted: widget.onSearch,
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Arama butonu
                if (widget.controller.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: widget.isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            onPressed: () =>
                                widget.onSearch(widget.controller.text),
                            icon: Icon(
                              Icons.arrow_forward,
                              color: AppTheme.primaryColor,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                  ),

                // Genişletme butonu
                IconButton(
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color:
                        _isExpanded ? AppTheme.primaryColor : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Genişletilmiş filtreler
          if (_isExpanded) ...[
            const SizedBox(height: 12),

            // Filtre seçenekleri
            Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                      // TODO: Filtre uygula
                    },
                    backgroundColor: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[100],
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Hızlı arama önerileri
            Wrap(
              spacing: 8,
              children: [
                _buildQuickSearchChip('Depresyon', 'F32.1'),
                _buildQuickSearchChip('Anksiyete', 'F41.1'),
                _buildQuickSearchChip('PTSD', 'F43.1'),
                _buildQuickSearchChip('Bipolar', 'F31.1'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String label, String code) {
    return ActionChip(
      label: Text('$label ($code)'),
      onPressed: () {
        widget.controller.text = label;
        widget.onSearch(label);
      },
      backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: AppTheme.accentColor),
      avatar: Icon(
        Icons.medical_services,
        size: 16,
        color: AppTheme.accentColor,
      ),
    );
  }
}
