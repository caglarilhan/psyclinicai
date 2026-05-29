import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// On-device live transcription via `speech_to_text`.
///
/// Uses native APIs (iOS Speech framework, Android SpeechRecognizer, Web Speech
/// API). No audio leaves the device — HIPAA & GDPR friendly by design.
class TranscriptionService extends ChangeNotifier {
  TranscriptionService();

  final stt.SpeechToText _engine = stt.SpeechToText();
  final StreamController<TranscriptUpdate> _controller =
      StreamController<TranscriptUpdate>.broadcast();

  Stream<TranscriptUpdate> get transcriptStream => _controller.stream;

  bool _available = false;
  bool _listening = false;
  String _fullTranscript = '';
  String _currentPartial = '';

  bool get available => _available;
  bool get isListening => _listening;
  String get fullTranscript => _fullTranscript;
  String get currentPartial => _currentPartial;

  Future<bool> initialize() async {
    try {
      _available = await _engine.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
    } catch (_) {
      _available = false;
    }
    notifyListeners();
    return _available;
  }

  Future<List<String>> supportedLocales() async {
    if (!_available) return const [];
    final locales = await _engine.locales();
    return locales.map((l) => l.localeId).toList(growable: false);
  }

  Future<void> start({String localeId = 'en_US'}) async {
    if (!_available || _listening) return;
    _currentPartial = '';
    await _engine.listen(
      onResult: _onResult,
      localeId: localeId,
      listenFor: const Duration(minutes: 60),
      pauseFor: const Duration(seconds: 30),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );
    _listening = true;
    notifyListeners();
  }

  Future<void> stop() async {
    if (!_listening) return;
    await _engine.stop();
    _listening = false;
    notifyListeners();
  }

  Future<void> cancel() async {
    if (!_listening) return;
    await _engine.cancel();
    _listening = false;
    _currentPartial = '';
    notifyListeners();
  }

  void reset() {
    _fullTranscript = '';
    _currentPartial = '';
    notifyListeners();
  }

  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    if (result.finalResult) {
      if (text.isNotEmpty) {
        _fullTranscript =
            _fullTranscript.isEmpty ? text : '$_fullTranscript $text';
      }
      _currentPartial = '';
      _controller.add(TranscriptUpdate(
        delta: text,
        fullTranscript: _fullTranscript,
        isFinal: true,
      ));
    } else {
      _currentPartial = text;
      _controller.add(TranscriptUpdate(
        delta: text,
        fullTranscript: _fullTranscript,
        partial: text,
        isFinal: false,
      ));
    }
    notifyListeners();
  }

  void _onStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      _listening = false;
      notifyListeners();
    }
  }

  void _onError(dynamic error) {
    _listening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class TranscriptUpdate {
  TranscriptUpdate({
    required this.delta,
    required this.fullTranscript,
    this.partial = '',
    required this.isFinal,
  });

  final String delta;
  final String fullTranscript;
  final String partial;
  final bool isFinal;
}
