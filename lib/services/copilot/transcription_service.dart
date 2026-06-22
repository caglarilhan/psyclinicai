import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../auth/sign_out_scrubbers.dart';

/// On-device live transcription via `speech_to_text`.
///
/// Uses native APIs (iOS Speech framework, Android SpeechRecognizer).
/// **M-10 fix (audit 2026-06-21):** the Web Speech API in Chromium
/// streams audio to Google's cloud servers before returning the
/// transcript — that is incompatible with our "no audio leaves the
/// device" HIPAA & GDPR promise. On the web build the service refuses
/// to initialise: `available` stays false and the UI hides the live
/// transcription surface. Mobile / desktop targets continue to use the
/// native engine where audio truly never leaves the device.
class TranscriptionService extends ChangeNotifier {
  TranscriptionService() {
    // H-8 fix (audit 2026-06-21): in-memory transcript is PHI; on
    // sign-out it MUST be wiped before the next clinician can land.
    // Registry-based wire so FirebaseAuthService.signOut triggers
    // every PHI-bearing service's reset() automatically — no UI
    // plumbing required.
    _unregisterScrubber = SignOutScrubbers.register(() async {
      await cancel();
      reset();
    });
  }

  void Function()? _unregisterScrubber;

  final stt.SpeechToText _engine = stt.SpeechToText();
  final StreamController<TranscriptUpdate> _controller =
      StreamController<TranscriptUpdate>.broadcast();

  Stream<TranscriptUpdate> get transcriptStream => _controller.stream;

  bool _available = false;
  bool _listening = false;
  String _fullTranscript = '';
  String _currentPartial = '';
  String? _disabledReason;

  bool get available => _available;
  bool get isListening => _listening;
  String get fullTranscript => _fullTranscript;
  String get currentPartial => _currentPartial;

  /// Non-null when [initialize] refused to bring the engine up
  /// (PHI policy on web, missing platform support, etc.). UI uses this
  /// to render the right "transcription unavailable" copy.
  String? get disabledReason => _disabledReason;

  Future<bool> initialize() async {
    if (kIsWeb) {
      _available = false;
      _disabledReason =
          'Live transcription is disabled on the web build to keep '
          'audio off third-party clouds (HIPAA / GDPR). Use the iOS / '
          'Android app for ambient note dictation.';
      notifyListeners();
      return false;
    }
    try {
      _available = await _engine.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      _disabledReason = _available ? null : 'platform_unavailable';
    } catch (_) {
      _available = false;
      _disabledReason = 'platform_unavailable';
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
        _fullTranscript = _fullTranscript.isEmpty
            ? text
            : '$_fullTranscript $text';
      }
      _currentPartial = '';
      _controller.add(
        TranscriptUpdate(
          delta: text,
          fullTranscript: _fullTranscript,
          isFinal: true,
        ),
      );
    } else {
      _currentPartial = text;
      _controller.add(
        TranscriptUpdate(
          delta: text,
          fullTranscript: _fullTranscript,
          partial: text,
          isFinal: false,
        ),
      );
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
    _unregisterScrubber?.call();
    _unregisterScrubber = null;
    unawaited(_controller.close());
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
