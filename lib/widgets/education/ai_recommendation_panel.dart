import 'package:flutter/material.dart';
import '../../models/education_model.dart';

class AIRecommendationPanel extends StatefulWidget {
  final List<EducationModel> allContent;
  final List<EducationModel> userProgress;

  const AIRecommendationPanel({
    super.key,
    required this.allContent,
    required this.userProgress,
  });

  @override
  State<AIRecommendationPanel> createState() => _AIRecommendationPanelState();
}

class _AIRecommendationPanelState extends State<AIRecommendationPanel> {
  final TextEditingController _interestsController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  bool _isGenerating = false;
  List<EducationModel> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _generateInitialRecommendations();
  }

  @override
  void dispose() {
    _interestsController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  void _generateInitialRecommendations() {
    // Kullanıcının ilerlemesine göre başlangıç önerileri
    final completedCategories = widget.userProgress
        .where((content) => content.progress == 1.0)
        .map((content) => content.category)
        .toSet();

    final recommendedContent = widget.allContent
        .where((content) => !completedCategories.contains(content.category))
        .take(5)
        .toList();

    setState(() {
      _recommendations = recommendedContent;
    });
  }

  Future<void> _generateAIRecommendations() async {
    if (_interestsController.text.isEmpty && _goalsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ilgi alanlarınızı veya hedeflerinizi belirtin'),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // AI öneri simülasyonu
      await Future.delayed(const Duration(seconds: 2));

      final interests = _interestsController.text.toLowerCase();
      final goals = _goalsController.text.toLowerCase();

      final filteredContent = widget.allContent.where((content) {
        final matchesInterests = interests.isEmpty ||
            content.title.toLowerCase().contains(interests) ||
            content.description.toLowerCase().contains(interests) ||
            content.tags.any((tag) => tag.toLowerCase().contains(interests));

        final matchesGoals = goals.isEmpty ||
            content.title.toLowerCase().contains(goals) ||
            content.description.toLowerCase().contains(goals) ||
            content.tags.any((tag) => tag.toLowerCase().contains(goals));

        return matchesInterests || matchesGoals;
      }).toList();

      // Zorluk seviyesine göre sırala (başlangıç seviyesinden ileri seviyeye)
      filteredContent
          .sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));

      setState(() {
        _recommendations = filteredContent.take(8).toList();
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Öneri oluşturulurken hata: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Destekli Öğrenme Önerileri',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          // İlgi alanları ve hedefler
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kişiselleştirilmiş Öneriler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _interestsController,
                    decoration: InputDecoration(
                      labelText: 'İlgi Alanlarınız',
                      hintText:
                          'Örn: Bilişsel davranışçı terapi, travma terapisi...',
                      prefixIcon: const Icon(Icons.psychology),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalsController,
                    decoration: InputDecoration(
                      labelText: 'Öğrenme Hedefleriniz',
                      hintText:
                          'Örn: Yeni terapi teknikleri öğrenmek, sertifika almak...',
                      prefixIcon: const Icon(Icons.flag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isGenerating ? null : _generateAIRecommendations,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating
                          ? 'Öneriler Oluşturuluyor...'
                          : 'AI Önerileri Al'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Öneriler listesi
          if (_recommendations.isNotEmpty) ...[
            Text(
              'Sizin İçin Önerilen İçerikler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  final content = _recommendations[index];
                  return _buildRecommendationCard(content);
                },
              ),
            ),
          ] else if (!_isGenerating) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz öneri oluşturulmadı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'İlgi alanlarınızı ve hedeflerinizi belirtin,\nAI size özel öneriler sunsun',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(EducationModel content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: content.typeColor.withOpacity(0.1),
              ),
              child: Icon(
                content.typeIcon,
                size: 40,
                color: content.typeColor,
              ),
            ),

            const SizedBox(width: 16),

            // İçerik bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (content.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: content.difficultyColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          content.difficulty.name.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: content.difficultyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${content.duration} dakika',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        content.rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Aksiyon butonu
            IconButton(
              onPressed: () {
                // İçeriği açma işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${content.title} açılıyor...'),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              iconSize: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
