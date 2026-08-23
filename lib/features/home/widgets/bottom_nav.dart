import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  int _getSelectedIndex(String location) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(location);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          12,
        ),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFFE0E8E1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18351C).withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => _handleNavigation(context, 0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.eco_outlined,
                selectedIcon: Icons.eco_rounded,
                label: 'Identify',
                selected: selectedIndex == 1,
                onTap: () => _handleNavigation(context, 1),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_rounded,
                label: 'AI Chat',
                selected: selectedIndex == 2,
                onTap: () => _handleNavigation(context, 2),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
                selected: selectedIndex == 3,
                onTap: () => _handleNavigation(context, 3),
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 58,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEAF5EC)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: selected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF68736A),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF707A72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}