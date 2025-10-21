import 'package:flutter/material.dart';
import '../../models/manager_staff_models.dart';
import '../../services/manager_staff_service.dart';
import '../../services/role_service.dart';

class ManagerStaffScreen extends StatefulWidget {
  const ManagerStaffScreen({super.key});

  @override
  State<ManagerStaffScreen> createState() => _ManagerStaffScreenState();
}

class _ManagerStaffScreenState extends State<ManagerStaffScreen> with TickerProviderStateMixin {
  final ManagerStaffService _staffService = ManagerStaffService();
  final RoleService _roleService = RoleService();
  
  late TabController _tabController;
  
  List<Employee> _employees = [];
  List<LeaveRequest> _leaveRequests = [];
  List<PerformanceReview> _performanceReviews = [];
  List<TrainingProgram> _trainingPrograms = [];
  List<EmployeeTraining> _employeeTrainings = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _selectedRole = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await _staffService.initialize();
      await _staffService.generateDemoData();
      
      _employees = _staffService.getActiveEmployees();
      _leaveRequests = _staffService.getPendingLeaveRequests();
      _performanceReviews = _staffService.getPerformanceReviewsForEmployee('emp_001');
      _trainingPrograms = _staffService.getTrainingProgramsByCategory('Klinik');
      _employeeTrainings = _staffService.getEmployeeTrainingsByStatus(TrainingStatus.inProgress);
    } catch (e) {
      print('Error loading manager staff data: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        title: const Text(
          'Personel Yönetimi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Personel'),
            Tab(text: 'İzinler'),
            Tab(text: 'Performans'),
            Tab(text: 'Eğitimler'),
            Tab(text: 'İstatistikler'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeesTab(),
                _buildLeaveRequestsTab(),
                _buildPerformanceTab(),
                _buildTrainingTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildEmployeesTab() {
    final filteredEmployees = _getFilteredEmployees();
    
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredEmployees.isEmpty
              ? const Center(
                  child: Text(
                    'Personel bulunamadı',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];
                    return _buildEmployeeCard(employee);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rol',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.purple[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tümü')),
                DropdownMenuItem(value: 'doctor', child: Text('Doktor')),
                DropdownMenuItem(value: 'psychologist', child: Text('Psikolog')),
                DropdownMenuItem(value: 'nurse', child: Text('Hemşire')),
                DropdownMenuItem(value: 'secretary', child: Text('Sekreter')),
                DropdownMenuItem(value: 'manager', child: Text('Yönetici')),
                DropdownMenuItem(value: 'technician', child: Text('Teknisyen')),
                DropdownMenuItem(value: 'other', child: Text('Diğer')),
              ],
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Durum',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              dropdownColor: Colors.purple[800],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tümü')),
                DropdownMenuItem(value: 'active', child: Text('Aktif')),
                DropdownMenuItem(value: 'inactive', child: Text('Pasif')),
                DropdownMenuItem(value: 'terminated', child: Text('İşten Ayrıldı')),
                DropdownMenuItem(value: 'onLeave', child: Text('İzinde')),
                DropdownMenuItem(value: 'suspended', child: Text('Askıda')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Employee> _getFilteredEmployees() {
    var filtered = _employees;
    
    if (_selectedRole != 'all') {
      filtered = filtered.where((employee) => 
          employee.role.toString().split('.').last == _selectedRole).toList();
    }
    
    if (_selectedStatus != 'all') {
      filtered = filtered.where((employee) => 
          employee.status.toString().split('.').last == _selectedStatus).toList();
    }
    
    return filtered;
  }

  Widget _buildEmployeeCard(Employee employee) {
    final roleColor = _getRoleColor(employee.role);
    final statusColor = _getStatusColor(employee.status);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${employee.firstName} ${employee.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleName(employee.role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${employee.email}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Telefon: ${employee.phone}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (employee.department != null) ...[
              const SizedBox(height: 4),
              Text(
                'Departman: ${employee.department}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (employee.position != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pozisyon: ${employee.position}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (employee.salary != null) ...[
              const SizedBox(height: 4),
              Text(
                'Maaş: ${employee.salary!.toStringAsFixed(2)} TL',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusName(employee.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'İşe Giriş: ${_formatDate(employee.hireDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (employee.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${employee.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEmployeeDetails(employee),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editEmployee(employee),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewPerformance(employee),
                    icon: const Icon(Icons.assessment),
                    label: const Text('Performans'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsTab() {
    return _leaveRequests.isEmpty
        ? const Center(
            child: Text(
              'İzin talebi bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _leaveRequests.length,
            itemBuilder: (context, index) {
              final leaveRequest = _leaveRequests[index];
              return _buildLeaveRequestCard(leaveRequest);
            },
          );
  }

  Widget _buildLeaveRequestCard(LeaveRequest leaveRequest) {
    final employee = _employees.firstWhere((e) => e.id == leaveRequest.employeeId, orElse: () => Employee(
      id: '',
      firstName: 'Bilinmeyen',
      lastName: 'Personel',
      email: '',
      phone: '',
      address: '',
      birthDate: DateTime.now(),
      hireDate: DateTime.now(),
      role: EmployeeRole.other,
      createdAt: DateTime.now(),
      createdBy: '',
    ));
    
    final typeColor = _getLeaveTypeColor(leaveRequest.type);
    final statusColor = _getLeaveStatusColor(leaveRequest.status);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${employee.firstName} ${employee.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getLeaveTypeName(leaveRequest.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Başlangıç: ${_formatDate(leaveRequest.startDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Bitiş: ${_formatDate(leaveRequest.endDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Toplam Gün: ${leaveRequest.totalDays}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Sebep: ${leaveRequest.reason}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getLeaveStatusName(leaveRequest.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Talep: ${_formatDateTime(leaveRequest.createdAt)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (leaveRequest.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notlar: ${leaveRequest.notes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLeaveRequestDetails(leaveRequest),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveLeaveRequest(leaveRequest),
                    icon: const Icon(Icons.check),
                    label: const Text('Onayla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectLeaveRequest(leaveRequest),
                    icon: const Icon(Icons.close),
                    label: const Text('Reddet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return _performanceReviews.isEmpty
        ? const Center(
            child: Text(
              'Performans değerlendirmesi bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final performanceReview = _performanceReviews[index];
              return _buildPerformanceReviewCard(performanceReview);
            },
          );
  }

  Widget _buildPerformanceReviewCard(PerformanceReview performanceReview) {
    final employee = _employees.firstWhere((e) => e.id == performanceReview.employeeId, orElse: () => Employee(
      id: '',
      firstName: 'Bilinmeyen',
      lastName: 'Personel',
      email: '',
      phone: '',
      address: '',
      birthDate: DateTime.now(),
      hireDate: DateTime.now(),
      role: EmployeeRole.other,
      createdAt: DateTime.now(),
      createdBy: '',
    ));
    
    final ratingColor = _getPerformanceLevelColor(performanceReview.overallRating);
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${employee.firstName} ${employee.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ratingColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPerformanceLevelName(performanceReview.overallRating),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Değerlendirme Tarihi: ${_formatDate(performanceReview.reviewDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Dönem: ${_formatDate(performanceReview.reviewPeriodStart)} - ${_formatDate(performanceReview.reviewPeriodEnd)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kategori Değerlendirmeleri:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...performanceReview.categoryRatings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPerformanceLevelColor(entry.value),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPerformanceLevelName(entry.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Güçlü Yönler: ${performanceReview.strengths}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Gelişim Alanları: ${performanceReview.areasForImprovement}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPerformanceReviewDetails(performanceReview),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editPerformanceReview(performanceReview),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingTab() {
    return _trainingPrograms.isEmpty
        ? const Center(
            child: Text(
              'Eğitim programı bulunamadı',
              style: TextStyle(color: Colors.white70),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _trainingPrograms.length,
            itemBuilder: (context, index) {
              final trainingProgram = _trainingPrograms[index];
              return _buildTrainingProgramCard(trainingProgram);
            },
          );
  }

  Widget _buildTrainingProgramCard(TrainingProgram trainingProgram) {
    final mandatoryColor = trainingProgram.isMandatory ? Colors.red : Colors.blue;
    
    return Card(
      color: Colors.purple[800],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trainingProgram.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mandatoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trainingProgram.isMandatory ? 'ZORUNLU' : 'İSTEĞE BAĞLI',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trainingProgram.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Kategori: ${trainingProgram.category}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Süre: ${trainingProgram.duration} saat',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Başlangıç: ${_formatDate(trainingProgram.startDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Bitiş: ${_formatDate(trainingProgram.endDate)}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (trainingProgram.instructor != null) ...[
              const SizedBox(height: 4),
              Text(
                'Eğitmen: ${trainingProgram.instructor}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (trainingProgram.location != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lokasyon: ${trainingProgram.location}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTrainingProgramDetails(trainingProgram),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Detaylar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _assignTraining(trainingProgram),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Ata'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editTrainingProgram(trainingProgram),
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final statistics = _staffService.getEmployeeStatistics();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personel İstatistikleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Personel', statistics['totalEmployees'].toString(), Colors.blue),
          _buildStatCard('Aktif Personel', statistics['activeEmployees'].toString(), Colors.green),
          _buildStatCard('Pasif Personel', statistics['inactiveEmployees'].toString(), Colors.orange),
          _buildStatCard('İşten Ayrılan', statistics['terminatedEmployees'].toString(), Colors.red),
          _buildStatCard('İzinde', statistics['onLeaveEmployees'].toString(), Colors.purple),
          const SizedBox(height: 24),
          const Text(
            'İzin Talepleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Bekleyen', statistics['pendingLeaveRequests'].toString(), Colors.orange),
          _buildStatCard('Onaylanan', statistics['approvedLeaveRequests'].toString(), Colors.green),
          _buildStatCard('Reddedilen', statistics['rejectedLeaveRequests'].toString(), Colors.red),
          const SizedBox(height: 24),
          const Text(
            'Performans Değerlendirmeleri',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Değerlendirme', statistics['totalPerformanceReviews'].toString(), Colors.blue),
          _buildStatCard('Mükemmel', statistics['excellentReviews'].toString(), Colors.green),
          _buildStatCard('İyi', statistics['goodReviews'].toString(), Colors.blue),
          _buildStatCard('Yeterli', statistics['satisfactoryReviews'].toString(), Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Eğitim Programları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Toplam Program', statistics['totalTrainingPrograms'].toString(), Colors.blue),
          _buildStatCard('Zorunlu Program', statistics['mandatoryPrograms'].toString(), Colors.red),
          _buildStatCard('Tamamlanan Eğitim', statistics['completedTrainings'].toString(), Colors.green),
          _buildStatCard('Devam Eden Eğitim', statistics['inProgressTrainings'].toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.doctor:
        return Colors.blue;
      case EmployeeRole.psychologist:
        return Colors.green;
      case EmployeeRole.nurse:
        return Colors.red;
      case EmployeeRole.secretary:
        return Colors.orange;
      case EmployeeRole.manager:
        return Colors.purple;
      case EmployeeRole.technician:
        return Colors.teal;
      case EmployeeRole.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return Colors.green;
      case EmployeeStatus.inactive:
        return Colors.orange;
      case EmployeeStatus.terminated:
        return Colors.red;
      case EmployeeStatus.onLeave:
        return Colors.blue;
      case EmployeeStatus.suspended:
        return Colors.red;
    }
  }

  Color _getLeaveTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return Colors.green;
      case LeaveType.sick:
        return Colors.red;
      case LeaveType.personal:
        return Colors.blue;
      case LeaveType.maternity:
        return Colors.pink;
      case LeaveType.paternity:
        return Colors.blue;
      case LeaveType.unpaid:
        return Colors.orange;
      case LeaveType.other:
        return Colors.grey;
    }
  }

  Color _getLeaveStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getPerformanceLevelColor(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.excellent:
        return Colors.green;
      case PerformanceLevel.good:
        return Colors.blue;
      case PerformanceLevel.satisfactory:
        return Colors.orange;
      case PerformanceLevel.needsImprovement:
        return Colors.red;
      case PerformanceLevel.poor:
        return Colors.red;
    }
  }

  String _getRoleName(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.doctor:
        return 'DOKTOR';
      case EmployeeRole.psychologist:
        return 'PSİKOLOG';
      case EmployeeRole.nurse:
        return 'HEMŞİRE';
      case EmployeeRole.secretary:
        return 'SEKRETER';
      case EmployeeRole.manager:
        return 'YÖNETİCİ';
      case EmployeeRole.technician:
        return 'TEKNİSYEN';
      case EmployeeRole.other:
        return 'DİĞER';
    }
  }

  String _getStatusName(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return 'AKTİF';
      case EmployeeStatus.inactive:
        return 'PASİF';
      case EmployeeStatus.terminated:
        return 'İŞTEN AYRILDI';
      case EmployeeStatus.onLeave:
        return 'İZİNDE';
      case EmployeeStatus.suspended:
        return 'ASKIDA';
    }
  }

  String _getLeaveTypeName(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return 'YILLIK';
      case LeaveType.sick:
        return 'HASTALIK';
      case LeaveType.personal:
        return 'KİŞİSEL';
      case LeaveType.maternity:
        return 'DOĞUM';
      case LeaveType.paternity:
        return 'BABALIK';
      case LeaveType.unpaid:
        return 'ÜCRETSİZ';
      case LeaveType.other:
        return 'DİĞER';
    }
  }

  String _getLeaveStatusName(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'BEKLİYOR';
      case LeaveStatus.approved:
        return 'ONAYLANDI';
      case LeaveStatus.rejected:
        return 'REDDEDİLDİ';
      case LeaveStatus.cancelled:
        return 'İPTAL';
    }
  }

  String _getPerformanceLevelName(PerformanceLevel level) {
    switch (level) {
      case PerformanceLevel.excellent:
        return 'MÜKEMMEL';
      case PerformanceLevel.good:
        return 'İYİ';
      case PerformanceLevel.satisfactory:
        return 'YETERLİ';
      case PerformanceLevel.needsImprovement:
        return 'GELİŞİM GEREKİR';
      case PerformanceLevel.poor:
        return 'ZAYIF';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Personel Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ad Soyad: ${employee.firstName} ${employee.lastName}', style: const TextStyle(color: Colors.white70)),
              Text('Email: ${employee.email}', style: const TextStyle(color: Colors.white70)),
              Text('Telefon: ${employee.phone}', style: const TextStyle(color: Colors.white70)),
              Text('Adres: ${employee.address}', style: const TextStyle(color: Colors.white70)),
              Text('Doğum Tarihi: ${_formatDate(employee.birthDate)}', style: const TextStyle(color: Colors.white70)),
              Text('İşe Giriş: ${_formatDate(employee.hireDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Rol: ${_getRoleName(employee.role)}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${_getStatusName(employee.status)}', style: const TextStyle(color: Colors.white70)),
              if (employee.department != null)
                Text('Departman: ${employee.department}', style: const TextStyle(color: Colors.white70)),
              if (employee.position != null)
                Text('Pozisyon: ${employee.position}', style: const TextStyle(color: Colors.white70)),
              if (employee.salary != null)
                Text('Maaş: ${employee.salary!.toStringAsFixed(2)} TL', style: const TextStyle(color: Colors.white70)),
              if (employee.emergencyContact != null)
                Text('Acil Durum İletişim: ${employee.emergencyContact}', style: const TextStyle(color: Colors.white70)),
              if (employee.emergencyPhone != null)
                Text('Acil Durum Telefon: ${employee.emergencyPhone}', style: const TextStyle(color: Colors.white70)),
              if (employee.notes != null)
                Text('Notlar: ${employee.notes}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${employee.createdBy}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(employee.createdAt)}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editEmployee(Employee employee) {
    // TODO: Implement employee editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personel düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _viewPerformance(Employee employee) {
    // TODO: Implement performance view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Performans görüntüleme özelliği yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLeaveRequestDetails(LeaveRequest leaveRequest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'İzin Talebi Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tür: ${_getLeaveTypeName(leaveRequest.type)}', style: const TextStyle(color: Colors.white70)),
              Text('Başlangıç: ${_formatDate(leaveRequest.startDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Bitiş: ${_formatDate(leaveRequest.endDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Toplam Gün: ${leaveRequest.totalDays}', style: const TextStyle(color: Colors.white70)),
              Text('Sebep: ${leaveRequest.reason}', style: const TextStyle(color: Colors.white70)),
              Text('Durum: ${_getLeaveStatusName(leaveRequest.status)}', style: const TextStyle(color: Colors.white70)),
              if (leaveRequest.approvedBy != null)
                Text('Onaylayan: ${leaveRequest.approvedBy}', style: const TextStyle(color: Colors.white70)),
              if (leaveRequest.approvedAt != null)
                Text('Onay Tarihi: ${_formatDateTime(leaveRequest.approvedAt!)}', style: const TextStyle(color: Colors.white70)),
              if (leaveRequest.rejectionReason != null)
                Text('Red Sebebi: ${leaveRequest.rejectionReason}', style: const TextStyle(color: Colors.white70)),
              if (leaveRequest.notes != null)
                Text('Notlar: ${leaveRequest.notes}', style: const TextStyle(color: Colors.white70)),
              Text('Talep Eden: ${leaveRequest.createdBy}', style: const TextStyle(color: Colors.white70)),
              Text('Talep Tarihi: ${_formatDateTime(leaveRequest.createdAt)}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _approveLeaveRequest(LeaveRequest leaveRequest) {
    // TODO: Implement leave request approval
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İzin onaylama formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectLeaveRequest(LeaveRequest leaveRequest) {
    // TODO: Implement leave request rejection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İzin reddetme formu yakında eklenecek'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPerformanceReviewDetails(PerformanceReview performanceReview) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Performans Değerlendirme Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Değerlendirme Tarihi: ${_formatDate(performanceReview.reviewDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Dönem: ${_formatDate(performanceReview.reviewPeriodStart)} - ${_formatDate(performanceReview.reviewPeriodEnd)}', style: const TextStyle(color: Colors.white70)),
              Text('Genel Değerlendirme: ${_getPerformanceLevelName(performanceReview.overallRating)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('Kategori Değerlendirmeleri:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ...performanceReview.categoryRatings.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• ${entry.key}: ${_getPerformanceLevelName(entry.value)}', style: const TextStyle(color: Colors.white70)),
                );
              }),
              const SizedBox(height: 8),
              Text('Güçlü Yönler: ${performanceReview.strengths}', style: const TextStyle(color: Colors.white70)),
              Text('Gelişim Alanları: ${performanceReview.areasForImprovement}', style: const TextStyle(color: Colors.white70)),
              Text('Hedefler: ${performanceReview.goals}', style: const TextStyle(color: Colors.white70)),
              Text('Yorumlar: ${performanceReview.comments}', style: const TextStyle(color: Colors.white70)),
              Text('Değerlendiren: ${performanceReview.reviewedBy}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(performanceReview.createdAt)}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editPerformanceReview(PerformanceReview performanceReview) {
    // TODO: Implement performance review editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Performans değerlendirme düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showTrainingProgramDetails(TrainingProgram trainingProgram) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[800],
        title: const Text(
          'Eğitim Programı Detayları',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Başlık: ${trainingProgram.title}', style: const TextStyle(color: Colors.white70)),
              Text('Açıklama: ${trainingProgram.description}', style: const TextStyle(color: Colors.white70)),
              Text('Kategori: ${trainingProgram.category}', style: const TextStyle(color: Colors.white70)),
              Text('Süre: ${trainingProgram.duration} saat', style: const TextStyle(color: Colors.white70)),
              Text('Başlangıç: ${_formatDate(trainingProgram.startDate)}', style: const TextStyle(color: Colors.white70)),
              Text('Bitiş: ${_formatDate(trainingProgram.endDate)}', style: const TextStyle(color: Colors.white70)),
              if (trainingProgram.instructor != null)
                Text('Eğitmen: ${trainingProgram.instructor}', style: const TextStyle(color: Colors.white70)),
              if (trainingProgram.location != null)
                Text('Lokasyon: ${trainingProgram.location}', style: const TextStyle(color: Colors.white70)),
              Text('Zorunlu: ${trainingProgram.isMandatory ? 'Evet' : 'Hayır'}', style: const TextStyle(color: Colors.white70)),
              if (trainingProgram.certificate != null)
                Text('Sertifika: ${trainingProgram.certificate}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturan: ${trainingProgram.createdBy}', style: const TextStyle(color: Colors.white70)),
              Text('Oluşturulma: ${_formatDateTime(trainingProgram.createdAt)}', style: const TextStyle(color: Colors.white70)),
              if (trainingProgram.requiredRoles.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Gerekli Roller:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ...trainingProgram.requiredRoles.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $role', style: const TextStyle(color: Colors.white70)),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _assignTraining(TrainingProgram trainingProgram) {
    // TODO: Implement training assignment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eğitim atama formu yakında eklenecek'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editTrainingProgram(TrainingProgram trainingProgram) {
    // TODO: Implement training program editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eğitim programı düzenleme formu yakında eklenecek'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
