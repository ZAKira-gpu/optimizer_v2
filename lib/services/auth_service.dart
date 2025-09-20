import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../features/auth/models/user.dart' as app_user;

/// Simple Firebase Auth service
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  /// Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Get current app user
  app_user.User? get currentUser {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) return null;

    try {
      return app_user.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        isEmailVerified: firebaseUser.emailVerified,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      // If metadata access fails due to PigeonUserDetails error, use current time
      print(
        '⚠️ AuthService: Using fallback creation time due to metadata access error: $e',
      );
      return app_user.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        isEmailVerified: firebaseUser.emailVerified,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<app_user.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 AuthService: Creating user with email: $email');

      // Create user with email and password
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Wait a moment for the user to be fully created
      await Future.delayed(const Duration(milliseconds: 1000));

      // Get the current user
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ AuthService: User creation returned null');
        throw Exception('Failed to create user');
      }

      print('✅ AuthService: User created successfully with ID: ${user.uid}');

      // Create the app user object with minimal data
      final appUser = app_user.User(
        id: user.uid,
        email: user.email ?? email,
        isEmailVerified: false, // Always false for new users
        createdAt: DateTime.now(),
      );

      // Send email verification in a separate try-catch
      try {
        print('📧 AuthService: Sending email verification to $email');
        await user.sendEmailVerification();
        print('✅ AuthService: Email verification sent successfully');
      } catch (emailError) {
        print('⚠️ AuthService: Email verification failed: $emailError');
        // Don't throw here, user creation was successful
      }

      return appUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ AuthService: Firebase auth exception: ${e.code} - ${e.message}');

      // Handle "email already in use" error
      if (e.code == 'email-already-in-use') {
        print('🔍 AuthService: Email already in use, checking if user exists');

        // Try to get the current user
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('✅ AuthService: User already exists and is signed in');

          // Create the app user object
          final appUser = app_user.User(
            id: currentUser.uid,
            email: currentUser.email ?? email,
            isEmailVerified: currentUser.emailVerified,
            createdAt: DateTime.now(),
          );

          // Try to send email verification
          try {
            if (!currentUser.emailVerified) {
              print('📧 AuthService: Sending email verification to $email');
              await currentUser.sendEmailVerification();
              print('✅ AuthService: Email verification sent successfully');
            }
          } catch (emailError) {
            print('⚠️ AuthService: Email verification failed: $emailError');
          }

          return appUser;
        }
      }

      throw Exception('Signup failed: ${e.message}');
    } catch (e) {
      print('❌ AuthService: General exception: $e');

      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        print(
          '🔍 AuthService: Detected PigeonUserDetails error, checking if user was created',
        );

        // Try to get the current user anyway
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print(
            '✅ AuthService: User was actually created despite PigeonUserDetails error',
          );

          // Create the app user object
          final appUser = app_user.User(
            id: currentUser.uid,
            email: currentUser.email ?? email,
            isEmailVerified: false,
            createdAt: DateTime.now(),
          );

          // Try to send email verification
          try {
            print('📧 AuthService: Sending email verification to $email');
            await currentUser.sendEmailVerification();
            print('✅ AuthService: Email verification sent successfully');
          } catch (emailError) {
            print('⚠️ AuthService: Email verification failed: $emailError');
          }

          return appUser;
        }
      }

      throw Exception('Signup failed: $e');
    }
  }

  /// Sign in with email and password
  Future<app_user.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 AuthService: Signing in user: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      print('✅ AuthService: Sign-in successful');

      // Get verification status without reloading to avoid PigeonUserDetails error
      final isVerified = user.emailVerified;
      print('📧 AuthService: Email verified: $isVerified');

      if (!isVerified) {
        print('⚠️ AuthService: User email not verified');
        // Optionally send verification email
        try {
          await user.sendEmailVerification();
          print('📧 AuthService: Verification email sent');
        } catch (e) {
          print('⚠️ AuthService: Failed to send verification email: $e');
        }
      }

      return app_user.User(
        id: user.uid,
        email: user.email ?? '',
        isEmailVerified: isVerified,
        createdAt: DateTime.now(), // Use current time to avoid metadata access
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ AuthService: Sign-in failed: ${e.code} - ${e.message}');
      throw Exception('Signin failed: ${e.message}');
    } catch (e) {
      print('❌ AuthService: General sign-in exception: $e');

      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>')) {
        print('🔍 AuthService: Detected PigeonUserDetails error in sign-in');

        // Try to get the current user anyway
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print(
            '✅ AuthService: Sign-in was successful despite PigeonUserDetails error',
          );

          return app_user.User(
            id: currentUser.uid,
            email: currentUser.email ?? email,
            isEmailVerified: currentUser.emailVerified,
            createdAt: DateTime.now(),
          );
        }
      }

      throw Exception('Signin failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final user = currentFirebaseUser;
    if (user == null) {
      print('❌ AuthService: No user is currently signed in');
      throw Exception('No user is currently signed in');
    }

    print('🔍 AuthService: Current user: ${user.uid}');
    print('🔍 AuthService: User email: ${user.email}');
    print('🔍 AuthService: Email verified: ${user.emailVerified}');

    if (user.emailVerified) {
      print('⚠️ AuthService: Email is already verified');
      throw Exception('Email is already verified');
    }

    try {
      print('📧 AuthService: Attempting to send email verification...');
      print('📧 AuthService: User email: ${user.email}');
      print('📧 AuthService: User UID: ${user.uid}');

      await user.sendEmailVerification();
      print('✅ AuthService: Email verification sent successfully!');
      print('✅ AuthService: Check your inbox at ${user.email}');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ AuthService: Firebase auth exception: ${e.code} - ${e.message}');

      // Handle rate limiting
      if (e.code == 'too-many-requests') {
        print(
          '⚠️ AuthService: Rate limited by Firebase. Please wait before trying again.',
        );
        throw Exception(
          'Too many requests. Please wait a few minutes before trying again.',
        );
      }

      throw Exception('Failed to send verification email: ${e.message}');
    } catch (e) {
      print('❌ AuthService: General exception: $e');
      throw Exception('Failed to send verification email: $e');
    }
  }

  /// Check if email is verified (with refresh)
  Future<bool> checkEmailVerificationStatus() async {
    final user = currentFirebaseUser;
    if (user == null) return false;

    try {
      // Reload user to get latest verification status
      await user.reload();
      final refreshedUser = _auth.currentUser;
      return refreshedUser?.emailVerified ?? false;
    } catch (e) {
      print(
        '⚠️ AuthService: Failed to reload user, using cached verification status: $e',
      );
      // If reload fails due to PigeonUserDetails error, use cached status
      return user.emailVerified;
    }
  }

  /// Check if email is verified (cached)
  bool get isEmailVerified => currentFirebaseUser?.emailVerified ?? false;

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  /// Test email verification (for debugging)
  Future<void> testEmailVerification() async {
    final user = currentFirebaseUser;
    if (user == null) {
      print('❌ AuthService: No user signed in for test');
      return;
    }

    print('🧪 AuthService: Testing email verification...');
    print('🧪 AuthService: User: ${user.email}');
    print('🧪 AuthService: UID: ${user.uid}');
    print('🧪 AuthService: Verified: ${user.emailVerified}');

    try {
      print('🧪 AuthService: Sending test verification email...');
      await user.sendEmailVerification();
      print('✅ AuthService: Test email sent successfully!');
    } catch (e) {
      print('❌ AuthService: Test email failed: $e');
    }
  }
}
