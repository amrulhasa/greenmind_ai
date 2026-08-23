import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>
      get _usersCollection {
    return _firestore.collection('users');
  }

  // ============================================================
  // CREATE USER PROFILE
  // ============================================================

  static Future<void> createUserProfile({
    required User user,
    String? name,
  }) async {
    final trimmedName =
        name?.trim() ?? '';

    await _usersCollection
        .doc(user.uid)
        .set(
      {
        'email': user.email ?? '',
        'name': trimmedName,
        'location': '',
        'phone': '',
        'bio': 'GreenMind AI plant enthusiast',
        'role': 'user',
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // ============================================================
  // UPDATE USER PROFILE
  // ============================================================

  static Future<void> updateUserProfile({
    required String name,
    required String location,
    required String phone,
    required String bio,
  }) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found.',
      );
    }

    await _usersCollection
        .doc(user.uid)
        .set(
      {
        'email': user.email ?? '',
        'name': name.trim(),
        'location': location.trim(),
        'phone': phone.trim(),
        'bio': bio.trim(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // ============================================================
  // GET CURRENT USER ROLE
  // ============================================================

  static Future<String?>
      getCurrentUserRole() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _usersCollection
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    final data =
        document.data();

    final role =
        data?['role'];

    if (role is String) {
      return role.trim();
    }

    return null;
  }

  // ============================================================
  // IS ADMIN
  // ============================================================

  static Future<bool> isAdmin() async {
    final role =
        await getCurrentUserRole();

    return role?.toLowerCase() ==
        'admin';
  }

  // ============================================================
  // GET CURRENT USER DATA
  // ============================================================

  static Future<
          Map<String, dynamic>?>
      getCurrentUserData() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _usersCollection
            .doc(user.uid)
            .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  // ============================================================
  // ENSURE PROFILE EXISTS
  // ============================================================

  static Future<void>
      ensureUserProfile() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      return;
    }

    final document =
        await _usersCollection
            .doc(user.uid)
            .get();

    if (!document.exists) {
      await createUserProfile(
        user: user,
        name: user.displayName,
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await _auth.signOut();
  }
}