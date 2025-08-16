import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class MedicationReminderWidget extends StatefulWidget {
  const MedicationReminderWidget({super.key});

  @override
  State<MedicationReminderWidget> createState() =>
      _MedicationReminderWidgetState();
}

class _MedicationReminderWidgetState extends State<MedicationReminderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final List<MedicationReminder> _reminders = [
    MedicationReminder(
      id: '1',
      medicationName: 'Escitalopram',
      dosage: '20mg',
      frequency: 'Günde 1 kez',
      time: TimeOfDay(hour: 9, minute: 0),
      days: [1, 2, 3, 4, 5, 6, 7], // Her gün
      isActive: true,
      lastTaken: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Kahvaltıdan sonra alın',
    ),
    MedicationReminder(
      id: '2',
      medicationName: 'Alprazolam',
      dosage: '0.5mg',
      frequency: 'Günde 2 kez',
      time: TimeOfDay(hour: 14, minute: 0),
      days: [1, 2, 3, 4, 5, 6, 7], // Her gün
      isActive: true,
      lastTaken: DateTime.now().subtract(const Duration(hours: 8)),
      notes: 'Öğle yemeğinden sonra',
    ),
    MedicationReminder(
      id: '3',
      medicationName: 'Melatonin',
      dosage: '3mg',
      frequency: 'Günde 1 kez',
      time: TimeOfDay(hour: 22, minute: 0),
      days: [1, 2, 3, 4, 5, 6, 7], // Her gün
      isActive: true,
      lastTaken: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Yatmadan 1 saat önce',
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
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
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
            Colors.orange.shade50,
            Colors.red.shade50,
            Colors.pink.shade50,
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
                  Colors.orange.shade600,
                  Colors.red.shade600,
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
                          Icons.alarm,
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
                        'İlaç Hatırlatıcıları',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'İlaçlarınızı zamanında almayı unutmayın',
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
                    Icons.medication,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Reminders
                    _buildTodayReminders(),
                    const SizedBox(height: 24),

                    // Add New Reminder
                    _buildAddReminderButton(),
                    const SizedBox(height: 24),

                    // All Reminders
                    _buildAllReminders(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReminders() {
    final today = DateTime.now().weekday;
    final todayReminders =
        _reminders.where((r) => r.days.contains(today)).toList();

    if (todayReminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Bugün için ilaç hatırlatıcısı yok!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tüm ilaçlarınızı aldınız veya bugün için planlanmamış.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bugünün Hatırlatıcıları',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...todayReminders.map((reminder) => _buildTodayReminderCard(reminder)),
      ],
    );
  }

  Widget _buildTodayReminderCard(MedicationReminder reminder) {
    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.time.hour,
      reminder.time.minute,
    );
    final isOverdue = now.isAfter(reminderTime);
    final isUpcoming = now.isBefore(reminderTime);
    final timeUntilReminder = reminderTime.difference(now);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (reminder.lastTaken.isAfter(reminderTime)) {
      statusColor = Colors.green;
      statusText = 'Alındı';
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusText = 'Gecikti';
      statusIcon = Icons.warning;
    } else if (isUpcoming) {
      statusColor = Colors.blue;
      statusText = 'Yakında';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.grey;
      statusText = 'Bilinmiyor';
      statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicationName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${reminder.dosage} - ${reminder.frequency}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          if (reminder.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reminder.notes,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (isUpcoming) ...[
                Icon(Icons.schedule, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${timeUntilReminder.inHours} saat ${timeUntilReminder.inMinutes % 60} dakika sonra',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                ),
              ],
              const Spacer(),
              if (reminder.lastTaken.isBefore(reminderTime)) ...[
                ElevatedButton.icon(
                  onPressed: () => _markAsTaken(reminder),
                  icon: const Icon(Icons.check),
                  label: const Text('Alındı'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: () => _showTakenDialog(reminder),
                  icon: const Icon(Icons.edit),
                  label: const Text('Düzenle'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddReminderButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddReminderDialog(),
        icon: const Icon(Icons.add_alarm),
        label: const Text('Yeni Hatırlatıcı Ekle'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade600,
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

  Widget _buildAllReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tüm Hatırlatıcılar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._reminders.map((reminder) => _buildReminderCard(reminder)),
      ],
    );
  }

  Widget _buildReminderCard(MedicationReminder reminder) {
    final isActive = reminder.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.medicationName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${reminder.dosage} - ${reminder.frequency}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) => _toggleReminder(reminder, value),
            activeColor: Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  void _markAsTaken(MedicationReminder reminder) {
    setState(() {
      reminder.lastTaken = DateTime.now();
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminder.medicationName} alındı olarak işaretlendi'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _showTakenDialog(MedicationReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlaç Alım Zamanı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${reminder.medicationName} ne zaman alındı?'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  reminder.lastTaken = DateTime.now();
                });
                Navigator.pop(context);
              },
              child: const Text('Şimdi Alındı'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _toggleReminder(MedicationReminder reminder, bool value) {
    setState(() {
      reminder.isActive = value;
    });
  }

  void _showAddReminderDialog() {
    // TODO: Implement add reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hatırlatıcı ekleme özelliği yakında!')),
    );
  }
}

class MedicationReminder {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final TimeOfDay time;
  final List<int> days; // 1=Monday, 7=Sunday
  bool isActive;
  DateTime lastTaken;
  final String notes;

  MedicationReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.time,
    required this.days,
    required this.isActive,
    required this.lastTaken,
    required this.notes,
  });
}
