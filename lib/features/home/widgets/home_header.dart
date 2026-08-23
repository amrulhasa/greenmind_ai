import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../announcements/providers/announcement_badge_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../reminder/providers/notification_badge_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  Future<void> _openAnnouncements(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(announcementBadgeProvider.notifier)
        .markAllAsRead();

    if (!context.mounted) return;

    await context.push('/announcements');
  }

  Future<void> _openReminders(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(notificationBadgeProvider.notifier)
        .markAllAsRead();

    if (!context.mounted) return;

    await context.push('/reminders');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    }

    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    }

    if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    }

    return 'Good Night';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny_rounded;
    }

    if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny_outlined;
    }

    if (hour >= 17 && hour < 21) {
      return Icons.wb_twilight_rounded;
    }

    return Icons.nightlight_round;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final reminderCount = ref.watch(
      notificationBadgeProvider,
    );

    final announcementCount = ref.watch(
      announcementBadgeProvider,
    );

    final displayName = profile.name.trim().isEmpty
        ? 'Welcome Back'
        : 'Welcome, ${profile.name.trim()}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =========================================================
        // PROFILE
        // =========================================================

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push('/profile'),
          child: _ProfileAvatar(
            imageBase64: profile.profileImagePath,
          ),
        ),

        const SizedBox(width: 14),

        // =========================================================
        // GREETING
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDDEBDF),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getGreetingIcon(),
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E6B43),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.65,
                  color: Color(0xFF172018),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // =========================================================
        // ANNOUNCEMENTS
        // =========================================================

        _HeaderActionButton(
          icon: Icons.campaign_outlined,
          tooltip: 'Announcements',
          backgroundColor: const Color(0xFFEAF5EC),
          iconColor: AppColors.primary,
          badgeCount: announcementCount,
          onPressed: () {
            _openAnnouncements(context, ref);
          },
        ),

        const SizedBox(width: 8),

        // =========================================================
        // REMINDERS
        // =========================================================

        _HeaderActionButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Plant Reminders',
          backgroundColor: Colors.white,
          iconColor: const Color(0xFF344139),
          badgeCount: reminderCount,
          onPressed: () {
            _openReminders(context, ref);
          },
        ),
      ],
    );
  }
}

// ============================================================================
// HEADER ACTION
// ============================================================================

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE0E9E1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF18351C)
                            .withValues(alpha: 0.035),
                        blurRadius: 13,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Tooltip(
                    message: tooltip,
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (badgeCount > 0)
            Positioned(
              right: -5,
              top: -7,
              child: _NotificationBadge(
                count: badgeCount,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// NOTIFICATION BADGE
// ============================================================================

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(
        minWidth: 21,
        minHeight: 21,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A00),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A00)
                .withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PROFILE AVATAR
// ============================================================================

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageBase64,
  });

  final String? imageBase64;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageBase64 != null &&
        imageBase64!.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF55A35B),
            Color(0xFF267331),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasImage
            ? _buildImage()
            : _placeholder(),
      ),
    );
  }

  Widget _buildImage() {
    try {
      var value = imageBase64!.trim();

      if (value.contains(',')) {
        value = value.split(',').last;
      }

      final Uint8List bytes = base64Decode(value);

      return Image.memory(
        bytes,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        gaplessPlayback: true,
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

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2E7D32),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}