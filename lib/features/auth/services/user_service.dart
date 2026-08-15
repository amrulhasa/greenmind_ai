import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>>
      get _usersCollection => _firestore.collection('users');

  /// Creates a Firestore profile for a newly registered user.
  /// Every normal registration gets the "user" role.
  static Future<void> createUserProfile({
    required User user,
    String? name,
  }) async {
    await _usersCollection.doc(user.uid).set({
      'email': user.email,
      'name': name?.trim() ?? '',
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Gets the currently logged-in user's role.
  static Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _usersCollection.doc(user.uid).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    return data?['role'] as String?;
  }

  /// Checks whether the current user is an admin.
  static Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();

    return role == 'admin';
  }

  /// Gets the current user's complete Firestore profile.
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await _usersCollection.doc(user.uid).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}