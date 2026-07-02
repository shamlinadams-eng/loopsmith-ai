import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Authentication service backed by Firebase Auth + Firestore user profiles.
/// On Flutter web (preview) all Firebase calls are skipped — the service runs
/// in demo mode so the UI renders without native channel errors.
class AuthService extends ChangeNotifier {
  // Lazily access Firebase instances only on native platforms.
  // GoogleSignIn must NEVER be instantiated on web — the google_sign_in_web
  // plugin calls initWithParams(clientId: null) at construction time and
  // crashes the preview before any kIsWeb guard in the constructor can run.
  FirebaseAuth? get _auth => kIsWeb ? null : FirebaseAuth.instance;
  FirebaseFirestore? get _db => kIsWeb ? null : FirebaseFirestore.instance;
  GoogleSignIn? get _googleSignIn => kIsWeb ? null : GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _currentUser != null;
  String? get error => _error;

  AuthService() {
    if (kIsWeb) {
      // Web preview: no Firebase — stay signed-out so the UI flows normally.
      return;
    }
    // Listen to Firebase auth state changes so sign-in persists across restarts.
    _authSubscription = _auth!.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      _currentUser = await _buildUserModel(firebaseUser);
    }
    notifyListeners();
  }

  /// Fetch Firestore profile and merge with Firebase Auth user.
  Future<UserModel> _buildUserModel(User firebaseUser) async {
    Map<String, dynamic>? firestoreData;
    try {
      final doc = await _db!.collection('users').doc(firebaseUser.uid).get();
      firestoreData = doc.data();
    } catch (_) {
      // Firestore unreachable — use auth-only data.
    }
    return UserModel.fromFirebase(firebaseUser, firestoreData: firestoreData);
  }

  /// Write / merge user profile into Firestore after sign-in.
  Future<void> _upsertFirestoreProfile(UserModel user) async {
    if (_db == null) return;
    await _db!
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------
  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      _setError('Sign-in is available on the iOS and Android app.');
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      final googleUser = await _googleSignIn?.signIn();
      if (googleUser == null) {
        // User cancelled the picker.
        _setLoading(false);
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth!.signInWithCredential(credential);
      final user = UserModel.fromFirebase(userCredential.user!);
      await _upsertFirestoreProfile(user);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Google sign-in failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Apple Sign-In
  // NOTE: Requires Sign in with Apple capability in Xcode + Firebase Console.
  // On Android this will show a web-based Apple sign-in flow automatically.
  // ---------------------------------------------------------------------------
  Future<bool> signInWithApple() async {
    if (kIsWeb) {
      _setError('Sign-in is available on the iOS and Android app.');
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final userCredential = await _auth!.signInWithProvider(appleProvider);
      final user = UserModel.fromFirebase(userCredential.user!);
      await _upsertFirestoreProfile(user);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Apple sign-in failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------
  Future<bool> signInWithEmail(String email, String password) async {
    if (kIsWeb) {
      _setError('Sign-in is available on the iOS and Android app.');
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = await _buildUserModel(userCredential.user!);
      await _upsertFirestoreProfile(user);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Sign-in failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createAccountWithEmail(
      String email, String password, String displayName) async {
    if (kIsWeb) {
      _setError('Account creation is available on the iOS and Android app.');
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      if (displayName.trim().isEmpty) throw Exception('Please enter your name.');
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await userCredential.user!.updateDisplayName(displayName.trim());
      // Reload so displayName is reflected immediately.
      await userCredential.user!.reload();
      final refreshed = _auth!.currentUser!;
      final user = UserModel.fromFirebase(refreshed);
      await _upsertFirestoreProfile(user);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    if (kIsWeb) {
      _setError('Password reset is available on the iOS and Android app.');
      return false;
    }
    _setLoading(true);
    _clearError();
    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
      await _auth!.signOut();
    }
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Premium toggle — called server-side via Stripe webhook or manually
  // ---------------------------------------------------------------------------
  Future<void> setPremium(bool value) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(isPremium: value);
    notifyListeners();
    if (!kIsWeb) {
      await _db!.collection('users').doc(_currentUser!.uid).update({
        'isPremium': value,
      });
    }
  }

  Future<void> incrementDailyGenerations() async {
    if (_currentUser == null) return;
    final newCount = _currentUser!.dailyGenerationsUsed + 1;
    _currentUser = _currentUser!.copyWith(dailyGenerationsUsed: newCount);
    notifyListeners();
    if (!kIsWeb) {
      await _db!.collection('users').doc(_currentUser!.uid).update({
        'dailyGenerationsUsed': newCount,
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'user-cancelled':
      case 'canceled':
        return 'Sign-in was cancelled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
