import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/user_profile.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style:
                AppTextStyles.heading3,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _InfoRow(
            icon:
                Icons.person_outline_rounded,
            label: 'Name',
            value: profile.name,
          ),

          const Divider(height: 24),

          _InfoRow(
            icon:
                Icons.email_outlined,
            label: 'Email',
            value: profile.email.isEmpty
                ? 'Not available'
                : profile.email,
            trailing:
                const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ),

          const Divider(height: 24),

          _InfoRow(
            icon:
                Icons.location_on_outlined,
            label: 'Location',
            value:
                profile.location.isEmpty
                    ? 'Not set'
                    : profile.location,
          ),

          const Divider(height: 24),

          _InfoRow(
            icon:
                Icons.phone_outlined,
            label: 'Phone',
            value: profile.phone.isEmpty
                ? 'Not set'
                : profile.phone,
          ),

          const Divider(height: 24),

          _InfoRow(
            icon:
                Icons.info_outline_rounded,
            label: 'Bio',
            value:
                profile.bio.isEmpty
                    ? 'Not set'
                    : profile.bio,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: AppColors.primary,
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTextStyles.caption,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                value,
                style:
                    AppTextStyles.body,
              ),
            ],
          ),
        ),

        if (trailing != null)
          Padding(
            padding:
                const EdgeInsets.only(
              left: 8,
              top: 18,
            ),
            child: trailing,
          ),
      ],
    );
  }
}