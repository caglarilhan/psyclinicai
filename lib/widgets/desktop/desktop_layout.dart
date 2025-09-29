import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../../utils/desktop_theme.dart';
import '../../services/keyboard_shortcuts_service.dart';

class DesktopLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? sidebar;
  final Widget? rightPanel;
  final bool showStatusBar;
  final bool showShortcuts;
  // Geri uyumluluk: bazı ekranlarda doğrudan sidebarItems geçiliyor
  final List<DesktopSidebarItem>? sidebarItems;

  const DesktopLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.sidebar,
    this.rightPanel,
    this.showStatusBar = true,
    this.showShortcuts = true,
    this.sidebarItems,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  bool _isFullScreen = false;
  bool _isSidebarCollapsed = false;
  bool _isRightPanelCollapsed = false;

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    // F11 - Tam ekran toggle
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.f11),
      _toggleFullScreen,
    );

    // Ctrl+B - Sidebar toggle
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyB),
      _toggleSidebar,
    );

    // Ctrl+P - Right panel toggle
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyP),
      _toggleRightPanel,
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _toggleRightPanel() {
    setState(() {
      _isRightPanelCollapsed = !_isRightPanelCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!DesktopTheme.isDesktop(context)) {
      return widget.child;
    }

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (_shortcutsService.handleKeyEvent(event)) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: DesktopTheme.desktopSurface,
        body: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            
            // Main Content
            Expanded(
              child: Row(
                children: [
                  // Sidebar
                  if ((widget.sidebar != null || (widget.sidebarItems != null && widget.sidebarItems!.isNotEmpty)) && !_isSidebarCollapsed)
                    _buildSidebar(),
                  
                  // Main Content
                  Expanded(
                    child: _buildMainContent(),
                  ),
                  
                  // Right Panel
                  if (widget.rightPanel != null && !_isRightPanelCollapsed)
                    _buildRightPanel(),
                ],
              ),
            ),
            
            // Status Bar
            if (widget.showStatusBar) _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: DesktopTheme.topBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: DesktopTheme.desktopBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo/Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: DesktopTheme.desktopPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Actions
          if (widget.actions != null) ...widget.actions!,
          
          // Sidebar Toggle
          if (widget.sidebar != null)
            IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open),
              tooltip: 'Sidebar ${_isSidebarCollapsed ? 'Aç' : 'Kapat'} (Ctrl+B)',
              onPressed: _toggleSidebar,
            ),
          
          // Right Panel Toggle
          if (widget.rightPanel != null)
            IconButton(
              icon: Icon(_isRightPanelCollapsed ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right),
              tooltip: 'Panel ${_isRightPanelCollapsed ? 'Aç' : 'Kapat'} (Ctrl+P)',
              onPressed: _toggleRightPanel,
            ),
          
          // Full Screen Toggle
          IconButton(
            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            tooltip: 'Tam Ekran (F11)',
            onPressed: _toggleFullScreen,
          ),
          
          // Shortcuts Help
          if (widget.showShortcuts)
            _shortcutsService.buildShortcutsHelpButton(context),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _isSidebarCollapsed ? 60 : DesktopTheme.getSidebarWidth(context),
      color: DesktopTheme.desktopSurface,
      child: Column(
        children: [
          // Sidebar Header
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: DesktopTheme.desktopBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                if (!_isSidebarCollapsed) ...[
                  const Text(
                    'Navigasyon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                ],
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: _toggleSidebar,
                  tooltip: 'Sidebar Kapat',
                ),
              ],
            ),
          ),
          
          // Sidebar Content
          Expanded(
            child: widget.sidebar ?? _buildSidebarFromItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFromItems() {
    final items = widget.sidebarItems ?? const <DesktopSidebarItem>[];
    return DesktopSidebar(
      items: items,
      selectedIndex: 0,
      onItemSelected: (i) {
        final cb = items[i].onTap;
        if (cb != null) cb();
      },
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: DesktopTheme.desktopSurfaceVariant,
      child: Column(
        children: [
          // Content Header
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: DesktopTheme.desktopBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Ana İçerik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                // Breadcrumb or additional info
                Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: _isRightPanelCollapsed ? 60 : DesktopTheme.getPanelWidth(context),
      color: Colors.white,
      child: Column(
        children: [
          // Panel Header
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: DesktopTheme.desktopBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                if (!_isRightPanelCollapsed) ...[
                  const Text(
                    'Detaylar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                ],
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: _toggleRightPanel,
                  tooltip: 'Panel Kapat',
                ),
              ],
            ),
          ),
          
          // Panel Content
          Expanded(
            child: widget.rightPanel!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 30,
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          const Text(
            'Hazır',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const Spacer(),
          if (widget.showShortcuts)
            _shortcutsService.buildShortcutsStatusBar(context),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// Masaüstü sidebar widget'ı
class DesktopSidebar extends StatelessWidget {
  final List<DesktopSidebarItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DesktopSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = index == selectedIndex;
        
        return ListTile(
          leading: Icon(
            item.icon,
            color: isSelected ? DesktopTheme.desktopPrimary : const Color(0xFF64748B),
            size: 20,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? DesktopTheme.desktopPrimary : const Color(0xFF1E293B),
            ),
          ),
          selected: isSelected,
          selectedTileColor: DesktopTheme.desktopPrimary.withOpacity(0.1),
          onTap: () => onItemSelected(index),
        );
      },
    );
  }
}

class DesktopSidebarItem {
  final String title;
  final IconData icon;
  final String? route;
  // Geri uyumluluk: bazı ekranlar onTap bekliyor
  final VoidCallback? onTap;

  const DesktopSidebarItem({
    required this.title,
    required this.icon,
    this.route,
    this.onTap,
  });
}

// Masaüstü panel widget'ı
class DesktopPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const DesktopPanel({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: DesktopTheme.desktopBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
        ),
        
        // Panel Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }
}
