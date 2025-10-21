import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class TelemedicineScreen extends StatefulWidget {
  final String? initialPatientName;
  final String? initialPatientId;
  const TelemedicineScreen({super.key, this.initialPatientName, this.initialPatientId});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isInitialized = false;
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;
  
  String _callStatus = 'Bağlantı bekleniyor...';
  String _patientName = 'Ahmet Yılmaz';
  String _patientId = '1';
  DateTime _callStartTime = DateTime.now();
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    if (widget.initialPatientName != null) {
      _patientName = widget.initialPatientName!;
    }
    if (widget.initialPatientId != null) {
      _patientId = widget.initialPatientId!;
    }
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemedicine'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showCallInfo,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Ana video alanı
              Expanded(
                flex: 3,
                child: _buildVideoArea(),
              ),
              
              // Kontrol paneli (overflow güvenli)
              SizedBox(
                height: 200,
                child: SingleChildScrollView(child: _buildControlPanel()),
              ),
              
              // Alt panel
              _buildBottomPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Uzak video (ana ekran)
          Positioned.fill(
            child: _isCallActive
                ? RTCVideoView(_remoteRenderer)
                : _buildWaitingScreen(),
          ),
          
          // Yerel video (küçük pencere)
          if (_isCallActive && _isVideoEnabled)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RTCVideoView(_localRenderer),
                ),
              ),
            ),
          
          // Çağrı durumu
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _callStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Çağrı süresi
          if (_isCallActive)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDuration(_callDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Video görüşme başlatılıyor...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hasta: $_patientName',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Üst kontroller
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'Ses Aç' : 'Ses Kapat',
                  color: _isMuted ? Colors.red : Colors.blue,
                  onPressed: _toggleMute,
                ),
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: _isVideoEnabled ? 'Video Kapat' : 'Video Aç',
                  color: _isVideoEnabled ? Colors.blue : Colors.red,
                  onPressed: _toggleVideo,
                ),
                _buildControlButton(
                  icon: Icons.screen_share,
                  label: 'Ekran Paylaş',
                  color: _isScreenSharing ? Colors.green : Colors.orange,
                  onPressed: _toggleScreenShare,
                ),
              ],
            ),
          ),
          
          // Alt kontroller
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.chat,
                  label: 'Sohbet',
                  color: Colors.purple,
                  onPressed: _openChat,
                ),
                _buildControlButton(
                  icon: Icons.record_voice_over,
                  label: 'Kayıt',
                  color: Colors.red,
                  onPressed: _toggleRecording,
                ),
                _buildControlButton(
                  icon: Icons.people,
                  label: 'Katılımcı',
                  color: Colors.green,
                  onPressed: _addParticipant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Çağrı bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasta: $_patientName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: $_patientId',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Ana kontrol butonları
          Row(
            children: [
              // Çağrıyı sonlandır
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.white, size: 24),
                  onPressed: _endCall,
                ),
              ),
              const SizedBox(width: 16),
              
              // Çağrıyı başlat/durdur
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _isCallActive ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isCallActive ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _isCallActive ? _pauseCall : _startCall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Mikrofon kapatıldı' : 'Mikrofon açıldı'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isVideoEnabled ? 'Video açıldı' : 'Video kapatıldı'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleScreenShare() {
    setState(() {
      _isScreenSharing = !_isScreenSharing;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isScreenSharing ? 'Ekran paylaşımı başlatıldı' : 'Ekran paylaşımı durduruldu'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbet'),
        content: const Text('Sohbet özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt özelliği yakında eklenecek'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addParticipant() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Katılımcı Ekle'),
        content: const Text('Katılımcı ekleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _startCall() {
    setState(() {
      _isCallActive = true;
      _callStatus = 'Çağrı aktif';
      _callStartTime = DateTime.now();
    });
    
    // Simüle edilmiş çağrı süresi
    _startCallTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Çağrı başlatıldı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _pauseCall() {
    setState(() {
      _isCallActive = false;
      _callStatus = 'Çağrı duraklatıldı';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Çağrı duraklatıldı'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çağrıyı Sonlandır'),
        content: Text('Çağrı süresi: ${_formatDuration(_callDuration)}\n\nÇağrıyı sonlandırmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isCallActive = false;
                _callStatus = 'Çağrı sonlandırıldı';
                _callDuration = Duration.zero;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Çağrı sonlandırıldı'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sonlandır'),
          ),
        ],
      ),
    );
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isCallActive) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime);
        });
        _startCallTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  void _showCallInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çağrı Bilgileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Hasta', _patientName),
            _buildInfoRow('Hasta ID', _patientId),
            _buildInfoRow('Durum', _callStatus),
            _buildInfoRow('Süre', _formatDuration(_callDuration)),
            _buildInfoRow('Ses', _isMuted ? 'Kapalı' : 'Açık'),
            _buildInfoRow('Video', _isVideoEnabled ? 'Açık' : 'Kapalı'),
            _buildInfoRow('Ekran Paylaşımı', _isScreenSharing ? 'Aktif' : 'Pasif'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }
}
