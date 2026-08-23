import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 245,
      decoration: const BoxDecoration(
        color: Color(0xFF173D1B),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // LOGO
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                22,
                24,
                22,
                28,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 11),

                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GreenMind',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'AI ADMIN',
                        style: TextStyle(
                          color: Color(0xFFB8D9BA),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // NAVIGATION
            // ==================================================

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildSectionLabel('MAIN'),

                  _buildItem(
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                  ),

                  _buildItem(
                    index: 1,
                    icon: Icons.people_outline_rounded,
                    selectedIcon: Icons.people_rounded,
                    title: 'Users',
                  ),

                  _buildItem(
                    index: 2,
                    icon: Icons.eco_outlined,
                    selectedIcon: Icons.eco_rounded,
                    title: 'Identifications',
                  ),

                  _buildItem(
                    index: 3,
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description_rounded,
                    title: 'Care Reports',
                  ),

                  const SizedBox(height: 18),

                  _buildSectionLabel('ANALYTICS'),

                  _buildItem(
                    index: 4,
                    icon: Icons.analytics_outlined,
                    selectedIcon: Icons.analytics_rounded,
                    title: 'Analytics',
                  ),

                  _buildItem(
                    index: 5,
                    icon: Icons.history_rounded,
                    selectedIcon: Icons.history_rounded,
                    title: 'Activity',
                  ),

                  const SizedBox(height: 18),

                  _buildSectionLabel('SYSTEM'),

                  _buildItem(
                    index: 6,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    title: 'Settings',
                  ),
                ],
              ),
            ),

            // ==================================================
            // ADMIN PROFILE
            // ==================================================

            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 19,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrator',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: Color(0xFFB8D9BA),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Color(0xFFB8D9BA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF88B58B),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _buildItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
  }) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => onItemSelected(index),
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.13)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 20,
                  color: selected
                      ? Colors.white
                      : const Color(0xFFA9C8AB),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFFA9C8AB),
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),

                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}