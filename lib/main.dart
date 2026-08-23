import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE INITIALIZATION
  // ============================================================

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('========================================');
    debugPrint('GREENMIND AI');
    debugPrint('Firebase initialized successfully.');
    debugPrint('========================================');
  } catch (error, stackTrace) {
    debugPrint('========================================');
    debugPrint('FIREBASE INITIALIZATION ERROR');
    debugPrint('ERROR: $error');
    debugPrint('STACK TRACE:');
    debugPrint('$stackTrace');
    debugPrint('========================================');
  }

  // ============================================================
  // RUN APP
  // ============================================================

  runApp(
    const ProviderScope(
      child: GreenMindApp(),
    ),
  );
}

// ================================================================
// GREENMIND APP
// ================================================================

class GreenMindApp extends StatelessWidget {
  const GreenMindApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'GreenMind AI',

      // ==========================================================
      // ROUTER
      // ==========================================================

      routerConfig: AppRouter.router,

      // ==========================================================
      // THEME
      // ==========================================================

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed: const Color(
          0xFF2E7D32,
        ),

        scaffoldBackgroundColor:
            const Color(0xFFF7FAF7),

        visualDensity:
            VisualDensity.adaptivePlatformDensity,

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor:
              Color(0xFFEAF3E8),
          foregroundColor:
              Color(0xFF1B1B1B),
        ),

        inputDecorationTheme:
            const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize:
                const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}