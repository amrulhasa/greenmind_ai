import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../profile/providers/profile_provider.dart';
import '../../reminder/providers/notification_badge_provider.dart';
import '../../reminder/providers/reminder_provider.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({
    super.key,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  Timer? _refreshTimer;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // Refresh notification badge periodically.
    // ----------------------------------------------------------

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (!mounted) {
          return;
        }

        ref
            .read(notificationBadgeProvider.notifier)
            .refresh();
      },
    );

    // ----------------------------------------------------------
    // Initial badge refresh.
    // ----------------------------------------------------------

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(notificationBadgeProvider.notifier)
          .refresh();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

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
  // OPEN REMINDERS
  // ============================================================

  void _openReminders(BuildContext context) {
    context.push('/reminders');
  }

  // ============================================================
  // MARK NOTIFICATIONS AS READ + OPEN REMINDERS
  // ============================================================

  Future<void> _openNotifications(
    BuildContext context,
  ) async {
    // ----------------------------------------------------------
    // First clear the notification badge.
    // ----------------------------------------------------------

    await ref
        .read(notificationBadgeProvider.notifier)
        .markAllAsRead();

    // ----------------------------------------------------------
    // Make sure widget is still mounted.
    // ----------------------------------------------------------

    if (!context.mounted) {
      return;
    }

    // ----------------------------------------------------------
    // Then open reminders.
    // ----------------------------------------------------------

    _openReminders(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final profile = ref.watch(
      profileProvider,
    ).profile;

    final reminderState = ref.watch(
      reminderProvider,
    );

    final notificationCount = ref.watch(
      notificationBadgeProvider,
    );

    // ----------------------------------------------------------
    // Keep notification badge synchronized whenever
    // reminder state changes.
    // ----------------------------------------------------------

    ref.listen<ReminderState>(
      reminderProvider,
      (previous, next) {
        if (previous?.reminders != next.reminders) {
          Future.microtask(() {
            if (!mounted) {
              return;
            }

            ref
                .read(
                  notificationBadgeProvider.notifier,
                )
                .refresh();
          });
        }
      },
    );

    // Keep provider subscription active.
    reminderState;

    return Row(
      children: [
        // ========================================================
        // PROFILE AVATAR
        // ========================================================

        GestureDetector(
          onTap: () {
            context.push('/profile');
          },
          child: _ProfileAvatar(
            imageBase64: profile.profileImagePath,
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
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                profile.name.isEmpty
                    ? 'Welcome Back'
                    : 'Welcome, ${profile.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading2,
              ),
            ],
          ),
        ),

        const SizedBox(
          width: AppSpacing.sm,
        ),

        // ========================================================
        // NOTIFICATION BUTTON
        // ========================================================

        _NotificationButton(
          count: notificationCount,
          onPressed: () {
            _openNotifications(context);
          },
        ),
      ],
    );
  }
}

// ============================================================
// NOTIFICATION BUTTON
// ============================================================

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _NotificationButton({
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ----------------------------------------------------
          // BUTTON
          // ----------------------------------------------------

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppRadius.circular,
                ),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: IconButton(
                onPressed: onPressed,
                tooltip: 'Notifications',
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // BADGE
          // ----------------------------------------------------

          if (count > 0)
            Positioned(
              right: -3,
              top: -5,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 21,
                  minHeight: 21,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE AVATAR
// ============================================================

class _ProfileAvatar extends StatelessWidget {
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
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          AppRadius.circular,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppRadius.circular,
        ),
        child: imageBase64 != null &&
                imageBase64!.isNotEmpty
            ? _buildImage()
            : _placeholder(),
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildImage() {
    try {
      final bytes = base64Decode(
        imageBase64!,
      );

      return Image.memory(
        bytes,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _placeholder();
        },
      );
    } catch (_) {
      return _placeholder();
    }
  }

  // ============================================================
  // PROFILE PLACEHOLDER
  // ============================================================

  Widget _placeholder() {
    return const Icon(
      Icons.person,
      color: Colors.white,
      size: 30,
    );
  }
}