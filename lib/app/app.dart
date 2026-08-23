import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile/providers/profile_provider.dart';
import 'router.dart';

class GreenMindApp extends ConsumerWidget {
  const GreenMindApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profileState =
        ref.watch(profileProvider);

    final bool isDarkMode =
        profileState.profile.darkModeEnabled;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'GreenMind AI',

      theme: _lightTheme(),

      darkTheme: _darkTheme(),

      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      routerConfig: appRouter,
    );
  }

  // ============================================================
  // LIGHT THEME
  // ============================================================

  ThemeData _lightTheme() {
    const background =
        Color(0xFFF7FAF7);

    const surface =
        Colors.white;

    const primary =
        Color(0xFF2E7D32);

    return ThemeData(
      useMaterial3: true,

      brightness:
          Brightness.light,

      scaffoldBackgroundColor:
          background,

      colorScheme:
          ColorScheme.fromSeed(
        seedColor: primary,
        brightness:
            Brightness.light,
      ),

      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            background,
        foregroundColor:
            Color(0xFF172018),
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme:
          CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(22),
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: surface,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFE0E8E1),
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFE0E8E1),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),

      navigationBarTheme:
          const NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor:
            Color(0xFFEAF5EC),
      ),

      dividerColor:
          const Color(0xFFE0E8E1),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  ThemeData _darkTheme() {
    const background =
        Color(0xFF0D120E);

    const surface =
        Color(0xFF151C17);

    const surfaceVariant =
        Color(0xFF1B241D);

    const primary =
        Color(0xFF66BB6A);

    const textPrimary =
        Color(0xFFF1F5F1);

    const textSecondary =
        Color(0xFFA8B3AA);

    return ThemeData(
      useMaterial3: true,

      brightness:
          Brightness.dark,

      scaffoldBackgroundColor:
          background,

      colorScheme:
          const ColorScheme.dark(
        primary: primary,
        onPrimary:
            Colors.white,

        secondary:
            Color(0xFF81C784),

        surface: surface,
        onSurface:
            textPrimary,

        surfaceContainerHighest:
            surfaceVariant,

        onSurfaceVariant:
            textSecondary,

        error:
            Color(0xFFFF6B60),

        onError:
            Colors.white,
      ),

      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            background,
        foregroundColor:
            textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme:
          CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(22),
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,

        fillColor:
            surfaceVariant,

        hintStyle:
            const TextStyle(
          color:
              textSecondary,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color:
                Color(0xFF2A352C),
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color:
                Color(0xFF2A352C),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide:
              const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),

      navigationBarTheme:
          const NavigationBarThemeData(
        backgroundColor:
            surface,

        indicatorColor:
            Color(0xFF29432C),

        labelTextStyle:
            WidgetStatePropertyAll(
          TextStyle(
            color:
                textPrimary,
          ),
        ),
      ),

      dividerColor:
          const Color(0xFF29332B),

      textTheme:
          const TextTheme(
        bodyLarge:
            TextStyle(
          color:
              textPrimary,
        ),

        bodyMedium:
            TextStyle(
          color:
              textSecondary,
        ),

        titleLarge:
            TextStyle(
          color:
              textPrimary,
        ),

        titleMedium:
            TextStyle(
          color:
              textPrimary,
        ),

        titleSmall:
            TextStyle(
          color:
              textSecondary,
        ),
      ),

      dialogTheme:
          DialogThemeData(
        backgroundColor:
            surface,

        surfaceTintColor:
            Colors.transparent,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
      ),

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}