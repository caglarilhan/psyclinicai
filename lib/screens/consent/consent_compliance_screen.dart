import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class ConsentComplianceScreen extends StatefulWidget {
  const ConsentComplianceScreen({super.key});

  @override
  State<ConsentComplianceScreen> createState() =>
      _ConsentComplianceScreenState();
}

class _ConsentComplianceScreenState extends State<ConsentComplianceScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService =
      KeyboardShortcutsService();
  late TabController _tabController;

  final List<_ConsentRecord> _records = [
    _ConsentRecord('Ahmet Yılmaz', 'Tedavi Onamı', '15.03.2026', 'Onaylandı'),
    _ConsentRecord('Ayşe Demir', 'KVKK Aydınlatma', '14.03.2026', 'Onaylandı'),
    _ConsentRecord('Mehmet Kaya', 'Veri İşleme', '13.03.2026', 'Beklemede'),
    _ConsentRecord('Fatma Çelik', 'Tedavi Onamı', '12.03.2026', 'Onaylandı'),
    _ConsentRecord('Ali Öztürk', 'Teleterapi Onamı', '11.03.2026', 'Onaylandı'),
    _ConsentRecord('Zeynep Aydın', 'KVKK Aydınlatma', '10.03.2026', 'Süresi Dolmuş'),
    _ConsentRecord('Hasan Yıldız', 'Veri İşleme', '09.03.2026', 'Beklemede'),
    _ConsentRecord('Elif Arslan', 'Tedavi Onamı', '08.03.2026', 'Onaylandı'),
    _ConsentRecord('Burak Şahin', 'Araştırma Katılım', '07.03.2026', 'Onaylandı'),
    _ConsentRecord('Selin Koç', 'KVKK Aydınlatma', '06.03.2026', 'Süresi Dolmuş'),
  ];

  final List<_ConsentTemplate> _templates = [
    _ConsentTemplate('Tedavi Onam Formu', 'v3.2', '01.02.2026', 'Genel tedavi sürecine ilişkin hasta bilgilendirme ve onam formu'),
    _ConsentTemplate('KVKK Aydınlatma Metni', 'v2.1', '15.01.2026', 'Kişisel verilerin işlenmesine ilişkin aydınlatma metni'),
    _ConsentTemplate('Veri İşleme Onayı', 'v1.8', '10.01.2026', 'Sağlık verilerinin işlenmesine yönelik açık rıza formu'),
    _ConsentTemplate('Teleterapi Onam Formu', 'v1.5', '20.12.2025', 'Uzaktan terapi hizmeti için özel onam formu'),
    _ConsentTemplate('Araştırma Katılım Formu', 'v2.0', '05.12.2025', 'Klinik araştırma katılımcıları için bilgilendirilmiş onam'),
  ];

  final List<_AuditEntry> _auditLog = [
    _AuditEntry('25.03.2026 09:15', 'Dr. Ayşe Kara', 'Onam formu onaylandı', 'Ahmet Yılmaz - Tedavi Onamı'),
    _AuditEntry('24.03.2026 14:30', 'Sistem', 'Otomatik hatırlatma gönderildi', '3 bekleyen onam'),
    _AuditEntry('24.03.2026 10:00', 'Dr. Mehmet Demir', 'Şablon güncellendi', 'KVKK Aydınlatma v2.1'),
    _AuditEntry('23.03.2026 16:45', 'Admin', 'Uyumluluk raporu oluşturuldu', 'Aylık KVKK raporu'),
    _AuditEntry('23.03.2026 11:20', 'Dr. Fatma Çelik', 'Onam formu oluşturuldu', 'Selin Koç - Veri İşleme'),
    _AuditEntry('22.03.2026 09:00', 'Sistem', 'Süresi dolan onamlar tespit edildi', '2 onam süresi dolmuş'),
    _AuditEntry('21.03.2026 15:30', 'Dr. Ali Yıldız', 'Toplu onam gönderildi', '15 hasta - KVKK güncelleme'),
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
      LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () {},
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      () {},
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
      child: Column(
        children: [
          _buildKPICards(),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Onam Kayıtları'),
              Tab(text: 'Şablonlar'),
              Tab(text: 'Uyumluluk'),
              Tab(text: 'Denetim'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordsTab(),
                _buildTemplatesTab(),
                _buildComplianceTab(),
                _buildAuditTab(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.assessment)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Onam Kayıtları',
          icon: Icons.verified_user,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Onam Şablonları',
          icon: Icons.description,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Uyumluluk Raporu',
          icon: Icons.assessment,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Denetim Kayıtları',
          icon: Icons.security,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
    );
  }

  Widget _buildKPICards() {
    return Row(
      children: [
        Expanded(
          child: _buildKPI('Toplam Onam', '847', Icons.verified_user,
              AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPI(
              'Bekleyen', '12', Icons.pending, AppTheme.warningColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPI(
              'KVKK Uyumu', '%98,5', Icons.shield, AppTheme.successColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPI('Son Denetim', '15 Gün Önce', Icons.schedule,
              AppTheme.accentColor),
        ),
      ],
    );
  }

  Widget _buildKPI(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }

  // --- Onam Kayıtları ---
  Widget _buildRecordsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = _records[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(r.patient[0],
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold)),
            ),
            title: Text(r.patient,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${r.type}  -  ${r.date}'),
            trailing: _statusBadge(r.status),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Onaylandı':
        bg = AppTheme.successColor.withValues(alpha: 0.1);
        fg = AppTheme.successColor;
        break;
      case 'Beklemede':
        bg = AppTheme.warningColor.withValues(alpha: 0.1);
        fg = AppTheme.warningColor;
        break;
      case 'Süresi Dolmuş':
        bg = AppTheme.errorColor.withValues(alpha: 0.1);
        fg = AppTheme.errorColor;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // --- Şablonlar ---
  Widget _buildTemplatesTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = _templates[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(t.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(t.version,
                          style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(t.description,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Son Güncelleme: ${t.lastUpdate}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Uyumluluk ---
  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _complianceCard('KVKK', 0.985, AppTheme.successColor, [
            _ComplianceItem('Aydınlatma metni yayınlandı', true),
            _ComplianceItem('Açık rıza formları güncel', true),
            _ComplianceItem('Veri envanteri tamamlandı', true),
            _ComplianceItem('Veri sorumlusu sicil kaydı', true),
            _ComplianceItem('Yıllık denetim raporu', false),
          ]),
          const SizedBox(height: 16),
          _complianceCard('HIPAA', 0.92, AppTheme.primaryColor, [
            _ComplianceItem('PHI erişim kontrolü', true),
            _ComplianceItem('Şifreleme standartları', true),
            _ComplianceItem('BAA sözleşmeleri', true),
            _ComplianceItem('Risk değerlendirmesi', false),
            _ComplianceItem('Personel eğitimi', true),
          ]),
          const SizedBox(height: 16),
          _complianceCard('GDPR', 0.88, AppTheme.accentColor, [
            _ComplianceItem('Gizlilik politikası', true),
            _ComplianceItem('Veri işleme kayıtları', true),
            _ComplianceItem('DPO atanması', true),
            _ComplianceItem('Veri taşınabilirliği', false),
            _ComplianceItem('Etki değerlendirmesi (DPIA)', false),
          ]),
        ],
      ),
    );
  }

  Widget _complianceCard(String title, double progress, Color color,
      List<_ComplianceItem> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        item.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: item.completed
                            ? AppTheme.successColor
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Text(item.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.completed
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                            decoration: item.completed
                                ? null
                                : null,
                          )),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.completed
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.completed ? 'Tamamlandı' : 'Beklemede',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.completed
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // --- Denetim Kayıtları ---
  Widget _buildAuditTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _auditLog.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = _auditLog[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history,
                      color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.action,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(a.detail,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(a.user,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(a.timestamp,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConsentRecord {
  final String patient;
  final String type;
  final String date;
  final String status;
  _ConsentRecord(this.patient, this.type, this.date, this.status);
}

class _ConsentTemplate {
  final String title;
  final String version;
  final String lastUpdate;
  final String description;
  _ConsentTemplate(this.title, this.version, this.lastUpdate, this.description);
}

class _AuditEntry {
  final String timestamp;
  final String user;
  final String action;
  final String detail;
  _AuditEntry(this.timestamp, this.user, this.action, this.detail);
}

class _ComplianceItem {
  final String title;
  final bool completed;
  _ComplianceItem(this.title, this.completed);
}
