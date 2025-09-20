import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../features/auth/models/user.dart' as app_user;

/// Minimal test auth service to isolate the PigeonUserDetails issue
class TestAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  /// Simple sign up test
  Future<bool> testSignUp({
    required String email,
    required String password,
  }) async {
    try {
      print('🧪 TestAuthService: Testing sign-up for $email');

      // Just try to create the user without any complex operations
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ TestAuthService: User created successfully');
      print('User ID: ${result.user?.uid}');
      print('User Email: ${result.user?.email}');

      return true;
    } catch (e) {
      print('❌ TestAuthService: Error: $e');

      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        print('🔍 TestAuthService: Detected PigeonUserDetails error');

        // Try to get the current user anyway
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('✅ TestAuthService: User was actually created despite error');
          print('User ID: ${currentUser.uid}');
          print('User Email: ${currentUser.email}');
          return true;
        }
      }

      // Check if this is an "email already in use" error
      if (e.toString().contains('email-already-in-use')) {
        print(
          '🔍 TestAuthService: Email already in use, checking if user exists',
        );

        // Try to get the current user
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('✅ TestAuthService: User already exists and is signed in');
          print('User ID: ${currentUser.uid}');
          print('User Email: ${currentUser.email}');
          return true;
        }
      }

      return false;
    }
  }

  /// Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;
}
