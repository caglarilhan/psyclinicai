import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class SessionManagementScreen extends StatefulWidget {
  final String? clientId;
  
  const SessionManagementScreen({
    super.key,
    this.clientId,
  });

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
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
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () {
        // Save session
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () {
        // New session
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Seans Yönetimi',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Seans Yönetimi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Seans yönetimi bileşenleri yakında eklenecek',
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
            // Save session
          },
          icon: const Icon(Icons.save),
        ),
        IconButton(
          onPressed: () {
            // New session
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            // Settings
          },
          icon: const Icon(Icons.settings),
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Yeni Seans',
          icon: Icons.add,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Seans Geçmişi',
          icon: Icons.history,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Notlar',
          icon: Icons.note,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'AI Özet',
          icon: Icons.summarize,
          onTap: () {},
        ),
      ],
    );
  }
}