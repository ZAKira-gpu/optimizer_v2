import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/glassmorphism_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../viewmodel/auth_provider.dart';

/// SignupScreen widget for user registration
///
/// This widget provides a clean and modern signup interface with:
/// - Email and password input fields
/// - Form validation using core validators
/// - Beautiful UI matching the app theme
/// - Navigation to login screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password visibility toggle
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles signup form submission
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();

    print('🔄 SignupScreen: Starting sign-up process for $email');

    final success = await authProvider.signUp(
      email: email,
      password: _passwordController.text,
    );

    print('📊 SignupScreen: Sign-up result: $success');

    if (success) {
      print('✅ SignupScreen: Navigating to email verification screen');
      // Navigate to email verification screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verifyEmail,
          arguments: email,
        );
      }
    } else {
      print('❌ SignupScreen: Sign-up failed, showing error');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Signup failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.spacing40),

                  // Floating User Icon
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 44,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Glassmorphism Form Container
                  GlassmorphismContainer(
                    borderRadius: 25.0,
                    blur: 15.0,
                    opacity: 0.15,
                    borderColor: Colors.white,
                    borderWidth: 1.5,
                    padding: const EdgeInsets.all(AppDimensions.spacing32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppDimensions.spacing32),

                        // Email Field
                        GlassmorphismInputField(
                          borderRadius: 15.0,
                          blur: 8.0,
                          opacity: 0.1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing16,
                            vertical: AppDimensions.spacing8,
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                              prefixIcon: Icon(
                                Icons.alternate_email_rounded,
                                color: const Color(0xFF2196F3),
                                size: 24,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacing12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacing20),

                        // Password Field
                        GlassmorphismInputField(
                          borderRadius: 15.0,
                          blur: 8.0,
                          opacity: 0.1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing16,
                            vertical: AppDimensions.spacing8,
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            obscureText: !_isPasswordVisible,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                              prefixIcon: Icon(
                                Icons.password_rounded,
                                color: const Color(0xFF2196F3),
                                size: 24,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: const Color(0xFF2196F3),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacing12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacing20),

                        // Confirm Password Field
                        GlassmorphismInputField(
                          borderRadius: 15.0,
                          blur: 8.0,
                          opacity: 0.1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing16,
                            vertical: AppDimensions.spacing8,
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) =>
                                Validators.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                            obscureText: !_isConfirmPasswordVisible,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.w400,
                                  ),
                              prefixIcon: Icon(
                                Icons.key_rounded,
                                color: const Color(0xFF2196F3),
                                size: 24,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: const Color(0xFF2196F3),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacing12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacing32),

                        // Signup Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleSignup,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Create Account',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.1,
                                            ),
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppDimensions.spacing20),

                        // Login Link
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Already have an account? Sign In',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white.withOpacity(
                                    0.6,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
