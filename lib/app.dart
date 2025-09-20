import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/splash_screen.dart';
import 'features/auth/view/signup_screen.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/view/forgot_password_screen.dart';
import 'features/auth/view/email_verification_screen.dart';
import 'features/auth/viewmodel/auth_provider.dart';
import 'features/navigation/view/main_navigation_screen.dart';
import 'features/navigation/viewmodel/navigation_provider.dart';
import 'features/profile/viewmodel/profile_provider.dart';
import 'features/health/viewmodel/step_tracker_provider.dart';
import 'features/health/viewmodel/sleep_provider.dart';
import 'features/health/viewmodel/health_database_provider.dart';
import 'features/meals/viewmodel/simple_meal_logging_provider.dart';
import 'features/efficiency/viewmodel/efficiency_provider.dart';
import 'core/database/providers/hive_database_provider.dart';
import 'core/database/providers/hive_sync_provider.dart';
import 'core/ml/providers/ml_score_provider.dart';

/// Main app configuration
///
/// This file contains the MaterialApp setup, routes, and theme configuration.
/// This separates the app configuration from the main entry point.
class OptimizerApp extends StatelessWidget {
  const OptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => StepTrackerProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => HealthDatabaseProvider()),
        ChangeNotifierProvider(create: (_) => SimpleMealLoggingProvider()),
        ChangeNotifierProvider(create: (_) => EfficiencyProvider()),
        ChangeNotifierProvider(create: (_) => HiveDatabaseProvider()),
        ChangeNotifierProvider(create: (_) => HiveSyncProvider()),
        ChangeNotifierProvider(create: (_) => MLScoreProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Follow system theme
        // Remove debug banner
        debugShowCheckedModeBanner: false,

        // Define routes for navigation
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.signup: (context) => const SignupScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.verifyEmail: (context) {
            final email =
                ModalRoute.of(context)?.settings.arguments as String? ?? '';
            return EmailVerificationScreen(email: email);
          },
          AppRoutes.home: (context) => const MainNavigationScreen(),
          // Add more routes as needed
        },

        // Set initial route to splash screen
        initialRoute: AppRoutes.splash,

        // Handle unknown routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(), // Fallback to splash
          );
        },
      ),
    );
  }
}
