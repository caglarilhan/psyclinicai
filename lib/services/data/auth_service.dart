import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../utils/portal_cache_purge.dart';
import '../auth/sign_out_scrubbers.dart';
import 'firestore_schema.dart';
import 'telemetry_service.dart';

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
    } catch (e, st) {
      // bootstrap() only calls this once real (non-placeholder) config is
      // present, so an exception here is a genuine failure, not demo mode —
      // report it. We still degrade to offline rather than crash.
      await TelemetryService.instance.captureError(e, st, hint: 'auth_init');
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
    // H-8 fix (audit 2026-06-21): wipe every in-memory PHI scratchpad
    // BEFORE we drop the auth handle so the next user cannot land on
    // a screen that re-reads stale state (live transcript, draft SOAP).
    // Scrubbers are registered by their owning services and run in
    // order; each one catches its own errors so a misbehaving cleaner
    // can never block sign-out.
    await SignOutScrubbers.runAll();

    await _auth.signOut();
    _user = null;
    _profile = null;
    // Sprint 27 / F-009 — ask the service worker (web) to drop every
    // Cache + broadcast logout to sibling tabs. No-op on mobile.
    await purgePortalCaches();
    notifyListeners();
  }

  Future<ClinicianProfile?> _loadProfile(String userId) async {
    try {
      final doc = await _db
          .doc(FirestoreSchema.clinicianPath(userId, userId))
          .get();
      if (!doc.exists) return null;
      final d = doc.data()!;
      final expiryRaw = d['licenseExpiry'] as String?;
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
        specialty: d['specialty'] as String? ?? '',
        licenseNumber: d['licenseNumber'] as String? ?? '',
        licenseExpiry: expiryRaw == null ? null : DateTime.tryParse(expiryRaw),
      );
    } catch (e, st) {
      // A null profile means clinicId is unavailable and downstream Firestore
      // calls will fail far from here — make the root cause observable.
      await TelemetryService.instance.captureError(e, st, hint: 'load_profile');
      return null;
    }
  }

  /// Persists the editable subset of the current clinician's profile and
  /// refreshes the in-memory snapshot so listeners pick up the change.
  /// Identity fields ([ClinicianProfile.userId], `clinicId`, `email`,
  /// `role`) are immutable from this entry point.
  Future<AuthResult> updateProfile({
    String? fullName,
    String? credentials,
    String? npi,
    String? taxId,
    String? specialty,
    String? licenseNumber,
    DateTime? licenseExpiry,
    bool clearLicenseExpiry = false,
  }) async {
    final current = _profile;
    if (current == null) {
      return AuthResult.failure('No profile loaded — please sign in again.');
    }
    try {
      final path = FirestoreSchema.clinicianPath(
        current.userId,
        current.userId,
      );
      await _db.doc(path).set({
        if (fullName != null) FirestoreSchema.fieldFullName: fullName,
        if (credentials != null) FirestoreSchema.fieldCredentials: credentials,
        if (npi != null) FirestoreSchema.fieldNpi: npi,
        if (taxId != null) FirestoreSchema.fieldTaxId: taxId,
        if (specialty != null) 'specialty': specialty,
        if (licenseNumber != null) 'licenseNumber': licenseNumber,
        if (clearLicenseExpiry)
          'licenseExpiry': null
        else if (licenseExpiry != null)
          'licenseExpiry': licenseExpiry.toUtc().toIso8601String(),
        FirestoreSchema.fieldUpdatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _profile = current.copyWith(
        fullName: fullName,
        credentials: credentials,
        npi: npi,
        taxId: taxId,
        specialty: specialty,
        licenseNumber: licenseNumber,
        licenseExpiry: clearLicenseExpiry ? null : licenseExpiry,
      );
      notifyListeners();
      return AuthResult.success();
    } catch (e, st) {
      await TelemetryService.instance.captureError(
        e,
        st,
        hint: 'update_profile',
      );
      return AuthResult.failure('Could not save profile: $e');
    }
  }

  // user-not-found and wrong-password return the SAME message to avoid account
  // enumeration (OWASP) — never confirm whether an email is registered.
  String _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
    'user-not-found' => 'Invalid email or password.',
    'wrong-password' => 'Invalid email or password.',
    'invalid-credential' => 'Invalid email or password.',
    'email-already-in-use' => 'That email is already registered.',
    'weak-password' => 'Password too weak (min 8 characters).',
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
    this.specialty = '',
    this.licenseNumber = '',
    this.licenseExpiry,
  });

  final String userId;
  final String clinicId;
  final String email;
  final String fullName;
  final ClinicianRole role;
  final String credentials;
  final String npi;
  final String taxId;

  /// Clinician-described specialty / modality (e.g. "CBT, trauma-focused").
  final String specialty;

  /// State / national license identifier — required for many superbill
  /// fields and for telehealth jurisdiction checks.
  final String licenseNumber;

  /// License expiry. Surfaced as a warning on the dashboard once it falls
  /// inside the next 60 days. Null = not on file yet.
  final DateTime? licenseExpiry;

  /// True when the license has lapsed or expires within 60 days. Used by
  /// the dashboard to render a warning.
  bool get licenseExpiringSoon {
    final exp = licenseExpiry;
    if (exp == null) return false;
    final days = exp.difference(DateTime.now()).inDays;
    return days <= 60;
  }

  ClinicianProfile copyWith({
    String? fullName,
    String? credentials,
    String? npi,
    String? taxId,
    String? specialty,
    String? licenseNumber,
    DateTime? licenseExpiry,
  }) => ClinicianProfile(
    userId: userId,
    clinicId: clinicId,
    email: email,
    fullName: fullName ?? this.fullName,
    role: role,
    credentials: credentials ?? this.credentials,
    npi: npi ?? this.npi,
    taxId: taxId ?? this.taxId,
    specialty: specialty ?? this.specialty,
    licenseNumber: licenseNumber ?? this.licenseNumber,
    licenseExpiry: licenseExpiry ?? this.licenseExpiry,
  );
}
