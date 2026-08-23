import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementReadService {
  AnnouncementReadService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER READ COLLECTION
  // ============================================================

  static CollectionReference<Map<String, dynamic>>?
      _readCollection() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('announcementReads');
  }

  // ============================================================
  // READ ANNOUNCEMENT STREAM
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      readStream() {
    final collection = _readCollection();

    if (collection == null) {
      return const Stream<
          QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return collection.snapshots();
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  static Future<void> markAsRead(
    String announcementId,
  ) async {
    final collection = _readCollection();

    if (collection == null) {
      return;
    }

    await collection
        .doc(announcementId)
        .set(
      {
        'readAt': FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  static Future<void> markAllAsRead(
    List<String> announcementIds,
  ) async {
    final collection = _readCollection();

    if (collection == null ||
        announcementIds.isEmpty) {
      return;
    }

    final WriteBatch batch =
        _firestore.batch();

    for (final String id in announcementIds) {
      batch.set(
        collection.doc(id),
        {
          'readAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    }

    await batch.commit();
  }

  // ============================================================
  // DELETE READ RECORD
  // ============================================================

  static Future<void> clearReadStatus(
    String announcementId,
  ) async {
    final collection = _readCollection();

    if (collection == null) {
      return;
    }

    await collection
        .doc(announcementId)
        .delete();
  }
}