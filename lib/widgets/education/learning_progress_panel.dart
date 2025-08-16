import 'package:flutter/material.dart';
import '../../models/education_model.dart';

class LearningProgressPanel extends StatefulWidget {
  final List<EducationModel> userProgress;

  const LearningProgressPanel({
    super.key,
    required this.userProgress,
  });

  @override
  State<LearningProgressPanel> createState() => _LearningProgressPanelState();
}

class _LearningProgressPanelState extends State<LearningProgressPanel> {
  String _selectedTimeframe = 'Bu Ay';
  final List<String> _timeframes = [
    'Bu Hafta',
    'Bu Ay',
    'Bu Yıl',
    'Tüm Zamanlar'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Öğrenme İlerlemeniz',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          // Zaman aralığı seçici
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zaman Aralığı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedTimeframe,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    items: _timeframes.map((timeframe) {
                      return DropdownMenuItem(
                        value: timeframe,
                        child: Text(timeframe),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeframe = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // İstatistikler
          _buildStatisticsCards(),

          const SizedBox(height: 24),

          // İlerleme listesi
          Text(
            'Son Aktiviteler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _buildProgressList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final completedContent =
        widget.userProgress.where((content) => content.progress == 1.0).length;

    final inProgressContent = widget.userProgress
        .where((content) =>
            (content.progress ?? 0) > 0 && (content.progress ?? 0) < 1.0)
        .length;

    final totalTime = widget.userProgress
        .where((content) => (content.progress ?? 0) > 0)
        .fold<int>(0, (sum, content) => sum + content.duration);

    final averageRating = widget.userProgress
            .where((content) => (content.progress ?? 0) > 0)
            .fold<double>(0.0, (sum, content) => sum + content.rating) /
        (widget.userProgress
            .where((content) => (content.progress ?? 0) > 0)
            .length);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tamamlanan',
            '$completedContent',
            Icons.check_circle,
            Colors.green,
            'İçerik',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Devam Eden',
            '$inProgressContent',
            Icons.pending,
            Colors.orange,
            'İçerik',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Toplam Süre',
            '${totalTime}dk',
            Icons.access_time,
            Colors.blue,
            'Öğrenme',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ortalama',
            averageRating.isNaN ? '0.0' : averageRating.toStringAsFixed(1),
            Icons.star,
            Colors.amber,
            'Puan',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressList() {
    final sortedProgress = List<EducationModel>.from(widget.userProgress)
      ..sort((a, b) => (b.lastAccessed ?? DateTime.now())
          .compareTo(a.lastAccessed ?? DateTime.now()));

    if (sortedProgress.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz öğrenme aktivitesi yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Eğitim içeriklerini keşfetmeye başlayın\nve ilerlemenizi takip edin',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedProgress.length,
      itemBuilder: (context, index) {
        final content = sortedProgress[index];
        return _buildProgressCard(content);
      },
    );
  }

  Widget _buildProgressCard(EducationModel content) {
    final progressPercentage = content.progress ?? 0.0;
    final isCompleted = progressPercentage == 1.0;
    final isInProgress = progressPercentage > 0 && progressPercentage < 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Thumbnail
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: content.typeColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    content.typeIcon,
                    size: 30,
                    color: content.typeColor,
                  ),
                ),

                const SizedBox(width: 16),

                // İçerik bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: content.difficultyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Durum ikonu
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : isInProgress
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : isInProgress
                            ? Icons.pending
                            : Icons.play_circle_outline,
                    color: isCompleted
                        ? Colors.green
                        : isInProgress
                            ? Colors.orange
                            : Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // İlerleme çubuğu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? Colors.green
                        : isInProgress
                            ? Colors.orange
                            : Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Alt bilgiler
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
                const Spacer(),
                if (content.lastAccessed != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatLastAccessed(content.lastAccessed!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Aksiyon butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // İçeriği açma işlemi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${content.title} açılıyor...'),
                        ),
                      );
                    },
                    icon: Icon(
                      isCompleted ? Icons.replay : Icons.play_arrow,
                    ),
                    label: Text(
                      isCompleted ? 'Tekrar İzle' : 'Devam Et',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isInProgress)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // İçeriği tamamlama işlemi
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${content.title} tamamlanıyor...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Tamamla'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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

  String _formatLastAccessed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    }
  }
}
