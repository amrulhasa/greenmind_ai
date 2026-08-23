import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime? createdAt;

  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.createdAt,
  });

  factory AdminUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final timestamp = data['createdAt'];

    return AdminUser(
      uid: document.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      status: data['status']?.toString() ?? 'active',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
    );
  }

  bool get isSuperAdmin {
    return role == 'super_admin';
  }

  bool get isAdmin {
    return role == 'admin' ||
        role == 'super_admin';
  }

  bool get isActive {
    return status == 'active';
  }
}