import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../nursery/screens/nearby_nursery_screen.dart';
import '../plant_report/screens/plant_report_screen.dart';

import 'widgets/bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_plants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F3),
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ==========================================================
            // PREMIUM BACKGROUND
            // ==========================================================

            const _HomeBackground(),

            // ==========================================================
            // CONTENT
            // ==========================================================

            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 900;

                final double horizontalPadding = isWide
                    ? ((constraints.maxWidth - 1180) / 2).clamp(
                        24.0,
                        80.0,
                      )
                    : 20.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1180,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        const HomeHeader(),

                        const SizedBox(height: 28),

                        // ==================================================
                        // HERO FEATURES
                        // ==================================================

                        const FeatureCard(),

                        const SizedBox(height: 22),

                        // ==================================================
                        // QUICK ACTIONS
                        // ==================================================

                        const _QuickActionsCard(),

                        const SizedBox(height: 22),

                        // ==================================================
                        // SECONDARY FEATURES
                        // ==================================================

                        if (isWide)
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _PlantReportCard(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PlantReportScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _NearbyNurseryCard(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NearbyNurseryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _PlantReportCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PlantReportScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _NearbyNurseryCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NearbyNurseryScreen(),
                                ),
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: 30),

                        // ==================================================
                        // RECENT PLANTS
                        // ==================================================

                        const RecentPlants(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PREMIUM HOME BACKGROUND
// ============================================================================

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Main soft gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7FBF7),
                    Color(0xFFF2F7F2),
                    Color(0xFFEEF5EF),
                  ],
                ),
              ),
            ),
          ),

          // Top green glow
          Positioned(
            top: -150,
            left: -120,
            child: _GlowCircle(
              size: 360,
              color: Color(0xFFBFE4C5),
              opacity: 0.28,
            ),
          ),

          // Top-right glow
          Positioned(
            top: -100,
            right: -140,
            child: _GlowCircle(
              size: 340,
              color: Color(0xFFD7EFD9),
              opacity: 0.45,
            ),
          ),

          // Middle decorative glow
          Positioned(
            top: 430,
            right: -180,
            child: _GlowCircle(
              size: 380,
              color: Color(0xFFCDE8D0),
              opacity: 0.20,
            ),
          ),

          // Bottom glow
          Positioned(
            bottom: -180,
            left: -150,
            child: _GlowCircle(
              size: 400,
              color: Color(0xFFB9DDBE),
              opacity: 0.18,
            ),
          ),

          // Subtle decorative leaves
          Positioned(
            top: 115,
            right: 25,
            child: Transform.rotate(
              angle: -0.35,
              child: Icon(
                Icons.eco_rounded,
                size: 75,
                color: const Color(0xFF2E7D32).withValues(
                  alpha: 0.035,
                ),
              ),
            ),
          ),

          Positioned(
            top: 390,
            left: 8,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                Icons.spa_rounded,
                size: 90,
                color: const Color(0xFF2E7D32).withValues(
                  alpha: 0.025,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GLOW CIRCLE
// ============================================================================

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(
          alpha: opacity,
        ),
      ),
    );
  }
}

// ============================================================================
// QUICK ACTIONS
// ============================================================================

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFDDE9DE),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18351C).withValues(
              alpha: 0.045,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE7F5E9),
                      Color(0xFFD8EEDB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 21,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF182019),
                        letterSpacing: -0.25,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Everything you need, one tap away',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF7A857C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 500;

              if (compact) {
                return Column(
                  children: [
                    _QuickActionItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Reminders',
                      subtitle: 'Plant care',
                      iconBackground: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF2E7D32),
                      onTap: () {
                        context.push('/reminders');
                      },
                    ),
                    const SizedBox(height: 10),
                    _QuickActionItem(
                      icon: Icons.campaign_outlined,
                      title: 'Announcements',
                      subtitle: 'Latest updates',
                      iconBackground: const Color(0xFFFFF3E2),
                      iconColor: const Color(0xFFEF6C00),
                      onTap: () {
                        context.push('/announcements');
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _QuickActionItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Reminders',
                      subtitle: 'Plant care',
                      iconBackground: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF2E7D32),
                      onTap: () {
                        context.push('/reminders');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionItem(
                      icon: Icons.campaign_outlined,
                      title: 'Announcements',
                      subtitle: 'Latest updates',
                      iconBackground: const Color(0xFFFFF3E2),
                      iconColor: const Color(0xFFEF6C00),
                      onTap: () {
                        context.push('/announcements');
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK ACTION ITEM
// ============================================================================

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBF8),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFE1EAE2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243026),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7B867D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE0E8E1),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PLANT CARE REPORT
// ============================================================================

class _PlantReportCard extends StatelessWidget {
  const _PlantReportCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE5F4E7),
            Color(0xFFF9FCF9),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD3E7D6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(
              alpha: 0.06,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PremiumIconBox(
                icon: Icons.auto_awesome_rounded,
                background: Colors.white,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Care Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18351C),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI-powered personalized care plan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF68786B),
                      ),
                    ),
                  ],
                ),
              ),
              const _SmallAiBadge(),
            ],
          ),

          const SizedBox(height: 17),

          const Text(
            'Analyze your plant and receive personalized '
            'recommendations for watering, light, soil and care.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF657468),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(
                child: _ReportFeature(
                  icon: Icons.water_drop_outlined,
                  title: 'Watering',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ReportFeature(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Light',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ReportFeature(
                  icon: Icons.spa_outlined,
                  title: 'Care',
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
              ),
              label: const Text(
                'Create Care Report',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// NEARBY NURSERY
// ============================================================================

class _NearbyNurseryCard extends StatelessWidget {
  const _NearbyNurseryCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE0E9E1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18351C).withValues(
              alpha: 0.04,
            ),
            blurRadius: 28,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PremiumIconBox(
                icon: Icons.location_on_rounded,
                background: const Color(0xFFEAF5EC),
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Nurseries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D261F),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Find plant nurseries near you',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF778078),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8F5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE1E9E2),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xFF68736A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE7EEE7),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.near_me_rounded,
                  size: 17,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Discover trusted plant stores around your location',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: Color(0xFF69756C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(
                Icons.map_outlined,
                size: 18,
              ),
              label: const Text(
                'Explore Nearby',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(
                  color: Color(0xFFBFD8C2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PREMIUM ICON BOX
// ============================================================================

class _PremiumIconBox extends StatelessWidget {
  const _PremiumIconBox({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 25,
        color: color,
      ),
    );
  }
}

// ============================================================================
// AI BADGE
// ============================================================================

class _SmallAiBadge extends StatelessWidget {
  const _SmallAiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD8E8DA),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 13,
            color: Color(0xFF2E7D32),
          ),
          SizedBox(width: 4),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REPORT FEATURE
// ============================================================================

class _ReportFeature extends StatelessWidget {
  const _ReportFeature({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.82,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFDDE9DE),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF3F7D45),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF526456),
              ),
            ),
          ),
        ],
      ),
    );
  }
}