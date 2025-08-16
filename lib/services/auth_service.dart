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
