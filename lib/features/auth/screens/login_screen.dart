import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles Firebase email/password login.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authServiceProvider)
          .login(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (!mounted) return;

      context.go('/home');
    } on Exception catch (error) {
      if (!mounted) return;

      String message = 'Unable to sign in. Please try again.';

      final errorText = error.toString();

      if (errorText.contains('user-not-found') ||
          errorText.contains('invalid-credential')) {
        message = 'Invalid email or password.';
      } else if (errorText.contains('wrong-password')) {
        message = 'Incorrect password.';
      } else if (errorText.contains('invalid-email')) {
        message = 'Please enter a valid email address.';
      } else if (errorText.contains('network-request-failed')) {
        message = 'Please check your internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sends a Firebase password reset email.
  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your account email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    final email = emailController.text.trim();

    emailController.dispose();

    if (shouldSend != true) {
      return;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;

      String message = 'Unable to send password reset email.';

      final errorText = error.toString();

      if (errorText.contains('user-not-found')) {
        message = 'No account found with this email.';
      } else if (errorText.contains('invalid-email')) {
        message = 'Please enter a valid email address.';
      } else if (errorText.contains('network-request-failed')) {
        message = 'Please check your internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Center(
                      child: Text(
                        'Welcome Back',
                        style: AppTextStyles.heading1,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Center(
                      child: Text(
                        'Sign in to continue to GreenMind AI',
                        style: AppTextStyles.subtitle,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text('Email', style: AppTextStyles.heading3),

                    const SizedBox(height: AppSpacing.xs),

                    // Email field without browser autofill.
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Please enter your email.';
                        }

                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Please enter a valid email.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text('Password', style: AppTextStyles.heading3),

                    const SizedBox(height: AppSpacing.xs),

                    // Password field without browser autofill.
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.body,
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/register');
                          },
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
