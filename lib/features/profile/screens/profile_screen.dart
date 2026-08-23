import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_spacing.dart';
import '../../auth/services/auth_service.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    // ==========================================================
    // LOADING
    // ==========================================================

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ==========================================================
    // THEME
    // ==========================================================

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ==========================================================
    // SCREEN
    // ==========================================================

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          tooltip: 'Back',
        ),
        title: const Text(
          'Profile',
        ),
        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          onRefresh: notifier.reloadProfile,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // PROFILE HEADER
                // ==================================================

                ProfileHeader(
                  profile: state.profile,
                  onEditPhoto: () {
                    _showPhotoOptions(
                      context,
                      ref,
                    );
                  },
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ==================================================
                // PERSONAL INFORMATION
                // ==================================================

                ProfileInfoCard(
                  profile: state.profile,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                // ==================================================
                // EDIT PROFILE
                // ==================================================

                _EditProfileButton(
                  onPressed: () async {
                    await _showEditProfileDialog(
                      context,
                      ref,
                    );
                  },
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                // ==================================================
                // PREFERENCES
                // ==================================================

                _PreferencesCard(
                  state: state,
                  notifier: notifier,
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                // ==================================================
                // ACCOUNT
                // ==================================================

                _AccountCard(
                  onReset: () {
                    _showResetDialog(
                      context,
                      ref,
                    );
                  },
                  onFeedback: () {
                    context.push('/feedback');
                  },
                  onSupport: () {
                    context.push('/support');
                  },
                  onSignOut: () {
                    _signOut(context);
                  },
                ),

                // ==================================================
                // ERROR
                // ==================================================

                if (state.errorMessage != null) ...[
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _ErrorMessage(
                    message: state.errorMessage!,
                  ),
                ],

                const SizedBox(
                  height: AppSpacing.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PHOTO OPTIONS
  // ============================================================

  static void _showPhotoOptions(
    BuildContext context,
    WidgetRef ref,
  ) {
    final notifier =
        ref.read(profileProvider.notifier);

    final profile =
        ref.read(profileProvider).profile;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme =
            Theme.of(sheetContext);

        final colorScheme =
            theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.photo_camera_back_outlined,
                  ),
                  title: Text(
                    'Profile Photo',
                  ),
                  subtitle: Text(
                    'Choose how you want to update your photo',
                  ),
                ),

                const Divider(
                  height: 1,
                ),

                // ==================================================
                // CAMERA
                // ==================================================

                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text(
                    'Camera',
                  ),
                  subtitle: const Text(
                    'Take a new photo',
                  ),
                  onTap: () async {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    await notifier.changeProfilePicture(
                      source:
                          ImageSource.camera,
                    );
                  },
                ),

                // ==================================================
                // GALLERY
                // ==================================================

                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text(
                    'Gallery',
                  ),
                  subtitle: const Text(
                    'Choose an existing photo',
                  ),
                  onTap: () async {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    await notifier.changeProfilePicture(
                      source:
                          ImageSource.gallery,
                    );
                  },
                ),

                // ==================================================
                // REMOVE PHOTO
                // ==================================================

                if (profile.profileImagePath != null &&
                    profile.profileImagePath!.isNotEmpty)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                    ),
                    title: Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: colorScheme.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Delete your current profile photo',
                    ),
                    onTap: () async {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      await notifier
                          .removeProfilePicture();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  static Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final profile =
        ref.read(profileProvider).profile;

    final result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditProfileDialog(
          profile: profile,
          onSave: ({
            required String name,
            required String location,
            required String phone,
            required String bio,
          }) async {
            await ref
                .read(profileProvider.notifier)
                .updateProfile(
                  name: name,
                  location: location,
                  phone: phone,
                  bio: bio,
                );

            final updatedState =
                ref.read(profileProvider);

            return updatedState.errorMessage ==
                null;
          },
        );
      },
    );

    if (result == true &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            'Profile updated successfully.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // RESET PROFILE
  // ============================================================

  static Future<void> _showResetDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.restart_alt_rounded,
          ),
          title: const Text(
            'Reset Profile Data?',
          ),
          content: const Text(
            'Your account will remain active. '
            'Only your editable profile information '
            'will be reset.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Reset',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(profileProvider.notifier)
        .resetProfileData();

    final state =
        ref.read(profileProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            state.errorMessage ??
                'Profile data reset successfully.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  static Future<void> _signOut(
    BuildContext context,
  ) async {
    try {
      await AuthService().logout();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior:
                SnackBarBehavior.floating,
            content: Text(
              'Unable to sign out. Please try again.',
            ),
          ),
        );
      }
    }
  }
}

// ============================================================================
// EDIT PROFILE DIALOG
// ============================================================================

