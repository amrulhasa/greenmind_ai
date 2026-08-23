import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN LOGIC — UNCHANGED
  // ==========================================================

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
            email:
                _emailController.text.trim(),
            password:
                _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      final bool isAdmin =
          await UserService.isAdmin();

      if (!mounted) {
        return;
      }

      if (isAdmin) {
        context.go('/admin');
        return;
      }

      context.go('/home');
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Unable to sign in. Please try again.';

      final errorText =
          error.toString();

      if (errorText.contains(
            'user-not-found',
          ) ||
          errorText.contains(
            'invalid-credential',
          )) {
        message =
            'Invalid email or password.';
      } else if (errorText.contains(
        'wrong-password',
      )) {
        message =
            'Incorrect password.';
      } else if (errorText.contains(
        'invalid-email',
      )) {
        message =
            'Please enter a valid email address.';
      } else if (errorText.contains(
        'network-request-failed',
      )) {
        message =
            'Please check your internet connection.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
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

  // ==========================================================
  // FORGOT PASSWORD LOGIC — UNCHANGED
  // ==========================================================

  Future<void> _forgotPassword() async {
    final emailController =
        TextEditingController(
      text:
          _emailController.text.trim(),
    );

    final shouldSend =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Reset Password'),
          content: TextField(
            controller:
                emailController,
            keyboardType:
                TextInputType.emailAddress,
            enableSuggestions:
                false,
            autocorrect: false,
            decoration:
                const InputDecoration(
              labelText: 'Email',
              hintText:
                  'Enter your account email',
              prefixIcon:
                  Icon(
                Icons.email_outlined,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
                  const Text('Send'),
            ),
          ],
        );
      },
    );

    final email =
        emailController.text.trim();

    emailController.dispose();

    if (shouldSend != true) {
      return;
    }

    if (email.isEmpty ||
        !email.contains('@') ||
        !email.contains('.')) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid email address.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(
            email: email,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your inbox.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Unable to send password reset email.';

      final errorText =
          error.toString();

      if (errorText.contains(
        'user-not-found',
      )) {
        message =
            'No account found with this email.';
      } else if (errorText.contains(
        'invalid-email',
      )) {
        message =
            'Please enter a valid email address.';
      } else if (errorText.contains(
        'network-request-failed',
      )) {
        message =
            'Please check your internet connection.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide(
          color:
              Colors.grey.shade300,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide(
          color:
              Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color:
              AppColors.primary,
          width: 1.8,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  // ==========================================================
  // BRAND PANEL
  // ==========================================================

  Widget _buildBrandPanel() {
    return Container(
      width: 390,
      padding:
          const EdgeInsets.all(44),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary
                .withValues(alpha: 0.82),
          ],
        ),
        borderRadius:
            BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 210,
              height: 210,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color: Colors.white
                    .withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 230,
              height: 230,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color: Colors.white
                    .withValues(
                  alpha: 0.06,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.16,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(
                height: 34,
              ),
              const Text(
                'GreenMind AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                'Smart plant care powered by artificial intelligence.',
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.88,
                  ),
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
              const SizedBox(
                height: 38,
              ),
              _brandFeature(
                Icons
                    .center_focus_strong_rounded,
                'AI-powered plant identification',
              ),
              const SizedBox(
                height: 18,
              ),
              _brandFeature(
                Icons
                    .health_and_safety_outlined,
                'Intelligent plant health insights',
              ),
              const SizedBox(
                height: 18,
              ),
              _brandFeature(
                Icons
                    .notifications_none_rounded,
                'Personalized care reminders',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _brandFeature(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              BoxDecoration(
            color: Colors.white
                .withValues(
              alpha: 0.13,
            ),
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white
                  .withValues(
                alpha: 0.9,
              ),
              fontSize: 14,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOGIN FORM
  // ==========================================================

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // Logo
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration:
                  BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 38,
                color:
                    AppColors.primary,
              ),
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          Center(
            child: Text(
              'Welcome back',
              style:
                  AppTextStyles.heading1
                      .copyWith(
                fontSize: 31,
                fontWeight:
                    FontWeight.w700,
                letterSpacing: -0.7,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Center(
            child: Text(
              'Sign in to continue to GreenMind AI',
              style:
                  AppTextStyles.subtitle
                      .copyWith(
                height: 1.45,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(
            height: 34,
          ),

          Text(
            'Email address',
            style:
                AppTextStyles.heading3
                    .copyWith(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          TextFormField(
            controller:
                _emailController,
            keyboardType:
                TextInputType.emailAddress,
            textInputAction:
                TextInputAction.next,
            enableSuggestions:
                false,
            autocorrect: false,
            decoration:
                _inputDecoration(
              hint:
                  'Enter your email',
              icon:
                  Icons.email_outlined,
            ),
            validator:
                (value) {
              final email =
                  value?.trim() ??
                      '';

              if (email.isEmpty) {
                return 'Please enter your email.';
              }

              if (!email.contains(
                      '@') ||
                  !email.contains(
                      '.')) {
                return 'Please enter a valid email.';
              }

              return null;
            },
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            'Password',
            style:
                AppTextStyles.heading3
                    .copyWith(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          TextFormField(
            controller:
                _passwordController,
            obscureText:
                _obscurePassword,
            enableSuggestions:
                false,
            autocorrect: false,
            textInputAction:
                TextInputAction.done,
            onFieldSubmitted:
                (_) {
              if (!_isLoading) {
                _login();
              }
            },
            decoration:
                _inputDecoration(
              hint:
                  'Enter your password',
              icon:
                  Icons.lock_outline_rounded,
              suffixIcon:
                  IconButton(
                tooltip:
                    _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscurePassword =
                        !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons
                          .visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),
            validator:
                (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Please enter your password.';
              }

              if (value.length <
                  6) {
                return 'Password must be at least 6 characters.';
              }

              return null;
            },
          ),

          const SizedBox(
            height: 8,
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : _forgotPassword,
              style:
                  TextButton.styleFrom(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
              child:
                  const Text(
                'Forgot password?',
              ),
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 54,
            child:
                ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : _login,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              child:
                  AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                child: _isLoading
                    ? const SizedBox(
                        key: ValueKey(
                          'loading',
                        ),
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        key: ValueKey(
                          'signin',
                        ),
                        style:
                            TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          Row(
            children: [
              Expanded(
                child: Divider(
                  color:
                      Colors.grey.shade300,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                ),
                child: Text(
                  'NEW TO GREENMIND?',
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color:
                      Colors.grey.shade300,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            width:
                double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                context.push(
                  '/register',
                );
              },
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary
                      .withValues(
                    alpha: 0.35,
                  ),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
              ),
              child:
                  const Text(
                'Create an account',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Center(
            child:
                TextButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                          context.go(
                            '/admin',
                          );
                        },
              icon: const Icon(
                Icons
                    .admin_panel_settings_outlined,
                size: 18,
              ),
              label:
                  const Text(
                'Administrator Login',
              ),
              style:
                  TextButton.styleFrom(
                foregroundColor:
                    Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F8F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) {
            final bool isDesktop =
                constraints.maxWidth >=
                    900;

            if (isDesktop) {
              return Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1080,
                    maxHeight: 720,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(14),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                        34,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha: 0.07,
                          ),
                          blurRadius: 45,
                          offset:
                              const Offset(
                            0,
                            18,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child:
                              _buildBrandPanel(),
                        ),
                        Expanded(
                          flex: 6,
                          child:
                              SingleChildScrollView(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 56,
                              vertical: 28,
                            ),
                            child:
                                _buildLoginForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Center(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child:
                      _buildLoginForm(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}