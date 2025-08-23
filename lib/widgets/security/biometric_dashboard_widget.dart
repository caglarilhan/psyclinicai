import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import '../../services/biometric_auth_service.dart';

class BiometricDashboardWidget extends StatefulWidget {
  const BiometricDashboardWidget({super.key});

  @override
  State<BiometricDashboardWidget> createState() => _BiometricDashboardWidgetState();
}

class _BiometricDashboardWidgetState extends State<BiometricDashboardWidget> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _fingerprintController = TextEditingController();
  final TextEditingController _faceDataController = TextEditingController();
  
  String _currentUserId = 'demo_user_001';
  BiometricProfile? _currentProfile;
  List<BiometricAuthEvent> _recentEvents = [];
  List<BiometricAlert> _activeAlerts = [];
  
  bool _isLoading = false;
  String _lastAuthResult = '';

  @override
  void initState() {
    super.initState();
    _userIdController.text = _currentUserId;
    _loadBiometricProfile();
    _loadRecentEvents();
    _loadActiveAlerts();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _fingerprintController.dispose();
    _faceDataController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _biometricService.getBiometricProfile(_currentUserId);
      setState(() {
        _currentProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading biometric profile: $e');
    }
  }

  Future<void> _loadRecentEvents() async {
    try {
      // Mock recent events for demo
      setState(() {
        _recentEvents = [
          BiometricAuthEvent(
            id: 'event_1',
            userId: _currentUserId,
            eventType: BiometricEventType.authentication,
            biometricType: BiometricType.fingerprint,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            success: true,
            details: 'Login successful',
          ),
          BiometricAuthEvent(
            id: 'event_2',
            userId: _currentUserId,
            eventType: BiometricEventType.enrollment,
            biometricType: BiometricType.face,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            success: true,
            details: 'Face recognition enrolled',
          ),
        ];
      });
    } catch (e) {
      print('Error loading recent events: $e');
    }
  }

  Future<void> _loadActiveAlerts() async {
    try {
      // Mock active alerts for demo
      setState(() {
        _activeAlerts = [
          BiometricAlert(
            id: 'alert_1',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            userId: _currentUserId,
            alertType: 'unusual_access_pattern',
            severity: BiometricAlertSeverity.medium,
            details: 'Multiple failed attempts detected',
            status: BiometricAlertStatus.active,
          ),
        ];
      });
    } catch (e) {
      print('Error loading active alerts: $e');
    }
  }

  Future<void> _enrollFingerprint() async {
    if (_fingerprintController.text.isEmpty) {
      _showSnackBar('Please enter fingerprint data', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _biometricService.enrollFingerprint(
        userId: _currentUserId,
        fingerprintData: _fingerprintController.text,
        description: 'Primary fingerprint',
      );

      if (success) {
        _showSnackBar('✅ Fingerprint enrolled successfully!');
        _fingerprintController.clear();
        await _loadBiometricProfile();
      } else {
        _showSnackBar('❌ Failed to enroll fingerprint', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enrollFaceRecognition() async {
    if (_faceDataController.text.isEmpty) {
      _showSnackBar('Please enter face data', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _biometricService.enrollFaceRecognition(
        userId: _currentUserId,
        faceData: _faceDataController.text,
        description: 'Primary face recognition',
      );

      if (success) {
        _showSnackBar('✅ Face recognition enrolled successfully!');
        _faceDataController.clear();
        await _loadBiometricProfile();
      } else {
        _showSnackBar('❌ Failed to enroll face recognition', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticateWithFingerprint() async {
    if (_fingerprintController.text.isEmpty) {
      _showSnackBar('Please enter fingerprint data', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _biometricService.authenticateWithFingerprint(
        userId: _currentUserId,
        fingerprintData: _fingerprintController.text,
      );

      setState(() {
        _lastAuthResult = result.message;
        _isLoading = false;
      });

      if (result.success) {
        _showSnackBar('🔓 Authentication successful! Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
        await _loadRecentEvents();
      } else {
        _showSnackBar('❌ Authentication failed: ${result.message}', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _authenticateWithFace() async {
    if (_faceDataController.text.isEmpty) {
      _showSnackBar('Please enter face data', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _biometricService.authenticateWithFace(
        userId: _currentUserId,
        faceData: _faceDataController.text,
      );

      setState(() {
        _lastAuthResult = result.message;
        _isLoading = false;
      });

      if (result.success) {
        _showSnackBar('🔓 Face recognition successful! Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%');
        await _loadRecentEvents();
      } else {
        _showSnackBar('❌ Face recognition failed: ${result.message}', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: $e', isError: true);
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
        title: const Text('🔐 Biometric Authentication Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User ID Section
            _buildUserSection(),
            const SizedBox(height: 24),
            
            // Biometric Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),
            
            // Enrollment Section
            _buildEnrollmentSection(),
            const SizedBox(height: 24),
            
            // Authentication Section
            _buildAuthenticationSection(),
            const SizedBox(height: 24),
            
            // Recent Events Section
            _buildRecentEventsSection(),
            const SizedBox(height: 24),
            
            // Active Alerts Section
            _buildActiveAlertsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'User Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              onChanged: (value) {
                setState(() => _currentUserId = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadBiometricProfile,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () {
                      _userIdController.text = 'demo_user_001';
                      setState(() => _currentUserId = 'demo_user_001');
                      _loadBiometricProfile();
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset to Demo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  Widget _buildProfileSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fingerprint, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Biometric Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_currentProfile == null)
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No biometric profile found for this user. Please enroll a biometric method.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfo('Type', _currentProfile!.type.name.toUpperCase()),
                  _buildProfileInfo('Description', _currentProfile!.description),
                  _buildProfileInfo('Enrolled', _formatDate(_currentProfile!.enrolledAt)),
                  _buildProfileInfo('Last Used', _formatDate(_currentProfile!.lastUsed)),
                  _buildProfileInfo('Status', _currentProfile!.isActive ? 'Active' : 'Inactive'),
                  _buildProfileInfo('Confidence', '${(_currentProfile!.confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Enroll Biometric Methods',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Fingerprint Enrollment
            const Text(
              'Fingerprint Enrollment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fingerprintController,
              decoration: const InputDecoration(
                labelText: 'Fingerprint Data (Demo: enter any text)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fingerprint),
                hintText: 'e.g., fingerprint_001',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _enrollFingerprint,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Enroll Fingerprint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Face Recognition Enrollment
            const Text(
              'Face Recognition Enrollment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _faceDataController,
              decoration: const InputDecoration(
                labelText: 'Face Data (Demo: enter any text)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.face),
                hintText: 'e.g., face_001',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _enrollFaceRecognition,
                icon: const Icon(Icons.face),
                label: const Text('Enroll Face Recognition'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_open, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Authentication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_lastAuthResult.isNotEmpty)
              Card(
                color: _lastAuthResult.contains('successful') ? Colors.green.shade100 : Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        _lastAuthResult.contains('successful') ? Icons.check_circle : Icons.error,
                        color: _lastAuthResult.contains('successful') ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last Result: $_lastAuthResult',
                          style: TextStyle(
                            color: _lastAuthResult.contains('successful') ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _authenticateWithFingerprint,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Authenticate with Fingerprint'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _authenticateWithFace,
                    icon: const Icon(Icons.face),
                    label: const Text('Authenticate with Face'),
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

  Widget _buildRecentEventsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Recent Authentication Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentEvents.isEmpty)
              const Center(
                child: Text(
                  'No recent events',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentEvents.length,
                itemBuilder: (context, index) {
                  final event = _recentEvents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: event.success ? Colors.green.shade50 : Colors.red.shade50,
                    child: ListTile(
                      leading: Icon(
                        event.biometricType == BiometricType.fingerprint 
                            ? Icons.fingerprint 
                            : Icons.face,
                        color: event.success ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${event.eventType.name.toUpperCase()} - ${event.biometricType.name.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${_formatDate(event.timestamp)}\n${event.details ?? ''}',
                      ),
                      trailing: Icon(
                        event.success ? Icons.check_circle : Icons.error,
                        color: event.success ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlertsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.deepPurple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Active Security Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_activeAlerts.isEmpty)
              const Center(
                child: Text(
                  'No active alerts',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _activeAlerts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: _getAlertColor(alert.severity),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning,
                        color: _getAlertIconColor(alert.severity),
                      ),
                      title: Text(
                        alert.alertType.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getAlertIconColor(alert.severity),
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(alert.timestamp)}\n${alert.details ?? ''}',
                        style: TextStyle(
                          color: _getAlertIconColor(alert.severity),
                        ),
                      ),
                      trailing: Chip(
                        label: Text(
                          alert.severity.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getAlertIconColor(alert.severity),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(BiometricAlertSeverity severity) {
    switch (severity) {
      case BiometricAlertSeverity.low:
        return Colors.blue.shade50;
      case BiometricAlertSeverity.medium:
        return Colors.orange.shade50;
      case BiometricAlertSeverity.high:
        return Colors.red.shade50;
      case BiometricAlertSeverity.critical:
        return Colors.purple.shade50;
    }
  }

  Color _getAlertIconColor(BiometricAlertSeverity severity) {
    switch (severity) {
      case BiometricAlertSeverity.low:
        return Colors.blue;
      case BiometricAlertSeverity.medium:
        return Colors.orange;
      case BiometricAlertSeverity.high:
        return Colors.red;
      case BiometricAlertSeverity.critical:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
