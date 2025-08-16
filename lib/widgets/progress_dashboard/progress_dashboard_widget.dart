import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ProgressDashboardWidget extends StatefulWidget {
  const ProgressDashboardWidget({super.key});

  @override
  State<ProgressDashboardWidget> createState() =>
      _ProgressDashboardWidgetState();
}

class _ProgressDashboardWidgetState extends State<ProgressDashboardWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  final List<Goal> _goals = [
    Goal(
      id: '1',
      title: 'Anksiyete Yönetimi',
      description: 'Günlük anksiyete seviyesini 5/10\'un altında tutmak',
      targetValue: 5,
      currentValue: 7,
      maxValue: 10,
      category: GoalCategory.mentalHealth,
      deadline: DateTime.now().add(const Duration(days: 30)),
      isCompleted: false,
    ),
    Goal(
      id: '2',
      title: 'Düzenli İlaç Kullanımı',
      description: '30 gün boyunca ilaçları zamanında almak',
      targetValue: 30,
      currentValue: 25,
      maxValue: 30,
      category: GoalCategory.medication,
      deadline: DateTime.now().add(const Duration(days: 5)),
      isCompleted: false,
    ),
    Goal(
      id: '3',
      title: 'Sosyal Aktivite',
      description: 'Haftada en az 2 kez sosyal aktiviteye katılmak',
      targetValue: 2,
      currentValue: 1,
      maxValue: 2,
      category: GoalCategory.social,
      deadline: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    ),
    Goal(
      id: '4',
      title: 'Uyku Düzeni',
      description: 'Günde 7-8 saat düzenli uyku',
      targetValue: 7,
      currentValue: 6,
      maxValue: 8,
      category: GoalCategory.lifestyle,
      deadline: DateTime.now().add(const Duration(days: 14)),
      isCompleted: false,
    ),
  ];

  final List<Achievement> _achievements = [
    Achievement(
      id: '1',
      title: 'İlk Adım',
      description: 'İlk seansınızı tamamladınız',
      icon: Icons.first_page,
      color: Colors.blue,
      unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Achievement(
      id: '2',
      title: 'Düzenli Kullanıcı',
      description: '7 gün boyunca uygulamayı kullandınız',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Achievement(
      id: '3',
      title: 'Motivasyon Ustası',
      description: '10 gün boyunca hedeflerinizi takip ettiniz',
      icon: Icons.emoji_events,
      color: Colors.yellow.shade700,
      unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade50,
            Colors.purple.shade50,
            Colors.pink.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade600,
                  Colors.purple.shade600,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İlerleme Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Hedeflerinizi takip edin ve başarılarınızı kutlayın',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insights,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Progress
                  _buildOverallProgress(),
                  const SizedBox(height: 24),

                  // Goals Section
                  _buildGoalsSection(),
                  const SizedBox(height: 24),

                  // Achievements Section
                  _buildAchievementsSection(),
                  const SizedBox(height: 24),

                  // Motivation Section
                  _buildMotivationSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    final completedGoals = _goals.where((g) => g.isCompleted).length;
    final totalGoals = _goals.length;
    final overallProgress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genel İlerleme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'Tamamlanan',
                  '$completedGoals',
                  Icons.check_circle,
                  Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressStat(
                  'Toplam',
                  '$totalGoals',
                  Icons.flag,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressStat(
                  'İlerleme',
                  '${(overallProgress * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.purple.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value * overallProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.shade600,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hedefler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () => _showAddGoalDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Hedef'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._goals.map((goal) => _buildGoalCard(goal)),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final progress = goal.currentValue / goal.maxValue;
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isNearDeadline = daysLeft <= 3 && daysLeft >= 0;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (goal.isCompleted) {
      statusColor = Colors.green;
      statusText = 'Tamamlandı';
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Gecikti';
      statusIcon = Icons.warning;
    } else if (isNearDeadline) {
      statusColor = Colors.orange;
      statusText = 'Yakında';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.blue;
      statusText = 'Devam Ediyor';
      statusIcon = Icons.play_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      goal.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(goal.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(goal.category),
                  color: _getCategoryColor(goal.category),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlerleme',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${goal.currentValue}/${goal.maxValue}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    isOverdue ? 'Gecikti' : '${daysLeft} gün kaldı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!goal.isCompleted) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateGoalProgress(goal),
                    icon: const Icon(Icons.add),
                    label: const Text('İlerleme Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showGoalDetails(goal),
                  icon: const Icon(Icons.info),
                  label: const Text('Detaylar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo.shade600,
                    side: BorderSide(color: Colors.indigo.shade600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Başarılar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _achievements.length,
          itemBuilder: (context, index) =>
              _buildAchievementCard(_achievements[index]),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: achievement.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.color,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${achievement.unlockedAt.day}/${achievement.unlockedAt.month}/${achievement.unlockedAt.year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: achievement.color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationSection() {
    final motivationalQuotes = [
      'Her gün yeni bir başlangıçtır.',
      'Küçük adımlar büyük değişimler yaratır.',
      'Kendinize inanın, başarabilirsiniz.',
      'İyileşme bir süreçtir, sabırlı olun.',
      'Her zorluk bir fırsattır.',
    ];

    final randomQuote = motivationalQuotes[
        DateTime.now().millisecond % motivationalQuotes.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade100,
            Colors.indigo.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb,
            color: Colors.purple.shade600,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'Günün Motivasyonu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            randomQuote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.purple.shade700,
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _refreshMotivation(),
            icon: const Icon(Icons.refresh),
            label: const Text('Yeni Motivasyon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.mentalHealth:
        return Colors.blue;
      case GoalCategory.medication:
        return Colors.green;
      case GoalCategory.social:
        return Colors.orange;
      case GoalCategory.lifestyle:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.mentalHealth:
        return Icons.psychology;
      case GoalCategory.medication:
        return Icons.medication;
      case GoalCategory.social:
        return Icons.people;
      case GoalCategory.lifestyle:
        return Icons.fitness_center;
    }
  }

  void _updateGoalProgress(Goal goal) {
    // TODO: Implement goal progress update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İlerleme güncelleme özelliği yakında!')),
    );
  }

  void _showGoalDetails(Goal goal) {
    // TODO: Implement goal details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hedef detayları yakında!')),
    );
  }

  void _showAddGoalDialog() {
    // TODO: Implement add goal dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hedef ekleme özelliği yakında!')),
    );
  }

  void _refreshMotivation() {
    setState(() {
      // Trigger rebuild to get new random quote
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni motivasyon yüklendi!')),
    );
  }
}

enum GoalCategory {
  mentalHealth,
  medication,
  social,
  lifestyle,
}

class Goal {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  double currentValue;
  final double maxValue;
  final GoalCategory category;
  final DateTime deadline;
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.maxValue,
    required this.category,
    required this.deadline,
    required this.isCompleted,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlockedAt,
  });
}
