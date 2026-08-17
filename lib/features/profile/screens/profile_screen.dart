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

    // ============================================================
    // LOADING
    // ============================================================

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ============================================================
    // SCREEN
    // ============================================================

    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

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

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: notifier.reloadProfile,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
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
                    message:
                        state.errorMessage!,
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
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              // ==================================================
              // CAMERA
              // ==================================================

              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text(
                  'Camera',
                ),
                onTap: () async {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  await notifier
                      .changeProfilePicture(
                    source:
                        ImageSource.camera,
                  );
                },
              ),

              // ==================================================
              // GALLERY
              // ==================================================

              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text(
                  'Gallery',
                ),
                onTap: () async {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  await notifier
                      .changeProfilePicture(
                    source:
                        ImageSource.gallery,
                  );
                },
              ),

              // ==================================================
              // REMOVE PHOTO
              // ==================================================

              if (profile.profileImagePath !=
                      null &&
                  profile.profileImagePath!
                      .isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    await notifier
                        .removeProfilePicture();
                  },
                ),

              const SizedBox(
                height: 8,
              ),
            ],
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
                .read(
                  profileProvider.notifier,
                )
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

    // ==========================================================
    // SUCCESS MESSAGE
    // ==========================================================

    if (result == true &&
        context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
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
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
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
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
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

      // ========================================================
      // SUCCESS
      // ========================================================

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

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
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

            TextField(
              controller:
                  _nameController,
              enabled: !_saving,
              textCapitalization:
                  TextCapitalization.words,
              decoration:
                  const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // EMAIL
            // ==================================================

            TextField(
              enabled: false,
              controller:
                  TextEditingController(
                text:
                    widget.profile.email,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
                helperText:
                    'Linked to your account',
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // LOCATION
            // ==================================================

            TextField(
              controller:
                  _locationController,
              enabled: !_saving,
              textCapitalization:
                  TextCapitalization.words,
              decoration:
                  const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // PHONE
            // ==================================================

            TextField(
              controller:
                  _phoneController,
              enabled: !_saving,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // BIO
            // ==================================================

            TextField(
              controller:
                  _bioController,
              enabled: !_saving,
              maxLines: 3,
              maxLength: 150,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration:
                  const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.info_outline,
                ),
              ),
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

        FilledButton(
          onPressed:
              _saving ? null : _save,
          child: _saving
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
      height: 50,
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
    return Card(
      elevation: 0,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.settings_outlined,
            ),
            title: Text(
              'Preferences',
            ),
          ),

          // ==================================================
          // NOTIFICATIONS
          // ==================================================

          SwitchListTile(
            value: state
                .profile
                .notificationsEnabled,
            onChanged: (_) {
              notifier
                  .toggleNotifications();
            },
            title: const Text(
              'Notifications',
            ),
            subtitle: const Text(
              'Receive plant care reminders and updates',
            ),
            secondary: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          // ==================================================
          // DARK MODE
          // ==================================================

          SwitchListTile(
            value: state
                .profile
                .darkModeEnabled,
            onChanged: (_) {
              notifier.toggleDarkMode();
            },
            title: const Text(
              'Dark Mode',
            ),
            subtitle: const Text(
              'Use dark appearance',
            ),
            secondary: const Icon(
              Icons.dark_mode_outlined,
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
  final VoidCallback onSignOut;

  const _AccountCard({
    required this.onReset,
    required this.onSignOut,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 0,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.manage_accounts_outlined,
            ),
            title: Text(
              'Account',
            ),
          ),

          // ==================================================
          // RESET
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.restart_alt_rounded,
            ),
            title: const Text(
              'Reset Profile Data',
            ),
            subtitle: const Text(
              'Clear name, location, phone and bio',
            ),
            onTap: onReset,
          ),

          const Divider(
            height: 1,
          ),

          // ==================================================
          // SIGN OUT
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: onSignOut,
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
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}