/// App route constants
///
/// This file contains all the route names used throughout the app.
/// This makes it easy to maintain consistent routing and update routes globally.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Main Routes
  static const String splash = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Auth Routes
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  // Feature Routes
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
}
