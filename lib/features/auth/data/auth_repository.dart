import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Friendly auth errors. Maps Firebase error codes to messages a user
/// can understand, hiding internal details.
class AuthFailure implements Exception {
  final String message;
  final String? code;
  AuthFailure(this.message, {this.code});

  @override
  String toString() => message;

  factory AuthFailure.fromFirebase(FirebaseAuthException e) {
    final code = e.code;
    String message;
    switch (code) {
      case 'invalid-email':
        message = 'That email address looks invalid.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        message = 'Email or password is incorrect.';
        break;
      case 'email-already-in-use':
        message = 'An account with this email already exists.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Use at least 6 characters.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Check your connection and try again.';
        break;
      case 'account-exists-with-different-credential':
        message =
            'An account exists with this email but a different sign-in method.';
        break;
      case 'requires-recent-login':
        message = 'Please sign in again to continue.';
        break;
      default:
        message = e.message ?? 'Authentication failed. Please try again.';
    }
    return AuthFailure(message, code: code);
  }
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  static const _guestModeKey = 'auth_guest_mode';

  /// Stream of auth state changes (signed in / signed out).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Whether the user has explicitly chosen "continue as guest". Persisted so
  /// we don't show the login gate on every cold start.
  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }

  Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, value);
  }

  // ---------------- Email / password ----------------

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await setGuestMode(false);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      // Fire and forget — verification is "soft" (we don't gate access on it).
      try {
        await cred.user?.sendEmailVerification();
      } catch (_) {}
      await setGuestMode(false);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.emailVerified) return;
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  // ---------------- Google ----------------

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Ensure no stale session.
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure('Google sign-in cancelled.', code: 'cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await setGuestMode(false);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure('Google sign-in failed: $e');
    }
  }

  // ---------------- Apple ----------------

  /// Whether Sign in with Apple should be offered on this platform.
  /// iOS only — Apple's guidelines require it on iOS when other social
  /// providers are offered, and don't require it on Android.
  bool get isAppleSignInAvailable => !kIsWeb && Platform.isIOS;

  Future<UserCredential> signInWithApple() async {
    if (!isAppleSignInAvailable) {
      throw AuthFailure('Sign in with Apple is only available on iOS.');
    }
    try {
      // Apple's flow needs a nonce to bind the credential to this request.
      // We pass the SHA-256 hash to Apple; Firebase verifies the raw value.
      final rawNonce = _generateNonce();
      final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCred = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCred.identityToken,
        rawNonce: rawNonce,
      );

      final userCred = await _auth.signInWithCredential(oauthCredential);

      // Apple only sends name on the FIRST sign-in. Persist it onto the
      // Firebase user immediately so we don't lose it.
      final givenName = appleCred.givenName;
      final familyName = appleCred.familyName;
      if ((givenName != null || familyName != null) &&
          (userCred.user?.displayName == null ||
              userCred.user!.displayName!.isEmpty)) {
        final fullName = [givenName, familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        if (fullName.isNotEmpty) {
          await userCred.user?.updateDisplayName(fullName);
        }
      }

      await setGuestMode(false);
      return userCred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthFailure('Apple sign-in cancelled.', code: 'cancelled');
      }
      throw AuthFailure('Apple sign-in failed: ${e.message}');
    } catch (e) {
      throw AuthFailure('Apple sign-in failed: $e');
    }
  }

  // ---------------- Sign out / delete ----------------

  Future<void> signOut() async {
    // Try Google sign-out too, in case the user used Google. Safe no-op
    // when they didn't.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Deletes the Firebase Auth user. Apple's guidelines require this be
  /// available in-app for any app that supports Sign in with Apple.
  /// Caller is responsible for deleting Firestore data first if needed.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthFailure('Not signed in.');
    }
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  /// Apple may force a re-auth before delete. Re-runs the relevant provider's
  /// sign-in flow for the current user.
  Future<void> reauthenticate() async {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('Not signed in.');
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : null;
    if (providerId == 'apple.com') {
      await signInWithApple();
    } else if (providerId == 'google.com') {
      await signInWithGoogle();
    } else {
      // For password users, the UI must re-prompt for password and call
      // [reauthenticateWithPassword] directly.
      throw AuthFailure(
        'Please sign out and sign back in to continue.',
        code: 'requires-recent-login',
      );
    }
  }

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw AuthFailure('Not signed in.');
    }
    try {
      final cred = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebase(e);
    }
  }

  // Cryptographically random nonce for Apple sign-in.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}
