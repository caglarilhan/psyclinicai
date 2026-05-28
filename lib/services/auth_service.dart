import 'package:flutter/foundation.dart';

// Legacy demo implementation (removed to avoid duplicate class error)

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;

  Future<bool> isAuthenticated() async {
    // TODO: Firebase Auth entegrasyonu
    await Future<void>.delayed(const Duration(milliseconds: 500)); // Simülasyon
    return _isAuthenticated;
  }

  Future<bool> signIn(String email, String password) async {
    // TODO: Firebase Auth sign in
    await Future<void>.delayed(const Duration(seconds: 2)); // Simülasyon

    if (email == 'admin' && password == 'admin') {
      _isAuthenticated = true;
      return true;
    }

    return false;
  }

  Future<void> signOut() async {
    // TODO: Firebase Auth sign out
    await Future<void>.delayed(const Duration(milliseconds: 500)); // Simülasyon
    _isAuthenticated = false;
  }

  String? getCurrentUser() {
    // TODO: Firebase Auth current user
    return _isAuthenticated ? 'admin' : null;
  }

  Future<bool> verify2FA(String code) async {
    // TODO: Firebase Auth 2FA verification
    await Future<void>.delayed(const Duration(seconds: 1)); // Simülasyon
    
    // Demo: Herhangi bir 6 haneli kod kabul edilir
    if (code.length == 6 && RegExp(r'^\d+$').hasMatch(code)) {
      return true;
    }
    
    return false;
  }
}
