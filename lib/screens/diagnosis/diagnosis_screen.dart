import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      () {
        // Focus search field
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      _clearSearch,
    );
  }

  void _removeKeyboardShortcuts() {
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
    );
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Tanı Rehberi',
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
              'Tanı Rehberi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tanı rehberi bileşenleri yakında eklenecek',
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
          title: 'Tanı Arama',
          icon: Icons.search,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Tanı Kategorileri',
          icon: Icons.category,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'AI Tanı Önerileri',
          icon: Icons.psychology,
          onTap: () {},
        ),
      ],
    );
  }
}