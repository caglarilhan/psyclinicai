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
  State<SessionManagementScreen> createState() =>
      _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late TabController _tabController;
  int _selectedSessionIndex = -1;

  // --- Mock Data ---

  final List<Map<String, dynamic>> _todaySessions = [
    {
      'time': '09:00 - 09:50',
      'patient': 'Ayse Yilmaz',
      'type': 'Bireysel',
      'status': 'Tamamlandi',
      'notes': 'Kaygi bozuklugu takibi. Ilerleme olumlu.',
    },
    {
      'time': '10:00 - 10:50',
      'patient': 'Mehmet Kara',
      'type': 'Bireysel',
      'status': 'Tamamlandi',
      'notes': 'Depresyon tedavisi, ilac uyumu degerlendirildi.',
    },
    {
      'time': '11:00 - 11:50',
      'patient': 'Fatma Demir',
      'type': 'Cift',
      'status': 'Tamamlandi',
      'notes': 'Iliski ici iletisim calismasi.',
    },
    {
      'time': '13:00 - 13:50',
      'patient': 'Ali Ozturk',
      'type': 'Bireysel',
      'status': 'Devam Ediyor',
      'notes': '',
    },
    {
      'time': '14:00 - 14:50',
      'patient': 'Zeynep Aksoy',
      'type': 'Aile',
      'status': 'Bekliyor',
      'notes': '',
    },
    {
      'time': '15:00 - 15:50',
      'patient': 'Kemal Sahin',
      'type': 'Grup',
      'status': 'Bekliyor',
      'notes': '',
    },
  ];

  final List<Map<String, dynamic>> _sessionHistory = [
    {
      'date': '24 Mar 2026',
      'patient': 'Ayse Yilmaz',
      'type': 'Bireysel',
      'duration': '50 dk',
      'notes': 'BDT oturumu. Dusunce kayitlari incelendi.',
    },
    {
      'date': '24 Mar 2026',
      'patient': 'Hasan Celik',
      'type': 'Bireysel',
      'duration': '50 dk',
      'notes': 'Travma sonrasi stres; EMDR protokolu uygulandi.',
    },
    {
      'date': '23 Mar 2026',
      'patient': 'Fatma Demir',
      'type': 'Cift',
      'duration': '80 dk',
      'notes': 'Gottman metodu; duygu haritasi calismasi.',
    },
    {
      'date': '23 Mar 2026',
      'patient': 'Mehmet Kara',
      'type': 'Bireysel',
      'duration': '50 dk',
      'notes': 'Ilac degisikligi sonrasi izlem.',
    },
    {
      'date': '22 Mar 2026',
      'patient': 'Elif Yildiz',
      'type': 'Bireysel',
      'duration': '50 dk',
      'notes': 'Sosyal fobi; maruz birakma plani olusturuldu.',
    },
    {
      'date': '21 Mar 2026',
      'patient': 'Kemal Sahin',
      'type': 'Grup',
      'duration': '90 dk',
      'notes': 'Ozkiyim destek grubu oturumu.',
    },
    {
      'date': '20 Mar 2026',
      'patient': 'Zeynep Aksoy',
      'type': 'Aile',
      'duration': '75 dk',
      'notes': 'Aile ici sinir belirleme calismasi.',
    },
  ];

  final List<Map<String, dynamic>> _sessionNotes = [
    {
      'title': 'Ayse Yilmaz - BDT Oturumu',
      'date': '24 Mar 2026',
      'preview':
          'Hasta kaygi seviyesinde belirgin azalma bildirdi. Otomatik dusunce kayitlari duzenli tutuluyor. Bir sonraki seansta davranissal deneyler planlanacak.',
    },
    {
      'title': 'Mehmet Kara - Ilac Izlemi',
      'date': '23 Mar 2026',
      'preview':
          'Sertralin 50mg dozuna uyum iyi. Uyku duzeninde iyilesme mevcut. Yan etki olarak hafif bulanti bildiriliyor, takip edilecek.',
    },
    {
      'title': 'Fatma Demir - Cift Terapisi',
      'date': '23 Mar 2026',
      'preview':
          'Ciftler arasinda iletisim kaliplari incelendi. Aktif dinleme egzersizleri verildi. Ev odevi: gunluk 15 dakika kaliteli zaman.',
    },
    {
      'title': 'Hasan Celik - EMDR Protokolu',
      'date': '24 Mar 2026',
      'preview':
          'Travmatik ani uzerinde islem yapildi. SUD puani 8den 3e dustu. Bilateral stimulasyon etkili. Gelecek seans kapatma asamasi planlanacak.',
    },
    {
      'title': 'Zeynep Aksoy - Aile Degerlendirmesi',
      'date': '20 Mar 2026',
      'preview':
          'Aile dinamikleri haritalandi. Rollerin yeniden belirlenmesi gerekiyor. Anne-kiz iliskisinde sinir ihlalleri tespit edildi.',
    },
  ];

  final List<Map<String, dynamic>> _aiInsights = [
    {
      'title': 'Risk Degerlendirmesi',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFF59E0B),
      'items': [
        'Mehmet Kara: Depresyon puanlarinda son 2 haftada yukselis trendi.',
        'Kemal Sahin: Grup terapisine katilim dusuyor, bireysel gorusme onerilir.',
      ],
    },
    {
      'title': 'Tedavi Ilerleme Ozeti',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF10B981),
      'items': [
        'Ayse Yilmaz: BDT protokolunde %70 ilerleme. Hedeflerin %4/6 si tamamlandi.',
        'Hasan Celik: EMDR tedavisinde olumlu yanit. SUD puanlari dusiyor.',
        'Elif Yildiz: Sosyal fobi belirtilerinde %35 azalma.',
      ],
    },
    {
      'title': 'Seans Analitigi',
      'icon': Icons.analytics_rounded,
      'color': AppTheme.primaryColor,
      'items': [
        'Bu hafta ortalama seans suresi: 50 dakika.',
        'En yogun gun: Pazartesi (6 seans).',
        'Iptal orani bu ay: %8 (gecen ay: %12).',
        'Danisan memnuniyet puani ortalamasi: 4.6/5.',
      ],
    },
    {
      'title': 'Oneriler',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFF8B5CF6),
      'items': [
        'Fatma Demir icin Gottman Ses Protokolu nun bir sonraki asamasina gecilebilir.',
        'Mehmet Kara icin psikiyatri konsultasyonu degerlendirilmeli.',
        'Grup terapisi icin yeni uyeler alinabilir (mevcut: 5, kapasite: 8).',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  // --- Status helpers ---

  Color _statusColor(String status) {
    switch (status) {
      case 'Tamamlandi':
        return const Color(0xFF10B981);
      case 'Devam Ediyor':
        return const Color(0xFF3B82F6);
      case 'Bekliyor':
        return const Color(0xFFF59E0B);
      case 'Iptal':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBackground(String status) {
    return _statusColor(status).withValues(alpha: 0.1);
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Bireysel':
        return Icons.person_rounded;
      case 'Cift':
        return Icons.people_rounded;
      case 'Aile':
        return Icons.family_restroom_rounded;
      case 'Grup':
        return Icons.groups_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  /// Returns a tint color based on session time position relative to now.
  Color _timeSlotColor(int index) {
    // Simulate: first 3 sessions are past, index 3 is current, rest upcoming
    if (index < 3) {
      return const Color(0xFFF3F4F6); // grey - past
    } else if (index == 3) {
      return AppTheme.primaryColor.withValues(alpha: 0.06); // blue-purple - current
    }
    return Colors.transparent; // upcoming - default
  }

  // ---- Build methods ----

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Seans Yonetimi',
      child: Column(
        children: [
          _buildKpiRow(),
          const SizedBox(height: 16),
          _buildTabBar(),
          const SizedBox(height: 2),
          Expanded(child: _buildTabContent()),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.save_rounded),
          tooltip: 'Kaydet (Ctrl+S)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Yeni Seans (Ctrl+N)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Yeni Seans',
          icon: Icons.add_circle_outline_rounded,
          onTap: () {},
        ),
        DesktopSidebarItem(
          title: 'Seans Gecmisi',
          icon: Icons.history_rounded,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Notlar',
          icon: Icons.note_alt_rounded,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'AI Ozet',
          icon: Icons.auto_awesome_rounded,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
    );
  }

  // --- KPI Cards ---

  Widget _buildKpiRow() {
    return Row(
      children: [
        _buildKpiCard(
          title: 'Bugun',
          value: '6',
          subtitle: 'Seans',
          icon: Icons.today_rounded,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        _buildKpiCard(
          title: 'Bu Hafta',
          value: '24',
          subtitle: 'Seans',
          icon: Icons.date_range_rounded,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 12),
        _buildKpiCard(
          title: 'Ortalama Sure',
          value: '50',
          subtitle: 'dk',
          icon: Icons.timer_rounded,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(width: 12),
        _buildKpiCard(
          title: 'Tamamlanma',
          value: '%92',
          subtitle: '',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: color,
                          height: 1.1,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Tabs ---

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Bugunku Seanslar'),
          Tab(text: 'Seans Gecmisi'),
          Tab(text: 'Notlar'),
          Tab(text: 'AI Ozet'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTodaySessionsTab(),
        _buildHistoryTab(),
        _buildNotesTab(),
        _buildAiSummaryTab(),
      ],
    );
  }

  // ===== Tab 1: Bugunku Seanslar =====

  Widget _buildTodaySessionsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                _headerCell('Saat', flex: 2),
                _headerCell('Danisan', flex: 3),
                _headerCell('Tur', flex: 2),
                _headerCell('Durum', flex: 2),
                _headerCell('', flex: 1),
              ],
            ),
          ),
          // Session rows
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _todaySessions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final s = _todaySessions[index];
                final isSelected = _selectedSessionIndex == index;
                return Material(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.07)
                      : _timeSlotColor(index),
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedSessionIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          // Time
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: index == 3
                                      ? AppTheme.primaryColor
                                      : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s['time'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: index == 3
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: index == 3
                                        ? AppTheme.primaryColor
                                        : const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Patient
                          Expanded(
                            flex: 3,
                            child: Text(
                              s['patient'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          // Type
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  _typeIcon(s['type']),
                                  size: 16,
                                  color: const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s['type'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status
                          Expanded(
                            flex: 2,
                            child: _buildStatusBadge(s['status']),
                          ),
                          // Action
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }

  // ===== Tab 2: Seans Gecmisi =====

  Widget _buildHistoryTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Search / filter bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Gecmis seanslarda ara...',
                      hintStyle: TextStyle(
                          fontSize: 13, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_rounded,
                          size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 4),
                      Text(
                        'Filtrele',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              itemCount: _sessionHistory.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final h = _sessionHistory[index];
                return Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date badge
                          Container(
                            width: 52,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  h['date'].toString().split(' ')[0],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                Text(
                                  h['date'].toString().split(' ')[1],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      h['patient'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        h['type'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      h['duration'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  h['notes'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 20, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== Tab 3: Notlar =====

  Widget _buildNotesTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.note_alt_rounded,
                    size: 18, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                const Text(
                  'Seans Notlari',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Yeni Not',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _sessionNotes.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final n = _sessionNotes[index];
                return Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              Text(
                                n['date'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n['preview'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== Tab 4: AI Ozet =====

  Widget _buildAiSummaryTab() {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4),
      itemCount: _aiInsights.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final insight = _aiInsights[index];
        final Color color = insight['color'] as Color;
        final List<String> items =
            (insight['items'] as List).cast<String>();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12)),
                  border: Border(
                    bottom:
                        BorderSide(color: color.withValues(alpha: 0.15)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        insight['icon'] as IconData,
                        size: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      insight['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${items.length} madde',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              // Items
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Column(
                  children: items.map((item) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
