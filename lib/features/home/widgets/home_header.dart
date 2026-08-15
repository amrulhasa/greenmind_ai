import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  // ============================================================
  // GREETING
  // ============================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning 👋';
    }

    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon ☀️';
    }

    if (hour >= 17 && hour < 21) {
      return 'Good Evening 🌆';
    }

    return 'Good Night 🌙';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profile =
        ref.watch(profileProvider).profile;

    final imagePath =
        profile.profileImagePath;

    final hasImage =
        imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return Row(
      children: [
        // ========================================================
        // PROFILE AVATAR
        // ========================================================

        GestureDetector(
          onTap: () {
            context.push('/profile');
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(
                AppRadius.circular,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                AppRadius.circular,
              ),
              child: hasImage
                  ? Image.file(
                      File(imagePath),
                      key: ValueKey(
                        imagePath,
                      ),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.person,
                          color:
                              Colors.white,
                          size: 30,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color:
                          Colors.white,
                      size: 30,
                    ),
            ),
          ),
        ),

        const SizedBox(
          width: AppSpacing.md,
        ),

        // ========================================================
        // GREETING
        // ========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style:
                    AppTextStyles.subtitle,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                'Welcome Back',
                style:
                    AppTextStyles.heading2,
              ),
            ],
          ),
        ),

        // ========================================================
        // NOTIFICATION
        // ========================================================

        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppRadius.circular,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: IconButton(
            onPressed: () {
              context.push('/reminders');
            },
            icon: const Icon(
              Icons
                  .notifications_none_rounded,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}