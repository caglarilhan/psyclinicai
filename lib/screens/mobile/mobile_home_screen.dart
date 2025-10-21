import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/offline_service.dart';
import '../../services/language_service.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Auto-scroll for featured content
    _startAutoScroll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentPage < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      body: NestedScrollView(
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHomeTab(),
            _buildPatientsTab(),
            _buildAppointmentsTab(),
            _buildProfileTab(),
          ],
        ),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  languageService.translate('app_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/pattern.png'),
                                repeat: ImageRepeat.repeat,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 48,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI Destekli Klinik Yönetimi',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showNotifications(),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showSearch(),
                ),
              ],
            ),
          ];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabController.index,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: languageService.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: languageService.translate('patients'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: languageService.translate('appointments'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageService = Provider.of<LanguageService>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Quick stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Bugünkü Randevular',
                    '5',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Aktif Hastalar',
                    '23',
                    Icons.people,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Bekleyen Mesajlar',
                    '3',
                    Icons.message,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Featured content carousel
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildFeaturedCard(
                  'AI Tanı Asistanı',
                  'Hastalarınız için AI destekli tanı önerileri alın',
                  Icons.psychology,
                  Colors.purple,
                ),
                _buildFeaturedCard(
                  'Telemedicine',
                  'Uzaktan hasta görüşmeleri yapın',
                  Icons.video_call,
                  Colors.blue,
                ),
                _buildFeaturedCard(
                  'Mood Tracking',
                  'Hasta ruh halini takip edin',
                  Icons.timeline,
                  Colors.green,
                ),
              ],
            ),
          ),

          // Page indicators
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? colorScheme.primary
                      : Colors.grey[300],
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hızlı İşlemler',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildQuickActionCard(
                      'Yeni Hasta Ekle',
                      Icons.person_add,
                      Colors.blue,
                      () => _addPatient(),
                    ),
                    _buildQuickActionCard(
                      'Randevu Oluştur',
                      Icons.event,
                      Colors.green,
                      () => _createAppointment(),
                    ),
                    _buildQuickActionCard(
                      'Sesli Not Al',
                      Icons.mic,
                      Colors.orange,
                      () => _recordVoiceNote(),
                    ),
                    _buildQuickActionCard(
                      'AI Tanı',
                      Icons.psychology,
                      Colors.purple,
                      () => _startAIDiagnosis(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent activities
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Son Aktiviteler',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(5, (index) {
                  return _buildActivityItem(
                    'Yeni hasta kaydı',
                    'Ahmet Yılmaz',
                    '10:30',
                    Icons.person_add,
                    Colors.blue,
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String action, String patient, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(action),
        subtitle: Text(patient),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    return const Center(
      child: Text('Hastalar sekmesi - Mobil optimizasyon'),
    );
  }

  Widget _buildAppointmentsTab() {
    return const Center(
      child: Text('Randevular sekmesi - Mobil optimizasyon'),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profil sekmesi - Mobil optimizasyon'),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirimler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem('Yeni randevu talebi', 'Ahmet Yılmaz', '2 saat önce'),
                  _buildNotificationItem('Reçete onayı', 'Dr. Mehmet Kaya', '4 saat önce'),
                  _buildNotificationItem('Sistem güncellemesi', 'Sistem', '1 gün önce'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, String time) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.notifications, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: MobileSearchDelegate(),
    );
  }

  void _addPatient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni hasta ekleme özelliği açılıyor...')),
    );
  }

  void _createAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Randevu oluşturma özelliği açılıyor...')),
    );
  }

  void _recordVoiceNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesli not alma özelliği açılıyor...')),
    );
  }

  void _startAIDiagnosis() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI tanı özelliği açılıyor...')),
    );
  }
}

class MobileSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Arama sonuçları: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'Hasta ara',
      'Randevu ara',
      'Reçete ara',
      'Sesli not ara',
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
