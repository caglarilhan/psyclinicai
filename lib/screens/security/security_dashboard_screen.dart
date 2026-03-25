import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../services/keyboard_shortcuts_service.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() =>
      _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();

  // Renk sabitleri
  static const Color _safeColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _dangerColor = Color(0xFFEF4444);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _headerText = Color(0xFF1E293B);
  static const Color _subtitleText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupShortcuts();
  }

  void _setupShortcuts() {
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.digit1),
      () => _tabController.animateTo(0),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.digit2),
      () => _tabController.animateTo(1),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.digit3),
      () => _tabController.animateTo(2),
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.digit4),
      () => _tabController.animateTo(3),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Guvenlik & Uyumluluk',
      child: Column(
        children: [
          _buildKpiRow(),
          const SizedBox(height: 16),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGenelBakisTab(),
                _buildDenetimKayitlariTab(),
                _buildUyumlulukTab(),
                _buildErisimKontrolTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // KPI Kartlari
  // ---------------------------------------------------------------
  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'Guvenlik Skoru',
            value: '94',
            subtitle: '/ 100',
            icon: Icons.shield_outlined,
            color: _safeColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Aktif Tehdit',
            value: '0',
            subtitle: 'Tespit edilmedi',
            icon: Icons.bug_report_outlined,
            color: _safeColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'KVKK Uyumu',
            value: '%98.5',
            subtitle: 'Uyumluluk orani',
            icon: Icons.verified_outlined,
            color: _safeColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
            title: 'Son Denetim',
            value: '2',
            subtitle: 'Gun Once',
            icon: Icons.history_outlined,
            color: AppTheme.primaryColor,
          ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _subtitleText,
                  ),
                ),
                const SizedBox(height: 4),
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
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _subtitleText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tab Bar
  // ---------------------------------------------------------------
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: _subtitleText,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Genel Bakis'),
          Tab(text: 'Denetim Kayitlari'),
          Tab(text: 'Uyumluluk'),
          Tab(text: 'Erisim Kontrolu'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TAB 1 - Genel Bakis
  // ---------------------------------------------------------------
  Widget _buildGenelBakisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRecentActivityCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildSystemStatusCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    final activities = [
      _ActivityItem(
        zaman: '14:32',
        kullanici: 'Dr. Ayse Yilmaz',
        eylem: 'Hasta kaydina erisim sagladi',
        durum: _StatusType.safe,
      ),
      _ActivityItem(
        zaman: '13:15',
        kullanici: 'Sistem',
        eylem: 'Otomatik yedekleme tamamlandi',
        durum: _StatusType.safe,
      ),
      _ActivityItem(
        zaman: '12:47',
        kullanici: 'Dr. Mehmet Kaya',
        eylem: 'Rapor disa aktarildi',
        durum: _StatusType.warning,
      ),
      _ActivityItem(
        zaman: '11:30',
        kullanici: 'Sistem',
        eylem: 'Guvenlik taramas tamamlandi - temiz',
        durum: _StatusType.safe,
      ),
      _ActivityItem(
        zaman: '10:05',
        kullanici: 'Admin',
        eylem: 'Kullanici izinleri guncellendi',
        durum: _StatusType.safe,
      ),
      _ActivityItem(
        zaman: '09:22',
        kullanici: 'Sistem',
        eylem: 'SSL sertifikasi yenilendi',
        durum: _StatusType.safe,
      ),
    ];

    return _buildSectionCard(
      title: 'Son Aktiviteler',
      icon: Icons.timeline_outlined,
      child: Column(
        children: activities.map((a) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildStatusDot(a.durum),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  child: Text(
                    a.zaman,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _subtitleText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: Text(
                    a.kullanici,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _headerText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    a.eylem,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _subtitleText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    final statuses = [
      _SystemStatus(
          baslik: 'Veritabani', durum: 'Calisir', tip: _StatusType.safe),
      _SystemStatus(
          baslik: 'Guvenlik Duvari', durum: 'Aktif', tip: _StatusType.safe),
      _SystemStatus(
          baslik: 'SSL/TLS', durum: 'Gecerli', tip: _StatusType.safe),
      _SystemStatus(
          baslik: 'Yedekleme', durum: 'Guncel', tip: _StatusType.safe),
      _SystemStatus(
          baslik: 'Anti-Virus', durum: 'Aktif', tip: _StatusType.safe),
      _SystemStatus(
          baslik: 'Disk Alani',
          durum: '%72 Kullanildi',
          tip: _StatusType.warning),
    ];

    return _buildSectionCard(
      title: 'Sistem Durumu',
      icon: Icons.monitor_heart_outlined,
      child: Column(
        children: statuses.map((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildStatusDot(s.tip),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.baslik,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _headerText,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorForStatus(s.tip).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.durum,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _colorForStatus(s.tip),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------
  // TAB 2 - Denetim Kayitlari
  // ---------------------------------------------------------------
  Widget _buildDenetimKayitlariTab() {
    final logs = [
      _AuditLog(
        tarih: '2026-03-25 14:32:10',
        kullanici: 'Dr. Ayse Yilmaz',
        eylem: 'Hasta kaydini goruntuledi',
        ip: '192.168.1.45',
        durum: _StatusType.safe,
      ),
      _AuditLog(
        tarih: '2026-03-25 13:15:42',
        kullanici: 'Sistem',
        eylem: 'Otomatik yedekleme baslatildi',
        ip: '10.0.0.1',
        durum: _StatusType.safe,
      ),
      _AuditLog(
        tarih: '2026-03-25 12:47:33',
        kullanici: 'Dr. Mehmet Kaya',
        eylem: 'PDF rapor disa aktarimi',
        ip: '192.168.1.52',
        durum: _StatusType.warning,
      ),
      _AuditLog(
        tarih: '2026-03-25 11:30:05',
        kullanici: 'Sistem',
        eylem: 'Guvenlik taramasi tamamlandi',
        ip: '10.0.0.1',
        durum: _StatusType.safe,
      ),
      _AuditLog(
        tarih: '2026-03-25 10:05:19',
        kullanici: 'Admin',
        eylem: 'Kullanici rolu degistirildi',
        ip: '192.168.1.10',
        durum: _StatusType.safe,
      ),
      _AuditLog(
        tarih: '2026-03-24 23:00:00',
        kullanici: 'Sistem',
        eylem: 'Basarisiz giris denemesi (3 kez)',
        ip: '85.104.22.178',
        durum: _StatusType.danger,
      ),
      _AuditLog(
        tarih: '2026-03-24 18:42:11',
        kullanici: 'Dr. Zeynep Demir',
        eylem: 'Seans notu olusturuldu',
        ip: '192.168.1.60',
        durum: _StatusType.safe,
      ),
      _AuditLog(
        tarih: '2026-03-24 16:10:55',
        kullanici: 'Admin',
        eylem: 'Guvenlik politikasi guncellendi',
        ip: '192.168.1.10',
        durum: _StatusType.safe,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: _buildSectionCard(
        title: 'Denetim Kayitlari',
        icon: Icons.receipt_long_outlined,
        child: Column(
          children: [
            // Tablo basligi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 170,
                    child: Text(
                      'Tarih / Saat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      'Kullanici',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Eylem',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Text(
                      'IP Adresi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      'Durum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Tablo satirlari
            ...logs.map((log) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        log.tarih,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _subtitleText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        log.kullanici,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _headerText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        log.eylem,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _headerText,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: Text(
                        log.ip,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _subtitleText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: _buildStatusBadge(log.durum),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // TAB 3 - Uyumluluk
  // ---------------------------------------------------------------
  Widget _buildUyumlulukTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          _buildComplianceCard(
            baslik: 'KVKK (Kisisel Verilerin Korunmasi Kanunu)',
            yuzde: 0.985,
            durum: _StatusType.safe,
            maddeler: [
              _ComplianceItem(
                  madde: 'Acik riza yonetimi', tamam: true),
              _ComplianceItem(
                  madde: 'Veri isleme envanteri', tamam: true),
              _ComplianceItem(
                  madde: 'Veri saklama politikasi', tamam: true),
              _ComplianceItem(
                  madde: 'Veri ihlali bildirim proseduru', tamam: true),
              _ComplianceItem(
                  madde: 'Kisisel veri silme mekanizmasi', tamam: true),
              _ComplianceItem(
                  madde: 'Ucuncu taraf veri paylasim sozlesmeleri',
                  tamam: false),
            ],
          ),
          const SizedBox(height: 16),
          _buildComplianceCard(
            baslik: 'HIPAA (Saglik Sigortasi Tasinabilirlik ve Sorumluluk)',
            yuzde: 0.92,
            durum: _StatusType.safe,
            maddeler: [
              _ComplianceItem(
                  madde: 'Hasta verisi sifreleme (AES-256)', tamam: true),
              _ComplianceItem(
                  madde: 'Erisim kontrolu ve kimlik dogrulama', tamam: true),
              _ComplianceItem(
                  madde: 'Denetim kayitlari', tamam: true),
              _ComplianceItem(
                  madde: 'Veri yedekleme ve felaket kurtarma', tamam: true),
              _ComplianceItem(
                  madde: 'Is ortagi sozlesmeleri (BAA)',
                  tamam: false),
              _ComplianceItem(
                  madde: 'Yillik risk degerlendirmesi', tamam: false),
            ],
          ),
          const SizedBox(height: 16),
          _buildComplianceCard(
            baslik: 'GDPR (Genel Veri Koruma Tuzugu)',
            yuzde: 0.95,
            durum: _StatusType.safe,
            maddeler: [
              _ComplianceItem(
                  madde: 'Veri isleme hukuki dayanak', tamam: true),
              _ComplianceItem(
                  madde: 'Veri koruma etki degerlendirmesi (DPIA)',
                  tamam: true),
              _ComplianceItem(
                  madde: 'Unutulma hakki uygulamasi', tamam: true),
              _ComplianceItem(
                  madde: 'Veri tasima hakki', tamam: true),
              _ComplianceItem(
                  madde: 'Cerez onay yonetimi', tamam: true),
              _ComplianceItem(
                  madde: 'Sinir otesi veri aktarim degerlendirmesi',
                  tamam: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard({
    required String baslik,
    required double yuzde,
    required _StatusType durum,
    required List<_ComplianceItem> maddeler,
  }) {
    final tamamlanan = maddeler.where((m) => m.tamam).length;
    final toplam = maddeler.length;
    final color = _colorForStatus(durum);

    return _buildSectionCard(
      title: baslik,
      icon: Icons.policy_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ilerleme cubugu
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$tamamlanan / $toplam madde tamamlandi',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _headerText,
                          ),
                        ),
                        Text(
                          '%${(yuzde * 100).toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: yuzde,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Maddeler
          ...maddeler.map((m) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    m.tamam
                        ? Icons.check_circle_outlined
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: m.tamam ? _safeColor : _warningColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      m.madde,
                      style: TextStyle(
                        fontSize: 13,
                        color: m.tamam ? _headerText : _warningColor,
                        fontWeight:
                            m.tamam ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: m.tamam
                          ? _safeColor.withOpacity(0.1)
                          : _warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      m.tamam ? 'Tamamlandi' : 'Beklemede',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: m.tamam ? _safeColor : _warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TAB 4 - Erisim Kontrolu
  // ---------------------------------------------------------------
  Widget _buildErisimKontrolTab() {
    final users = [
      _AccessUser(
        ad: 'Dr. Ayse Yilmaz',
        rol: 'Psikolog',
        sonGiris: '2026-03-25 14:32',
        ikiFA: true,
        durum: _StatusType.safe,
      ),
      _AccessUser(
        ad: 'Dr. Mehmet Kaya',
        rol: 'Psikolog',
        sonGiris: '2026-03-25 12:47',
        ikiFA: true,
        durum: _StatusType.safe,
      ),
      _AccessUser(
        ad: 'Dr. Zeynep Demir',
        rol: 'Psikolog',
        sonGiris: '2026-03-24 18:42',
        ikiFA: true,
        durum: _StatusType.safe,
      ),
      _AccessUser(
        ad: 'Fatma Celik',
        rol: 'Sekreter',
        sonGiris: '2026-03-25 09:00',
        ikiFA: false,
        durum: _StatusType.warning,
      ),
      _AccessUser(
        ad: 'Admin',
        rol: 'Sistem Yoneticisi',
        sonGiris: '2026-03-25 10:05',
        ikiFA: true,
        durum: _StatusType.safe,
      ),
      _AccessUser(
        ad: 'Ahmet Ozturk',
        rol: 'Stajyer',
        sonGiris: '2026-03-20 16:30',
        ikiFA: false,
        durum: _StatusType.danger,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: _buildSectionCard(
        title: 'Kullanici Erisim Listesi',
        icon: Icons.people_outline,
        child: Column(
          children: [
            // Tablo basligi
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      'Kullanici',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(
                      'Rol',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Son Giris',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      '2FA Durum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      'Durum',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _subtitleText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...users.map((u) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              u.ad[0],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              u.ad,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _headerText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        u.rol,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _subtitleText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        u.sonGiris,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _subtitleText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: u.ikiFA
                              ? _safeColor.withOpacity(0.1)
                              : _dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              u.ikiFA ? Icons.lock_outlined : Icons.lock_open,
                              size: 14,
                              color: u.ikiFA ? _safeColor : _dangerColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              u.ikiFA ? 'Aktif' : 'Pasif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: u.ikiFA ? _safeColor : _dangerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: _buildStatusBadge(u.durum),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Ortak Yardimci Widget'lar
  // ---------------------------------------------------------------
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _headerText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusDot(_StatusType tip) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorForStatus(tip),
      ),
    );
  }

  Widget _buildStatusBadge(_StatusType tip) {
    final label = switch (tip) {
      _StatusType.safe => 'Guvenli',
      _StatusType.warning => 'Uyari',
      _StatusType.danger => 'Tehlike',
    };
    final color = _colorForStatus(tip);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _colorForStatus(_StatusType tip) {
    return switch (tip) {
      _StatusType.safe => _safeColor,
      _StatusType.warning => _warningColor,
      _StatusType.danger => _dangerColor,
    };
  }
}

// ---------------------------------------------------------------
// Veri Modelleri
// ---------------------------------------------------------------
enum _StatusType { safe, warning, danger }

class _ActivityItem {
  final String zaman;
  final String kullanici;
  final String eylem;
  final _StatusType durum;

  const _ActivityItem({
    required this.zaman,
    required this.kullanici,
    required this.eylem,
    required this.durum,
  });
}

class _SystemStatus {
  final String baslik;
  final String durum;
  final _StatusType tip;

  const _SystemStatus({
    required this.baslik,
    required this.durum,
    required this.tip,
  });
}

class _AuditLog {
  final String tarih;
  final String kullanici;
  final String eylem;
  final String ip;
  final _StatusType durum;

  const _AuditLog({
    required this.tarih,
    required this.kullanici,
    required this.eylem,
    required this.ip,
    required this.durum,
  });
}

class _ComplianceItem {
  final String madde;
  final bool tamam;

  const _ComplianceItem({
    required this.madde,
    required this.tamam,
  });
}

class _AccessUser {
  final String ad;
  final String rol;
  final String sonGiris;
  final bool ikiFA;
  final _StatusType durum;

  const _AccessUser({
    required this.ad,
    required this.rol,
    required this.sonGiris,
    required this.ikiFA,
    required this.durum,
  });
}
