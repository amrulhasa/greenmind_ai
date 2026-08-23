import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  AdminService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================================================
  // COLLECTIONS
  // ==========================================================

  static CollectionReference<
      Map<String, dynamic>> get _usersCollection {
    return _firestore.collection(
      'users',
    );
  }

  static CollectionReference<
      Map<String, dynamic>>
      get _identificationsCollection {
    return _firestore.collection(
      'identifications',
    );
  }

  static CollectionReference<
      Map<String, dynamic>> get _reportsCollection {
    return _firestore.collection(
      'reports',
    );
  }

  static CollectionReference<
      Map<String, dynamic>>
      get _adminLogsCollection {
    return _firestore.collection(
      'admin_logs',
    );
  }

  // ==========================================================
  // TOTAL USERS
  // ==========================================================

  static Future<int> getTotalUsers() async {
    final snapshot =
        await _usersCollection
            .count()
            .get();

    return snapshot.count ?? 0;
  }

  // ==========================================================
  // TOTAL IDENTIFICATIONS
  // ==========================================================

  static Future<int>
      getTotalIdentifications() async {
    final snapshot =
        await _identificationsCollection
            .count()
            .get();

    return snapshot.count ?? 0;
  }

  // ==========================================================
  // TOTAL REPORTS
  // ==========================================================

  static Future<int> getTotalReports() async {
    final snapshot =
        await _reportsCollection
            .count()
            .get();

    return snapshot.count ?? 0;
  }

  // ==========================================================
  // AI SUCCESS RATE
  // ==========================================================

  static Future<double>
      getAiSuccessRate() async {
    final totalSnapshot =
        await _identificationsCollection
            .count()
            .get();

    final int total =
        totalSnapshot.count ?? 0;

    if (total == 0) {
      return 0.0;
    }

    final successfulSnapshot =
        await _identificationsCollection
            .where(
              'status',
              isEqualTo: 'success',
            )
            .count()
            .get();

    final int successful =
        successfulSnapshot.count ?? 0;

    return (successful / total) * 100;
  }

  // ==========================================================
  // DASHBOARD STATISTICS
  // ==========================================================

  static Future<
      AdminDashboardStats>
      getDashboardStats() async {
    final totalUsersFuture =
        getTotalUsers();

    final totalIdentificationsFuture =
        getTotalIdentifications();

    final totalReportsFuture =
        getTotalReports();

    final aiSuccessRateFuture =
        getAiSuccessRate();

    final results = await Future.wait([
      totalUsersFuture,
      totalIdentificationsFuture,
      totalReportsFuture,
      aiSuccessRateFuture,
    ]);

    return AdminDashboardStats(
      totalUsers:
          results[0] as int,
      totalIdentifications:
          results[1] as int,
      totalReports:
          results[2] as int,
      aiSuccessRate:
          results[3] as double,
    );
  }

  // ==========================================================
  // RECENT IDENTIFICATIONS
  // ==========================================================

  static Stream<
      QuerySnapshot<
          Map<String, dynamic>>>
      watchRecentIdentifications({
    int limit = 10,
  }) {
    return _identificationsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots();
  }

  // ==========================================================
  // RECENT REPORTS
  // ==========================================================

  static Stream<
      QuerySnapshot<
          Map<String, dynamic>>>
      watchRecentReports({
    int limit = 10,
  }) {
    return _reportsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots();
  }

  // ==========================================================
  // RECENT ADMIN ACTIVITY
  // ==========================================================

  static Stream<
      QuerySnapshot<
          Map<String, dynamic>>>
      watchRecentAdminActivity({
    int limit = 10,
  }) {
    return _adminLogsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(limit)
        .snapshots();
  }

  // ==========================================================
  // CREATE IDENTIFICATION
  // ==========================================================

  static Future<String>
      createIdentification({
    required String userId,
    required String plantName,
    required String scientificName,
    required double confidence,
    required bool isHealthy,
    required String description,
    required String careTips,
    required String status,
  }) async {
    final document =
        await _identificationsCollection
            .add({
      'userId': userId,
      'plantName': plantName,
      'scientificName':
          scientificName,
      'confidence': confidence,
      'isHealthy': isHealthy,
      'description': description,
      'careTips': careTips,
      'status': status,
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // ==========================================================
  // CREATE REPORT
  // ==========================================================

  static Future<String>
      createReport({
    required String userId,
    required String identificationId,
    required String plantName,
    required String scientificName,
    required double confidence,
    required bool isHealthy,
  }) async {
    final document =
        await _reportsCollection.add({
      'userId': userId,
      'identificationId':
          identificationId,
      'plantName': plantName,
      'scientificName':
          scientificName,
      'confidence': confidence,
      'isHealthy': isHealthy,
      'status': 'generated',
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  // ==========================================================
  // CREATE ADMIN LOG
  // ==========================================================

  static Future<void>
      createAdminLog({
    required String adminId,
    required String action,
    String? targetId,
    String? description,
  }) async {
    await _adminLogsCollection.add({
      'adminId': adminId,
      'action': action,
      'targetId': targetId,
      'description':
          description ?? '',
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }
}

// ================================================================
// DASHBOARD STATS MODEL
// ================================================================

class AdminDashboardStats {
  final int totalUsers;
  final int totalIdentifications;
  final int totalReports;
  final double aiSuccessRate;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalIdentifications,
    required this.totalReports,
    required this.aiSuccessRate,
  });
}