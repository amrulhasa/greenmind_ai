import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // REGISTER LOGIC — UNCHANGED
  // ==========================================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authServiceProvider)
          .register(
            name:
                _nameController.text.trim(),
            email:
                _emailController.text.trim(),
            password:
                _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      context.go('/home');
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          'Unable to create your account.';

      final errorText =
          error.toString();

      if (errorText.contains(
        'email-already-in-use',
      )) {
        message =
            'An account already exists with this email.';
      } else if (errorText.contains(
        'invalid-email',
      )) {
        message =
            'Please enter a valid email address.';
      } else if (errorText.contains(
        'weak-password',
      )) {
        message =
            'Password is too weak. Use at least 6 characters.';
      } else if (errorText.contains(
        'network-request-failed',
      )) {
        message =
            'Please check your internet connection.';
      } else if (errorText.contains(
        'permission-denied',
      )) {
        message =
            'Account created, but profile setup was blocked. Please check Firebase permissions.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(message),
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
  // INPUT DECORATION
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
      suffixIcon:
          suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      border:
          OutlineInputBorder(
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
        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
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
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary
                .withValues(
              alpha: 0.82,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          32,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
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
            left: -90,
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
                child:
                    const Icon(
                  Icons.eco_rounded,
                  color:
                      Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(
                height: 34,
              ),

              const Text(
                'Grow smarter.',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize: 31,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing:
                      -0.7,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Care better.',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize: 31,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing:
                      -0.7,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                'Create your GreenMind AI account and make every plant care decision smarter.',
                style:
                    TextStyle(
                  color: Colors
                      .white
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

              _feature(
                Icons
                    .center_focus_strong_rounded,
                'Identify plants instantly',
              ),

              const SizedBox(
                height: 18,
              ),

              _feature(
                Icons
                    .health_and_safety_outlined,
                'Understand plant health',
              ),

              const SizedBox(
                height: 18,
              ),

              _feature(
                Icons
                    .tips_and_updates_outlined,
                'Get intelligent care guidance',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feature(
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
            color:
                Colors.white,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            text,
            style:
                TextStyle(
              color: Colors
                  .white
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
  // FIELD LABEL
  // ==========================================================

  Widget _label(
    String text,
  ) {
    return Text(
      text,
      style:
          AppTextStyles.heading3
              .copyWith(
        fontSize: 15,
        fontWeight:
            FontWeight.w600,
      ),
    );
  }

  // ==========================================================
  // REGISTER FORM
  // ==========================================================

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
                border: Border.all(
                  color: AppColors
                      .primary
                      .withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child:
                  const Icon(
                Icons.eco_rounded,
                size: 38,
                color:
                    AppColors.primary,
              ),
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          Center(
            child: Text(
              'Create your account',
              style:
                  AppTextStyles.heading1
                      .copyWith(
                fontSize: 30,
                fontWeight:
                    FontWeight.w700,
                letterSpacing:
                    -0.7,
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
              'Join GreenMind AI and care for your plants smarter',
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
            height: 30,
          ),

          // ==================================================
          // NAME
          // ==================================================

          _label('Full name'),

          const SizedBox(
            height: 9,
          ),

          TextFormField(
            controller:
                _nameController,
            textInputAction:
                TextInputAction.next,
            autofillHints:
                const [
              AutofillHints.name,
            ],
            decoration:
                _inputDecoration(
              hint:
                  'Enter your name',
              icon:
                  Icons.person_outline_rounded,
            ),
            validator:
                (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter your name.';
              }

              return null;
            },
          ),

          const SizedBox(
            height: 18,
          ),

          // ==================================================
          // EMAIL
          // ==================================================

          _label('Email address'),

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
            autofillHints:
                const [
              AutofillHints.email,
            ],
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
            height: 18,
          ),

          // ==================================================
          // PASSWORD
          // ==================================================

          _label('Password'),

          const SizedBox(
            height: 9,
          ),

          TextFormField(
            controller:
                _passwordController,
            obscureText:
                _obscurePassword,
            textInputAction:
                TextInputAction.next,
            autofillHints:
                const [
              AutofillHints
                  .newPassword,
            ],
            decoration:
                _inputDecoration(
              hint:
                  'Create a password',
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
                return 'Please enter a password.';
              }

              if (value.length <
                  6) {
                return 'Password must be at least 6 characters.';
              }

              return null;
            },
          ),

          const SizedBox(
            height: 18,
          ),

          // ==================================================
          // CONFIRM PASSWORD
          // ==================================================

          _label('Confirm password'),

          const SizedBox(
            height: 9,
          ),

          TextFormField(
            controller:
                _confirmPasswordController,
            obscureText:
                _obscureConfirmPassword,
            textInputAction:
                TextInputAction.done,
            autofillHints:
                const [
              AutofillHints
                  .newPassword,
            ],
            onFieldSubmitted:
                (_) {
              if (!_isLoading) {
                _register();
              }
            },
            decoration:
                _inputDecoration(
              hint:
                  'Confirm your password',
              icon:
                  Icons.lock_outline_rounded,
              suffixIcon:
                  IconButton(
                tooltip:
                    _obscureConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
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
                return 'Please confirm your password.';
              }

              if (value !=
                  _passwordController
                      .text) {
                return 'Passwords do not match.';
              }

              return null;
            },
          ),

          const SizedBox(
            height: 26,
          ),

          // ==================================================
          // CREATE ACCOUNT
          // ==================================================

          SizedBox(
            width:
                double.infinity,
            height: 54,
            child:
                ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : _register,
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
                        'Create Account',
                        key: ValueKey(
                          'create',
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
                  'ALREADY A MEMBER?',
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing:
                        1.1,
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
                context.pop();
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
                'Sign In',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
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
                    maxHeight: 760,
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
                              vertical: 26,
                            ),
                            child:
                                _buildRegisterForm(),
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
                  vertical: 26,
                ),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child:
                      _buildRegisterForm(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}