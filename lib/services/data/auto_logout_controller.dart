import 'dart:async';

import 'package:flutter/foundation.dart';

import 'shared_device_service.dart';

/// Idle-watchdog that triggers sign-out when the device is in
/// "shared / kiosk" mode and the user has been inactive for
/// [sharedIdleTimeout] (default 5 minutes). On a non-shared device
/// the controller is a no-op — the watchdog only arms when
/// [SharedDeviceService.isShared] is true.
///
/// Activity is recorded by calling [recordActivity] from the
/// Listener/MouseRegion that wraps the portal shell.
///
/// The controller is decoupled from FirebaseAuth so it can be
/// widget-tested with an injected callback.
class AutoLogoutController {
  AutoLogoutController({
    required this.sharedDevice,
    required this.onLogout,
    Duration sharedIdleTimeout = const Duration(minutes: 5),
    Duration tickInterval = const Duration(seconds: 1),
    DateTime Function()? now,
  })  : _sharedIdleTimeout = sharedIdleTimeout,
        _tickInterval = tickInterval,
        _now = now ?? DateTime.now {
    sharedDevice.addListener(_onSharedDeviceChanged);
    _onSharedDeviceChanged();
  }

  final SharedDeviceService sharedDevice;
  final Future<void> Function() onLogout;
  final Duration _sharedIdleTimeout;
  final Duration _tickInterval;
  final DateTime Function() _now;

  Timer? _timer;
  DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0);
  bool _firing = false;

  @visibleForTesting
  Duration remaining() {
    final elapsed = _now().difference(_lastActivity);
    final left = _sharedIdleTimeout - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  void recordActivity() {
    _lastActivity = _now();
  }

  void _onSharedDeviceChanged() {
    if (sharedDevice.isShared) {
      _lastActivity = _now();
      _timer ??= Timer.periodic(_tickInterval, (_) => _tick());
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _tick() {
    if (_firing) return;
    if (!sharedDevice.isShared) return;
    if (_now().difference(_lastActivity) < _sharedIdleTimeout) return;
    _firing = true;
    () async {
      try {
        await onLogout();
      } finally {
        _lastActivity = _now();
        _firing = false;
      }
    }();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    sharedDevice.removeListener(_onSharedDeviceChanged);
  }
}
