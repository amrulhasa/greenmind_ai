import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  // ============================================================
  // GET SELECTED TAB FROM CURRENT ROUTE
  // ============================================================

  int _getSelectedIndex(
    String location,
  ) {
    switch (location) {
      case '/identify':
        return 1;

      case '/chatbot':
        return 2;

      case '/profile':
        return 3;

      case '/home':
      default:
        return 0;
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _handleNavigation(
    BuildContext context,
    int index,
  ) {
    switch (index) {
      case 0:
        context.go('/home');
        break;

      case 1:
        context.go('/identify');
        break;

      case 2:
        context.go('/chatbot');
        break;

      case 3:
        context.go('/profile');
        break;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final location =
        GoRouterState.of(context)
            .uri
            .path;

    final selectedIndex =
        _getSelectedIndex(location);

    return NavigationBar(
      height: 72,

      selectedIndex: selectedIndex,

      backgroundColor:
          AppColors.surface,

      indicatorColor:
          AppColors.primary.withValues(
        alpha: 0.12,
      ),

      labelTextStyle:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return AppTextStyles.caption
                .copyWith(
              color:
                  AppColors.primary,
              fontWeight:
                  FontWeight.w600,
            );
          }

          return AppTextStyles.caption;
        },
      ),

      onDestinationSelected: (
        index,
      ) {
        _handleNavigation(
          context,
          index,
        );
      },

      destinations: const [
        // ========================================================
        // HOME
        // ========================================================

        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
          ),
          selectedIcon: Icon(
            Icons.home,
          ),
          label: 'Home',
        ),

        // ========================================================
        // IDENTIFY
        // ========================================================

        NavigationDestination(
          icon: Icon(
            Icons.eco_outlined,
          ),
          selectedIcon: Icon(
            Icons.eco,
          ),
          label: 'Identify',
        ),

        // ========================================================
        // AI CHAT
        // ========================================================

        NavigationDestination(
          icon: Icon(
            Icons.chat_bubble_outline,
          ),
          selectedIcon: Icon(
            Icons.chat,
          ),
          label: 'AI Chat',
        ),

        // ========================================================
        // PROFILE
        // ========================================================

        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
          ),
          selectedIcon: Icon(
            Icons.person,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}