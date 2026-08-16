import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashController {
  SplashController._();

  static void start(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      if (!context.mounted) {
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }
}
