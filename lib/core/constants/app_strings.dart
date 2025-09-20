/// App string constants
///
/// This file contains all the text strings used throughout the app.
/// This makes it easy to maintain consistent text and update strings globally.
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // App Info
  static const String appName = 'Optimizer';
  static const String appTagline = 'Optimize Your Performance';
  static const String appDescription = 'Join Optimizer to get started';

  // Splash Screen
  static const String splashTitle = 'OPTIMIZER';
  static const String splashSubtitle = 'Optimize Your Performance';

  // Auth Screen
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signUp = 'Sign Up';

  // Form Fields
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String enterEmail = 'Enter your email';
  static const String enterPassword = 'Enter your password';
  static const String confirmYourPassword = 'Confirm your password';

  // Validation Messages
  static const String pleaseEnterEmail = 'Please enter your email';
  static const String pleaseEnterValidEmail = 'Please enter a valid email';
  static const String pleaseEnterPassword = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String pleaseConfirmPassword = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // Success Messages
  static const String accountCreatedSuccessfully =
      'Account created successfully!';
  static const String loginSuccessful = 'Login successful!';

  // Error Messages
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String networkError =
      'Network error. Please check your connection.';

  // Buttons
  static const String createAccountButton = 'Create Account';
  static const String signInButton = 'Sign In';
  static const String continueButton = 'Continue';
  static const String cancelButton = 'Cancel';
  static const String saveButton = 'Save';
  static const String deleteButton = 'Delete';
}
