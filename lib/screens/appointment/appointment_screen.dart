import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedType = 'Terapi Seansı';

  final List<String> _appointmentTypes = [
    'Terapi Seansı',
    'Kontrol',
    'İlk Görüşme',
    'Acil',
    'Süpervizyon',
  ];

  @override
  void dispose() {
    _clientNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createAppointment() async {
    if (_clientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Danışan adı gerekli'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    // TODO: Appointment service entegrasyonu
    await Future.delayed(const Duration(seconds: 1)); // Simülasyon

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Randevu oluşturuldu: ${_clientNameController.text}'),
        backgroundColor: AppTheme.accentColor,
      ),
    );

    // Form temizle
    _clientNameController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedType = 'Terapi Seansı';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Takvimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateAppointmentDialog(context);
            },
            tooltip: 'Yeni Randevu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Takvim üst bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Tarih Seç'),
                ),
              ],
            ),
          ),

          // Takvim görünümü
          Expanded(
            child: _buildCalendarView(),
          ),

          // Alt bilgi paneli
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI destekli hatırlatıcılar ve no-show tahmini özellikleri yakında!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateAppointmentDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Randevu'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCalendarView() {
    // Basit takvim görünümü
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _getDaysInMonth(_selectedDate.year, _selectedDate.month),
      itemBuilder: (context, index) {
        final day = index + 1;
        final isToday = day == DateTime.now().day &&
            _selectedDate.month == DateTime.now().month &&
            _selectedDate.year == DateTime.now().year;
        final hasAppointment = day % 3 == 0; // Demo: her 3. günde randevu var

        return Card(
          color: isToday ? AppTheme.primaryColor : null,
          child: InkWell(
            onTap: () {
              // TODO: Gün detayı göster
            },
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isToday ? Colors.white : null,
                    ),
                  ),
                ),
                if (hasAppointment)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Randevu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Danışan adı
              TextField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Danışan Adı',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Randevu tipi
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Randevu Tipi',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _appointmentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Tarih seçimi
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Tarih: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: TextButton(
                  onPressed: _selectDate,
                  child: const Text('Değiştir'),
                ),
              ),

              // Saat seçimi
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  'Saat: ${_selectedTime.format(context)}',
                ),
                trailing: TextButton(
                  onPressed: _selectTime,
                  child: const Text('Değiştir'),
                ),
              ),

              const SizedBox(height: 16),

              // Notlar
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createAppointment();
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }
}
