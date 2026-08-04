import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashController {
  SplashController._();

  static void start(BuildContext context) {
    Timer(
      const Duration(seconds: 2),
      () {
        if (context.mounted) {
          context.go('/home');
        }
      },
    );
  }
}