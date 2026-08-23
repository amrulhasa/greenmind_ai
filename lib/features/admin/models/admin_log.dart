import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLog {
  const AdminLog({
    required this.id,
    required this.action,
    required this.category,
    required this.description,
    required this.adminId,
    required this.adminEmail,
    required this.createdAt,
    this.targetId,
    this.targetType,
    this.metadata,
  });

  final String id;
  final String action;
  final String category;
  final String description;
  final String adminId;
  final String adminEmail;
  final Timestamp createdAt;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? metadata;

  factory AdminLog.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return AdminLog(
      id: document.id,
      action: data['action']?.toString() ?? 'unknown',
      category: data['category']?.toString() ?? 'system',
      description:
          data['description']?.toString() ?? 'No description',
      adminId: data['adminId']?.toString() ?? '',
      adminEmail: data['adminEmail']?.toString() ?? 'Unknown admin',
      createdAt:
          data['createdAt'] is Timestamp
              ? data['createdAt'] as Timestamp
              : Timestamp.now(),
      targetId: data['targetId']?.toString(),
      targetType: data['targetType']?.toString(),
      metadata:
          data['metadata'] is Map
              ? Map<String, dynamic>.from(
                data['metadata'] as Map,
              )
              : null,
    );
  }
}