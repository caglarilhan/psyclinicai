import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class WhiteLabelDashboardScreen extends StatefulWidget {
  const WhiteLabelDashboardScreen({super.key});

  @override
  State<WhiteLabelDashboardScreen> createState() => _WhiteLabelDashboardScreenState();
}

class _WhiteLabelDashboardScreenState extends State<WhiteLabelDashboardScreen> {
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
        // Save settings
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      () {
        // Reset settings
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'White Label Yönetimi',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'White Label Yönetimi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'White label yönetimi bileşenleri yakında eklenecek',
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
            // Save settings
          },
          icon: const Icon(Icons.save),
        ),
        IconButton(
          onPressed: () {
            // Preview
          },
          icon: const Icon(Icons.preview),
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
          title: 'Marka Ayarları',
          icon: Icons.branding_watermark,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Tema Özelleştirme',
          icon: Icons.palette,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Logo Yönetimi',
          icon: Icons.image,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Önizleme',
          icon: Icons.preview,
          onTap: () {},
        ),
      ],
    );
  }
}