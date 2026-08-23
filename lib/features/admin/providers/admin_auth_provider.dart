import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_user.dart';
import '../services/admin_auth_service.dart';

final adminAuthServiceProvider =
    Provider<AdminAuthService>((ref) {
  return AdminAuthService();
});

// ================================================================
// STATE
// ================================================================

class AdminAuthState {
  final AdminUser? admin;
  final bool isLoading;
  final String? errorMessage;

  const AdminAuthState({
    this.admin,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated {
    return admin != null;
  }

  AdminAuthState copyWith({
    AdminUser? admin,
    bool? isLoading,
    String? errorMessage,
    bool clearAdmin = false,
    bool clearError = false,
  }) {
    return AdminAuthState(
      admin: clearAdmin
          ? null
          : admin ?? this.admin,
      isLoading:
          isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

// ================================================================
// NOTIFIER
// ================================================================

class AdminAuthNotifier
    extends Notifier<AdminAuthState> {
  late final AdminAuthService _service;

  @override
  AdminAuthState build() {
    _service =
        ref.read(adminAuthServiceProvider);

    return const AdminAuthState();
  }

  // ==============================================================
  // LOGIN
  // ==============================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) {
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final admin =
          await _service.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        admin: admin,
        isLoading: false,
        clearError: true,
      );

      return true;
    } on AdminAuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );

      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Something went wrong. Please try again.',
      );

      return false;
    }
  }

  // ==============================================================
  // LOGOUT
  // ==============================================================

  Future<void> logout() async {
    await _service.logout();

    state = const AdminAuthState();
  }

  // ==============================================================
  // RESTORE SESSION
  // ==============================================================

  Future<void> restoreSession() async {
    try {
      final admin =
          await _service.getCurrentAdmin();

      if (admin == null) {
        state = const AdminAuthState();
        return;
      }

      state = state.copyWith(
        admin: admin,
        clearError: true,
      );
    } catch (_) {
      state = const AdminAuthState();
    }
  }
}

// ================================================================
// PROVIDER
// ================================================================

final adminAuthProvider =
    NotifierProvider<
        AdminAuthNotifier,
        AdminAuthState>(
  AdminAuthNotifier.new,
);