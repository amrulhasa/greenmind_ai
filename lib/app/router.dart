import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ============================================================
// USER ANNOUNCEMENTS
// ============================================================

import '../features/announcements/screens/announcements_screen.dart';

// ============================================================
// ADMIN SCREENS
// ============================================================

import '../features/admin/screens/admin_announcements_screen.dart';
import '../features/admin/screens/admin_app_settings_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_feedback_screen.dart';
import '../features/admin/screens/admin_logs_screen.dart';
import '../features/admin/screens/admin_plants_screen.dart';
import '../features/admin/screens/admin_reports_screen.dart';
import '../features/admin/screens/admin_support_screen.dart';
import '../features/admin/screens/admin_users_screen.dart';

// ============================================================
// AUTH
// ============================================================

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/services/user_service.dart';

// ============================================================
// USER FEATURES
// ============================================================

import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/disease/screens/disease_screen.dart';
import '../features/feedback/screens/feedback_screen.dart';
import '../features/home/home_screen.dart';
import '../features/identify/screens/identify_screen.dart';
import '../features/plant_report/screens/plant_report_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/reminder/screens/reminder_screen.dart';
import '../features/splash/splash_screen.dart';

// ============================================================
// SUPPORT
// ============================================================

import '../features/support/screens/support_screen.dart';

class AppRouter {
  AppRouter._();

  // ============================================================
  // ROUTER
  // ============================================================

  static final GoRouter router = GoRouter(
    initialLocation: '/',

    // ==========================================================
    // AUTH REFRESH
    // ==========================================================

    refreshListenable: authRefreshNotifier,

    // ==========================================================
    // REDIRECT
    // ==========================================================

    redirect: (
      BuildContext context,
      GoRouterState state,
    ) async {
      final ProviderContainer container =
          ProviderScope.containerOf(
        context,
        listen: false,
      );

      final authState = container.read(
        authProvider,
      );

      final String location = state.uri.path;

      // ========================================================
      // PUBLIC ROUTES
      // ========================================================

      final bool isSplashPage = location == '/';
      final bool isLoginPage = location == '/login';
      final bool isRegisterPage = location == '/register';

      final bool isPublicPage =
          isSplashPage ||
          isLoginPage ||
          isRegisterPage;

      // ========================================================
      // AUTH LOADING
      // ========================================================

      if (authState.isLoading) {
        return null;
      }

      // ========================================================
      // LOGIN STATUS
      // ========================================================

      final bool isLoggedIn =
          authState.valueOrNull != null;

      // ========================================================
      // NOT LOGGED IN
      // ========================================================

      if (!isLoggedIn) {
        if (isPublicPage) {
          return null;
        }

        return '/login';
      }

      // ========================================================
      // USER ROLE
      // ========================================================

      String? role;

      try {
        role =
            await UserService.getCurrentUserRole();
      } catch (error) {
        debugPrint(
          'GET USER ROLE ERROR: $error',
        );

        return '/login';
      }

      final String normalizedRole =
          (role ?? 'user')
              .trim()
              .toLowerCase();

      final bool isAdmin =
          normalizedRole == 'admin';

      // ========================================================
      // ADMIN
      // ========================================================

      if (isAdmin) {
        if (isLoginPage ||
            isRegisterPage) {
          return '/admin';
        }

        if (isSplashPage) {
          return '/admin';
        }

        if (location == '/home') {
          return '/admin';
        }

        final bool isUserOnlyRoute =
            location == '/identify' ||
            location == '/plant-report' ||
            location == '/disease' ||
            location == '/chatbot' ||
            location == '/reminders' ||
            location == '/profile' ||
            location == '/feedback' ||
            location == '/support';

        if (isUserOnlyRoute) {
          return '/admin';
        }

        final bool isAdminRoute =
            location == '/admin' ||
            location == '/admin/users' ||
            location == '/admin/plants' ||
            location == '/admin/reports' ||
            location == '/admin/feedback' ||
            location == '/admin/support' ||
            location == '/admin/announcements' ||
            location == '/admin/settings' ||
            location == '/admin/logs';

        if (isAdminRoute) {
          return null;
        }

        if (location == '/announcements') {
          return null;
        }

        if (location.startsWith('/admin/')) {
          return '/admin';
        }

        return '/admin';
      }

      // ========================================================
      // NORMAL USER
      // ========================================================

      if (location == '/admin' ||
          location.startsWith('/admin/')) {
        return '/home';
      }

      if (isLoginPage ||
          isRegisterPage) {
        return '/home';
      }

      if (isSplashPage) {
        return '/home';
      }

      if (location == '/announcements') {
        return null;
      }

      return null;
    },

    // ==========================================================
    // ROUTES
    // ==========================================================

    routes: [
      GoRoute(
        path: '/',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/home',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const HomeScreen();
        },
      ),

      GoRoute(
        path: '/announcements',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AnnouncementsScreen();
        },
      ),

      GoRoute(
        path: '/admin',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminDashboardScreen();
        },
      ),

      GoRoute(
        path: '/admin/users',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminUsersScreen();
        },
      ),

      GoRoute(
        path: '/admin/plants',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminPlantsScreen();
        },
      ),

      GoRoute(
        path: '/admin/reports',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminReportsScreen();
        },
      ),

      GoRoute(
        path: '/admin/feedback',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminFeedbackScreen();
        },
      ),

      GoRoute(
        path: '/admin/support',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminSupportScreen();
        },
      ),

      GoRoute(
        path: '/admin/announcements',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminAnnouncementsScreen();
        },
      ),

      GoRoute(
        path: '/admin/settings',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminAppSettingsScreen();
        },
      ),

      GoRoute(
        path: '/admin/logs',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminLogsScreen();
        },
      ),

      GoRoute(
        path: '/identify',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const IdentifyScreen();
        },
      ),

      GoRoute(
        path: '/plant-report',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const PlantReportScreen();
        },
      ),

      GoRoute(
        path: '/disease',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const DiseaseScreen();
        },
      ),

      GoRoute(
        path: '/chatbot',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const ChatbotScreen();
        },
      ),

      GoRoute(
        path: '/reminders',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const ReminderScreen();
        },
      ),

      GoRoute(
        path: '/profile',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const ProfileScreen();
        },
      ),

      GoRoute(
        path: '/feedback',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const FeedbackScreen();
        },
      ),

      GoRoute(
        path: '/support',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const SupportScreen();
        },
      ),
    ],
  );
}

// ============================================================
// GLOBAL ROUTER INSTANCE
// ============================================================
//
// app.dart uses:
// routerConfig: appRouter
//
// Therefore this must exist.
//

final GoRouter appRouter = AppRouter.router;