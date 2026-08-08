import 'package:go_router/go_router.dart';

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
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/identify',
        builder: (context, state) => const IdentifyScreen(),
      ),
      GoRoute(
        path: '/disease',
        builder: (context, state) => const DiseaseScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const ReminderScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}