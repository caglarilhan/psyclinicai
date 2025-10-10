import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/hr_management_models.dart';
import '../../services/hr_management_service.dart';
import '../../utils/theme.dart';

class HRManagementDashboardWidget extends StatefulWidget {
  const HRManagementDashboardWidget({super.key});

  @override
  State<HRManagementDashboardWidget> createState() => _HRManagementDashboardWidgetState();
}

class _HRManagementDashboardWidgetState extends State<HRManagementDashboardWidget> {
  final HRManagementService _service = HRManagementService();
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  List<Employee> _employees = [];
  List<PerformanceReview> _performanceReviews = [];
  List<Recruitment> _recruitments = [];
  List<TrainingProgram> _trainingPrograms = [];
  List<CareerDevelopment> _careerDevelopments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final statistics = await _service.getHRStatistics('org_001');
      final employees = await _service.getEmployees();
      final recruitments = await _service.getActiveRecruitments();
      final trainingPrograms = await _service.getTrainingPrograms();
      
      setState(() {
        _statistics = statistics;
        _employees = employees;
        _recruitments = recruitments;
        _trainingPrograms = trainingPrograms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatisticsCards(),
          const SizedBox(height: 24),
          _buildEmployeesSection(),
          const SizedBox(height: 24),
          _buildRecruitmentSection(),
          const SizedBox(height: 24),
          _buildTrainingSection(),
          const SizedBox(height: 24),
          _buildPerformanceSection(),
          const SizedBox(height: 24),
          _buildAIFeaturesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İnsan Kaynakları Yönetimi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personel yönetimi, performans takibi ve eğitim programları',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Personel',
          '${_statistics['totalEmployees'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Performans Değerlendirmeleri',
          '${_statistics['totalPerformanceReviews'] ?? 0}',
          Icons.assessment,
          Colors.green,
        ),
        _buildStatCard(
          'Aktif İş İlanları',
          '${_statistics['totalRecruitments'] ?? 0}',
          Icons.work,
          Colors.orange,
        ),
        _buildStatCard(
          'Eğitim Programları',
          '${_statistics['totalTrainingPrograms'] ?? 0}',
          Icons.school,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
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

  Widget _buildEmployeesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personel Listesi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addEmployee,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Yeni Personel'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_employees.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz personel bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  return _buildEmployeeCard(employee);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Text(
            '${employee.firstName[0]}${employee.lastName[0]}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${employee.firstName} ${employee.lastName}'),
        subtitle: Text('${employee.position} - ${employee.department}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewEmployee(employee);
                break;
              case 'edit':
                _editEmployee(employee);
                break;
              case 'performance':
                _viewPerformanceReviews(employee);
                break;
              case 'career':
                _viewCareerDevelopment(employee);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Görüntüle')),
            const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
            const PopupMenuItem(value: 'performance', child: Text('Performans')),
            const PopupMenuItem(value: 'career', child: Text('Kariyer')),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktif İş İlanları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createRecruitment,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni İlan'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recruitments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz aktif iş ilanı bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recruitments.length,
                itemBuilder: (context, index) {
                  final recruitment = _recruitments[index];
                  return _buildRecruitmentCard(recruitment);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecruitmentCard(Recruitment recruitment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: const Icon(Icons.work, color: Colors.orange),
        ),
        title: Text(recruitment.position),
        subtitle: Text('${recruitment.department} - ${recruitment.applicants.length} başvuru'),
        trailing: Text(
          NumberFormat.currency(symbol: '₺', decimalDigits: 0).format(recruitment.salaryRange),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTrainingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eğitim Programları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createTrainingProgram,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Program'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_trainingPrograms.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Henüz eğitim programı bulunmuyor'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trainingPrograms.length,
                itemBuilder: (context, index) {
                  final program = _trainingPrograms[index];
                  return _buildTrainingProgramCard(program);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingProgramCard(TrainingProgram program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          child: const Icon(Icons.school, color: Colors.purple),
        ),
        title: Text(program.title),
        subtitle: Text('${program.category} - ${program.duration} saat'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${program.enrolledEmployees.length}/${program.maxParticipants}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              NumberFormat.currency(symbol: '₺', decimalDigits: 0).format(program.cost),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performans Özeti',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    'Ortalama Performans',
                    '4.2/5.0',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Eğitim Tamamlama',
                    '85%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    'İşe Alım Süresi',
                    '28 gün',
                    Icons.schedule,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Personel Memnuniyeti',
                    '4.5/5.0',
                    Icons.sentiment_satisfied,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
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

  Widget _buildAIFeaturesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Destekli İK Analizi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatePerformanceInsights,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Performans İçgörüleri'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateRecruitmentRecommendations,
                    icon: const Icon(Icons.work),
                    label: const Text('İşe Alım Önerileri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateTrainingRecommendations,
                    icon: const Icon(Icons.school),
                    label: const Text('Eğitim Önerileri'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateCareerRecommendations,
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Kariyer Önerileri'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  Future<void> _addEmployee() async {
    // TODO: Implement employee creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personel ekleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _createRecruitment() async {
    // TODO: Implement recruitment creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İş ilanı oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _createTrainingProgram() async {
    // TODO: Implement training program creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eğitim programı oluşturma özelliği yakında eklenecek')),
    );
  }

  Future<void> _viewEmployee(Employee employee) async {
    // TODO: Implement employee view dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personel görüntüleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _editEmployee(Employee employee) async {
    // TODO: Implement employee edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personel düzenleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _viewPerformanceReviews(Employee employee) async {
    // TODO: Implement performance reviews view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performans değerlendirmeleri görüntüleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _viewCareerDevelopment(Employee employee) async {
    // TODO: Implement career development view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kariyer gelişimi görüntüleme özelliği yakında eklenecek')),
    );
  }

  Future<void> _generatePerformanceInsights() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final insights = await _service.generatePerformanceInsights(
        employeeId: 'emp_001',
        performanceData: {
          'ratings': {
            'Clinical Skills': 'excellent',
            'Communication': 'good',
            'Leadership': 'needsImprovement',
          },
          'goals': {
            'Patient Satisfaction': 0.95,
            'Documentation': 0.85,
            'Team Collaboration': 0.70,
          },
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Performans İçgörüleri', insights);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analiz hatası: $e')),
        );
      }
    }
  }

  Future<void> _generateRecruitmentRecommendations() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final recommendations = await _service.generateRecruitmentRecommendations(
        position: 'Psychiatrist',
        department: 'Psychiatry',
        requirements: {
          'education': 'MD',
          'experience': '3+ years',
          'certification': 'Board certified',
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('İşe Alım Önerileri', recommendations);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analiz hatası: $e')),
        );
      }
    }
  }

  Future<void> _generateTrainingRecommendations() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final recommendations = await _service.generateTrainingRecommendations(
        employeeId: 'emp_001',
        currentSkills: ['Clinical Skills', 'Communication'],
        targetPosition: 'Senior Psychiatrist',
        performanceData: {
          'ratings': {
            'Leadership': 'needsImprovement',
            'Research': 'satisfactory',
          },
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showInsightsDialog('Eğitim Önerileri', recommendations);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analiz hatası: $e')),
        );
      }
    }
  }

  Future<void> _generateCareerRecommendations() async {
    // TODO: Implement career recommendations
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kariyer önerileri özelliği yakında eklenecek')),
    );
  }

  void _showInsightsDialog(String title, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data['insights'] != null) ...[
                const Text('İçgörüler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['insights'] as List).map((insight) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $insight'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['recommendations'] != null) ...[
                const Text('Öneriler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['recommendations'] as List).map((recommendation) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $recommendation'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['strengths'] != null) ...[
                const Text('Güçlü Yönler:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['strengths'] as List).map((strength) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $strength'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['areasForImprovement'] != null) ...[
                const Text('Gelişim Alanları:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(data['areasForImprovement'] as List).map((area) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $area'),
                )),
                const SizedBox(height: 16),
              ],
              if (data['confidence'] != null) ...[
                Text('Güven Skoru: ${(data['confidence'] * 100).toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
