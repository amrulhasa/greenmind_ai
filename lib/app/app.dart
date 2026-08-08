import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';
import '../features/profile/providers/profile_provider.dart';

class GreenMindApp extends ConsumerWidget {
  const GreenMindApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profileState = ref.watch(profileProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'GreenMind AI',

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: profileState.profile.darkModeEnabled
          ? ThemeMode.dark
          : ThemeMode.light,

      routerConfig: AppRouter.router,
    );
  }
}