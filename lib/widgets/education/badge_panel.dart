import 'package:flutter/material.dart';
import '../../models/education_model.dart';

class BadgePanel extends StatefulWidget {
  final List<EducationModel> userProgress;

  const BadgePanel({
    super.key,
    required this.userProgress,
  });

  @override
  State<BadgePanel> createState() => _BadgePanelState();
}

class _BadgePanelState extends State<BadgePanel> {
  @override
  Widget build(BuildContext context) {
    final badges = _generateBadges();
    final unlockedBadges = badges.where((badge) => badge.isUnlocked).toList();
    final lockedBadges = badges.where((badge) => !badge.isUnlocked).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rozetleriniz',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          // Rozet istatistikleri
          _buildBadgeStats(badges.length, unlockedBadges.length),

          const SizedBox(height: 24),

          // Kazanılan rozetler
          if (unlockedBadges.isNotEmpty) ...[
            Text(
              'Kazanılan Rozetler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: unlockedBadges.length,
                itemBuilder: (context, index) {
                  return _buildUnlockedBadge(unlockedBadges[index]);
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Kilitli rozetler
          Text(
            'Gelecek Hedefler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: lockedBadges.length,
              itemBuilder: (context, index) {
                return _buildLockedBadge(lockedBadges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStats(int totalBadges, int unlockedBadges) {
    final progress = totalBadges > 0 ? unlockedBadges / totalBadges : 0.0;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Toplam Rozet',
                    '$totalBadges',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Kazanılan',
                    '$unlockedBadges',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'İlerleme',
                    '${(progress * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // İlerleme çubuğu
            LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  Theme.of(context).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
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
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUnlockedBadge(Badge badge) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          // Rozet ikonu
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badge.color,
                  badge.color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: badge.color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              badge.icon,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Rozet adı
          Text(
            badge.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadge(Badge badge) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kilitli rozet ikonu
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.lock,
                size: 30,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),

            const SizedBox(height: 12),

            // Rozet adı
            Text(
              badge.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Gereksinim
            Text(
              badge.requirement,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<Badge> _generateBadges() {
    final completedCourses = widget.userProgress
        .where((content) => (content.progress ?? 0) == 1.0)
        .length;

    final totalDuration = widget.userProgress
        .where((content) => (content.progress ?? 0) > 0)
        .fold<int>(0, (sum, content) => sum + content.duration);

    final categories = widget.userProgress
        .where((content) => (content.progress ?? 0) > 0)
        .map((content) => content.category)
        .toSet()
        .length;

    final premiumCourses = widget.userProgress
        .where((content) => (content.progress ?? 0) > 0 && content.isPremium)
        .length;

    return [
      // İlk adım rozetleri
      Badge(
        id: 'first_course',
        name: 'İlk Adım',
        description: 'İlk eğitim kursunu tamamladınız',
        icon: Icons.school,
        color: Colors.green,
        isUnlocked: completedCourses >= 1,
        requirement: '1 kurs tamamla',
      ),

      Badge(
        id: 'course_collector',
        name: 'Kurs Toplayıcısı',
        description: '5 farklı kurs tamamladınız',
        icon: Icons.collections_bookmark,
        color: Colors.blue,
        isUnlocked: completedCourses >= 5,
        requirement: '5 kurs tamamla',
      ),

      Badge(
        id: 'course_master',
        name: 'Kurs Ustası',
        description: '10 farklı kurs tamamladınız',
        icon: Icons.psychology,
        color: Colors.purple,
        isUnlocked: completedCourses >= 10,
        requirement: '10 kurs tamamla',
      ),

      // Süre rozetleri
      Badge(
        id: 'time_investor',
        name: 'Zaman Yatırımcısı',
        description: 'Toplam 100 dakika eğitim aldınız',
        icon: Icons.access_time,
        color: Colors.orange,
        isUnlocked: totalDuration >= 100,
        requirement: '100 dakika eğitim',
      ),

      Badge(
        id: 'time_master',
        name: 'Zaman Ustası',
        description: 'Toplam 500 dakika eğitim aldınız',
        icon: Icons.timer,
        color: Colors.red,
        isUnlocked: totalDuration >= 500,
        requirement: '500 dakika eğitim',
      ),

      // Kategori rozetleri
      Badge(
        id: 'category_explorer',
        name: 'Kategori Kaşifi',
        description: '3 farklı kategoride eğitim aldınız',
        icon: Icons.explore,
        color: Colors.teal,
        isUnlocked: categories >= 3,
        requirement: '3 kategori keşfet',
      ),

      Badge(
        id: 'category_master',
        name: 'Kategori Ustası',
        description: '5 farklı kategoride eğitim aldınız',
        icon: Icons.category,
        color: Colors.indigo,
        isUnlocked: categories >= 5,
        requirement: '5 kategori keşfet',
      ),

      // Premium rozetleri
      Badge(
        id: 'premium_starter',
        name: 'Premium Başlangıç',
        description: 'İlk premium kursu tamamladınız',
        icon: Icons.star,
        color: Colors.amber,
        isUnlocked: premiumCourses >= 1,
        requirement: '1 premium kurs',
      ),

      Badge(
        id: 'premium_collector',
        name: 'Premium Toplayıcısı',
        description: '5 premium kurs tamamladınız',
        icon: Icons.stars,
        color: Colors.deepOrange,
        isUnlocked: premiumCourses >= 5,
        requirement: '5 premium kurs',
      ),

      // Özel rozetler
      Badge(
        id: 'quiz_master',
        name: 'Quiz Ustası',
        description: 'İlk quiz\'i tamamladınız',
        icon: Icons.quiz,
        color: Colors.cyan,
        isUnlocked: widget.userProgress.any((content) =>
            content.type == EducationType.quiz && content.progress == 1.0),
        requirement: '1 quiz tamamla',
      ),

      Badge(
        id: 'video_lover',
        name: 'Video Tutkunu',
        description: '5 video kursu tamamladınız',
        icon: Icons.video_library,
        color: Colors.red,
        isUnlocked: widget.userProgress
                .where((content) =>
                    content.type == EducationType.video &&
                    content.progress == 1.0)
                .length >=
            5,
        requirement: '5 video kursu',
      ),

      Badge(
        id: 'interactive_learner',
        name: 'İnteraktif Öğrenci',
        description: '3 interaktif kurs tamamladınız',
        icon: Icons.touch_app,
        color: Colors.green,
        isUnlocked: widget.userProgress
                .where((content) =>
                    content.type == EducationType.interactive &&
                    content.progress == 1.0)
                .length >=
            3,
        requirement: '3 interaktif kurs',
      ),
    ];
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final String requirement;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.requirement,
  });
}
