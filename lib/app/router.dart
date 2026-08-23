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

  static final GoRouter router =
      GoRouter(
    initialLocation: '/',

    // ==========================================================
    // AUTH REFRESH
    // ==========================================================

    refreshListenable:
        authRefreshNotifier,

    // ==========================================================
    // REDIRECT
    // ==========================================================

    redirect: (
      BuildContext context,
      GoRouterState state,
    ) async {
      final ProviderContainer
          container =
          ProviderScope.containerOf(
        context,
        listen: false,
      );

      final authState =
          container.read(
        authProvider,
      );

      final String location =
          state.uri.path;

      // ========================================================
      // PUBLIC ROUTES
      // ========================================================

      final bool isSplashPage =
          location == '/';

      final bool isLoginPage =
          location == '/login';

      final bool isRegisterPage =
          location == '/register';

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
          authState.valueOrNull !=
              null;

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
            await UserService
                .getCurrentUserRole();
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
        // ======================================================
        // AUTH PAGES
        // ======================================================

        if (isLoginPage ||
            isRegisterPage) {
          return '/admin';
        }

        // ======================================================
        // SPLASH
        // ======================================================

        if (isSplashPage) {
          return '/admin';
        }

        // ======================================================
        // BLOCK USER HOME
        // ======================================================

        if (location == '/home') {
          return '/admin';
        }

        // ======================================================
        // USER-ONLY ROUTES
        // ======================================================

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

        // ======================================================
        // ADMIN ROUTES
        // ======================================================

        final bool isAdminRoute =
            location == '/admin' ||
            location == '/admin/users' ||
            location == '/admin/plants' ||
            location == '/admin/reports' ||
            location == '/admin/feedback' ||
            location == '/admin/support' ||
            location ==
                '/admin/announcements' ||
            location ==
                '/admin/settings' ||
            location == '/admin/logs';

        if (isAdminRoute) {
          return null;
        }

        // ======================================================
        // USER ANNOUNCEMENTS
        // ======================================================

        if (location ==
            '/announcements') {
          return null;
        }

        // ======================================================
        // UNKNOWN ADMIN ROUTE
        // ======================================================

        if (location.startsWith(
          '/admin/',
        )) {
          return '/admin';
        }

        // ======================================================
        // DEFAULT
        // ======================================================

        return '/admin';
      }

      // ========================================================
      // NORMAL USER
      // ========================================================

      // ========================================================
      // BLOCK ADMIN ROUTES
      // ========================================================

      if (location == '/admin' ||
          location.startsWith(
            '/admin/',
          )) {
        return '/home';
      }

      // ========================================================
      // LOGIN / REGISTER
      // ========================================================

      if (isLoginPage ||
          isRegisterPage) {
        return '/home';
      }

      // ========================================================
      // SPLASH
      // ========================================================

      if (isSplashPage) {
        return '/home';
      }

      // ========================================================
      // ANNOUNCEMENTS
      // ========================================================

      if (location ==
          '/announcements') {
        return null;
      }

      // ========================================================
      // OTHER USER ROUTES
      // ========================================================

      return null;
    },

    // ==========================================================
    // ROUTES
    // ==========================================================

    routes: [
      // ========================================================
      // SPLASH
      // ========================================================

      GoRoute(
        path: '/',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const SplashScreen();
        },
      ),

      // ========================================================
      // LOGIN
      // ========================================================

      GoRoute(
        path: '/login',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const LoginScreen();
        },
      ),

      // ========================================================
      // REGISTER
      // ========================================================

      GoRoute(
        path: '/register',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const RegisterScreen();
        },
      ),

      // ========================================================
      // HOME
      // ========================================================

      GoRoute(
        path: '/home',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const HomeScreen();
        },
      ),

      // ========================================================
      // USER ANNOUNCEMENTS
      // ========================================================

      GoRoute(
        path: '/announcements',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AnnouncementsScreen();
        },
      ),

      // ========================================================
      // ADMIN DASHBOARD
      // ========================================================

      GoRoute(
        path: '/admin',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminDashboardScreen();
        },
      ),

      // ========================================================
      // ADMIN USERS
      // ========================================================

      GoRoute(
        path: '/admin/users',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminUsersScreen();
        },
      ),

      // ========================================================
      // ADMIN PLANTS
      // ========================================================

      GoRoute(
        path: '/admin/plants',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminPlantsScreen();
        },
      ),

      // ========================================================
      // ADMIN REPORTS
      // ========================================================

      GoRoute(
        path: '/admin/reports',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminReportsScreen();
        },
      ),

      // ========================================================
      // ADMIN FEEDBACK
      // ========================================================

      GoRoute(
        path: '/admin/feedback',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminFeedbackScreen();
        },
      ),

      // ========================================================
      // ADMIN SUPPORT
      // ========================================================

      GoRoute(
        path: '/admin/support',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminSupportScreen();
        },
      ),

      // ========================================================
      // ADMIN ANNOUNCEMENTS
      // ========================================================

      GoRoute(
        path: '/admin/announcements',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminAnnouncementsScreen();
        },
      ),

      // ========================================================
      // ADMIN APP SETTINGS
      // ========================================================

      GoRoute(
        path: '/admin/settings',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminAppSettingsScreen();
        },
      ),

      // ========================================================
      // ADMIN LOGS
      // ========================================================

      GoRoute(
        path: '/admin/logs',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const AdminLogsScreen();
        },
      ),

      // ========================================================
      // IDENTIFY
      // ========================================================

      GoRoute(
        path: '/identify',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const IdentifyScreen();
        },
      ),

      // ========================================================
      // PLANT REPORT
      // ========================================================

      GoRoute(
        path: '/plant-report',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const PlantReportScreen();
        },
      ),

      // ========================================================
      // DISEASE
      // ========================================================

      GoRoute(
        path: '/disease',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const DiseaseScreen();
        },
      ),

      // ========================================================
      // CHATBOT
      // ========================================================

      GoRoute(
        path: '/chatbot',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const ChatbotScreen();
        },
      ),

      // ========================================================
      // REMINDERS
      // ========================================================

      GoRoute(
        path: '/reminders',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const ReminderScreen();
        },
      ),

      // ========================================================
      // PROFILE
      // ========================================================

      GoRoute(
        path: '/profile',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const ProfileScreen();
        },
      ),

      // ========================================================
      // FEEDBACK
      // ========================================================

      GoRoute(
        path: '/feedback',
        builder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return const FeedbackScreen();
        },
      ),

      // ========================================================
      // SUPPORT
      // ========================================================

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