import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SignalingService {
  static final SignalingService _instance = SignalingService._internal();
  factory SignalingService() => _instance;
  SignalingService._internal();

  WebSocket? _socket;
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<void> connect({required Uri url, required String roomId, required String userId}) async {
    if (_socket != null) return;
    try {
      _socket = await WebSocket.connect(url.toString());
      _socket!.listen((data) {
        try {
          final msg = jsonDecode(data as String) as Map<String, dynamic>;
          _events.add(msg);
        } catch (_) {}
      }, onDone: () {
        _socket = null;
      }, onError: (_) {
        _socket = null;
      });

      // oda katılım bildirimi
      send({'type': 'join', 'roomId': roomId, 'userId': userId});
    } catch (e) {
      // Demo: sunucu yoksa local mock event üret
      _socket = null;
      Timer(const Duration(milliseconds: 10), () {
        _events.add({'type': 'joined', 'roomId': roomId, 'userId': userId});
      });
    }
  }

  void send(Map<String, dynamic> data) {
    final s = _socket;
    final payload = jsonEncode(data);
    if (s != null) {
      s.add(payload);
    } else {
      // mock: loopback
      Timer(const Duration(milliseconds: 5), () => _events.add(data));
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}


