import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SymptomTrackerWidget extends StatefulWidget {
  const SymptomTrackerWidget({super.key});

  @override
  State<SymptomTrackerWidget> createState() => _SymptomTrackerWidgetState();
}

class _SymptomTrackerWidgetState extends State<SymptomTrackerWidget>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _pulseController;
  late Animation<double> _chartAnimation;
  late Animation<double> _pulseAnimation;

  final List<SymptomData> _symptoms = [
    SymptomData(
      name: 'Anksiyete',
      severity: 7,
      date: DateTime.now().subtract(const Duration(days: 6)),
      notes: 'Sabah erken saatlerde daha yoğun',
    ),
    SymptomData(
      name: 'Depresyon',
      severity: 5,
      date: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Gün boyunca sürekli',
    ),
    SymptomData(
      name: 'Uyku Bozukluğu',
      severity: 8,
      date: DateTime.now().subtract(const Duration(days: 4)),
      notes: 'Gece uyanmalar',
    ),
    SymptomData(
      name: 'Sosyal İzolasyon',
      severity: 6,
      date: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Arkadaşlarla görüşmek istemiyorum',
    ),
    SymptomData(
      name: 'Konsantrasyon',
      severity: 4,
      date: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'İşe odaklanmak zor',
    ),
    SymptomData(
      name: 'Yorgunluk',
      severity: 9,
      date: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Sürekli yorgun hissetme',
    ),
    SymptomData(
      name: 'İştah Değişikliği',
      severity: 3,
      date: DateTime.now(),
      notes: 'Daha az yemek yiyorum',
    ),
  ];

  final List<String> _symptomTypes = [
    'Anksiyete',
    'Depresyon',
    'Uyku Bozukluğu',
    'Sosyal İzolasyon',
    'Konsantrasyon',
    'Yorgunluk',
    'İştah Değişikliği',
    'Panik Atak',
    'Obsesif Düşünceler',
    'Sosyal Fobi',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _chartController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _chartController.dispose();
    _pulseController.dispose();
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
            Colors.blue.shade50,
            Colors.green.shade50,
            Colors.teal.shade50,
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
                  Colors.teal.shade600,
                  Colors.green.shade600,
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
                          Icons.trending_up,
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
                        'Semptom Takibi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Günlük semptom seviyelerinizi takip edin',
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
                    Icons.analytics,
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
                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 24),

                  // Chart
                  _buildChart(),
                  const SizedBox(height: 24),

                  // Add New Symptom
                  _buildAddSymptomButton(),
                  const SizedBox(height: 24),

                  // Symptom List
                  _buildSymptomList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final averageSeverity =
        _symptoms.fold(0.0, (sum, symptom) => sum + symptom.severity) /
            _symptoms.length;
    final mostSevere =
        _symptoms.reduce((a, b) => a.severity > b.severity ? a : b);
    final improving = _symptoms.length >= 2 &&
        _symptoms.last.severity < _symptoms[_symptoms.length - 2].severity;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Ortalama',
            '${averageSeverity.toStringAsFixed(1)}',
            Icons.analytics,
            Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En Yüksek',
            '${mostSevere.severity}',
            Icons.trending_up,
            Colors.red.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Durum',
            improving ? 'İyileşiyor' : 'Stabil',
            improving ? Icons.arrow_upward : Icons.remove,
            improving ? Colors.green.shade600 : Colors.orange.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              Text(
                '7 Günlük Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: SymptomChartPainter(
                    symptoms: _symptoms,
                    animation: _chartAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSymptomButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddSymptomDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Semptom Ekle'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
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

  Widget _buildSymptomList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Semptomlar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._symptoms.map((symptom) => _buildSymptomCard(symptom)),
      ],
    );
  }

  Widget _buildSymptomCard(SymptomData symptom) {
    final severityColor = _getSeverityColor(symptom.severity);

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
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (symptom.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    symptom.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Seviye: ${symptom.severity}/10',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(symptom.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editSymptom(symptom),
            icon: Icon(Icons.edit, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    if (severity <= 8) return Colors.red.shade400;
    return Colors.red.shade700;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Bugün';
    if (difference.inDays == 1) return 'Dün';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddSymptomDialog() {
    String selectedSymptom = _symptomTypes.first;
    int severity = 5;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Semptom Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSymptom,
              decoration: const InputDecoration(
                labelText: 'Semptom Türü',
                border: OutlineInputBorder(),
              ),
              items: _symptomTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) => selectedSymptom = value!,
            ),
            const SizedBox(height: 16),
            Text('Şiddet Seviyesi: $severity/10'),
            Slider(
              value: severity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: severity.toString(),
              onChanged: (value) {
                setState(() => severity = value.round());
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notlar (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => notes = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _symptoms.add(SymptomData(
                  name: selectedSymptom,
                  severity: severity,
                  date: DateTime.now(),
                  notes: notes,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _editSymptom(SymptomData symptom) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Düzenleme özelliği yakında!')),
    );
  }
}

class SymptomData {
  final String name;
  final int severity;
  final DateTime date;
  final String notes;

  SymptomData({
    required this.name,
    required this.severity,
    required this.date,
    required this.notes,
  });
}

class SymptomChartPainter extends CustomPainter {
  final List<SymptomData> symptoms;
  final double animation;

  SymptomChartPainter({
    required this.symptoms,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (symptoms.isEmpty) return;

    final paint = Paint()
      ..color = Colors.teal.shade600
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.teal.shade100.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final width = size.width;
    final height = size.height;
    final padding = 40.0;
    final chartWidth = width - (padding * 2);
    final chartHeight = height - (padding * 2);

    for (int i = 0; i < symptoms.length; i++) {
      final x = padding + (chartWidth / (symptoms.length - 1)) * i;
      final y = height - padding - (chartHeight * symptoms[i].severity / 10);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.teal.shade600);
    }

    fillPath.lineTo(width - padding, height - padding);
    fillPath.close();

    // Draw filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
