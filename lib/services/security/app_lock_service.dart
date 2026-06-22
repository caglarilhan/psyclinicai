import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HIPAA §164.312(a)(2)(iii) automatic logoff + biometric/PIN
/// app-lock. Closes the senior-security finding in rapor 12
/// (mobile PHI on a lost device).
///
/// Three states: disabled / armed / locked. The root widget should
/// (a) call [load] at startup, (b) call [recordActivity] on each
/// route change, (c) call [maybeAutoLock] on app resume.
class AppLockService extends ChangeNotifier {
  AppLockService._({
    Future<SharedPreferences> Function()? prefs,
    LocalAuthentication? auth,
    DateTime Function()? clock,
  }) : _prefsFactory = prefs,
       _auth = auth ?? LocalAuthentication(),
       _clock = clock ?? DateTime.now;

  static AppLockService instance = AppLockService._();

  @visibleForTesting
  static void setTestInstance({
    required Future<SharedPreferences> Function() prefs,
    LocalAuthentication? auth,
    DateTime Function()? clock,
  }) {
    instance = AppLockService._(prefs: prefs, auth: auth, clock: clock);
  }

  @visibleForTesting
  static void resetTestInstance() {
    instance = AppLockService._();
  }

  static const _enabledKey = 'app_lock.enabled';
  static const _pinHashKey = 'app_lock.pin_hash';
  static const _idleKey = 'app_lock.idle_timeout_minutes';
  static const _defaultIdleMinutes = 5;

  final Future<SharedPreferences> Function()? _prefsFactory;
  final LocalAuthentication _auth;
  final DateTime Function() _clock;

  bool _enabled = false;
  String? _pinHash;
  int _idleMinutes = _defaultIdleMinutes;

  AppLockState _state = AppLockState.disabled;
  DateTime? _lastActivity;
  bool _loaded = false;

  AppLockState get state => _state;
  bool get enabled => _enabled;
  int get idleMinutes => _idleMinutes;
  bool get hasPin => _pinHash != null;

  Future<SharedPreferences> _prefs() =>
      _prefsFactory?.call() ?? SharedPreferences.getInstance();

  Future<void> load() async {
    if (_loaded) return;
    final p = await _prefs();
    _enabled = p.getBool(_enabledKey) ?? false;
    _pinHash = p.getString(_pinHashKey);
    _idleMinutes = p.getInt(_idleKey) ?? _defaultIdleMinutes;
    _state = _enabled ? AppLockState.locked : AppLockState.disabled;
    _lastActivity = _clock();
    _loaded = true;
    notifyListeners();
  }

  void recordActivity() {
    _lastActivity = _clock();
  }

  bool shouldRelock() {
    if (!_enabled || _state != AppLockState.armed) return false;
    final last = _lastActivity;
    if (last == null) return true;
    return _clock().difference(last) >= Duration(minutes: _idleMinutes);
  }

  bool maybeAutoLock() {
    if (!shouldRelock()) return false;
    _state = AppLockState.locked;
    notifyListeners();
    return true;
  }

  Future<void> enable({required String pin, int? idleMinutes}) async {
    if (pin.length < 4 || pin.length > 8) {
      throw ArgumentError('PIN must be 4–8 digits long.');
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError('PIN must only contain digits.');
    }
    final p = await _prefs();
    _enabled = true;
    _pinHash = sha256.convert(utf8.encode(pin)).toString();
    _idleMinutes = idleMinutes ?? _idleMinutes;
    await p.setBool(_enabledKey, true);
    await p.setString(_pinHashKey, _pinHash!);
    await p.setInt(_idleKey, _idleMinutes);
    _state = AppLockState.armed;
    _lastActivity = _clock();
    notifyListeners();
  }

  Future<void> disable() async {
    final p = await _prefs();
    _enabled = false;
    _pinHash = null;
    await p.remove(_enabledKey);
    await p.remove(_pinHashKey);
    _state = AppLockState.disabled;
    notifyListeners();
  }

  Future<bool> unlockWithBiometrics() async {
    if (!_enabled) return true;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock PsyClinicAI',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (ok) {
        _state = AppLockState.armed;
        _lastActivity = _clock();
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  bool unlockWithPin(String pin) {
    if (!_enabled || _pinHash == null) return true;
    final candidate = sha256.convert(utf8.encode(pin)).toString();
    if (!_constantTimeEq(candidate, _pinHash!)) return false;
    _state = AppLockState.armed;
    _lastActivity = _clock();
    notifyListeners();
    return true;
  }

  static bool _constantTimeEq(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

enum AppLockState { disabled, armed, locked }
