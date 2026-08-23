import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_user.dart';

class AdminAuthService {
  AdminAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser {
    return _auth.currentUser;
  }

  // ============================================================
  // ADMIN LOGIN
  // ============================================================

  Future<AdminUser> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty) {
      throw const AdminAuthException(
        'Please enter your email address.',
      );
    }

    if (password.isEmpty) {
      throw const AdminAuthException(
        'Please enter your password.',
      );
    }

    try {
      // ----------------------------------------------------------
      // FIREBASE AUTHENTICATION
      // ----------------------------------------------------------

      final credential =
          await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AdminAuthException(
          'Authentication failed.',
        );
      }

      // ----------------------------------------------------------
      // CHECK ADMIN DOCUMENT
      // ----------------------------------------------------------

      final adminDocument =
          await _firestore
              .collection('admins')
              .doc(user.uid)
              .get();

      if (!adminDocument.exists) {
        await _auth.signOut();

        throw const AdminAuthException(
          'This account does not have admin access.',
        );
      }

      final admin =
          AdminUser.fromFirestore(
        adminDocument,
      );

      // ----------------------------------------------------------
      // CHECK ROLE
      // ----------------------------------------------------------

      if (!admin.isAdmin) {
        await _auth.signOut();

        throw const AdminAuthException(
          'You are not authorized to access the admin panel.',
        );
      }

      // ----------------------------------------------------------
      // CHECK STATUS
      // ----------------------------------------------------------

      if (!admin.isActive) {
        await _auth.signOut();

        throw const AdminAuthException(
          'This admin account is currently disabled.',
        );
      }

      return admin;
    } on AdminAuthException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw AdminAuthException(
        _authErrorMessage(error),
      );
    } catch (error) {
      throw AdminAuthException(
        'Unable to sign in as administrator.',
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // ADMIN CHECK
  // ============================================================

  Future<AdminUser?> getCurrentAdmin() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _firestore
            .collection('admins')
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    final admin =
        AdminUser.fromFirestore(document);

    if (!admin.isAdmin || !admin.isActive) {
      return null;
    }

    return admin;
  }

  // ============================================================
  // AUTH ERROR
  // ============================================================

  String _authErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return 'Unable to sign in. Please try again.';
    }
  }
}

// ================================================================
// EXCEPTION
// ================================================================

class AdminAuthException implements Exception {
  final String message;

  const AdminAuthException(this.message);

  @override
  String toString() {
    return 'AdminAuthException: $message';
  }
}