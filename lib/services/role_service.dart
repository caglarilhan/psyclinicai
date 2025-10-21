import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleService extends ChangeNotifier {
  static const String _roleKey = 'current_role';

  String _currentRole = 'Psikiyatrist';

  String get currentRole => _currentRole;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRole = prefs.getString(_roleKey) ?? _currentRole;
    notifyListeners();
  }

  Future<void> setRole(String role) async {
    _currentRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    notifyListeners();
  }

  // Eksik metod - getCurrentUser
  Map<String, dynamic> getCurrentUser() {
    return {
      'id': 'current_user',
      'name': 'Mevcut Kullanıcı',
      'role': _currentRole,
      'email': 'user@psyclinicai.com',
    };
  }
}


