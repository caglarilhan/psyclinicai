import 'package:flutter/material.dart';
import '../../services/fhir_integration_service.dart';

class FHIRDashboardWidget extends StatefulWidget {
  const FHIRDashboardWidget({super.key});

  @override
  State<FHIRDashboardWidget> createState() => _FHIRDashboardWidgetState();
}

class _FHIRDashboardWidgetState extends State<FHIRDashboardWidget> {
  final FHIRIntegrationService _fhirService = FHIRIntegrationService();
  final TextEditingController _searchController = TextEditingController();
  
  FHIRStatistics? _statistics;
  List<FHIRPatient> _patients = [];
  List<FHIRObservation> _observations = [];
  List<FHIRMedication> _medications = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedResourceType = 'patients';

  @override
  void initState() {
    super.initState();
    _initializeFHIRService();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeFHIRService() async {
    await _fhirService.initialize();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _fhirService.getFHIRStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading FHIR statistics: $e');
    }
  }

  Future<void> _searchPatients() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final patients = await _fhirService.searchPatients(
        name: _searchController.text,
        limit: 20,
      );
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error searching patients: $e');
    }
  }

  Future<void> _searchObservations() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final observations = await _fhirService.searchObservations(
        code: _searchController.text,
        limit: 20,
      );
      setState(() {
        _observations = observations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error searching observations: $e');
    }
  }

  Future<void> _searchMedications() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final medications = await _fhirService.searchMedications(
        name: _searchController.text,
        limit: 20,
      );
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error searching medications: $e');
    }
  }

  Future<void> _performSearch() async {
    _searchQuery = _searchController.text;
    
    switch (_selectedResourceType) {
      case 'patients':
        await _searchPatients();
        break;
      case 'observations':
        await _searchObservations();
        break;
      case 'medications':
        await _searchMedications();
        break;
    }
  }

  Future<void> _syncWithFHIR() async {
    setState(() => _isLoading = true);
    try {
      await _fhirService.syncWithFHIR();
      await _loadStatistics();
      _showSnackBar('✅ FHIR sync completed successfully!');
    } catch (e) {
      _showSnackBar('❌ FHIR sync failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔗 FHIR Integration Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            _buildConnectionStatus(),
            const SizedBox(height: 24),
            
            // FHIR Statistics
            _buildStatistics(),
            const SizedBox(height: 24),
            
            // Search Section
            _buildSearchSection(),
            const SizedBox(height: 24),
            
            // Results Section
            _buildResultsSection(),
            const SizedBox(height: 24),
            
            // Sync Controls
            _buildSyncControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _fhirService.isConnected ? Icons.link : Icons.link_off,
                  color: _fhirService.isConnected ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'FHIR Server Connection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Status',
                    _fhirService.isConnected ? 'Connected' : 'Disconnected',
                    _fhirService.isConnected ? Colors.green : Colors.red,
                    _fhirService.isConnected ? Icons.check_circle : Icons.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Server',
                    _fhirService.config?.baseUrl.split('/').last ?? 'Unknown',
                    Colors.blue,
                    Icons.dns,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_fhirService.lastSyncTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Last sync: ${_formatDate(_fhirService.lastSyncTime!)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'FHIR Server Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Patients',
                    '${_statistics!.totalPatients}',
                    Colors.blue,
                    Icons.people,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Observations',
                    '${_statistics!.totalObservations}',
                    Colors.green,
                    Icons.analytics,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Medications',
                    '${_statistics!.totalMedications}',
                    Colors.orange,
                    Icons.medication,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Pending Sync',
                    '${_statistics!.pendingSyncCount}',
                    Colors.purple,
                    Icons.sync,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Search FHIR Resources',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Resource Type Selector
            DropdownButtonFormField<String>(
              value: _selectedResourceType,
              decoration: const InputDecoration(
                labelText: 'Resource Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'patients', child: Text('Patients')),
                DropdownMenuItem(value: 'observations', child: Text('Observations')),
                DropdownMenuItem(value: 'medications', child: Text('Medications')),
              ],
              onChanged: (value) {
                setState(() => _selectedResourceType = value!);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: _getSearchLabel(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _patients.clear();
                      _observations.clear();
                      _medications.clear();
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _performSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSearchLabel() {
    switch (_selectedResourceType) {
      case 'patients':
        return 'Search by patient name or identifier';
      case 'observations':
        return 'Search by observation code or category';
      case 'medications':
        return 'Search by medication name or code';
      default:
        return 'Search';
    }
  }

  Widget _buildResultsSection() {
    if (_searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.results, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Search Results for "$_searchQuery"',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    switch (_selectedResourceType) {
      case 'patients':
        return _buildPatientsList();
      case 'observations':
        return _buildObservationsList();
      case 'medications':
        return _buildMedicationsList();
      default:
        return const Text('No results');
    }
  }

  Widget _buildPatientsList() {
    if (_patients.isEmpty) {
      return const Center(
        child: Text(
          'No patients found',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
        final patient = _patients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              patient.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'ID: ${patient.identifier} | Gender: ${patient.gender}\n'
              'Birth: ${_formatDate(patient.birthDate)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showPatientDetails(patient),
            ),
          ),
        );
      },
    );
  }

  Widget _buildObservationsList() {
    if (_observations.isEmpty) {
      return const Center(
        child: Text(
          'No observations found',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _observations.length,
      itemBuilder: (context, index) {
        final observation = _observations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.analytics, color: Colors.white),
            ),
            title: Text(
              observation.code,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Category: ${observation.category} | Value: ${observation.value} ${observation.unit}\n'
              'Date: ${_formatDate(observation.effectiveDate)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showObservationDetails(observation),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationsList() {
    if (_medications.isEmpty) {
      return const Center(
        child: Text(
          'No medications found',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.medication, color: Colors.white),
            ),
            title: Text(
              medication.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Code: ${medication.code} | Form: ${medication.form}\n'
              'Strength: ${medication.strength} | Active: ${medication.isActive ? "Yes" : "No"}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showMedicationDetails(medication),
            ),
          ),
        );
      },
    );
  }

  void _showPatientDetails(FHIRPatient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient: ${patient.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${patient.identifier}'),
            Text('Gender: ${patient.gender}'),
            Text('Birth Date: ${_formatDate(patient.birthDate)}'),
            Text('Address: ${patient.address}'),
            Text('Phone: ${patient.phone}'),
            Text('Email: ${patient.email}'),
            Text('Created: ${_formatDate(patient.createdAt)}'),
            Text('Updated: ${_formatDate(patient.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showObservationDetails(FHIRObservation observation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Observation: ${observation.code}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${observation.id}'),
            Text('Patient ID: ${observation.patientId}'),
            Text('Category: ${observation.category}'),
            Text('Value: ${observation.value} ${observation.unit}'),
            Text('Effective Date: ${_formatDate(observation.effectiveDate)}'),
            Text('Status: ${observation.status}'),
            Text('Created: ${_formatDate(observation.createdAt)}'),
            Text('Updated: ${_formatDate(observation.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMedicationDetails(FHIRMedication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Medication: ${medication.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${medication.id}'),
            Text('Code: ${medication.code}'),
            Text('Manufacturer: ${medication.manufacturer}'),
            Text('Form: ${medication.form}'),
            Text('Strength: ${medication.strength}'),
            Text('Active: ${medication.isActive ? "Yes" : "No"}'),
            Text('Created: ${_formatDate(medication.createdAt)}'),
            Text('Updated: ${_formatDate(medication.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'FHIR Synchronization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || !_fhirService.isConnected ? null : _syncWithFHIR,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync with FHIR Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadStatistics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Statistics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (!_fhirService.isConnected)
              const Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cannot sync while disconnected from FHIR server.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
