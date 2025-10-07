import 'dart:async';

enum TeleCallStatus { idle, waiting, connecting, inCall, ended }

class TeletherapyEvent {
  final String type; // e.g. join, leave, mute, unmute
  final DateTime at;
  final Map<String, Object?> data;
  TeletherapyEvent(this.type, {Map<String, Object?>? data})
      : at = DateTime.now(),
        data = data ?? const {};
}

class TeletherapyService {
  static final TeletherapyService _instance = TeletherapyService._internal();
  factory TeletherapyService() => _instance;
  TeletherapyService._internal();

  final _statusCtrl = StreamController<TeleCallStatus>.broadcast();
  final _eventCtrl = StreamController<TeletherapyEvent>.broadcast();
  final _transcriptCtrl = StreamController<String>.broadcast();

  TeleCallStatus _status = TeleCallStatus.idle;
  bool _micOn = true;
  bool _camOn = true;
  Timer? _fakeConnectTimer;
  Timer? _fakeTranscriptTimer;

  Stream<TeleCallStatus> get statusStream => _statusCtrl.stream;
  Stream<TeletherapyEvent> get eventStream => _eventCtrl.stream;
  Stream<String> get transcriptStream => _transcriptCtrl.stream;

  TeleCallStatus get status => _status;
  bool get micOn => _micOn;
  bool get camOn => _camOn;

  void enterWaitingRoom() {
    _setStatus(TeleCallStatus.waiting);
    _eventCtrl.add(TeletherapyEvent('waiting.enter'));
  }

  void startConnecting() {
    _setStatus(TeleCallStatus.connecting);
    _eventCtrl.add(TeletherapyEvent('call.connecting'));
    _fakeConnectTimer?.cancel();
    _fakeConnectTimer = Timer(const Duration(seconds: 2), () {
      _setStatus(TeleCallStatus.inCall);
      _eventCtrl.add(TeletherapyEvent('call.started'));
      _beginFakeTranscript();
    });
  }

  void endCall() {
    _fakeConnectTimer?.cancel();
    _stopFakeTranscript();
    _setStatus(TeleCallStatus.ended);
    _eventCtrl.add(TeletherapyEvent('call.ended'));
  }

  void toggleMic() {
    _micOn = !_micOn;
    _eventCtrl.add(TeletherapyEvent(_micOn ? 'mic.on' : 'mic.off'));
  }

  void toggleCam() {
    _camOn = !_camOn;
    _eventCtrl.add(TeletherapyEvent(_camOn ? 'cam.on' : 'cam.off'));
  }

  void dispose() {
    _statusCtrl.close();
    _eventCtrl.close();
    _transcriptCtrl.close();
    _fakeConnectTimer?.cancel();
    _stopFakeTranscript();
  }

  void _setStatus(TeleCallStatus s) {
    _status = s;
    _statusCtrl.add(s);
  }

  void _beginFakeTranscript() {
    int counter = 1;
    _fakeTranscriptTimer?.cancel();
    _fakeTranscriptTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _transcriptCtrl.add('Konuşma kesiti $counter: danışan-kısmi metin...');
      counter += 1;
      if (counter > 10) {
        // otomatik durdur
        _stopFakeTranscript();
      }
    });
  }

  void _stopFakeTranscript() {
    _fakeTranscriptTimer?.cancel();
    _fakeTranscriptTimer = null;
  }
}


