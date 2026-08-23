import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      '================================',
    );

    debugPrint(
      'GREENMIND AI',
    );

    debugPrint(
      'Firebase initialized successfully.',
    );

    debugPrint(
      '================================',
    );
  } catch (error, stackTrace) {
    debugPrint(
      'FIREBASE INITIALIZATION ERROR',
    );

    debugPrint(
      'ERROR: $error',
    );

    debugPrint(
      'STACK TRACE: $stackTrace',
    );
  }

  runApp(
    const ProviderScope(
      child: GreenMindApp(),
    ),
  );
}