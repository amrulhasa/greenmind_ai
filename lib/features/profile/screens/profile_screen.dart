import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/services/auth_service.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  // ============================================================
  // GO HOME
  // ============================================================

  void _goHome(BuildContext context) {
    context.go('/home');
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final profile = ref.read(profileProvider).profile;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _EditProfileDialog(
          profile: profile,

          onSave: ({
            required String name,
            required String email,
            required String location,
            required String bio,
          }) async {
            await ref
                .read(profileProvider.notifier)
                .updateProfile(
                  name: name,
                  email: email,
                  location: location,
                  bio: bio,
                );
          },
        );
      },
    );
  }

  // ============================================================
  // RESET PROFILE
  // ============================================================

  Future<void> _confirmReset(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldReset = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Profile?'),

          content: const Text(
            'Your profile information will be restored '
            'to the default values.',
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
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await ref
          .read(profileProvider.notifier)
          .resetProfile();
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(
    BuildContext context,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out?'),

          content: const Text(
            'Are you sure you want to sign out '
            'of GreenMind AI?',
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
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await AuthService().logout();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to sign out. Please try again.',
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(profileProvider);

    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (
        bool didPop,
        Object? result,
      ) {
        if (didPop) {
          return;
        }

        _goHome(context);
      },

      child: Scaffold(
        // ========================================================
        // APP BAR
        // ========================================================

        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _goHome(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            tooltip: 'Back',
          ),

          title: Text(
            'Profile',
            style: AppTextStyles.heading3,
          ),

          actions: [
            IconButton(
              tooltip: 'Edit profile',

              onPressed: state.isLoading
                  ? null
                  : () {
                      _editProfile(
                        context,
                        ref,
                      );
                    },

              icon: const Icon(
                Icons.edit_outlined,
              ),
            ),
          ],
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.errorMessage != null
                ? _ErrorState(
                    message: state.errorMessage!,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      AppSpacing.md,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const ProfileHeader(),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        ProfileInfoCard(
                          profile: state.profile,
                        ),

                        const SizedBox(
                          height: AppSpacing.lg,
                        ),

                        Text(
                          'Settings',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        // ==================================================
                        // NOTIFICATIONS
                        // ==================================================

                        SettingsTile(
                          icon:
                              Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle:
                              'Manage plant care notifications',

                          trailing: Switch(
                            value: state.profile
                                .notificationsEnabled,

                            onChanged: (bool value) {
                              ref
                                  .read(
                                    profileProvider
                                        .notifier,
                                  )
                                  .toggleNotifications();
                            },

                            activeThumbColor:
                                AppColors.primary,
                          ),
                        ),

                        // ==================================================
                        // DARK MODE
                        // ==================================================

                        SettingsTile(
                          icon:
                              Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle:
                              'Save your preferred theme',

                          trailing: Switch(
                            value: state.profile
                                .darkModeEnabled,

                            onChanged: (bool value) {
                              ref
                                  .read(
                                    profileProvider
                                        .notifier,
                                  )
                                  .toggleDarkMode();
                            },

                            activeThumbColor:
                                AppColors.primary,
                          ),
                        ),

                        // ==================================================
                        // ABOUT
                        // ==================================================

                        SettingsTile(
                          icon:
                              Icons.info_outline_rounded,
                          title: 'About GreenMind AI',
                          subtitle:
                              'AI-powered plant care assistant',

                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),

                        // ==================================================
                        // RESET
                        // ==================================================

                        SettingsTile(
                          icon:
                              Icons.refresh_rounded,
                          title: 'Reset Profile',
                          subtitle:
                              'Restore default profile data',

                          onTap: () {
                            _confirmReset(
                              context,
                              ref,
                            );
                          },
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        // ==================================================
                        // SIGN OUT
                        // ==================================================

                        SettingsTile(
                          icon:
                              Icons.logout_rounded,
                          title: 'Sign Out',
                          subtitle:
                              'Sign out from your GreenMind AI account',

                          onTap: () {
                            _logout(context);
                          },
                        ),

                        const SizedBox(
                          height: AppSpacing.lg,
                        ),

                        // ==================================================
                        // VERSION
                        // ==================================================

                        Center(
                          child: Text(
                            'GreenMind AI • Version 1.0.0',
                            style:
                                AppTextStyles.caption.copyWith(
                              color:
                                  AppColors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  // ABOUT DIALOG
  // ============================================================

  void _showAboutDialog(
    BuildContext context,
  ) {
    showAboutDialog(
      context: context,

      applicationName:
          'GreenMind AI',

      applicationVersion:
          '1.0.0',

      applicationIcon: const Icon(
        Icons.eco_rounded,
        color: AppColors.primary,
        size: 36,
      ),

      children: const [
        Text(
          'GreenMind AI is an AI-powered plant '
          'identification and smart plant care assistant.',
        ),
      ],
    );
  }
}

// ============================================================
// EDIT PROFILE DIALOG
// ============================================================

class _EditProfileDialog
    extends StatefulWidget {
  final UserProfile profile;

  final Future<void> Function({
    required String name,
    required String email,
    required String location,
    required String bio,
  }) onSave;

  const _EditProfileDialog({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_EditProfileDialog> createState() =>
      _EditProfileDialogState();
}

class _EditProfileDialogState
    extends State<_EditProfileDialog> {
  late final TextEditingController
      _nameController;

  late final TextEditingController
      _emailController;

  late final TextEditingController
      _locationController;

  late final TextEditingController
      _bioController;

  bool _isSaving = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.profile.name,
    );

    _emailController =
        TextEditingController(
      text: widget.profile.email,
    );

    _locationController =
        TextEditingController(
      text: widget.profile.location,
    );

    _bioController =
        TextEditingController(
      text: widget.profile.bio,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        location:
            _locationController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update profile. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: const Text(
        'Edit Profile',
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: _nameController,
              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: _emailController,
              keyboardType:
                  TextInputType.emailAddress,
              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: _locationController,
              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            TextField(
              controller: _bioController,
              maxLines: 2,
              textInputAction:
                  TextInputAction.done,

              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(
                  Icons.info_outline_rounded,
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },

          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton(
          onPressed:
              _isSaving ? null : _save,

          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,

                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save',
                ),
        ),
      ],
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState
    extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.error,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            Text(
              message,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}