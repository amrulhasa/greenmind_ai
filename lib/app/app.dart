import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class GreenMindApp extends StatelessWidget {
  const GreenMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'GreenMind AI',

      theme: AppTheme.lightTheme,

      routerConfig: AppRouter.router,
    );
  }
}