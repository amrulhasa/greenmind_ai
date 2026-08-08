import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final state = ref.read(profileProvider);

    final nameController = TextEditingController(
      text: state.profile.name,
    );
    final emailController = TextEditingController(
      text: state.profile.email,
    );
    final locationController = TextEditingController(
      text: state.profile.location,
    );
    final bioController = TextEditingController(
      text: state.profile.bio,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: bioController,
                  maxLines: 2,
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(profileProvider.notifier)
                    .updateProfile(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      location: locationController.text.trim(),
                      bio: bioController.text.trim(),
                    );

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    bioController.dispose();
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
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
                    _editProfile(context, ref);
                  },
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),
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

                      SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle:
                            'Manage plant care notifications',
                        trailing: Switch(
                          value:
                              state.profile.notificationsEnabled,
                          onChanged: (_) {
                            ref
                                .read(
                                  profileProvider.notifier,
                                )
                                .toggleNotifications();
                          },
                          activeThumbColor:
                              AppColors.primary,
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle:
                            'Save your preferred theme',
                        trailing: Switch(
                          value:
                              state.profile.darkModeEnabled,
                          onChanged: (_) {
                            ref
                                .read(
                                  profileProvider.notifier,
                                )
                                .toggleDarkMode();
                          },
                          activeThumbColor:
                              AppColors.primary,
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About GreenMind AI',
                        subtitle:
                            'AI-powered plant care assistant',
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),

                      SettingsTile(
                        icon: Icons.refresh_rounded,
                        title: 'Reset Profile',
                        subtitle:
                            'Restore default profile data',
                        onTap: () {
                          _confirmReset(context, ref);
                        },
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      Center(
                        child: Text(
                          'GreenMind AI • Version 1.0.0',
                          style: AppTextStyles.caption.copyWith(
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
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GreenMind AI',
      applicationVersion: '1.0.0',
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

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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