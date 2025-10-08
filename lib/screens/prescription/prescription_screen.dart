import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
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
        // New prescription
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () {
        // Save prescription
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Reçete Yönetimi',
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
              'Reçete Yönetimi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Reçete yönetimi bileşenleri yakında eklenecek',
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
            // New prescription
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
          title: 'Yeni Reçete',
          icon: Icons.add,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Reçete Geçmişi',
          icon: Icons.history,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'İlaç Kütüphanesi',
          icon: Icons.medication,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Etkileşim Kontrolü',
          icon: Icons.warning,
          onTap: () {},
        ),
      ],
    );
  }
}