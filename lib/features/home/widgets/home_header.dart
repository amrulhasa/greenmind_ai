import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
  });

  String _getGreeting() {
    final hour =
        DateTime.now().hour;

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

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profile =
        ref.watch(
      profileProvider,
    ).profile;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.push(
              '/profile',
            );
          },
          child: _ProfileAvatar(
            imageBase64:
                profile.profileImagePath,
          ),
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
                _getGreeting(),
                style:
                    AppTextStyles.subtitle,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                profile.name.isEmpty
                    ? 'Welcome Back'
                    : 'Welcome, ${profile.name}',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    AppTextStyles.heading2,
              ),
            ],
          ),
        ),

        Container(
          width: 50,
          height: 50,
          decoration:
              BoxDecoration(
            color:
                AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppRadius.circular,
            ),
            border: Border.all(
              color:
                  AppColors.border,
            ),
          ),
          child: IconButton(
            onPressed: () {
              context.push(
                '/reminders',
              );
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

// ============================================================
// PROFILE AVATAR
// ============================================================

class _ProfileAvatar
    extends StatelessWidget {
  final String? imageBase64;

  const _ProfileAvatar({
    required this.imageBase64,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 56,
      height: 56,
      decoration:
          BoxDecoration(
        color:
            AppColors.primary,
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
        child:
            imageBase64 != null &&
                    imageBase64!
                        .isNotEmpty
                ? _buildImage()
                : _placeholder(),
      ),
    );
  }

  Widget _buildImage() {
    try {
      final bytes =
          base64Decode(
        imageBase64!,
      );

      return Image.memory(
        bytes,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return _placeholder();
        },
      );
    } catch (_) {
      return _placeholder();
    }
  }

  Widget _placeholder() {
    return const Icon(
      Icons.person,
      color: Colors.white,
      size: 30,
    );
  }
}