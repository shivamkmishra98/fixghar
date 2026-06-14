import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Manages authentication state for the entire FixGhar app
/// Uses ChangeNotifier so all listening widgets rebuild on state change
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId; // Stored during OTP flow

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  String? get verificationId => _verificationId;

  // ---------------------------------------------------------------------------
  // Constructor — listen to Firebase auth state
  // ---------------------------------------------------------------------------

  AuthProvider() {
    // Whenever Firebase auth state changes, update our local user state
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Called automatically when the Firebase auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User signed out
      _currentUser = null;
      notifyListeners();
      return;
    }

    // User is signed in — load full profile from Firestore
    try {
      _setLoading(true);
      // Listen to live user updates from Firestore
      _authService.userStream(firebaseUser.uid).listen((userModel) {
        _currentUser = userModel;
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Phone OTP Login
  // ---------------------------------------------------------------------------

  /// Sends an OTP to the given phone number
  /// [phoneNumber] should include country code: '+91XXXXXXXXXX'
  Future<void> sendOtp({
    required String phoneNumber,
    required VoidCallback onCodeSent,
    required void Function(String) onError,
  }) async {
    _setLoading(true);
    _clearError();

    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        _setLoading(false);
        onCodeSent();
      },
      onError: (error) {
        _setLoading(false);
        _setError(error);
        onError(error);
      },
    );
  }

  /// Verifies the OTP entered by the user and logs them in
  Future<bool> verifyOtp({
    required String smsCode,
    required void Function(String) onError,
  }) async {
    if (_verificationId == null) {
      onError('Verification ID missing. Please request OTP again.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authService.verifyOtpAndLogin(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthError(e.code);
      _setError(message);
      onError(message);
      return false;
    } catch (e) {
      _setError(e.toString());
      onError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Email / Password Authentication
  // ---------------------------------------------------------------------------

  /// Registers a new customer account with email and password
  Future<bool> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required void Function(String) onError,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authService.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthError(e.code);
      _setError(message);
      onError(message);
      return false;
    } catch (e) {
      _setError(e.toString());
      onError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs in an existing user with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
    required void Function(String) onError,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthError(e.code);
      _setError(message);
      onError(message);
      return false;
    } catch (e) {
      _setError(e.toString());
      onError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Profile Update
  // ---------------------------------------------------------------------------

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    try {
      _setLoading(true);
      await _authService.updateUserProfile(uid: _currentUser!.uid, data: data);
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Maps Firebase Auth error codes to human-readable messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
