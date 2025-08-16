import 'package:flutter/material.dart';
import 'package:psyclinicai/models/flag_ai_models.dart';
import 'package:psyclinicai/services/flag_ai_service.dart';
import 'package:psyclinicai/services/ai_logger.dart';

// Acil Durum Protokolü Widget'ı
class EmergencyProtocolWidget extends StatefulWidget {
  final AIFlagDetection flag;
  final Function(CrisisInterventionPlan) onPlanCreated;
  final Function(String) onError;

  const EmergencyProtocolWidget({
    super.key,
    required this.flag,
    required this.onPlanCreated,
    required this.onError,
  });

  @override
  State<EmergencyProtocolWidget> createState() => _EmergencyProtocolWidgetState();
}

class _EmergencyProtocolWidgetState extends State<EmergencyProtocolWidget>
    with TickerProviderStateMixin {
  final FlagAIService _flagService = FlagAIService();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isInitialized = false;
  CrisisInterventionPlan? _interventionPlan;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeService();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _flagService.initialize();
      
      setState(() {
        _isInitialized = true;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _error = 'Servis başlatılamadı: $e';
      });
      widget.onError('Servis başlatılamadı: $e');
    }
  }

  Future<void> _createInterventionPlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock intervention plan - gerçek uygulamada AI ile oluşturulacak
      final plan = CrisisInterventionPlan(
        id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
        flagId: widget.flag.id,
        level: widget.flag.emergencyLevel,
        interventions: widget.flag.recommendedInterventions,
        actionSteps: {
          'immediate': [
            'Güvenlik değerlendirmesi yap',
            'Acil servisleri bilgilendir',
            'Aile ile iletişime geç',
          ],
          'within_1_hour': [
            'Kriz müdahale ekibini topla',
            'Güvenlik planı oluştur',
            'İlaç değerlendirmesi yap',
          ],
          'within_24_hours': [
            'Takip planı oluştur',
            'Aile eğitimi ver',
            'Destek sistemlerini organize et',
          ],
        },
        requiredResources: [
          'Kriz müdahale ekibi',
          'Güvenlik planı şablonu',
          'Acil iletişim listesi',
          'İlaç değerlendirme formu',
        ],
        contactPersons: [
          'Birincil terapist',
          'Acil durum kontağı',
          'Aile üyesi',
          'Psikiyatrist',
        ],
        emergencyContacts: [
          '112 Acil Servis',
          'Kriz müdahale hattı',
          'Acil psikiyatri servisi',
        ],
        protocol: _getProtocolForEmergencyLevel(widget.flag.emergencyLevel),
        createdAt: DateTime.now(),
        status: 'planned',
        outcomes: {},
        notes: [
          'Flag tespit edildi: ${widget.flag.type.name}',
          'Risk seviyesi: ${widget.flag.riskLevel.name}',
          'Acil durum: ${widget.flag.emergencyLevel.name}',
        ],
      );

      setState(() {
        _interventionPlan = plan;
        _isLoading = false;
      });

      widget.onPlanCreated(plan);

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 Kriz müdahale planı oluşturuldu!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Plan oluşturulamadı: $e';
        _isLoading = false;
      });
      widget.onError('Plan oluşturulamadı: $e');
    }
  }

  String _getProtocolForEmergencyLevel(EmergencyLevel level) {
    switch (level) {
      case EmergencyLevel.none:
        return 'Standart takip protokolü';
      case EmergencyLevel.urgent:
        return 'Acil müdahale protokolü - 1 saat içinde';
      case EmergencyLevel.immediate:
        return 'Anında müdahale protokolü - 15 dakika içinde';
      case EmergencyLevel.critical:
        return 'Kritik müdahale protokolü - 5 dakika içinde';
      case EmergencyLevel.lifeThreatening:
        return 'Yaşam tehdidi protokolü - Anında';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (!_isInitialized) _buildInitializingState(),
              if (_isInitialized && _isLoading) _buildLoadingState(),
              if (_isInitialized && !_isLoading && _error != null) _buildErrorState(),
              if (_isInitialized && !_isLoading && _error == null && _interventionPlan == null)
                _buildCreatePlanState(),
              if (_isInitialized && !_isLoading && _error == null && _interventionPlan != null)
                _buildPlanDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final emergencyColor = _getEmergencyColor(widget.flag.emergencyLevel);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: emergencyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.emergency,
            color: emergencyColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚨 Acil Durum Protokolü',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: emergencyColor,
                ),
              ),
              Text(
                'Kriz müdahale planı oluştur ve uygula',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitializingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            'Acil Durum Protokolü Yükleniyor...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            SizedBox(height: 16),
            Text('Kriz müdahale planı oluşturuluyor...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Hata Oluştu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Bilinmeyen hata',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createInterventionPlan,
            child: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePlanState() {
    final emergencyColor = _getEmergencyColor(widget.flag.emergencyLevel);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: emergencyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: emergencyColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: emergencyColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Acil Durum Tespit Edildi!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: emergencyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.flag.emergencyLevel.name.toUpperCase()} seviyesinde kriz müdahale planı oluşturulmalı',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: emergencyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _createInterventionPlan,
            icon: const Icon(Icons.emergency),
            label: const Text('Kriz Müdahale Planı Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: emergencyColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanDetails() {
    if (_interventionPlan == null) return const SizedBox.shrink();

    final plan = _interventionPlan!;
    final emergencyColor = _getEmergencyColor(plan.level);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanHeader(plan, emergencyColor),
        const SizedBox(height: 20),
        _buildActionSteps(plan),
        const SizedBox(height: 20),
        _buildResources(plan),
        const SizedBox(height: 20),
        _buildContacts(plan),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPlanHeader(CrisisInterventionPlan plan, Color emergencyColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emergencyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emergencyColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: emergencyColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kriz Müdahale Planı',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: emergencyColor,
                      ),
                    ),
                    Text(
                      'Oluşturulma: ${_formatDateTime(plan.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusBadge('Seviye', plan.level.name, emergencyColor),
              const SizedBox(width: 12),
              _buildStatusBadge('Durum', plan.status, Colors.blue),
              const SizedBox(width: 12),
              _buildStatusBadge('Protokol', plan.protocol.split(' ').first, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSteps(CrisisInterventionPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksiyon Adımları',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              _buildActionStep('Anında', plan.actionSteps['immediate'] ?? [], Colors.red),
              const SizedBox(height: 16),
              _buildActionStep('1 Saat İçinde', plan.actionSteps['within_1_hour'] ?? [], Colors.orange),
              const SizedBox(height: 16),
              _buildActionStep('24 Saat İçinde', plan.actionSteps['within_24_hours'] ?? [], Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionStep(String title, List<dynamic> steps, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...steps.map((step) => Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.fiber_manual_record,
                size: 8,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(step.toString())),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildResources(CrisisInterventionPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gerekli Kaynaklar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plan.requiredResources.map((resource) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Text(
                resource,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContacts(CrisisInterventionPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İletişim Kişileri',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContactSection(
                'İletişim Kişileri',
                plan.contactPersons,
                Icons.people,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContactSection(
                'Acil Numaralar',
                plan.emergencyContacts,
                Icons.emergency,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(String title, List<String> contacts, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...contacts.map((contact) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(contact)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Planı düzenle
            },
            icon: const Icon(Icons.edit),
            label: const Text('Planı Düzenle'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Planı aktifleştir
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Planı Aktifleştir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Color _getEmergencyColor(EmergencyLevel level) {
    switch (level) {
      case EmergencyLevel.none:
        return Colors.green;
      case EmergencyLevel.urgent:
        return Colors.orange;
      case EmergencyLevel.immediate:
        return Colors.red;
      case EmergencyLevel.critical:
        return Colors.purple;
      case EmergencyLevel.lifeThreatening:
        return Colors.red[900]!;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
