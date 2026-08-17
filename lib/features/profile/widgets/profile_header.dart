import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onEditPhoto;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        profile.name.trim().isEmpty
            ? 'Plant Lover'
            : profile.name.trim();

    return Column(
      children: [
        // ==========================================================
        // PROFILE AVATAR
        // ==========================================================

        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _ProfileAvatar(
              imageBase64:
                  profile.profileImagePath,
              name: displayName,
            ),

            // ========================================================
            // EDIT PHOTO BUTTON
            // ========================================================

            if (onEditPhoto != null)
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),

                  elevation: 2,

                  child: InkWell(
                    customBorder:
                        const CircleBorder(),

                    onTap: onEditPhoto,

                    child: const Tooltip(
                      message: 'Change profile photo',

                      child: Padding(
                        padding:
                            EdgeInsets.all(9),

                        child: Icon(
                          Icons
                              .camera_alt_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        // ==========================================================
        // NAME
        // ==========================================================

        Text(
          displayName,

          textAlign:
              TextAlign.center,

          maxLines: 2,

          overflow:
              TextOverflow.ellipsis,

          style:
              AppTextStyles.heading2,
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        // ==========================================================
        // ACCOUNT EMAIL
        // ==========================================================

        if (profile.email.trim().isNotEmpty)
          _ProfileMetaRow(
            icon:
                Icons.verified_user_outlined,

            text:
                profile.email.trim(),

            tooltip:
                'Account email',
          ),

        // ==========================================================
        // LOCATION
        // ==========================================================

        if (profile.location
            .trim()
            .isNotEmpty) ...[
          const SizedBox(
            height: AppSpacing.xs,
          ),

          _ProfileMetaRow(
            icon:
                Icons.location_on_outlined,

            text:
                profile.location.trim(),

            tooltip:
                'Location',
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// PROFILE META ROW
// ============================================================================

class _ProfileMetaRow
    extends StatelessWidget {
  final IconData icon;
  final String text;
  final String tooltip;

  const _ProfileMetaRow({
    required this.icon,
    required this.text,
    required this.tooltip,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.primary,
        ),

        const SizedBox(
          width: 5,
        ),

        Flexible(
          child: Tooltip(
            message: tooltip,

            child: Text(
              text,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              textAlign:
                  TextAlign.center,

              style:
                  AppTextStyles.caption,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PROFILE AVATAR
// ============================================================================

class _ProfileAvatar
    extends StatelessWidget {
  final String? imageBase64;
  final String name;

  const _ProfileAvatar({
    required this.imageBase64,
    required this.name,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final encoded =
        imageBase64?.trim();

    // ==============================================================
    // NO IMAGE
    // ==============================================================

    if (encoded == null ||
        encoded.isEmpty) {
      return _avatarWithInitials();
    }

    // ==============================================================
    // BASE64 IMAGE
    // ==============================================================

    try {
      final bytes =
          base64Decode(encoded);

      if (bytes.isEmpty) {
        return _avatarWithInitials();
      }

      return Container(
        width: 112,
        height: 112,

        padding: const EdgeInsets.all(2),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          border: Border.all(
            color:
                AppColors.primary
                    .withValues(
              alpha: 0.25,
            ),
            width: 2,
          ),
        ),

        child: ClipOval(
          child: Image.memory(
            bytes,

            width: 108,
            height: 108,

            fit: BoxFit.cover,

            gaplessPlayback: true,

            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return _avatarWithInitials();
            },
          ),
        ),
      );
    } catch (_) {
      return _avatarWithInitials();
    }
  }

  // ==============================================================
  // INITIALS AVATAR
  // ==============================================================

  Widget _avatarWithInitials() {
    final initials =
        _getInitials(name);

    return Container(
      width: 112,
      height: 112,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color:
            AppColors.primary
                .withValues(
          alpha: 0.10,
        ),

        border: Border.all(
          color:
              AppColors.primary
                  .withValues(
            alpha: 0.20,
          ),
          width: 2,
        ),
      ),

      child: Center(
        child: Text(
          initials,

          textAlign:
              TextAlign.center,

          style: const TextStyle(
            fontSize: 32,
            fontWeight:
                FontWeight.w700,
            color:
                AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // GET INITIALS
  // ==============================================================

  String _getInitials(
    String value,
  ) {
    final cleanName =
        value.trim();

    if (cleanName.isEmpty) {
      return 'P';
    }

    final parts =
        cleanName.split(
      RegExp(r'\s+'),
    );

    // --------------------------------------------------------------
    // TWO OR MORE WORDS
    // --------------------------------------------------------------

    if (parts.length >= 2) {
      final first =
          parts.first.trim();

      final last =
          parts.last.trim();

      if (first.isNotEmpty &&
          last.isNotEmpty) {
        return '${first[0]}${last[0]}'
            .toUpperCase();
      }
    }

    // --------------------------------------------------------------
    // SINGLE WORD
    // --------------------------------------------------------------

    return parts.first
        .substring(0, 1)
        .toUpperCase();
  }
}