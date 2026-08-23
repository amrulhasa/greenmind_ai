import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/services/user_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  bool _isLoggingOut = false;

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await UserService.logout();

      if (!mounted) {
        return;
      }

      context.go('/login');
    } catch (error) {
      debugPrint(
        'ADMIN LOGOUT ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to logout. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final Size size =
        MediaQuery.sizeOf(context);

    final double screenWidth =
        size.width;

    final bool isDesktop =
        screenWidth >= 1000;

    final bool isTablet =
        screenWidth >= 650 &&
        screenWidth < 1000;

    final int crossAxisCount =
        isDesktop
            ? 4
            : isTablet
                ? 3
                : 2;

    return Scaffold(
      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'GreenMind AI Admin',
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,

        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed:
                _isLoggingOut
                    ? null
                    : _logout,
            icon:
                _isLoggingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.logout_rounded,
                      ),
          ),

          const SizedBox(
            width: 8,
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isDesktop
                ? AppSpacing.xl
                : AppSpacing.lg,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1400,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Text(
                    'Admin Dashboard',
                    style:
                        AppTextStyles.heading1,
                  ),

                  const SizedBox(
                    height: AppSpacing.xs,
                  ),

                  Text(
                    'Manage GreenMind AI application data, users and administrative activities.',
                    style:
                        AppTextStyles.subtitle,
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ==================================================
                  // ADMIN ACCESS CARD
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(24),

                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary
                              .withValues(
                        alpha: 0.08,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),

                      border:
                          Border.all(
                        color:
                            AppColors.primary
                                .withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),

                    child: Row(
                      children: [
                        // ADMIN ICON

                        Container(
                          width: 58,
                          height: 58,

                          decoration:
                              const BoxDecoration(
                            color:
                                AppColors.primary,
                            shape:
                                BoxShape.circle,
                          ),

                          child:
                              const Icon(
                            Icons
                                .admin_panel_settings_rounded,
                            color:
                                Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(
                          width: 18,
                        ),

                        // ADMIN TEXT

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                'Administrator Access',
                                style:
                                    AppTextStyles
                                        .heading3,
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                'You are signed in with administrator privileges.',
                                style:
                                    AppTextStyles
                                        .body,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ==================================================
                  // ADMIN MODULES
                  // ==================================================

                  GridView.count(
                    crossAxisCount:
                        crossAxisCount,

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    crossAxisSpacing: 18,

                    mainAxisSpacing: 18,

                    childAspectRatio:
                        isDesktop
                            ? 1.35
                            : 1.15,

                    children: [
                      // ==================================================
                      // USERS
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons
                                .people_alt_rounded,
                        title:
                            'Users',
                        subtitle:
                            'Manage application users',
                        onTap: () {
                          context.push(
                            '/admin/users',
                          );
                        },
                      ),

                      // ==================================================
                      // PLANTS
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons.eco_rounded,
                        title:
                            'Plants',
                        subtitle:
                            'Manage plant data',
                        onTap: () {
                          context.push(
                            '/admin/plants',
                          );
                        },
                      ),

                      // ==================================================
                      // REPORTS
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons
                                .medical_services_rounded,
                        title:
                            'Reports',
                        subtitle:
                            'Review and manage user reports',
                        onTap: () {
                          context.push(
                            '/admin/reports',
                          );
                        },
                      ),

                      // ==================================================
                      // FEEDBACK
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons.feedback_rounded,
                        title:
                            'Feedback',
                        subtitle:
                            'Review and manage user feedback',
                        onTap: () {
                          context.push(
                            '/admin/feedback',
                          );
                        },
                      ),

                      // ==================================================
                      // SUPPORT
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons
                                .support_agent_rounded,
                        title:
                            'Support',
                        subtitle:
                            'Manage support tickets',
                        onTap: () {
                          context.push(
                            '/admin/support',
                          );
                        },
                      ),

                      // ==================================================
                      // ANNOUNCEMENTS
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons
                                .campaign_rounded,
                        title:
                            'Announcements',
                        subtitle:
                            'Create and manage announcements',
                        onTap: () {
                          context.push(
                            '/admin/announcements',
                          );
                        },
                      ),

                      // ==================================================
                      // APP SETTINGS
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons
                                .settings_rounded,
                        title:
                            'App Settings',
                        subtitle:
                            'Manage application settings',
                        onTap: () {
                          context.push(
                            '/admin/settings',
                          );
                        },
                      ),

                      // ==================================================
                      // ADMIN LOGS
                      // ==================================================

                      _AdminCard(
                        icon:
                            Icons
                                .admin_panel_settings_rounded,
                        title:
                            'Admin Logs',
                        subtitle:
                            'Review administrative activity',
                        onTap: () {
                          context.push(
                            '/admin/logs',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ==================================================
                  // FOOTER
                  // ==================================================

                  Center(
                    child: Text(
                      'GreenMind AI • Administration Panel',
                      style:
                          AppTextStyles.subtitle,
                      textAlign:
                          TextAlign.center,
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

// ==================================================================
// ADMIN CARD
// ==================================================================

class _AdminCard
    extends StatelessWidget {
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final ColorScheme colors =
        Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,

      borderRadius:
          BorderRadius.circular(18),

      clipBehavior:
          Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(18),

        child: Container(
          padding:
              const EdgeInsets.all(20),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),

            border:
                Border.all(
              color:
                  Theme.of(context)
                      .dividerColor,
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ICON

              Container(
                width: 52,
                height: 52,

                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.10,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Icon(
                  icon,
                  color:
                      AppColors.primary,
                  size: 28,
                ),
              ),

              const Spacer(),

              // TITLE

              Text(
                title,
                style:
                    AppTextStyles.heading3,
              ),

              const SizedBox(
                height: 5,
              ),

              // SUBTITLE

              Text(
                subtitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    AppTextStyles.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}