import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/pseudonym_service.dart';

class PatientPortalScreen extends StatefulWidget {
  const PatientPortalScreen({super.key});

  @override
  State<PatientPortalScreen> createState() => _PatientPortalScreenState();
}

class _PatientPortalScreenState extends State<PatientPortalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPatient = 'Ahmet Yılmaz';
  
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'date': DateTime(2024, 2, 20, 10, 0),
      'doctor': 'Dr. Ayşe Demir',
      'type': 'Kontrol',
      'status': 'Planlandı',
      'notes': 'Depresyon takibi',
    },
    {
      'id': '2',
      'date': DateTime(2024, 2, 25, 14, 30),
      'doctor': 'Dr. Mehmet Kaya',
      'type': 'Terapi',
      'status': 'Planlandı',
      'notes': 'Anksiyete terapisi',
    },
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'from': 'Dr. Ayşe Demir',
      'message': 'Merhaba Ahmet Bey, ilaçlarınızı düzenli alıyor musunuz?',
      'timestamp': DateTime(2024, 2, 15, 10, 30),
      'isRead': false,
    },
    {
      'id': '2',
      'from': 'Dr. Mehmet Kaya',
      'message': 'Randevunuzu ertesi güne alabiliriz.',
      'timestamp': DateTime(2024, 2, 14, 16, 45),
      'isRead': true,
    },
  ];

  final List<Map<String, dynamic>> _documents = [
    {
      'id': '1',
      'name': 'Tedavi Planı',
      'type': 'PDF',
      'date': DateTime(2024, 2, 10),
      'size': '2.3 MB',
    },
    {
      'id': '2',
      'name': 'Laboratuvar Sonuçları',
      'type': 'PDF',
      'date': DateTime(2024, 2, 8),
      'size': '1.8 MB',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Portalı'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Ana Sayfa'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Randevular'),
            Tab(icon: Icon(Icons.message), text: 'Mesajlar'),
            Tab(icon: Icon(Icons.folder), text: 'Dosyalar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildAppointmentsTab(),
          _buildMessagesTab(),
          _buildDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş geldin kartı
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      _selectedPatient.split(' ').map((e) => e[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş geldiniz, $_selectedPatient',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        // Hasta portalında nick gösterilmez - sadece klinik ekip görür
                        // Text('Takma Ad: ${PseudonymService.generate(_selectedPatient)}', style: theme.textTheme.bodySmall),
                        Text(
                          'Son giriş: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Hızlı erişim
          Text(
            'Hızlı Erişim',
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickAccessCard(
                'Randevu Al',
                Icons.add_circle,
                Colors.blue,
                () => _showBookAppointment(),
              ),
              _buildQuickAccessCard(
                'Mesaj Gönder',
                Icons.message,
                Colors.green,
                () => _showSendMessage(),
              ),
              _buildQuickAccessCard(
                'Ödeme Yap',
                Icons.payment,
                Colors.orange,
                () => _showPayment(),
              ),
              _buildQuickAccessCard(
                'Dosya Yükle',
                Icons.upload,
                Colors.purple,
                () => _showUploadFile(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Yaklaşan randevular
          Text(
            'Yaklaşan Randevular',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._appointments.take(2).map((appointment) {
            return _buildAppointmentCard(appointment);
          }).toList(),
          const SizedBox(height: 24),

          // Son mesajlar
          Text(
            'Son Mesajlar',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._messages.take(2).map((message) {
            return _buildMessageCard(message);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
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
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy HH:mm').format(appointment['date']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Doktor: ${appointment['doctor']}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'Tür: ${appointment['type']}',
              style: theme.textTheme.bodyMedium,
            ),
            if (appointment['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${appointment['notes']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => _rescheduleAppointment(appointment),
                  child: const Text('Ertele'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _cancelAppointment(appointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('İptal Et'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: message['isRead'] ? Colors.grey : theme.colorScheme.primary,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          message['from'],
          style: TextStyle(
            fontWeight: message['isRead'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          message['message'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(message['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (!message['isRead'])
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () => _openMessage(message),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(_appointments[index]);
      },
    );
  }

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageCard(_messages[index]);
      },
    );
  }

  Widget _buildDocumentsTab() {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final document = _documents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
              ),
            ),
            title: Text(document['name']),
            subtitle: Text(
              '${DateFormat('dd.MM.yyyy').format(document['date'])} • ${document['size']}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadDocument(document),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareDocument(document),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookAppointment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevu Al'),
        content: const Text('Randevu alma formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Randevu alma özelliği yakında eklenecek')),
              );
            },
            child: const Text('Randevu Al'),
          ),
        ],
      ),
    );
  }

  void _showSendMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesaj Gönder'),
        content: const Text('Mesaj gönderme formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mesaj gönderme özelliği yakında eklenecek')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _showPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Yap'),
        content: const Text('Ödeme formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ödeme özelliği yakında eklenecek')),
              );
            },
            child: const Text('Ödeme Yap'),
          ),
        ],
      ),
    );
  }

  void _showUploadFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya Yükle'),
        content: const Text('Dosya yükleme formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dosya yükleme özelliği yakında eklenecek')),
              );
            },
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(Map<String, dynamic> appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${appointment['doctor']} randevusu erteleme özelliği yakında eklenecek')),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Randevu İptal'),
        content: Text('${appointment['doctor']} ile olan randevunuzu iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Randevu iptal edildi')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _openMessage(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mesaj - ${message['from']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message['message']),
            const SizedBox(height: 16),
            Text(
              'Gönderim: ${DateFormat('dd.MM.yyyy HH:mm').format(message['timestamp'])}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yanıt gönderme özelliği yakında eklenecek')),
              );
            },
            child: const Text('Yanıtla'),
          ),
        ],
      ),
    );
  }

  void _downloadDocument(Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${document['name']} indiriliyor...')),
    );
  }

  void _shareDocument(Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${document['name']} paylaşım özelliği yakında eklenecek')),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimler'),
        content: const Text('Bildirimler burada görüntülenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarlar'),
        content: const Text('Hasta portalı ayarları burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
