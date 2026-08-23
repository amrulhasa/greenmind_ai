import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({
    super.key,
  });

  int _getSelectedIndex(
    String location,
  ) {
    if (location.startsWith('/identify')) {
      return 1;
    }

    if (location.startsWith('/chatbot')) {
      return 2;
    }

    if (location.startsWith('/profile')) {
      return 3;
    }

    return 0;
  }

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

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    final location =
        GoRouterState.of(
      context,
    ).uri.path;

    final selectedIndex =
        _getSelectedIndex(location);

    return SafeArea(
      top: false,
      child: Container(
        margin:
            const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          12,
        ),
        padding:
            const EdgeInsets.all(7),
        decoration:
            BoxDecoration(
          color:
              colors.surface,
          borderRadius:
              BorderRadius.circular(25),
          border:
              Border.all(
            color:
                colors.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha:
                    theme.brightness ==
                            Brightness.dark
                        ? 0.28
                        : 0.08,
              ),
              blurRadius: 28,
              offset:
                  const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon:
                    Icons.home_outlined,
                selectedIcon:
                    Icons.home_rounded,
                label: 'Home',
                selected:
                    selectedIndex == 0,
                onTap: () =>
                    _handleNavigation(
                  context,
                  0,
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon:
                    Icons.eco_outlined,
                selectedIcon:
                    Icons.eco_rounded,
                label: 'Identify',
                selected:
                    selectedIndex == 1,
                onTap: () =>
                    _handleNavigation(
                  context,
                  1,
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons
                    .chat_bubble_outline_rounded,
                selectedIcon:
                    Icons.chat_rounded,
                label: 'AI Chat',
                selected:
                    selectedIndex == 2,
                onTap: () =>
                    _handleNavigation(
                  context,
                  2,
                ),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon:
                    Icons.person_outline_rounded,
                selectedIcon:
                    Icons.person_rounded,
                label: 'Profile',
                selected:
                    selectedIndex == 3,
                onTap: () =>
                    _handleNavigation(
                  context,
                  3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Material(
      color:
          Colors.transparent,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 220,
          ),
          curve:
              Curves.easeOutCubic,
          height: 58,
          decoration:
              BoxDecoration(
            color: selected
                ? colors.primary
                    .withValues(
                    alpha: 0.12,
                  )
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? selectedIcon
                    : icon,
                size: 22,
                color: selected
                    ? colors.primary
                    : colors
                        .onSurfaceVariant,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                label,
                style:
                    TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected
                      ? colors.primary
                      : colors
                          .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}