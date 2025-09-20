import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/glassmorphism_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../viewmodel/auth_provider.dart';

/// ForgotPasswordScreen widget for password reset
///
/// This widget provides a clean and modern password reset interface with:
/// - Email input field for password reset
/// - Form validation using core validators
/// - Beautiful UI matching the app theme
/// - Navigation back to login screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controller for email field
  final _emailController = TextEditingController();

  // State to track if reset email was sent
  bool _resetEmailSent = false;

  @override
  void dispose() {
    // Dispose controller to prevent memory leaks
    _emailController.dispose();
    super.dispose();
  }

  /// Handles password reset form submission
  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (success) {
      // Show success message and update UI
      if (mounted) {
        setState(() {
          _resetEmailSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send reset email'),
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

                  // Floating Reset Icon
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
                      child: Icon(
                        _resetEmailSent
                            ? Icons.mark_email_read_rounded
                            : Icons.lock_reset_rounded,
                        size: 44,
                        color: const Color(0xFF2196F3),
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
                          _resetEmailSent
                              ? 'Check Your Email'
                              : 'Forgot Password?',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppDimensions.spacing8),

                        // Subtitle
                        Text(
                          _resetEmailSent
                              ? 'We\'ve sent a password reset link to your email address'
                              : 'Enter your email address and we\'ll send you a link to reset your password',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        if (!_resetEmailSent) ...[
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

                          const SizedBox(height: AppDimensions.spacing32),

                          // Reset Password Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handlePasswordReset,
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
                                          'Send Reset Link',
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
                        ],

                        if (_resetEmailSent) ...[
                          const SizedBox(height: AppDimensions.spacing32),

                          // Resend Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _resetEmailSent = false;
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF2196F3),
                                    side: const BorderSide(
                                      color: Color(0xFF2196F3),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Send Another Email',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: const Color(0xFF2196F3),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: AppDimensions.spacing20),

                        // Back to Login Link
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Back to Sign In',
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
