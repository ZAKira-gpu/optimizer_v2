import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/database/database_init.dart';

/// Main entry point of the application
///
/// This is the entry point that initializes and runs the Flutter app.
/// It initializes Firebase and uses the OptimizerApp widget which contains all the app configuration.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Initialize Hive database
    await DatabaseInit.initialize();
    print('✅ Hive database initialized successfully');
  } catch (e) {
    print('❌ Initialization failed: $e');
    rethrow;
  }

  runApp(const OptimizerApp());
}
