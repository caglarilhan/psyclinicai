import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/common/pro_card.dart';
import '../../widgets/common/pro_button.dart';
import '../../widgets/common/pro_badge.dart';
import '../../services/keyboard_shortcuts_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
    _setupAnimations();
  }

  @override
  void dispose() {
    _removeKeyboardShortcuts();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/session-management'),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/appointment-calendar'),
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.control),
    );
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: AppSpacing.paddingAll(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(isDark),
                AppSpacing.heightLG,
                _buildStatsSection(isDark),
                AppSpacing.heightLG,
                _buildQuickActionsSection(isDark),
                AppSpacing.heightLG,
                _buildRecentActivitiesSection(isDark),
                AppSpacing.heightLG,
                _buildUpcomingAppointmentsSection(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      title: Text(
        'PsyKlinikAI',
        style: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: 0,
      shadowColor: Colors.transparent,
      actions: [
        ProNotificationBadge(
          count: 3,
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            onPressed: () {
              // TODO: Notifications
            },
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            // TODO: Settings
          },
        ),
        AppSpacing.widthMD,
      ],
    );
  }

  Widget _buildWelcomeSection(bool isDark) {
    return ProCard(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: AppSpacing.iconLg,
            ),
          ),
          AppSpacing.widthLG,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş geldiniz, Dr. Örnek',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.heightXS,
                Text(
                  'Bugün ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.heightSM,
                ProStatusBadge(
                  status: 'Aktif',
                  size: ProBadgeSize.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genel Bakış',
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.heightMD,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'Toplam Hasta',
              '24',
              Icons.people_outline,
              AppColors.primary,
              isDark,
              onTap: () => Navigator.pushNamed(context, '/client-management'),
            ),
            _buildStatCard(
              'Bu Ay Seans',
              '18',
              Icons.event_outlined,
              AppColors.success,
              isDark,
            ),
            _buildStatCard(
              'Bekleyen Randevu',
              '7',
              Icons.schedule_outlined,
              AppColors.warning,
              isDark,
              onTap: () => Navigator.pushNamed(context, '/pending-appointments'),
            ),
            _buildStatCard(
              'AI Tanı',
              '12',
              Icons.psychology_outlined,
              AppColors.accent,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.heightMD,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionCard(
              'Yeni Hasta',
              Icons.person_add_outlined,
              AppColors.primary,
              isDark,
              () => Navigator.pushNamed(context, '/client-management'),
            ),
            _buildQuickActionCard(
              'Randevu Oluştur',
              Icons.add_circle_outline,
              AppColors.success,
              isDark,
              () => Navigator.pushNamed(context, '/appointment-calendar'),
            ),
            _buildQuickActionCard(
              'Seans Notu',
              Icons.note_add_outlined,
              AppColors.info,
              isDark,
              () => Navigator.pushNamed(context, '/session-management'),
            ),
            _buildQuickActionCard(
              'AI Tanı',
              Icons.psychology_outlined,
              AppColors.accent,
              isDark,
              () => Navigator.pushNamed(context, '/diagnosis'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Aktiviteler',
              style: AppTypography.headlineMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            ProButton(
              text: 'Tümünü Gör',
              variant: ProButtonVariant.ghost,
              size: ProButtonSize.small,
              onPressed: () {
                // TODO: Show all activities
              },
            ),
          ],
        ),
        AppSpacing.heightMD,
        ProCard(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              height: AppSpacing.lg,
            ),
            itemBuilder: (context, index) {
              return _buildActivityItem(index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Yaklaşan Randevular',
              style: AppTypography.headlineMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            ProButton(
              text: 'Takvimi Gör',
              variant: ProButtonVariant.ghost,
              size: ProButtonSize.small,
              onPressed: () => Navigator.pushNamed(context, '/appointment-calendar'),
            ),
          ],
        ),
        AppSpacing.heightMD,
        ProCard(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              height: AppSpacing.lg,
            ),
            itemBuilder: (context, index) {
              return _buildAppointmentItem(index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    return ProCard(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: AppSpacing.paddingAllSM,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppSpacing.iconMd,
                ),
              ),
              Text(
                value,
                style: AppTypography.headlineLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.heightMD,
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return ProCard(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingAllSM,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSpacing.iconMd,
            ),
          ),
          AppSpacing.widthMD,
          Expanded(
            child: Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            size: AppSpacing.iconSm,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index, bool isDark) {
    final activities = [
      {'title': 'Yeni hasta eklendi', 'subtitle': 'Ahmet Yılmaz', 'time': '2 saat önce', 'icon': Icons.person_add_outlined, 'color': AppColors.success},
      {'title': 'Randevu oluşturuldu', 'subtitle': 'Bugün 14:00', 'time': '4 saat önce', 'icon': Icons.event_outlined, 'color': AppColors.info},
      {'title': 'Seans notu güncellendi', 'subtitle': 'Depresyon seansı', 'time': '1 gün önce', 'icon': Icons.note_add_outlined, 'color': AppColors.warning},
      {'title': 'AI tanı tamamlandı', 'subtitle': 'Anksiyete bozukluğu', 'time': '2 gün önce', 'icon': Icons.psychology_outlined, 'color': AppColors.accent},
      {'title': 'Randevu hatırlatması', 'subtitle': 'Yarın 10:00', 'time': '3 gün önce', 'icon': Icons.schedule_outlined, 'color': AppColors.primary},
    ];

    final activity = activities[index];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (activity['color'] as Color).withValues(alpha: 0.1),
        child: Icon(
          activity['icon'] as IconData,
          color: activity['color'] as Color,
          size: AppSpacing.iconSm,
        ),
      ),
      title: Text(
        activity['title'] as String,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        activity['subtitle'] as String,
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Text(
        activity['time'] as String,
        style: AppTypography.caption.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(int index, bool isDark) {
    final appointments = [
      {'title': 'Ahmet Yılmaz', 'subtitle': 'Depresyon Seansı', 'time': '14:00', 'status': 'Scheduled', 'color': AppColors.info},
      {'title': 'Ayşe Demir', 'subtitle': 'Anksiyete Terapisi', 'time': '16:30', 'status': 'Confirmed', 'color': AppColors.success},
      {'title': 'Mehmet Kaya', 'subtitle': 'Aile Terapisi', 'time': '18:00', 'status': 'Pending', 'color': AppColors.warning},
    ];

    final appointment = appointments[index];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: (appointment['color'] as Color).withValues(alpha: 0.1),
        child: Icon(
          Icons.person_outline,
          color: appointment['color'] as Color,
          size: AppSpacing.iconSm,
        ),
      ),
      title: Text(
        appointment['title'] as String,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        appointment['subtitle'] as String,
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            appointment['time'] as String,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.heightXS,
          ProStatusBadge(
            status: appointment['status'] as String,
            size: ProBadgeSize.small,
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month];
  }
}