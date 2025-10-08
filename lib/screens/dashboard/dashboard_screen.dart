import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _removeKeyboardShortcuts();
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

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'PsyClinicAI Dashboard',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'PsyClinicAI Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Dashboard bileşenleri yakında eklenecek',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Ayarlar
          },
          icon: const Icon(Icons.settings),
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Seans Yönetimi',
          icon: Icons.medical_services,
          onTap: () => Navigator.pushNamed(context, '/session-management'),
        ),
        DesktopSidebarItem(
          title: 'Randevu Takvimi',
          icon: Icons.calendar_today,
          onTap: () => Navigator.pushNamed(context, '/appointment-calendar'),
        ),
        DesktopSidebarItem(
          title: 'Vaka Yönetimi',
          icon: Icons.folder,
          onTap: () => Navigator.pushNamed(context, '/case-management'),
        ),
        DesktopSidebarItem(
          title: 'AI Modülleri',
          icon: Icons.psychology,
          onTap: () => Navigator.pushNamed(context, '/therapy-simulation'),
        ),
        DesktopSidebarItem(
          title: 'Finans',
          icon: Icons.attach_money,
          onTap: () => Navigator.pushNamed(context, '/finance'),
        ),
        DesktopSidebarItem(
          title: 'Güvenlik',
          icon: Icons.security,
          onTap: () => Navigator.pushNamed(context, '/security'),
        ),
      ],
    );
  }
}