import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/user_service.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({
    super.key,
  });

  @override
  ConsumerState<AdminLoginScreen> createState() =>
      _AdminLoginScreenState();
}

class _AdminLoginScreenState
    extends ConsumerState<AdminLoginScreen> {
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

  Future<void> _loginAsAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authServiceProvider).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      final isAdmin = await UserService.isAdmin();

      if (!mounted) {
        return;
      }

      if (!isAdmin) {
        await ref.read(authServiceProvider).logout();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This account does not have administrator access.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      context.go('/admin');
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Unable to sign in as administrator.';

      final errorText = error.toString();

      if (errorText.contains('user-not-found') ||
          errorText.contains('invalid-credential')) {
        message = 'Invalid admin email or password.';
      } else if (errorText.contains('wrong-password')) {
        message = 'Incorrect password.';
      } else if (errorText.contains('invalid-email')) {
        message = 'Please enter a valid email address.';
      } else if (errorText.contains('network-request-failed')) {
        message = 'Please check your internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 52,
                          color: Colors.red,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    Center(
                      child: Text(
                        'Administrator Login',
                        style: AppTextStyles.heading1,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Center(
                      child: Text(
                        'Sign in to access the GreenMind AI Admin Dashboard',
                        style: AppTextStyles.subtitle,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    Text(
                      'Admin Email',
                      style: AppTextStyles.heading3,
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Enter administrator email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                      validator: (value) {
                        final email =
                            value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Please enter your email.';
                        }

                        if (!email.contains('@') ||
                            !email.contains('.')) {
                          return 'Please enter a valid email.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    Text(
                      'Password',
                      style: AppTextStyles.heading3,
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction:
                          TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _loginAsAdmin();
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Enter administrator password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
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
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your password.';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : _loginAsAdmin,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.login_rounded,
                              ),
                        label: Text(
                          _isLoading
                              ? 'Signing In...'
                              : 'Admin Sign In',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          context.go('/login');
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                        ),
                        label: const Text(
                          'Back to User Login',
                        ),
                      ),
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