import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final splashProvider = Provider<SplashService>(
  (ref) => SplashService(),
);

class SplashService {
  void navigateToHome(GoRouter router) {
    Timer(
      const Duration(seconds: 2),
      () {
        router.go('/home');
      },
    );
  }
}