import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/client_model.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(client.fullName),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'appointment',
                child: Row(
                  children: [
                    Icon(Icons.event),
                    SizedBox(width: 8),
                    Text('Randevu Oluştur'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'session',
                child: Row(
                  children: [
                    Icon(Icons.note_add),
                    SizedBox(width: 8),
                    Text('Seans Notu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Dışa Aktar'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'appointment':
                  // TODO: Navigate to appointment creation
                  break;
                case 'session':
                  // TODO: Navigate to session notes
                  break;
                case 'export':
                  // TODO: Export client data
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        client.firstName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${client.age} yaşında • ${client.gender}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client.email,
                            style: TextStyle(
                              color: Colors.grey[600],
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
            
            // Kişisel Bilgiler
            _buildSectionHeader('Kişisel Bilgiler'),
            const SizedBox(height: 16),
            
            _buildInfoCard([
              _buildInfoRow('Ad Soyad', client.fullName),
              _buildInfoRow('Doğum Tarihi', _formatDate(client.dateOfBirth)),
              _buildInfoRow('Yaş', '${client.age} yaşında'),
              _buildInfoRow('Cinsiyet', client.gender),
            ]),
            
            const SizedBox(height: 24),
            
            // İletişim Bilgileri
            _buildSectionHeader('İletişim Bilgileri'),
            const SizedBox(height: 16),
            
            _buildInfoCard([
              _buildInfoRow('E-posta', client.email),
              _buildInfoRow('Telefon', client.phone),
              _buildInfoRow('Adres', client.address),
            ]),
            
            const SizedBox(height: 24),
            
            // Acil Durum İletişim
            _buildSectionHeader('Acil Durum İletişim'),
            const SizedBox(height: 16),
            
            _buildInfoCard([
              _buildInfoRow('Acil Durum Kişisi', client.emergencyContact),
              _buildInfoRow('Acil Durum Telefonu', client.emergencyPhone),
            ]),
            
            const SizedBox(height: 24),
            
            // Notlar
            if (client.notes.isNotEmpty) ...[
              _buildSectionHeader('Notlar'),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    client.notes,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Sistem Bilgileri
            _buildSectionHeader('Sistem Bilgileri'),
            const SizedBox(height: 16),
            
            _buildInfoCard([
              _buildInfoRow('Hasta ID', client.id),
              _buildInfoRow('Kayıt Tarihi', _formatDate(client.createdAt)),
              _buildInfoRow('Son Güncelleme', _formatDate(client.updatedAt)),
              _buildInfoRow('Durum', client.isActive ? 'Aktif' : 'Pasif'),
            ]),
            
            const SizedBox(height: 32),
            
            // Hızlı İşlemler
            _buildSectionHeader('Hızlı İşlemler'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Randevu Oluştur',
                    Icons.event,
                    AppTheme.primaryColor,
                    () {
                      // TODO: Navigate to appointment creation
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    'Seans Notu',
                    Icons.note_add,
                    Colors.green,
                    () {
                      // TODO: Navigate to session notes
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'AI Tanı',
                    Icons.psychology,
                    Colors.purple,
                    () {
                      // TODO: Navigate to AI diagnosis
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    'Dışa Aktar',
                    Icons.download,
                    Colors.orange,
                    () {
                      // TODO: Export client data
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
