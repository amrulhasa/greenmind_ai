import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/chatbot/screens/chatbot_screen.dart';
import '../features/disease/screens/disease_screen.dart';
import '../features/home/home_screen.dart';
import '../features/identify/screens/identify_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/reminder/screens/reminder_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',

    // ==========================================================
    // AUTH STATE REFRESH
    // ==========================================================

    refreshListenable:
        authRefreshNotifier,

    // ==========================================================
    // AUTH REDIRECT
    // ==========================================================

    redirect: (
      context,
      state,
    ) {
      final container =
          ProviderScope.containerOf(
        context,
        listen: false,
      );

      final authState =
          container.read(
        authProvider,
      );

      final isLoggedIn =
          authState.valueOrNull != null;

      final location =
          state.matchedLocation;

      final isLoginPage =
          location == '/login';

      final isRegisterPage =
          location == '/register';

      final isSplashPage =
          location == '/';

      final isPublicPage =
          isLoginPage ||
          isRegisterPage ||
          isSplashPage;

      // ========================================================
      // NOT LOGGED IN
      // ========================================================

      if (!isLoggedIn &&
          !isPublicPage) {
        return '/login';
      }

      // ========================================================
      // ALREADY LOGGED IN
      // ========================================================

      if (isLoggedIn &&
          (isLoginPage ||
              isRegisterPage)) {
        return '/home';
      }

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
          context,
          state,
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
          context,
          state,
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
          context,
          state,
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
          context,
          state,
        ) {
          return const HomeScreen();
        },
      ),

      // ========================================================
      // IDENTIFY
      // ========================================================

      GoRoute(
        path: '/identify',
        builder: (
          context,
          state,
        ) {
          return const IdentifyScreen();
        },
      ),

      // ========================================================
      // DISEASE
      // ========================================================

      GoRoute(
        path: '/disease',
        builder: (
          context,
          state,
        ) {
          return const DiseaseScreen();
        },
      ),

      // ========================================================
      // AI CHAT
      // ========================================================

      GoRoute(
        path: '/chatbot',
        builder: (
          context,
          state,
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
          context,
          state,
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
          context,
          state,
        ) {
          return const ProfileScreen();
        },
      ),
    ],
  );
}