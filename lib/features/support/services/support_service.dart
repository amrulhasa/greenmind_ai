import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {
  SupportService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const String _collectionName = 'support_tickets';

  // ============================================================
  // CREATE SUPPORT TICKET
  // ============================================================

  static Future<String> createTicket({
    required String subject,
    required String message,
    required String category,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to create a support ticket.',
      );
    }

    final String cleanSubject = subject.trim();
    final String cleanMessage = message.trim();
    final String cleanCategory = category.trim();

    if (cleanSubject.isEmpty) {
      throw Exception(
        'Please enter a subject.',
      );
    }

    if (cleanMessage.isEmpty) {
      throw Exception(
        'Please describe your problem.',
      );
    }

    if (cleanMessage.length < 5) {
      throw Exception(
        'Message must contain at least 5 characters.',
      );
    }

    if (cleanCategory.isEmpty) {
      throw Exception(
        'Please select a category.',
      );
    }

    final DocumentReference<Map<String, dynamic>> document =
        await _firestore
            .collection(_collectionName)
            .add({
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'subject': cleanSubject,
      'message': cleanMessage,
      'category': cleanCategory,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // ============================================================
  // GET CURRENT USER TICKETS
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchMyTickets() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Stream<
          QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return _firestore
        .collection(_collectionName)
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .snapshots();
  }

  // ============================================================
  // GET ALL TICKETS
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      watchAllTickets() {
    return _firestore
        .collection(_collectionName)
        .snapshots();
  }

  // ============================================================
  // UPDATE TICKET STATUS
  // ============================================================

  static Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    final String id = ticketId.trim();
    final String normalizedStatus =
        status.trim().toLowerCase();

    if (id.isEmpty) {
      throw Exception(
        'Ticket ID is required.',
      );
    }

    const List<String> allowedStatuses = [
      'open',
      'in_progress',
      'resolved',
      'closed',
    ];

    if (!allowedStatuses.contains(normalizedStatus)) {
      throw Exception(
        'Invalid ticket status.',
      );
    }

    await _firestore
        .collection(_collectionName)
        .doc(id)
        .update({
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE TICKET
  // ============================================================

  static Future<void> deleteTicket({
    required String ticketId,
  }) async {
    final String id = ticketId.trim();

    if (id.isEmpty) {
      throw Exception(
        'Ticket ID is required.',
      );
    }

    await _firestore
        .collection(_collectionName)
        .doc(id)
        .delete();
  }
}