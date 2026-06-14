import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Handles all Firebase Authentication operations for FixGhar
/// Supports phone OTP login and email/password login
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Returns the currently signed-in Firebase user (or null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes — useful for reactive UI updates
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Phone OTP Authentication
  // ---------------------------------------------------------------------------

  /// Step 1: Send OTP to the given phone number
  /// [phoneNumber] must include country code, e.g. '+919876543210'
  /// [onCodeSent] is called when the OTP SMS is dispatched (with verificationId)
  /// [onError] is called on failure with an error message
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Called when SMS is successfully sent
        codeSent: (String verificationId, int? resendToken) {
          print("OTP SENT SUCCESS");
          onCodeSent(verificationId);
        },

        // Called if the OTP is auto-detected by Android
        verificationCompleted: (PhoneAuthCredential credential) {
          onAutoVerified?.call(credential);
        },

        // Called if verification fails
        verificationFailed: (FirebaseAuthException e) {
          String message;
          switch (e.code) {
            case 'invalid-phone-number':
              message = 'Invalid phone number format.';
              break;
            case 'too-many-requests':
              message = 'Too many requests. Please try again later.';
              break;
            default:
              message = e.message ?? 'OTP sending failed. Please try again.';
          }
          onError(message);
        },

        // Called when the auto-retrieval timeout expires
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout — user must enter OTP manually
        },
      );
    } catch (e) {
      onError('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Step 2: Verify OTP and sign the user in
  /// Returns [UserModel] on success, throws [FirebaseAuthException] on failure
  Future<UserModel> verifyOtpAndLogin({
    required String verificationId,
    required String smsCode,
  }) async {
    // Create credential from the verificationId + user-entered OTP
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Sign in with the credential
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    // Determine if this is a new user or returning user
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      // Create a new Firestore document for the user
      final newUser = UserModel(
        uid: user.uid,
        fullName: user.displayName ?? 'User',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ?? '',
        role: 'customer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
      return newUser;
    } else {
      // Fetch existing user data from Firestore
      return await _getUserFromFirestore(user.uid);
    }
  }

  // ---------------------------------------------------------------------------
  // Email / Password Authentication
  // ---------------------------------------------------------------------------

  /// Registers a new user with email and password
  Future<UserModel> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    // Create Firebase Auth account
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user!;

    // Update display name in Firebase Auth
    await user.updateDisplayName(fullName);

    // Save user data to Firestore
    final newUser = UserModel(
      uid: user.uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      role: 'customer',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
    return newUser;
  }

  /// Signs in an existing user with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await _getUserFromFirestore(userCredential.user!.uid);
  }

  /// Sends a password reset email to the given address
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs the current user out of Firebase Auth
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  /// Fetches the UserModel from Firestore for the given [uid]
  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User document not found in Firestore for uid: $uid');
    }
    return UserModel.fromFirestore(doc);
  }

  /// Updates the user's profile data in Firestore
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _firestore.collection('users').doc(uid).update(data);
  }

  /// Returns the current user's Firestore document as a stream (live updates)
  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
}
