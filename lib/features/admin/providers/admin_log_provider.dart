import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/admin_log_service.dart';

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
// ADMIN LOG STREAM PROVIDER
// ============================================================

final adminLogStreamProvider =
    StreamProvider<
        QuerySnapshot<Map<String, dynamic>>>(
  (ref) {
    final AdminLogService service =
        ref.read(
      adminLogServiceProvider,
    );

    return service.watchLogs();
  },
);

// ============================================================
// ADMIN LOG ACTIONS
// ============================================================

final adminLogActionsProvider =
    Provider<AdminLogActions>(
  (ref) {
    return AdminLogActions(
      ref.read(
        adminLogServiceProvider,
      ),
    );
  },
);

// ============================================================
// ADMIN LOG ACTIONS
// ============================================================

class AdminLogActions {
  const AdminLogActions(
    this._service,
  );

  final AdminLogService _service;

  // ============================================================
  // CREATE GENERIC LOG
  // ============================================================

  Future<void> createLog({
    required String action,
    required String description,
    String category = 'system',
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
  }) {
    return _service.createLog(
      action: action,
      category: category,
      description: description,
      targetId: targetId,
      targetType: targetType,
      metadata: metadata,
    );
  }

  // ============================================================
  // SETTINGS UPDATE
  // ============================================================

  Future<void> logSettingsUpdate({
    required String setting,
    required dynamic oldValue,
    required dynamic newValue,
  }) {
    return _service.createLog(
      action: 'settings_updated',
      category: 'settings',
      description:
          'Application setting "$setting" was updated.',
      targetType: 'app_settings',
      metadata: <String, dynamic>{
        'setting': setting,
        'oldValue': oldValue,
        'newValue': newValue,
      },
    );
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> logCreate({
    required String category,
    required String description,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
  }) {
    return _service.createLog(
      action: 'create',
      category: category,
      description: description,
      targetId: targetId,
      targetType: targetType,
      metadata: metadata,
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> logUpdate({
    required String category,
    required String action,
    required String description,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
  }) {
    return _service.createLog(
      action: action,
      category: category,
      description: description,
      targetId: targetId,
      targetType: targetType,
      metadata: metadata,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> logDelete({
    required String category,
    required String description,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
  }) {
    return _service.createLog(
      action: 'delete',
      category: category,
      description: description,
      targetId: targetId,
      targetType: targetType,
      metadata: metadata,
    );
  }
}