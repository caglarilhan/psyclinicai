import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/flag_model.dart';
import '../../widgets/flag/flag_detection_panel.dart';
import '../../widgets/flag/flag_history_panel.dart';

class FlagScreen extends StatefulWidget {
  const FlagScreen({super.key});

  @override
  State<FlagScreen> createState() => _FlagScreenState();
}

class _FlagScreenState extends State<FlagScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<FlagModel> _activeFlags = [];
  List<FlagModel> _flagHistory = [];
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    // Demo flag verileri
    setState(() {
      _activeFlags = [
        FlagModel(
          id: '1',
          patientName: 'Mehmet Kaya',
          flagType: FlagType.suicide,
          severity: FlagSeverity.high,
          description:
              'Danışan bugünkü seansında ölüm düşüncelerini ifade etti',
          symptoms: ['Ölüm düşünceleri', 'Umutsuzluk', 'İntihar planı'],
          riskFactors: [
            'Geçmiş intihar girişimi',
            'Aile öyküsü',
            'Madde kullanımı'
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          status: FlagStatus.active,
          interventions: [
            'Acil psikiyatrik değerlendirme',
            'Güvenlik planı',
            'Aile bilgilendirmesi'
          ],
        ),
        FlagModel(
          id: '2',
          patientName: 'Ayşe Demir',
          flagType: FlagType.crisis,
          severity: FlagSeverity.medium,
          description: 'Danışan aşırı ajite ve agresif davranış sergiliyor',
          symptoms: ['Ajitasyon', 'Agresif davranış', 'Konsantrasyon güçlüğü'],
          riskFactors: ['Bipolar bozukluk', 'Uyku yoksunluğu', 'Stres'],
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          status: FlagStatus.active,
          interventions: [
            'Sakinleştirici teknikler',
            'Güvenli ortam',
            'İlaç değerlendirmesi'
          ],
        ),
      ];

      _flagHistory = [
        FlagModel(
          id: '3',
          patientName: 'Ali Yılmaz',
          flagType: FlagType.selfHarm,
          severity: FlagSeverity.low,
          description: 'Danışan kendine zarar verme düşüncelerini ifade etti',
          symptoms: ['Kendine zarar verme düşünceleri', 'Düşük özgüven'],
          riskFactors: ['Depresyon', 'Geçmiş travma'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          status: FlagStatus.resolved,
          interventions: ['Güvenlik planı', 'Günlük takip', 'Aile desteği'],
        ),
      ];
    });
  }

  Future<void> _analyzeSessionNotes(String notes) async {
    setState(() => _isAnalyzing = true);

    try {
      // TODO: AI flag detection service
      await Future.delayed(const Duration(seconds: 3));

      // Demo AI analizi
      final detectedFlags = _detectFlagsFromNotes(notes);

      if (detectedFlags.isNotEmpty) {
        setState(() {
          _activeFlags.addAll(detectedFlags);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${detectedFlags.length} yeni flag tespit edildi!'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Herhangi bir risk tespit edilmedi'),
              backgroundColor: AppTheme.accentColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flag analizi hatası: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  List<FlagModel> _detectFlagsFromNotes(String notes) {
    final flags = <FlagModel>[];
    final lowerNotes = notes.toLowerCase();

    // Suicide risk detection
    if (lowerNotes.contains('ölüm') ||
        lowerNotes.contains('intihar') ||
        lowerNotes.contains('öldürmek')) {
      flags.add(FlagModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: 'Yeni Danışan',
        flagType: FlagType.suicide,
        severity: FlagSeverity.high,
        description: 'AI: Seans notlarında intihar riski tespit edildi',
        symptoms: ['Ölüm düşünceleri', 'İntihar planı'],
        riskFactors: ['Yüksek risk'],
        createdAt: DateTime.now(),
        status: FlagStatus.active,
        interventions: ['Acil değerlendirme gerekli'],
      ));
    }

    // Crisis detection
    if (lowerNotes.contains('ajite') ||
        lowerNotes.contains('agresif') ||
        lowerNotes.contains('kriz')) {
      flags.add(FlagModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        patientName: 'Yeni Danışan',
        flagType: FlagType.crisis,
        severity: FlagSeverity.medium,
        description: 'AI: Seans notlarında kriz durumu tespit edildi',
        symptoms: ['Ajitasyon', 'Agresif davranış'],
        riskFactors: ['Orta risk'],
        createdAt: DateTime.now(),
        status: FlagStatus.active,
        interventions: ['Güvenlik planı gerekli'],
      ));
    }

    return flags;
  }

  void _resolveFlag(String flagId) {
    setState(() {
      final flagIndex = _activeFlags.indexWhere((flag) => flag.id == flagId);
      if (flagIndex != -1) {
        final flag = _activeFlags[flagIndex];
        final resolvedFlag = flag.markAsResolved();
        _flagHistory.add(resolvedFlag);
        _activeFlags.removeAt(flagIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flag Sistemi - Risk Tespiti'),
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.warning), text: 'Aktif Flaglar'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Analiz'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Aktif Flaglar
          _buildActiveFlagsTab(),

          // Tab 2: AI Analiz
          FlagDetectionPanel(
            onAnalyzeNotes: _analyzeSessionNotes,
            isAnalyzing: _isAnalyzing,
          ),

          // Tab 3: Geçmiş
          FlagHistoryPanel(
            flags: _flagHistory,
            onFlagSelected: (flag) {
              // TODO: Flag detayını göster
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFlagsTab() {
    if (_activeFlags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Aktif Flag Yok',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.accentColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tüm risk durumları çözüldü',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeFlags.length,
      itemBuilder: (context, index) {
        final flag = _activeFlags[index];
        return _buildFlagCard(context, flag);
      },
    );
  }

  Widget _buildFlagCard(BuildContext context, FlagModel flag) {
    final severityColor = _getSeverityColor(flag.severity);
    final flagTypeIcon = _getFlagTypeIcon(flag.flagType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: severityColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Üst panel - Flag tipi ve şiddeti
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    flagTypeIcon,
                    color: severityColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFlagTypeText(flag.flagType),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: severityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          flag.patientName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: severityColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getSeverityText(flag.severity),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // İçerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Açıklama
                  Text(
                    flag.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 16),

                  // Belirtiler
                  _buildSection('Belirtiler', flag.symptoms, Icons.psychology,
                      AppTheme.primaryColor),

                  const SizedBox(height: 16),

                  // Risk faktörleri
                  _buildSection('Risk Faktörleri', flag.riskFactors,
                      Icons.warning, AppTheme.warningColor),

                  const SizedBox(height: 16),

                  // Müdahaleler
                  _buildSection('Önerilen Müdahaleler', flag.interventions,
                      Icons.medical_services, AppTheme.accentColor),

                  const SizedBox(height: 16),

                  // Tarih
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tespit: ${_formatDateTime(flag.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Aksiyonlar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Flag detayını göster
                          },
                          icon: const Icon(Icons.info),
                          label: const Text('Detay'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _resolveFlag(flag.id),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Çözüldü'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Color _getSeverityColor(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return AppTheme.accentColor;
      case FlagSeverity.medium:
        return AppTheme.warningColor;
      case FlagSeverity.high:
        return AppTheme.errorColor;
    }
  }

  String _getSeverityText(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return 'Düşük';
      case FlagSeverity.medium:
        return 'Orta';
      case FlagSeverity.high:
        return 'Yüksek';
    }
  }

  IconData _getFlagTypeIcon(FlagType type) {
    switch (type) {
      case FlagType.suicide:
        return Icons.warning;
      case FlagType.crisis:
        return Icons.psychology;
      case FlagType.selfHarm:
        return Icons.healing;
      case FlagType.violence:
        return Icons.security;
    }
  }

  String _getFlagTypeText(FlagType type) {
    switch (type) {
      case FlagType.suicide:
        return 'İntihar Riski';
      case FlagType.crisis:
        return 'Kriz Durumu';
      case FlagType.selfHarm:
        return 'Kendine Zarar Verme';
      case FlagType.violence:
        return 'Şiddet Riski';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
