import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../announcements/providers/announcement_badge_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../reminder/providers/notification_badge_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
  });

  // ==========================================================================
  // OPEN ANNOUNCEMENTS
  // ==========================================================================

  Future<void> _openAnnouncements(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(
          announcementBadgeProvider.notifier,
        )
        .markAllAsRead();

    if (!context.mounted) {
      return;
    }

    await context.push('/announcements');
  }

  // ==========================================================================
  // OPEN REMINDERS
  // ==========================================================================

  Future<void> _openReminders(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(
          notificationBadgeProvider.notifier,
        )
        .markAllAsRead();

    if (!context.mounted) {
      return;
    }

    await context.push('/reminders');
  }

  // ==========================================================================
  // GREETING
  // ==========================================================================

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

  // ==========================================================================
  // GREETING ICON
  // ==========================================================================

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

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final profile = ref.watch(profileProvider).profile;

    final reminderCount = ref.watch(
      notificationBadgeProvider,
    );

    final announcementCount = ref.watch(
      announcementBadgeProvider,
    );

    final String name = profile.name.trim();

    final String displayName = name.isEmpty
        ? 'Welcome Back'
        : 'Welcome, $name';

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        // ====================================================================
        // PROFILE AVATAR
        // ====================================================================

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.push('/profile');
          },
          child: _ProfileAvatar(
            imageBase64:
                profile.profileImagePath,
          ),
        ),

        const SizedBox(width: 14),

        // ====================================================================
        // GREETING + NAME
        // ====================================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------------------
              // GREETING CHIP
              // --------------------------------------------------------------

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        colors.primary.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      _getGreetingIcon(),
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              // --------------------------------------------------------------
              // USER NAME
              // --------------------------------------------------------------

              Text(
                displayName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.65,
                  color:
                      colors.onSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // ====================================================================
        // ANNOUNCEMENTS
        // ====================================================================

        _HeaderActionButton(
          icon: Icons.campaign_outlined,
          tooltip: 'Announcements',
          backgroundColor:
              colors.primary.withValues(
            alpha: 0.10,
          ),
          iconColor: colors.primary,
          badgeCount: announcementCount,
          onPressed: () {
            _openAnnouncements(
              context,
              ref,
            );
          },
        ),

        const SizedBox(width: 8),

        // ====================================================================
        // REMINDERS
        // ====================================================================

        _HeaderActionButton(
          icon:
              Icons.notifications_none_rounded,
          tooltip: 'Plant Reminders',
          backgroundColor:
              colors.surfaceContainerHighest,
          iconColor: colors.onSurface,
          badgeCount: reminderCount,
          onPressed: () {
            _openReminders(
              context,
              ref,
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// HEADER ACTION BUTTON
// ============================================================================

class _HeaderActionButton
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

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
                borderRadius:
                    BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.outline
                          .withValues(
                        alpha: 0.18,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(
                          alpha: 0.05,
                        ),
                        blurRadius: 13,
                        offset:
                            const Offset(0, 5),
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

          // ------------------------------------------------------------------
          // BADGE
          // ------------------------------------------------------------------

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

class _NotificationBadge
    extends StatelessWidget {
  const _NotificationBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final String text =
        count > 99 ? '99+' : '$count';

    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 21,
        minHeight: 21,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A00),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: colors.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.12,
            ),
            blurRadius: 5,
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

class _ProfileAvatar
    extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageBase64,
  });

  final String? imageBase64;

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    final bool hasImage =
        imageBase64 != null &&
        imageBase64!.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(
              alpha: 0.75,
            ),
            colors.primary,
          ],
        ),
        borderRadius:
            BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: colors.primary
                .withValues(
              alpha: 0.18,
            ),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: hasImage
            ? _buildImage(context)
            : _placeholder(context),
      ),
    );
  }

  // ==========================================================================
  // IMAGE
  // ==========================================================================

  Widget _buildImage(
    BuildContext context,
  ) {
    try {
      String value =
          imageBase64!.trim();

      // --------------------------------------------------------------
      // Support data:image/...;base64,... format
      // --------------------------------------------------------------

      if (value.contains(',')) {
        value = value.split(',').last;
      }

      final Uint8List bytes =
          base64Decode(value);

      if (bytes.isEmpty) {
        return _placeholder(context);
      }

      return Image.memory(
        bytes,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return _placeholder(context);
        },
      );
    } catch (_) {
      return _placeholder(context);
    }
  }

  // ==========================================================================
  // PLACEHOLDER
  // ==========================================================================

  Widget _placeholder(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      color: colors.primary,
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