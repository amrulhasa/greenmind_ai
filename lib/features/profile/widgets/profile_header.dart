import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/profile_provider.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  const ProfileHeader({super.key});

  @override
  ConsumerState<ProfileHeader> createState() =>
      _ProfileHeaderState();
}

class _ProfileHeaderState
    extends ConsumerState<ProfileHeader> {
  bool _isPickingImage = false;

  // ============================================================
  // CHANGE PROFILE PICTURE
  // ============================================================

  Future<void> _changeProfilePicture() async {
    if (_isPickingImage) {
      return;
    }

    final source =
        await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CAMERA
                // ==================================================

                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration:
                        BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color:
                          AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Use your camera',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.camera,
                    );
                  },
                ),

                // ==================================================
                // GALLERY
                // ==================================================

                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration:
                        BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color:
                          AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Select an existing photo',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .changeProfilePicture(
        source: source,
      );

      if (!mounted) {
        return;
      }

      final error =
          ref.read(profileProvider).errorMessage;

      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to change profile picture.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(profileProvider);

    final profile = state.profile;

    final imagePath =
        profile.profileImagePath;

    final hasImage =
        imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================================================
          // PROFILE IMAGE
          // ========================================================

          GestureDetector(
            onTap: _changeProfilePicture,
            child: Stack(
              clipBehavior:
                  Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primary,
                    shape:
                        BoxShape.circle,
                    border: Border.all(
                      color:
                          AppColors.surface,
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: hasImage
                        ? Image.file(
                            File(imagePath),
                            key: ValueKey(
                              imagePath,
                            ),
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .person_rounded,
                                color:
                                    Colors.white,
                                size: 48,
                              );
                            },
                          )
                        : const Icon(
                            Icons
                                .person_rounded,
                            color:
                                Colors.white,
                            size: 48,
                          ),
                  ),
                ),

                // ==================================================
                // CAMERA BUTTON
                // ==================================================

                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration:
                        const BoxDecoration(
                      color:
                          AppColors.primary,
                      shape:
                          BoxShape.circle,
                    ),
                    child:
                        _isPickingImage
                            ? const Padding(
                                padding:
                                    EdgeInsets
                                        .all(
                                  9,
                                ),
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .camera_alt_rounded,
                                color:
                                    Colors.white,
                                size: 20,
                              ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          // ========================================================
          // NAME
          // ========================================================

          Text(
            profile.name,
            style:
                AppTextStyles.heading2,
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height: AppSpacing.xs,
          ),

          // ========================================================
          // EMAIL
          // ========================================================

          Text(
            profile.email,
            style: AppTextStyles.body,
            textAlign:
                TextAlign.center,
          ),

          // ========================================================
          // BIO
          // ========================================================

          if (profile.bio.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Text(
              profile.bio,
              style:
                  AppTextStyles.caption,
              textAlign:
                  TextAlign.center,
            ),
          ],

          // ========================================================
          // LOCATION
          // ========================================================

          if (profile.location.isNotEmpty) ...[
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons
                      .location_on_outlined,
                  size: 17,
                  color: AppColors
                      .textSecondary,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  profile.location,
                  style:
                      AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}