import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class ConsentComplianceScreen extends StatefulWidget {
  const ConsentComplianceScreen({super.key});

  @override
  State<ConsentComplianceScreen> createState() => _ConsentComplianceScreenState();
}

class _ConsentComplianceScreenState extends State<ConsentComplianceScreen> {
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
      () {
        // New consent
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      () {
        // Generate report
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Onam Uyumluluğu',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Onam Uyumluluğu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Onam uyumluluğu bileşenleri yakında eklenecek',
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
            // New consent
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            // Generate report
          },
          icon: const Icon(Icons.assessment),
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
          title: 'Onam Kayıtları',
          icon: Icons.verified_user,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Onam Şablonları',
          icon: Icons.description,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Uyumluluk Raporu',
          icon: Icons.assessment,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Denetim Kayıtları',
          icon: Icons.security,
          onTap: () {},
        ),
      ],
    );
  }
}