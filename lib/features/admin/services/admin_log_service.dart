import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// ADMIN LOG SERVICE PROVIDER
// ============================================================

final adminLogServiceProvider =
    Provider<AdminLogService>(
  (ref) {
    return AdminLogService();
  },
);

// ============================================================
// ADMIN LOG SERVICE
// ============================================================

class AdminLogService {
  AdminLogService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ============================================================
  // COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _logsCollection {
    return _firestore.collection(
      'admin_logs',
    );
  }

  // ============================================================
  // CREATE LOG
  // ============================================================

  Future<void> createLog({
    required String action,
    required String category,
    required String description,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) async {
    final User? user =
        _auth.currentUser;

    final Map<String, dynamic>
        logData =
        <String, dynamic>{
      'action': action,

      'category': category,

      'description': description,

      'targetType': ?targetType,

      'targetId': ?targetId,

      'metadata':
          metadata ??
              <String, dynamic>{},

      'adminUid':
          user?.uid,

      'adminEmail':
          user?.email,

      'createdAt':
          FieldValue.serverTimestamp(),
    };

    await _logsCollection.add(
      logData,
    );
  }

  // ============================================================
  // WATCH LOGS
  // ============================================================

  Stream<
      QuerySnapshot<
          Map<String, dynamic>>> watchLogs({
    int limit = 100,
  }) {
    return _logsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots();
  }

  // ============================================================
  // DELETE LOG
  // ============================================================

  Future<void> deleteLog(
    String logId,
  ) async {
    await _logsCollection
        .doc(logId)
        .delete();
  }

  // ============================================================
  // CLEAR LOGS
  // ============================================================

  Future<void> clearAllLogs() async {
    while (true) {
      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await _logsCollection
              .limit(500)
              .get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final WriteBatch batch =
          _firestore.batch();

      for (final QueryDocumentSnapshot<
              Map<String, dynamic>>
          document
          in snapshot.docs) {
        batch.delete(
          document.reference,
        );
      }

      await batch.commit();

      if (snapshot.docs.length < 500) {
        break;
      }
    }
  }
}