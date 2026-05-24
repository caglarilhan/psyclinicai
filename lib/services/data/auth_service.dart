import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_schema.dart';

/// Real Firebase Auth wrapper. Replaces the legacy mock that only accepted
/// `admin/admin`. Solo-practice tenant model: 1 user = 1 clinic.
class FirebaseAuthService extends ChangeNotifier {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  // Lazy — `FirebaseAuth.instance` throws if `Firebase.initializeApp` has
  // not run (placeholder firebase_options.dart / demo mode). Reading these
  // getters before bootstrap surfaces a controlled error the caller can
  // catch instead of blowing up at field-init time.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool _initialized = false;
  StreamSubscription<User?>? _sub;
  User? _user;
  ClinicianProfile? _profile;

  User? get currentUser => _user;
  ClinicianProfile? get profile => _profile;
  bool get isAuthenticated => _user != null;
  bool get isReady => _initialized;

  Stream<User?> get authStateChanges =>
      _initialized ? _auth.authStateChanges() : const Stream.empty();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _sub?.cancel();
      _sub = _auth.authStateChanges().listen((u) async {
        _user = u;
        _profile = u != null ? await _loadProfile(u.uid) : null;
        notifyListeners();
      });
      _user = _auth.currentUser;
      if (_user != null) {
        _profile = await _loadProfile(_user!.uid);
      }
      _initialized = true;
    } catch (_) {
      // Firebase not configured — stay in offline / demo mode.
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      _profile = _user != null ? await _loadProfile(_user!.uid) : null;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('Unexpected error: $e');
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required ClinicianRole role,
    String credentials = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = cred.user;
      if (_user == null) {
        return AuthResult.failure('Signup succeeded but user is null.');
      }
      await _user!.updateDisplayName(fullName);

      final clinicId = _user!.uid;
      final clinicRef = _db.collection(FirestoreSchema.clinics).doc(clinicId);
      final now = FieldValue.serverTimestamp();

      await clinicRef.set({
        FirestoreSchema.fieldCreatedAt: now,
        FirestoreSchema.fieldUpdatedAt: now,
        'ownerId': _user!.uid,
        'name': "$fullName's Practice",
      });

      await clinicRef
          .collection(FirestoreSchema.clinicians)
          .doc(_user!.uid)
          .set({
        FirestoreSchema.fieldEmail: email.trim(),
        FirestoreSchema.fieldFullName: fullName,
        FirestoreSchema.fieldRole: role.id,
        FirestoreSchema.fieldCredentials: credentials,
        FirestoreSchema.fieldCreatedAt: now,
        FirestoreSchema.fieldUpdatedAt: now,
      });

      _profile = ClinicianProfile(
        userId: _user!.uid,
        clinicId: clinicId,
        email: email.trim(),
        fullName: fullName,
        role: role,
        credentials: credentials,
      );
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('Unexpected error: $e');
    }
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure('Unexpected error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<ClinicianProfile?> _loadProfile(String userId) async {
    try {
      final doc = await _db
          .doc(FirestoreSchema.clinicianPath(userId, userId))
          .get();
      if (!doc.exists) return null;
      final d = doc.data()!;
      return ClinicianProfile(
        userId: userId,
        clinicId: userId,
        email: d[FirestoreSchema.fieldEmail] as String? ?? '',
        fullName: d[FirestoreSchema.fieldFullName] as String? ?? '',
        role: ClinicianRole.values.firstWhere(
          (r) => r.id == (d[FirestoreSchema.fieldRole] as String? ?? ''),
          orElse: () => ClinicianRole.therapist,
        ),
        credentials: d[FirestoreSchema.fieldCredentials] as String? ?? '',
        npi: d[FirestoreSchema.fieldNpi] as String? ?? '',
        taxId: d[FirestoreSchema.fieldTaxId] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
        'user-not-found' => 'No account found with that email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Invalid email or password.',
        'email-already-in-use' => 'That email is already registered.',
        'weak-password' => 'Password too weak (min 6 characters).',
        'invalid-email' => 'That email is not valid.',
        'network-request-failed' => 'Network error. Check your connection.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        _ => 'Authentication failed: ${e.message ?? e.code}',
      };

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class AuthResult {
  AuthResult._(this.success, this.error);
  factory AuthResult.success() => AuthResult._(true, null);
  factory AuthResult.failure(String error) => AuthResult._(false, error);

  final bool success;
  final String? error;
}

class ClinicianProfile {
  ClinicianProfile({
    required this.userId,
    required this.clinicId,
    required this.email,
    required this.fullName,
    required this.role,
    this.credentials = '',
    this.npi = '',
    this.taxId = '',
  });

  final String userId;
  final String clinicId;
  final String email;
  final String fullName;
  final ClinicianRole role;
  final String credentials;
  final String npi;
  final String taxId;
}
