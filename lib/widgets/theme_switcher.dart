import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  ThemeMode _currentThemeMode = AppTheme.themeMode;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    await AppTheme.loadThemeMode();
    setState(() {
      _currentThemeMode = AppTheme.themeMode;
    });
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    await AppTheme.setThemeMode(mode);
    setState(() {
      _currentThemeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      icon: Icon(
        _getThemeIcon(),
        color: Theme.of(context).iconTheme.color,
      ),
      tooltip: 'Tema Değiştir',
      onSelected: _changeTheme,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: _currentThemeMode == ThemeMode.light 
                    ? AppTheme.primaryColor 
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Açık Tema',
                style: TextStyle(
                  fontWeight: _currentThemeMode == ThemeMode.light 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: _currentThemeMode == ThemeMode.dark 
                    ? AppTheme.primaryColor 
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Koyu Tema',
                style: TextStyle(
                  fontWeight: _currentThemeMode == ThemeMode.dark 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.settings_system_daydream,
                color: _currentThemeMode == ThemeMode.system 
                    ? AppTheme.primaryColor 
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Sistem',
                style: TextStyle(
                  fontWeight: _currentThemeMode == ThemeMode.system 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getThemeIcon() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }
}

// Tema değiştirici card widget'ı
class ThemeSwitcherCard extends StatelessWidget {
  const ThemeSwitcherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tema Ayarları',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    context,
                    ThemeMode.light,
                    'Açık',
                    Icons.light_mode,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    ThemeMode.dark,
                    'Koyu',
                    Icons.dark_mode,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    ThemeMode.system,
                    'Sistem',
                    Icons.settings_system_daydream,
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = AppTheme.themeMode == mode;
    
    return GestureDetector(
      onTap: () => AppTheme.setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.1) 
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
