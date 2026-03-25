import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class CRMDashboardScreen extends StatefulWidget {
  const CRMDashboardScreen({super.key});

  @override
  State<CRMDashboardScreen> createState() => _CRMDashboardScreenState();
}

class _CRMDashboardScreenState extends State<CRMDashboardScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedSidebarIndex = 0;

  // --- Mock Data ---
  final List<_ClientData> _clients = [
    _ClientData('Ayse Yilmaz', 'VIP', '15.03.2026', 'ayse.yilmaz@email.com', '+90 532 111 2233'),
    _ClientData('Mehmet Kaya', 'Aktif', '20.03.2026', 'mehmet.kaya@email.com', '+90 533 222 3344'),
    _ClientData('Zeynep Demir', 'Aktif', '18.03.2026', 'zeynep.demir@email.com', '+90 534 333 4455'),
    _ClientData('Ali Ozturk', 'Pasif', '02.02.2026', 'ali.ozturk@email.com', '+90 535 444 5566'),
    _ClientData('Fatma Celik', 'VIP', '22.03.2026', 'fatma.celik@email.com', '+90 536 555 6677'),
    _ClientData('Emre Aksoy', 'Aktif', '19.03.2026', 'emre.aksoy@email.com', '+90 537 666 7788'),
    _ClientData('Selin Arslan', 'Aktif', '21.03.2026', 'selin.arslan@email.com', '+90 538 777 8899'),
    _ClientData('Burak Sahin', 'Pasif', '10.01.2026', 'burak.sahin@email.com', '+90 539 888 9900'),
    _ClientData('Deniz Korkmaz', 'Aktif', '23.03.2026', 'deniz.korkmaz@email.com', '+90 540 999 0011'),
    _ClientData('Elif Tekin', 'VIP', '24.03.2026', 'elif.tekin@email.com', '+90 541 000 1122'),
  ];

  final List<_CommunicationEntry> _communications = [
    _CommunicationEntry('Ayse Yilmaz', 'Telefon', '24.03.2026 14:30', 'Seans hatirlatma aramasi yapildi.', Icons.phone),
    _CommunicationEntry('Mehmet Kaya', 'E-posta', '24.03.2026 11:15', 'Randevu onay maili gonderildi.', Icons.email),
    _CommunicationEntry('Fatma Celik', 'SMS', '23.03.2026 09:00', 'Yeni kampanya bilgilendirmesi yapildi.', Icons.sms),
    _CommunicationEntry('Zeynep Demir', 'Telefon', '22.03.2026 16:45', 'Terapi sureci hakkinda bilgilendirme.', Icons.phone),
    _CommunicationEntry('Emre Aksoy', 'E-posta', '22.03.2026 10:00', 'Odeme hatirlatmasi gonderildi.', Icons.email),
    _CommunicationEntry('Elif Tekin', 'SMS', '21.03.2026 08:30', 'Randevu hatirlatmasi gonderildi.', Icons.sms),
    _CommunicationEntry('Selin Arslan', 'Telefon', '20.03.2026 15:00', 'Memnuniyet anketi yapildi.', Icons.phone),
    _CommunicationEntry('Ali Ozturk', 'E-posta', '19.03.2026 13:20', 'Tekrar basvuru daveti gonderildi.', Icons.email),
  ];

  final List<_CampaignData> _campaigns = [
    _CampaignData('Bahar Indirimi 2026', 450, 'Aktif', 68.5),
    _CampaignData('Yeni Danisan Karsilama', 320, 'Aktif', 74.2),
    _CampaignData('Sadakat Programi', 185, 'Aktif', 81.0),
    _CampaignData('Yildonumu Kampanyasi', 290, 'Tamamlandi', 72.8),
    _CampaignData('Online Terapi Tanitimi', 510, 'Aktif', 59.3),
    _CampaignData('Referans Programi', 140, 'Planlandi', 0.0),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedSidebarIndex = _tabController.index;
        });
      }
    });
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _removeKeyboardShortcuts();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () {
        _showNewClientDialog();
      },
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () {
        _focusSearch();
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

  void _showNewClientDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Musteri Ekle'),
        content: const Text('Yeni musteri kayit formu yakin zamanda eklenecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _focusSearch() {
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  void _navigateToTab(int index) {
    _tabController.animateTo(index);
    setState(() {
      _selectedSidebarIndex = index;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Aktif':
        return const Color(0xFF10B981);
      case 'Pasif':
        return const Color(0xFF9CA3AF);
      case 'VIP':
        return const Color(0xFF8B5CF6);
      case 'Tamamlandi':
        return const Color(0xFF3B82F6);
      case 'Planlandi':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<_ClientData> get _filteredClients {
    if (_searchQuery.isEmpty) return _clients;
    final q = _searchQuery.toLowerCase();
    return _clients.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.status.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'CRM Yonetim Paneli',
      child: Column(
        children: [
          _buildKPICards(),
          const SizedBox(height: 2),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMusteriYonetimiTab(),
                _buildIletisimGecmisiTab(),
                _buildKampanyalarTab(),
                _buildRaporlarTab(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showNewClientDialog,
          icon: const Icon(Icons.person_add_alt_1),
          tooltip: 'Yeni Musteri (Ctrl+N)',
        ),
        IconButton(
          onPressed: _focusSearch,
          icon: const Icon(Icons.search),
          tooltip: 'Ara (Ctrl+S)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Rapor Indir',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Ayarlar',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Musteri Yonetimi',
          icon: Icons.people_outline,
          onTap: () => _navigateToTab(0),
        ),
        DesktopSidebarItem(
          title: 'Iletisim Gecmisi',
          icon: Icons.history,
          onTap: () => _navigateToTab(1),
        ),
        DesktopSidebarItem(
          title: 'Kampanyalar',
          icon: Icons.campaign_outlined,
          onTap: () => _navigateToTab(2),
        ),
        DesktopSidebarItem(
          title: 'Raporlar',
          icon: Icons.assessment_outlined,
          onTap: () => _navigateToTab(3),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Cards
  // ---------------------------------------------------------------------------
  Widget _buildKPICards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        children: [
          Expanded(
            child: _KPICard(
              title: 'Toplam Musteri',
              value: '1,247',
              icon: Icons.groups_outlined,
              color: AppTheme.primaryColor,
              trend: '+12%',
              trendPositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KPICard(
              title: 'Aktif Danisan',
              value: '384',
              icon: Icons.person_outline,
              color: const Color(0xFF10B981),
              trend: '+5%',
              trendPositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KPICard(
              title: 'Yeni Kayit (Bu Ay)',
              value: '42',
              icon: Icons.person_add_alt_1_outlined,
              color: const Color(0xFF3B82F6),
              trend: '+18%',
              trendPositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KPICard(
              title: 'Memnuniyet',
              value: '4.7 / 5.0',
              icon: Icons.star_outline_rounded,
              color: const Color(0xFFF59E0B),
              trend: '+0.2',
              trendPositive: true,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Bar
  // ---------------------------------------------------------------------------
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'Musteri Yonetimi'),
          Tab(text: 'Iletisim Gecmisi'),
          Tab(text: 'Kampanyalar'),
          Tab(text: 'Raporlar'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1 -- Musteri Yonetimi
  // ---------------------------------------------------------------------------
  Widget _buildMusteriYonetimiTab() {
    final clients = _filteredClients;
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Musteri ara (isim, durum, e-posta)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
        // Client list header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: const Row(
            children: [
              SizedBox(width: 48),
              Expanded(flex: 3, child: Text('Musteri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              Expanded(flex: 2, child: Text('E-posta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              Expanded(flex: 2, child: Text('Telefon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              Expanded(flex: 1, child: Text('Son Ziyaret', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              SizedBox(width: 80, child: Text('Durum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
            ],
          ),
        ),
        // Client list
        Expanded(
          child: clients.isEmpty
              ? const Center(
                  child: Text(
                    'Aramanizla eslesen musteri bulunamadi.',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                )
              : ListView.separated(
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final c = clients[index];
                    return _buildClientRow(c);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildClientRow(_ClientData client) {
    final statusCol = _statusColor(client.status);
    final initials = client.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: statusCol.withOpacity(0.15),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusCol,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              flex: 3,
              child: Text(
                client.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              ),
            ),
            // Email
            Expanded(
              flex: 2,
              child: Text(
                client.email,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Phone
            Expanded(
              flex: 2,
              child: Text(
                client.phone,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
            // Last visit
            Expanded(
              flex: 1,
              child: Text(
                client.lastVisit,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
            // Status badge
            SizedBox(
              width: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusCol.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  client.status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusCol,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2 -- Iletisim Gecmisi
  // ---------------------------------------------------------------------------
  Widget _buildIletisimGecmisiTab() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _communications.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final entry = _communications[index];
        final typeColor = entry.type == 'Telefon'
            ? const Color(0xFF10B981)
            : entry.type == 'E-posta'
                ? const Color(0xFF3B82F6)
                : const Color(0xFFF59E0B);
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.icon, color: typeColor, size: 20),
          ),
          title: Row(
            children: [
              Text(
                entry.clientName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.type,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              entry.description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          trailing: Text(
            entry.dateTime,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3 -- Kampanyalar
  // ---------------------------------------------------------------------------
  Widget _buildKampanyalarTab() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Kampanya Adi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              Expanded(flex: 1, child: Text('Hedef Kisi', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              Expanded(flex: 1, child: Text('Durum', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
              Expanded(flex: 2, child: Text('Basari Orani', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _campaigns.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final c = _campaigns[index];
              final statusCol = _statusColor(c.status);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Name
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.campaign_outlined, size: 18, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              c.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Target
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${c.targetCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                      ),
                    ),
                    // Status
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusCol.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c.status,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusCol),
                          ),
                        ),
                      ),
                    ),
                    // Success rate bar
                    Expanded(
                      flex: 2,
                      child: c.successRate > 0
                          ? Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: c.successRate / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        c.successRate >= 75
                                            ? const Color(0xFF10B981)
                                            : c.successRate >= 50
                                                ? const Color(0xFFF59E0B)
                                                : const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '%${c.successRate.toStringAsFixed(1)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                ),
                              ],
                            )
                          : const Text(
                              'Henuz baslamadi',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4 -- Raporlar
  // ---------------------------------------------------------------------------
  Widget _buildRaporlarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Genel Ozet Istatistikleri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          // Stats grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildReportCard('Toplam Seans (Bu Ay)', '1,856', Icons.event_note_outlined, const Color(0xFF6B46C1)),
              _buildReportCard('Ortalama Seans Suresi', '48 dk', Icons.timer_outlined, const Color(0xFF3B82F6)),
              _buildReportCard('Randevu Iptal Orani', '%4.2', Icons.event_busy_outlined, const Color(0xFFEF4444)),
              _buildReportCard('Yeni Musteri Donusum', '%32.5', Icons.trending_up, const Color(0xFF10B981)),
              _buildReportCard('Aktif Kampanya Sayisi', '4', Icons.campaign_outlined, const Color(0xFFF59E0B)),
              _buildReportCard('Toplam Gelir (Bu Ay)', '248,500 TL', Icons.account_balance_wallet_outlined, const Color(0xFF8B5CF6)),
              _buildReportCard('Musteri Kayip Orani', '%2.8', Icons.person_remove_outlined, const Color(0xFFEF4444)),
              _buildReportCard('Ort. Musteri Yasam Suresi', '14.3 ay', Icons.access_time_outlined, const Color(0xFF3B82F6)),
              _buildReportCard('NPS Skoru', '72', Icons.thumb_up_outlined, const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Durum Dagilimi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          // Distribution bars
          _buildDistributionRow('Aktif Danisanlar', 384, 1247, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _buildDistributionRow('VIP Musteriler', 127, 1247, const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _buildDistributionRow('Pasif Musteriler', 312, 1247, const Color(0xFF9CA3AF)),
          const SizedBox(height: 8),
          _buildDistributionRow('Yeni Kayitlar (Ay)', 42, 1247, const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String label, int count, int total, Color color) {
    final ratio = count / total;
    final pct = (ratio * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 50,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 50,
            child: Text(
              '(%$pct)',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// KPI Card Widget
// =============================================================================
class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendPositive;

  const _KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
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
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trendPositive
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  trendPositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: trendPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Data Models
// =============================================================================
class _ClientData {
  final String name;
  final String status;
  final String lastVisit;
  final String email;
  final String phone;

  const _ClientData(this.name, this.status, this.lastVisit, this.email, this.phone);
}

class _CommunicationEntry {
  final String clientName;
  final String type;
  final String dateTime;
  final String description;
  final IconData icon;

  const _CommunicationEntry(this.clientName, this.type, this.dateTime, this.description, this.icon);
}

class _CampaignData {
  final String name;
  final int targetCount;
  final String status;
  final double successRate;

  const _CampaignData(this.name, this.targetCount, this.status, this.successRate);
}
