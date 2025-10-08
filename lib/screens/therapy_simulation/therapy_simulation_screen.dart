import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class TherapySimulationScreen extends StatefulWidget {
  const TherapySimulationScreen({super.key});

  @override
  State<TherapySimulationScreen> createState() => _TherapySimulationScreenState();
}

class _TherapySimulationScreenState extends State<TherapySimulationScreen> {
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
        // Start simulation
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
      () {
        // End simulation
      },
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyE, LogicalKeyboardKey.control),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Terapi Simülasyonu',
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Terapi Simülasyonu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Terapi simülasyonu bileşenleri yakında eklenecek',
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
            // Start simulation
          },
          icon: const Icon(Icons.play_arrow),
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
          title: 'Yeni Simülasyon',
          icon: Icons.add,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Simülasyon Geçmişi',
          icon: Icons.history,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Senaryolar',
          icon: Icons.theater_comedy,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Performans Analizi',
          icon: Icons.analytics,
          onTap: () {},
        ),
      ],
    );
  }
}