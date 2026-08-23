import 'package:flutter/material.dart';

import '../../auth/services/user_service.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_login_screen.dart';

class AdminGuard extends StatefulWidget {
  const AdminGuard({
    super.key,
  });

  @override
  State<AdminGuard> createState() =>
      _AdminGuardState();
}

class _AdminGuardState
    extends State<AdminGuard> {
  bool _isChecking = true;
  bool _isAdmin = false;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _checkAdminAccess();
  }

  // ==========================================================
  // CHECK ADMIN ACCESS
  // ==========================================================

  Future<void> _checkAdminAccess() async {
    try {
      // --------------------------------------------------------
      // CHECK ADMIN FROM USER SERVICE
      // --------------------------------------------------------

      final bool isAdmin =
          await UserService.isAdmin();

      // --------------------------------------------------------
      // WIDGET DISPOSED
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // UPDATE STATE
      // --------------------------------------------------------

      setState(() {
        _isAdmin = isAdmin;
        _isChecking = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'ADMIN ACCESS CHECK ERROR: $error',
      );

      debugPrint(
        'ADMIN ACCESS CHECK STACK TRACE: $stackTrace',
      );

      // --------------------------------------------------------
      // WIDGET DISPOSED
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // ACCESS DENIED
      // --------------------------------------------------------

      setState(() {
        _isAdmin = false;
        _isChecking = false;
      });
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    // ========================================================
    // CHECKING
    // ========================================================

    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ========================================================
    // NOT ADMIN
    // ========================================================

    if (!_isAdmin) {
      return const AdminLoginScreen();
    }

    // ========================================================
    // ADMIN
    // ========================================================

    return const AdminDashboardScreen();
  }
}