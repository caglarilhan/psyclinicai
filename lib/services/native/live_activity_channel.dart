import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Wraps the iOS `psyclinicai/live_activity` MethodChannel that drives
/// ActivityKit's lock-screen + Dynamic Island session timer.
///
/// PHI never crosses this boundary — pass only sanitized labels.
/// Non-iOS platforms return a [LiveActivityHandle] whose calls are
/// no-ops, so callers don't need a platform guard.
class LiveActivityChannel {
  LiveActivityChannel({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('psyclinicai/live_activity');

  final MethodChannel _channel;

  bool get _supported {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  Future<LiveActivityHandle> start({
    required String sessionTitle,
    required String modality,
    required String clinician,
    Duration elapsed = Duration.zero,
    bool isRecording = false,
    String? nextStepLabel,
  }) async {
    if (!_supported) {
      return const LiveActivityHandle._noop();
    }
    try {
      final id = await _channel.invokeMethod<String>('start', {
        'sessionTitle': sessionTitle,
        'modality': modality,
        'clinician': clinician,
        'elapsedSeconds': elapsed.inSeconds,
        'isRecording': isRecording,
        if (nextStepLabel != null) 'nextStepLabel': nextStepLabel,
      });
      if (id == null || id.isEmpty) {
        return const LiveActivityHandle._noop();
      }
      return LiveActivityHandle._(channel: _channel, activityId: id);
    } on PlatformException catch (e, st) {
      // Surface the failure so misconfigured entitlements / disabled
      // Live Activities don't silently degrade the lock-screen UX.
      // The session screen receives a `notSupported` handle and can
      // show a banner.
      debugPrint('LiveActivity.start failed: ${e.code} ${e.message}\n$st');
      return const LiveActivityHandle._noop();
    }
  }
}

class LiveActivityHandle {
  const LiveActivityHandle._({
    required this.activityId,
    required MethodChannel channel,
  })  : _channel = channel,
        _active = true;

  const LiveActivityHandle._noop()
      : activityId = '',
        _channel = null,
        _active = false;

  final String activityId;
  final MethodChannel? _channel;
  final bool _active;

  bool get isActive => _active;

  Future<void> update({
    Duration? elapsed,
    bool? isRecording,
    String? sessionTitle,
    String? nextStepLabel,
  }) async {
    if (!_active || _channel == null) return;
    await _channel.invokeMethod('update', {
      'activityId': activityId,
      if (elapsed != null) 'elapsedSeconds': elapsed.inSeconds,
      if (isRecording != null) 'isRecording': isRecording,
      if (sessionTitle != null) 'sessionTitle': sessionTitle,
      if (nextStepLabel != null) 'nextStepLabel': nextStepLabel,
    });
  }

  Future<void> end() async {
    if (!_active || _channel == null) return;
    await _channel.invokeMethod('end', {'activityId': activityId});
  }
}
