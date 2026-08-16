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

  static final GoRouter router =
      GoRouter(
    initialLocation: '/',

    refreshListenable:
        authRefreshNotifier,

    redirect:
        (context, state) {
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

      final isSplashPage =
          location == '/';

      final isLoginPage =
          location == '/login';

      final isRegisterPage =
          location == '/register';

      final isPublicPage =
          isSplashPage ||
              isLoginPage ||
              isRegisterPage;

      if (!isLoggedIn &&
          !isPublicPage) {
        return '/login';
      }

      if (isLoggedIn &&
          (isLoginPage ||
              isRegisterPage)) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) =>
                const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        builder:
            (context, state) =>
                const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder:
            (context, state) =>
                const RegisterScreen(),
      ),

      GoRoute(
        path: '/home',
        builder:
            (context, state) =>
                const HomeScreen(),
      ),

      GoRoute(
        path: '/identify',
        builder:
            (context, state) =>
                const IdentifyScreen(),
      ),

      GoRoute(
        path: '/disease',
        builder:
            (context, state) =>
                const DiseaseScreen(),
      ),

      GoRoute(
        path: '/chatbot',
        builder:
            (context, state) =>
                const ChatbotScreen(),
      ),

      GoRoute(
        path: '/reminders',
        builder:
            (context, state) =>
                const ReminderScreen(),
      ),

      GoRoute(
        path: '/profile',
        builder:
            (context, state) =>
                const ProfileScreen(),
      ),
    ],
  );
}