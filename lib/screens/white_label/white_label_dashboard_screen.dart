import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
import '../../services/keyboard_shortcuts_service.dart';
import '../../widgets/desktop/desktop_layout.dart';

class WhiteLabelDashboardScreen extends StatefulWidget {
  const WhiteLabelDashboardScreen({super.key});

  @override
  State<WhiteLabelDashboardScreen> createState() =>
      _WhiteLabelDashboardScreenState();
}

class _WhiteLabelDashboardScreenState extends State<WhiteLabelDashboardScreen>
    with TickerProviderStateMixin {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();
  late TabController _tabController;
  int _selectedBrandIndex = 0;

  static const List<_BrandData> _brands = [
    _BrandData(
      name: 'PsyClinic Pro',
      slogan: 'Profesyonel Psikolojik Destek Platformu',
      email: 'info@psyclinicpro.com',
      phone: '+90 212 555 01 01',
      primaryColor: Color(0xFF6B46C1),
      secondaryColor: Color(0xFFEC4899),
      accentColor: Color(0xFF8B5CF6),
      surfaceColor: Color(0xFFF5F3FF),
      fontFamily: 'Inter',
      borderRadius: 12.0,
    ),
    _BrandData(
      name: 'MindCare Plus',
      slogan: 'Zihinsel Saglik ve Terapi Merkezi',
      email: 'destek@mindcareplus.com.tr',
      phone: '+90 216 444 02 02',
      primaryColor: Color(0xFF0D9488),
      secondaryColor: Color(0xFF0EA5E9),
      accentColor: Color(0xFF14B8A6),
      surfaceColor: Color(0xFFF0FDFA),
      fontFamily: 'Roboto',
      borderRadius: 8.0,
    ),
    _BrandData(
      name: 'TerapiNet',
      slogan: 'Online Terapi ve Danismanlik Agi',
      email: 'iletisim@terapinet.com',
      phone: '+90 312 333 03 03',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFFEF4444),
      accentColor: Color(0xFFF59E0B),
      surfaceColor: Color(0xFFFFFBEB),
      fontFamily: 'Poppins',
      borderRadius: 16.0,
    ),
  ];

  _BrandData get _activeBrand => _brands[_selectedBrandIndex];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
      () {},
    );
    _shortcutsService.addShortcut(
      LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control),
      () {},
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
      title: 'White Label Yonetimi',
      child: Column(
        children: [
          _buildCurrentBrandHeader(),
          const SizedBox(height: 16),
          _buildBrandSelector(),
          const SizedBox(height: 16),
          _buildTabBar(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(child: _buildTabContent()),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined),
          tooltip: 'Kaydet (Ctrl+S)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          tooltip: 'Sifirla (Ctrl+R)',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.publish_outlined),
          tooltip: 'Yayinla',
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Marka Ayarlari',
          icon: Icons.branding_watermark,
          onTap: () => _tabController.animateTo(0),
        ),
        DesktopSidebarItem(
          title: 'Tema Ozellestirme',
          icon: Icons.palette,
          onTap: () => _tabController.animateTo(1),
        ),
        DesktopSidebarItem(
          title: 'Logo Yonetimi',
          icon: Icons.image_outlined,
          onTap: () => _tabController.animateTo(2),
        ),
        DesktopSidebarItem(
          title: 'Onizleme',
          icon: Icons.preview_outlined,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Current brand info header
  // ---------------------------------------------------------------------------
  Widget _buildCurrentBrandHeader() {
    final brand = _activeBrand;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brand.primaryColor,
            brand.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                brand.name.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  brand.slogan,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Brand selector chips
  // ---------------------------------------------------------------------------
  Widget _buildBrandSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final brand = _brands[index];
          final selected = index == _selectedBrandIndex;
          return ChoiceChip(
            label: Text(brand.name),
            selected: selected,
            onSelected: (_) => setState(() => _selectedBrandIndex = index),
            selectedColor: brand.primaryColor.withOpacity(0.15),
            backgroundColor: const Color(0xFFF9FAFB),
            side: BorderSide(
              color: selected ? brand.primaryColor : const Color(0xFFE5E7EB),
            ),
            labelStyle: TextStyle(
              color: selected ? brand.primaryColor : const Color(0xFF6B7280),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
            avatar: CircleAvatar(
              backgroundColor: brand.primaryColor,
              radius: 10,
              child: Text(
                brand.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab bar
  // ---------------------------------------------------------------------------
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppTheme.primaryColor,
      unselectedLabelColor: const Color(0xFF6B7280),
      indicatorColor: AppTheme.primaryColor,
      indicatorWeight: 2.5,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      tabs: const [
        Tab(text: 'Marka Ayarlari', icon: Icon(Icons.branding_watermark, size: 20)),
        Tab(text: 'Tema', icon: Icon(Icons.palette, size: 20)),
        Tab(text: 'Logo', icon: Icon(Icons.image_outlined, size: 20)),
        Tab(text: 'Onizleme', icon: Icon(Icons.preview_outlined, size: 20)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab content
  // ---------------------------------------------------------------------------
  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBrandSettingsTab(),
        _buildThemeTab(),
        _buildLogoTab(),
        _buildPreviewTab(),
      ],
    );
  }

  // ===========================================================================
  // TAB 0 : Marka Ayarlari
  // ===========================================================================
  Widget _buildBrandSettingsTab() {
    final brand = _activeBrand;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Marka Bilgileri'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  icon: Icons.business,
                  label: 'Marka Adi',
                  value: brand.name,
                  color: brand.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoCard(
                  icon: Icons.format_quote,
                  label: 'Slogan',
                  value: brand.slogan,
                  color: brand.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  icon: Icons.email_outlined,
                  label: 'E-posta',
                  value: brand.email,
                  color: const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoCard(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  value: brand.phone,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Tum Markalar'),
          const SizedBox(height: 12),
          ..._brands.asMap().entries.map((entry) {
            final idx = entry.key;
            final b = entry.value;
            final isCurrent = idx == _selectedBrandIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? b.primaryColor : const Color(0xFFE5E7EB),
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: b.primaryColor,
                  child: Text(
                    b.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  b.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCurrent
                        ? b.primaryColor
                        : const Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  b.slogan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                trailing: isCurrent
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Secili',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: b.primaryColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                onTap: () => setState(() => _selectedBrandIndex = idx),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1 : Tema
  // ===========================================================================
  Widget _buildThemeTab() {
    final brand = _activeBrand;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Renk Paleti'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _colorSwatch('Birincil', brand.primaryColor),
              _colorSwatch('Ikincil', brand.secondaryColor),
              _colorSwatch('Vurgu', brand.accentColor),
              _colorSwatch('Yuzey', brand.surfaceColor),
              _colorSwatch('Basari', const Color(0xFF10B981)),
              _colorSwatch('Uyari', const Color(0xFFF59E0B)),
              _colorSwatch('Hata', const Color(0xFFEF4444)),
              _colorSwatch('Bilgi', const Color(0xFF0EA5E9)),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Yazi Tipi ve Bicim'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _settingCard(
                  icon: Icons.text_fields,
                  title: 'Yazi Tipi Ailesi',
                  value: brand.fontFamily,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _settingCard(
                  icon: Icons.rounded_corner,
                  title: 'Kenar Yaricapi',
                  value: '${brand.borderRadius.toInt()} px',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _settingCard(
                  icon: Icons.format_size,
                  title: 'Baslik Boyutu',
                  value: '24 px',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _settingCard(
                  icon: Icons.line_weight,
                  title: 'Govde Boyutu',
                  value: '14 px',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Onizleme Ornegi'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: brand.surfaceColor,
              borderRadius: BorderRadius.circular(brand.borderRadius),
              border: Border.all(color: brand.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ornek Baslik Metni',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: brand.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bu alan secilen tema ayarlarina gore gorunumun nasil olacagini gostermektedir. '
                  'Renkler, yazi tipi ve kenar yaricapi burada yansitilmaktadir.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brand.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(brand.borderRadius / 2),
                        ),
                      ),
                      child: const Text('Birincil Buton'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: brand.primaryColor,
                        side: BorderSide(color: brand.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(brand.borderRadius / 2),
                        ),
                      ),
                      child: const Text('Ikincil Buton'),
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

  // ===========================================================================
  // TAB 2 : Logo
  // ===========================================================================
  Widget _buildLogoTab() {
    final brand = _activeBrand;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Logo Yonetimi'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _logoPlaceholderCard(
                  title: 'Ana Logo',
                  subtitle: 'Onerilen boyut: 512 x 128 px',
                  iconSize: 56,
                  icon: Icons.image_outlined,
                  brand: brand,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _logoPlaceholderCard(
                  title: 'Kucuk Logo',
                  subtitle: 'Onerilen boyut: 128 x 128 px',
                  iconSize: 44,
                  icon: Icons.photo_size_select_small,
                  brand: brand,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _logoPlaceholderCard(
                  title: 'Favicon',
                  subtitle: 'Onerilen boyut: 32 x 32 px',
                  iconSize: 32,
                  icon: Icons.tab_outlined,
                  brand: brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('Logo Kurallari'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ruleRow('Desteklenen formatlar: PNG, SVG, WebP'),
                const SizedBox(height: 8),
                _ruleRow('Maksimum dosya boyutu: 2 MB'),
                _ruleRow('Seffaf arka plan onerilir'),
                const SizedBox(height: 8),
                _ruleRow('Yuksek cozunurluklu (2x) gorseller yukleyin'),
                const SizedBox(height: 8),
                _ruleRow('Koyu ve acik arka plan icin ayri logolar ekleyin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3 : Onizleme
  // ===========================================================================
  Widget _buildPreviewTab() {
    final brand = _activeBrand;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Canli Onizleme - ${brand.name}'),
          const SizedBox(height: 12),

          // Mock login card
          _previewCard(
            brand: brand,
            title: 'Giris Ekrani',
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: brand.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.psychology,
                      size: 36, color: brand.primaryColor),
                ),
                const SizedBox(height: 14),
                Text(
                  brand.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: brand.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hesabiniza giris yapin',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                _mockTextField('E-posta', brand),
                const SizedBox(height: 10),
                _mockTextField('Sifre', brand),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(brand.borderRadius / 2),
                      ),
                    ),
                    child: const Text('Giris Yap',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mock dashboard card
          _previewCard(
            brand: brand,
            title: 'Kontrol Paneli',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _miniStatCard('Danisman', '248', brand.primaryColor),
                    const SizedBox(width: 12),
                    _miniStatCard('Randevu', '56', brand.secondaryColor),
                    const SizedBox(width: 12),
                    _miniStatCard('Aktif', '182', const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: brand.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: brand.primaryColor.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      'Grafik Alani',
                      style: TextStyle(
                        color: brand.primaryColor.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mock navigation bar card
          _previewCard(
            brand: brand,
            title: 'Navigasyon Cubugu',
            child: Container(
              decoration: BoxDecoration(
                color: brand.primaryColor,
                borderRadius: BorderRadius.circular(brand.borderRadius / 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    brand.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  ...[
                    'Anasayfa',
                    'Danisanlar',
                    'Randevular',
                    'Raporlar'
                  ].map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Shared helper widgets
  // ===========================================================================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorSwatch(String label, Color color) {
    final hex =
        '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          hex,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9CA3AF),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholderCard({
    required String title,
    required String subtitle,
    required double iconSize,
    required IconData icon,
    required _BrandData brand,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: brand.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: brand.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize, color: brand.primaryColor.withOpacity(0.4)),
                const SizedBox(height: 8),
                Text(
                  'Logo Yukle',
                  style: TextStyle(
                    fontSize: 12,
                    color: brand.primaryColor.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: const Text('Dosya Sec', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: brand.primaryColor,
                side: BorderSide(color: brand.primaryColor.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline,
              size: 16, color: Color(0xFF10B981)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewCard({
    required _BrandData brand,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _mockTextField(String hint, _BrandData brand) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(brand.borderRadius / 2),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        hint,
        style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  Widget _miniStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Data model
// =============================================================================
class _BrandData {
  final String name;
  final String slogan;
  final String email;
  final String phone;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color surfaceColor;
  final String fontFamily;
  final double borderRadius;

  const _BrandData({
    required this.name,
    required this.slogan,
    required this.email,
    required this.phone,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.fontFamily,
    required this.borderRadius,
  });
}
