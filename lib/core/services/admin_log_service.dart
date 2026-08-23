import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminLogService {
  AdminLogService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static Future<void> createLog({
    required String action,
    required String description,
    String category = 'general',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final User? user = _auth.currentUser;

      await _firestore
          .collection('admin_logs')
          .add({
        'action': action,
        'description': description,
        'category': category,

        'adminEmail':
            user?.email ?? 'Unknown administrator',

        'adminUid':
            user?.uid,

        'createdAt':
            FieldValue.serverTimestamp(),

        'metadata': ?metadata,
      });
    } catch (error) {
      // Logging failure should not crash the application.
      developer.log(
        'ADMIN LOG ERROR: $error',
        name: 'AdminLogService',
      );
    }
  }
}