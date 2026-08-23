import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  AnnouncementService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const String _collectionName = 'announcements';

  // ============================================================
  // CREATE ANNOUNCEMENT
  // ============================================================

  static Future<String> createAnnouncement({
    required String title,
    required String message,
    required String type,
    required bool isPublished,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to create an announcement.',
      );
    }

    final String cleanTitle = title.trim();
    final String cleanMessage = message.trim();
    final String cleanType = type.trim().toLowerCase();

    if (cleanTitle.isEmpty) {
      throw Exception(
        'Please enter an announcement title.',
      );
    }

    if (cleanMessage.isEmpty) {
      throw Exception(
        'Please enter an announcement message.',
      );
    }

    if (cleanType.isEmpty) {
      throw Exception(
        'Please select an announcement type.',
      );
    }

    final DocumentReference<Map<String, dynamic>> document =
        await _firestore
            .collection(_collectionName)
            .add({
      'title': cleanTitle,
      'message': cleanMessage,
      'type': cleanType,
      'isPublished': isPublished,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // ============================================================
  // WATCH ALL ANNOUNCEMENTS
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchAllAnnouncements() {
    return _firestore
        .collection(_collectionName)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ============================================================
  // WATCH PUBLISHED ANNOUNCEMENTS
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchPublishedAnnouncements() {
    return _firestore
        .collection(_collectionName)
        .where(
          'isPublished',
          isEqualTo: true,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ============================================================
  // GET SINGLE ANNOUNCEMENT
  // ============================================================

  static Future<DocumentSnapshot<Map<String, dynamic>>>
      getAnnouncement(
    String announcementId,
  ) async {
    final String id = announcementId.trim();

    if (id.isEmpty) {
      throw Exception(
        'Announcement ID is required.',
      );
    }

    return _firestore
        .collection(_collectionName)
        .doc(id)
        .get();
  }

  // ============================================================
  // UPDATE ANNOUNCEMENT
  // ============================================================

  static Future<void> updateAnnouncement({
    required String announcementId,
    required String title,
    required String message,
    required String type,
    required bool isPublished,
  }) async {
    final String id = announcementId.trim();

    final String cleanTitle = title.trim();
    final String cleanMessage = message.trim();
    final String cleanType = type.trim().toLowerCase();

    if (id.isEmpty) {
      throw Exception(
        'Announcement ID is required.',
      );
    }

    if (cleanTitle.isEmpty) {
      throw Exception(
        'Please enter an announcement title.',
      );
    }

    if (cleanMessage.isEmpty) {
      throw Exception(
        'Please enter an announcement message.',
      );
    }

    if (cleanType.isEmpty) {
      throw Exception(
        'Please select an announcement type.',
      );
    }

    await _firestore
        .collection(_collectionName)
        .doc(id)
        .update({
      'title': cleanTitle,
      'message': cleanMessage,
      'type': cleanType,
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE PUBLISHED STATUS
  // ============================================================

  static Future<void> updatePublishedStatus({
    required String announcementId,
    required bool isPublished,
  }) async {
    final String id = announcementId.trim();

    if (id.isEmpty) {
      throw Exception(
        'Announcement ID is required.',
      );
    }

    await _firestore
        .collection(_collectionName)
        .doc(id)
        .update({
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE ANNOUNCEMENT
  // ============================================================

  static Future<void> deleteAnnouncement({
    required String announcementId,
  }) async {
    final String id = announcementId.trim();

    if (id.isEmpty) {
      throw Exception(
        'Announcement ID is required.',
      );
    }

    await _firestore
        .collection(_collectionName)
        .doc(id)
        .delete();
  }
}