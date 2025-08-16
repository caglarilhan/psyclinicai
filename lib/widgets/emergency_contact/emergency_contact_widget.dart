import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class EmergencyContactWidget extends StatefulWidget {
  const EmergencyContactWidget({super.key});

  @override
  State<EmergencyContactWidget> createState() => _EmergencyContactWidgetState();
}

class _EmergencyContactWidgetState extends State<EmergencyContactWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  final List<EmergencyContact> _contacts = [
    EmergencyContact(
      id: '1',
      name: 'Dr. Ahmet Yılmaz',
      relationship: 'Psikiyatrist',
      phone: '+90 555 123 4567',
      isEmergency: true,
      isFavorite: true,
      notes: 'Ana doktorum, acil durumlarda ilk aranacak',
    ),
    EmergencyContact(
      id: '2',
      name: '112 Acil Servis',
      relationship: 'Acil Servis',
      phone: '112',
      isEmergency: true,
      isFavorite: false,
      notes: 'Hayati tehlike durumlarında',
    ),
    EmergencyContact(
      id: '3',
      name: 'Psikolojik Destek Hattı',
      relationship: 'Destek Hattı',
      phone: '184',
      isEmergency: true,
      isFavorite: false,
      notes: '7/24 psikolojik destek',
    ),
    EmergencyContact(
      id: '4',
      name: 'Ayşe Kaya',
      relationship: 'Aile Üyesi',
      phone: '+90 555 987 6543',
      isEmergency: false,
      isFavorite: true,
      notes: 'Kız kardeşim, yakın destek',
    ),
    EmergencyContact(
      id: '5',
      name: 'Mehmet Demir',
      relationship: 'Arkadaş',
      phone: '+90 555 456 7890',
      isEmergency: false,
      isFavorite: true,
      notes: 'Güvenilir arkadaşım',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.orange.shade50,
            Colors.yellow.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade600,
                  Colors.orange.shade600,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acil Durum Kontakları',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Hızlı erişim için önemli kontaklar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emergency Quick Actions
                  _buildEmergencyQuickActions(),
                  const SizedBox(height: 24),

                  // Favorite Contacts
                  _buildFavoriteContacts(),
                  const SizedBox(height: 24),

                  // All Contacts
                  _buildAllContacts(),
                  const SizedBox(height: 24),

                  // Add New Contact
                  _buildAddContactButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                '112',
                'Acil Servis',
                Icons.local_hospital,
                Colors.red.shade600,
                () => _callEmergency('112'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                '184',
                'Psikolojik Destek',
                Icons.psychology,
                Colors.blue.shade600,
                () => _callEmergency('184'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Ana Doktor',
                'Dr. Ahmet Yılmaz',
                Icons.medical_services,
                Colors.green.shade600,
                () => _callContact(_contacts.firstWhere(
                    (c) => c.isFavorite && c.relationship == 'Psikiyatrist')),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                'Aile',
                'Ayşe Kaya',
                Icons.family_restroom,
                Colors.purple.shade600,
                () => _callContact(_contacts
                    .firstWhere((c) => c.relationship == 'Aile Üyesi')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        _shakeController.forward().then((_) => _shakeController.reset());
        onTap();
      },
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shakeAnimation.value *
                0.1 *
                math.sin(_shakeAnimation.value * 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteContacts() {
    final favoriteContacts = _contacts.where((c) => c.isFavorite).toList();

    if (favoriteContacts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favori Kontaklar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...favoriteContacts.map((contact) => _buildContactCard(contact, true)),
      ],
    );
  }

  Widget _buildAllContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tüm Kontaklar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._contacts.map((contact) => _buildContactCard(contact, false)),
      ],
    );
  }

  Widget _buildContactCard(EmergencyContact contact, bool isFavorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              contact.isEmergency ? Colors.red.shade300 : Colors.grey.shade300,
          width: contact.isEmergency ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: contact.isEmergency
                  ? Colors.red.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              contact.isEmergency ? Icons.emergency : Icons.person,
              color: contact.isEmergency
                  ? Colors.red.shade600
                  : Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contact.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (contact.isFavorite) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 16,
                      ),
                    ],
                    if (contact.isEmergency) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.warning,
                        color: Colors.orange.shade600,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  contact.relationship,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                if (contact.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    contact.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _callContact(contact),
                icon: Icon(
                  Icons.call,
                  color: Colors.green.shade600,
                ),
              ),
              if (isFavorite) ...[
                IconButton(
                  onPressed: () => _toggleFavorite(contact),
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.red.shade400,
                  ),
                ),
              ] else ...[
                IconButton(
                  onPressed: () => _toggleFavorite(contact),
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddContactDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Yeni Kontak Ekle'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _callEmergency(String number) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$number aranıyor...'),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Implement actual phone call
  }

  void _callContact(EmergencyContact contact) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${contact.name} aranıyor...'),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Implement actual phone call
  }

  void _toggleFavorite(EmergencyContact contact) {
    setState(() {
      contact.isFavorite = !contact.isFavorite;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(contact.isFavorite
            ? '${contact.name} favorilere eklendi'
            : '${contact.name} favorilerden çıkarıldı'),
        backgroundColor:
            contact.isFavorite ? Colors.red.shade600 : Colors.grey.shade600,
      ),
    );
  }

  void _showAddContactDialog() {
    // TODO: Implement add contact dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kontak ekleme özelliği yakında!')),
    );
  }
}

class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final bool isEmergency;
  bool isFavorite;
  final String notes;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    required this.isEmergency,
    required this.isFavorite,
    required this.notes,
  });
}
