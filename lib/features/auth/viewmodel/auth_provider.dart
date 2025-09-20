import 'package:flutter/foundation.dart';
import '../../../services/auth_service.dart';
import '../../../services/test_auth_service.dart';
import '../models/user.dart' as app_user;

/// Simple AuthProvider using ChangeNotifier
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TestAuthService _testAuthService = TestAuthService();

  app_user.User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.isEmailVerified ?? false;

  /// Initialize auth provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _user = _authService.currentUser;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({required String email, required String password}) async {
    _setLoading(true);
    try {
      print('🔄 AuthProvider: Starting sign-up for $email');

      // First try the test service to isolate the issue
      final testResult = await _testAuthService.testSignUp(
        email: email,
        password: password,
      );

      if (!testResult) {
        print('❌ AuthProvider: Test sign-up failed');
        _setError('Test sign-up failed');
        return false;
      }

      // If test succeeds, try the full service
      _user = await _authService.signUp(email: email, password: password);
      print('✅ AuthProvider: Sign-up successful for $email');
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ AuthProvider: Sign-up failed: $e');
      _setError('Signup failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      _user = await _authService.signIn(email: email, password: password);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Signin failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Signout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      _clearError();
    } catch (e) {
      _setError('Failed to send verification email: $e');
    }
  }

  /// Check email verification status
  Future<bool> checkEmailVerificationStatus() async {
    try {
      // Use the new method that reloads user data
      return await _authService.checkEmailVerificationStatus();
    } catch (e) {
      _setError('Failed to check verification status: $e');
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email: email);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to reset password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend email verification
  Future<bool> resendEmailVerification() async {
    _setLoading(true);
    try {
      await _authService.sendEmailVerification();
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to resend verification email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
