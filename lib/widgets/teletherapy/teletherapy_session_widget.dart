import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../services/teletherapy_service.dart';
import '../../utils/theme.dart';
import '../../utils/identity_validation.dart';

class TeletherapySessionWidget extends StatefulWidget {
  final String clientName;
  final String therapistName;
  const TeletherapySessionWidget({super.key, required this.clientName, required this.therapistName});

  @override
  State<TeletherapySessionWidget> createState() => _TeletherapySessionWidgetState();
}

class _TeletherapySessionWidgetState extends State<TeletherapySessionWidget> {
  final TeletherapyService _service = TeletherapyService();
  TeletherapySession? _session;
  bool _busy = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'TR');
  final TextEditingController _idController = TextEditingController();
  
  // Gelişmiş özellikler
  List<Map<String, dynamic>> _waitingParticipants = [];
  bool _isHost = false;
  bool _isWaitingRoom = true;
  bool _isSessionActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.videocam, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Teleterapi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          if (_session == null) ...[
            Text('Danışan: ${widget.clientName}'),
            Text('Terapist: ${widget.therapistName}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _createAsHost,
                    icon: _busy ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.play_circle),
                    label: Text(_busy ? 'Oluşturuluyor...' : 'Host Olarak Başlat'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _joinAsParticipant,
                    icon: const Icon(Icons.login),
                    label: const Text('Katılımcı Olarak Katıl'),
                  ),
                ),
              ],
            )
          ] else ...[
            // Host/Participant kontrolü
            if (_isHost) ...[
              Text('Host: ${widget.therapistName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ] else ...[
              Text('Katılımcı: ${widget.clientName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ],
            
            Text('Oturum ID: ${_session!.sessionId}'),
            const SizedBox(height: 4),
            SelectableText(_session!.meetingUrl, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            
            // Bekleme odası durumu
            if (_isWaitingRoom) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Bekleme Odasında'),
                    const Spacer(),
                    if (_isHost)
                      ElevatedButton(
                        onPressed: _admitParticipants,
                        child: const Text('Katılımcıları Kabul Et'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => Clipboard.setData(ClipboardData(text: _session!.meetingUrl)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bağlantı kopyalandı')));
                  }),
                  icon: const Icon(Icons.copy),
                  label: const Text('Linki Kopyala'),
                ),
                const SizedBox(width: 12),
                Chip(label: Text('Süre: ' + _format(_elapsed))),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(_session!.locked ? Icons.lock : Icons.lock_open, color: _session!.locked ? Colors.red : Colors.green),
              const SizedBox(width: 6),
              Text(_session!.locked ? 'Oda kilitli' : 'Oda açık'),
              const Spacer(),
              Text('Şifre: ${_session!.passcode}', style: Theme.of(context).textTheme.bodySmall),
              if (_isHost) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _toggleRoomLock,
                  icon: Icon(_session!.locked ? Icons.lock_open : Icons.lock),
                  tooltip: _session!.locked ? 'Kilidi Aç' : 'Kilitle',
                ),
              ],
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kimlik doğrulama alanları
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ad Soyad')),
                    const SizedBox(height: 8),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-posta')),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextField(controller: _countryController, decoration: const InputDecoration(labelText: 'Ülke (TR/US/UK/DE/FR)'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _idController, decoration: const InputDecoration(labelText: 'Kimlik/SSN/NHS'))),
                    ]),
                    const SizedBox(height: 8),
                    if (_session!.locked) ...[
                      TextField(
                        controller: _passController,
                        decoration: const InputDecoration(labelText: 'Oda şifresi'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _join,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Bağlantıyı Aç'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _end,
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('Oturumu Bitir'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
                ),
              ),
            ])
          ]
        ],
      ),
    );
  }

  Future<void> _createAsHost() async {
    setState(() => _busy = true);
    try {
      final s = await _service.createSession(clientName: widget.clientName, therapistName: widget.therapistName, locked: true);
      if (mounted) {
        setState(() {
          _session = s;
          _isHost = true;
          _isWaitingRoom = true;
          _isSessionActive = false;
        });
        _startTimer();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinAsParticipant() async {
    // Session ID girişi için dialog göster
    final sessionId = await _showSessionIdDialog();
    if (sessionId == null) return;
    
    setState(() => _busy = true);
    try {
      // Mock session oluştur (gerçek uygulamada API'den alınır)
      final s = TeletherapySession(
        sessionId: sessionId,
        clientName: widget.clientName,
        therapistName: widget.therapistName,
        meetingUrl: 'https://meet.example.com/$sessionId',
        passcode: '123456',
        locked: true,
        createdAt: DateTime.now(),
      );
      
      if (mounted) {
        setState(() {
          _session = s;
          _isHost = false;
          _isWaitingRoom = true;
          _isSessionActive = false;
        });
        _startTimer();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _showSessionIdDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oturum ID Gir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Oturum ID',
            hintText: 'Oturum ID\'sini girin',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Katıl'),
          ),
        ],
      ),
    );
  }

  Future<void> _admitParticipants() async {
    setState(() {
      _isWaitingRoom = false;
      _isSessionActive = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Katılımcılar kabul edildi')),
    );
  }

  Future<void> _toggleRoomLock() async {
    if (_session == null) return;
    
    setState(() => _busy = true);
    try {
      // Mock lock toggle (gerçek uygulamada API çağrısı yapılır)
      final updatedSession = TeletherapySession(
        sessionId: _session!.sessionId,
        clientName: _session!.clientName,
        therapistName: _session!.therapistName,
        meetingUrl: _session!.meetingUrl,
        passcode: _session!.passcode,
        locked: !_session!.locked,
        createdAt: _session!.createdAt,
      );
      
      setState(() => _session = updatedSession);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updatedSession.locked ? 'Oda kilitlendi' : 'Oda kilidi açıldı')),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    final s = _session; if (s == null) return;
    
    // Kimlik doğrulama
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final country = _countryController.text.trim().toUpperCase();
    final idVal = _idController.text.trim();
    
    if (name.isEmpty || !IdentityValidation.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad ve geçerli e-posta zorunlu')));
      return;
    }
    
    bool idOk = true;
    switch (country) {
      case 'TR':
        idOk = IdentityValidation.isValidTCKN(idVal);
        break;
      case 'US':
        idOk = IdentityValidation.isValidUSSSN(idVal);
        break;
      case 'UK':
        idOk = IdentityValidation.isValidUKNHS(idVal);
        break;
      case 'DE':
        idOk = IdentityValidation.isValidDEInsurance(idVal);
        break;
      case 'FR':
        idOk = IdentityValidation.isValidFRNIR(idVal);
        break;
      default:
        idOk = idVal.isNotEmpty; // diğer ülkeler için temel zorunluluk
    }
    
    if (!idOk) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kimlik numarası geçerli değil')));
      return;
    }
    
    if (s.locked && _passController.text.trim() != s.passcode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şifre hatalı')));
      return;
    }
    
    setState(() => _busy = true);
    try {
      // Katılımcı bilgilerini kaydet
      final participant = {
        'name': name,
        'email': email,
        'country': country,
        'id': idVal,
        'joinedAt': DateTime.now().toIso8601String(),
        'isHost': _isHost,
      };
      
      _waitingParticipants.add(participant);
      
      // Bekleme odasından çık
      if (_isWaitingRoom) {
        setState(() {
          _isWaitingRoom = false;
          _isSessionActive = true;
        });
      }
      
      await _service.openMeetingUrl(s.meetingUrl, clientName: s.clientName, therapistName: s.therapistName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturuma başarıyla katıldınız')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _end() async {
    final s = _session; if (s == null) return;
    setState(() => _busy = true);
    try {
      await _service.endSession(s);
      if (mounted) setState(() { _session = null; _stopTimer(); _elapsed = Duration.zero; });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _elapsed + const Duration(seconds: 1));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  void dispose() {
    _stopTimer();
    _passController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _idController.dispose();
    super.dispose();
  }
}


