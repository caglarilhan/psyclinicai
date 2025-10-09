import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _userKey = 'auth_user';
  static const String _orgKey = 'auth_org';
  TwoFactorChallenge? _pendingChallenge;

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  Future<User?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<Organization> ensureOrganization() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_orgKey);
    if (raw != null) return Organization.fromJson(jsonDecode(raw));
    final org = Organization(id: 'org_demo', name: 'Demo Klinik');
    await prefs.setString(_orgKey, jsonEncode(org.toJson()));
    return org;
  }

  Future<TwoFactorChallenge> loginWithPassword({required String email, required String password}) async {
    // Demo doğrulama
    final org = await ensureOrganization();
    final user = User(
      id: 'user_demo',
      email: email,
      fullName: 'Dr. Örnek',
      roles: [UserRole.therapist],
      organizationId: org.id,
    );

    // 2FA kodu üret
    final code = _generateCode();
    final challenge = TwoFactorChallenge(
      userId: user.id,
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    _pendingChallenge = challenge;

    // Normalde: kodu e-posta/SMS ile gönder
    return challenge;
  }

  Future<bool> verify2FA(String code) async {
    if (_pendingChallenge == null) return false;
    final ch = _pendingChallenge!;
    if (DateTime.now().isAfter(ch.expiresAt)) return false;
    if (ch.code != code) return false;

    // Başarılıysa user'ı kaydet
    final prefs = await SharedPreferences.getInstance();
    final org = await ensureOrganization();
    final user = User(
      id: ch.userId,
      email: 'demo@psyclinic.ai',
      fullName: 'Dr. Örnek',
      roles: [UserRole.therapist],
      organizationId: org.id,
    );
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    _pendingChallenge = null;
    return true;
  }

  String _generateCode() {
    final r = Random.secure();
    return List.generate(6, (_) => r.nextInt(10)).join();
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;

  Future<bool> isAuthenticated() async {
    // TODO: Firebase Auth entegrasyonu
    await Future.delayed(const Duration(milliseconds: 500)); // Simülasyon
    return _isAuthenticated;
  }

  Future<bool> signIn(String email, String password) async {
    // TODO: Firebase Auth sign in
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon

    if (email == 'admin@psyclinic.ai' && password == '123456') {
      _isAuthenticated = true;
      return true;
    }

    return false;
  }

  Future<void> signOut() async {
    // TODO: Firebase Auth sign out
    await Future.delayed(const Duration(milliseconds: 500)); // Simülasyon
    _isAuthenticated = false;
  }

  String? getCurrentUser() {
    // TODO: Firebase Auth current user
    return _isAuthenticated ? 'admin@psyclinic.ai' : null;
  }
}