class _EditProfileDialog
    extends StatefulWidget {
  final UserProfile profile;

  final Future<bool> Function({
    required String name,
    required String location,
    required String phone,
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

// ============================================================================
// EDIT PROFILE DIALOG STATE
// ============================================================================

class _EditProfileDialogState
    extends State<_EditProfileDialog> {
  late final TextEditingController
      _nameController;

  late final TextEditingController
      _emailController;

  late final TextEditingController
      _locationController;

  late final TextEditingController
      _phoneController;

  late final TextEditingController
      _bioController;

  bool _saving = false;

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

    _phoneController =
        TextEditingController(
      text: widget.profile.phone,
    );

    _bioController =
        TextEditingController(
      text: widget.profile.bio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final name =
        _nameController.text.trim();

    final location =
        _locationController.text.trim();

    final phone =
        _phoneController.text.trim();

    final bio =
        _bioController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (name.isEmpty) {
      _showMessage(
        'Please enter your full name.',
      );
      return;
    }

    if (name.length < 2) {
      _showMessage(
        'Name must contain at least 2 characters.',
      );
      return;
    }

    if (phone.isNotEmpty &&
        phone.length < 7) {
      _showMessage(
        'Please enter a valid phone number.',
      );
      return;
    }

    // ==========================================================
    // START SAVING
    // ==========================================================

    setState(() {
      _saving = true;
    });

    try {
      final success =
          await widget.onSave(
        name: name,
        location: location,
        phone: phone,
        bio: bio,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        setState(() {
          _saving = false;
        });

        _showMessage(
          'Unable to update profile. Please try again.',
        );

        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled && !_saving,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization:
          textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon),
      ),
    );
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
          mainAxisSize:
              MainAxisSize.min,
          children: [
            // ==================================================
            // NAME
            // ==================================================

            _buildField(
              label: 'Full Name',
              controller:
                  _nameController,
              icon:
                  Icons.person_outline_rounded,
              textCapitalization:
                  TextCapitalization.words,
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // EMAIL
            // ==================================================

            _buildField(
              label: 'Email',
              controller:
                  _emailController,
              icon:
                  Icons.email_outlined,
              enabled: false,
              keyboardType:
                  TextInputType.emailAddress,
              helperText:
                  'Linked to your account',
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // LOCATION
            // ==================================================

            _buildField(
              label: 'Location',
              controller:
                  _locationController,
              icon:
                  Icons.location_on_outlined,
              textCapitalization:
                  TextCapitalization.words,
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // PHONE
            // ==================================================

            _buildField(
              label: 'Phone Number',
              controller:
                  _phoneController,
              icon:
                  Icons.phone_outlined,
              keyboardType:
                  TextInputType.phone,
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // BIO
            // ==================================================

            _buildField(
              label: 'Bio',
              controller:
                  _bioController,
              icon:
                  Icons.info_outline_rounded,
              maxLines: 3,
              maxLength: 150,
              textCapitalization:
                  TextCapitalization.sentences,
            ),
          ],
        ),
      ),

      // ========================================================
      // ACTIONS
      // ========================================================

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pop(false);
                },
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton.icon(
          onPressed:
              _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.check_rounded,
                ),
          label: Text(
            _saving
                ? 'Saving...'
                : 'Save',
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EDIT PROFILE BUTTON
// ============================================================================

class _EditProfileButton
    extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditProfileButton({
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.edit_outlined,
        ),
        label: const Text(
          'Edit Profile',
        ),
      ),
    );
  }
}

// ============================================================================
// PREFERENCES CARD
// ============================================================================

class _PreferencesCard
    extends StatelessWidget {
  final ProfileState state;
  final ProfileNotifier notifier;

  const _PreferencesCard({
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              12,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme
                        .primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .settings_outlined,
                    color: colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        'Customize your GreenMind AI experience',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
          ),

          // ====================================================
          // NOTIFICATIONS
          // ====================================================

          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            value: state
                .profile
                .notificationsEnabled,
            onChanged: (_) {
              notifier.toggleNotifications();
            },
            secondary: Icon(
              Icons
                  .notifications_none_rounded,
              color: colorScheme.primary,
            ),
            title: const Text(
              'Notifications',
            ),
            subtitle: const Text(
              'Receive plant care reminders and updates',
            ),
          ),

          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),

          // ====================================================
          // DARK MODE
          // ====================================================

          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            value: state
                .profile
                .darkModeEnabled,
            onChanged: (_) {
              notifier.toggleDarkMode();
            },
            secondary: AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 250,
              ),
              child: Icon(
                state.profile.darkModeEnabled
                    ? Icons
                        .dark_mode_rounded
                    : Icons
                        .light_mode_outlined,
                key: ValueKey(
                  state.profile
                      .darkModeEnabled,
                ),
                color: colorScheme.primary,
              ),
            ),
            title: const Text(
              'Dark Mode',
            ),
            subtitle: Text(
              state.profile.darkModeEnabled
                  ? 'Dark appearance is enabled'
                  : 'Use a comfortable dark appearance',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACCOUNT CARD
// ============================================================================

class _AccountCard
    extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onFeedback;
  final VoidCallback onSupport;
  final VoidCallback onSignOut;

  const _AccountCard({
    required this.onReset,
    required this.onFeedback,
    required this.onSupport,
    required this.onSignOut,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              12,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme
                        .secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .manage_accounts_outlined,
                    color: colorScheme
                        .onSecondaryContainer,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
          ),

          // ====================================================
          // RESET
          // ====================================================

          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Icon(
              Icons.restart_alt_rounded,
              color: colorScheme.primary,
            ),
            title: const Text(
              'Reset Profile Data',
            ),
            subtitle: const Text(
              'Clear name, location, phone and bio',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: onReset,
          ),

          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),

          // ====================================================
          // SUPPORT
          // ====================================================

          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Icon(
              Icons.support_agent_outlined,
              color: colorScheme.primary,
            ),
            title: const Text(
              'Help & Support',
            ),
            subtitle: const Text(
              'Get help or contact GreenMind AI support',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: onSupport,
          ),

          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),

          // ====================================================
          // FEEDBACK
          // ====================================================

          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Icon(
              Icons.feedback_outlined,
              color: colorScheme.primary,
            ),
            title: const Text(
              'Send Feedback',
            ),
            subtitle: const Text(
              'Share your experience with GreenMind AI',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: onFeedback,
          ),

          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),

          // ====================================================
          // SIGN OUT
          // ====================================================

          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Icon(
              Icons.logout_rounded,
              color: colorScheme.error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Sign out of your GreenMind AI account',
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.error,
            ),
            onTap: onSignOut,
          ),

          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR MESSAGE
// ============================================================================

class _ErrorMessage
    extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme
            .errorContainer,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.error
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color:
                colorScheme.onErrorContainer,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme
                    .onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}