import 'package:flutter/material.dart';
import '../../models/patient_portal_models.dart';
import '../../services/patient_portal_service.dart';
import '../../utils/theme.dart';

class PatientPortalDashboardWidget extends StatefulWidget {
  final String patientId;

  const PatientPortalDashboardWidget({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientPortalDashboardWidget> createState() => _PatientPortalDashboardWidgetState();
}

class _PatientPortalDashboardWidgetState extends State<PatientPortalDashboardWidget> {
  final _portalService = PatientPortalService();
  PatientPortalUser? _patient;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final patient = await _portalService.getPatientPortalUser(widget.patientId);
      final statistics = await _portalService.getPatientPortalStatistics(widget.patientId);
      
      setState(() {
        _patient = patient;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Veriler yüklenemedi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_patient == null) {
      return const Center(child: Text('Hasta bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          
          const SizedBox(height: 24),
          
          // Statistics Cards
          _buildStatisticsCards(),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _patient!.firstName[0].toUpperCase(),
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
                  'Hoş geldiniz, ${_patient!.firstName}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Randevularınızı yönetin ve terapistinizle iletişim kurun',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Bekleyen Randevular',
          '${_statistics['pendingAppointmentRequests'] ?? 0}',
          Icons.schedule,
          Colors.orange,
        ),
        _buildStatCard(
          'Toplam Ödemeler',
          '${_statistics['totalPayments'] ?? 0}',
          Icons.payment,
          Colors.green,
        ),
        _buildStatCard(
          'Okunmamış Mesajlar',
          '${_statistics['unreadMessages'] ?? 0}',
          Icons.message,
          Colors.blue,
        ),
        _buildStatCard(
          'Toplam Randevular',
          '${_statistics['totalAppointmentRequests'] ?? 0}',
          Icons.calendar_today,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildQuickActionCard(
              'Randevu Talep Et',
              Icons.add_circle,
              AppTheme.primaryColor,
              () => _requestAppointment(),
            ),
            _buildQuickActionCard(
              'Mesaj Gönder',
              Icons.message,
              Colors.blue,
              () => _sendMessage(),
            ),
            _buildQuickActionCard(
              'Ödeme Yap',
              Icons.payment,
              Colors.green,
              () => _makePayment(),
            ),
            _buildQuickActionCard(
              'Dokümanlar',
              Icons.folder,
              Colors.orange,
              () => _viewDocuments(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Aktiviteler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  'Randevu talebiniz onaylandı',
                  '2 gün önce',
                  Icons.check_circle,
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  'Yeni mesaj aldınız',
                  '3 gün önce',
                  Icons.message,
                  Colors.blue,
                ),
                const Divider(),
                _buildActivityItem(
                  'Ödeme başarılı',
                  '1 hafta önce',
                  Icons.payment,
                  Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  'Doküman yüklendi',
                  '2 hafta önce',
                  Icons.upload,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
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

  void _requestAppointment() {
    showDialog(
      context: context,
      builder: (context) => _AppointmentRequestDialog(
        patientId: widget.patientId,
        onRequestSubmitted: () {
          Navigator.pop(context);
          _loadData(); // Refresh statistics
        },
      ),
    );
  }

  void _sendMessage() {
    showDialog(
      context: context,
      builder: (context) => _MessageDialog(
        patientId: widget.patientId,
        onMessageSent: () {
          Navigator.pop(context);
          _loadData(); // Refresh statistics
        },
      ),
    );
  }

  void _makePayment() {
    showDialog(
      context: context,
      builder: (context) => _PaymentDialog(
        patientId: widget.patientId,
        onPaymentCompleted: () {
          Navigator.pop(context);
          _loadData(); // Refresh statistics
        },
      ),
    );
  }

  void _viewDocuments() {
    showDialog(
      context: context,
      builder: (context) => _DocumentsDialog(patientId: widget.patientId),
    );
  }
}

class _AppointmentRequestDialog extends StatefulWidget {
  final String patientId;
  final VoidCallback onRequestSubmitted;

  const _AppointmentRequestDialog({
    required this.patientId,
    required this.onRequestSubmitted,
  });

  @override
  State<_AppointmentRequestDialog> createState() => _AppointmentRequestDialogState();
}

class _AppointmentRequestDialogState extends State<_AppointmentRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '09:00';
  final _portalService = PatientPortalService();
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Randevu Talebi'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date Picker
              ListTile(
                title: const Text('Tarih'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              
              // Time Picker
              DropdownButtonFormField<String>(
                value: _selectedTime,
                decoration: const InputDecoration(
                  labelText: 'Saat',
                  border: OutlineInputBorder(),
                ),
                items: _timeSlots.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTime = value);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Randevu Nedeni',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Randevu nedeni gerekli';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar (İsteğe bağlı)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRequest,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Talep Gönder'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      await _portalService.createAppointmentRequest(
        patientId: widget.patientId,
        therapistId: 'therapist_001', // TODO: Get actual therapist ID
        preferredDate: _selectedDate,
        preferredTime: _selectedTime,
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu talebiniz başarıyla gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onRequestSubmitted();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

class _MessageDialog extends StatefulWidget {
  final String patientId;
  final VoidCallback onMessageSent;

  const _MessageDialog({
    required this.patientId,
    required this.onMessageSent,
  });

  @override
  State<_MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<_MessageDialog> {
  final _messageController = TextEditingController();
  final _portalService = PatientPortalService();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mesaj Gönder'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Mesajınız',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendMessage,
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gönder'),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() => _isSending = true);
    
    try {
      await _portalService.sendMessage(
        patientId: widget.patientId,
        therapistId: 'therapist_001', // TODO: Get actual therapist ID
        message: _messageController.text.trim(),
        isFromPatient: true,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mesajınız başarıyla gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onMessageSent();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }
}

class _PaymentDialog extends StatefulWidget {
  final String patientId;
  final VoidCallback onPaymentCompleted;

  const _PaymentDialog({
    required this.patientId,
    required this.onPaymentCompleted,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _amountController = TextEditingController();
  final _portalService = PatientPortalService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ödeme Yap'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Tutar',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ödeme işlemi Stripe üzerinden güvenli bir şekilde gerçekleştirilecektir.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ödeme Yap'),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir tutar girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      await _portalService.createPayment(
        patientId: widget.patientId,
        appointmentId: 'appointment_001', // TODO: Get actual appointment ID
        amount: amount,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme işlemi başlatıldı'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onPaymentCompleted();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}

class _DocumentsDialog extends StatefulWidget {
  final String patientId;

  const _DocumentsDialog({required this.patientId});

  @override
  State<_DocumentsDialog> createState() => _DocumentsDialogState();
}

class _DocumentsDialogState extends State<_DocumentsDialog> {
  final _portalService = PatientPortalService();
  List<PatientDocument> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await _portalService.getPatientDocuments(widget.patientId);
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dokümanlar'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _documents.isEmpty
                ? const Center(child: Text('Henüz doküman yüklenmemiş'))
                : ListView.builder(
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final document = _documents[index];
                      return ListTile(
                        leading: Icon(
                          _getDocumentIcon(document.mimeType),
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(document.fileName),
                        subtitle: Text(
                          '${_formatFileSize(document.fileSize)} • ${_formatDate(document.uploadedAt)}',
                        ),
                        trailing: IconButton(
                          onPressed: () => _downloadDocument(document),
                          icon: const Icon(Icons.download),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  IconData _getDocumentIcon(String mimeType) {
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('image')) return Icons.image;
    if (mimeType.contains('word')) return Icons.description;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _downloadDocument(PatientDocument document) {
    // TODO: Implement document download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Doküman indirme özelliği yakında eklenecek')),
    );
  }
}
