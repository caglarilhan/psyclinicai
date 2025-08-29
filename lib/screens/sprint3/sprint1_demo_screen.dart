import 'package:flutter/material.dart';
import '../session/session_screen.dart';
import '../appointment/appointment_screen.dart';

class Sprint1DemoScreen extends StatefulWidget {
  const Sprint1DemoScreen({super.key});

  @override
  State<Sprint1DemoScreen> createState() => _Sprint1DemoScreenState();
}

class _Sprint1DemoScreenState extends State<Sprint1DemoScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SessionDemoTab(),
    const AppointmentDemoTab(),
    const PDFDemoTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint 1 Demo - PsyClinic AI'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sol sidebar - Navigasyon
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Logo ve başlık
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PsyClinic AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Sprint 1 Demo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Navigasyon menüsü
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(
                        icon: Icons.edit_note,
                        title: 'Seans Ekranı',
                        subtitle: 'AI destekli seans notu',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.calendar_today,
                        title: 'Randevu Sistemi',
                        subtitle: 'Akıllı takvim yönetimi',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.picture_as_pdf,
                        title: 'PDF Export',
                        subtitle: 'Profesyonel raporlar',
                        index: 2,
                      ),
                    ],
                  ),
                ),
                
                // Sprint bilgisi
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Sprint 1 Tamamlandı! 🎉',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '✅ Seans ekranı\n✅ Randevu sistemi\n✅ PDF export',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Ana içerik alanı
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.7) : Colors.grey[600],
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      ),
    );
  }
}

/// Seans Demo Tab'ı
class SessionDemoTab extends StatelessWidget {
  const SessionDemoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(Icons.edit_note, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 16),
              const Text(
                'Seans Ekranı Demo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'AI destekli seans notu yazma ve analiz sistemi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Özellikler
          Expanded(
            child: Row(
              children: [
                // Sol taraf - Özellik listesi
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Ana Özellikler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildFeatureCard(
                        icon: Icons.timer,
                        title: 'Seans Zamanlayıcısı',
                        description: 'Otomatik seans süresi takibi',
                        color: Colors.green,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildFeatureCard(
                        icon: Icons.psychology,
                        title: 'AI Özet Asistanı',
                        description: 'Seans notlarından otomatik analiz',
                        color: Colors.blue,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildFeatureCard(
                        icon: Icons.picture_as_pdf,
                        title: 'PDF Export',
                        description: 'Profesyonel seans raporları',
                        color: Colors.orange,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildFeatureCard(
                        icon: Icons.keyboard,
                        title: 'Klavye Kısayolları',
                        description: 'Hızlı erişim için kısayollar',
                        color: Colors.purple,
                      ),
                      
                      const Spacer(),
                      
                      // Test butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SessionScreen(
                                  sessionId: 'demo-001',
                                  clientId: 'client-001',
                                  clientName: 'Ahmet Yılmaz',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Seans Ekranını Test Et'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 32),
                
                // Sağ taraf - Ekran görüntüsü
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/session_screen_preview.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Ekran görüntüsü yüklenemedi',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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

/// Randevu Demo Tab'ı
class AppointmentDemoTab extends StatelessWidget {
  const AppointmentDemoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 16),
              const Text(
                'Randevu Sistemi Demo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'AI destekli randevu yönetimi ve hatırlatıcılar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Test butonu
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentScreen(),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Randevu Sistemini Test Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Özellikler grid'i
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildAppointmentFeatureCard(
                  icon: Icons.smart_toy,
                  title: 'AI Hatırlatıcılar',
                  description: 'Akıllı randevu hatırlatıcıları',
                  color: Colors.blue,
                ),
                _buildAppointmentFeatureCard(
                  icon: Icons.analytics,
                  title: 'No-Show Tahmini',
                  description: 'Randevu iptal olasılığı analizi',
                  color: Colors.green,
                ),
                _buildAppointmentFeatureCard(
                  icon: Icons.integration_instructions,
                  title: 'Entegrasyon',
                  description: 'Google Calendar, Outlook desteği',
                  color: Colors.orange,
                ),
                _buildAppointmentFeatureCard(
                  icon: Icons.notifications_active,
                  title: 'Bildirimler',
                  description: 'SMS, Email, Push bildirimleri',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// PDF Demo Tab'ı
class PDFDemoTab extends StatelessWidget {
  const PDFDemoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 16),
              const Text(
                'PDF Export Demo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Profesyonel seans raporları ve PDF export sistemi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // PDF özellikleri
          Expanded(
            child: Row(
              children: [
                // Sol taraf - PDF özellikleri
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📄 PDF Özellikleri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildPDFFeatureCard(
                        icon: Icons.description,
                        title: 'Seans Raporu',
                        description: 'Detaylı seans notları ve AI özeti',
                        color: Colors.blue,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPDFFeatureCard(
                        icon: Icons.print,
                        title: 'Yazdırma',
                        description: 'Direkt yazıcıya gönderim',
                        color: Colors.green,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPDFFeatureCard(
                        icon: Icons.share,
                        title: 'Paylaşım',
                        description: 'Email, WhatsApp, Drive paylaşımı',
                        color: Colors.orange,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPDFFeatureCard(
                        icon: Icons.security,
                        title: 'Güvenlik',
                        description: 'Şifreli PDF ve watermark',
                        color: Colors.red,
                      ),
                      
                      const Spacer(),
                      
                      // PDF test butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showPDFPreview(context);
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('PDF Önizleme'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 32),
                
                // Sağ taraf - PDF önizleme
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // PDF header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Seans_Raporu_Ahmet_Yilmaz.pdf',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // PDF içerik önizleme
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo ve başlık
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.psychology,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'PsyClinic AI',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                const Text(
                                  'SEANS RAPORU',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Bilgi kartları
                                _buildPDFPreviewCard('Danışan:', 'Ahmet Yılmaz'),
                                const SizedBox(height: 8),
                                _buildPDFPreviewCard('Seans ID:', 'demo-001'),
                                const SizedBox(height: 8),
                                _buildPDFPreviewCard('Tarih:', '15.01.2025'),
                                const SizedBox(height: 8),
                                _buildPDFPreviewCard('Terapist:', 'Dr. Terapist'),
                                
                                const SizedBox(height: 20),
                                
                                const Text(
                                  'Seans İçeriği:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Bugünkü seansımızda danışan depresif duygu durumu...',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFPreviewCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showPDFPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Önizleme'),
        content: const Text('PDF önizleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

