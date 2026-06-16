import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Shared device" / kiosk-mode toggle (Sprint 27 F-009).
///
/// When enabled, the patient portal:
///   - shortens its idle-timeout window (see [AutoLogoutController]),
///   - asks the service worker to purge caches on every logout,
///   - hides the "remember me" affordance.
///
/// Persisted with [SharedPreferences] using the same swappable
/// factory pattern as [AppearancePreferences] so widget tests can
/// inject an in-memory backend.
class SharedDeviceService extends ChangeNotifier {
  SharedDeviceService._({Future<SharedPreferences> Function()? prefs})
    : _prefsFactory = prefs;

  static SharedDeviceService instance = SharedDeviceService._();

  @visibleForTesting
  static void setTestInstance(Future<SharedPreferences> Function() prefs) {
    instance = SharedDeviceService._(prefs: prefs);
  }

  @visibleForTesting
  static void resetTestInstance() {
    instance = SharedDeviceService._();
  }

  final Future<SharedPreferences> Function()? _prefsFactory;

  static const _key = 'security.shared_device';

  bool _isShared = false;
  bool _loaded = false;
  bool get isShared => _isShared;
  bool get isLoaded => _loaded;

  Future<SharedPreferences> _prefs() =>
      _prefsFactory?.call() ?? SharedPreferences.getInstance();

  Future<void> load() async {
    final prefs = await _prefs();
    _isShared = prefs.getBool(_key) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setShared(bool value) async {
    if (_isShared == value && _loaded) return;
    final prefs = await _prefs();
    await prefs.setBool(_key, value);
    _isShared = value;
    _loaded = true;
    notifyListeners();
  }
}
