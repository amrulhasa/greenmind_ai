import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  FeedbackService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // SUBMIT FEEDBACK
  // ============================================================

  static Future<void> submitFeedback({
    required int rating,
    required String message,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to submit feedback.',
      );
    }

    final String feedbackMessage = message.trim();

    if (feedbackMessage.isEmpty) {
      throw Exception(
        'Please enter your feedback.',
      );
    }

    if (feedbackMessage.length < 5) {
      throw Exception(
        'Feedback must contain at least 5 characters.',
      );
    }

    if (rating < 1 || rating > 5) {
      throw Exception(
        'Please select a rating between 1 and 5.',
      );
    }

    await _firestore.collection('feedback').add({
      'userId': user.uid,

      // Keep both fields for compatibility.
      'userEmail': user.email ?? '',
      'email': user.email ?? '',

      'rating': rating,

      'message': feedbackMessage,

      'status': 'pending',

      'createdAt': FieldValue.serverTimestamp(),

      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE FEEDBACK
  // ============================================================

  static Future<void> deleteFeedback({
    required String feedbackId,
  }) async {
    final String id = feedbackId.trim();

    if (id.isEmpty) {
      throw Exception(
        'Feedback ID is required.',
      );
    }

    await _firestore
        .collection('feedback')
        .doc(id)
        .delete();
  }

  // ============================================================
  // UPDATE FEEDBACK STATUS
  // ============================================================

  static Future<void> updateFeedbackStatus({
    required String feedbackId,
    required String status,
  }) async {
    final String id = feedbackId.trim();

    final String normalizedStatus =
        status.trim().toLowerCase();

    if (id.isEmpty) {
      throw Exception(
        'Feedback ID is required.',
      );
    }

    const List<String> allowedStatuses = [
      'pending',
      'reviewed',
      'resolved',
      'rejected',
      'closed',
      'completed',
    ];

    if (!allowedStatuses.contains(
      normalizedStatus,
    )) {
      throw Exception(
        'Invalid feedback status.',
      );
    }

    await _firestore
        .collection('feedback')
        .doc(id)
        .update({
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}