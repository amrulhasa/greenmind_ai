import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home_provider.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  void _handleNavigation(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) {
    final notifier = ref.read(homeProvider.notifier);

    notifier.changeTab(index);

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
        // Profile screen will be connected when Phase 6 is implemented.
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return NavigationBar(
      height: 72,
      selectedIndex: state.selectedIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }

          return AppTextStyles.caption;
        },
      ),
      onDestinationSelected: (index) {
        _handleNavigation(
          context,
          ref,
          index,
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.eco_outlined),
          selectedIcon: Icon(Icons.eco),
          label: 'Identify',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat),
          label: 'AI Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}