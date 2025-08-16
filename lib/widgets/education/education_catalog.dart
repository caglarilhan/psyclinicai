import 'package:flutter/material.dart';
import '../../models/education_model.dart';
import '../../utils/theme.dart';

class EducationCatalog extends StatefulWidget {
  final List<EducationModel> content;
  final Function(EducationModel) onContentSelected;

  const EducationCatalog({
    super.key,
    required this.content,
    required this.onContentSelected,
  });

  @override
  State<EducationCatalog> createState() => _EducationCatalogState();
}

class _EducationCatalogState extends State<EducationCatalog> {
  String _selectedCategory = 'Tümü';
  String _selectedDifficulty = 'Tümü';
  String _searchQuery = '';
  List<String> _categories = [];
  List<String> _difficulties = [];

  @override
  void initState() {
    super.initState();
    _extractFilters();
  }

  void _extractFilters() {
    _categories = [
      'Tümü',
      ...widget.content.map((c) => c.category).toSet().toList()
    ];
    _difficulties = [
      'Tümü',
      ...widget.content
          .map((c) => c.difficulty.toString().split('.').last)
          .toSet()
          .toList()
    ];
  }

  List<EducationModel> get _filteredContent {
    return widget.content.where((content) {
      // Kategori filtresi
      if (_selectedCategory != 'Tümü' &&
          content.category != _selectedCategory) {
        return false;
      }

      // Zorluk filtresi
      if (_selectedDifficulty != 'Tümü' &&
          content.difficulty.toString().split('.').last !=
              _selectedDifficulty) {
        return false;
      }

      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return content.title.toLowerCase().contains(query) ||
            content.description.toLowerCase().contains(query) ||
            content.tags.any((tag) => tag.toLowerCase().contains(query)) ||
            content.author.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtreler ve arama
        _buildFiltersAndSearch(),

        // İçerik listesi
        Expanded(
          child: _filteredContent.isEmpty
              ? _buildEmptyState()
              : _buildContentList(),
        ),
      ],
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Arama çubuğu
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Eğitim içeriği ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 16),

          // Filtreler
          Row(
            children: [
              // Kategori filtresi
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
              ),

              const SizedBox(width: 12),

              // Zorluk filtresi
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Zorluk',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _difficulties
                      .map(
                        (difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDifficulty = value!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sonuç sayısı
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_filteredContent.length} içerik bulundu',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredContent.length,
      itemBuilder: (context, index) {
        final content = _filteredContent[index];
        return _buildContentCard(content);
      },
    );
  }

  Widget _buildContentCard(EducationModel content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => widget.onContentSelected(content),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Üst panel - Thumbnail ve premium badge
              Stack(
                children: [
                  // Thumbnail placeholder
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: content.typeColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        content.typeIcon,
                        size: 48,
                        color: content.typeColor,
                      ),
                    ),
                  ),

                  // Premium badge
                  if (content.showPremiumBadge)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // İçerik tipi badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: content.typeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            content.typeIcon,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTypeText(content.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // İçerik bilgileri
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            content.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppTheme.warningColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              content.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Açıklama
                    Text(
                      content.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Meta bilgiler
                    Row(
                      children: [
                        // Yazar
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              content.author,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Süre
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${content.duration} dk',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Görüntülenme
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${content.viewCount}',
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

                    // Alt bilgiler
                    Row(
                      children: [
                        // Zorluk seviyesi
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: content.difficultyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: content.difficultyColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            content.difficulty.toString().split('.').last,
                            style: TextStyle(
                              color: content.difficultyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Kategori
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            content.category,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Başla butonu
                        ElevatedButton.icon(
                          onPressed: () => widget.onContentSelected(content),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Başla'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'İçerik Bulunamadı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filtreleri değiştirin veya farklı anahtar kelimeler deneyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTypeText(EducationType type) {
    switch (type) {
      case EducationType.video:
        return 'Video';
      case EducationType.pdf:
        return 'PDF';
      case EducationType.interactive:
        return 'İnteraktif';
      case EducationType.audio:
        return 'Ses';
      case EducationType.quiz:
        return 'Quiz';
    }
  }
}
